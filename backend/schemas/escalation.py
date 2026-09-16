from datetime import datetime
from typing import Optional
from pydantic import BaseModel
from backend.models.enums import EscalationReason, EscalationStatus


class EscalationResponse(BaseModel):
    id: str
    case_id: str
    trigger_reason: EscalationReason
    escalated_to: str
    escalated_by: Optional[str]
    status: EscalationStatus
    acknowledged_at: Optional[datetime]
    resolved_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class EscalationAcknowledgeRequest(BaseModel):
    note: Optional[str] = None
