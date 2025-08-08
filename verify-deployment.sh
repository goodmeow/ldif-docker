#!/bin/bash

# LDIF Converter Deployment Verification Script

echo "=== LDIF Docker Converter - Deployment Verification ==="
echo

# Check if Docker is running
echo "1. Checking Docker status..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi
echo "✅ Docker is running"

# Check if container is running
echo "2. Checking container status..."
if ! docker compose ps | grep -q "Up.*healthy"; then
    echo "❌ Container is not running or not healthy"
    echo "Run: docker compose up -d"
    exit 1
fi
echo "✅ Container is running"

# Check health endpoint
echo "3. Testing health endpoint..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health.html)
if [ "$HEALTH_STATUS" != "200" ]; then
    echo "❌ Health check failed (HTTP $HEALTH_STATUS)"
    exit 1
fi
echo "✅ Health check passed"

# Check main application
echo "4. Testing main application..."
APP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$APP_STATUS" != "200" ]; then
    echo "❌ Main application failed (HTTP $APP_STATUS)"
    exit 1
fi
echo "✅ Main application accessible"

# Check for required content
echo "5. Verifying application content..."
if ! curl -s http://localhost:8080 | grep -q "LDIF.*Excel Converter"; then
    echo "❌ Application content verification failed"
    exit 1
fi
echo "✅ Application content verified"

echo
echo "🎉 Deployment verification successful!"
echo "📊 LDIF Converter is ready at: http://localhost:8080"
echo
echo "Quick commands:"
echo "  • View logs:     docker compose logs -f"
echo "  • Stop app:      docker compose down"
echo "  • Restart app:   docker compose restart"
echo "  • Rebuild app:   docker compose up --build -d"
