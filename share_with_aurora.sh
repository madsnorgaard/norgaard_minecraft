#!/bin/bash
echo "📦 Creating Aurora's modpack..."

# Sync latest
./scripts/sync_modpack.sh

# Create timestamped package
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cd modpack
zip -r ../AurorasKingdom_$TIMESTAMP.zip .
cd ..

echo "✅ Created: AurorasKingdom_$TIMESTAMP.zip"
echo "📤 Share this file with Aurora!"
echo ""
echo "Size: $(du -h AurorasKingdom_$TIMESTAMP.zip | cut -f1)"
echo "Mods included: $(ls modpack/client/mods/*.jar 2>/dev/null | wc -l)"
