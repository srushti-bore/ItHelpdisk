from abc import ABC, abstractmethod
from typing import Any, Dict, Optional
from pydantic import BaseModel


class GoogleUserInfo(BaseModel):
    subject_id: str  # Google 'sub' claim
    email: str
    email_verified: bool
    name: Optional[str] = None
    picture: Optional[str] = None


class AuthProvider(ABC):
    """Abstract interface for third-party OAuth providers (Google OAuth2/OIDC)."""

    @abstractmethod
    async def exchange_google_code(self, code: str, code_verifier: Optional[str] = None) -> GoogleUserInfo:
        """Exchanges an authorization code for user profile info."""
        pass
