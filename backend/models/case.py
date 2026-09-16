from sqlalchemy import Column, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel
from backend.models.enums import CaseStatus, CaseType, Priority, RelationshipType


class Case(TimeStampedUUIDModel):
    """
    Central Case entity per SRS v3.3 §4, §5.1, §6.
    Represents Incidents and Service Requests with optimistic locking and soft deletion.
    """
    __tablename__ = "cases"

    reference_number = Column(String(50), unique=True, nullable=False, index=True)
    type = Column(Enum(CaseType, name="case_type"), nullable=False, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)  # Immutable requester input
    
    status = Column(
        Enum(CaseStatus, name="case_status"),
        default=CaseStatus.NEW,
        nullable=False,
        index=True,
    )
    priority = Column(
        Enum(Priority, name="priority_level"),
        default=Priority.P3_MEDIUM,
        nullable=False,
        index=True,
    )

    requester_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    team_id = Column(UUID(as_uuid=True), ForeignKey("teams.id", ondelete="SET NULL"), nullable=True)
    
    site = Column(String(100), nullable=True)  # Inherited from requester at creation
    service_id = Column(String(100), nullable=True)  # Optional catalog / service identifier

    version = Column(Integer, default=1, nullable=False)  # Optimistic locking against race conditions

    resolved_at = Column(DateTime(timezone=True), nullable=True)
    closed_at = Column(DateTime(timezone=True), nullable=True)
    deleted_at = Column(DateTime(timezone=True), nullable=True)  # Soft delete flag

    # Relationships
    requester = relationship("User", back_populates="created_cases", foreign_keys=[requester_id])
    owner = relationship("User", back_populates="assigned_cases", foreign_keys=[owner_id])
    team = relationship("Team", foreign_keys=[team_id])
    
    messages = relationship("Message", back_populates="case", cascade="all, delete-orphan")
    attachments = relationship("Attachment", back_populates="case", cascade="all, delete-orphan")
    sla = relationship("SLA", back_populates="case", uselist=False, cascade="all, delete-orphan")
    triage_result = relationship("AITriageResult", back_populates="case", uselist=False, cascade="all, delete-orphan")
    summary = relationship("CaseSummary", back_populates="case", uselist=False, cascade="all, delete-orphan")
    risk_assessment = relationship("CaseRiskAssessment", back_populates="case", uselist=False, cascade="all, delete-orphan")
    escalation_events = relationship("EscalationEvent", back_populates="case", cascade="all, delete-orphan")
    drafts = relationship("CommunicationDraft", back_populates="case", cascade="all, delete-orphan")


class CaseRelationship(TimeStampedUUIDModel):
    """Links between cases (e.g. related to, duplicate of, major incident child)."""
    __tablename__ = "case_relationships"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    related_case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    relationship_type = Column(Enum(RelationshipType, name="relationship_type"), nullable=False)
