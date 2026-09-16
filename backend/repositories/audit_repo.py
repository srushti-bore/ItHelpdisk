from typing import Any, Dict, List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.models.audit import AuditLog
from backend.repositories.base import BaseRepository


class AuditRepository(BaseRepository[AuditLog]):
    def __init__(self):
        super().__init__(AuditLog)

    async def log(
        self,
        db: AsyncSession,
        action: str,
        target_type: str,
        target_id: str,
        actor_id: Optional[str] = None,
        before_value: Optional[Dict[str, Any]] = None,
        after_value: Optional[Dict[str, Any]] = None,
    ) -> AuditLog:
        """Appends an immutable audit log entry."""
        log_entry = AuditLog(
            actor_id=actor_id,
            action=action,
            target_type=target_type,
            target_id=target_id,
            before_value=before_value,
            after_value=after_value,
        )
        db.add(log_entry)
        return log_entry

    async def list_by_target(self, db: AsyncSession, target_type: str, target_id: str) -> List[AuditLog]:
        stmt = (
            select(AuditLog)
            .where(AuditLog.target_type == target_type, AuditLog.target_id == target_id)
            .order_by(AuditLog.created_at.asc())
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())


audit_repository = AuditRepository()
