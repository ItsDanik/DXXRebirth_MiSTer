# DXXRebirth for MiSTer: notes

How the port works and how it is built. For playing it, see the [README](README.md).

## Building

Everything builds in Docker on a Linux PC.

```sh
git clone --recursive https://github.com/ItsDanik/DXXRebirth_MiSTer.git
cd DXXRebirth_MiSTer
./build.sh              # ARM game binaries -> build/mister/
./core/build_core.sh    # FPGA core (Quartus Lite 17.0.2) -> core/output_files/DXXRebirth.rbf
./package.sh            # release zip      -> dist/DXXRebirth_YYYYMMDD.zip
```

The toolchain image (Debian bullseye, glibc 2.31 to match the MiSTer) is built from `hybrid/toolchain/` on first use. DXX-Rebirth needs a newer compiler (gcc 14) and Python than that image has, so a second image is built from `toolchain/`: it has a gcc 14 cross compiler built against the same glibc 2.31, which takes a while the first time. The first build also downloads and builds SDL2, SDL2_mixer and SDL2_net (`hybrid/sdl2/build.sh`), PhysFS, SDL2_image and libADLMIDI (`tools/deps.sh`, which patches libADLMIDI so that its OPL2's register writes can go to the core's FM chip: `tools/libadlmidi-mister.patch`).

### Repository layout

| Path | |
|---|---|
| `hybrid/` | submodule: [ItsDanik/Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), what all our hybrid ports share: the FPGA host module, the ARM side library, SDL2 drivers, the launcher (`danik_hybrid_ports.sh`), toolchain and conventions. See its README. |
| `core/` | FPGA core, based on [Template_MiSTer](https://github.com/MiSTer-devel/Template_MiSTer): `DXXRebirth.sv` (OSD and button names) around `hybrid/rtl/hybrid_host.sv` |
| `dxxrebirth/` | submodule: the game, branch `mister`, with the MiSTer changes (SCons option `mister_hybrid=1`) and the software renderer on SDL2 |
| `src/dxxrebirth.c` | `DXXRebirth`, the program the launcher starts: picks the game (the menu entry's, or from the list), then becomes `d1x-rebirth` or `d2x-rebirth` |
| `toolchain/` | Docker image with gcc 14 for the MiSTer |
| `tools/deps.sh` | builds PhysFS, SDL2_image and libADLMIDI |
| `package/` | files shipped in the release next to the binaries (`danik_hybrid_launch.sh`, README), `games.txt`: the games and their menu entries, and `logos/`: each game's logo |
| `releases/` | release packages |

### Development notes

- `./build.sh host` builds the same games for the PC. They run against `hybrid/tools/fakecore`, a stand-in for the FPGA core that takes scripted input and saves screenshots and audio:
  ```sh
  gcc -O2 -o build/host/fakecore hybrid/tools/fakecore.c -lm
  build/host/fakecore /tmp/shm script.txt audio.raw &
  MISTER_HYBRID_SHM=/tmp/shm LD_LIBRARY_PATH=build/host D1X_REBIRTH_HOME=/tmp/d1 \
      build/host/d1x-rebirth/d1x-rebirth -hogdir <data folder>
  ```
- The ARM binaries run on the PC under `qemu-arm` too (with the toolchain image's `/opt/mister-sysroot` as `QEMU_LD_PREFIX`), against the same fakecore. That is how the compiler bug named in `build.sh` was found.
- `MISTER=root@<address> tools/test_on_mister.sh <d1|d2>` tries the build on a MiSTer next to what is installed there, without installing it: from `/tmp`, with the installed game's folder mirrored there (what the game writes stays in `/tmp`) and its own OSD settings. `list` and `nodata` for the core started by itself and without data, `log` for the game's log, `stop` to remove all of it again.
- `MISTER_HYBRID_STATS=1` in the environment of the game (`danik_hybrid_launch.sh`) puts frame and audio timing in the log: fields per frame, time per frame, every late frame. `hybrid/tools/fbmon.c` watches from outside whether every field got a new frame.
- `touch /tmp/dxxrebirth_nolaunch` on the MiSTer keeps the core loaded without starting the game, so you can start a development binary by hand (set `MISTER_HYBRID_CORE=DXXRebirth`, and `MISTER_HYBRID_SET` for a game's set name). `/tmp/danik_hybrid_ports.log` shows what the launcher daemon did.
