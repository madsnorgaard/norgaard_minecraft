#!/bin/bash
# Download and prepare popular modpacks

echo "Popular Modpack Downloader"
echo "=========================="
echo "1) Fabric Vanilla+ (Performance & QoL)"
echo "2) Create Mod Pack"
echo "3) Origins Mod Pack"
echo "4) Custom URL"

read -p "Select option: " choice

case $choice in
    1)
        echo "📥 Downloading Vanilla+ mods..."
        mkdir -p modpacks/vanilla-plus/mods
        
        # Add performance mods
        MODS=(
            "https://cdn.modrinth.com/data/AANobbMI/versions/lXeVkLCH/sodium-fabric-0.6.3%2Bmc1.21.5.jar"
            "https://cdn.modrinth.com/data/P7dR8mSH/versions/Lh6g1SkM/fabric-api-0.121.0%2B1.21.5.jar"
            "https://cdn.modrinth.com/data/gvQqBUqZ/versions/vYOEksUL/lithium-fabric-0.16.2%2Bmc1.21.5.jar"
        )
        
        for mod in "${MODS[@]}"; do
            curl -L -o "modpacks/vanilla-plus/mods/$(basename "$mod")" "$mod"
        done
        
        echo "✅ Vanilla+ pack ready in modpacks/vanilla-plus/"
        ;;
    4)
        read -p "Enter modpack URL: " URL
        # Download and extract logic here
        ;;
esac
