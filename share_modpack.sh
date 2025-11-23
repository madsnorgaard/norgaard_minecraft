#!/bin/bash
echo "📦 Creating Server modpack..."

# Sync latest
./scripts/sync_modpack.sh

# Create timestamped package
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cd modpack
zip -r ../MinecraftModpack_$TIMESTAMP.zip .
cd ..

echo "✅ Created: MinecraftModpack_$TIMESTAMP.zip"
echo "📤 Share this file with Player!"
echo ""
echo "Size: $(du -h MinecraftModpack_$TIMESTAMP.zip | cut -f1)"
echo "Mods included: $(ls modpack/client/mods/*.jar 2>/dev/null | wc -l)"
