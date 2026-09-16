from datetime import datetime, timedelta, timezone
from typing import Tuple
from backend.models.enums import Priority


class SLAService:
    """
    SLA Calculation Service per SRS v3.3 §4.3.
    Computes response and resolution deadlines using pure 24/7 elapsed wall-clock time in UTC.
    """

    # Target durations in hours/minutes per Priority level
    SLA_TARGETS = {
        Priority.P1_CRITICAL: {
            "response": timedelta(minutes=15),
            "resolve": timedelta(hours=4),
        },
        Priority.P2_HIGH: {
            "response": timedelta(hours=1),
            "resolve": timedelta(hours=8),
        },
        Priority.P3_MEDIUM: {
            "response": timedelta(hours=4),
            "resolve": timedelta(hours=72),
        },
        Priority.P4_LOW: {
            "response": timedelta(hours=24),
            "resolve": timedelta(hours=120),
        },
    }

    @classmethod
    def calculate_targets(cls, priority: Priority, base_time: Optional[datetime] = None) -> Tuple[datetime, datetime]:
        """
        Calculates target_response_at and target_resolve_at timestamps in UTC.
        """
        now = base_time or datetime.now(timezone.utc)
        targets = cls.SLA_TARGETS.get(priority, cls.SLA_TARGETS[Priority.P3_MEDIUM])

        target_response_at = now + targets["response"]
        target_resolve_at = now + targets["resolve"]

        return target_response_at, target_resolve_at


sla_service = SLAService()
