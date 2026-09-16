from sqlalchemy import Column, ForeignKey, JSON, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel


class AuditLog(TimeStampedUUIDModel):
    """
    Audit Log entity per SRS v3.3 §4, §5.11 and AGENTS.md Rule 9.
    Immutable, append-only ledger of material system and user actions.
    """
    __tablename__ = "audit_logs"

    actor_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    action = Column(String(100), nullable=False, index=True)  # e.g. 'case.created', 'case.assigned', 'sla.breached'
    
    target_type = Column(String(50), nullable=False, index=True)  # e.g. 'case', 'user', 'sla', 'draft'
    target_id = Column(String(100), nullable=False, index=True)

    before_value = Column(JSON, nullable=True)
    after_value = Column(JSON, nullable=True)

    # Relationships
    actor = relationship("User", back_populates="audit_logs")
