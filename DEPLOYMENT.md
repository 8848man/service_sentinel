# ServiceSentinel Deployment Guide

This guide covers various deployment options for ServiceSentinel Backend.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Docker Deployment](#docker-deployment)
3. [Production Deployment](#production-deployment)
4. [Database Setup](#database-setup)
5. [Environment Configuration](#environment-configuration)
6. [Monitoring & Logging](#monitoring--logging)

## Development Setup

### Quick Start

1. **Clone and setup:**
```bash
git clone <repository-url>
cd service_sentinel_be
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

2. **Configure environment:**
```bash
cp .env.example .env
# Edit .env with your settings
```

3. **Run the server:**
```bash
python run.py
# Or directly:
uvicorn app.main:app --reload
```

4. **Run tests:**
```bash
pytest
```

## Docker Deployment

### Using Docker Compose (Recommended)

1. **Create .env file:**
```bash
cp .env.example .env
# Edit with your settings
```

2. **Start services:**
```bash
docker-compose up -d
```

3. **View logs:**
```bash
docker-compose logs -f api
```

4. **Stop services:**
```bash
docker-compose down
```

### Using Docker only

1. **Build image:**
```bash
docker build -t servicesentinel:latest .
```

2. **Run container:**
```bash
docker run -d \
  -p 8000:8000 \
  -e DATABASE_URL="sqlite:///./servicesentinel.db" \
  -e AI_ENABLED="False" \
  --name servicesentinel \
  servicesentinel:latest
```

## Production Deployment

### Prerequisites

- Ubuntu 20.04+ or similar Linux distribution
- Python 3.10+
- PostgreSQL 13+
- nginx (for reverse proxy)
- systemd (for service management)

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y python3.11 python3.11-venv python3-pip postgresql postgresql-contrib nginx

# Create application user
sudo useradd -m -s /bin/bash servicesentinel
```

### Step 2: PostgreSQL Setup

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE servicesentinel;
CREATE USER sentinel_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE servicesentinel TO sentinel_user;
\q
```

### Step 3: Application Setup

```bash
# Switch to app user
sudo su - servicesentinel

# Clone repository
git clone <repository-url> /home/servicesentinel/app
cd /home/servicesentinel/app

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
nano .env
```

Edit `.env`:
```env
DATABASE_URL=postgresql://sentinel_user:your_secure_password@localhost:5432/servicesentinel
AI_ENABLED=True
AI_API_KEY=your-api-key
SECRET_KEY=generate-with-openssl-rand-hex-32
DEBUG=False
```

### Step 4: Systemd Service

Create `/etc/systemd/system/servicesentinel.service`:

```ini
[Unit]
Description=ServiceSentinel Backend
After=network.target postgresql.service

[Service]
Type=simple
User=servicesentinel
WorkingDirectory=/home/servicesentinel/app
Environment="PATH=/home/servicesentinel/app/venv/bin"
ExecStart=/home/servicesentinel/app/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable servicesentinel
sudo systemctl start servicesentinel
sudo systemctl status servicesentinel
```

### Step 5: Nginx Configuration

Create `/etc/nginx/sites-available/servicesentinel`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (for future features)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:8000/health;
        access_log off;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/servicesentinel /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 6: SSL with Let's Encrypt

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Test auto-renewal
sudo certbot renew --dry-run
```

## Database Setup

### Migration with Alembic

1. **Initialize Alembic:**
```bash
alembic init migrations
```

2. **Configure `alembic.ini`:**
```ini
sqlalchemy.url = postgresql://user:pass@localhost/servicesentinel
```

3. **Create migration:**
```bash
alembic revision --autogenerate -m "Initial migration"
```

4. **Apply migration:**
```bash
alembic upgrade head
```

### Backup Strategy

**Daily backups:**

Create `/home/servicesentinel/backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/home/servicesentinel/backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="servicesentinel_$DATE.sql.gz"

mkdir -p $BACKUP_DIR

# Backup database
pg_dump -U sentinel_user servicesentinel | gzip > "$BACKUP_DIR/$FILENAME"

# Keep only last 7 days
find $BACKUP_DIR -name "servicesentinel_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $FILENAME"
```

Add to crontab:
```bash
crontab -e
# Add:
0 2 * * * /home/servicesentinel/backup.sh >> /home/servicesentinel/backup.log 2>&1
```

## Environment Configuration

### Production Environment Variables

```env
# Application
APP_NAME=ServiceSentinel
APP_VERSION=1.0.0
DEBUG=False

# Database
DATABASE_URL=postgresql://sentinel_user:password@localhost:5432/servicesentinel

# AI Configuration
AI_ENABLED=True
AI_API_KEY=your-openai-api-key
AI_MODEL=gpt-4-turbo
AI_API_URL=https://api.openai.com/v1/chat/completions

# Monitoring
SCHEDULER_ENABLED=True
MONITORING_INTERVAL_SECONDS=30
DEFAULT_CHECK_INTERVAL_SECONDS=60
DEFAULT_FAILURE_THRESHOLD=3
CONCURRENT_CHECKS_LIMIT=50

# Security
SECRET_KEY=use-openssl-rand-hex-32-to-generate
CORS_ORIGINS=["https://your-frontend-domain.com"]

# Logging
LOG_LEVEL=INFO
```

### Security Checklist

- [ ] Use strong database passwords
- [ ] Generate secure SECRET_KEY
- [ ] Keep AI_API_KEY secure
- [ ] Configure CORS for your domain only
- [ ] Enable HTTPS/SSL
- [ ] Set DEBUG=False in production
- [ ] Restrict database access to localhost
- [ ] Use firewall to limit port access
- [ ] Regular security updates
- [ ] Monitor logs for suspicious activity

## Monitoring & Logging

### Application Logs

View logs:
```bash
# Systemd logs
sudo journalctl -u servicesentinel -f

# Application logs (if configured)
tail -f /home/servicesentinel/app/logs/app.log
```

### Health Monitoring

Create health check script `/usr/local/bin/check-servicesentinel.sh`:
```bash
#!/bin/bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)

if [ $STATUS -eq 200 ]; then
    echo "ServiceSentinel is healthy"
    exit 0
else
    echo "ServiceSentinel is down (Status: $STATUS)"
    exit 1
fi
```

Add to cron for monitoring:
```bash
*/5 * * * * /usr/local/bin/check-servicesentinel.sh || systemctl restart servicesentinel
```

### Performance Monitoring

Install monitoring tools:
```bash
# Install Prometheus node exporter
sudo apt install prometheus-node-exporter

# Or use htop for manual monitoring
sudo apt install htop
htop
```

## Scaling Considerations

### Horizontal Scaling

For multiple instances:

1. **Use external PostgreSQL**
2. **Share Redis for caching** (if implemented)
3. **Load balancer** (nginx, HAProxy)
4. **Separate monitoring worker** from API servers

Example load balancer config:
```nginx
upstream servicesentinel_backend {
    least_conn;
    server 10.0.0.1:8000;
    server 10.0.0.2:8000;
    server 10.0.0.3:8000;
}

server {
    listen 80;
    location / {
        proxy_pass http://servicesentinel_backend;
    }
}
```

### Vertical Scaling

Optimize for single server:

1. **Increase worker processes:**
```bash
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

2. **Database connection pooling:**
```python
# In app/core/database.py
engine = create_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=40
)
```

3. **Resource limits in systemd:**
```ini
[Service]
LimitNOFILE=65535
LimitNPROC=4096
```

## Troubleshooting

### Common Issues

**Service won't start:**
```bash
# Check logs
sudo journalctl -u servicesentinel -n 50

# Check permissions
sudo chown -R servicesentinel:servicesentinel /home/servicesentinel/app

# Check database connection
sudo -u servicesentinel psql -U sentinel_user -d servicesentinel -h localhost
```

**High memory usage:**
```bash
# Check process
ps aux | grep uvicorn

# Restart service
sudo systemctl restart servicesentinel
```

**Database connection errors:**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

## Maintenance

### Update Application

```bash
# As servicesentinel user
cd /home/servicesentinel/app
git pull
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart servicesentinel
```

### Database Maintenance

```bash
# Vacuum database
sudo -u postgres psql servicesentinel -c "VACUUM ANALYZE;"

# Check database size
sudo -u postgres psql servicesentinel -c "SELECT pg_size_pretty(pg_database_size('servicesentinel'));"
```

## Support

For issues or questions:
- Check logs: `sudo journalctl -u servicesentinel`
- Review documentation: README.md
- Open issue on GitHub
