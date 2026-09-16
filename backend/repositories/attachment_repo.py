from typing import List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.models.attachment import Attachment
from backend.repositories.base import BaseRepository


class AttachmentRepository(BaseRepository[Attachment]):
    def __init__(self):
        super().__init__(Attachment)

    async def list_by_case(self, db: AsyncSession, case_id: str) -> List[Attachment]:
        stmt = select(Attachment).where(Attachment.case_id == case_id).order_by(Attachment.created_at.asc())
        result = await db.execute(stmt)
        return list(result.scalars().all())


attachment_repository = AttachmentRepository()
