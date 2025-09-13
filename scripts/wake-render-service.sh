#!/bin/bash

# Render Free Tier Wake-Up Script
# This script wakes up sleeping Render services

set -e

SERVICE_URL=$1

if [ -z "$SERVICE_URL" ]; then
    echo "Usage: $0 <service-url>"
    echo "Example: $0 https://your-app.onrender.com"
    exit 1
fi

echo "🌅 Waking up Render service: $SERVICE_URL"

# Make a simple request to wake up the service
curl -s -o /dev/null -w "%{http_code}" "$SERVICE_URL" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Wake-up request sent successfully"
else
    echo "❌ Failed to wake up service"
    exit 1
fi
