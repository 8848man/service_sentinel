# ServiceSentinel Backend

AI-powered service monitoring with intelligent failure analysis. ServiceSentinel continuously monitors APIs, external services, and cloud infrastructure, and when failures occur, it analyzes the failure context using AI to provide probable root causes, developer-friendly explanations, and suggested next actions.

## Features

- **Service & API Registration** - Monitor HTTP/HTTPS endpoints with custom headers, methods, and configurations
- **Periodic Monitoring** - Automated health checks on configurable intervals
- **Incident Detection** - Intelligent failure threshold detection with severity classification
- **AI Failure Analysis** - Powered by OpenAI GPT-4 or similar models to analyze failures and suggest solutions
- **Monitoring Dashboard** - Multi-service overview with health status, incidents, and historical logs
- **RESTful API** - Comprehensive API for managing services, incidents, and analytics

## Architecture

```
├── app/
│   ├── api/                    # API endpoints
│   │   ├── services.py        # Service management routes
│   │   ├── incidents.py       # Incident management routes
│   │   └── dashboard.py       # Dashboard & metrics routes
│   ├── core/                  # Core configuration
│   │   ├── config.py          # Settings & environment variables
│   │   └── database.py        # Database connection
│   ├── models/                # SQLAlchemy models
│   │   ├── service.py         # Service model
│   │   ├── health_check.py    # Health check model
│   │   ├── incident.py        # Incident model
│   │   └── ai_analysis.py     # AI analysis model
│   ├── repositories/          # Data access layer
│   ├── schemas/               # Pydantic schemas
│   ├── services/              # Business logic
│   │   ├── incident_service.py      # Incident detection logic
│   │   ├── ai_analysis_service.py   # AI integration
│   │   └── monitoring_worker.py     # Health check worker
│   ├── scheduler.py           # Background task scheduler
│   └── main.py                # FastAPI application
├── requirements.txt           # Python dependencies
├── .env.example              # Environment variables template
└── README.md                 # This file
```

## Tech Stack

- **FastAPI** - Modern, fast web framework
- **SQLAlchemy** - SQL toolkit and ORM
- **PostgreSQL** - Production database (SQLite for development)
- **APScheduler** - Background task scheduling
- **httpx** - Async HTTP client for health checks
- **Pydantic** - Data validation
- **OpenAI/Anthropic** - AI analysis integration

## Getting Started

### Prerequisites

- Python 3.10+
- pip
- (Optional) PostgreSQL for production

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd service_sentinel_be
```

2. Create and activate virtual environment:
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Copy environment template and configure:
```bash
copy .env.example .env
```

Edit `.env` with your settings:
```env
DATABASE_URL=sqlite:///./servicesentinel.db
AI_ENABLED=True
AI_API_KEY=your-openai-api-key
SCHEDULER_ENABLED=True
MONITORING_INTERVAL_SECONDS=30
```

5. Run the application:
```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### API Documentation

Interactive API documentation is available at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### Services

- `POST /api/v1/services` - Create new service
- `GET /api/v1/services` - List all services
- `GET /api/v1/services/{id}` - Get service details
- `PATCH /api/v1/services/{id}` - Update service
- `DELETE /api/v1/services/{id}` - Delete service
- `POST /api/v1/services/{id}/activate` - Activate monitoring
- `POST /api/v1/services/{id}/deactivate` - Pause monitoring
- `POST /api/v1/services/{id}/check-now` - Trigger immediate health check
- `GET /api/v1/services/{id}/health-checks` - Get health check history
- `GET /api/v1/services/{id}/stats` - Get uptime statistics
- `GET /api/v1/services/{id}/incidents` - Get service incidents

### Incidents

- `GET /api/v1/incidents` - List all incidents
- `GET /api/v1/incidents/{id}` - Get incident details
- `PATCH /api/v1/incidents/{id}` - Update incident
- `POST /api/v1/incidents/{id}/acknowledge` - Acknowledge incident
- `POST /api/v1/incidents/{id}/resolve` - Resolve incident
- `GET /api/v1/incidents/{id}/analysis` - Get AI analysis
- `POST /api/v1/incidents/{id}/analysis` - Request AI analysis

### Dashboard

- `GET /api/v1/dashboard/overview` - Multi-service health overview
- `GET /api/v1/dashboard/metrics` - System-wide metrics

