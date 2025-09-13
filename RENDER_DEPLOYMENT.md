# Render Free/Cheapest Tier Deployment Guide

## Overview
This guide covers deploying the Ensemble sheet music conversion application to Render using free tier for frontend and starter tier for backend, optimized for maximum cost efficiency.

## Cost Breakdown
- **Frontend**: FREE ($0/month) - 750 hours/month
- **Backend**: Starter ($7/month) - 512MB RAM, 0.5 CPU
- **Database**: FREE ($0/month) - 256MB, 1GB storage
- **Total**: $7/month

## Prerequisites
- Render account (free)
- GitHub repository
- Clerk authentication setup

## Automated Deployment

```bash
# Run the Render deployment script
npm run deploy:render
```

This script will:
- Push code to GitHub
- Provide manual deployment instructions
- Show cost breakdown

## Manual Deployment Steps

### 1. Prepare Repository
```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### 2. Create Services on Render

#### Service Names (Pre-configured)
**Your services will be named:**
- **Frontend**: `ensemble-v1-frontend`
- **Backend**: `ensemble-v1-backend`
- **Database**: `ensemble-v1-db`

**Note**: If these names are taken, you can modify them in `render.yaml` before deployment.

#### Frontend Service (Free Tier)
1. Go to [render.com](https://render.com) and sign in
2. Click "New" → "Web Service"
3. Connect your repository: `Ensemble-v1/ensemble-v2-deployement`
4. Configure:
   - **Name**: `ensemble-v1-frontend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Plan**: `Free`

#### Backend Service (Starter Tier)
1. Click "New" → "Web Service"
2. Connect the same repository
3. Configure:
   - **Name**: `ensemble-v1-backend`
   - **Runtime**: `Node`
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && npm start`
   - **Plan**: `Starter` ($7/month)

#### Database (Free Tier)
1. Click "New" → "PostgreSQL"
2. Configure:
   - **Name**: `ensemble-v1-db`
   - **Plan**: `Free`

### 3. Environment Variables

#### Frontend Environment Variables:
```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_your_key
CLERK_SECRET_KEY=sk_live_your_key
NEXT_PUBLIC_BACKEND_URL=https://ensemble-v1-backend.onrender.com
```

#### Backend Environment Variables:
```
NODE_ENV=production
PORT=10000
FRONTEND_URL=https://ensemble-v1-frontend.onrender.com
CLERK_SECRET_KEY=sk_live_your_key
CLERK_PUBLISHABLE_KEY=pk_live_your_key
PYTHON_PATH=python3
LOG_LEVEL=info
DATABASE_URL=postgresql://user:password@host:5432/db
```

## Free Tier Limitations & Solutions

### Problem: Services Sleep After 15 Minutes
**Solution**: Use wake-up script when needed
```bash
# Wake up the backend service
npm run wake:render https://ensemble-v1-backend.onrender.com
```

### Problem: Limited Resources
**Solution**: Optimized for 512MB RAM backend

### Problem: No Custom Domains on Free Tier
**Solution**: Use Render's default subdomain or upgrade frontend to paid tier

## Monitoring & Maintenance

### View Logs
```bash
# Frontend logs: Render dashboard → ensemble-frontend → Logs
# Backend logs: Render dashboard → ensemble-backend → Logs
```

### Monitor Usage
- Check free tier hours remaining in Render dashboard
- Monitor backend resource usage
- Set up alerts for service downtime

### Cost Monitoring
- Free tier: 750 hours/month
- Starter tier: $7/month (fixed)
- Database: Free (256MB limit)

## Troubleshooting

### Service Won't Start
- Check build logs for errors
- Verify environment variables
- Ensure Python/OEMER dependencies are available

### Free Tier Sleep Issues
- Use wake-up script before API calls
- Consider upgrading to paid tier for 24/7 availability

### Memory Issues
- Monitor backend memory usage
- Optimize OEMER processing for limited RAM

## Performance Optimization

### For Free Tier Constraints:
- Reduced image processing resolution
- Optimized memory usage in OEMER
- Efficient file cleanup
- Smart caching strategies

### Scaling Options:
- Upgrade backend to Standard tier ($25/month) for more resources
- Add horizontal scaling for high traffic
- Use Redis add-on for caching ($7/month)

## Backup & Recovery

### Database Backups
- Free tier: Manual exports only
- Paid tiers: Automatic daily backups

### Code Deployment
- Automatic deployments from GitHub
- Rollback to previous versions
- Environment-specific configurations

---

## Success Checklist

- [ ] Frontend deployed on free tier
- [ ] Backend deployed on starter tier ($7/month)
- [ ] Database created on free tier
- [ ] Environment variables configured
- [ ] Services accessible at Render URLs
- [ ] OEMER processing working
- [ ] Authentication functional
- [ ] File upload/download working

**Total Cost: $7/month** 🎉

**URLs will be:**
- Frontend: `https://ensemble-v1-frontend.onrender.com`
- Backend: `https://ensemble-v1-backend.onrender.com`
