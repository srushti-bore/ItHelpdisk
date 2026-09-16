import csv
import io
from fastapi import APIRouter, Depends
from fastapi.responses import Response
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.api.deps import require_roles
from backend.db.session import get_db
from backend.models.case import Case
from backend.models.enums import UserRole
from backend.models.user import User
from backend.schemas.ai import OperationalInsightsResponse
from backend.services.ai_service import ai_service

router = APIRouter()


@router.get("/operational-insights", response_model=OperationalInsightsResponse)
async def get_operational_insights(
    current_user: User = Depends(require_roles([UserRole.MANAGER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """
    Returns AI-powered operational insights and aggregated workload trends per SRS §5.12.
    Restricted strictly to Managers and Administrators.
    """
    return await ai_service.get_operational_insights(db, current_user)


@router.get("/export-csv")
async def export_cases_csv(
    current_user: User = Depends(require_roles([UserRole.MANAGER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """
    Exports permitted case list as CSV per SRS §3.6, §7.6.
    (PDF export is Phase 2).
    """
    stmt = select(Case).where(Case.deleted_at.is_(None)).order_by(Case.created_at.desc())
    cases = list((await db.execute(stmt)).scalars().all())

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "Reference Number",
        "Type",
        "Title",
        "Status",
        "Priority",
        "Site",
        "Created At",
        "Resolved At",
    ])

    for c in cases:
        writer.writerow([
            c.reference_number,
            c.type.value,
            c.title,
            c.status.value,
            c.priority.value,
            c.site or "",
            c.created_at.isoformat(),
            c.resolved_at.isoformat() if c.resolved_at else "",
        ])

    csv_data = output.getvalue()
    return Response(
        content=csv_data,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=it_helpdesk_cases.csv"},
    )
