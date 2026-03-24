import json
import time
import logging
from typing import Optional
from datetime import datetime

import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold

import httpx
from sqlalchemy.orm import Session

from app.models.incident import Incident
from app.models.ai_analysis import AIAnalysis
from app.repositories.ai_analysis_repository import AIAnalysisRepository
from app.core.config import settings

logger = logging.getLogger(__name__)


# class AIAnalysisService:
#     def __init__(self, db: Session):
#         self.db = db
#         self.analysis_repo = AIAnalysisRepository(db)
#
#     async def analyze_incident(
#         self,
#         incident: Incident,
#         force_reanalyze: bool = False
#     ) -> Optional[AIAnalysis]:
#         """Request AI analysis for an incident"""
#
#         # Check if AI is enabled
#         if not settings.AI_ENABLED or not settings.AI_API_KEY:
#             logger.warning("AI analysis requested but AI is not enabled or API key not set")
#             return None
#
#         # Check if already analyzed
#         if incident.ai_analysis_completed and not force_reanalyze:
#             return self.analysis_repo.find_by_incident_id(incident.id)
#
#         start_time = time.time()
#
#         try:
#             # Build context for AI
#             context = self._build_analysis_context(incident)
#
#             # Call AI API
#             response_data = await self._call_ai_api(context)
#
#             # Parse and structure response
#             analysis_data = self._parse_ai_response(response_data)
#
#             # Calculate duration and cost
#             duration_ms = int((time.time() - start_time) * 1000)
#             cost = self._calculate_cost(response_data)
#
#             # Save analysis
#             analysis_dict = {
#                 "incident_id": incident.id,
#                 "model_used": settings.AI_MODEL,
#                 "prompt_tokens": response_data.get("usage", {}).get("prompt_tokens"),
#                 "completion_tokens": response_data.get("usage", {}).get("completion_tokens"),
#                 "total_cost_usd": cost,
#                 "root_cause_hypothesis": analysis_data["root_cause"],
#                 "confidence_score": analysis_data.get("confidence", 0.75),
#                 "debug_checklist": analysis_data["debug_checklist"],
#                 "suggested_actions": analysis_data["suggested_actions"],
#                 "related_error_patterns": analysis_data.get("related_patterns"),
#                 "raw_response": json.dumps(response_data),
#                 "analysis_duration_ms": duration_ms
#             }
#
#             analysis = self.analysis_repo.create(analysis_dict)
#
#             # Update incident
#             incident.ai_analysis_completed = True
#             incident.ai_analysis_requested = True
#             self.db.commit()
#
#             logger.info(f"AI analysis completed for incident {incident.id}. Cost: ${cost:.4f}")
#
#             return analysis
#
#         except Exception as e:
#             logger.exception(f"Failed to analyze incident {incident.id}")
#             incident.ai_analysis_requested = True
#             self.db.commit()
#             return None
#
#     def _build_analysis_context(self, incident: Incident) -> str:
#         """Build rich context for AI analysis"""
#         service = incident.service
#         trigger = incident.trigger_check
#
#         context = f"""Analyze this service failure incident:
#
# **Service Information:**
# - Name: {service.name}
# - Type: {service.service_type.value}
# - Endpoint: {service.endpoint_url}
# - Method: {service.http_method.value}
# - Expected Status Codes: {service.expected_status_codes}
# - Timeout: {service.timeout_seconds}s
#
# **Failure Details:**
# - Status Code: {trigger.status_code if trigger.status_code else 'None (no response)'}
# - Error Type: {trigger.error_type}
# - Error Message: {trigger.error_message}
# - Latency: {trigger.latency_ms}ms
# - Response Body: {trigger.response_body[:500] if trigger.response_body else 'N/A'}
#
# **Incident Context:**
# - Severity: {incident.severity.value}
# - Consecutive Failures: {incident.consecutive_failures}
# - First Detected: {incident.detected_at}
#
# **Request Configuration:**
# - Headers: {json.dumps(service.headers or {})}
# - Request Body: {json.dumps(service.request_body or {})}
#
# Provide a detailed failure analysis with:
# 1. Most likely root cause(s)
# 2. Step-by-step debug checklist
# 3. Prioritized suggested actions
# 4. Related error patterns to watch for"""
#
#         return context
#
#     async def _call_ai_api(self, context: str) -> dict:
#         """Call AI API (OpenAI-compatible)"""
#
#         system_prompt = """You are an expert DevOps and SRE engineer specializing in incident analysis.
# Analyze service failures and provide actionable debugging insights.
# Always structure your response as JSON with these fields:
# {
#   "root_cause": "detailed explanation",
#   "confidence": 0.0-1.0,
#   "debug_checklist": ["step 1", "step 2", ...],
#   "suggested_actions": [
#     {"action": "...", "priority": "high|medium|low", "estimated_impact": "..."}
#   ],
#   "related_patterns": ["pattern 1", "pattern 2", ...]
# }"""
#
#         payload = {
#             "model": settings.AI_MODEL,
#             "messages": [
#                 {"role": "system", "content": system_prompt},
#                 {"role": "user", "content": context}
#             ],
#             "temperature": settings.AI_TEMPERATURE,
#             "max_tokens": settings.AI_MAX_TOKENS,
#             "response_format": {"type": "json_object"}
#         }
#
#         async with httpx.AsyncClient() as client:
#             response = await client.post(
#                 settings.AI_API_URL,
#                 json=payload,
#                 headers={
#                     "Authorization": f"Bearer {settings.AI_API_KEY}",
#                     "Content-Type": "application/json"
#                 },
#                 timeout=30.0
#             )
#             response.raise_for_status()
#             return response.json()
#
#     def _parse_ai_response(self, response_data: dict) -> dict:
#         """Parse and validate AI response"""
#         content = response_data["choices"][0]["message"]["content"]
#         return json.loads(content)
#
#     def _calculate_cost(self, response_data: dict) -> float:
#         """Calculate API call cost in USD"""
#         usage = response_data.get("usage", {})
#         prompt_tokens = usage.get("prompt_tokens", 0)
#         completion_tokens = usage.get("completion_tokens", 0)
#
#         # Example pricing (adjust based on actual model)
#         # GPT-4 Turbo: $0.01/1K prompt, $0.03/1K completion
#         prompt_cost = (prompt_tokens / 1000) * 0.01
#         completion_cost = (completion_tokens / 1000) * 0.03
#
#         return round(prompt_cost + completion_cost, 6)
class AIAnalysisService:
    def __init__(self, db: Session):
        self.db = db
        self.analysis_repo = AIAnalysisRepository(db)

        if not settings.AI_API_KEY or not settings.AI_ENABLED:
            logger.warning("Gemini AI is disabled or API key missing")
            self.model = None
            return

        genai.configure(api_key=settings.AI_API_KEY)

        self.model = genai.GenerativeModel(
            model_name=settings.AI_MODEL,
            safety_settings={
                HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
                HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            },
        )

    async def analyze_incident(
        self,
        incident: Incident,
        force_reanalyze: bool = False
    ) -> Optional[AIAnalysis]:

        if not self.model:
            return None

        if incident.ai_analysis_completed and not force_reanalyze:
            return self.analysis_repo.find_by_incident_id(incident.id)

        if force_reanalyze:
            existing = self.analysis_repo.find_by_incident_id(incident.id)
            if existing:
                try:
                    self.analysis_repo.delete(existing)
                except Exception:
                    logger.exception(
                        "Failed to delete existing analysis for incident %s before re-analysis",
                        incident.id,
                    )
                    raise RuntimeError(
                        f"Could not replace existing analysis for incident {incident.id}"
                    )

        start_time = time.time()

        try:
            prompt = self._build_analysis_prompt(incident)

            response = await self._call_gemini(prompt)

            analysis_data = self._parse_gemini_response(response)

            duration_ms = int((time.time() - start_time) * 1000)

            analysis_dict = {
                "incident_id": incident.id,
                "model_used": settings.AI_MODEL,
                "prompt_tokens": None,          # Gemini SDK 미제공
                "completion_tokens": None,      # Gemini SDK 미제공
                "total_cost_usd": None,         # 추후 추정 가능
                "root_cause_hypothesis": analysis_data["root_cause"],
                "confidence_score": analysis_data.get("confidence", 0.75),
                "debug_checklist": analysis_data["debug_checklist"],
                "suggested_actions": analysis_data["suggested_actions"],
                "related_error_patterns": analysis_data.get("related_patterns"),
                "raw_response": response.text,
                "analysis_duration_ms": duration_ms,
            }

            analysis = self.analysis_repo.create(analysis_dict)

            incident.ai_analysis_completed = True
            incident.ai_analysis_requested = True
            self.db.commit()

            return analysis

        except Exception:
            logger.exception("Gemini analysis failed")
            incident.ai_analysis_requested = True
            self.db.commit()
            return None

    def _build_analysis_prompt(self, incident: Incident) -> str:
        service = incident.service
        trigger = incident.trigger_check

        return f"""
    You are a senior DevOps & SRE engineer.
    
    Analyze the following service failure incident and respond ONLY in valid JSON.
    Do not include explanations outside JSON.
    
    JSON schema:
    {{
      "root_cause": "string",
      "confidence": number,
      "debug_checklist": ["string"],
      "suggested_actions": [
        {{
          "action": "string",
          "priority": "high|medium|low",
          "estimated_impact": "string"
        }}
      ],
      "related_patterns": ["string"]
    }}
    
    Incident data:
    - Service name: {service.name}
    - Service type: {service.service_type.value}
    - Endpoint: {service.endpoint_url}
    - HTTP method: {service.http_method.value}
    - Expected status codes: {service.expected_status_codes}
    - Timeout: {service.timeout_seconds}s
    
    Failure:
    - Status code: {trigger.status_code if trigger is not None else "No triggering health check available"}
    - Error type: {trigger.error_type if trigger is not None else "N/A"}
    - Error message: {trigger.error_message if trigger is not None else "N/A"}
    - Latency: {str(trigger.latency_ms) + "ms" if trigger is not None else "N/A"}
    - Response body: {trigger.response_body[:500] if trigger is not None and trigger.response_body else "N/A"}
    
    Context:
    - Severity: {incident.severity.value}
    - Consecutive failures: {incident.consecutive_failures}
    """

    async def _call_gemini(self, prompt: str):
        import asyncio
        loop = asyncio.get_running_loop()

        return await loop.run_in_executor(
            None,
            lambda: self.model.generate_content(prompt)
        )

    # def _parse_gemini_response(self, response) -> dict:
    #     text = response.text.strip()
    #
    #     logger.error("RAW GEMINI RESPONSE:\n%s", text)
    #
    #     # ```json ... ``` 제거
    #     if text.startswith("```"):
    #         text = text.split("```")[1]
    #
    #     try:
    #         return json.loads(text)
    #     except json.JSONDecodeError:
    #         logger.error("Failed to parse Gemini JSON response")
    #         raise

    def _parse_gemini_response(self, response) -> dict:
        """
        Gemini SDK response 객체를 받아
        마크다운 / 설명 문구를 제거하고 JSON만 안전하게 파싱한다.
        """

        if not response or not getattr(response, "text", None):
            raise ValueError("Empty Gemini response")

        raw_text = response.text.strip()

        logger.debug("RAW GEMINI RESPONSE:\n%s", raw_text)

        try:
            # 1. 코드블록 제거 (```json, ```)
            cleaned = raw_text
            cleaned = cleaned.replace("```json", "")
            cleaned = cleaned.replace("```", "")
            logger.debug("RAW GEMINI RESPONSE:\n%s", cleaned)

            # 2. JSON 시작/끝 탐색 (object 기준)
            start = cleaned.find("{")
            end = cleaned.rfind("}")

            if start == -1 or end == -1 or end <= start:
                raise ValueError("No JSON object found in Gemini response")

            json_str = cleaned[start:end + 1]

            # 3. JSON 파싱
            return json.loads(json_str)

        except Exception:
            logger.exception("Failed to parse Gemini JSON response")
            raise