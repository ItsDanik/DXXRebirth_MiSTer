# DXXRebirth hybrid core for MiSTer (Descent and Descent II)

@hybrid/CLAUDE.md

## This core

- Name everywhere: `DXXRebirth` (core, folders, release), `dxxrebirth` (game submodule, log, lock). The user asked for "DXX-Rebirth"; `new_core.sh` takes no hyphen.
- The game is `dxxrebirth/`, branch `mister` (upstream dxx-rebirth master). Its MiSTer code is behind the SCons option `mister_hybrid=1` (`DXX_USE_MISTER_HYBRID`), most of it in `common/arch/mister/mister_port.cpp`. Until the fork `ItsDanik/dxx-rebirth` exists it is a plain clone, not a submodule.
- Build: `./build.sh` (game), `./core/build_core.sh` (FPGA), `./package.sh` (zip in `dist/`), `MISTER=root@<address> tools/deploy.sh`.
- Lines marked `GAME:` in the scripts and `TODO` in the READMEs are the places the template left for this game.

<!-- Notes that are only true for this game go below. -->

## Only this game

- Two games, three binaries: `DXXRebirth` (`src/dxxrebirth.c`) is what the launcher starts; it shows the list of games if both have data and execs `d1x-rebirth` or `d2x-rebirth`. Data is in `/media/fat/games/d1x-rebirth` and `/media/fat/games/d2x-rebirth` (the user's choice, not `games/DXXRebirth/`); what the games write is in `games/DXXRebirth/descent` and `descent2`.
- The build is SCons, not CMake, and needs gcc 14 and Python 3.10: `toolchain/Dockerfile` (image `mister-dxxrebirth-tc`) has a gcc 14.3 cross compiler built against the glibc 2.31 of the hybrid toolchain. `tools/deps.sh` builds PhysFS, SDL2_image and libADLMIDI.
- The ARM build has `-fno-tree-vectorize`: gcc 14.3 miscompiles a NEON shift in `check_vec` (vecmat.cpp), which breaks the level geometry. Keep it unless a newer compiler is verified.
- Upstream only has the software renderer for SDL 1.2; `similar/arch/sdl/gr.cpp` has our SDL2 path. Upstream master is not tested with the software renderer or the shareware data: several fixes in the fork are for that, not for the MiSTer.
- The game's clock is the core's field counter (`MiSTer_RunTime` in `timer_update`). The game has wait loops on that clock, so `MiSTer_RunTime` also checks that the core is alive and leaves with `_Exit` if not.
- Speed: the Cortex-A9 has no divide instruction. `c_tmap_scanline_per_span` (scanline.cpp, the default here, `-tmap c` is upstream's) divides once per 16 pixels instead of twice per pixel, and `fixdiv` uses the FPU with an exact correction on ARM. Before adding a division to anything that runs per pixel, per vertex or per object, think of that.
- Profiling for ARM without a MiSTer: a `-pg` build (`lto=0`) run under `qemu-arm` with a script that quits through the menus (gmon.out is not written on `_Exit`), then `arm-linux-gnueabihf-gprof`. qemu's time follows the instruction count, software division included, so it shows what x86 profiles hide. First user report on hardware: 30-40 fps before the span mapper.
- Loading the core again while a game runs: `MH_CoreReloaded()` and exit code 43, which `danik_hybrid_launch.sh` answers by starting `DXXRebirth` again.
- Descent II movies: frames are drawn (and the 640x480 ones scaled) by `MovieShowFrame` in movie.cpp, not by `gr_bm_ubitbltm`, which calls two functions per pixel. The movie sound must wrap at 16 bits (`processSwath`, mve_audio.cpp). The retail data to test with is in `~/.d2x-rebirth` on the user's PC (high resolution movies only); never copy it into the repository.
- Measuring on the MiSTer (see the memory note for its address): `MISTER_HYBRID_STATS=1` in the environment makes the game log, every 600 frames, how many fields each frame took and how long it worked, every late frame with what it waited for, and (from `hybrid/hps`) how full the audio ring stayed. `hybrid/tools/fbmon.c` shows from outside whether every field got a new frame. A `-pg -DDXX_MISTER_PROFILE` build (`build/armpg.sh` in the build folder is the recipe) run by hand with `/tmp/dxxrebirth_nolaunch` set writes `gmon.out` when the core is unloaded. Measured on 2026-10-05: a frame of Descent level 1 takes about 5 ms, a menu frame took 10 ms before the menu fixes.
- Things that stalled frames and must stay cheap: sounds are converted when first played (`-sdlmixer-resampler=`; the default here is `emulate-sdl1`, SDL's own converter took 50-100 ms per sound), the menus load the palette every frame (`gr_palette_load`, `gr_remap_color_fonts`), and a frame of the game waits for its field at its start (`MiSTer_WaitFrame`), not when it is shown.
- Testing without a MiSTer: `./build.sh host` with `hybrid/tools/fakecore`, and the ARM binaries under `qemu-arm` in the toolchain image (`QEMU_LD_PREFIX=/opt/mister-sysroot`). The shareware data of both games is free (icculus.org/d2x/data).
