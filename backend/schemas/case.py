from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from backend.models.enums import CaseStatus, CaseType, Priority, UserRole
from backend.schemas.auth import UserResponse


class CaseCreateRequest(BaseModel):
    title: str = Field(..., min_length=5, max_length=200, description="Brief summary of the issue or request")
    description: str = Field(..., min_length=10, max_length=10000, description="Detailed explanation of the issue")
    type: CaseType = Field(default=CaseType.INCIDENT, description="Incident or Service Request")
    priority: Optional[Priority] = Field(None, description="Optional user-suggested priority")
    site: Optional[str] = Field(None, description="Location context")
    service_id: Optional[str] = Field(None, description="Optional service/catalog identifier")


class CaseUpdateRequest(BaseModel):
    version: int = Field(..., description="Optimistic locking version integer")
    priority: Optional[Priority] = None
    site: Optional[str] = None
    service_id: Optional[str] = None


class CaseStatusTransitionRequest(BaseModel):
    version: int = Field(..., description="Current version integer to prevent concurrent overrides")
    target_status: CaseStatus = Field(..., description="Target lifecycle state")
    reason: Optional[str] = Field(None, description="Reason or evidence for the transition")


class CaseAssignRequest(BaseModel):
    version: int = Field(..., description="Optimistic locking version")
    owner_id: Optional[str] = Field(None, description="User ID of assigned operator")
    team_id: Optional[str] = Field(None, description="Team ID for assignment")


class CaseReopenRequest(BaseModel):
    version: int = Field(..., description="Optimistic locking version")
    reason: str = Field(..., min_length=5, description="Reason why the issue is still persisting")


class SLAResponse(BaseModel):
    target_response_at: datetime
    target_resolve_at: datetime
    response_breached: bool
    resolve_breached: bool
    first_responded_at: Optional[datetime]
    resolved_at: Optional[datetime]
    paused_reason: Optional[str]

    class Config:
        from_attributes = True


class AITriageSummaryResponse(BaseModel):
    suggested_category: str
    suggested_severity: str
    suggested_priority: str
    confidence_level: str
    supporting_factors: List[str]
    missing_info: List[str]
    suggested_team: Optional[str]
    recommended_next_action: Optional[str]

    class Config:
        from_attributes = True


class CaseResponse(BaseModel):
    id: str
    reference_number: str
    type: CaseType
    title: str
    description: str
    status: CaseStatus
    priority: Priority
    requester_id: str
    owner_id: Optional[str]
    team_id: Optional[str]
    site: Optional[str]
    service_id: Optional[str]
    version: int
    created_at: datetime
    updated_at: datetime
    resolved_at: Optional[datetime]
    closed_at: Optional[datetime]

    class Config:
        from_attributes = True


class CaseDetailResponse(CaseResponse):
    requester: Optional[UserResponse] = None
    owner: Optional[UserResponse] = None
    sla: Optional[SLAResponse] = None
    triage_result: Optional[AITriageSummaryResponse] = None
    summary_text: Optional[str] = None
    risk_level: Optional[str] = None
