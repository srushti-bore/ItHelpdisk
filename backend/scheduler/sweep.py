import logging
from datetime import datetime, timezone
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from backend.core.config import settings
from backend.db.session import AsyncSessionLocal
from backend.models.ai_artifacts import CaseRiskAssessment
from backend.models.case import Case
from backend.models.enums import CaseStatus, EscalationReason, RiskLevel
from backend.services.escalation_service import escalation_service
from backend.services.risk_service import risk_service

logger = logging.getLogger("it_helpdesk.scheduler.sweep")

scheduler = AsyncIOScheduler()


async def run_sweep_job():
    """
    The Sweep — Periodic SLA, Risk & Escalation Job per SRS v3.3 §3.5, §5.7, §5.8.
    Runs in-process on APScheduler on fixed interval (default: 5 min).
    """
    logger.info("Starting periodic SLA & Risk Assessment Sweep...")
    now = datetime.now(timezone.utc)

    async with AsyncSessionLocal() as db:
        try:
            # 1. Fetch all open/active cases
            open_statuses = [
                CaseStatus.NEW,
                CaseStatus.IN_ASSESSMENT,
                CaseStatus.ASSIGNED,
                CaseStatus.AWAITING_REQUESTER,
                CaseStatus.AWAITING_APPROVAL,
                CaseStatus.PENDING,
            ]
            stmt = (
                select(Case)
                .where(Case.status.in_(open_statuses), Case.deleted_at.is_(None))
                .options(
                    selectinload(Case.sla),
                    selectinload(Case.triage_result),
                    selectinload(Case.risk_assessment),
                )
            )
            cases = list((await db.execute(stmt)).scalars().all())
            logger.info(f"The Sweep: evaluating {len(cases)} active cases.")

            breaches_detected = 0
            escalations_raised = 0

            for case in cases:
                # A. Evaluate SLA Breaches per SRS §4.3
                if case.sla:
                    # Check Response SLA
                    if not case.sla.first_responded_at and now > case.sla.target_response_at:
                        if not case.sla.response_breached:
                            case.sla.response_breached = True
                            breaches_detected += 1

                    # Check Resolution SLA
                    if not case.sla.resolved_at and now > case.sla.target_resolve_at:
                        if not case.sla.resolve_breached:
                            case.sla.resolve_breached = True
                            breaches_detected += 1

                # B. Compute Operational Risk Score per SRS §5.7
                risk_level, signals = risk_service.evaluate_case_risk(case)
                if case.risk_assessment:
                    case.risk_assessment.risk_level = risk_level
                    case.risk_assessment.signals = signals
                    case.risk_assessment.computed_at = now
                else:
                    assessment = CaseRiskAssessment(
                        case_id=case.id,
                        risk_level=risk_level,
                        signals=signals,
                        computed_at=now,
                    )
                    db.add(assessment)

                # C. Trigger Automatic Escalation per SRS §5.8
                escalation_reason = None
                if signals.get("sla_breached"):
                    escalation_reason = EscalationReason.MISSED_DEADLINE
                elif signals.get("sla_approaching"):
                    escalation_reason = EscalationReason.APPROACHING_DEADLINE
                elif risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
                    escalation_reason = EscalationReason.HIGH_RISK

                if escalation_reason:
                    event = await escalation_service.trigger_escalation(
                        db=db,
                        case=case,
                        reason=escalation_reason,
                        escalated_by=None,  # System-triggered
                        target_role="team_lead",
                    )
                    if event:
                        escalations_raised += 1

            await db.commit()
            logger.info(
                f"The Sweep completed successfully. Evaluated: {len(cases)} | Breaches: {breaches_detected} | Escalations: {escalations_raised}"
            )

        except Exception as e:
            await db.rollback()
            logger.error(f"The Sweep encountered an unhandled error: {str(e)}", exc_info=True)


def start_scheduler():
    """Initializes and starts the in-process APScheduler."""
    if not scheduler.running:
        scheduler.add_job(
            run_sweep_job,
            "interval",
            minutes=settings.SWEEP_INTERVAL_MINUTES,
            id="sla_risk_escalation_sweep",
            replace_existing=True,
        )
        scheduler.start()
        logger.info(f"APScheduler active with sweep interval: {settings.SWEEP_INTERVAL_MINUTES} minutes.")


def shutdown_scheduler():
    """Graceful scheduler shutdown on application exit."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        logger.info("APScheduler shutdown complete.")
