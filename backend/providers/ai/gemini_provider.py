import json
import logging
from typing import Any, Dict, List, Optional
from backend.core.config import settings
from backend.core.exceptions import AIProviderUnavailableError
from backend.providers.ai.base import AIProvider, DraftOutput, TriageOutput

logger = logging.getLogger("it_helpdesk.ai.gemini")


class GeminiProvider(AIProvider):
    """
    Google Gemini AI Provider per SRS v3.3 §3.1, §5.
    Executes synchronous, inline per-request AI operations with structured output.
    """

    def __init__(self, api_key: str, model_name: str):
        self.api_key = api_key
        self.model_name = model_name

    async def analyze_case(self, title: str, description: str, metadata: Optional[Dict[str, Any]] = None) -> TriageOutput:
        """
        AI Case Analysis (SRS §5.2, Level 1).
        Suggests category, severity, priority, missing info, supporting factors.
        """
        if not self.api_key:
            return MockAIProvider().analyze_case_sync(title, description)

        prompt = f"""
        You are an expert IT Helpdesk Triage AI Assistant.
        Analyze the following IT support request:
        Title: {title}
        Description: {description}
        Metadata: {json.dumps(metadata or {})}

        Respond strictly in JSON matching this schema:
        {{
            "suggested_category": "Hardware | Software | Network | Access | Email | Security | Other",
            "suggested_severity": "Low | Medium | High | Critical",
            "suggested_priority": "P1 | P2 | P3 | P4",
            "confidence_level": "Low | Moderate | High",
            "confidence_score": 0.85,
            "supporting_factors": ["string reason 1", "string reason 2"],
            "missing_info": ["question 1", "question 2"],
            "suggested_team": "Network Team | IT Support | Security Team",
            "recommended_next_action": "Recommended immediate action"
        }}
        """
        try:
            from google import genai
            client = genai.Client(api_key=self.api_key)
            response = client.models.generate_content(
                model=self.model_name,
                contents=prompt,
                config={"response_mime_type": "application/json"},
            )
            data = json.loads(response.text)
            return TriageOutput(**data)
        except Exception as e:
            logger.error(f"Gemini Case Analysis failed: {str(e)}", exc_info=True)
            # Fallback to mock / graceful degradation per SRS §9
            return MockAIProvider().analyze_case_sync(title, description)

    async def summarize_case(self, case_history: List[Dict[str, Any]], new_message: str) -> str:
        """
        Continuous Case Summarization (SRS §5.3, Level 0).
        """
        if not self.api_key:
            return f"Summary: Case contains {len(case_history)} prior updates. Latest update: {new_message[:100]}..."

        prompt = f"""
        Summarize the current state of this IT Helpdesk case concisely.
        Case History: {json.dumps(case_history)}
        Latest Message: {new_message}
        Provide a 2-3 sentence executive summary of: what was reported, what has been done, and what is currently pending.
        """
        try:
            from google import genai
            client = genai.Client(api_key=self.api_key)
            response = client.models.generate_content(
                model=self.model_name,
                contents=prompt,
            )
            return response.text.strip()
        except Exception as e:
            logger.error(f"Gemini Case Summarization failed: {str(e)}", exc_info=True)
            return "Summary currently unavailable due to transient AI provider downtime."

    async def generate_draft(self, draft_type: str, context: Dict[str, Any]) -> DraftOutput:
        """
        AI Communication Drafting (SRS §5.9, Level 1).
        """
        if not self.api_key:
            return DraftOutput(
                draft_type=draft_type,
                body=f"Hello,\n\nRegarding your ticket: {context.get('title', '')}. Could you please provide more details?",
            )

        prompt = f"""
        Draft a polite, professional IT support message of type '{draft_type}' to the requester.
        Context: {json.dumps(context)}
        Do not auto-commit or make promises outside policy.
        """
        try:
            from google import genai
            client = genai.Client(api_key=self.api_key)
            response = client.models.generate_content(
                model=self.model_name,
                contents=prompt,
            )
            return DraftOutput(draft_type=draft_type, body=response.text.strip())
        except Exception as e:
            logger.error(f"Gemini Draft Generation failed: {str(e)}", exc_info=True)
            raise AIProviderUnavailableError()

    async def narrate_operational_insights(self, aggregate_data: Dict[str, Any]) -> str:
        """
        AI Operational Insights narration (SRS §5.12, Level 0).
        """
        if not self.api_key:
            return "Operational Insight: Ticket volumes are stable across departments."

        prompt = f"""
        Narrate a plain-language operational summary for IT Managers based on these aggregated metrics:
        {json.dumps(aggregate_data)}
        Highlight: top categories, SLA compliance trends, risk hotspots, and improvement areas.
        """
        try:
            from google import genai
            client = genai.Client(api_key=self.api_key)
            response = client.models.generate_content(
                model=self.model_name,
                contents=prompt,
            )
            return response.text.strip()
        except Exception as e:
            logger.error(f"Gemini Operational Insights failed: {str(e)}", exc_info=True)
            return "Operational trends summary is temporarily unavailable."


class MockAIProvider(AIProvider):
    """Deterministic Mock AI provider for local testing and offline runs."""

    def analyze_case_sync(self, title: str, description: str) -> TriageOutput:
        text = f"{title} {description}".lower()
        if "vpn" in text or "network" in text or "wifi" in text:
            category = "Network"
            priority = "P2"
            team = "Network Operations"
        elif "password" in text or "login" in text or "access" in text:
            category = "Access"
            priority = "P3"
            team = "Identity & Access"
        elif "laptop" in text or "monitor" in text or "keyboard" in text or "hardware" in text:
            category = "Hardware"
            priority = "P3"
            team = "Workplace IT"
        else:
            category = "Software"
            priority = "P3"
            team = "IT Service Desk"

        return TriageOutput(
            suggested_category=category,
            suggested_severity="Medium",
            suggested_priority=priority,
            confidence_level="Moderate",
            confidence_score=0.75,
            supporting_factors=["Pattern match on keywords in title and description"],
            missing_info=["Device serial number or IP address if applicable"],
            suggested_team=team,
            recommended_next_action=f"Assign to {team} and verify details.",
        )

    async def analyze_case(self, title: str, description: str, metadata: Optional[Dict[str, Any]] = None) -> TriageOutput:
        return self.analyze_case_sync(title, description)

    async def summarize_case(self, case_history: List[Dict[str, Any]], new_message: str) -> str:
        return f"Deterministic Summary: {len(case_history)} events recorded. Latest update: {new_message[:80]}..."

    async def generate_draft(self, draft_type: str, context: Dict[str, Any]) -> DraftOutput:
        return DraftOutput(
            draft_type=draft_type,
            body="Hello,\n\nWe have reviewed your request. Could you please confirm if this issue is still persisting?",
        )

    async def narrate_operational_insights(self, aggregate_data: Dict[str, Any]) -> str:
        return "Operational insight: Stable volume across categories with healthy SLA response times."


def get_ai_provider() -> AIProvider:
    """Factory returning configured AI Provider."""
    if settings.GEMINI_API_KEY:
        return GeminiProvider(api_key=settings.GEMINI_API_KEY, model_name=settings.GEMINI_MODEL)
    return MockAIProvider()
