import os
from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # General & Environment
    PROJECT_NAME: str = "AI IT Helpdesk"
    ENVIRONMENT: str = "local"  # local | staging | production
    DEBUG: bool = True
    API_V1_STR: str = "/api/v1"

    # Security & Tokens
    SECRET_KEY: str = "default-insecure-dev-secret-key-change-in-production-min-32-chars"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    DEV_ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours for local dev
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    ALLOWED_ORIGINS: Union[str, List[str]] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
    ]

    @field_validator("ALLOWED_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        elif isinstance(v, list):
            return v
        return []

    # Database URLs
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgrespassword@localhost:5432/it_helpdesk"
    SYNC_DATABASE_URL: str = "postgresql://postgres:postgrespassword@localhost:5432/it_helpdesk"

    # Supabase Storage
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""
    SUPABASE_STORAGE_BUCKET: str = "attachments"

    # AI Provider (Google Gemini)
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-2.5-flash"

    # Google OAuth
    GOOGLE_OAUTH_CLIENT_ID: str = ""
    GOOGLE_OAUTH_CLIENT_SECRET: str = ""
    GOOGLE_OAUTH_REDIRECT_URI: str = "http://localhost:8000/api/v1/auth/google/callback"

    # Email Config (Local: Gmail SMTP; Staging/Prod: Brevo)
    GMAIL_SMTP_ADDRESS: str = ""
    GMAIL_SMTP_APP_PASSWORD: str = ""
    BREVO_API_KEY: str = ""
    EMAIL_FROM_ADDRESS: str = "support@ithelpdesk.local"
    EMAIL_FROM_NAME: str = "AI IT Helpdesk"

    # Sweeper Settings
    SWEEP_INTERVAL_MINUTES: int = 5

    def get_jwt_expire_minutes(self) -> int:
        """Returns 24h for local dev, 15m for staging/production per SRS §3.3a."""
        if self.ENVIRONMENT == "local":
            return self.DEV_ACCESS_TOKEN_EXPIRE_MINUTES
        return self.ACCESS_TOKEN_EXPIRE_MINUTES

    def validate_startup_env(self) -> None:
        """
        Validates environment variables at application boot.
        Fails fast with descriptive error message if critical variables are missing per SRS §3.3.
        """
        if self.ENVIRONMENT == "production":
            missing = []
            if self.SECRET_KEY == "default-insecure-dev-secret-key-change-in-production-min-32-chars" or len(self.SECRET_KEY) < 32:
                missing.append("SECRET_KEY (must be high entropy >= 32 chars in production)")
            if not self.GEMINI_API_KEY:
                missing.append("GEMINI_API_KEY")
            if not self.SUPABASE_URL:
                missing.append("SUPABASE_URL")
            if not self.SUPABASE_KEY:
                missing.append("SUPABASE_KEY")
            if not self.BREVO_API_KEY:
                missing.append("BREVO_API_KEY (required in staging/production for Brevo HTTP API)")
            if not self.GOOGLE_OAUTH_CLIENT_ID or not self.GOOGLE_OAUTH_CLIENT_SECRET:
                missing.append("GOOGLE_OAUTH_CLIENT_ID and GOOGLE_OAUTH_CLIENT_SECRET")

            if missing:
                raise RuntimeError(
                    f"Startup validation failed! Missing required environment variables for {self.ENVIRONMENT}: {', '.join(missing)}"
                )


settings = Settings()
