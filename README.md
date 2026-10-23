# DXXRebirth for MiSTer

Descent and Descent II on [MiSTer FPGA](https://github.com/MiSTer-devel/Main_MiSTer/wiki) as a hybrid core.

The games themselves are [DXX-Rebirth](https://www.dxx-rebirth.com/) (D1X-Rebirth and D2X-Rebirth), the source port of the Descent and Descent II engines, with its software renderer. They run on the MiSTer's ARM CPU. The DXXRebirth FPGA core provides native 15kHz video (CRT, VGA and HDMI) at 320x200, 44.1kHz audio and keyboard, mouse and gamepad input. The two halves talk through shared DDR3 memory.

> **Beta.** Expect rough edges and please report problems in the issues.

Disclaimer: AI is being used to speed up development of this project.

## Requirements

- **danik_hybrid_cores**, the launcher that comes in the release zip (`Scripts/danik_hybrid_cores.sh`): run it **once** from the MiSTer's `Scripts` menu. It starts the game whenever the core is loaded, keeps running after a reboot, and serves all our hybrid cores. Every hybrid core brings the launcher along and the newest version is the one that runs, so it never has to be run again after an update. Without it the core only shows colour bars.
- **Game data**, which is not included: your own copy of Descent and/or Descent II (the versions sold by GOG and Steam work), or the free shareware and demo versions. One of the two games is enough.

## Installation

1. Download the newest `DXXRebirth_YYYYMMDD.zip` from [releases](releases/) and extract it to the root of your SD card (`/media/fat`). That gives you:
   - `_Other/DXXRebirth_YYYYMMDD.rbf`, the FPGA core
   - `games/DXXRebirth/`, the game binary and its launcher
   - `Scripts/danik_hybrid_cores.sh`, the launcher (from [Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), which can also keep it up to date through `update_all`)
2. Copy the game data to the SD card. Each game has a folder of its own:

   | Game | Folder | Files |
   |---|---|---|
   | Descent | `/media/fat/games/d1x-rebirth/` | `descent.hog`, `descent.pig` |
   | Descent II | `/media/fat/games/d2x-rebirth/` | `descent2.hog`, `descent2.ham`, `descent2.s11`, `descent2.s22`, `alien1.pig`, `alien2.pig`, `fire.pig`, `groupa.pig`, `ice.pig`, `water.pig`; for the movies `intro-l.mvl`, `other-l.mvl`, `robots-l.mvl` |
   | Descent II demo | `/media/fat/games/d2x-rebirth/` | `d2demo.hog`, `d2demo.ham`, `d2demo.pig` |

   The shareware version of Descent has the same two file names as the full game. Of the Descent II movies the low resolution ones (`-l.mvl`) are the size of the screen; if only the high resolution ones (`-h.mvl`) are there, they are scaled down. Missions (`.hog` with `.msn` or `.mn2`) go into a `missions` folder inside the game's folder.
3. Run **danik_hybrid_cores** from the `Scripts` menu, if you have not done so before (see Requirements).
4. Load **DXXRebirth** from the `Other` menu.

With the data of both games on the card, a list asks which one to play; quitting a game returns to it, and so does loading the core again from the MiSTer menu. Pilots, settings, saved games and demos are in `/media/fat/games/DXXRebirth/descent/` and `/media/fat/games/DXXRebirth/descent2/`. The log is in `/media/fat/logs/DXXRebirth/dxxrebirth.log`.

## OSD options

| Option | |
|---|---|
| Aspect ratio, Scale, Scandoubler Fx, Stereo Mix | as in other cores |
| Sound Volume, Music Volume | on top of the volumes in the game's own *Sound effects & music* options |
| Menu OK, Menu Back | the gamepad button that confirms / goes back in the game's menus, whatever it does in the game. **MiSTer** (default) uses the OK/Back buttons of your MiSTer menu |

## Controls

- **Keyboard and mouse:**

| Key | Action |
|---|---|
| Arrow keys, mouse | Turn and pitch |
| W / S | Accelerate / reverse |
| A / D | Slide left / right |
| C / X | Slide up / down |
| Q / E | Bank left / right |
| Left Alt | Slide: the arrow keys slide while it is held |
| Ctrl, left mouse button | Fire primary weapon |
| Space, right mouse button | Fire secondary weapon |
| F | Fire flare |
| B | Drop bomb |
| 1-5 / 6-0 | Select primary / secondary weapon |
| , / . | Next primary / secondary weapon |
| R | Rear view |
| Tab | Automap |
| Left Shift / H / T | Afterburner / headlight / energy to shield (Descent II) |
| Esc | Game menu (automap, options, save, load, abort) |
| F2 / Alt+F2 / Alt+F3 | Options / save game / load game |
| F3 | Cockpit, status bar or full screen view |
| F1 | Help: all keys |

All of them can be changed in the game under *Options*, *Controls*.

- **Gamepad** (default mapping):

| Button | Action |
|---|---|
| Left stick, D-pad | Turn and pitch |
| Right stick | Slide left / right and up / down |
| Y (Xbox X / PlayStation Square) | Fire primary weapon |
| X (Xbox Y / PlayStation Triangle) | Fire secondary weapon |
| B (Xbox A / PlayStation Cross) | Accelerate |
| A (Xbox B / PlayStation Circle) | Reverse |
| L (LB / L1) | Slide: the left stick and the D-pad slide while it is held |
| R (RB / R1) | Next primary weapon |
| Select | Next secondary weapon |
| Start | Game menu: automap, options, save, load, abort. Closes the automap and the menus too |

Nothing needs a keyboard. Where the game asks for text (the name of a pilot, the description of a saved game), the D-pad types: up and down change the last character, right adds one, left removes one. A game saved without a description gets the date and time. Start, Menu OK and Menu Back skip a movie.

The actions of the buttons can also be changed in the game under *Options*, *Controls*, *Customize joystick*; there, Select clears a binding and holding Start resets all of them.

Change the buttons in the OSD under *Define DXXRebirth buttons*. *Menu OK* and *Menu Back* there are only needed for a button without a game function; MiSTer doesn't let you assign a button twice, so to confirm with a button that also has a game function, pick it in the OSD's Menu OK/Menu Back options instead.

## Building

Everything builds in Docker on a Linux PC.

```sh
git clone --recursive https://github.com/ItsDanik/DXXRebirth_MiSTer.git
cd DXXRebirth_MiSTer
./build.sh              # ARM game binaries -> build/mister/
./core/build_core.sh    # FPGA core (Quartus Lite 17.0.2) -> core/output_files/DXXRebirth.rbf
./package.sh            # release zip      -> dist/DXXRebirth_YYYYMMDD.zip
```

The toolchain image (Debian bullseye, glibc 2.31 to match the MiSTer) is built from `hybrid/toolchain/` on first use. DXX-Rebirth needs a newer compiler (gcc 14) and Python than that image has, so a second image is built from `toolchain/`: it has a gcc 14 cross compiler built against the same glibc 2.31, which takes a while the first time. The first build also downloads and builds SDL2, SDL2_mixer and SDL2_net (`hybrid/sdl2/build.sh`), PhysFS, SDL2_image and libADLMIDI (`tools/deps.sh`).

### Repository layout

| Path | |
|---|---|
| `hybrid/` | submodule: [ItsDanik/Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), what all our hybrid cores share: the FPGA host module, the ARM side library, SDL2 drivers, the launcher (`danik_hybrid_cores.sh`), toolchain and conventions. See its README. |
| `core/` | FPGA core, based on [Template_MiSTer](https://github.com/MiSTer-devel/Template_MiSTer): `DXXRebirth.sv` (OSD and button names) around `hybrid/rtl/hybrid_host.sv` |
| `dxxrebirth/` | submodule: the game, branch `mister`, with the MiSTer changes (SCons option `mister_hybrid=1`) and the software renderer on SDL2 |
| `src/dxxrebirth.c` | `DXXRebirth`, the program the launcher starts: the list of games, then `d1x-rebirth` or `d2x-rebirth` |
| `toolchain/` | Docker image with gcc 14 for the MiSTer |
| `tools/deps.sh` | builds PhysFS, SDL2_image and libADLMIDI |
| `package/` | files shipped in the release next to the binary (`danik_hybrid_launch.sh`, README) |
| `releases/` | release packages |

### Development notes

- `./build.sh host` builds the same game for the PC. It runs against `hybrid/tools/fakecore`, a stand-in for the FPGA core that takes scripted input and saves screenshots and audio:
  ```sh
  gcc -O2 -o build/host/fakecore hybrid/tools/fakecore.c
  build/host/fakecore /tmp/shm script.txt audio.raw &
  MISTER_HYBRID_SHM=/tmp/shm LD_LIBRARY_PATH=build/host D1X_REBIRTH_HOME=/tmp/d1 \
      build/host/d1x-rebirth/d1x-rebirth -hogdir <data folder>
  ```
  `build/host/DXXRebirth` is the list of games; it takes the data folders from `DXX_D1_DATA` and `DXX_D2_DATA`.
- The ARM binaries run on the PC under `qemu-arm` too (with the toolchain image's `/opt/mister-sysroot` as `QEMU_LD_PREFIX`), against the same fakecore. That is how the compiler bug named in `build.sh` was found.
- `MISTER_HYBRID_STATS=1` in the environment of the game (`danik_hybrid_launch.sh`) puts frame and audio timing in the log: fields per frame, time per frame, every late frame. `hybrid/tools/fbmon.c` watches from outside whether every field got a new frame.
- `touch /tmp/dxxrebirth_nolaunch` on the MiSTer keeps the core loaded without starting the game, so you can start a development binary by hand (set `MISTER_HYBRID_CORE=DXXRebirth`). `/tmp/danik_hybrid_cores.log` shows what the launcher daemon did.

## Credits

- **[DXX-Rebirth](https://www.dxx-rebirth.com/)** ([source](https://github.com/dxx-rebirth/dxx-rebirth)) by Kp, Christian Beckhäuser and the DXX-Rebirth contributors, based on the Descent and Descent II source code released by Parallax Software.
- **[PhysicsFS](https://icculus.org/physfs/)** by Ryan C. Gordon, **[libADLMIDI](https://github.com/Wohlstand/libADLMIDI)** by Vitaly Novichkov and Joel Yliluoma (the music, with the DOSBox OPL3 emulator), **SDL_image** and **SDL_mixer**.
- **[SDL](https://libsdl.org)** by Sam Lantinga and contributors.
- **[MiSTer](https://github.com/MiSTer-devel)** by Sorgelig and the MiSTer-devel contributors: the framework and Template_MiSTer.
- **[MiSTer Frontier](https://github.com/MiSTerOrganize/MiSTer_Frontier)** by MiSTer Organize: thank you for the inspiration. Hybrid cores on the MiSTer, and the way their game is launched (a daemon that watches the loaded core and runs a script from its games folder), come from MiSTer Frontier. Our launcher is a separate implementation and does not need MiSTer Frontier installed.

This project and its maintainers are in no way associated with or endorsed by Parallax Software, Interplay Entertainment or the DXX-Rebirth project. It does not include any game data.

## License

The top-level scripts, tools and documentation are licensed under the [GPL-3.0](LICENSE). The components keep their own licenses: the shared framework in `hybrid/` is GPL-3.0 except where its files say otherwise, DXX-Rebirth is under its own license (`dxxrebirth/COPYING.txt`: the Parallax license for the original source, GPL-3.0 for what was added since), PhysFS and SDL_image are zlib, libADLMIDI is LGPL-3.0, SDL and the SDL drivers in `hybrid/sdl2` are zlib, the FPGA core and the MiSTer framework are GPL-2.0 (`core/LICENSE`, with the core's own sources GPL-2.0-or-later).
