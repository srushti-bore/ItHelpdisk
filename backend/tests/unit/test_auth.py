import pytest
from backend.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_password_hash,
    verify_password,
)
from backend.models.enums import UserRole
from backend.providers.ai.gemini_provider import get_ai_provider
from backend.providers.notifications.email import get_notification_provider
from backend.providers.storage.supabase_storage import get_storage_provider


def test_password_hashing():
    password = "SuperSecretPassword123!"
    hashed = get_password_hash(password)
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("WrongPassword123!", hashed) is False


def test_jwt_tokens():
    user_id = "123e4567-e89b-12d3-a456-426614174000"
    role = UserRole.REQUESTER.value

    # Access Token
    access_token = create_access_token(subject=user_id, extra_claims={"role": role})
    payload = decode_token(access_token)
    assert payload["sub"] == user_id
    assert payload["role"] == role
    assert payload["type"] == "access"

    # Refresh Token
    refresh_token = create_refresh_token(subject=user_id)
    refresh_payload = decode_token(refresh_token)
    assert refresh_payload["sub"] == user_id
    assert refresh_payload["type"] == "refresh"


@pytest.mark.asyncio
async def test_providers_factory():
    ai = get_ai_provider()
    assert ai is not None
    triage = await ai.analyze_case("VPN down", "Cannot connect to office VPN")
    assert triage.suggested_category is not None

    storage = get_storage_provider()
    assert storage is not None

    notifier = get_notification_provider()
    assert notifier is not None
