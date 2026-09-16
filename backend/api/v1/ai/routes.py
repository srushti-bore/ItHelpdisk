from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from backend.api.deps import get_current_user, require_roles
from backend.db.session import get_db
from backend.models.enums import UserRole
from backend.models.user import User
from backend.schemas.ai import (
    DraftGenerateRequest,
    DraftResponse,
    DraftSendRequest,
    DuplicateDetectionResponse,
    SmartAssignmentResponse,
)
from backend.schemas.message import MessageResponse
from backend.services.ai_service import ai_service

router = APIRouter()


@router.post("/cases/{case_id}/draft", response_model=DraftResponse, status_code=status.HTTP_201_CREATED)
async def generate_draft(
    case_id: str,
    req: DraftGenerateRequest,
    current_user: User = Depends(require_roles([UserRole.OPERATOR, UserRole.TEAM_LEAD, UserRole.MANAGER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """Generates an AI communication draft for staff review (SRS §5.9, Level 1)."""
    return await ai_service.generate_draft(db, case_id, current_user, req)


@router.post("/drafts/{draft_id}/send", response_model=MessageResponse)
async def send_draft(
    draft_id: str,
    req: DraftSendRequest,
    current_user: User = Depends(require_roles([UserRole.OPERATOR, UserRole.TEAM_LEAD, UserRole.MANAGER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """Sends a human-reviewed draft as an official requester-visible message."""
    return await ai_service.send_draft(db, draft_id, current_user, req)


@router.get("/cases/{case_id}/smart-assignment", response_model=SmartAssignmentResponse)
async def get_smart_assignment(
    case_id: str,
    current_user: User = Depends(require_roles([UserRole.OPERATOR, UserRole.TEAM_LEAD, UserRole.MANAGER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """Recommends operator assignment based on workload, availability, and site match (SRS §5.6, Level 1)."""
    return await ai_service.recommend_smart_assignment(db, case_id, current_user)


@router.get("/cases/{case_id}/duplicates", response_model=DuplicateDetectionResponse)
async def get_duplicates(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Detects candidate related/duplicate cases using title similarity (SRS §5.5, Level 0)."""
    return await ai_service.detect_duplicates(db, case_id)
