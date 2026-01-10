from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func, desc

from app.models.ai_analysis import AIAnalysis


class AIAnalysisRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, data: dict) -> AIAnalysis:
        analysis = AIAnalysis(**data)
        self.db.add(analysis)
        self.db.commit()
        self.db.refresh(analysis)
        return analysis

    def find_by_id(self, analysis_id: int) -> Optional[AIAnalysis]:
        return self.db.query(AIAnalysis).filter(AIAnalysis.id == analysis_id).first()

    def find_by_incident_id(self, incident_id: int) -> Optional[AIAnalysis]:
        return self.db.query(AIAnalysis).filter(AIAnalysis.incident_id == incident_id).first()

    def find_all(self, skip: int = 0, limit: int = 100) -> list[AIAnalysis]:
        return (
            self.db.query(AIAnalysis)
            .order_by(desc(AIAnalysis.analyzed_at))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_summary_stats(self) -> dict:
        """Get summary statistics for all AI analyses"""
        total = self.db.query(AIAnalysis).count()

        if total == 0:
            return {
                "total_analyses": 0,
                "total_cost_usd": 0.0,
                "avg_analysis_time_ms": 0.0,
                "models_used": {}
            }

        total_cost = self.db.query(func.sum(AIAnalysis.total_cost_usd)).scalar() or 0.0
        avg_time = self.db.query(func.avg(AIAnalysis.analysis_duration_ms)).scalar() or 0.0

        # Get model usage counts
        models = self.db.query(
            AIAnalysis.model_used,
            func.count(AIAnalysis.id)
        ).group_by(AIAnalysis.model_used).all()

        models_dict = {model: count for model, count in models}

        return {
            "total_analyses": total,
            "total_cost_usd": round(total_cost, 2),
            "avg_analysis_time_ms": round(avg_time, 2),
            "models_used": models_dict
        }
