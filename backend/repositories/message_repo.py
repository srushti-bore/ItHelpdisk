from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from backend.models.enums import MessageVisibility
from backend.models.message import Message
from backend.repositories.base import BaseRepository


class MessageRepository(BaseRepository[Message]):
    def __init__(self):
        super().__init__(Message)

    async def list_by_case(
        self, db: AsyncSession, case_id: str, allow_internal: bool = False
    ) -> List[Message]:
        stmt = select(Message).where(Message.case_id == case_id)
        if not allow_internal:
            stmt = stmt.where(Message.visibility == MessageVisibility.REQUESTER_VISIBLE)

        stmt = stmt.order_by(Message.created_at.asc()).options(selectinload(Message.author))
        result = await db.execute(stmt)
        return list(result.scalars().all())


message_repository = MessageRepository()
