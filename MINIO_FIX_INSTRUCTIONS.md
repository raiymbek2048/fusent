# MinIO Image Loading Fix Instructions

## Problem
Product images are not loading with error "500 Internal Server Error" because MinIO service is not running.

## Current Status
- MinIO is configured but not accessible on ports 9000 or 902
- Backend generates image URLs pointing to: `http://85.113.27.42:902/fucent-media/...`
- These URLs return 503 Service Unavailable

## Solution Steps

### 1. SSH into Production Server
```bash
ssh your-user@85.113.27.42
```

### 2. Navigate to Project Directory
```bash
cd ~/fusent
```

### 3. Check Docker Container Status
```bash
docker compose ps
```

Look for `fusent-minio` container. If it's not running or shows unhealthy status, proceed to next step.

### 4. Restart MinIO Service
```bash
# Stop MinIO container
docker compose stop minio

# Remove MinIO container
docker compose rm -f minio

# Start MinIO container
docker compose up -d minio

# Wait for MinIO to be healthy
docker compose ps minio

# Check MinIO logs
docker compose logs minio --tail=50
```

### 5. Verify MinIO Bucket Creation
The `minio-create-bucket` service should automatically create the bucket and set it to public. Check its logs:
```bash
docker compose logs minio-create-bucket
```

If needed, manually create the bucket:
```bash
docker exec -it fusent-minio mc alias set myminio http://localhost:9000 minioadmin minioadmin
docker exec -it fusent-minio mc mb myminio/fucent-media --ignore-existing
docker exec -it fusent-minio mc anonymous set public myminio/fucent-media
```

### 6. Test MinIO Accessibility
From your local machine or server:
```bash
# Test MinIO health
curl http://85.113.27.42:902/fucent-media/

# Should return XML listing or 200 OK, not 503
```

### 7. Restart Full Stack (Optional but Recommended)
```bash
cd ~/fusent
./restart-full-production.sh
```

## Verification

After fixing MinIO, verify images load correctly:
1. Navigate to: http://85.113.27.42:900
2. Go to any product page
3. Images should now load properly

## Configuration Reference

### Backend Configuration (application.yml)
```yaml
app:
  s3:
    endpoint: http://85.113.27.42:902
    public-endpoint: http://85.113.27.42:902
    bucket-media: fucent-media
```

### Docker Compose (docker-compose.yml)
- MinIO API: Port 9000 → 9000
- MinIO Console: Port 9001 → 9001
- Proxy maps port 902 to MinIO (via Envoy/Nginx)

### Next.js Configuration (fusent-web/next.config.js)
```javascript
remotePatterns: [
  {
    protocol: 'http',
    hostname: '85.113.27.42',
    port: '902',
    pathname: '/**',
  },
]
```

## Alternative: Use Port 9000 Directly

If port 902 proxy is not working, you can update the configuration to use port 9000 directly:

### 1. Update Backend Environment Variable
In docker-compose.yml, update:
```yaml
S3_PUBLIC_ENDPOINT: http://85.113.27.42:9000
```

### 2. Update Next.js Config
In fusent-web/next.config.js, update:
```javascript
{
  protocol: 'http',
  hostname: '85.113.27.42',
  port: '9000',  // Changed from 902
  pathname: '/**',
}
```

### 3. Rebuild and Restart
```bash
cd ~/fusent
./restart-full-production.sh
```

## Prevention

Add MinIO health monitoring to your production setup:
- Monitor MinIO container health: `docker compose ps minio`
- Check MinIO logs regularly: `docker compose logs minio --tail=100`
- Ensure MinIO container restarts on failure: already configured in docker-compose.yml with health checks

## Related Files
- Backend config: `/src/main/resources/application.yml`
- Docker compose: `/docker-compose.yml`
- Next.js config: `/fusent-web/next.config.js`
- Environment: `/fusent-web/.env.production`

## Technical Details

The error "upstream connect error or disconnect/reset before headers. reset reason: remote connection failure" indicates:
- Envoy proxy is running and receiving requests
- But it cannot connect to the upstream MinIO service
- MinIO container is either not running or not reachable from Envoy
