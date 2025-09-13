# Ensemble Deployment Guide

This guide provides comprehensive instructions for deploying Ensemble to DigitalOcean App Platform with auto-scaling capabilities.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [DigitalOcean App Platform Deployment](#digitalocean-app-platform-deployment)
- [Local Development with Docker](#local-development-with-docker)
- [Environment Configuration](#environment-configuration)
- [Auto-scaling Configuration](#auto-scaling-configuration)
- [Domain Setup](#domain-setup)
- [Monitoring and Logging](#monitoring-and-logging)
- [Troubleshooting](#troubleshooting)
- [Cost Optimization](#cost-optimization)

## 🚀 Overview

Ensemble is a full-stack application with separate frontend and backend components. The deployment process involves:

1. **Frontend**: Next.js application deployed as a static site
2. **Backend**: Node.js/Express API with OEMER integration deployed as a web service
3. **Auto-scaling**: CPU-based scaling for the backend service
4. **Environment Variables**: Secure configuration for both services

## 📋 Prerequisites

Before deployment, ensure you have:

- **GitHub Account**: For hosting your code
- **DigitalOcean Account**: With $300 GitHub student credits
- **Clerk Account**: For authentication
- **Domain Name**: Optional, for custom domains (can use DO default subdomain)
- **Git**: For version control
- **Docker**: For local development (optional)

## 🚀 DigitalOcean App Platform Deployment

### One-Time Automated Deployment

The easiest way to deploy is using the automated script:

```bash
# Set your GitHub username
export GITHUB_USERNAME=your-username

# Run the deployment script
npm run deploy:do
```

This script will:
- Check prerequisites (doctl, git)
- Authenticate with DigitalOcean
- Update configuration files with your repository details
- Push code to GitHub
- Create and deploy the app
- Monitor deployment progress
- Provide the live URL

### Manual Deployment Steps

If you prefer manual deployment:

#### 1. Prepare Your Repository

```bash
# Ensure all changes are committed
git add .
git commit -m "Prepare for DigitalOcean deployment"
git push origin main
```

#### 2. Install doctl (DigitalOcean CLI)

```bash
# Download and install doctl
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin

# Authenticate
doctl auth init
```

#### 3. Update App Configuration

Edit `.do/app.yaml` and update the repository information:

```yaml
github:
  repo: your-username/ensemble-v2-deployement
```

#### 4. Create the App

```bash
# Create the app
doctl apps create --spec .do/app.yaml

# Get app ID
APP_ID=$(doctl apps list | grep ensemble-app | awk '{print $1}')

# Monitor deployment
doctl apps get $APP_ID
```

#### 5. Configure Environment Variables

In the DigitalOcean dashboard:

1. Go to your app
2. Click "Settings" → "Environment Variables"
3. Add the following variables:

**Frontend Environment Variables:**
```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_...
CLERK_SECRET_KEY=sk_live_...
NEXT_PUBLIC_BACKEND_URL=${APP_URL}
```

**Backend Environment Variables:**
```
NODE_ENV=production
PORT=8080
FRONTEND_URL=${APP_URL}
CLERK_SECRET_KEY=sk_live_...
CLERK_PUBLISHABLE_KEY=pk_live_...
PYTHON_PATH=python3
LOG_LEVEL=info
```

### Auto-scaling Configuration

The backend service is pre-configured with auto-scaling:

- **Min instances**: 1
- **Max instances**: 5
- **Scaling trigger**: CPU usage > 80%

You can adjust these settings in the DigitalOcean dashboard under "Settings" → "Scaling".

### Cost Estimation

With $300 GitHub student credits:
- **Basic tier**: ~$12/month (covered by credits)
- **Auto-scaling**: Additional instances cost ~$12/month each
- **Bandwidth**: First 1TB free, then $0.01/GB
- **Build minutes**: 200 minutes free per month

### Monitoring Auto-scaling

```bash
# Check current instances
doctl apps get $APP_ID --format Services

# View logs
doctl apps logs $APP_ID --follow

# Monitor metrics
doctl apps get $APP_ID --format Metrics
```

## 🐳 Local Development with Docker

### Quick Start with Docker Compose

```bash
# Start all services
npm run docker:dev

# Or manually
docker-compose up --build

# Access the application
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
```

### Individual Service Development

```bash
# Build and run frontend only
npm run docker:build
npm run docker:run

# Backend development with volume mounting
docker run -p 8080:8080 \
  -v $(pwd)/backend:/app \
  -v /app/node_modules \
  ensemble-backend
```

### Docker Commands

```bash
# Stop all services
npm run docker:stop

# View logs
docker-compose logs -f

# Clean up
docker system prune -a
```

## 🛠️ Manual Deployment

### 1. Server Setup

#### Ubuntu Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Python and pip
sudo apt install python3 python3-pip -y

# Install OEMER
pip3 install oemer

# Install Nginx
sudo apt install nginx -y

# Install PM2
sudo npm install -g pm2
```

### 2. Application Setup

```bash
# Clone repository
git clone https://github.com/your-username/ensemble-v2.git
cd ensemble-v2

# Install dependencies
npm install
cd backend && npm install && cd ..

# Create environment files
cp .env.local.example .env.local
cp backend/.env.example backend/.env

# Edit environment files with your values
```

### 3. Frontend Build

```bash
# Build frontend
npm run build

# Start frontend with PM2
pm2 start npm --name "ensemble-frontend" -- start
```

### 4. Backend Setup

```bash
# Create systemd service for backend
sudo nano /etc/systemd/system/ensemble-backend.service
```

#### Backend Service File
```ini
[Unit]
Description=Ensemble Backend Service
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/home/your-user/ensemble-v2/backend
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3001
Environment=FRONTEND_URL=https://your-domain.com
Environment=CLERK_SECRET_KEY=your_secret_key
Environment=CLERK_PUBLISHABLE_KEY=your_publishable_key
Environment=PYTHON_PATH=python3

[Install]
WantedBy=multi-user.target
```

#### Start Backend Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable ensemble-backend
sudo systemctl start ensemble-backend
```

### 5. Nginx Configuration

```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/ensemble
```

#### Nginx Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL Configuration
    ssl_certificate /path/to/your/cert.pem;
    ssl_certificate_key /path/to/your/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Static files
    location /static/ {
        alias /home/your-user/ensemble-v2/public/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Enable Nginx Site
```bash
sudo ln -s /etc/nginx/sites-available/ensemble /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 🔧 Environment Configuration

### Frontend (.env.local)

```env
# Clerk Authentication
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_your_publishable_key
CLERK_SECRET_KEY=sk_live_your_secret_key

# Backend URL
NEXT_PUBLIC_BACKEND_URL=https://your-backend-domain.com

# Optional: Custom domain for Clerk
# NEXT_PUBLIC_CLERK_DOMAIN=your-domain.com

# Optional: Theme customization
# NEXT_PUBLIC_THEME=dark
```

### Backend (.env)

```env
# Server Configuration
NODE_ENV=production
PORT=3001

# Frontend URL
FRONTEND_URL=https://your-frontend-domain.com

# Clerk Authentication
CLERK_SECRET_KEY=sk_live_your_secret_key
CLERK_PUBLISHABLE_KEY=pk_live_your_publishable_key

# Python Path (for OEMER)
PYTHON_PATH=python3

# Logging
LOG_LEVEL=info

# File Upload Limits
MAX_FILE_SIZE=52428800  # 50MB

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 minutes
RATE_LIMIT_MAX_REQUESTS=100

# CORS Origins
CORS_ORIGIN=https://your-frontend-domain.com

# Optional: Database (if needed)
# DATABASE_URL=your_database_url

# Optional: Redis (for caching)
# REDIS_URL=your_redis_url
```

## 🗄️ Database Setup

### PostgreSQL (Optional)

If you need user data persistence:

```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Create database and user
sudo -u postgres createdb ensemble_db
sudo -u postgres createuser ensemble_user
sudo -u postgres psql -c "ALTER USER ensemble_user PASSWORD 'your_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ensemble_db TO ensemble_user;"
```

#### Database Environment Variables
```env
DATABASE_URL=postgresql://ensemble_user:your_password@localhost:5432/ensemble_db
```

### Redis (Optional)

For caching and session management:

```bash
# Install Redis
sudo apt install redis-server -y

# Configure Redis
sudo nano /etc/redis/redis.conf
# Set maxmemory and maxmemory-policy

# Restart Redis
sudo systemctl restart redis-server
```

#### Redis Environment Variables
```env
REDIS_URL=redis://localhost:6379
```

## 🔒 SSL/TLS Configuration

### Let's Encrypt (Free SSL)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### SSL Configuration in Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;
}
```

## 📊 Monitoring and Logging

### Application Logging

```bash
# View backend logs
pm2 logs ensemble-backend

# View PM2 status
pm2 status

# View system logs
journalctl -u ensemble-backend -f
```

### Error Tracking

Consider integrating with error tracking services:

- **Sentry**: For error monitoring
- **LogRocket**: For session replay
- **Datadog**: For comprehensive monitoring

### Performance Monitoring

```bash
# Install monitoring tools
npm install -g pm2-web

# Start PM2 web interface
pm2-web
```

## 🐛 Troubleshooting

### Common Deployment Issues

#### 1. OEMER Not Found
```bash
# Check OEMER installation
python3 -c "import oemer; print('OEMER installed')"

# If not installed
pip3 install oemer
```

#### 2. Port Conflicts
```bash
# Check port usage
sudo lsof -i :3000
sudo lsof -i :3001

# Kill processes if needed
sudo kill -9 <PID>
```

#### 3. Environment Variables
```bash
# Check environment variables
echo $NODE_ENV
echo $CLERK_SECRET_KEY

# Verify backend can access env
cd backend && node -e "console.log(process.env.CLERK_SECRET_KEY)"
```

#### 4. Build Failures
```bash
# Clear node modules and rebuild
rm -rf node_modules backend/node_modules
npm install
cd backend && npm install && cd ..
npm run build
```

#### 5. SSL Issues
```bash
# Test SSL configuration
openssl s_client -connect your-domain.com:443

# Check certificate expiration
sudo openssl x509 -enddate -noout -in /etc/letsencrypt/live/your-domain.com/cert.pem
```

### Debug Mode in Production

```bash
# Enable debug logging
export LOG_LEVEL=debug

# Restart services
pm2 restart ensemble-backend
sudo systemctl restart ensemble-backend
```

## 🎯 Best Practices

### Security

1. **Environment Variables**: Never commit sensitive data to git
2. **SSL**: Always use HTTPS in production
3. **Dependencies**: Keep packages updated
4. **Firewall**: Configure UFW or similar
5. **User Input**: Validate and sanitize all inputs

### Performance

1. **Caching**: Implement Redis for session storage
2. **CDN**: Use CDN for static assets
3. **Database**: Optimize queries and use indexes
4. **Compression**: Enable gzip/brotli compression
5. **Monitoring**: Set up alerts for performance issues

### Maintenance

1. **Backups**: Regular database and file backups
2. **Updates**: Regular security updates
3. **Logs**: Monitor and rotate logs
4. **Health Checks**: Implement comprehensive health checks
5. **Documentation**: Keep deployment documentation updated

### Scaling

1. **Load Balancing**: Consider load balancers for high traffic
2. **Database**: Use managed database services
3. **CDN**: Global content delivery
4. **Monitoring**: Set up distributed tracing
5. **Auto-scaling**: Configure auto-scaling based on demand

## 📞 Support

For deployment issues:
- Check the troubleshooting section
- Review logs for error messages
- Consult platform-specific documentation
- Create an issue on GitHub with deployment details

---

**Happy deploying!** 🚀

*Remember: Always test in a staging environment before deploying to production.*
