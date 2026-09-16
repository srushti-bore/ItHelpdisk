from datetime import datetime, timedelta, timezone
from typing import Dict, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.config import settings
from backend.core.exceptions import (
    AccountConflictError,
    AppException,
    NotFoundError,
    PermissionDeniedError,
    ValidationError,
)
from backend.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_password_hash,
    verify_password,
)
from backend.models.enums import AuthProviderType, AvailabilityStatus, UserRole
from backend.models.user import User
from backend.providers.auth.google_auth import get_auth_provider
from backend.providers.notifications.email import get_notification_provider
from backend.repositories.user_repo import user_repository
from backend.schemas.auth import (
    GoogleAuthRequest,
    PasswordResetConfirmRequest,
    RefreshTokenRequest,
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
)


class AuthService:
    """
    Authentication & Identity Service per SRS v3.3 §3.1, §3.3a, §4, §7.4.
    Handles Password + JWT and Google OAuth 2.0 / OIDC sign-in paths.
    """

    async def register_user(self, db: AsyncSession, req: UserRegisterRequest) -> User:
        # 1. Check if email already registered
        existing_user = await user_repository.get_by_email(db, req.email)
        if existing_user:
            raise AccountConflictError(message="An account with this email address already exists")

        # 2. Local vs Production email verification behavior per SRS §3.3a
        is_auto_verified = settings.ENVIRONMENT == "local"

        user = User(
            email=req.email.lower(),
            full_name=req.full_name,
            password_hash=get_password_hash(req.password),
            auth_provider=AuthProviderType.PASSWORD,
            role=UserRole.REQUESTER,
            site=req.site,
            availability_status=AvailabilityStatus.AVAILABLE,
            email_verified=is_auto_verified,
            is_active=True,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

        # 3. Send verification email if not auto-verified
        if not is_auto_verified:
            token = create_access_token(
                subject=str(user.id),
                extra_claims={"type": "email_verification", "email": user.email},
            )
            verify_url = f"{settings.API_V1_STR}/auth/verify-email?token={token}"
            notifier = get_notification_provider()
            await notifier.send_verification_email(user.email, verify_url)

        return user

    async def login_user(self, db: AsyncSession, req: UserLoginRequest) -> TokenResponse:
        user = await user_repository.get_by_email(db, req.email)
        if not user or not user.password_hash:
            raise PermissionDeniedError(message="Invalid email or password")

        if not verify_password(req.password, user.password_hash):
            raise PermissionDeniedError(message="Invalid email or password")

        if not user.is_active:
            raise PermissionDeniedError(message="This account has been deactivated")

        # Email verification enforcement in production per SRS §3.3a
        if settings.ENVIRONMENT == "production" and not user.email_verified:
            raise PermissionDeniedError(message="Please verify your email address before logging in")

        # Generate tokens
        access_token = create_access_token(
            subject=str(user.id),
            extra_claims={"role": user.role.value, "email": user.email},
        )
        refresh_token = create_refresh_token(subject=str(user.id))

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.get_jwt_expire_minutes() * 60,
        )

    async def login_with_google(self, db: AsyncSession, req: GoogleAuthRequest) -> TokenResponse:
        """
        Google OAuth 2.0 / OIDC sign-in exchange per SRS v3.3 §3.3a, §7.4.
        """
        auth_provider = get_auth_provider()
        google_user = await auth_provider.exchange_google_code(req.code, req.code_verifier)

        # 1. Lookup existing user by Google subject ID or email
        user = await user_repository.get_by_oauth_subject_id(db, google_user.subject_id)
        
        if not user:
            existing_email_user = await user_repository.get_by_email(db, google_user.email)
            if existing_email_user:
                # Per SRS §7.4: email collision with password account is 409 Conflict, not silent merge
                if existing_email_user.auth_provider == AuthProviderType.PASSWORD:
                    raise AccountConflictError(
                        message="An account with this email already exists using password authentication. Account linking is not supported in Phase 1."
                    )
                user = existing_email_user
            else:
                # Create new pre-verified Google account per SRS §3.3a
                user = User(
                    email=google_user.email.lower(),
                    full_name=google_user.name or google_user.email.split("@")[0],
                    password_hash=None,
                    auth_provider=AuthProviderType.GOOGLE,
                    oauth_subject_id=google_user.subject_id,
                    role=UserRole.REQUESTER,
                    availability_status=AvailabilityStatus.AVAILABLE,
                    email_verified=True,  # Google accounts are pre-verified
                    is_active=True,
                )
                db.add(user)
                await db.commit()
                await db.refresh(user)

        if not user.is_active:
            raise PermissionDeniedError(message="This account has been deactivated")

        access_token = create_access_token(
            subject=str(user.id),
            extra_claims={"role": user.role.value, "email": user.email},
        )
        refresh_token = create_refresh_token(subject=str(user.id))

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.get_jwt_expire_minutes() * 60,
        )

    async def refresh_tokens(self, db: AsyncSession, req: RefreshTokenRequest) -> TokenResponse:
        try:
            payload = decode_token(req.refresh_token)
            if payload.get("type") != "refresh":
                raise ValidationError(message="Invalid token type")
            user_id = payload.get("sub")
        except Exception:
            raise PermissionDeniedError(message="Invalid or expired refresh token")

        user = await user_repository.get(db, user_id)
        if not user or not user.is_active:
            raise PermissionDeniedError(message="User account no longer active")

        new_access_token = create_access_token(
            subject=str(user.id),
            extra_claims={"role": user.role.value, "email": user.email},
        )
        new_refresh_token = create_refresh_token(subject=str(user.id))

        return TokenResponse(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
            expires_in=settings.get_jwt_expire_minutes() * 60,
        )

    async def verify_email_token(self, db: AsyncSession, token: str) -> bool:
        try:
            payload = decode_token(token)
            user_id = payload.get("sub")
            if payload.get("type") != "email_verification":
                raise ValidationError(message="Invalid verification token type")
        except Exception:
            raise ValidationError(message="Invalid or expired email verification link")

        user = await user_repository.get(db, user_id)
        if not user:
            raise NotFoundError(message="User not found")

        user.email_verified = True
        await db.commit()
        return True

    async def request_password_reset(self, db: AsyncSession, email: str) -> bool:
        user = await user_repository.get_by_email(db, email)
        if not user or user.auth_provider != AuthProviderType.PASSWORD:
            # Return true silently to prevent account enumeration
            return True

        reset_token = create_access_token(
            subject=str(user.id),
            extra_claims={"type": "password_reset", "email": user.email},
        )
        reset_url = f"{settings.API_V1_STR}/auth/reset-password?token={reset_token}"
        notifier = get_notification_provider()
        return await notifier.send_password_reset_email(user.email, reset_url)

    async def reset_password(self, db: AsyncSession, req: PasswordResetConfirmRequest) -> bool:
        try:
            payload = decode_token(req.token)
            user_id = payload.get("sub")
            if payload.get("type") != "password_reset":
                raise ValidationError(message="Invalid reset token type")
        except Exception:
            raise ValidationError(message="Invalid or expired password reset link")

        user = await user_repository.get(db, user_id)
        if not user:
            raise NotFoundError(message="User not found")

        user.password_hash = get_password_hash(req.new_password)
        await db.commit()
        return True


auth_service = AuthService()
