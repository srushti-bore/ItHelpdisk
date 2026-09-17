from datetime import datetime
from typing import Optional, Union
from uuid import UUID
from pydantic import BaseModel
from backend.models.enums import EscalationReason, EscalationStatus


class EscalationResponse(BaseModel):
    id: Union[UUID, str]
    case_id: Union[UUID, str]
    trigger_reason: EscalationReason
    escalated_to: str
    escalated_by: Optional[Union[UUID, str]]
    status: EscalationStatus
    acknowledged_at: Optional[datetime]
    resolved_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class EscalationAcknowledgeRequest(BaseModel):
    note: Optional[str] = None
