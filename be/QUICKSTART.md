# ServiceSentinel - Quick Start Guide

Get ServiceSentinel up and running in 5 minutes!

## 🚀 Option 1: Quick Start (Recommended for Testing)

### Prerequisites
- Python 3.10 or higher
- pip

### Steps

1. **Clone and Navigate**
```bash
cd service_sentinel_be
```

2. **Setup Virtual Environment**
```bash
python -m venv venv
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate
```

3. **Install Dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure Environment**
```bash
# Windows
copy .env.example .env
# Linux/Mac
cp .env.example .env
```

5. **Run the Application**
```bash
python run.py
```

6. **Access the Application**
- API Documentation: http://localhost:8000/docs
- Alternative Docs: http://localhost:8000/redoc
- Health Check: http://localhost:8000/health

## 🐳 Option 2: Docker (Recommended for Development)

### Prerequisites
- Docker
- Docker Compose

### Steps

1. **Create Environment File**
```bash
cp .env.example .env
# Edit .env if needed
```

2. **Start with Docker Compose**
```bash
docker-compose up -d
```

3. **View Logs**
```bash
docker-compose logs -f api
```

4. **Access the Application**
- API: http://localhost:8000
- Documentation: http://localhost:8000/docs

## 📝 First API Calls

### 1. Check System Health
```bash
curl http://localhost:8000/health
```

### 2. Create Your First Service
```bash
curl -X POST "http://localhost:8000/api/v1/services" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Google",
    "description": "Google homepage",
    "endpoint_url": "https://www.google.com",
    "http_method": "GET",
    "service_type": "https_api",
    "expected_status_codes": [200],
    "timeout_seconds": 10,
    "check_interval_seconds": 60,
    "failure_threshold": 3
  }'
```

### 3. View Dashboard
```bash
curl http://localhost:8000/api/v1/dashboard/overview
```

### 4. Trigger Manual Health Check
```bash
# Replace {service_id} with your service ID from step 2
curl -X POST "http://localhost:8000/api/v1/services/1/check-now"
```

### 5. Get Service Statistics
```bash
curl "http://localhost:8000/api/v1/services/1/stats?period=24h"
```

## 🎯 Next Steps

### Enable AI Analysis (Optional)

1. **Get an OpenAI API Key**
   - Visit https://platform.openai.com/api-keys
   - Create a new API key

2. **Update .env**
```env
AI_ENABLED=True
AI_API_KEY=your-api-key-here
AI_MODEL=gpt-4-turbo
```

3. **Restart the Application**
```bash
# If using Python
# Press Ctrl+C and run: python run.py

# If using Docker
docker-compose restart api
```

4. **Request AI Analysis for an Incident**
```bash
curl -X POST "http://localhost:8000/api/v1/incidents/{incident_id}/analysis"
```

### Add More Services

Monitor your own APIs:

```bash
curl -X POST "http://localhost:8000/api/v1/services" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Production API",
    "description": "Main API endpoint",
    "endpoint_url": "https://api.yourcompany.com/health",
    "http_method": "GET",
    "service_type": "https_api",
    "headers": {
      "Authorization": "Bearer your-token"
    },
    "expected_status_codes": [200, 204],
    "timeout_seconds": 15,
    "check_interval_seconds": 30,
    "failure_threshold": 3
  }'
```

## 🧪 Run Tests

```bash
pytest
```

## 📚 Learn More

- **Full Documentation**: See [README.md](README.md)
- **API Examples**: See [API_EXAMPLES.md](API_EXAMPLES.md)
- **Deployment Guide**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Interactive API Docs**: Visit http://localhost:8000/docs

## 🛠️ Common Commands

### Development

```bash
# Run with auto-reload
uvicorn app.main:app --reload

# Run on different port
uvicorn app.main:app --port 8080

# Run tests
pytest

# Run tests with coverage
pytest --cov=app tests/
```

### Docker

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f api

# Rebuild after code changes
docker-compose up -d --build

# Access database
docker-compose exec db psql -U sentinel -d servicesentinel
```

### Production

```bash
# Run with multiple workers
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000

# Check systemd service status
sudo systemctl status servicesentinel

# View application logs
sudo journalctl -u servicesentinel -f

# Restart service
sudo systemctl restart servicesentinel
```

## 🔧 Configuration

### Key Environment Variables

```env
# Database
DATABASE_URL=sqlite:///./servicesentinel.db
# Or for PostgreSQL:
# DATABASE_URL=postgresql://user:pass@localhost/servicesentinel

# Monitoring
SCHEDULER_ENABLED=True
MONITORING_INTERVAL_SECONDS=30

# AI (Optional)
AI_ENABLED=False
AI_API_KEY=your-key-here
AI_MODEL=gpt-4-turbo

# Security
SECRET_KEY=generate-with-openssl-rand-hex-32
DEBUG=False

# CORS
CORS_ORIGINS=["http://localhost:3000"]
```

## ❓ Troubleshooting

### Application Won't Start

**Check Python version:**
```bash
python --version  # Should be 3.10+
```

**Check dependencies:**
```bash
pip install -r requirements.txt
```

### Database Errors

**For SQLite (default):**
- Ensure write permissions in current directory

**For PostgreSQL:**
- Check DATABASE_URL is correct
- Ensure PostgreSQL is running
- Verify database and user exist

### Health Checks Not Running

**Check configuration:**
```bash
# In .env file
SCHEDULER_ENABLED=True
MONITORING_INTERVAL_SECONDS=30
```

**Check logs:**
```bash
# Look for "Monitoring scheduler started" message
```

### Port Already in Use

**Use different port:**
```bash
uvicorn app.main:app --port 8080
```

## 💡 Pro Tips

1. **Use Docker Compose for development** - Includes PostgreSQL
2. **Enable debug mode** - Set `DEBUG=True` in .env during development
3. **Check the docs** - Interactive API docs at `/docs` are your friend
4. **Monitor costs** - Check `/api/v1/dashboard/metrics` for AI usage
5. **Start simple** - Use SQLite first, migrate to PostgreSQL later

## 🎉 Success!

If you can access http://localhost:8000/docs, you're all set!

Now you can:
- ✅ Monitor your APIs
- ✅ Get instant health status
- ✅ Receive intelligent failure analysis
- ✅ Track uptime and performance

Happy monitoring! 🚀
