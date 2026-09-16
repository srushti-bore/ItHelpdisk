# Import all models here so that Alembic and SQLAlchemy can register their metadata
from backend.db.session import Base  # noqa: F401
from backend.models.user import Team, User  # noqa: F401
from backend.models.case import Case, CaseRelationship  # noqa: F401
from backend.models.message import Message  # noqa: F401
from backend.models.attachment import Attachment  # noqa: F401
from backend.models.sla import SLA  # noqa: F401
from backend.models.ai_artifacts import (  # noqa: F401
    AITriageResult,
    CaseRiskAssessment,
    CaseSummary,
    CommunicationDraft,
)
from backend.models.escalation import EscalationEvent  # noqa: F401
from backend.models.audit import AuditLog  # noqa: F401
from backend.models.knowledge import KnowledgeArticle  # noqa: F401
