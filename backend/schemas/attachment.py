from datetime import datetime
from typing import Optional, Union
from uuid import UUID
from pydantic import BaseModel


class AttachmentResponse(BaseModel):
    id: Union[UUID, str]
    case_id: Union[UUID, str]
    file_name: str
    file_type: str
    size_bytes: int
    uploaded_by: Optional[Union[UUID, str]]
    download_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
