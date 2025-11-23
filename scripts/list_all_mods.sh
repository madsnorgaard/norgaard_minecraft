#!/bin/bash

MODS_DIR="data/mods"
TOTAL=$(ls -1 $MODS_DIR/*.jar 2>/dev/null | wc -l)

echo "================================"
echo "   Complete Mod List ($TOTAL mods)"
echo "================================"

# List all mods with numbers
ls -1 $MODS_DIR/*.jar 2>/dev/null | nl -w3 -s'. ' | sed 's|.*/||g' | sed 's|\.jar||g'

echo "================================"
echo "Mod Categories:"
echo "--------------------------------"
echo "Performance: $(ls -1 $MODS_DIR/*{lithium,ferrite,sodium}*.jar 2>/dev/null | wc -l)"
echo "Building: $(ls -1 $MODS_DIR/*{chisel,diagonal,macaw}*.jar 2>/dev/null | wc -l)"
echo "Adventure: $(ls -1 $MODS_DIR/*{dungeon,structure,waystone}*.jar 2>/dev/null | wc -l)"
echo "QoL: $(ls -1 $MODS_DIR/*{jade,jei,appleskin,journeymap}*.jar 2>/dev/null | wc -l)"
echo "================================"
