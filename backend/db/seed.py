import asyncio
from datetime import datetime, timedelta, timezone
from sqlalchemy import select
from backend.core.security import get_password_hash
from backend.db.session import AsyncSessionLocal
from backend.models.ai_artifacts import AITriageResult, CaseRiskAssessment, CommunicationDraft
from backend.models.case import Case
from backend.models.enums import (
    ArticleState,
    CaseStatus,
    CaseType,
    ConfidenceLevel,
    DraftStatus,
    DraftType,
    EscalationReason,
    EscalationStatus,
    MessageVisibility,
    Priority,
    RiskLevel,
    UserRole,
)
from backend.models.escalation import EscalationEvent
from backend.models.knowledge import KnowledgeArticle
from backend.models.message import Message
from backend.models.sla import SLA
from backend.models.user import Team, User
from backend.services.sla_service import sla_service


async def seed_database():
    print("Starting IT Helpdesk Demo Data Seeder...")

    async with AsyncSessionLocal() as db:
        # 1. Create Teams
        teams_data = [
            {"name": "Tier 1 Service Desk", "description": "Frontline user support and initial triage"},
            {"name": "Network Operations (NOC)", "description": "Core routing, VPN, firewalls, and ISP links"},
            {"name": "Infrastructure & Cloud Ops", "description": "Kubernetes, AWS/GCP resources, and DB clusters"},
            {"name": "Identity & Access Management", "description": "Okta, Google Workspace, AD, and permissions"},
        ]

        teams_map = {}
        for t_info in teams_data:
            stmt = select(Team).where(Team.name == t_info["name"])
            team = (await db.execute(stmt)).scalar_one_or_none()
            if not team:
                team = Team(name=t_info["name"], description=t_info["description"])
                db.add(team)
                await db.flush()
                await db.refresh(team)
            teams_map[t_info["name"]] = team

        # 2. Create Users
        users_data = [
            {
                "email": "admin@ithelpdesk.com",
                "full_name": "Antigravity Admin",
                "role": UserRole.ADMINISTRATOR,
                "site": "Pune",
                "password": "AdminPassword123!",
                "team": None,
            },
            {
                "email": "manager@ithelpdesk.com",
                "full_name": "Operations Manager",
                "role": UserRole.MANAGER,
                "site": "Pune",
                "password": "ManagerPassword123!",
                "team": None,
            },
            {
                "email": "operator.pune@ithelpdesk.com",
                "full_name": "Rahul Deshmukh",
                "role": UserRole.OPERATOR,
                "site": "Pune",
                "password": "OperatorPassword123!",
                "team": teams_map["Tier 1 Service Desk"],
            },
            {
                "email": "operator.blr@ithelpdesk.com",
                "full_name": "Priya Sharma",
                "role": UserRole.OPERATOR,
                "site": "Bengaluru",
                "password": "OperatorPassword123!",
                "team": teams_map["Network Operations (NOC)"],
            },
            {
                "email": "knowledge.owner@ithelpdesk.com",
                "full_name": "Amit Kulkarni",
                "role": UserRole.KNOWLEDGE_OWNER,
                "site": "Pune",
                "password": "KnowledgePassword123!",
                "team": None,
            },
            {
                "email": "requester@ithelpdesk.com",
                "full_name": "Srushti Engineer",
                "role": UserRole.REQUESTER,
                "site": "Pune",
                "password": "RequesterPassword123!",
                "team": None,
            },
        ]

        users_map = {}
        for u_info in users_data:
            stmt = select(User).where(User.email == u_info["email"])
            user = (await db.execute(stmt)).scalar_one_or_none()
            if not user:
                user = User(
                    email=u_info["email"],
                    password_hash=get_password_hash(u_info["password"]),
                    full_name=u_info["full_name"],
                    role=u_info["role"],
                    site=u_info["site"],
                    is_active=True,
                    email_verified=True,
                    team_id=u_info["team"].id if u_info["team"] else None,
                )
                db.add(user)
                await db.flush()
                await db.refresh(user)
            users_map[u_info["email"]] = user

        now = datetime.now(timezone.utc)

        # 3. Create Sample Cases & SLA Records
        cases_data = [
            {
                "ref": "INC-20260917-0001",
                "type": CaseType.INCIDENT,
                "category": "Network",
                "severity": "Sev 1 - Critical",
                "title": "Production VPN Gateway Unreachable - Remote Engineers Impacted",
                "description": "The primary GlobalProtect VPN portal is timing out with 504 Gateway errors. Over 50 remote developers are unable to access production clusters.",
                "priority": Priority.P1_CRITICAL,
                "status": CaseStatus.ASSIGNED,
                "site": "Pune",
                "assigned_to": users_map["operator.blr@ithelpdesk.com"],
                "assigned_team": teams_map["Network Operations (NOC)"],
                "requester": users_map["requester@ithelpdesk.com"],
                "created_at": now - timedelta(minutes=10),
                "risk_score": 85,
                "risk_level": RiskLevel.HIGH,
            },
            {
                "ref": "INC-20260917-0002",
                "type": CaseType.INCIDENT,
                "category": "Infrastructure",
                "severity": "Sev 2 - Major",
                "title": "PostgreSQL Read Replica Latency Spike in EU Region",
                "description": "Replication lag on pg-replica-02 exceeded 15 minutes. Query timeouts observed on manager reporting dashboard.",
                "priority": Priority.P2_HIGH,
                "status": CaseStatus.ASSIGNED,
                "site": "Bengaluru",
                "assigned_to": users_map["operator.pune@ithelpdesk.com"],
                "assigned_team": teams_map["Infrastructure & Cloud Ops"],
                "requester": users_map["requester@ithelpdesk.com"],
                "created_at": now - timedelta(hours=2),
                "risk_score": 60,
                "risk_level": RiskLevel.MODERATE,
            },
            {
                "ref": "REQ-20260917-0003",
                "type": CaseType.SERVICE_REQUEST,
                "category": "Access & Identity",
                "severity": "Sev 3 - Moderate",
                "title": "Request for AWS Production Console Access (DevOps Team)",
                "description": "Need ReadOnly and CloudWatch Metric access on AWS Production Account for newly onboarded senior SRE.",
                "priority": Priority.P3_MEDIUM,
                "status": CaseStatus.AWAITING_REQUESTER,
                "site": "Pune",
                "assigned_to": users_map["operator.pune@ithelpdesk.com"],
                "assigned_team": teams_map["Identity & Access Management"],
                "requester": users_map["requester@ithelpdesk.com"],
                "created_at": now - timedelta(hours=5),
                "risk_score": 20,
                "risk_level": RiskLevel.LOW,
            },
            {
                "ref": "INC-20260917-0004",
                "type": CaseType.INCIDENT,
                "category": "Hardware",
                "severity": "Sev 4 - Minor",
                "title": "Wireless Keyboard and Mouse Replacement for Pune Desk 402",
                "description": "Ergonomic keyboard spacebar is jammed and optical mouse sensor is erratic.",
                "priority": Priority.P4_LOW,
                "status": CaseStatus.RESOLVED,
                "site": "Pune",
                "assigned_to": users_map["operator.pune@ithelpdesk.com"],
                "assigned_team": teams_map["Tier 1 Service Desk"],
                "requester": users_map["requester@ithelpdesk.com"],
                "created_at": now - timedelta(days=2),
                "resolved_at": now - timedelta(days=1),
                "risk_score": 10,
                "risk_level": RiskLevel.LOW,
            },
            {
                "ref": "INC-20260917-0005",
                "type": CaseType.INCIDENT,
                "category": "Network",
                "severity": "Sev 2 - Major",
                "title": "Core Switch 4B Port Flapping in Bengaluru Datacenter",
                "description": "Uplink interface Eth1/48 showing periodic link renegotiation every 30 seconds.",
                "priority": Priority.P2_HIGH,
                "status": CaseStatus.ASSIGNED,
                "site": "Bengaluru",
                "assigned_to": users_map["operator.blr@ithelpdesk.com"],
                "assigned_team": teams_map["Network Operations (NOC)"],
                "requester": users_map["requester@ithelpdesk.com"],
                "created_at": now - timedelta(hours=10),
                "risk_score": 90,
                "risk_level": RiskLevel.CRITICAL,
                "is_breached": True,
            },
        ]

        for c_data in cases_data:
            stmt = select(Case).where(Case.reference_number == c_data["ref"])
            case = (await db.execute(stmt)).scalar_one_or_none()
            if not case:
                case = Case(
                    reference_number=c_data["ref"],
                    type=c_data["type"],
                    title=c_data["title"],
                    description=c_data["description"],
                    priority=c_data["priority"],
                    status=c_data["status"],
                    site=c_data["site"],
                    requester_id=c_data["requester"].id,
                    owner_id=c_data["assigned_to"].id if c_data.get("assigned_to") else None,
                    team_id=c_data["assigned_team"].id if c_data.get("assigned_team") else None,
                    created_at=c_data["created_at"],
                    resolved_at=c_data.get("resolved_at"),
                    version=1,
                )
                db.add(case)
                await db.flush()
                await db.refresh(case)

                # SLA
                resp_target, res_target = sla_service.calculate_targets(case.priority, case.created_at)
                sla = SLA(
                    case_id=case.id,
                    target_response_at=resp_target,
                    target_resolve_at=res_target,
                    first_responded_at=case.created_at + timedelta(minutes=5) if case.status != CaseStatus.NEW else None,
                    resolved_at=case.resolved_at,
                    response_breached=False,
                    resolve_breached=c_data.get("is_breached", False),
                )
                db.add(sla)

                # AI Triage Result
                triage = AITriageResult(
                    case_id=case.id,
                    suggested_category=c_data["category"],
                    suggested_severity=c_data["severity"],
                    suggested_priority=case.priority.value,
                    confidence_level=ConfidenceLevel.HIGH,
                    confidence_score=0.92,
                    supporting_factors=[
                        "Keywords match critical infrastructure telemetry",
                        "Impact is broad across developer workspace",
                        "Urgency indicated in description",
                    ],
                    missing_info=["Device MAC address or exact error log snippet"],
                    suggested_team=c_data["assigned_team"].name if c_data.get("assigned_team") else None,
                    recommended_next_action="Engage primary on-call engineer and verify gateway logs",
                )
                db.add(triage)

                # Case Risk Assessment
                risk = CaseRiskAssessment(
                    case_id=case.id,
                    risk_level=c_data["risk_level"],
                    signals={
                        "risk_score": c_data["risk_score"],
                        "factors": [
                            "High priority tier SLA elapsed > 50%",
                            "Cross-region developer impact",
                        ],
                    },
                )
                db.add(risk)

                # Messages / Communication Thread
                msg1 = Message(
                    case_id=case.id,
                    author_id=case.requester_id,
                    body=f"Initial request submitted: {case.description}",
                    visibility=MessageVisibility.REQUESTER_VISIBLE,
                    created_at=case.created_at,
                )
                db.add(msg1)

                if case.owner_id:
                    msg2 = Message(
                        case_id=case.id,
                        author_id=case.owner_id,
                        body="[Internal Note] Diagnosing switch interfaces and active routing tables.",
                        visibility=MessageVisibility.INTERNAL_ONLY,
                        created_at=case.created_at + timedelta(minutes=15),
                    )
                    db.add(msg2)

                # If Breached or High Risk, Add Escalation Event
                if c_data.get("is_breached"):
                    esc = EscalationEvent(
                        case_id=case.id,
                        trigger_reason=EscalationReason.MISSED_DEADLINE,
                        escalated_to="team_lead",
                        status=EscalationStatus.OPEN,
                        created_at=case.created_at + timedelta(hours=8),
                    )
                    db.add(esc)

                # Add a sample AI Communication Draft
                draft = CommunicationDraft(
                    case_id=case.id,
                    draft_type=DraftType.PROGRESS_UPDATE,
                    body="Hello team, our NOC engineers are actively routing traffic via our secondary gateway while diagnosing the root issue. We will update you in 30 minutes.",
                    status=DraftStatus.DRAFT,
                    created_at=now - timedelta(minutes=5),
                )
                db.add(draft)

        # 4. Knowledge Base Articles
        articles_data = [
            {
                "title": "How to Configure and Troubleshoot GlobalProtect VPN Client",
                "category": "Network",
                "state": ArticleState.PUBLISHED,
                "body": """### Overview
This SOP guides you through establishing secure connectivity to the corporate intranet.

### Step 1: Client Installation
1. Download the GlobalProtect client from the IT Self-Service Portal.
2. Enter the portal URL: `vpn.corp.company.com`.

### Step 2: Authentication
1. Click **Connect** and authenticate via Okta SSO.
2. Complete Push notification MFA on your registered mobile device.

### Troubleshooting:
- **Error 504 Gateway Timeout**: Switch to the fallback gateway `vpn-backup.corp.company.com`.
- **IP Address Conflict**: Flush local DNS cache via `ipconfig /flushdns` or `sudo dscacheutil -flushcache`.""",
            },
            {
                "title": "Standard Operating Procedure for Production Incident Escalation",
                "category": "Infrastructure",
                "state": ArticleState.PUBLISHED,
                "body": """### Severity 1 & 2 Incident Protocol
1. **Initial Assessment (T+0 to T+5m)**: Verify service telemetry and confirm user impact.
2. **War Room Creation**: Post incident link in `#incident-war-room` Slack channel.
3. **Manager Notification**: Trigger Tier 2 Manager Escalation if unresolved after 30 minutes.
4. **Post-Mortem**: Required within 48 hours for all P1/P2 incidents.""",
            },
            {
                "title": "Password Reset and Multi-Factor Authentication (MFA) Setup Guide",
                "category": "Access & Identity",
                "state": ArticleState.PUBLISHED,
                "body": """### Self-Service Password Reset
1. Visit `https://id.company.com/reset`.
2. Enter your corporate email and verify SMS OTP.
3. Choose a strong password (minimum 12 characters, uppercase, lowercase, numbers, symbols).

### MFA Setup:
- Use Google Authenticator or Okta Verify.
- Save backup codes securely in an encrypted password manager.""",
            },
        ]

        for a_data in articles_data:
            stmt = select(KnowledgeArticle).where(KnowledgeArticle.title == a_data["title"])
            article = (await db.execute(stmt)).scalar_one_or_none()
            if not article:
                article = KnowledgeArticle(
                    title=a_data["title"],
                    category=a_data["category"],
                    body=a_data["body"],
                    state=a_data["state"],
                    author_id=users_map["knowledge.owner@ithelpdesk.com"].id,
                )
                db.add(article)

        await db.commit()

    print("SUCCESS: IT Helpdesk Demo Data Successfully Seeded!")
    print("\n--- Demo Login Credentials ---")
    print("Admin:            admin@ithelpdesk.com          / AdminPassword123!")
    print("Manager:          manager@ithelpdesk.com        / ManagerPassword123!")
    print("Operator (Pune):  operator.pune@ithelpdesk.com  / OperatorPassword123!")
    print("Operator (BLR):   operator.blr@ithelpdesk.com   / OperatorPassword123!")
    print("Knowledge Owner:  knowledge.owner@ithelpdesk.com / KnowledgePassword123!")
    print("Requester:        requester@ithelpdesk.com      / RequesterPassword123!")
    print("------------------------------\n")


if __name__ == "__main__":
    asyncio.run(seed_database())
