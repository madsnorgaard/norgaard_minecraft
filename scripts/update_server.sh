#!/bin/bash
echo "🔄 Updating Minecraft Server to 1.21.4"
echo "======================================"

# Backup first
echo "📦 Creating backup..."
./scripts/backup.sh

# Update server
echo "🐋 Pulling latest Docker image..."
docker compose pull

echo "🛑 Stopping server..."
docker compose down

echo "🚀 Starting updated server..."
docker compose up -d

echo "📝 Checking logs..."
sleep 5
docker logs minecraft-server --tail 20

echo "✅ Update complete! Server running 1.21.4"
