from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from backend.api.deps import get_current_user
from backend.db.session import get_db
from backend.models.user import User
from backend.schemas.auth import (
    EmailVerificationRequest,
    GoogleAuthRequest,
    PasswordResetConfirmRequest,
    PasswordResetRequest,
    RefreshTokenRequest,
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)
from backend.services.auth_service import auth_service

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(req: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    """Registers a new user account with password hashing."""
    user = await auth_service.register_user(db, req)
    return user


@router.post("/login", response_model=TokenResponse)
async def login(req: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    """Logs in an existing user with email and password."""
    return await auth_service.login_user(db, req)


@router.post("/google", response_model=TokenResponse)
async def google_login(req: GoogleAuthRequest, db: AsyncSession = Depends(get_db)):
    """Exchanges Google authorization code for JWT tokens per SRS §7.4."""
    return await auth_service.login_with_google(db, req)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(req: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    """Refreshes access token with a valid refresh token."""
    return await auth_service.refresh_tokens(db, req)


@router.post("/verify-email")
async def verify_email(req: EmailVerificationRequest, db: AsyncSession = Depends(get_db)):
    """Verifies account email with time-limited signed link."""
    await auth_service.verify_email_token(db, req.token)
    return {"message": "Email verified successfully"}


@router.post("/forgot-password")
async def forgot_password(req: PasswordResetRequest, db: AsyncSession = Depends(get_db)):
    """Requests password reset link."""
    await auth_service.request_password_reset(db, req.email)
    return {"message": "If the email is registered, a password reset link has been sent"}


@router.post("/reset-password")
async def reset_password(req: PasswordResetConfirmRequest, db: AsyncSession = Depends(get_db)):
    """Resets password with valid reset token."""
    await auth_service.reset_password(db, req)
    return {"message": "Password reset successfully"}


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Returns profile for the currently authenticated user."""
    return current_user
