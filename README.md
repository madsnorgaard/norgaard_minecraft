# Minecraft Server 1.21.5

Dockerized Minecraft server with automated modpack distribution system.

## Features
- 🐳 Docker-based server deployment
- 📦 Automatic modpack generation
- 🎮 CurseForge integration
- 💾 Automated backups
- 🎯 Fun player commands
- 🔧 50+ pre-configured mods

## Quick Start

### Server Setup
```bash
# Clone repository
git clone https://github.com/yourusername/minecraft-server.git
cd minecraft-server

# Configure environment
cp .env.example .env

# Start server
docker compose up -d
```

### Modpack Distribution
```bash
# Generate modpack for players
./scripts/sync_modpack.sh

# Create CurseForge package
./scripts/create_curseforge_pack.sh
```

## Player Setup

1. Install [CurseForge](https://www.curseforge.com/download/app)
2. Import the modpack zip file
3. Launch Minecraft through CurseForge
4. Connect to server

## Configuration

Edit `docker-compose.yml` to customize:
- Server name
- Game mode
- Difficulty
- Player limits

## Scripts

- `backup.sh` - Backup world data
- `sync_modpack.sh` - Sync server mods to client pack
- `player_fun.sh` - Fun commands for players
- `create_curseforge_pack.sh` - Create CurseForge import

## Requirements

- Docker & Docker Compose
- Minecraft Java Edition 1.21.5
- Fabric Loader

## License

MIT
