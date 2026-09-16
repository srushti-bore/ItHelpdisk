from datetime import datetime, timedelta, timezone
import pytest
from backend.models.case import Case
from backend.models.enums import CaseStatus, CaseType, Priority, RiskLevel
from backend.models.sla import SLA
from backend.services.risk_service import risk_service


def test_risk_evaluation_healthy():
    now = datetime.now(timezone.utc)
    case = Case(
        reference_number="INC-2026-000001",
        type=CaseType.INCIDENT,
        title="Password reset",
        description="User forgot password",
        status=CaseStatus.NEW,
        priority=Priority.P3_MEDIUM,
        created_at=now,
        updated_at=now,
        version=1,
    )
    case.sla = SLA(
        target_response_at=now + timedelta(hours=4),
        target_resolve_at=now + timedelta(hours=72),
        response_breached=False,
        resolve_breached=False,
    )

    risk, signals = risk_service.evaluate_case_risk(case)
    assert risk == RiskLevel.LOW
    assert signals["sla_breached"] is False


def test_risk_evaluation_breached():
    now = datetime.now(timezone.utc)
    case = Case(
        reference_number="INC-2026-000002",
        type=CaseType.INCIDENT,
        title="Server outage",
        description="Production database unreachable",
        status=CaseStatus.ASSIGNED,
        priority=Priority.P1_CRITICAL,
        created_at=now - timedelta(hours=5),
        updated_at=now - timedelta(hours=5),
        version=1,
    )
    case.sla = SLA(
        target_response_at=now - timedelta(hours=4),
        target_resolve_at=now - timedelta(hours=1),
        response_breached=True,
        resolve_breached=True,
    )

    risk, signals = risk_service.evaluate_case_risk(case)
    assert risk == RiskLevel.CRITICAL
    assert signals["sla_breached"] is True
