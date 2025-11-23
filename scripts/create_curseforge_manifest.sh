#!/bin/bash
echo "Creating CurseForge modpack manifest..."

# List all mods
ls -1 data/mods/*.jar > mod_list.txt

cat > manifest.json << 'JSON'
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
  "name": "Minecraft Server Mods",
  "version": "1.0.0",
  "author": "Dad"
}
JSON

echo "✅ Created manifest.json"
echo "📝 Mods to add manually in CurseForge:"
cat mod_list.txt
