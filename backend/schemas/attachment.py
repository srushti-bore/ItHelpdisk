from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class AttachmentResponse(BaseModel):
    id: str
    case_id: str
    file_name: str
    file_type: str
    size_bytes: int
    uploaded_by: Optional[str]
    download_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
