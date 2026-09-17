from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.api.deps import get_current_user, require_roles
from backend.db.session import get_db
from backend.models.enums import ArticleState, UserRole
from backend.models.knowledge import KnowledgeArticle
from backend.models.user import User
from backend.schemas.common import PaginatedResponse
from backend.schemas.knowledge import (
    KnowledgeArticleCreate,
    KnowledgeArticleResponse,
    KnowledgeArticleUpdate,
)

router = APIRouter()


@router.get("/articles", response_model=PaginatedResponse[KnowledgeArticleResponse])
async def list_knowledge_articles(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Lists knowledge base articles with search and category filter.
    Requesters see only PUBLISHED articles. Knowledge Owners / Admins see all.
    """
    stmt = select(KnowledgeArticle)

    # Filter by user role visibility
    if current_user.role in [UserRole.REQUESTER, UserRole.OPERATOR]:
        stmt = stmt.where(KnowledgeArticle.state == ArticleState.PUBLISHED)

    if category and category.lower() != "all":
        stmt = stmt.where(KnowledgeArticle.category.ilike(f"%{category}%"))

    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(
            or_(
                KnowledgeArticle.title.ilike(term),
                KnowledgeArticle.body.ilike(term),
                KnowledgeArticle.category.ilike(term),
            )
        )

    stmt = stmt.order_by(KnowledgeArticle.updated_at.desc())

    # Count total
    all_articles = list((await db.execute(stmt)).scalars().all())
    total = len(all_articles)

    # Paginate
    offset = (page - 1) * page_size
    items = all_articles[offset : offset + page_size]

    return PaginatedResponse(
        total=total,
        page=page,
        page_size=page_size,
        items=items,
    )


@router.post("/articles", response_model=KnowledgeArticleResponse, status_code=status.HTTP_201_CREATED)
async def create_knowledge_article(
    payload: KnowledgeArticleCreate,
    current_user: User = Depends(require_roles([UserRole.KNOWLEDGE_OWNER, UserRole.ADMINISTRATOR, UserRole.OPERATOR])),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new knowledge base article per SRS §4.
    """
    article = KnowledgeArticle(
        title=payload.title,
        body=payload.body,
        category=payload.category,
        author_id=current_user.id,
        state=payload.state or ArticleState.DRAFT,
        source_case_id=payload.source_case_id,
    )
    db.add(article)
    await db.commit()
    await db.refresh(article)
    return article


@router.get("/articles/{article_id}", response_model=KnowledgeArticleResponse)
async def get_knowledge_article(
    article_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieves a single knowledge base article.
    """
    stmt = select(KnowledgeArticle).where(KnowledgeArticle.id == article_id)
    article = (await db.execute(stmt)).scalar_one_or_none()
    if not article:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")

    if current_user.role in [UserRole.REQUESTER, UserRole.OPERATOR] and article.state != ArticleState.PUBLISHED:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Article is not published")

    return article


@router.patch("/articles/{article_id}", response_model=KnowledgeArticleResponse)
async def update_knowledge_article(
    article_id: str,
    payload: KnowledgeArticleUpdate,
    current_user: User = Depends(require_roles([UserRole.KNOWLEDGE_OWNER, UserRole.ADMINISTRATOR])),
    db: AsyncSession = Depends(get_db),
):
    """
    Updates an existing article (e.g., publish, edit content, review date).
    """
    stmt = select(KnowledgeArticle).where(KnowledgeArticle.id == article_id)
    article = (await db.execute(stmt)).scalar_one_or_none()
    if not article:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")

    update_data = payload.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        setattr(article, field, val)

    await db.commit()
    await db.refresh(article)
    return article
