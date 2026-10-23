#!/bin/sh
# Build the libraries DXX-Rebirth needs besides the SDL2 of hybrid/sdl2: PhysFS
# and SDL2_image (PCX only, for the title and menu screens) as static
# libraries, and libADLMIDI (the music: MIDI played by an emulated OPL3, as a
# Sound Blaster did) as the shared library the game loads at run time.
# Runs inside the toolchain container (see build.sh), after hybrid/sdl2/build.sh.
# usage: deps.sh <mister|host> <work directory>
#   libraries and headers end up in <work directory>/<target>/prefix
set -e
TARGET=$1
WORK=$(mkdir -p "$2" && cd "$2" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)

PHYSFS=physfs-release-3.2.0
IMAGE=SDL2_image-2.8.8
ADLMIDI=libADLMIDI-1.6.2.1

fetch() { # <tarball> <url> <sha256>
    [ -f "$WORK/dl/$1" ] || curl -fsSL -o "$WORK/dl/$1" "$2"
    echo "$3  $WORK/dl/$1" | sha256sum -c - > /dev/null
}
mkdir -p "$WORK/dl" "$WORK/src"
fetch $PHYSFS.tar.gz https://github.com/icculus/physfs/archive/refs/tags/release-3.2.0.tar.gz \
    1991500eaeb8d5325e3a8361847ff3bf8e03ec89252b7915e1f25b3f8ab5d560
fetch $IMAGE.tar.gz https://github.com/libsdl-org/SDL_image/releases/download/release-2.8.8/$IMAGE.tar.gz \
    2213b56fdaff2220d0e38c8e420cbe1a83c87374190cba8c70af2156097ce30a
fetch $ADLMIDI.tar.gz https://github.com/Wohlstand/libADLMIDI/archive/refs/tags/v1.6.2.1.tar.gz \
    e01aec7b2bc284476eedab77a8b6e177c5beda2bc2f4545166339badfc0464c5
for p in $PHYSFS $IMAGE $ADLMIDI; do
    [ -d "$WORK/src/$p" ] || tar -xzf "$WORK/dl/$p.tar.gz" -C "$WORK/src"
done

PREFIX=$WORK/$TARGET/prefix
COMMON="-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
if [ "$TARGET" = mister ]; then
    COMMON="$COMMON -DCMAKE_TOOLCHAIN_FILE=$ROOT/hybrid/toolchain/mister.cmake -DCMAKE_FIND_ROOT_PATH=$PREFIX"
    # gcc 14.3 miscompiles vectorized shifts for NEON, see build.sh. CMake
    # puts these in front of the flags of the toolchain file.
    export CFLAGS=-fno-tree-vectorize CXXFLAGS=-fno-tree-vectorize
fi
JOBS=$(nproc)

# HOG and MVL are the archives of the games, .dxa add-ons are ZIP
cmake -S "$WORK/src/$PHYSFS" -B "$WORK/$TARGET/$PHYSFS" $COMMON \
    -DPHYSFS_BUILD_SHARED=OFF -DPHYSFS_BUILD_STATIC=ON -DPHYSFS_BUILD_TEST=OFF -DPHYSFS_BUILD_DOCS=OFF \
    -DPHYSFS_ARCHIVE_ZIP=ON -DPHYSFS_ARCHIVE_7Z=OFF -DPHYSFS_ARCHIVE_GRP=OFF -DPHYSFS_ARCHIVE_WAD=OFF \
    -DPHYSFS_ARCHIVE_HOG=ON -DPHYSFS_ARCHIVE_MVL=ON -DPHYSFS_ARCHIVE_QPAK=OFF -DPHYSFS_ARCHIVE_SLB=OFF \
    -DPHYSFS_ARCHIVE_ISO9660=OFF -DPHYSFS_ARCHIVE_VDF=OFF > "$WORK/$TARGET/$PHYSFS.log" 2>&1
cmake --build "$WORK/$TARGET/$PHYSFS" -j"$JOBS" >> "$WORK/$TARGET/$PHYSFS.log" 2>&1
cmake --install "$WORK/$TARGET/$PHYSFS" >> "$WORK/$TARGET/$PHYSFS.log"

cmake -S "$WORK/src/$IMAGE" -B "$WORK/$TARGET/$IMAGE" $COMMON \
    -DSDL2IMAGE_SAMPLES=OFF -DSDL2IMAGE_TESTS=OFF -DSDL2IMAGE_DEPS_SHARED=OFF -DSDL2IMAGE_VENDORED=OFF \
    -DSDL2IMAGE_BACKEND_STB=OFF -DSDL2IMAGE_AVIF=OFF -DSDL2IMAGE_GIF=OFF -DSDL2IMAGE_JPG=OFF \
    -DSDL2IMAGE_JXL=OFF -DSDL2IMAGE_LBM=OFF -DSDL2IMAGE_PNG=OFF -DSDL2IMAGE_PNM=OFF -DSDL2IMAGE_QOI=OFF \
    -DSDL2IMAGE_SVG=OFF -DSDL2IMAGE_TGA=OFF -DSDL2IMAGE_TIF=OFF -DSDL2IMAGE_WEBP=OFF -DSDL2IMAGE_XCF=OFF \
    -DSDL2IMAGE_XPM=OFF -DSDL2IMAGE_XV=OFF -DSDL2IMAGE_BMP=ON -DSDL2IMAGE_PCX=ON > "$WORK/$TARGET/$IMAGE.log" 2>&1
cmake --build "$WORK/$TARGET/$IMAGE" -j"$JOBS" >> "$WORK/$TARGET/$IMAGE.log" 2>&1
cmake --install "$WORK/$TARGET/$IMAGE" >> "$WORK/$TARGET/$IMAGE.log"

# Only the DOSBox OPL3 emulator: the others are too slow for the MiSTer's ARM.
# The C++ runtime is linked in, as in the game.
cmake -S "$WORK/src/$ADLMIDI" -B "$WORK/$TARGET/$ADLMIDI" $COMMON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SHARED_LINKER_FLAGS="-static-libstdc++ -static-libgcc" \
    -DlibADLMIDI_SHARED=ON -DlibADLMIDI_STATIC=OFF -DWITH_MIDIPLAY=OFF -DWITH_VLC_PLUGIN=OFF \
    -DWITH_EMBEDDED_BANKS=ON -DWITH_GENADLDATA=OFF -DWITH_HQ_RESAMPLER=OFF \
    -DUSE_DOSBOX_EMULATOR=ON -DUSE_NUKED_EMULATOR=OFF -DUSE_OPAL_EMULATOR=OFF -DUSE_JAVA_EMULATOR=OFF \
    -DUSE_ESFMU_EMULATOR=OFF -DUSE_MAME_EMULATOR=OFF -DUSE_YMFM_EMULATOR=OFF -DUSE_NUKED_OPL2_LLE_EMULATOR=OFF \
    -DUSE_NUKED_OPL3_LLE_EMULATOR=OFF -DUSE_HW_SERIAL=OFF > "$WORK/$TARGET/$ADLMIDI.log" 2>&1
cmake --build "$WORK/$TARGET/$ADLMIDI" -j"$JOBS" >> "$WORK/$TARGET/$ADLMIDI.log" 2>&1
cmake --install "$WORK/$TARGET/$ADLMIDI" >> "$WORK/$TARGET/$ADLMIDI.log"

echo "PhysFS, SDL2_image and libADLMIDI for $TARGET installed in $PREFIX"
