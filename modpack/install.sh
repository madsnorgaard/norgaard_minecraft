#!/bin/bash

echo "======================================="
echo "  Minecraft Server Modpack Installer"
echo "======================================="
echo

MC_DIR="$HOME/.minecraft"

# Check Minecraft installation
if [ ! -d "$MC_DIR" ]; then
    echo "ERROR: Minecraft not found! Please install Minecraft first."
    exit 1
fi

# Create mods folder
mkdir -p "$MC_DIR/mods"

# Backup existing mods
if [ -d "$MC_DIR/mods" ] && [ "$(ls -A $MC_DIR/mods)" ]; then
    echo "Backing up existing mods..."
    BACKUP_DIR="$MC_DIR/mods_backup_$(date +%Y%m%d_%H%M%S)"
    cp -r "$MC_DIR/mods" "$BACKUP_DIR"
    echo "Backup saved to: $BACKUP_DIR"
fi

# Copy new mods
echo "Installing Minecraft Server mods..."
cp -r client/mods/* "$MC_DIR/mods/" 2>/dev/null

echo
echo "✅ Installation complete!"
echo
echo "Next steps:"
echo "1. Open Minecraft Launcher"
echo "2. Select 'Fabric 1.21.5' profile"
echo "3. Click Play"
echo "4. Add server: $(cat client/server.txt 2>/dev/null || echo 'Ask for server address')"
echo
