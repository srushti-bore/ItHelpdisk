from abc import ABC, abstractmethod
from typing import List, Optional


class NotificationProvider(ABC):
    """Abstract interface for email and transactional notifications per SRS §3.9."""

    @abstractmethod
    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
    ) -> bool:
        """Sends an email notification."""
        pass

    @abstractmethod
    async def send_verification_email(self, to_email: str, verification_url: str) -> bool:
        """Sends an account email-verification link."""
        pass

    @abstractmethod
    async def send_password_reset_email(self, to_email: str, reset_url: str) -> bool:
        """Sends a password-reset link."""
        pass
