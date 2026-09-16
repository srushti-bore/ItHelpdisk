from sqlalchemy import Column, DateTime, Enum, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel
from backend.models.enums import EscalationReason, EscalationStatus


class EscalationEvent(TimeStampedUUIDModel):
    """
    Escalation Event entity per SRS v3.3 §4, §5.8.
    Triggered by 'The Sweep' or explicitly by an operator.
    """
    __tablename__ = "escalation_events"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    trigger_reason = Column(Enum(EscalationReason, name="escalation_reason"), nullable=False)
    
    escalated_to = Column(String(100), nullable=False)  # User ID or Role name (e.g. 'team_lead', 'manager')
    escalated_by = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)  # Null = System

    status = Column(
        Enum(EscalationStatus, name="escalation_status"),
        default=EscalationStatus.OPEN,
        nullable=False,
    )
    acknowledged_at = Column(DateTime(timezone=True), nullable=True)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    case = relationship("Case", back_populates="escalation_events")
    actor = relationship("User", foreign_keys=[escalated_by])
