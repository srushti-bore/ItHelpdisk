from typing import Optional, Union
from uuid import UUID
from pydantic import BaseModel, EmailStr, Field
from backend.models.enums import AuthProviderType, AvailabilityStatus, UserRole


class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None


class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=12, description="Password must be at least 12 characters per SRS §7.4")
    full_name: str = Field(..., min_length=2, max_length=150)
    site: Optional[str] = Field(None, description="Office location or Remote")


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


class GoogleAuthRequest(BaseModel):
    code: str = Field(..., description="Authorization code returned by Google OAuth")
    code_verifier: Optional[str] = Field(None, description="PKCE code verifier for mobile/desktop flows")
    redirect_uri: Optional[str] = None


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = Field(..., description="Access token expiration in seconds")


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class EmailVerificationRequest(BaseModel):
    token: str


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetConfirmRequest(BaseModel):
    token: str
    new_password: str = Field(..., min_length=12)


class UserResponse(BaseModel):
    id: Union[UUID, str]
    email: EmailStr
    full_name: Optional[str]
    role: UserRole
    auth_provider: AuthProviderType
    site: Optional[str]
    availability_status: AvailabilityStatus
    email_verified: bool
    is_active: bool

    class Config:
        from_attributes = True
