import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Optional
import httpx
from backend.core.config import settings
from backend.providers.notifications.base import NotificationProvider

logger = logging.getLogger("it_helpdesk.notifications")


class GmailSmtpNotificationProvider(NotificationProvider):
    """
    Local development email provider using Gmail SMTP per SRS §3.3a & §3.9.
    Uses free Gmail account + App Password over standard SMTP ports.
    """

    def __init__(self, smtp_address: str, smtp_password: str, from_name: str):
        self.smtp_address = smtp_address
        self.smtp_password = smtp_password
        self.from_name = from_name

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
    ) -> bool:
        if not self.smtp_address or not self.smtp_password:
            logger.warning(
                f"[LOCAL DEV MOCK EMAIL] To: {to_email} | Subject: {subject} | Content: {text_content or html_content[:100]}..."
            )
            return True

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"{self.from_name} <{self.smtp_address}>"
            msg["To"] = to_email

            if text_content:
                msg.attach(MIMEText(text_content, "plain"))
            msg.attach(MIMEText(html_content, "html"))

            with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
                server.login(self.smtp_address, self.smtp_password)
                server.sendmail(self.smtp_address, to_email, msg.as_string())

            logger.info(f"Email sent successfully to {to_email} via Gmail SMTP.")
            return True
        except Exception as e:
            logger.error(f"Failed to send email to {to_email} via Gmail SMTP: {str(e)}", exc_info=True)
            return False

    async def send_verification_email(self, to_email: str, verification_url: str) -> bool:
        subject = "Verify your AI IT Helpdesk account"
        html_content = f"""
        <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h2>Welcome to AI IT Helpdesk</h2>
            <p>Please verify your email address to start submitting and managing cases.</p>
            <p><a href="{verification_url}" style="background-color: #2563eb; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Verify Email</a></p>
            <p>Or copy this link: {verification_url}</p>
        </div>
        """
        return await self.send_email(to_email, subject, html_content, text_content=f"Verify link: {verification_url}")

    async def send_password_reset_email(self, to_email: str, reset_url: str) -> bool:
        subject = "Reset your AI IT Helpdesk password"
        html_content = f"""
        <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h2>Password Reset Request</h2>
            <p>Click the link below to reset your password. This link is valid for 1 hour.</p>
            <p><a href="{reset_url}" style="background-color: #dc2626; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a></p>
            <p>Or copy this link: {reset_url}</p>
        </div>
        """
        return await self.send_email(to_email, subject, html_content, text_content=f"Reset link: {reset_url}")


class BrevoNotificationProvider(NotificationProvider):
    """
    Staging & Production email provider using Brevo Transactional HTTP API per SRS §3.9.
    Sends over HTTPS (Port 443), avoiding Render free-tier outbound SMTP port blocks.
    """

    def __init__(self, api_key: str, from_email: str, from_name: str):
        self.api_key = api_key
        self.from_email = from_email
        self.from_name = from_name
        self.endpoint = "https://api.brevo.com/v3/smtp/email"

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
    ) -> bool:
        if not self.api_key:
            logger.warning(
                f"[BREVO MOCK EMAIL] To: {to_email} | Subject: {subject} | Content: {text_content or html_content[:100]}..."
            )
            return True

        headers = {
            "api-key": self.api_key,
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        payload = {
            "sender": {"name": self.from_name, "email": self.from_email},
            "to": [{"email": to_email}],
            "subject": subject,
            "htmlContent": html_content,
        }
        if text_content:
            payload["textContent"] = text_content

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(self.endpoint, headers=headers, json=payload)
                if response.status_code in [200, 201, 202]:
                    logger.info(f"Email sent successfully to {to_email} via Brevo HTTP API.")
                    return True
                else:
                    logger.error(f"Brevo API error: {response.status_code} - {response.text}")
                    return False
        except Exception as e:
            logger.error(f"Failed to send email to {to_email} via Brevo HTTP API: {str(e)}", exc_info=True)
            return False

    async def send_verification_email(self, to_email: str, verification_url: str) -> bool:
        subject = "Verify your AI IT Helpdesk account"
        html_content = f"""
        <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h2>Welcome to AI IT Helpdesk</h2>
            <p>Please verify your email address to start submitting and managing cases.</p>
            <p><a href="{verification_url}" style="background-color: #2563eb; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Verify Email</a></p>
        </div>
        """
        return await self.send_email(to_email, subject, html_content)

    async def send_password_reset_email(self, to_email: str, reset_url: str) -> bool:
        subject = "Reset your AI IT Helpdesk password"
        html_content = f"""
        <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h2>Password Reset Request</h2>
            <p>Click the link below to reset your password. This link is valid for 1 hour.</p>
            <p><a href="{reset_url}" style="background-color: #dc2626; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a></p>
        </div>
        """
        return await self.send_email(to_email, subject, html_content)


def get_notification_provider() -> NotificationProvider:
    """Factory function returning the environment-appropriate NotificationProvider."""
    if settings.ENVIRONMENT == "local":
        return GmailSmtpNotificationProvider(
            smtp_address=settings.GMAIL_SMTP_ADDRESS,
            smtp_password=settings.GMAIL_SMTP_APP_PASSWORD,
            from_name=settings.EMAIL_FROM_NAME,
        )
    return BrevoNotificationProvider(
        api_key=settings.BREVO_API_KEY,
        from_email=settings.EMAIL_FROM_ADDRESS,
        from_name=settings.EMAIL_FROM_NAME,
    )
