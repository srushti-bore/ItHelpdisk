from typing import Generic, List, Optional, TypeVar, Dict, Any
from pydantic import BaseModel, Field

T = TypeVar("T")


class ErrorDetail(BaseModel):
    code: str = Field(..., description="Stable machine-readable error code")
    message: str = Field(..., description="Human-readable safe error summary")
    details: Dict[str, Any] = Field(default_factory=dict, description="Field-level or contextual error details")


class ErrorEnvelope(BaseModel):
    error: ErrorDetail


class PaginatedResponse(BaseModel, Generic[T]):
    """Standard pagination envelope per SRS §3.6."""
    items: List[T]
    page: int = Field(1, ge=1, description="Current page number (1-indexed)")
    page_size: int = Field(20, ge=1, le=100, description="Items per page (max 100)")
    total: int = Field(..., ge=0, description="Total count of matching items")


class PaginationParams(BaseModel):
    page: int = Field(1, ge=1, description="Page number")
    page_size: int = Field(20, ge=1, le=100, description="Items per page")


class HealthResponse(BaseModel):
    status: str = "ok"
    db: str = "ok"
    environment: str
    timestamp: str
