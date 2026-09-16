import pytest
from backend.models.enums import ArticleState, UserRole
from backend.models.knowledge import KnowledgeArticle
from backend.schemas.ai import OperationalMetrics


def test_operational_metrics_model():
    """Verify operational insights data structure complies with SRS §5.12."""
    metrics = OperationalMetrics(
        total_cases=25,
        open_cases=8,
        resolved_cases=17,
        sla_compliance_rate=92.5,
        average_resolution_hours=3.8,
        cases_by_category={"Network": 10, "Software": 8, "Hardware": 7},
        cases_by_priority={"P1": 2, "P2": 5, "P3": 12, "P4": 6},
        cases_by_site={"Pune": 15, "Bengaluru": 10},
        risk_breakdown={"low": 18, "medium": 5, "high": 2, "critical": 0},
    )

    assert metrics.total_cases == 25
    assert metrics.open_cases == 8
    assert metrics.sla_compliance_rate == 92.5
    assert "Network" in metrics.cases_by_category
    assert metrics.risk_breakdown["high"] == 2


def test_knowledge_article_states():
    """Verify knowledge article states and default values."""
    assert ArticleState.DRAFT.value == "draft"
    assert ArticleState.PUBLISHED.value == "published"
    assert ArticleState.ARCHIVED.value == "archived"
