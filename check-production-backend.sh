#!/bin/bash

echo "=== Production Backend Diagnostics (Docker) ==="
echo ""

echo "1. Checking Docker containers status..."
docker-compose ps

echo ""
echo "2. Checking backend container health..."
docker inspect fusent-backend --format='Container: {{.Name}}
Status: {{.State.Status}}
Health: {{.State.Health.Status}}
Started: {{.State.StartedAt}}' || echo "Backend container not found"

echo ""
echo "3. Checking backend logs (last 30 lines)..."
docker-compose logs --tail=30 backend

echo ""
echo "4. Checking backend resource usage..."
docker stats fusent-backend --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo "5. Checking backend network connectivity..."
docker exec fusent-backend wget -q -O- http://localhost:8080/actuator/health 2>&1 || echo "Health endpoint not responding"

echo ""
echo "6. Checking database connectivity..."
docker-compose exec -T postgres pg_isready -U fusent_user -d fusent || echo "Database not ready"

echo ""
echo "7. Checking Redis connectivity..."
docker-compose exec -T redis redis-cli ping || echo "Redis not responding"

echo ""
echo "8. Checking Kafka connectivity..."
docker-compose exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9092 2>&1 | head -n 5 || echo "Kafka not responding"

echo ""
echo "9. Checking MinIO connectivity..."
docker-compose exec -T minio curl -s http://localhost:9000/minio/health/live || echo "MinIO not responding"

echo ""
echo "10. Checking all container networks..."
docker network inspect fusent_fusent-network --format='{{range .Containers}}{{.Name}}: {{.IPv4Address}}
{{end}}' || echo "Network not found"

echo ""
echo "=== End of diagnostics ==="
echo ""
echo "Useful commands:"
echo "  - View live logs: docker-compose logs -f backend"
echo "  - Restart backend: docker-compose restart backend"
echo "  - Rebuild backend: docker-compose up -d --build backend"
echo "  - Shell into backend: docker exec -it fusent-backend /bin/sh"
