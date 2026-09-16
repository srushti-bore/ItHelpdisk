from datetime import datetime, timezone
from typing import Dict, Tuple
from backend.models.case import Case
from backend.models.enums import RiskLevel


class RiskService:
    """
    Case Risk Assessment Engine per SRS v3.3 §4, §5.7.
    Evaluates operational risk signals during the scheduled sweep.
    """

    @classmethod
    def evaluate_case_risk(cls, case: Case, message_count: int = 0) -> Tuple[RiskLevel, Dict[str, Any]]:
        now = datetime.now(timezone.utc)
        signals: Dict[str, Any] = {}

        # 1. Inactivity signal (hours since last update)
        last_activity = case.updated_at or case.created_at
        inactivity_hours = (now - last_activity).total_seconds() / 3600.0
        signals["inactivity_hours"] = round(inactivity_hours, 2)

        # 2. SLA deadline proximity signal
        hours_to_deadline = 999.0
        is_breached = False
        is_approaching = False

        if case.sla and not case.sla.resolved_at:
            time_left_sec = (case.sla.target_resolve_at - now).total_seconds()
            hours_to_deadline = time_left_sec / 3600.0
            signals["hours_to_resolve_deadline"] = round(hours_to_deadline, 2)

            if time_left_sec <= 0:
                is_breached = True
            elif time_left_sec <= 0.20 * (case.sla.target_resolve_at - case.created_at).total_seconds():
                is_approaching = True

        signals["sla_breached"] = is_breached
        signals["sla_approaching"] = is_approaching
        signals["version"] = case.version

        # 3. Determine RiskLevel based on combined signals
        if is_breached or (is_approaching and inactivity_hours > 4):
            risk = RiskLevel.CRITICAL
        elif is_approaching or (case.sla and case.sla.response_breached) or inactivity_hours > 48:
            risk = RiskLevel.HIGH
        elif inactivity_hours > 24 or (case.triage_result and len(case.triage_result.missing_info) > 0):
            risk = RiskLevel.MODERATE
        else:
            risk = RiskLevel.LOW

        signals["computed_risk"] = risk.value
        return risk, signals


risk_service = RiskService()
