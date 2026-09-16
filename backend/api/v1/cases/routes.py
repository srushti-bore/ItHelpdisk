from typing import List, Optional
from fastapi import APIRouter, Depends, File, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession
from backend.api.deps import get_current_user, require_roles
from backend.core.exceptions import PermissionDeniedError
from backend.db.session import get_db
from backend.models.enums import CaseStatus, CaseType, Priority, UserRole
from backend.models.user import User
from backend.providers.storage.supabase_storage import get_storage_provider
from backend.repositories.attachment_repo import attachment_repository
from backend.repositories.case_repo import case_repository
from backend.repositories.message_repo import message_repository
from backend.schemas.attachment import AttachmentResponse
from backend.schemas.case import (
    CaseAssignRequest,
    CaseCreateRequest,
    CaseDetailResponse,
    CaseReopenRequest,
    CaseResponse,
    CaseStatusTransitionRequest,
    CaseUpdateRequest,
)
from backend.schemas.common import PaginatedResponse
from backend.schemas.message import MessageCreateRequest, MessageResponse
from backend.services.case_service import case_service

router = APIRouter()


@router.post("", response_model=CaseResponse, status_code=status.HTTP_201_CREATED)
async def create_case(
    req: CaseCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Creates an Incident or Service Request, initiating 24/7 SLA and synchronous AI Triage analysis."""
    return await case_service.create_case(db, current_user, req)


@router.get("", response_model=PaginatedResponse[CaseResponse])
async def list_cases(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: Optional[CaseStatus] = Query(None),
    priority: Optional[Priority] = Query(None),
    case_type: Optional[CaseType] = Query(None),
    search: Optional[str] = Query(None),
    owner_id: Optional[str] = Query(None),
    team_id: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Lists cases with filters and pagination per SRS §3.6.
    Requesters can only view their own cases; staff can view all permitted cases.
    """
    requester_id = current_user.id if current_user.role == UserRole.REQUESTER else None
    skip = (page - 1) * page_size

    items, total = await case_repository.list_cases(
        db,
        requester_id=requester_id,
        owner_id=owner_id,
        team_id=team_id,
        status=status,
        priority=priority,
        case_type=case_type,
        search=search,
        skip=skip,
        limit=page_size,
    )

    return PaginatedResponse[CaseResponse](
        items=[CaseResponse.model_validate(item) for item in items],
        page=page,
        page_size=page_size,
        total=total,
    )


@router.get("/{id}", response_model=CaseDetailResponse)
async def get_case_detail(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieves full case context including SLA status, AI triage, continuous summary, and risk scoring."""
    case = await case_repository.get_with_details(db, id)
    if not case:
        raise PermissionDeniedError(message="Case not found or permission denied")

    # Enforce requester isolation
    if current_user.role == UserRole.REQUESTER and case.requester_id != current_user.id:
        raise PermissionDeniedError(message="You do not have access to this case")

    resp = CaseDetailResponse.model_validate(case)
    if case.summary:
        resp.summary_text = case.summary.summary_text
    if case.risk_assessment:
        resp.risk_level = case.risk_assessment.risk_level.value

    return resp


@router.patch("/{id}/status", response_model=CaseResponse)
async def transition_case_status(
    id: str,
    req: CaseStatusTransitionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Transitions case lifecycle state with optimistic locking (STALE_VERSION check)."""
    return await case_service.transition_status(db, id, current_user, req)


@router.patch("/{id}/assign", response_model=CaseResponse)
async def assign_case(
    id: str,
    req: CaseAssignRequest,
    current_user: User = Depends(require_roles([UserRole.OPERATOR, UserRole.TEAM_LEAD, UserRole.MANAGER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """Assigns an operator or team to the case."""
    return await case_service.assign_case(db, id, current_user, req)


@router.post("/{id}/reopen", response_model=CaseResponse)
async def reopen_case(
    id: str,
    req: CaseReopenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Reopens a closed case within 7 calendar days, starting a new SLA clock."""
    return await case_service.reopen_case(db, id, current_user, req)


@router.post("/{id}/messages", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def add_message(
    id: str,
    req: MessageCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Adds a requester-visible message or internal note, updating the AI continuous summary."""
    return await case_service.add_message(db, id, current_user, req)


@router.get("/{id}/messages", response_model=List[MessageResponse])
async def list_messages(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Lists messages for a case. Requesters are strictly restricted from seeing internal_only notes."""
    allow_internal = current_user.role != UserRole.REQUESTER
    messages = await message_repository.list_by_case(db, id, allow_internal=allow_internal)
    return [MessageResponse.model_validate(m) for m in messages]


@router.post("/{id}/attachments", response_model=AttachmentResponse, status_code=status.HTTP_201_CREATED)
async def upload_attachment(
    id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Uploads file evidence to Supabase Storage with server-generated UUID storage filename."""
    file_data = await file.read()
    attachment = await case_service.upload_attachment(
        db,
        case_id=id,
        current_user=current_user,
        file_name=file.filename or "attachment.bin",
        file_data=file_data,
        content_type=file.content_type or "application/octet-stream",
    )
    storage_provider = get_storage_provider()
    download_url = await storage_provider.get_file_url(attachment.storage_path)
    resp = AttachmentResponse.model_validate(attachment)
    resp.download_url = download_url
    return resp


@router.get("/{id}/attachments", response_model=List[AttachmentResponse])
async def list_attachments(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Lists attachments for a case with fresh signed download URLs."""
    attachments = await attachment_repository.list_by_case(db, id)
    storage_provider = get_storage_provider()
    resList = []
    for att in attachments:
        resp = AttachmentResponse.model_validate(att)
        resp.download_url = await storage_provider.get_file_url(att.storage_path)
        resList.append(resp)
    return resList
