#!/bin/bash

set -e

echo "=== Starting Production Backend (Docker) ==="
echo ""

# Navigate to the project directory
cd ~/fusent

echo "1. Stopping existing backend container..."
docker compose stop backend || echo "Backend container not running"
docker compose rm -f backend || echo "No backend container to remove"

echo ""
echo "2. Rebuilding backend Docker image..."
docker compose build backend

echo ""
echo "3. Starting backend container..."
docker compose up -d backend

echo ""
echo "4. Waiting for backend to start..."
sleep 15

echo ""
echo "5. Checking backend container status..."
docker compose ps backend

echo ""
echo "6. Checking backend health..."
docker inspect fusent-backend --format='{{.State.Health.Status}}' || echo "Health check not ready yet"

echo ""
echo "7. Checking backend logs..."
docker compose logs --tail=30 backend

echo ""
echo "=== Production backend start complete! ==="
echo "Backend should be accessible at http://85.113.27.42:901"
echo ""
echo "Useful commands:"
echo "  - View logs: docker compose logs -f backend"
echo "  - Check status: docker compose ps"
echo "  - Restart: docker compose restart backend"
