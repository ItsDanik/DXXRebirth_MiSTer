#!/bin/sh
# Package the build and copy it to a MiSTer over ssh.
# usage: MISTER=root@<address> tools/deploy.sh
# The core is not (re)loaded: load DXXRebirth from the menu afterwards. Run
# /media/fat/Scripts/danik_hybrid_cores.sh on the MiSTer once to set up the launcher.
set -e
cd "$(dirname "$0")/.."
HOST=${MISTER:?set MISTER=root@<address of the MiSTer>}
./package.sh > /dev/null
OUT=dist/DXXRebirth_$(date +%Y%m%d)
G=/media/fat/games/DXXRebirth
ssh "$HOST" "mkdir -p $G && rm -f /media/fat/_Other/DXXRebirth_*.rbf"
# a running game keeps its binaries busy: copy next to them, then swap
for f in DXXRebirth d1x-rebirth d2x-rebirth libADLMIDI.so; do
    scp -q "$OUT/games/DXXRebirth/$f" "$HOST:$G/$f.new"
    ssh "$HOST" "mv -f $G/$f.new $G/$f"
done
# everything else of the package (user files on the MiSTer are left alone)
(cd "$OUT/games/DXXRebirth" && tar cf - --exclude=./DXXRebirth --exclude=./d1x-rebirth --exclude=./d2x-rebirth --exclude=./libADLMIDI.so .) |
    ssh "$HOST" "tar xf - --no-same-owner -C $G"
scp -q "$OUT/Scripts/danik_hybrid_cores.sh" "$HOST:/media/fat/Scripts/"
scp -q "$OUT"/_Other/*.rbf "$HOST:/media/fat/_Other/"
ssh "$HOST" "chmod +x $G/DXXRebirth $G/d1x-rebirth $G/d2x-rebirth $G/*.sh /media/fat/Scripts/danik_hybrid_cores.sh; ls -la $G /media/fat/_Other/DXXRebirth_*.rbf"
