#!/bin/bash
# Automatically syncs server mods to client modpack

echo "🔄 Syncing modpack..."

# Variables
SERVER_MODS="data/mods"
CLIENT_MODS="modpack/client/mods"
MODPACK_VERSION=$(grep 'VERSION:' docker-compose.yml | cut -d'"' -f2)

# Create directories
mkdir -p $CLIENT_MODS

# Copy all mods (excluding server-only ones)
echo "📦 Copying mods..."
rsync -av --delete \
  --exclude="*server*.jar" \
  --exclude="*lithium*.jar" \
  --exclude="*ferritecore*.jar" \
  $SERVER_MODS/ $CLIENT_MODS/

# Generate modpack metadata
cat > modpack/client/modpack.json << JSON
{
  "name": "Aurora's Kingdom",
  "version": "$MODPACK_VERSION",
  "minecraft": "$MODPACK_VERSION",
  "fabric": "0.18.1",
  "updated": "$(date -Iseconds)"
}
JSON

# Create mod list
ls -1 $CLIENT_MODS > modpack/client/mods.txt

echo "✅ Modpack synced for version $MODPACK_VERSION"
echo "📊 Total mods: $(ls -1 $CLIENT_MODS | wc -l)"
