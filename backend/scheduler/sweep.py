import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from backend.core.config import settings

logger = logging.getLogger("it_helpdesk.scheduler")

scheduler = AsyncIOScheduler()


async def run_sweep_job():
    """
    Periodic background sweep job ('The Sweep') per SRS §3.5, §5.7, §5.8.
    Evaluates:
    - SLA deadline proximity and breaches
    - Case risk scoring (inactivity, follow-ups, reassignments)
    - Automatic escalation events
    """
    logger.info("Executing periodic SLA, Risk & Escalation Sweep...")
    try:
        # Business logic for sweep will be invoked here via service layer
        pass
    except Exception as e:
        logger.error(f"Error during scheduled sweep: {str(e)}", exc_info=True)


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
        logger.info(f"APScheduler started with sweep interval: {settings.SWEEP_INTERVAL_MINUTES} minutes.")


def shutdown_scheduler():
    """Shuts down the scheduler gracefully on app teardown."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        logger.info("APScheduler stopped.")
