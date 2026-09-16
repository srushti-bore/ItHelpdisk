from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field
from backend.models.enums import ArticleState


class KnowledgeArticleCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=255)
    body: str = Field(..., min_length=10)
    category: str = Field(..., min_length=2, max_length=100)
    state: Optional[ArticleState] = Field(ArticleState.DRAFT)
    source_case_id: Optional[str] = None


class KnowledgeArticleUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=3, max_length=255)
    body: Optional[str] = Field(None, min_length=10)
    category: Optional[str] = Field(None, min_length=2, max_length=100)
    state: Optional[ArticleState] = None
    review_date: Optional[datetime] = None


class KnowledgeArticleResponse(BaseModel):
    id: str
    title: str
    body: str
    category: str
    author_id: Optional[str]
    state: ArticleState
    review_date: Optional[datetime]
    source_case_id: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
