from sqlalchemy import Boolean, Column, Enum, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from backend.models.base import TimeStampedUUIDModel
from backend.models.enums import AuthProviderType, AvailabilityStatus, UserRole


class Team(TimeStampedUUIDModel):
    """Team entity representing support desk departments or functional groups."""
    __tablename__ = "teams"

    name = Column(String(100), unique=True, nullable=False, index=True)
    description = Column(String(500), nullable=True)
    lead_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)

    # Relationships
    members = relationship("User", back_populates="team", foreign_keys="User.team_id")
    lead = relationship("User", foreign_keys=[lead_id], post_update=True)


class User(TimeStampedUUIDModel):
    """
    User entity per SRS v3.3 §4.
    Supports both Password-based and Google OAuth 2.0 / OIDC sign-ins.
    """
    __tablename__ = "users"

    email = Column(String(255), unique=True, nullable=False, index=True)
    full_name = Column(String(150), nullable=True)
    password_hash = Column(String(255), nullable=True)  # Nullable for OAuth-only accounts per SRS §4

    auth_provider = Column(
        Enum(AuthProviderType, name="auth_provider_type"),
        default=AuthProviderType.PASSWORD,
        nullable=False,
    )
    oauth_subject_id = Column(String(255), nullable=True, index=True)  # Google 'sub' claim

    role = Column(
        Enum(UserRole, name="user_role"),
        default=UserRole.REQUESTER,
        nullable=False,
        index=True,
    )
    team_id = Column(UUID(as_uuid=True), ForeignKey("teams.id", ondelete="SET NULL"), nullable=True)
    
    site = Column(String(100), nullable=True)  # Feeds smart assignment (e.g. Pune, Mumbai, Remote)
    availability_status = Column(
        Enum(AvailabilityStatus, name="availability_status"),
        default=AvailabilityStatus.AVAILABLE,
        nullable=False,
    )
    email_verified = Column(Boolean, default=False, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    team = relationship("Team", back_populates="members", foreign_keys=[team_id])
    created_cases = relationship("Case", back_populates="requester", foreign_keys="Case.requester_id")
    assigned_cases = relationship("Case", back_populates="owner", foreign_keys="Case.owner_id")
    messages = relationship("Message", back_populates="author")
    audit_logs = relationship("AuditLog", back_populates="actor")
