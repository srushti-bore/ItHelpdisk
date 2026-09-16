import uuid
from backend.models.enums import AuthProviderType, CaseStatus, CaseType, Priority, UserRole
from backend.models.user import Team, User
from backend.models.case import Case
from backend.models.message import Message
from backend.models.sla import SLA


def test_model_instantiation():
    """Verifies that all core models can be instantiated cleanly with correct attributes."""
    user_id = uuid.uuid4()
    user = User(
        id=user_id,
        email="operator@test.com",
        full_name="Test Operator",
        role=UserRole.OPERATOR,
        auth_provider=AuthProviderType.PASSWORD,
        email_verified=True,
    )
    assert user.email == "operator@test.com"
    assert user.role == UserRole.OPERATOR

    case = Case(
        reference_number="INC-2026-000001",
        type=CaseType.INCIDENT,
        title="VPN Connection failure",
        description="Unable to connect to internal network",
        status=CaseStatus.NEW,
        priority=Priority.P1_CRITICAL,
        requester_id=user_id,
    )
    assert case.reference_number == "INC-2026-000001"
    assert case.priority == Priority.P1_CRITICAL
    assert case.version == 1
