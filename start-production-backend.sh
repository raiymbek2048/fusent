#!/bin/bash

set -e

echo "=== Starting Production Backend ==="
echo ""

# Navigate to the project directory
cd ~/fusent

echo "1. Loading environment variables..."
export $(cat .env.production | xargs)

echo ""
echo "2. Building the application..."
./mvnw clean package -DskipTests

echo ""
echo "3. Stopping existing backend if running..."
pkill -f "fusent-0.0.1-SNAPSHOT.jar" || echo "No existing backend process found"

echo ""
echo "4. Starting the backend..."
nohup java -jar target/fusent-0.0.1-SNAPSHOT.jar \
  --spring.profiles.active=production \
  > backend.log 2>&1 &

echo "Backend started with PID: $!"

echo ""
echo "5. Waiting for backend to start..."
sleep 10

echo ""
echo "6. Checking if backend is running..."
ps aux | grep "fusent-0.0.1-SNAPSHOT.jar" | grep -v grep

echo ""
echo "7. Checking backend logs..."
tail -n 30 backend.log

echo ""
echo "=== Production backend start complete! ==="
echo "Backend should be accessible at http://85.113.27.42:901"
