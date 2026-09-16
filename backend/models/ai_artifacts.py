from datetime import datetime, timezone
from sqlalchemy import ARRAY, Column, DateTime, Enum, Float, ForeignKey, JSON, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel
from backend.models.enums import ConfidenceLevel, DraftStatus, DraftType, RiskLevel


class AITriageResult(TimeStampedUUIDModel):
    """
    AI Triage Result entity per SRS v3.3 §4, §5.2.
    Stores initial Gemini analysis suggestions for human review.
    """
    __tablename__ = "ai_triage_results"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), unique=True, nullable=False)

    suggested_category = Column(String(100), nullable=False)
    suggested_severity = Column(String(50), nullable=False)
    suggested_priority = Column(String(20), nullable=False)

    confidence_level = Column(Enum(ConfidenceLevel, name="confidence_level"), nullable=False)
    confidence_score = Column(Float, nullable=False)  # Internal metric (0.0 to 1.0)

    supporting_factors = Column(JSON, default=list, nullable=False)
    missing_info = Column(JSON, default=list, nullable=False)

    suggested_team = Column(String(100), nullable=True)
    recommended_next_action = Column(String(255), nullable=True)
    related_case_ids = Column(JSON, default=list, nullable=False)

    # Relationships
    case = relationship("Case", back_populates="triage_result")


class CaseSummary(TimeStampedUUIDModel):
    """
    Continuously maintained AI Case Summary entity per SRS v3.3 §4, §5.3.
    Recomputed synchronously whenever new messages are added.
    """
    __tablename__ = "case_summaries"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), unique=True, nullable=False)
    summary_text = Column(Text, nullable=False)
    last_source_message_id = Column(UUID(as_uuid=True), nullable=True)

    # Relationships
    case = relationship("Case", back_populates="summary")


class CaseRiskAssessment(TimeStampedUUIDModel):
    """
    Case Risk Assessment entity per SRS v3.3 §4, §5.7.
    Computed by 'The Sweep' (APScheduler job).
    """
    __tablename__ = "case_risk_assessments"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), unique=True, nullable=False)
    risk_level = Column(Enum(RiskLevel, name="risk_level"), nullable=False)
    signals = Column(JSON, default=dict, nullable=False)  # inactivity_hours, follow_up_count, etc.
    computed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    # Relationships
    case = relationship("Case", back_populates="risk_assessment")


class CommunicationDraft(TimeStampedUUIDModel):
    """
    AI-generated Communication Draft entity per SRS v3.3 §4, §5.9.
    Never sent automatically; human must review/edit before sending.
    """
    __tablename__ = "communication_drafts"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    draft_type = Column(Enum(DraftType, name="draft_type"), nullable=False)
    body = Column(Text, nullable=False)
    status = Column(Enum(DraftStatus, name="draft_status"), default=DraftStatus.DRAFT, nullable=False)

    reviewed_by = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    sent_message_id = Column(UUID(as_uuid=True), ForeignKey("messages.id", ondelete="SET NULL"), nullable=True)

    # Relationships
    case = relationship("Case", back_populates="drafts")
    reviewer = relationship("User")
    sent_message = relationship("Message")
