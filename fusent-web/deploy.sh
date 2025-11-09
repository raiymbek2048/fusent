#!/bin/bash

# Fusent Web Production Deployment Script
# Usage: ./deploy.sh

set -e

echo "🚀 Starting Fusent Web deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}❌ PM2 is not installed!${NC}"
    echo -e "${YELLOW}Installing PM2...${NC}"
    npm install -g pm2
fi

# Stop the old process if it exists
echo -e "${YELLOW}📦 Stopping old process...${NC}"
pm2 stop fusent-web || true

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
npm install

# Build the application
echo -e "${YELLOW}🔨 Building production bundle...${NC}"
npm run build

# Start the application with PM2
echo -e "${YELLOW}🚀 Starting application with PM2...${NC}"
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "📊 Application Status:"
pm2 status

echo ""
echo "📝 Useful commands:"
echo "  pm2 logs fusent-web    - View logs"
echo "  pm2 monit              - Monitor resources"
echo "  pm2 restart fusent-web - Restart app"
echo "  pm2 stop fusent-web    - Stop app"
