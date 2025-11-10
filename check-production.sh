#!/bin/bash

echo "=== Production Frontend Diagnostics ==="
echo ""

echo "1. Checking PM2 status..."
pm2 status

echo ""
echo "2. Checking PM2 logs for fusent-web..."
pm2 logs fusent-web --lines 20 --nostream

echo ""
echo "3. Checking nginx status..."
sudo systemctl status nginx --no-pager || sudo service nginx status

echo ""
echo "4. Checking what's listening on port 80 and 443..."
sudo netstat -tlnp | grep -E ":(80|443)"

echo ""
echo "5. Checking nginx error logs..."
sudo tail -n 20 /var/log/nginx/error.log

echo ""
echo "6. Testing if nginx config is valid..."
sudo nginx -t

echo ""
echo "7. Checking if Next.js build exists..."
ls -la ~/fusent/fusent-web/.next/ 2>&1 || echo ".next directory not found"

echo ""
echo "8. Checking firewall status..."
sudo ufw status || echo "UFW not available"

echo ""
echo "=== End of diagnostics ==="
