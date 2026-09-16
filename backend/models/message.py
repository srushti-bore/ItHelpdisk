from sqlalchemy import Boolean, Column, Enum, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel
from backend.models.enums import MessageVisibility


class Message(TimeStampedUUIDModel):
    """
    Message / Note entity per SRS v3.3 §4.
    Supports separate requester-visible communication and staff internal-only notes.
    """
    __tablename__ = "messages"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    
    body = Column(Text, nullable=False)
    visibility = Column(
        Enum(MessageVisibility, name="message_visibility"),
        default=MessageVisibility.REQUESTER_VISIBLE,
        nullable=False,
        index=True,
    )
    ai_generated = Column(Boolean, default=False, nullable=False)

    # Relationships
    case = relationship("Case", back_populates="messages")
    author = relationship("User", back_populates="messages")
