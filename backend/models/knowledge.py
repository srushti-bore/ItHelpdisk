from sqlalchemy import Column, DateTime, Enum, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel
from backend.models.enums import ArticleState


class KnowledgeArticle(TimeStampedUUIDModel):
    """
    Knowledge Article entity per SRS v3.3 §4, §6.
    Manually authored guidance for requesters and support teams.
    """
    __tablename__ = "knowledge_articles"

    title = Column(String(255), nullable=False, index=True)
    body = Column(Text, nullable=False)
    category = Column(String(100), nullable=False, index=True)

    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    state = Column(Enum(ArticleState, name="article_state"), default=ArticleState.DRAFT, nullable=False)
    
    review_date = Column(DateTime(timezone=True), nullable=True)
    source_case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="SET NULL"), nullable=True)

    # Relationships
    author = relationship("User")
    source_case = relationship("Case")
