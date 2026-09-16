from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.exceptions import NotFoundError
from backend.models.case import Case
from backend.models.enums import EscalationReason, EscalationStatus
from backend.models.escalation import EscalationEvent
from backend.models.user import User
from backend.repositories.audit_repo import audit_repository


class EscalationService:
    """
    Escalation Service per SRS v3.3 §5.8.
    Handles automated and manual escalation events with audit logs and notifications.
    """

    async def trigger_escalation(
        self,
        db: AsyncSession,
        case: Case,
        reason: EscalationReason,
        escalated_by: Optional[User] = None,
        target_role: str = "team_lead",
    ) -> Optional[EscalationEvent]:
        # 1. Prevent duplicate open escalations for the same case and reason
        stmt = (
            select(EscalationEvent)
            .where(
                EscalationEvent.case_id == case.id,
                EscalationEvent.status == EscalationStatus.OPEN,
                EscalationEvent.trigger_reason == reason,
            )
        )
        existing = (await db.execute(stmt)).scalars().first()
        if existing:
            return None

        # 2. Create EscalationEvent
        actor_id = str(escalated_by.id) if escalated_by else None
        event = EscalationEvent(
            case_id=case.id,
            trigger_reason=reason,
            escalated_to=target_role,
            escalated_by=escalated_by.id if escalated_by else None,
            status=EscalationStatus.OPEN,
        )
        db.add(event)

        # 3. Write immutable AuditLog entry (actor_id is None for Sweep-triggered events per SRS §4)
        await audit_repository.log(
            db,
            action="case.escalated",
            target_type="case",
            target_id=str(case.id),
            actor_id=actor_id,
            after_value={
                "trigger_reason": reason.value,
                "escalated_to": target_role,
                "is_system_triggered": escalated_by is None,
            },
        )

        return event

    async def acknowledge_escalation(
        self, db: AsyncSession, escalation_id: str, current_user: User
    ) -> EscalationEvent:
        stmt = select(EscalationEvent).where(EscalationEvent.id == escalation_id)
        event = (await db.execute(stmt)).scalars().first()
        if not event:
            raise NotFoundError(message="Escalation event not found")

        event.status = EscalationStatus.ACKNOWLEDGED
        event.acknowledged_at = datetime.now(timezone.utc)

        await audit_repository.log(
            db,
            action="escalation.acknowledged",
            target_type="escalation",
            target_id=str(event.id),
            actor_id=str(current_user.id),
        )

        await db.commit()
        await db.refresh(event)
        return event

    async def resolve_escalation(
        self, db: AsyncSession, escalation_id: str, current_user: User
    ) -> EscalationEvent:
        stmt = select(EscalationEvent).where(EscalationEvent.id == escalation_id)
        event = (await db.execute(stmt)).scalars().first()
        if not event:
            raise NotFoundError(message="Escalation event not found")

        event.status = EscalationStatus.RESOLVED
        event.resolved_at = datetime.now(timezone.utc)

        await audit_repository.log(
            db,
            action="escalation.resolved",
            target_type="escalation",
            target_id=str(event.id),
            actor_id=str(current_user.id),
        )

        await db.commit()
        await db.refresh(event)
        return event


escalation_service = EscalationService()
