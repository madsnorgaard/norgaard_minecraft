#!/bin/bash
# Quick script to add a single mod

MOD_FILE="$1"
MODS_DIR="data/mods"

if [ -z "$MOD_FILE" ]; then
    echo "Usage: $0 <mod.jar or download-url>"
    exit 1
fi

# If it's a URL, download it
if [[ "$MOD_FILE" =~ ^https?:// ]]; then
    echo "📥 Downloading mod..."
    FILENAME=$(basename "$MOD_FILE")
    curl -L -o "/tmp/$FILENAME" "$MOD_FILE"
    MOD_FILE="/tmp/$FILENAME"
fi

# Check if file exists
if [ ! -f "$MOD_FILE" ]; then
    echo "❌ File not found: $MOD_FILE"
    exit 1
fi

# Copy to mods folder
cp "$MOD_FILE" "$MODS_DIR/"
echo "✅ Mod added: $(basename "$MOD_FILE")"
echo "🔄 Restart server to load the new mod"

# Update modpack
./scripts/sync_modpack.sh
