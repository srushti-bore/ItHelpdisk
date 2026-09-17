from datetime import datetime
from typing import Any, Dict, List, Optional, Union
from uuid import UUID
from pydantic import BaseModel, Field
from backend.models.enums import DraftStatus, DraftType


class DraftGenerateRequest(BaseModel):
    draft_type: DraftType = Field(..., description="info_request | progress_update | resolution | escalation_summary")
    custom_instructions: Optional[str] = Field(None, description="Optional extra instructions or bullet points for the AI")


class DraftSendRequest(BaseModel):
    body: str = Field(..., min_length=1, description="Final reviewed message body (may be edited by human)")


class DraftResponse(BaseModel):
    id: Union[UUID, str]
    case_id: Union[UUID, str]
    draft_type: DraftType
    body: str
    status: DraftStatus
    reviewed_by: Optional[Union[UUID, str]]
    sent_message_id: Optional[Union[UUID, str]]
    created_at: datetime

    class Config:
        from_attributes = True


class CandidateOperator(BaseModel):
    user_id: Union[UUID, str]
    full_name: str
    email: str
    site: Optional[str]
    availability_status: str
    active_case_count: int
    match_score: float
    reasons: List[str]


class SmartAssignmentResponse(BaseModel):
    case_id: Union[UUID, str]
    recommended_team: Optional[str]
    candidate_operators: List[CandidateOperator]
    reasoning: str


class DuplicateCandidate(BaseModel):
    case_id: Union[UUID, str]
    reference_number: str
    title: str
    status: str
    similarity_score: float
    created_at: datetime


class DuplicateDetectionResponse(BaseModel):
    case_id: Union[UUID, str]
    candidates: List[DuplicateCandidate]


class OperationalMetrics(BaseModel):
    total_cases: int
    open_cases: int
    resolved_cases: int
    sla_compliance_rate: float
    average_resolution_hours: float
    cases_by_category: Dict[str, int]
    cases_by_priority: Dict[str, int]
    cases_by_site: Dict[str, int]
    risk_breakdown: Dict[str, int]


class OperationalInsightsResponse(BaseModel):
    generated_at: datetime
    metrics: OperationalMetrics
    ai_narrative_summary: str
