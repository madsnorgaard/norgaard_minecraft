#!/bin/bash

# Modpack Manager for Minecraft Server
set -e

MODS_DIR="data/mods"
BACKUP_DIR="backups/mods"
MODPACKS_DIR="modpacks"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

function show_menu() {
    echo "================================"
    echo "    Modpack Manager"
    echo "================================"
    echo "1) List current mods"
    echo "2) Backup current modpack"
    echo "3) Import new modpack"
    echo "4) Switch modpack"
    echo "5) Create modpack from current"
    echo "6) Download from CurseForge URL"
    echo "7) Exit"
    echo "================================"
}

function list_mods() {
    echo -e "${GREEN}Current mods:${NC}"
    ls -1 $MODS_DIR/*.jar 2>/dev/null | wc -l
    ls -1 $MODS_DIR/*.jar 2>/dev/null | head -20
    echo "..."
}

function backup_current() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mkdir -p $BACKUP_DIR
    echo -e "${YELLOW}Backing up current modpack...${NC}"
    tar czf "$BACKUP_DIR/modpack_$TIMESTAMP.tar.gz" -C $MODS_DIR .
    echo -e "${GREEN}✓ Backup saved to: $BACKUP_DIR/modpack_$TIMESTAMP.tar.gz${NC}"
}

function import_modpack() {
    echo "Enter path to modpack zip/folder:"
    read -r MODPACK_PATH
    
    if [ ! -e "$MODPACK_PATH" ]; then
        echo -e "${RED}Path not found!${NC}"
        return
    fi
    
    backup_current
    
    echo -e "${YELLOW}Clearing current mods...${NC}"
    rm -f $MODS_DIR/*.jar
    
    if [ -f "$MODPACK_PATH" ]; then
        # It's a file (zip)
        echo -e "${YELLOW}Extracting modpack...${NC}"
        unzip -j "$MODPACK_PATH" "*/mods/*.jar" -d $MODS_DIR/ 2>/dev/null || \
        unzip -j "$MODPACK_PATH" "*.jar" -d $MODS_DIR/ 2>/dev/null
    else
        # It's a directory
        echo -e "${YELLOW}Copying mods...${NC}"
        find "$MODPACK_PATH" -name "*.jar" -exec cp {} $MODS_DIR/ \;
    fi
    
    echo -e "${GREEN}✓ Modpack imported! Restart server to apply.${NC}"
}

function create_modpack() {
    echo "Enter name for this modpack:"
    read -r PACK_NAME
    
    mkdir -p "$MODPACKS_DIR/$PACK_NAME/mods"
    cp $MODS_DIR/*.jar "$MODPACKS_DIR/$PACK_NAME/mods/"
    
    # Create metadata
    cat > "$MODPACKS_DIR/$PACK_NAME/modpack.json" << JSON
{
    "name": "$PACK_NAME",
    "minecraft": "1.21.5",
    "created": "$(date -Iseconds)",
    "mods": $(ls $MODS_DIR/*.jar | wc -l)
}
JSON
    
    echo -e "${GREEN}✓ Modpack saved to: $MODPACKS_DIR/$PACK_NAME${NC}"
}

function switch_modpack() {
    echo "Available modpacks:"
    ls -1 $MODPACKS_DIR 2>/dev/null || echo "No saved modpacks"
    
    echo "Enter modpack name to switch to:"
    read -r PACK_NAME
    
    if [ ! -d "$MODPACKS_DIR/$PACK_NAME" ]; then
        echo -e "${RED}Modpack not found!${NC}"
        return
    fi
    
    backup_current
    rm -f $MODS_DIR/*.jar
    cp "$MODPACKS_DIR/$PACK_NAME/mods/"*.jar $MODS_DIR/
    
    echo -e "${GREEN}✓ Switched to modpack: $PACK_NAME${NC}"
    echo -e "${YELLOW}Restart server to apply changes${NC}"
}

# Main loop
while true; do
    show_menu
    read -p "Select option: " choice
    
    case $choice in
        1) list_mods ;;
        2) backup_current ;;
        3) import_modpack ;;
        4) switch_modpack ;;
        5) create_modpack ;;
        6) echo "Feature coming soon!" ;;
        7) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
