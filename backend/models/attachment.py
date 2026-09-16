from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel


class Attachment(TimeStampedUUIDModel):
    """
    Attachment entity per SRS v3.3 §4, §7.5.
    Tracks files uploaded to Supabase Storage with UUID storage paths.
    """
    __tablename__ = "attachments"

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    uploaded_by = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)

    file_name = Column(String(255), nullable=False)
    storage_path = Column(String(500), nullable=False, unique=True)
    file_type = Column(String(100), nullable=False)  # MIME type
    size_bytes = Column(Integer, nullable=False)

    # Relationships
    case = relationship("Case", back_populates="attachments")
    uploader = relationship("User")
