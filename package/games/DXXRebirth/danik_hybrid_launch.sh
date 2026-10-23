#!/bin/bash
#
# DXXRebirth (Descent and Descent II) launcher. danik_hybrid_cores (Scripts/danik_hybrid_cores.sh)
# runs it when the DXXRebirth core is loaded and stops it, with SIGTERM to the
# process group, when another core is loaded.
#
# Laid out after the per-core handlers of MiSTer Frontier by MiSTer Organize
# (https://github.com/MiSTerOrganize/MiSTer_Frontier, GPL-3.0), with thanks
# for the inspiration. Licensed under the GPL-3.0.

CORE="DXXRebirth"
GAMEDIR="/media/fat/games/$CORE"
LOGDIR="/media/fat/logs/$CORE"
LOG="$LOGDIR/dxxrebirth.log"

cd "$GAMEDIR" || exit 1
mkdir -p "$LOGDIR" descent descent2

# Only once
exec 9> /tmp/dxxrebirth.lock
flock -n 9 || exit 0

# Development: keep the core loaded without starting the game
[ -f /tmp/dxxrebirth_nolaunch ] && exit 0

# FPGA settle after the core was just loaded
sleep 1

mv -f "$LOG" "$LOGDIR/dxxrebirth.prev.log" 2>/dev/null

# For the hybrid core drivers in the binary: which core to attach to and its
# default button mapping ("jn" in core/DXXRebirth.sv)
export MISTER_HYBRID_CORE="$CORE"
export MISTER_HYBRID_JN="Y,X,B,A,L,R,Select,Start"
# GAME: the data of Descent and Descent II, in folders of their own
export DXX_D1_DATA="/media/fat/games/d1x-rebirth"
export DXX_D2_DATA="/media/fat/games/d2x-rebirth"
# Everything the games write (settings, pilots, saved games, demos) stays in
# the core's folder, one folder for each game
export HOME="$GAMEDIR"
export D1X_REBIRTH_HOME="$GAMEDIR/descent"
export D2X_REBIRTH_HOME="$GAMEDIR/descent2"
export DXX_LAST_GAME="$GAMEDIR/last_game"
# libADLMIDI.so (the music) is next to the binaries
export LD_LIBRARY_PATH="$GAMEDIR"

# Both CPUs: the game takes CPU0 (better DDR3 bandwidth, Main_MiSTer lives on
# CPU1) and runs audio and the frame copy on CPU1. Everything else on the
# MiSTer (scripts, daemons, interrupts) lands on CPU0 as well: without the
# higher priority the game waits for it a quarter of the time and misses fields.
# Exit code 42: the player quit a game picked from a list (MH_UI_Menu), start
# again to show the list. Exit code 43: the core was loaded again while the
# game ran (MH_CoreReloaded), start again once it has settled, unless it was
# another core after all.
GAME=
# The game must not outlive us: on SIGTERM it saves its settings and quits
trap '[ -n "$GAME" ] && kill "$GAME" 2>/dev/null; exit 0' TERM INT
while :; do
    # GAME: DXXRebirth shows the list of games if both have their data, then
    # becomes d1x-rebirth or d2x-rebirth
    nice -n -20 taskset 0x03 ./DXXRebirth >> "$LOG" 2>&1 &
    GAME=$!
    wait "$GAME"
    RC=$?
    if [ $RC -eq 43 ]; then
        sleep 1
        grep -q "^$CORE" /tmp/CORENAME 2>/dev/null || break
    elif [ $RC -ne 42 ]; then
        break
    fi
done
GAME=

# Back to the MiSTer menu, unless another core was loaded meanwhile
if grep -q "^$CORE" /tmp/CORENAME 2>/dev/null; then
    echo "load_core /media/fat/menu.rbf" > /dev/MiSTer_cmd
fi
