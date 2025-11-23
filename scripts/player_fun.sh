#!/bin/bash

PLAYER=${1:-Player1}
CMD=$2

run_cmd() {
    docker exec -it minecraft-server rcon-cli "$@"
}

case "$CMD" in
    party)
        echo "🎉 PARTY MODE ACTIVATED!"
        run_cmd effect give $PLAYER minecraft:jump_boost 60 3
        run_cmd effect give $PLAYER minecraft:speed 60 2
        run_cmd effect give $PLAYER minecraft:glowing 60 1
        for i in {1..5}; do
            run_cmd execute at $PLAYER run summon firework_rocket ~ ~2 ~ {LifeTime:30,FireworksItem:{id:"firework_rocket",Count:1,tag:{Fireworks:{Explosions:[{Type:1,Flicker:1,Trail:1,Colors:[I;11743532,15435844,14602026]}]}}}}
            sleep 0.5
        done
        run_cmd title $PLAYER title {"text":"PARTY TIME!","color":"gold","bold":true}
        ;;
    
    pets)
        echo "🐾 Spawning adorable pets!"
        run_cmd execute at $PLAYER run summon cat ~2 ~ ~ {Owner:"$PLAYER",CatType:0}
        run_cmd execute at $PLAYER run summon wolf ~-2 ~ ~ {Owner:"$PLAYER",CollarColor:14}
        run_cmd execute at $PLAYER run summon parrot ~ ~ ~2 {Variant:0}
        run_cmd execute at $PLAYER run summon parrot ~ ~ ~-2 {Variant:4}
        run_cmd say "§d$PLAYER's pets have arrived!"
        ;;
    
    treasure)
        echo "💎 Treasure incoming!"
        run_cmd give $PLAYER diamond_block 10
        run_cmd give $PLAYER emerald_block 10
        run_cmd give $PLAYER gold_block 10
        run_cmd give $PLAYER netherite_ingot 5
        run_cmd playsound minecraft:entity.player.levelup player $PLAYER
        run_cmd title $PLAYER title {"text":"TREASURE!","color":"aqua","bold":true}
        ;;
    
    rainbow)
        echo "🌈 Rainbow sheep party!"
        for i in {1..7}; do
            run_cmd execute at $PLAYER run summon sheep ~$i ~ ~ {CustomName:'"jeb_"',Age:-999999}
        done
        run_cmd say "§dLook at the rainbow sheep dance!"
        ;;
    
    fly)
        echo "🦋 Flying powers activated!"
        run_cmd effect give $PLAYER minecraft:levitation 15 2
        run_cmd effect give $PLAYER minecraft:slow_falling 120 1
        run_cmd effect give $PLAYER minecraft:jump_boost 120 5
        run_cmd title $PLAYER subtitle {"text":"Jump to fly!","color":"aqua"}
        run_cmd title $PLAYER title {"text":"FLY MODE","color":"gold","bold":true}
        ;;
    
    super)
        echo "⚡ SUPER AURORA MODE!"
        run_cmd effect give $PLAYER minecraft:speed 300 2
        run_cmd effect give $PLAYER minecraft:jump_boost 300 3
        run_cmd effect give $PLAYER minecraft:strength 300 5
        run_cmd effect give $PLAYER minecraft:regeneration 300 2
        run_cmd effect give $PLAYER minecraft:resistance 300 2
        run_cmd give $PLAYER minecraft:elytra{Unbreakable:1b}
        run_cmd give $PLAYER minecraft:firework_rocket 64
        run_cmd title $PLAYER title {"text":"SUPER MODE!","color":"red","bold":true,"italic":true}
        ;;
        
    clear)
        echo "🧹 Clearing effects..."
        run_cmd effect clear $PLAYER
        ;;
        
    *)
        echo "✨ Player's Fun Commands ✨"
        echo ""
        echo "Usage: $0 [player] {command}"
        echo ""
        echo "Commands:"
        echo "  party    - Party effects and fireworks!"
        echo "  pets     - Spawn cute pets"
        echo "  treasure - Get treasure blocks"
        echo "  rainbow  - Spawn rainbow sheep"
        echo "  fly      - Temporary flying powers"
        echo "  super    - SUPER AURORA MODE!"
        echo "  clear    - Remove all effects"
        echo ""
        echo "Example: $0 Player1 party"
        ;;
esac
