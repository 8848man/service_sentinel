FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 (최소화)
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 의존성 먼저 복사 (캐시 활용)
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# 앱 코드 복사
COPY app ./app

# Cloud Run은 PORT 환경변수 사용
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]