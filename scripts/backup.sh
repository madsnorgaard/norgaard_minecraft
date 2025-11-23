#!/bin/bash
set -e

CONTAINER="minecraft-server"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🎮 Minecraft Server Backup Script"
echo "================================="
echo "📅 Timestamp: $TIMESTAMP"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Announce backup in-game
docker exec $CONTAINER rcon-cli say "§6[Server] §eStarting backup... Lag may occur!"
docker exec $CONTAINER rcon-cli save-all
docker exec $CONTAINER rcon-cli save-off

echo "📦 Creating backup..."

# Create compressed backup
docker exec $CONTAINER tar czf - \
    -C /data \
    world world_nether world_the_end \
    whitelist.json ops.json server.properties \
    2>/dev/null > "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

# Re-enable saves
docker exec $CONTAINER rcon-cli save-on
docker exec $CONTAINER rcon-cli say "§6[Server] §aBackup complete!"

# Get backup size
SIZE=$(du -h "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" | cut -f1)
echo "✅ Backup complete: backup_$TIMESTAMP.tar.gz ($SIZE)"

# Cleanup old backups (keep last 5)
echo "🧹 Cleaning old backups..."
ls -t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -v

echo "✨ Done!"
