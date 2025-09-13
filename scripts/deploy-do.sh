#!/bin/bash

# DigitalOcean App Platform Deployment Script
# This script automates the deployment of Ensemble to DigitalOcean App Platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ensemble-app"
REPO_NAME="ensemble-v2-deployement"
GITHUB_USERNAME=${GITHUB_USERNAME:-"your-username"}

echo -e "${BLUE}🚀 Starting DigitalOcean App Platform Deployment${NC}"
echo -e "${BLUE}================================================${NC}"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v doctl &> /dev/null; then
    echo -e "${RED}❌ doctl is not installed. Please install it first:${NC}"
    echo "curl -sL https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz | tar -xzv"
    echo "sudo mv doctl /usr/local/bin"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ git is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Check if user is logged in to doctl
echo -e "${YELLOW}🔐 Checking doctl authentication...${NC}"
if ! doctl account get &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with DigitalOcean. Please run:${NC}"
    echo "doctl auth init"
    exit 1
fi

echo -e "${GREEN}✅ Authentication check passed${NC}"

# Check if repository exists and is clean
echo -e "${YELLOW}📦 Checking repository status...${NC}"
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not a git repository. Please initialize git first.${NC}"
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Repository has uncommitted changes. Committing them...${NC}"
    git add .
    git commit -m "Prepare for DigitalOcean deployment" || true
fi

echo -e "${GREEN}✅ Repository is ready${NC}"

# Push to GitHub
echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ Code pushed to GitHub${NC}"

# Update app spec with correct repository
echo -e "${YELLOW}🔧 Updating app specification...${NC}"
sed -i "s/your-username/${GITHUB_USERNAME}/g" .do/app.yaml
sed -i "s/ensemble-v2-deployement/${REPO_NAME}/g" .do/app.yaml

echo -e "${GREEN}✅ App specification updated${NC}"

# Create or update the app
echo -e "${YELLOW}🏗️  Creating/updating DigitalOcean App...${NC}"

if doctl apps list | grep -q "$APP_NAME"; then
    echo -e "${BLUE}📝 Updating existing app...${NC}"
    doctl apps update "$APP_NAME" --spec .do/app.yaml
else
    echo -e "${BLUE}🆕 Creating new app...${NC}"
    doctl apps create --spec .do/app.yaml
fi

echo -e "${GREEN}✅ App deployment initiated${NC}"

# Wait for deployment to complete
echo -e "${YELLOW}⏳ Waiting for deployment to complete...${NC}"
echo -e "${BLUE}This may take 10-15 minutes. You can check progress at:${NC}"
echo "https://cloud.digitalocean.com/apps"

# Get app ID and monitor deployment
APP_ID=$(doctl apps list | grep "$APP_NAME" | awk '{print $1}')

if [ -n "$APP_ID" ]; then
    echo -e "${BLUE}App ID: $APP_ID${NC}"

    # Monitor deployment status
    for i in {1..60}; do
        STATUS=$(doctl apps get "$APP_ID" --format Phase --no-header)
        echo -e "${BLUE}Deployment status: $STATUS${NC}"

        if [ "$STATUS" = "ACTIVE" ]; then
            echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
            break
        elif [ "$STATUS" = "ERROR" ] || [ "$STATUS" = "FAILED" ]; then
            echo -e "${RED}❌ Deployment failed. Check the DigitalOcean dashboard for details.${NC}"
            exit 1
        fi

        sleep 30
    done

    # Get app URL
    APP_URL=$(doctl apps get "$APP_ID" --format DefaultIngress --no-header)
    echo -e "${GREEN}🎉 Your app is live at: $APP_URL${NC}"

else
    echo -e "${RED}❌ Could not retrieve app ID. Please check the DigitalOcean dashboard.${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Deployment completed successfully!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Visit your app at: $APP_URL"
echo "2. Set up your domain (optional)"
echo "3. Configure environment variables in App Platform dashboard"
echo "4. Monitor auto-scaling in the dashboard"
