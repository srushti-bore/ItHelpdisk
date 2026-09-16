from typing import List, Optional
from fastapi import Depends, Header, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.exceptions import PermissionDeniedError
from backend.core.security import decode_token
from backend.db.session import get_db
from backend.models.enums import UserRole
from backend.models.user import User
from backend.repositories.user_repo import user_repository

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login", auto_error=False)


async def get_current_user(
    token: Optional[str] = Depends(oauth2_scheme),
    authorization: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Dependency for authenticating the current user from Bearer JWT.
    Enforces token validation and DB user existence.
    """
    raw_token = token
    if not raw_token and authorization and authorization.startswith("Bearer "):
        raw_token = authorization.split(" ")[1]

    if not raw_token:
        raise PermissionDeniedError(message="Authentication credentials were not provided", details={"status": 401})

    try:
        payload = decode_token(raw_token)
        if payload.get("type") != "access":
            raise PermissionDeniedError(message="Invalid token type — access token required")
        user_id = payload.get("sub")
        if not user_id:
            raise PermissionDeniedError(message="Malformed token claims")
    except Exception as e:
        raise PermissionDeniedError(message=f"Invalid or expired access token: {str(e)}")

    user = await user_repository.get(db, user_id)
    if not user:
        raise PermissionDeniedError(message="User not found")
    if not user.is_active:
        raise PermissionDeniedError(message="User account is inactive")

    return user


async def get_current_active_verified_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Ensures the authenticated user has verified their email address."""
    if not current_user.email_verified:
        raise PermissionDeniedError(message="Email address must be verified before performing this action")
    return current_user


class RoleChecker:
    """
    RBAC dependency enforcing permitted user roles per SRS §2.2, §7.6.
    """
    def __init__(self, allowed_roles: List[UserRole]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in self.allowed_roles and current_user.role != UserRole.ADMINISTRATOR:
            raise PermissionDeniedError(
                message=f"Access forbidden: requires one of [{', '.join([r.value for r in self.allowed_roles])}]"
            )
        return current_user


def require_roles(roles: List[UserRole]):
    """Helper factory for RBAC role checking."""
    return RoleChecker(roles)
