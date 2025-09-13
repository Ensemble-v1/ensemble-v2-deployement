#!/bin/bash

# Render Deployment Script for Free/Cheapest Tiers
# This script deploys the app to Render using free tier for frontend and starter tier for backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Render Free/Cheapest Tier Deployment${NC}"
echo -e "${BLUE}================================================${NC}"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ git is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Check if repository is clean
echo -e "${YELLOW}📦 Checking repository status...${NC}"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Repository has uncommitted changes. Committing them...${NC}"
    git add .
    git commit -m "Prepare for Render deployment" || true
fi

echo -e "${GREEN}✅ Repository is ready${NC}"

# Push to GitHub
echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ Code pushed to GitHub${NC}"

# Instructions for manual deployment
echo -e "${BLUE}📋 Manual Deployment Instructions:${NC}"
echo ""
echo -e "${YELLOW}1. Go to https://render.com${NC}"
echo -e "${YELLOW}2. Sign in with your GitHub account${NC}"
echo -e "${YELLOW}3. Click 'New' → 'Web Service'${NC}"
echo -e "${YELLOW}4. Connect your repository: Ensemble-v1/ensemble-v2-deployement${NC}"
echo ""
echo -e "${GREEN}Frontend Configuration:${NC}"
echo "  - Name: ensemble-frontend"
echo "  - Runtime: Node"
echo "  - Build Command: npm install && npm run build"
echo "  - Start Command: npm start"
echo "  - Plan: Free ($0/month)"
echo ""
echo -e "${GREEN}Backend Configuration:${NC}"
echo "  - Name: ensemble-backend"
echo "  - Runtime: Node"
echo "  - Build Command: cd backend && npm install"
echo "  - Start Command: cd backend && npm start"
echo "  - Plan: Starter ($7/month)"
echo ""
echo -e "${GREEN}Database Configuration:${NC}"
echo "  - Name: ensemble-db"
echo "  - Database: PostgreSQL"
echo "  - Plan: Free ($0/month)"
echo ""
echo -e "${YELLOW}5. Set Environment Variables:${NC}"
echo "   Frontend:"
echo "   - NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY"
echo "   - CLERK_SECRET_KEY"
echo "   - NEXT_PUBLIC_BACKEND_URL"
echo ""
echo "   Backend:"
echo "   - NODE_ENV=production"
echo "   - PORT=10000"
echo "   - FRONTEND_URL"
echo "   - CLERK_SECRET_KEY"
echo "   - CLERK_PUBLISHABLE_KEY"
echo "   - PYTHON_PATH=python3"
echo "   - LOG_LEVEL=info"
echo ""
echo -e "${BLUE}🎯 Cost Breakdown:${NC}"
echo "  - Frontend: FREE ($0/month)"
echo "  - Backend: $7/month (Starter tier)"
echo "  - Database: FREE ($0/month)"
echo "  - Total: $7/month"
echo ""
echo -e "${GREEN}✅ Deployment preparation complete!${NC}"
echo -e "${GREEN}🎉 Your app will cost only $7/month total!${NC}"
