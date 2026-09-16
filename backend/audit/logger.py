from typing import Any, Dict, Optional
from sqlalchemy.ext.asyncio import AsyncSession
import logging

logger = logging.getLogger("it_helpdesk.audit")


class AuditLogger:
    """
    Append-only audit logger per SRS §4, §5.11, and AGENTS.md Rule 9.
    Records material case and governance events (status change, assignment, escalation, AI outputs).
    """

    @staticmethod
    async def log_event(
        db: AsyncSession,
        action: str,
        target_type: str,
        target_id: str,
        actor_id: Optional[str] = None,
        before_value: Optional[Dict[str, Any]] = None,
        after_value: Optional[Dict[str, Any]] = None,
    ) -> None:
        """
        Appends an immutable audit log row within the current DB transaction.
        actor_id is None for system-triggered events (e.g. automatic sweep escalations).
        """
        logger.info(
            f"AUDIT: action={action} target_type={target_type} target_id={target_id} actor_id={actor_id}"
        )
        # SQLAlchemy model persistence will be hooked up here
