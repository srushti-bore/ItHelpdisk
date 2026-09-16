from datetime import datetime, timezone
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from backend.models.case import Case, CaseRelationship
from backend.models.enums import CaseStatus, CaseType, Priority
from backend.repositories.base import BaseRepository


class CaseRepository(BaseRepository[Case]):
    def __init__(self):
        super().__init__(Case)

    async def generate_reference_number(self, db: AsyncSession, case_type: CaseType) -> str:
        """
        Generates server-side human-readable sequential reference number per SRS §4.2.
        Format: <TYPE_PREFIX>-<YEAR>-<6_DIGIT_SEQ>, e.g. INC-2026-000123
        """
        prefix = "INC" if case_type == CaseType.INCIDENT else "REQ"
        current_year = datetime.now(timezone.utc).year

        # Count existing cases created this year with this prefix to get sequential number
        like_pattern = f"{prefix}-{current_year}-%"
        result = await db.execute(
            select(func.count(Case.id)).where(Case.reference_number.like(like_pattern))
        )
        count = result.scalar() or 0
        seq = count + 1
        return f"{prefix}-{current_year}-{seq:06d}"

    async def get_with_details(self, db: AsyncSession, case_id: str) -> Optional[Case]:
        """Retrieves a single case with all related context eager-loaded."""
        stmt = (
            select(Case)
            .where(Case.id == case_id, Case.deleted_at.is_(None))
            .options(
                selectinload(Case.requester),
                selectinload(Case.owner),
                selectinload(Case.team),
                selectinload(Case.sla),
                selectinload(Case.triage_result),
                selectinload(Case.summary),
                selectinload(Case.risk_assessment),
            )
        )
        result = await db.execute(stmt)
        return result.scalars().first()

    async def list_cases(
        self,
        db: AsyncSession,
        *,
        requester_id: Optional[str] = None,
        owner_id: Optional[str] = None,
        team_id: Optional[str] = None,
        status: Optional[CaseStatus] = None,
        priority: Optional[Priority] = None,
        case_type: Optional[CaseType] = None,
        search: Optional[str] = None,
        skip: int = 0,
        limit: int = 20,
    ) -> Tuple[List[Case], int]:
        """Filtered, searched, and paginated case query."""
        stmt = select(Case).where(Case.deleted_at.is_(None))

        if requester_id:
            stmt = stmt.where(Case.requester_id == requester_id)
        if owner_id:
            stmt = stmt.where(Case.owner_id == owner_id)
        if team_id:
            stmt = stmt.where(Case.team_id == team_id)
        if status:
            stmt = stmt.where(Case.status == status)
        if priority:
            stmt = stmt.where(Case.priority == priority)
        if case_type:
            stmt = stmt.where(Case.type == case_type)
        if search:
            search_filter = or_(
                Case.reference_number.ilike(f"%{search}%"),
                Case.title.ilike(f"%{search}%"),
                Case.description.ilike(f"%{search}%"),
            )
            stmt = stmt.where(search_filter)

        # Count total
        count_stmt = select(func.count()).select_from(stmt.subquery())
        count_res = await db.execute(count_stmt)
        total = count_res.scalar() or 0

        # Fetch page with eager loaded associations
        stmt = stmt.order_by(Case.created_at.desc()).offset(skip).limit(limit)
        stmt = stmt.options(
            selectinload(Case.requester),
            selectinload(Case.owner),
            selectinload(Case.sla),
        )
        result = await db.execute(stmt)
        items = list(result.scalars().all())

        return items, total


case_repository = CaseRepository()
