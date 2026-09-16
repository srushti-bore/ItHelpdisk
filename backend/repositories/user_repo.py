from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.models.user import Team, User
from backend.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    def __init__(self):
        super().__init__(User)

    async def get_by_email(self, db: AsyncSession, email: str) -> Optional[User]:
        """Retrieves user by case-insensitive email."""
        result = await db.execute(select(User).where(User.email.ilike(email)))
        return result.scalars().first()

    async def get_by_oauth_subject_id(self, db: AsyncSession, subject_id: str) -> Optional[User]:
        """Retrieves user by Google OAuth subject ID."""
        result = await db.execute(select(User).where(User.oauth_subject_id == subject_id))
        return result.scalars().first()


class TeamRepository(BaseRepository[Team]):
    def __init__(self):
        super().__init__(Team)

    async def get_by_name(self, db: AsyncSession, name: str) -> Optional[Team]:
        result = await db.execute(select(Team).where(Team.name == name))
        return result.scalars().first()


user_repository = UserRepository()
team_repository = TeamRepository()
