import logging
from typing import Optional
import httpx
from backend.core.config import settings
from backend.core.exceptions import AppException
from backend.providers.auth.base import AuthProvider, GoogleUserInfo

logger = logging.getLogger("it_helpdesk.auth.google")


class GoogleOAuthProvider(AuthProvider):
    """
    Google OAuth 2.0 / OIDC Provider per SRS v3.3 §3.1, §3.3a, §7.4.
    Exchanges authorization code for Google user profile (sub, email, verified status).
    """

    TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"
    USERINFO_ENDPOINT = "https://www.googleapis.com/oauth2/v3/userinfo"

    def __init__(self, client_id: str, client_secret: str, redirect_uri: str):
        self.client_id = client_id
        self.client_secret = client_secret
        self.redirect_uri = redirect_uri

    async def exchange_google_code(self, code: str, code_verifier: Optional[str] = None) -> GoogleUserInfo:
        """
        Exchanges Google auth code for id_token / access_token, then fetches user profile.
        Supports PKCE for Mobile/Desktop clients.
        """
        payload = {
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": self.redirect_uri,
        }
        if code_verifier:
            payload["code_verifier"] = code_verifier

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                # 1. Exchange code for tokens
                token_resp = await client.post(self.TOKEN_ENDPOINT, data=payload)
                if token_resp.status_code != 200:
                    logger.error(f"Google Token exchange failed: {token_resp.status_code} - {token_resp.text}")
                    raise AppException(
                        code="GOOGLE_AUTH_FAILED",
                        message="Failed to exchange authorization code with Google",
                        status_code=400,
                        details={"google_error": token_resp.text},
                    )

                token_data = token_resp.json()
                access_token = token_data.get("access_token")

                # 2. Fetch user profile with access token
                headers = {"Authorization": f"Bearer {access_token}"}
                userinfo_resp = await client.get(self.USERINFO_ENDPOINT, headers=headers)
                if userinfo_resp.status_code != 200:
                    logger.error(f"Google UserInfo fetch failed: {userinfo_resp.status_code} - {userinfo_resp.text}")
                    raise AppException(
                        code="GOOGLE_USERINFO_FAILED",
                        message="Failed to retrieve profile information from Google",
                        status_code=400,
                    )

                user_data = userinfo_resp.json()
                return GoogleUserInfo(
                    subject_id=user_data["sub"],
                    email=user_data["email"],
                    email_verified=user_data.get("email_verified", True),
                    name=user_data.get("name"),
                    picture=user_data.get("picture"),
                )
        except AppException:
            raise
        except Exception as e:
            logger.error(f"Unexpected error in Google OAuth exchange: {str(e)}", exc_info=True)
            raise AppException(
                code="GOOGLE_AUTH_ERROR",
                message="Unexpected error during Google authentication",
                status_code=500,
                details={"error": str(e)},
            )


def get_auth_provider() -> AuthProvider:
    """Factory returning configured GoogleOAuthProvider."""
    return GoogleOAuthProvider(
        client_id=settings.GOOGLE_OAUTH_CLIENT_ID,
        client_secret=settings.GOOGLE_OAUTH_CLIENT_SECRET,
        redirect_uri=settings.GOOGLE_OAUTH_REDIRECT_URI,
    )
