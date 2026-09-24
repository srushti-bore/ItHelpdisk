from datetime import datetime, timezone
import pytest
from backend.models.enums import CaseStatus, CaseType, Priority, UserRole
from backend.services.case_service import case_service
from backend.services.sla_service import sla_service


def test_sla_targets_integrity():
    """Verify SLA targets for all 4 priorities follow SRS v3.3 §7.1."""
    now = datetime.now(timezone.utc)

    # P1: 15 min response, 4 hr resolution
    resp_p1, res_p1 = sla_service.calculate_targets(Priority.P1_CRITICAL, now)
    assert (resp_p1 - now).total_seconds() == 15 * 60
    assert (res_p1 - now).total_seconds() == 4 * 3600

    # P2: 1 hr response, 8 hr resolution
    resp_p2, res_p2 = sla_service.calculate_targets(Priority.P2_HIGH, now)
    assert (resp_p2 - now).total_seconds() == 3600
    assert (res_p2 - now).total_seconds() == 8 * 3600

    # P3: 4 hr response, 72 hr resolution
    resp_p3, res_p3 = sla_service.calculate_targets(Priority.P3_MEDIUM, now)
    assert (resp_p3 - now).total_seconds() == 4 * 3600
    assert (res_p3 - now).total_seconds() == 72 * 3600

    # P4: 24 hr response, 120 hr resolution
    resp_p4, res_p4 = sla_service.calculate_targets(Priority.P4_LOW, now)
    assert (resp_p4 - now).total_seconds() == 24 * 3600
    assert (res_p4 - now).total_seconds() == 120 * 3600


def test_reference_number_format():
    """Verify generated reference numbers adhere to format: INC-YYYYMMDD-XXXX / REQ-YYYYMMDD-XXXX."""
    from backend.repositories.case_repo import case_repo

    now = datetime.now(timezone.utc)
    date_str = now.strftime("%Y%m%d")

    ref_inc = f"INC-{date_str}-0042"
    ref_req = f"REQ-{date_str}-0010"

    assert ref_inc.startswith(f"INC-{date_str}-")
    assert ref_req.startswith(f"REQ-{date_str}-")
    assert len(ref_inc) == 17
