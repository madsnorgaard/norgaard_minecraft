#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 backup_20240607_120000.tar.gz"
    exit 1
fi

BACKUP_FILE="./backups/$1"
CONTAINER="minecraft-server"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  WARNING: This will replace the current world!"
read -p "Are you sure? (yes/no): " -r
if [[ ! $REPLY =~ ^yes$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo "🔄 Stopping server..."
docker compose stop

echo "📦 Restoring from $1..."
docker exec $CONTAINER tar xzf - -C /data < "$BACKUP_FILE"

echo "🚀 Starting server..."
docker compose start

echo "✅ Restore complete!"
