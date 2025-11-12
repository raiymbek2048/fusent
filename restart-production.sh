#!/bin/bash

set -e

echo "=== Restarting Production Frontend ==="
echo ""

# Navigate to the project directory
cd ~/fusent/fusent-web

echo "1. Using current local version (skipping git pull)..."

echo ""
echo "2. Installing dependencies..."
npm install

echo ""
echo "3. Building Next.js application..."
npm run build

echo ""
echo "4. Stopping PM2 if running..."
pm2 stop fusent-web || echo "PM2 app not running"

echo ""
echo "5. Starting PM2 with ecosystem config..."
pm2 start ecosystem.config.js

echo ""
echo "6. Saving PM2 configuration..."
pm2 save

echo ""
echo "7. Setting up PM2 startup..."
pm2 startup || echo "PM2 startup already configured"

echo ""
echo "8. Checking PM2 status..."
pm2 status

echo ""
echo "9. Checking nginx status..."
sudo systemctl status nginx --no-pager || sudo service nginx status

echo ""
echo "10. Restarting nginx..."
sudo systemctl restart nginx || sudo service nginx restart

echo ""
echo "11. Checking nginx configuration..."
sudo nginx -t

echo ""
echo "12. Checking what's listening on ports..."
sudo netstat -tlnp | grep -E ":(80|443|3000)"

echo ""
echo "13. Showing recent PM2 logs..."
pm2 logs fusent-web --lines 30 --nostream

echo ""
echo "=== Production restart complete! ==="
echo "Frontend should be accessible at http://85.113.27.42"
