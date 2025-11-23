#!/bin/bash
echo "📦 Creating CurseForge-compatible modpack..."

# Sync mods first
./scripts/sync_modpack.sh

# Create CurseForge manifest
cat > modpack/manifest.json << JSON
{
  "minecraft": {
    "version": "1.21.5",
    "modLoaders": [{
      "id": "fabric-0.18.1",
      "primary": true
    }]
  },
  "manifestType": "minecraftModpack",
  "manifestVersion": 1,
  "name": "Minecraft Server",
  "version": "1.0.0",
  "author": "Dad"
}
JSON

# Create instance config for CurseForge
cat > modpack/minecraftinstance.json << JSON
{
  "baseModLoader": {
    "forgeVersion": "",
    "name": "fabric-0.18.1",
    "type": "fabric",
    "downloadUrl": "https://fabricmc.net/",
    "filename": "fabric-loader-0.18.1-1.21.5.jar",
    "minecraftVersion": "1.21.5"
  },
  "modpackOverrides": [
    "mods"
  ],
  "isUnlocked": true,
  "javaArgsOverride": "-Xmx4G",
  "name": "Minecraft Server",
  "notes": "Dad's Minecraft Server Modpack"
}
JSON

# Create the zip
cd modpack
zip -r ../MinecraftModpack-CurseForge.zip .
cd ..

echo "✅ Created: MinecraftModpack-CurseForge.zip"
echo "📤 This file can be imported directly into CurseForge!"
