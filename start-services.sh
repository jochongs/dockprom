#!/bin/bash

echo "==========================================
Starting Dockprom Inner Services
=========================================="

# Wait for Docker daemon to be ready
echo "Waiting for Docker daemon to start..."
timeout=30
counter=0
until docker info >/dev/null 2>&1; do
    if [ $counter -eq $timeout ]; then
        echo "ERROR: Docker daemon failed to start within $timeout seconds"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting... ($counter/$timeout)"
    sleep 1
done

echo "Docker daemon is ready!"

# Show Docker version
echo "Docker version:"
docker --version
docker compose version

# Navigate to app directory
cd /app

echo "Starting docker-compose services..."
docker compose -f docker-compose.inner.yml up -d

# Wait a bit for services to start
sleep 5

echo "==========================================
Services Status:
=========================================="
docker compose -f docker-compose.inner.yml ps

echo "==========================================
Dockprom is running!
Access Grafana at: http://localhost:3000
Default credentials: admin/admin
=========================================="

# Keep the script running and show logs
echo "Following container logs..."
docker compose -f docker-compose.inner.yml logs -f
