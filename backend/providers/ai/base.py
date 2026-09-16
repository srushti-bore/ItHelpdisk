from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional
from pydantic import BaseModel


class TriageOutput(BaseModel):
    suggested_category: str
    suggested_severity: str
    suggested_priority: str
    confidence_level: str  # Low | Moderate | High
    confidence_score: float
    supporting_factors: List[str]
    missing_info: List[str]
    suggested_team: Optional[str] = None
    recommended_next_action: Optional[str] = None


class DraftOutput(BaseModel):
    draft_type: str
    body: str


class AIProvider(ABC):
    """Abstract interface for AI capabilities (Gemini / Mock)."""

    @abstractmethod
    async def analyze_case(self, title: str, description: str, metadata: Optional[Dict[str, Any]] = None) -> TriageOutput:
        """Analyzes case description on creation (Level 1)."""
        pass

    @abstractmethod
    async def summarize_case(self, case_history: List[Dict[str, Any]], new_message: str) -> str:
        """Continuously recomputes case summary on new message (Level 0)."""
        pass

    @abstractmethod
    async def generate_draft(self, draft_type: str, context: Dict[str, Any]) -> DraftOutput:
        """Generates communication draft for operator review (Level 1)."""
        pass

    @abstractmethod
    async def narrate_operational_insights(self, aggregate_data: Dict[str, Any]) -> str:
        """Narrates plain-language insights from aggregate metrics for Managers (Level 0)."""
        pass
