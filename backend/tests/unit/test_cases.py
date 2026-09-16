from datetime import datetime, timezone
import pytest
from backend.models.enums import CaseStatus, CaseType, Priority
from backend.services.sla_service import sla_service


def test_sla_targets_calculation():
    now = datetime(2026, 9, 16, 12, 0, 0, tzinfo=timezone.utc)

    # Test P1 Critical: 15m response, 4h resolution
    resp_p1, res_p1 = sla_service.calculate_targets(Priority.P1_CRITICAL, now)
    assert (resp_p1 - now).total_seconds() == 15 * 60
    assert (res_p1 - now).total_seconds() == 4 * 3600

    # Test P2 High: 1h response, 8h resolution
    resp_p2, res_p2 = sla_service.calculate_targets(Priority.P2_HIGH, now)
    assert (resp_p2 - now).total_seconds() == 3600
    assert (res_p2 - now).total_seconds() == 8 * 3600

    # Test P3 Medium: 4h response, 72h resolution
    resp_p3, res_p3 = sla_service.calculate_targets(Priority.P3_MEDIUM, now)
    assert (resp_p3 - now).total_seconds() == 4 * 3600
    assert (res_p3 - now).total_seconds() == 72 * 3600

    # Test P4 Low: 24h response, 120h resolution
    resp_p4, res_p4 = sla_service.calculate_targets(Priority.P4_LOW, now)
    assert (resp_p4 - now).total_seconds() == 24 * 3600
    assert (res_p4 - now).total_seconds() == 120 * 3600
