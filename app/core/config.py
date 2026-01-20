from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    # Application
    APP_NAME: str = "ServiceSentinel"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "sqlite:///./servicesentinel.db"

    # AI Configuration
    AI_ENABLED: bool = False
    AI_API_KEY: Optional[str] = None
    AI_MODEL: str = "gpt-4-turbo"
    AI_API_URL: str = "https://api.openai.com/v1/chat/completions"
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
    SECRET_KEY: str = "change-this-in-production-use-openssl-rand-hex-32"
    ENCRYPTION_KEY: Optional[str] = None  # For encrypting sensitive headers

    # CORS
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8080"]

    # firebase
    GOOGLE_APPLICATION_CREDENTIALS: str | None

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()