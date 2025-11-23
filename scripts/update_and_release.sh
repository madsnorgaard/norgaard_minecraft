#!/bin/bash
# Complete update and release process

echo "🚀 Aurora's Kingdom Update Script"
echo "================================="

# 1. Sync modpack
./scripts/sync_modpack.sh

# 2. Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Server IP: $SERVER_IP:25565" > modpack/client/server.txt

# 3. Create release package
VERSION=$(grep 'VERSION:' docker-compose.yml | cut -d'"' -f2)
RELEASE_NAME="AurorasKingdom-$VERSION-$(date +%Y%m%d)"

cd modpack
zip -r "../releases/$RELEASE_NAME.zip" .
cd ..

echo "✅ Release created: releases/$RELEASE_NAME.zip"

# 4. Update README with download link
cat >> README.md << README

## 📦 Latest Modpack

[Download $RELEASE_NAME](releases/$RELEASE_NAME.zip)
README

# 5. Commit and push
git add .
git commit -m "Release modpack $VERSION"
git push

echo "🎉 Complete! Modpack ready for distribution"
