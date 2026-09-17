


from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.api.deps import require_roles
from backend.db.session import get_db
from backend.models.audit import AuditLog
from backend.models.enums import UserRole
from backend.models.user import User
from backend.repositories.user_repo import user_repository
from backend.schemas.auth import UserResponse

router = APIRouter()


@router.get("/audit-logs")
async def list_audit_logs(
    target_type: Optional[str] = Query(None),
    target_id: Optional[str] = Query(None),
    current_user: User = Depends(require_roles([UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """
    Lists immutable audit log entries per SRS §4, §5.11 and AGENTS.md Rule 9.
    Restricted to Administrators.
    """
    stmt = select(AuditLog)
    if target_type:
        stmt = stmt.where(AuditLog.target_type == target_type)
    if target_id:
        stmt = stmt.where(AuditLog.target_id == target_id)

    stmt = stmt.order_by(AuditLog.created_at.desc()).limit(100)
    result = await db.execute(stmt)
    logs = result.scalars().all()

    return [
        {
            "id": str(log.id),
            "actor_id": str(log.actor_id) if log.actor_id else None,
            "action": log.action,
            "target_type": log.target_type,
            "target_id": log.target_id,
            "before_value": log.before_value,
            "after_value": log.after_value,
            "created_at": log.created_at.isoformat(),
        }
        for log in logs
    ]


@router.get("/users", response_model=List[UserResponse])
async def list_users(
    current_user: User = Depends(require_roles([UserRole.ADMINISTRATOR, UserRole.MANAGER, UserRole.TEAM_LEAD])),
    db: AsyncSession = Depends(get_db),
):
    """Lists users for administration and assignment purposes."""
    users = await user_repository.get_multi(db, limit=100)
    return users
