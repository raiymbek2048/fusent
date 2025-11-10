#!/bin/bash

set -e

echo "=== Full Production Restart ==="
echo ""

# Pull latest changes
echo "1. Pulling latest changes..."
cd ~/fusent
git pull origin claude/prod-setup-011CUv2vMSa4Nc2m8dkts4fX

echo ""
echo "2. Restarting Backend..."
./start-production-backend.sh

echo ""
echo "3. Waiting for backend to be ready..."
sleep 15

echo ""
echo "4. Restarting Frontend..."
cd ~/fusent
./restart-production.sh

echo ""
echo "=== Full production restart complete! ==="
echo ""
echo "Services:"
echo "  - Frontend: http://85.113.27.42:900"
echo "  - Backend API: http://85.113.27.42:901"
echo "  - MinIO: http://85.113.27.42:9000"
