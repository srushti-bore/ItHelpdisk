import logging
import os
import uuid
from typing import Optional
from backend.core.config import settings
from backend.providers.storage.base import StorageProvider

logger = logging.getLogger("it_helpdesk.storage")


class SupabaseStorageProvider(StorageProvider):
    """
    Supabase Storage Provider per SRS v3.3 §3.1, §4, §7.5.
    Uploads evidence/attachments with server-generated UUID storage filenames.
    """

    def __init__(self, supabase_url: str, supabase_key: str, bucket_name: str):
        self.supabase_url = supabase_url
        self.supabase_key = supabase_key
        self.bucket_name = bucket_name
        self.client = None
        if supabase_url and supabase_key:
            try:
                from supabase import create_client
                self.client = create_client(supabase_url, supabase_key)
            except Exception as e:
                logger.warning(f"Could not initialize Supabase client: {str(e)}")

    async def upload_file(self, file_data: bytes, destination_path: str, content_type: str) -> str:
        if not self.client:
            logger.warning(f"[MOCK STORAGE] Uploaded {len(file_data)} bytes to {destination_path}")
            return destination_path

        try:
            res = self.client.storage.from_(self.bucket_name).upload(
                path=destination_path,
                file=file_data,
                file_options={"content-type": content_type},
            )
            return destination_path
        except Exception as e:
            logger.error(f"Failed to upload to Supabase storage: {str(e)}", exc_info=True)
            raise

    async def get_file_url(self, storage_path: str, expires_in: int = 3600) -> str:
        if not self.client:
            return f"/mock-storage/{storage_path}"

        try:
            res = self.client.storage.from_(self.bucket_name).create_signed_url(
                path=storage_path,
                expires_in=expires_in,
            )
            return res.get("signedURL", "")
        except Exception as e:
            logger.error(f"Failed to generate signed URL from Supabase storage: {str(e)}", exc_info=True)
            return ""

    async def delete_file(self, storage_path: str) -> bool:
        if not self.client:
            return True

        try:
            self.client.storage.from_(self.bucket_name).remove([storage_path])
            return True
        except Exception as e:
            logger.error(f"Failed to delete file from Supabase storage: {str(e)}", exc_info=True)
            return False


class LocalStorageProvider(StorageProvider):
    """Local disk storage provider for offline / local testing."""

    def __init__(self, base_dir: str = "uploads"):
        self.base_dir = base_dir
        os.makedirs(self.base_dir, exist_ok=True)

    async def upload_file(self, file_data: bytes, destination_path: str, content_type: str) -> str:
        full_path = os.path.join(self.base_dir, destination_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, "wb") as f:
            f.write(file_data)
        return destination_path

    async def get_file_url(self, storage_path: str, expires_in: int = 3600) -> str:
        return f"/api/v1/attachments/file/{storage_path}"

    async def delete_file(self, storage_path: str) -> bool:
        full_path = os.path.join(self.base_dir, storage_path)
        if os.path.exists(full_path):
            os.remove(full_path)
        return True


def get_storage_provider() -> StorageProvider:
    """Factory returning appropriate StorageProvider."""
    if settings.SUPABASE_URL and settings.SUPABASE_KEY:
        return SupabaseStorageProvider(
            supabase_url=settings.SUPABASE_URL,
            supabase_key=settings.SUPABASE_KEY,
            bucket_name=settings.SUPABASE_STORAGE_BUCKET,
        )
    return LocalStorageProvider()
