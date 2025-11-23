#!/bin/bash
# Automatically syncs server mods to client modpack

echo "🔄 Syncing modpack..."

# Variables
SERVER_MODS="data/mods"
CLIENT_MODS="modpack/client/mods"

# Get version from docker-compose - fixed to handle properly
MODPACK_VERSION=$(grep 'VERSION:' docker-compose.yml | head -1 | cut -d'"' -f2)
if [ "$MODPACK_VERSION" = "LATEST" ] || [ -z "$MODPACK_VERSION" ]; then
  MODPACK_VERSION="1.21.5"
fi

# Create directories
mkdir -p $CLIENT_MODS

# Copy all mods (excluding server-only ones)
echo "📦 Copying mods..."
if [ -d "$SERVER_MODS" ]; then
  rsync -av --delete \
    --exclude="*server*.jar" \
    --exclude="*lithium*.jar" \
    --exclude="*ferritecore*.jar" \
    --exclude="README.txt" \
    $SERVER_MODS/ $CLIENT_MODS/ 2>/dev/null || cp -r $SERVER_MODS/* $CLIENT_MODS/ 2>/dev/null || true
fi

# Generate modpack metadata
cat > modpack/client/modpack.json << JSON
{
  "name": "Minecraft Server",
  "version": "$MODPACK_VERSION",
  "minecraft": "$MODPACK_VERSION",
  "fabric": "0.18.1",
  "updated": "$(date -Iseconds)"
}
JSON

# Create mod list
if [ -d "$CLIENT_MODS" ]; then
  ls -1 $CLIENT_MODS 2>/dev/null > modpack/client/mods.txt || echo "No mods yet" > modpack/client/mods.txt
fi

echo "✅ Modpack synced for version $MODPACK_VERSION"
echo "📊 Total mods: $(ls -1 $CLIENT_MODS 2>/dev/null | wc -l || echo 0)"
