# Aurora's Minecraft Kingdom 🏰

Family-friendly Minecraft Java Edition server running in Docker!

## 🎮 Server Information

- **Version**: Minecraft Java Edition 1.21.4
- **Type**: Fabric (modded)
- **Mode**: Creative with keep inventory
- **Address**: theazanianprepper (local) or your-server-ip:25565

## 🚀 Quick Start Guide

### For Server Admin (Dad)

1. **Update the server to 1.21.4**:
```bash
# Backup first!
./scripts/backup.sh

# Update and restart
docker compose down
docker compose pull
docker compose up -d

# Check logs
docker logs minecraft-server -f
```

2. **Monitor server**:
```bash
# View live logs
docker logs minecraft-server -f

# Server console
docker exec -it minecraft-server rcon-cli
```

### For Aurora (Client Setup)

1. **Update Minecraft to 1.21.4**:
   - Open Minecraft Launcher
   - Go to "Installations" tab
   - Click "New Installation"
   - Name it: "Dad's Server 1.21.4"
   - Version: Select "release 1.21.4"
   - Click "Create" and then "Play"

2. **Connect to Server**:
   - Click "Multiplayer"
   - Click "Add Server"
   - Server Name: "Dad's Server"
   - Server Address: `theazanianprepper` (or dad's IP address)
   - Click "Done" and join!

## 🎯 Fun Commands for Aurora

Run these from the terminal (ask Dad!):
```bash
# Party mode!
./scripts/aurora_fun.sh WariarPrncss party

# Spawn pets
./scripts/aurora_fun.sh WariarPrncss pets

# Get treasure
./scripts/aurora_fun.sh WariarPrncss treasure

# Rainbow sheep
./scripts/aurora_fun.sh WariarPrncss rainbow
```

## 👥 Whitelisted Players

- dalordcraft (Dad/Admin)
- WariarPrncss (Aurora)
- auroranorgaard
- oddgepard

## 🛠️ Admin Commands
```bash
# Give Aurora creative mode
docker exec -it minecraft-server rcon-cli gamemode creative WariarPrncss

# Make it daytime
docker exec -it minecraft-server rcon-cli time set day

# Clear weather
docker exec -it minecraft-server rcon-cli weather clear

# Give items
docker exec -it minecraft-server rcon-cli give WariarPrncss diamond_block 64
```

## 📦 Backup & Restore
```bash
# Create backup
./scripts/backup.sh

# Restore backup
./scripts/restore.sh backup_20240607_120000.tar.gz
```

## 🔧 Troubleshooting

- **Can't connect**: Check server is running: `docker ps`
- **Wrong version**: Both client and server must be 1.21.4
- **Lost items**: Items are kept on death (keepInventory is on)

## 📚 Mods

Currently running Fabric with:
- GeckoLib (for animations)

To add more mods, place `.jar` files in `data/mods/` and restart.

## 📦 Latest Modpack

[Download AurorasKingdom-1.21.5
latest-20251123](releases/AurorasKingdom-1.21.5
latest-20251123.zip)
