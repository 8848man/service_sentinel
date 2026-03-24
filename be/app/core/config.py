from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import model_validator
from typing import Optional
import json

_PLACEHOLDER_SECRET_KEY = "change-this-in-production-use-openssl-rand-hex-32"

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "ServiceSentinel"
    APP_VERSION: str = "1.1.0"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "sqlite:///./servicesentinel.db"

    # AI Configuration
    AI_ENABLED: bool = False
    AI_API_KEY: Optional[str] = None
    AI_MODEL: str = "gemini-pro"
    AI_MAX_TOKENS: int = 2000
    AI_TEMPERATURE: float = 0.3

    # Monitoring Configuration
    DEFAULT_CHECK_INTERVAL_SECONDS: int = 60
    DEFAULT_TIMEOUT_SECONDS: int = 10
    DEFAULT_FAILURE_THRESHOLD: int = 3
    CONCURRENT_CHECKS_LIMIT: int = 50

    # Scheduler Configuration
    SCHEDULER_ENABLED: bool = True
    MONITORING_INTERVAL_SECONDS: int = 30

    # Security
    SECRET_KEY: Optional[str] = None
    ENCRYPTION_KEY: Optional[str] = None  # For encrypting sensitive headers

    @model_validator(mode='after')
    def validate_secret_key(self) -> 'Settings':
        if not self.SECRET_KEY or self.SECRET_KEY == _PLACEHOLDER_SECRET_KEY:
            raise ValueError(
                "SECRET_KEY must be set to a secure random value via the SECRET_KEY environment variable. "
                "Generate one with: openssl rand -hex 32"
            )
        return self

    # CORS
    CORS_ORIGINS: str = ""

    @property
    def cors_origins_list(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.CORS_ORIGINS.split(",")
            if origin.strip()
        ]
    # GCP
    GOOGLE_APPLICATION_CREDENTIALS: str | None = None  # ← 이렇게 수정

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()