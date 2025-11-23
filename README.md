# Minecraft Server 1.21.5 - Dockerized with Modpack Management

A complete Minecraft server setup with 90+ mods, automated modpack distribution, and easy management tools.

## Features
- 🐳 Docker-based server deployment
- 📦 90+ carefully selected mods
- 🎮 Automatic modpack generation for CurseForge
- 💾 Backup and restore functionality
- 🔧 Easy mod management system

## Quick Start

### Server Setup
```bash
git clone https://github.com/madsnorgaard/norgaard_minecraft.git
cd norgaard_minecraft
cp .env.example .env
docker compose up -d
```

### Player Setup
1. Download latest modpack from [Releases](https://github.com/madsnorgaard/norgaard_minecraft/releases)
2. Import to CurseForge
3. Connect to `your-server-ip:25565`

## Server Management

### Modpack Manager
```bash
./scripts/modpack_manager.sh  # Interactive mod management
./scripts/backup.sh           # Backup world
./scripts/sync_modpack.sh     # Update modpack
```

## Mod List
See [MOD_LIST.md](MOD_LIST.md) for complete list of 90 included mods.

## Requirements
- Docker & Docker Compose
- 10GB+ RAM recommended
- Minecraft Java Edition 1.21.5
- Fabric Loader 0.18.1

## License
MIT
