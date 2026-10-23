#!/bin/sh
# Assemble the MiSTer release in dist/DXXRebirth_<date>/ from the build outputs
set -e
cd "$(dirname "$0")"
ROOT=$PWD
DATE=$(date +%Y%m%d)
OUT=dist/DXXRebirth_$DATE
rm -rf "$OUT"
mkdir -p "$OUT/_Other" "$OUT/games/DXXRebirth" "$OUT/Scripts"
cp hybrid/launcher/danik_hybrid_cores.sh "$OUT/Scripts/danik_hybrid_cores.sh"
# a copy with the game too: the daemon installs the newest one it finds
cp hybrid/launcher/danik_hybrid_cores.sh "$OUT/games/DXXRebirth/danik_hybrid_cores.sh"
cp core/output_files/DXXRebirth.rbf "$OUT/_Other/DXXRebirth_$DATE.rbf"
cp -r package/games/DXXRebirth/. "$OUT/games/DXXRebirth/"
# GAME: DXXRebirth is the list of games, the two games and the music library
# are next to it (never game data)
cp build/mister/DXXRebirth "$OUT/games/DXXRebirth/DXXRebirth"
cp build/mister/d1x-rebirth/d1x-rebirth build/mister/d2x-rebirth/d2x-rebirth build/mister/libADLMIDI.so "$OUT/games/DXXRebirth/"
(cd "$OUT/games/DXXRebirth" && "$ROOT/hybrid/docker.sh" arm-linux-gnueabihf-strip DXXRebirth d1x-rebirth d2x-rebirth libADLMIDI.so)
chmod +x "$OUT/games/DXXRebirth/DXXRebirth" "$OUT/games/DXXRebirth/d1x-rebirth" "$OUT/games/DXXRebirth/d2x-rebirth" \
    "$OUT"/games/DXXRebirth/*.sh "$OUT/Scripts/danik_hybrid_cores.sh"
# GAME: the licenses of the game and of what is linked into it or shipped with it
cp dxxrebirth/COPYING.txt "$OUT/games/DXXRebirth/LICENSE-dxxrebirth.txt"
cp dxxrebirth/GPL-3.txt "$OUT/games/DXXRebirth/LICENSE-dxxrebirth-gpl3.txt"
cp build/sdl/src/physfs-release-*/LICENSE.txt "$OUT/games/DXXRebirth/LICENSE-physfs.txt"
cp build/sdl/src/SDL2_image-*/LICENSE.txt "$OUT/games/DXXRebirth/LICENSE-sdl_image.txt"
cp build/sdl/src/SDL2_mixer-*/LICENSE.txt "$OUT/games/DXXRebirth/LICENSE-sdl_mixer.txt"
cp build/sdl/src/libADLMIDI-*/LICENSE "$OUT/games/DXXRebirth/LICENSE-libadlmidi.txt"
cp build/sdl/src/SDL2-*/LICENSE.txt "$OUT/games/DXXRebirth/LICENSE-sdl.txt"
cp LICENSE "$OUT/games/DXXRebirth/LICENSE-gpl3.txt"
rm -f "dist/DXXRebirth_$DATE.zip"
(cd "$OUT" && python3 -m zipfile -c "../DXXRebirth_$DATE.zip" _Other games Scripts)
find "$OUT" -type f | sort
ls -la "dist/DXXRebirth_$DATE.zip"
