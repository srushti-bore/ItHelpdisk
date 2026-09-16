from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from backend.core.exceptions import (
    AppException,
    NotFoundError,
    PermissionDeniedError,
    StaleVersionError,
    ValidationError,
)
from backend.models.ai_artifacts import AITriageResult, CaseSummary
from backend.models.attachment import Attachment
from backend.models.case import Case
from backend.models.enums import CaseStatus, CaseType, MessageVisibility, Priority, UserRole
from backend.models.message import Message
from backend.models.sla import SLA
from backend.models.user import User
from backend.providers.ai.gemini_provider import get_ai_provider
from backend.providers.notifications.email import get_notification_provider
from backend.providers.storage.supabase_storage import get_storage_provider
from backend.repositories.attachment_repo import attachment_repository
from backend.repositories.audit_repo import audit_repository
from backend.repositories.case_repo import case_repository
from backend.repositories.message_repo import message_repository
from backend.schemas.case import (
    CaseAssignRequest,
    CaseCreateRequest,
    CaseReopenRequest,
    CaseStatusTransitionRequest,
    CaseUpdateRequest,
)
from backend.schemas.message import MessageCreateRequest
from backend.services.sla_service import sla_service


class CaseService:
    """
    Case Lifecycle & Collaboration Service per SRS v3.3 §4, §5, §6.
    Handles Incident/Request lifecycle transitions, SLA math, optimistic concurrency, and AI triage.
    """

    ALLOWED_TRANSITIONS = {
        CaseStatus.DRAFT: [CaseStatus.NEW, CaseStatus.CANCELLED],
        CaseStatus.NEW: [CaseStatus.IN_ASSESSMENT, CaseStatus.ASSIGNED, CaseStatus.CANCELLED],
        CaseStatus.IN_ASSESSMENT: [CaseStatus.ASSIGNED, CaseStatus.CANCELLED],
        CaseStatus.ASSIGNED: [
            CaseStatus.AWAITING_REQUESTER,
            CaseStatus.AWAITING_APPROVAL,
            CaseStatus.RESOLVED,
            CaseStatus.CANCELLED,
        ],
        CaseStatus.AWAITING_REQUESTER: [CaseStatus.ASSIGNED, CaseStatus.RESOLVED, CaseStatus.CANCELLED],
        CaseStatus.AWAITING_APPROVAL: [CaseStatus.ASSIGNED, CaseStatus.CANCELLED],
        CaseStatus.PENDING: [CaseStatus.ASSIGNED, CaseStatus.RESOLVED],
        CaseStatus.RESOLVED: [CaseStatus.CLOSED, CaseStatus.ASSIGNED],  # Reopens to Assigned if fix rejected
        CaseStatus.CLOSED: [CaseStatus.ASSIGNED],  # Reopens within 7 days
        CaseStatus.CANCELLED: [],
    }

    ALLOWED_MIME_TYPES = [
        "image/jpeg",
        "image/png",
        "image/webp",
        "image/gif",
        "application/pdf",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "text/plain",
        "text/x-log",
    ]

    async def create_case(self, db: AsyncSession, current_user: User, req: CaseCreateRequest) -> Case:
        # 1. Generate human-readable reference number (e.g. INC-2026-000001)
        ref_num = await case_repository.generate_reference_number(db, req.type)

        # 2. Priority calculation (default to P3 or requested)
        priority = req.priority or Priority.P3_MEDIUM
        site = req.site or current_user.site

        # 3. Create Case record
        case = Case(
            reference_number=ref_num,
            type=req.type,
            title=req.title,
            description=req.description,
            status=CaseStatus.NEW,
            priority=priority,
            requester_id=current_user.id,
            site=site,
            service_id=req.service_id,
            version=1,
        )
        db.add(case)
        await db.flush()  # Populates case.id

        # 4. Calculate initial 24/7 SLA deadlines and create SLA record
        target_resp, target_res = sla_service.calculate_targets(priority, case.created_at)
        sla = SLA(
            case_id=case.id,
            target_response_at=target_resp,
            target_resolve_at=target_res,
            response_breached=False,
            resolve_breached=False,
        )
        db.add(sla)

        # 5. Synchronous AI Triage Analysis per SRS §5.2 (Level 1)
        ai_provider = get_ai_provider()
        try:
            triage = await ai_provider.analyze_case(
                title=case.title,
                description=case.description,
                metadata={"site": site, "service_id": req.service_id},
            )
            triage_record = AITriageResult(
                case_id=case.id,
                suggested_category=triage.suggested_category,
                suggested_severity=triage.suggested_severity,
                suggested_priority=triage.suggested_priority,
                confidence_level=triage.confidence_level,
                confidence_score=triage.confidence_score,
                supporting_factors=triage.supporting_factors,
                missing_info=triage.missing_info,
                suggested_team=triage.suggested_team,
                recommended_next_action=triage.recommended_next_action,
            )
            db.add(triage_record)
        except Exception:
            # Graceful degradation per SRS §9: case creation succeeds even if AI is unavailable
            pass

        # 6. Initialize empty Continuous Case Summary per SRS §5.3
        summary = CaseSummary(
            case_id=case.id,
            summary_text=f"Initial report: {case.title}. Awaiting triage and assignment.",
        )
        db.add(summary)

        # 7. Write immutable AuditLog
        await audit_repository.log(
            db,
            action="case.created",
            target_type="case",
            target_id=str(case.id),
            actor_id=str(current_user.id),
            after_value={"reference_number": ref_num, "status": case.status.value, "priority": priority.value},
        )

        await db.commit()
        await db.refresh(case)
        return case

    async def transition_status(
        self,
        db: AsyncSession,
        case_id: str,
        current_user: User,
        req: CaseStatusTransitionRequest,
    ) -> Case:
        case = await case_repository.get_with_details(db, case_id)
        if not case:
            raise NotFoundError(message="Case not found")

        # 1. Optimistic locking check per SRS §7.12
        if case.version != req.version:
            raise StaleVersionError()

        # 2. RBAC check: Requesters can only cancel their own cases
        if current_user.role == UserRole.REQUESTER:
            if case.requester_id != current_user.id or req.target_status != CaseStatus.CANCELLED:
                raise PermissionDeniedError(message="Requesters can only cancel their own cases")

        # 3. Validate lifecycle state transition per SRS §6.1
        allowed = self.ALLOWED_TRANSITIONS.get(case.status, [])
        if req.target_status not in allowed:
            raise ValidationError(
                message=f"Invalid state transition from '{case.status.value}' to '{req.target_status.value}'"
            )

        before_status = case.status
        case.status = req.target_status
        now = datetime.now(timezone.utc)

        # Handle resolution timestamp & SLA
        if req.target_status == CaseStatus.RESOLVED:
            case.resolved_at = now
            if case.sla and not case.sla.resolved_at:
                case.sla.resolved_at = now
        elif req.target_status == CaseStatus.CLOSED:
            case.closed_at = now

        # Increment version for concurrency
        case.version += 1

        # Write immutable AuditLog
        await audit_repository.log(
            db,
            action="case.status_changed",
            target_type="case",
            target_id=str(case.id),
            actor_id=str(current_user.id),
            before_value={"status": before_status.value, "version": req.version},
            after_value={"status": case.status.value, "version": case.version, "reason": req.reason},
        )

        await db.commit()
        await db.refresh(case)
        return case

    async def assign_case(
        self,
        db: AsyncSession,
        case_id: str,
        current_user: User,
        req: CaseAssignRequest,
    ) -> Case:
        case = await case_repository.get_with_details(db, case_id)
        if not case:
            raise NotFoundError(message="Case not found")

        if case.version != req.version:
            raise StaleVersionError()

        # RBAC: Requesters cannot assign cases
        if current_user.role == UserRole.REQUESTER:
            raise PermissionDeniedError(message="Requesters are not permitted to assign cases")

        before_owner = str(case.owner_id) if case.owner_id else None
        before_team = str(case.team_id) if case.team_id else None

        if req.owner_id is not None:
            case.owner_id = req.owner_id
        if req.team_id is not None:
            case.team_id = req.team_id

        # Auto-progress from New / In Assessment to Assigned
        if case.status in [CaseStatus.NEW, CaseStatus.IN_ASSESSMENT]:
            case.status = CaseStatus.ASSIGNED

        case.version += 1

        await audit_repository.log(
            db,
            action="case.assigned",
            target_type="case",
            target_id=str(case.id),
            actor_id=str(current_user.id),
            before_value={"owner_id": before_owner, "team_id": before_team},
            after_value={"owner_id": str(case.owner_id), "team_id": str(case.team_id), "status": case.status.value},
        )

        await db.commit()
        await db.refresh(case)
        return case

    async def reopen_case(
        self,
        db: AsyncSession,
        case_id: str,
        current_user: User,
        req: CaseReopenRequest,
    ) -> Case:
        """
        Reopens a closed case within 7 calendar days per SRS §6.
        Resets status to Assigned and starts a new SLA clock.
        """
        case = await case_repository.get_with_details(db, case_id)
        if not case:
            raise NotFoundError(message="Case not found")

        if case.version != req.version:
            raise StaleVersionError()

        if case.status != CaseStatus.CLOSED:
            raise ValidationError(message="Only closed cases can be reopened")

        # 7 calendar days rule verification
        if case.closed_at:
            cutoff = case.closed_at + timedelta(days=7)
            if datetime.now(timezone.utc) > cutoff:
                raise ValidationError(message="Reopen window expired (must be within 7 calendar days of closure)")

        # Reopen transitions to Assigned
        case.status = CaseStatus.ASSIGNED
        case.resolved_at = None
        case.closed_at = None
        case.version += 1

        # Start a new SLA clock per SRS §6
        target_resp, target_res = sla_service.calculate_targets(case.priority)
        if case.sla:
            case.sla.target_response_at = target_resp
            case.sla.target_resolve_at = target_res
            case.sla.response_breached = False
            case.sla.resolve_breached = False
            case.sla.first_responded_at = None
            case.sla.resolved_at = None

        # Add message recording reopen reason
        reopen_msg = Message(
            case_id=case.id,
            author_id=current_user.id,
            body=f"[CASE REOPENED]: {req.reason}",
            visibility=MessageVisibility.REQUESTER_VISIBLE,
            ai_generated=False,
        )
        db.add(reopen_msg)

        await audit_repository.log(
            db,
            action="case.reopened",
            target_type="case",
            target_id=str(case.id),
            actor_id=str(current_user.id),
            after_value={"reason": req.reason, "new_status": CaseStatus.ASSIGNED.value},
        )

        await db.commit()
        await db.refresh(case)
        return case

    async def add_message(
        self,
        db: AsyncSession,
        case_id: str,
        current_user: User,
        req: MessageCreateRequest,
    ) -> Message:
        case = await case_repository.get_with_details(db, case_id)
        if not case:
            raise NotFoundError(message="Case not found")

        # RBAC: Requesters can NEVER create internal_only notes per SRS §4, §7.6
        if current_user.role == UserRole.REQUESTER:
            if req.visibility == MessageVisibility.INTERNAL_ONLY:
                raise PermissionDeniedError(message="Requesters are not permitted to add internal notes")
            if case.requester_id != current_user.id:
                raise PermissionDeniedError(message="You can only communicate on your own cases")

        message = Message(
            case_id=case.id,
            author_id=current_user.id,
            body=req.body,
            visibility=req.visibility,
            ai_generated=req.ai_generated,
        )
        db.add(message)

        # If case was Awaiting Requester and Requester responded, auto-transition to Assigned
        if case.status == CaseStatus.AWAITING_REQUESTER and current_user.id == case.requester_id:
            case.status = CaseStatus.ASSIGNED
            case.version += 1

        # Track first response time on SLA if responded by staff
        if current_user.role != UserRole.REQUESTER and case.sla and not case.sla.first_responded_at:
            case.sla.first_responded_at = datetime.now(timezone.utc)

        # Trigger synchronous Continuous Case Summary update per SRS §5.3 (Level 0)
        try:
            messages = await message_repository.list_by_case(db, case_id, allow_internal=True)
            history = [{"author": m.author.email if m.author else "system", "body": m.body} for m in messages]
            ai_provider = get_ai_provider()
            new_summary = await ai_provider.summarize_case(history, req.body)
            if case.summary:
                case.summary.summary_text = new_summary
                case.summary.last_source_message_id = message.id
        except Exception:
            pass

        await audit_repository.log(
            db,
            action="message.created",
            target_type="case",
            target_id=str(case.id),
            actor_id=str(current_user.id),
            after_value={"visibility": req.visibility.value, "ai_generated": req.ai_generated},
        )

        await db.commit()
        await db.refresh(message)
        return message

    async def upload_attachment(
        self,
        db: AsyncSession,
        case_id: str,
        current_user: User,
        file_name: str,
        file_data: bytes,
        content_type: str,
    ) -> Attachment:
        case = await case_repository.get(db, case_id)
        if not case:
            raise NotFoundError(message="Case not found")

        # Validate file constraints per SRS §7.5 (max 10MB per file)
        if len(file_data) > 10 * 1024 * 1024:
            raise ValidationError(message="File exceeds maximum allowed size of 10MB")

        if content_type not in self.ALLOWED_MIME_TYPES:
            raise ValidationError(message=f"File type '{content_type}' is not permitted")

        # Server-generated UUID storage filename per SRS §4, §7.5
        ext = file_name.split(".")[-1] if "." in file_name else "bin"
        storage_path = f"cases/{case.id}/{uuid.uuid4()}.{ext}"

        storage_provider = get_storage_provider()
        await storage_provider.upload_file(file_data, storage_path, content_type)

        attachment = Attachment(
            case_id=case.id,
            uploaded_by=current_user.id,
            file_name=file_name,
            storage_path=storage_path,
            file_type=content_type,
            size_bytes=len(file_data),
        )
        db.add(attachment)

        await audit_repository.log(
            db,
            action="attachment.uploaded",
            target_type="case",
            target_id=str(case.id),
            actor_id=str(current_user.id),
            after_value={"file_name": file_name, "storage_path": storage_path, "size_bytes": len(file_data)},
        )

        await db.commit()
        await db.refresh(attachment)
        return attachment


import uuid  # placed at module level
case_service = CaseService()
