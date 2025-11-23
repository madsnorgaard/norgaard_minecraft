#!/bin/bash
# Fixed sync script

echo "🔄 Syncing modpack..."

SERVER_MODS="data/mods"
CLIENT_MODS="modpack/client/mods"

# Create directory
mkdir -p $CLIENT_MODS

# Simple copy (rsync was excluding too much)
echo "📦 Copying mods..."
cp $SERVER_MODS/*.jar $CLIENT_MODS/ 2>/dev/null

# Count
TOTAL=$(ls $CLIENT_MODS/*.jar 2>/dev/null | wc -l)

# Update metadata
cat > modpack/client/modpack.json << JSON
{
  "name": "Minecraft Server",
  "version": "1.21.5",
  "minecraft": "1.21.5",
  "fabric": "0.18.1",
  "updated": "$(date -Iseconds)"
}
JSON

echo "✅ Modpack synced"
echo "📊 Total mods: $TOTAL"
