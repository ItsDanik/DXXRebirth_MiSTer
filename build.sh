#!/bin/sh
# Build Descent and Descent II (DXX-Rebirth) for the MiSTer in the toolchain
# containers: static SDL2 with the hybrid core drivers first (once), then
# PhysFS, SDL2_image and libADLMIDI, the two games and the game list.
# usage: ./build.sh [mister|host] [extra scons options]
#   mister  ARM binaries for the MiSTer   -> build/mister/
#   host    same code for this PC, to run against hybrid/tools/fakecore
# In both: d1x-rebirth/d1x-rebirth, d2x-rebirth/d2x-rebirth, DXXRebirth (the
# list of games, src/dxxrebirth.c) and libADLMIDI.so (the music).
set -e
cd "$(dirname "$0")"
TARGET=${1:-mister}
[ $# -gt 0 ] && shift
ROOT=$PWD
PREFIX=$ROOT/build/sdl/$TARGET/prefix

hybrid/docker.sh hybrid/sdl2/build.sh "$TARGET" build/sdl

# GAME: DXX-Rebirth needs gcc 14 and Python 3.10, see toolchain/Dockerfile
docker image inspect mister-dxxrebirth-tc > /dev/null 2>&1 || docker build -t mister-dxxrebirth-tc toolchain
tc() {
    docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -v "$ROOT":"$ROOT" -w "$ROOT" mister-dxxrebirth-tc "$@"
}
tc tools/deps.sh "$TARGET" build/sdl

if [ "$TARGET" = mister ]; then
    CROSS=arm-linux-gnueabihf-
    # No auto-vectorization: gcc 14.3 turns "v.x >>= n; v.y >>= n;" into a NEON
    # shift by 0 (check_vec in common/maths/vecmat.cpp), which gives the level
    # geometry wrong surface normals. tools/deps.sh does the same.
    ARCH="-mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard -fno-pie -fno-tree-vectorize"
    # the compiler's runtime is linked in, the binaries only need the MiSTer's glibc
    LINK="-no-pie -static-libstdc++ -static-libgcc"
else
    CROSS=
    ARCH=
    LINK="-static-libstdc++ -static-libgcc"
fi

# GAME: the software renderer on SDL2, the MiSTer code (mister_hybrid=1), music
# by libADLMIDI (loaded at run time), no network tracker, no screenshots as PNG
tc sh -c "
  cd dxxrebirth &&
  PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig PKG_CONFIG_PATH= scons -j\$(nproc) builddir=../build/$TARGET \
    CXX=${CROSS}g++ CXXFLAGS='-O2 $ARCH' LINKFLAGS='$LINK' host_platform=linux \
    sdl2=1 opengl=0 mister_hybrid=1 sdlimage=1 sdlmixer=1 adlmidi=runtime \
    use_tracker=0 ipv6=0 screenshot=none verbosebuild=0 $* ../build/$TARGET &&
  cd .. &&
  ${CROSS}gcc -O2 $ARCH -Wall -Ihybrid/hps -o build/$TARGET/DXXRebirth src/dxxrebirth.c \
    hybrid/hps/mister_hybrid.c hybrid/hps/mister_ui.c hybrid/hps/mister_joymap.c -lpthread"
cp "$PREFIX/lib/libADLMIDI.so" "build/$TARGET/libADLMIDI.so"
ls -la "build/$TARGET/d1x-rebirth/d1x-rebirth" "build/$TARGET/d2x-rebirth/d2x-rebirth" \
    "build/$TARGET/DXXRebirth" "build/$TARGET/libADLMIDI.so"
