from fastapi import APIRouter
from backend.api.health import router as health_router
from backend.api.v1.auth.routes import router as auth_router

api_v1_router = APIRouter()

# Register core endpoints
api_v1_router.include_router(health_router)
api_v1_router.include_router(auth_router, prefix="/auth", tags=["Auth"])

# Feature routers will be mounted here as they are implemented:
# api_v1_router.include_router(cases_router, prefix="/cases", tags=["Cases"])
# api_v1_router.include_router(messages_router, prefix="/messages", tags=["Messages"])
# api_v1_router.include_router(attachments_router, prefix="/attachments", tags=["Attachments"])
# api_v1_router.include_router(knowledge_router, prefix="/knowledge", tags=["Knowledge"])
# api_v1_router.include_router(sla_router, prefix="/sla", tags=["SLA"])
# api_v1_router.include_router(ai_router, prefix="/ai", tags=["AI"])
# api_v1_router.include_router(notifications_router, prefix="/notifications", tags=["Notifications"])
# api_v1_router.include_router(admin_router, prefix="/admin", tags=["Admin"])
# api_v1_router.include_router(reports_router, prefix="/reports", tags=["Reports"])
