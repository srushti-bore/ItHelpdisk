from abc import ABC, abstractmethod
from typing import BinaryIO, Optional


class StorageProvider(ABC):
    """Abstract interface for file storage (Supabase Storage / Local Disk)."""

    @abstractmethod
    async def upload_file(self, file_data: bytes, destination_path: str, content_type: str) -> str:
        """Uploads a file and returns its storage reference/path."""
        pass

    @abstractmethod
    async def get_file_url(self, storage_path: str, expires_in: int = 3600) -> str:
        """Generates a secure download URL for the file."""
        pass

    @abstractmethod
    async def delete_file(self, storage_path: str) -> bool:
        """Deletes a file from storage."""
        pass
