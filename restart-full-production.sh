#!/bin/bash

set -e

echo "=== Full Production Restart (Docker + PM2) ==="
echo ""

# Skip git pull to avoid overwriting local changes
echo "1. Using current local version (skipping git pull)..."
cd ~/fusent

echo ""
echo "2. Restarting Backend (Docker)..."
./start-production-backend.sh

echo ""
echo "3. Waiting for backend to be fully ready..."
sleep 20

echo ""
echo "4. Checking backend health..."
docker inspect fusent-backend --format='{{.State.Health.Status}}' || echo "Backend health check in progress..."

echo ""
echo "5. Restarting Frontend (PM2)..."
cd ~/fusent
./restart-production.sh

echo ""
echo "=== Full production restart complete! ==="
echo ""
echo "Services:"
echo "  - Frontend: http://85.113.27.42"
echo "  - Backend API: http://85.113.27.42:8080"
echo "  - MinIO Console: http://85.113.27.42:9001"
echo "  - MinIO API: http://85.113.27.42:9000"
echo ""
echo "Docker containers status:"
docker-compose ps
