from enum import Enum


class UserRole(str, Enum):
    REQUESTER = "requester"
    OPERATOR = "operator"
    TEAM_LEAD = "team_lead"
    MANAGER = "manager"
    ADMINISTRATOR = "administrator"
    # Minimal schema stubs for future phases
    APPROVER = "approver"
    KNOWLEDGE_OWNER = "knowledge_owner"
    SERVICE_OWNER = "service_owner"
    AUDITOR = "auditor"


class AuthProviderType(str, Enum):
    PASSWORD = "password"
    GOOGLE = "google"


class AvailabilityStatus(str, Enum):
    AVAILABLE = "available"
    AWAY = "away"
    OFFLINE = "offline"


class CaseType(str, Enum):
    INCIDENT = "incident"
    SERVICE_REQUEST = "service_request"
    # Phase 2 stubs
    PROBLEM = "problem"
    CHANGE = "change"


class CaseStatus(str, Enum):
    DRAFT = "draft"
    NEW = "new"
    IN_ASSESSMENT = "in_assessment"
    ASSIGNED = "assigned"
    AWAITING_REQUESTER = "awaiting_requester"
    AWAITING_APPROVAL = "awaiting_approval"
    PENDING = "pending"
    RESOLVED = "resolved"
    CLOSED = "closed"
    CANCELLED = "cancelled"


class Priority(str, Enum):
    P1_CRITICAL = "P1"
    P2_HIGH = "P2"
    P3_MEDIUM = "P3"
    P4_LOW = "P4"


class MessageVisibility(str, Enum):
    REQUESTER_VISIBLE = "requester_visible"
    INTERNAL_ONLY = "internal_only"


class ConfidenceLevel(str, Enum):
    LOW = "Low"
    MODERATE = "Moderate"
    HIGH = "High"


class RiskLevel(str, Enum):
    LOW = "Low"
    MODERATE = "Moderate"
    HIGH = "High"
    CRITICAL = "Critical"


class EscalationReason(str, Enum):
    APPROACHING_DEADLINE = "approaching_deadline"
    MISSED_DEADLINE = "missed_deadline"
    HIGH_RISK = "high_risk"
    REPEATED_REOPEN = "repeated_reopen"
    OPERATOR_REQUESTED = "operator_requested"


class EscalationStatus(str, Enum):
    OPEN = "open"
    ACKNOWLEDGED = "acknowledged"
    RESOLVED = "resolved"


class DraftType(str, Enum):
    INFO_REQUEST = "info_request"
    PROGRESS_UPDATE = "progress_update"
    RESOLUTION = "resolution"
    ESCALATION_SUMMARY = "escalation_summary"


class DraftStatus(str, Enum):
    DRAFT = "draft"
    SENT = "sent"
    DISCARDED = "discarded"


class RelationshipType(str, Enum):
    RELATED_TO = "related_to"
    DUPLICATE_OF = "duplicate_of"
    PART_OF_MAJOR_INCIDENT = "part_of_major_incident"


class ArticleState(str, Enum):
    DRAFT = "draft"
    PUBLISHED = "published"
    ARCHIVED = "archived"
