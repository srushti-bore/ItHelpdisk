from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel


class SLA(TimeStampedUUIDModel):
    """
    SLA entity per SRS v3.3 §4.3.
    Operates strictly on 24/7 elapsed wall-clock time.
    """
    __tablename__ = "slas"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), unique=True, nullable=False)

    target_response_at = Column(DateTime(timezone=True), nullable=False)
    target_resolve_at = Column(DateTime(timezone=True), nullable=False)

    first_responded_at = Column(DateTime(timezone=True), nullable=True)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    response_breached = Column(Boolean, default=False, nullable=False)
    resolve_breached = Column(Boolean, default=False, nullable=False)
    
    paused_reason = Column(String(255), nullable=True)

    # Relationships
    case = relationship("Case", back_populates="sla")