### Health

- `GET /health` - Basic health check
- `GET /health/db` - Database connectivity check

## Usage Examples

### Register a Service

```bash
curl -X POST "http://localhost:8000/api/v1/services" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Auth API Production",
    "description": "User authentication service",
    "endpoint_url": "https://api.example.com/health",
    "http_method": "GET",
    "service_type": "https_api",
    "headers": {
      "Authorization": "Bearer secret-token"
    },
    "expected_status_codes": [200, 204],
    "timeout_seconds": 10,
    "check_interval_seconds": 60,
    "failure_threshold": 3
  }'
```

### Get Dashboard Overview

```bash
curl "http://localhost:8000/api/v1/dashboard/overview"
```

### Request AI Analysis for Incident

```bash
curl -X POST "http://localhost:8000/api/v1/incidents/42/analysis" \
  -H "Content-Type: application/json" \
  -d '{
    "force_reanalyze": false
  }'
```

## Configuration

### Environment Variables

See `.env.example` for all available configuration options.

Key settings:

- `DATABASE_URL` - Database connection string
- `AI_ENABLED` - Enable/disable AI analysis
- `AI_API_KEY` - OpenAI API key
- `AI_MODEL` - AI model to use (default: gpt-4-turbo)
- `SCHEDULER_ENABLED` - Enable/disable background monitoring
- `MONITORING_INTERVAL_SECONDS` - Health check interval (default: 30)
- `DEFAULT_CHECK_INTERVAL_SECONDS` - Default service check interval (default: 60)
- `DEFAULT_FAILURE_THRESHOLD` - Failures before incident (default: 3)

### Database Migration

For production with PostgreSQL:

1. Update DATABASE_URL in `.env`:
```env
DATABASE_URL=postgresql://user:password@localhost:5432/servicesentinel
```

2. Install PostgreSQL driver:
```bash
pip install psycopg2-binary
```

3. Run the application - tables will be created automatically

## Development

### Project Structure

- **Models** - SQLAlchemy ORM models define database schema
- **Schemas** - Pydantic models for request/response validation
- **Repositories** - Data access layer with CRUD operations
- **Services** - Business logic layer
- **API Routes** - FastAPI endpoints

### Adding a New Endpoint

1. Define Pydantic schema in `app/schemas/`
2. Add repository method in `app/repositories/`
3. Create route handler in `app/api/`
4. Register router in `app/main.py`

### Running Tests

```bash
pytest
```

## Deployment

### Docker Deployment (Recommended)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t servicesentinel .
docker run -p 8000:8000 --env-file .env servicesentinel
```

### Production Considerations

1. Use PostgreSQL instead of SQLite
2. Set `DEBUG=False` in production
3. Use a reverse proxy (nginx) for HTTPS
4. Set up proper logging and monitoring
5. Configure CORS for your frontend domain
6. Set strong SECRET_KEY for security
7. Consider running monitoring worker as separate process
8. Set up database backups

## AI Integration

ServiceSentinel can integrate with various AI providers:

- **OpenAI** - GPT-4 Turbo (default)
- **Anthropic** - Claude 3.5 Sonnet
- **Custom** - Any OpenAI-compatible API

Configure in `.env`:
```env
AI_ENABLED=True
AI_API_KEY=your-api-key
AI_MODEL=gpt-4-turbo
AI_API_URL=https://api.openai.com/v1/chat/completions
```

## Cost Management

AI analysis costs are tracked per incident:

- View total costs: `GET /api/v1/dashboard/metrics`
- Per-incident cost in AI analysis response
- Automatic deduplication to avoid analyzing similar incidents

## Troubleshooting

### Database Connection Issues

Check `DATABASE_URL` format and database accessibility.

### Scheduler Not Running

Verify `SCHEDULER_ENABLED=True` in `.env`

### AI Analysis Failing

- Confirm `AI_ENABLED=True` and `AI_API_KEY` is set
- Check API key validity and quota
- Review logs for detailed error messages

## Roadmap

- [ ] Notification system (Email, Slack, Discord)
- [ ] WebSocket support for real-time updates
- [ ] Advanced analytics and reporting
- [ ] Multi-tenancy support
- [ ] Service groups and dependencies
- [ ] Custom alert rules
- [ ] Integration tests
- [ ] Performance optimizations

## License

MIT License

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
