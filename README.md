# DXXRebirth for MiSTer

Descent and Descent II on [MiSTer FPGA](https://github.com/MiSTer-devel/Main_MiSTer/wiki) as a hybrid port.

The games themselves are [DXX-Rebirth](https://www.dxx-rebirth.com/) (D1X-Rebirth and D2X-Rebirth), the source port of the Descent and Descent II engines, with its software renderer. They run on the MiSTer's ARM CPU. The DXXRebirth FPGA core provides native 15kHz video (CRT, VGA and HDMI) at 320x200 or 320x240, 44.1kHz audio, the music on its FM chip or MIDI synthesizer, and keyboard, mouse and gamepad input with rumble. The two halves talk through shared DDR3 memory.

> **Beta.** Expect rough edges and please report problems in the issues.

Disclaimer: AI is being used to speed up development of this project.

## Requirements

- **danik_hybrid_ports**, the launcher (`Scripts/danik_hybrid_ports.sh`): run it **once** from the MiSTer's `Scripts` menu. It starts the game whenever its menu entry is loaded, keeps running after a reboot, and serves all our hybrid ports; its screen picks which ports and games to have, and can keep them up to date through `update_all`. It replaces `danik_hybrid_cores`, the launcher before it, and moves ports installed the old way into the new folders by itself. Without it the core says "Game not running".
- **Game data**, which is not included: your own copy of Descent and/or Descent II (the versions sold by GOG and Steam work), or the free shareware and demo versions. One of the two games is enough.

## Installation

With `update_all` (Downloader 2.4 or newer, which update_all keeps up to date):

1. Copy [`downloader_danik_hybrid_ports.ini`](https://raw.githubusercontent.com/ItsDanik/Hybrid_MiSTer/main/launcher/downloader_danik_hybrid_ports.ini) to the root of your SD card (`/media/fat`).
2. Run `update_all`. That installs the launcher, **danik_hybrid_ports**, in `Scripts`.
3. Run **danik_hybrid_ports** from the `Scripts` menu, tick the games you want and press *X: Apply*. They are installed, and update_all keeps them up to date.

By hand:

1. Download the newest `DXXRebirth_YYYYMMDD.zip` from [releases](releases/) and extract it to the root of your SD card (`/media/fat`). That gives you:
   - `_Other/dnk-Descent.mgl` and `_Other/dnk-Descent II.mgl`, the games' entries in the `Other` menu
   - `_Other/dnk/dnk-DXXRebirth_YYYYMMDD.rbf`, the FPGA core
   - `games/dnk/DXXRebirth/`, the game binaries and their launch script
   - `games/dnk/SoundFonts/`, the SoundFont of the core's MIDI synthesizer
   - `Scripts/danik_hybrid_ports.sh`, the launcher (from [Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer))
   - `downloader_danik_hybrid_ports.ini`, with which `update_all` keeps the ports up to date from then on
2. Copy the game data to `/media/fat/games/dnk/DXXRebirth/`: everything in the folder of your Descent, of your Descent II, or of both, into that one folder. Among the files are:

   | Game | Files |
   |---|---|
   | Descent | `descent.hog`, `descent.pig` |
   | Descent II | `descent2.hog`, `descent2.ham`, `descent2.s11`, `descent2.s22`, `alien1.pig`, `alien2.pig`, `fire.pig`, `groupa.pig`, `ice.pig`, `water.pig`; the movies `intro-l.mvl`, `other-l.mvl`, `robots-l.mvl` |
   | Descent II demo | `d2demo.hog`, `d2demo.ham`, `d2demo.pig` |

   The shareware version of Descent has the same two file names as the full game. Of the Descent II movies the low resolution ones (`-l.mvl`) are the size of the screen; if only the high resolution ones (`-h.mvl`) are there, they are scaled down. Missions (`.hog` with `.msn` or `.mn2`) go into `games/dnk/DXXRebirth/descent/missions/` (Descent) and `descent2/missions/` (Descent II).
3. Run **danik_hybrid_ports** from the `Scripts` menu, if you have not done so before (see Requirements).
4. Load **dnk-Descent** or **dnk-Descent II** from the `Other` menu.

The game data can go on a USB drive instead, into the same folder there (`/media/usb0/games/dnk/DXXRebirth/`): the game looks for it there first, and then keeps its settings and saved games there as well. Everything else stays on the SD card.

Loaded by itself (`_Other/dnk/`), the core shows a list of the games whose data is there. Pilots, settings, saved games and demos are in `games/dnk/DXXRebirth/descent/` and `descent2/`. The log is in `/media/fat/logs/dnk/DXXRebirth/dxxrebirth.log`.

The data of the first versions of this port, in `games/d1x-rebirth/` and `games/d2x-rebirth/`, is moved into the new folders by the launcher.

## OSD options

| Option | |
|---|---|
| Aspect ratio, Scale, Scandoubler Fx, Stereo Mix | as in other cores |
| FPS Counter | shows the pictures per second in the top left corner |
| HDMI Only | **Yes** if no CRT is connected: resolutions of 640x400 and more are then progressive instead of interlaced, and the analog output is switched off while one is shown, so that a 15kHz screen can never get such a signal. Nothing changes at lower resolutions. Not needed with `forced_scandoubler=1` (VGA monitor); not there with `direct_video=1` |
| CRT Options | for a 15kHz screen: *Horizontal Size*, *Horizontal Pos* and *Vertical Pos* fit the picture to it. The pixels stay as they are; HDMI is not affected. The size is for the game's picture: the core's own, with its messages, keeps its width. Not there with `forced_scandoubler=1`. *HUD (Top)* and *HUD (Bottom)*: in 320x240, how far the HUD is from the top and the bottom edge of the screen, to keep it out of a CRT's overscan |
| Sound Volume, Music Volume | on top of the volumes in the game's own *Sound effects & music* options |
| Resolution | **320x200**, the games' own, or **320x240**: the view fills all 240 lines from edge to edge, with the cockpit, the status bar and the HUD drawn over it at the HUD margins. Menus, briefings and movies stay 320x200 in the middle |
| Music | **MIDI**: the music is played by an MT32-pi when one is connected and on, else by the core's MIDI synthesizer with the SoundFont below. **FM chip**: by the core's OPL2, as on a Sound Blaster |
| SoundFont | the synthesizer's SoundFont: *Default* (GeneralUser GS, which comes with the port) or one of your own, 1 to 7: the `.sf2` files in `games/dnk/SoundFonts/`, in the order of their names |
| MT32-pi | only while one is connected: on or off, its synth, ROM and SoundFont |
| Rumble | the controller rumbles when the ship is hit, fires, hits a wall or explodes, while the fusion cannon charges and while the mine shakes |
| Cheats | the games' own cheats, for one player: *Invulnerability*, *Robots Don't Fire*, *Rapid Fire*, *Ghost (No Clipping)*, *Turbo*, and in Descent II *Homing Weapons*, *Bouncy Weapons*, *Robots Kill Robots*; *Give All* (all weapons and keys, full shields and energy; in Descent II the accessories too), *Kill Reactor*, *Next Level*, *Exit Path*. As with the typed cheats, the score goes to 0 |
| Save Diagnostic Report | the last line: see [If something is wrong](#if-something-is-wrong) |

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

In the game's menus the buttons that confirm and go back are the ones of your MiSTer menu, whatever they do in the game: its *Menu OK* / *Menu Back* if you set them in *Define joystick buttons*, else its A / B. A controller never set up in MiSTer confirms and goes back as on its console: Cross / Circle on PlayStation, A / B on Xbox and on Nintendo. They also skip a movie, as Start does.

Nothing needs a keyboard. Where the game asks for text (the name of a pilot, the description of a saved game), the D-pad types: up and down change the last character, right adds one, left removes one. A game saved without a description gets the date and time.

The actions of the buttons can also be changed in the game under *Options*, *Controls*, *Customize joystick*; there, Select clears a binding and holding Start resets all of them.

Change the buttons in the OSD under *Define DXXRebirth buttons*. *Menu OK* and *Menu Back* there are only needed for a spare button without a game function. While the OSD is open, the game gets no input.

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

## If something is wrong

If the game stutters, the sound breaks up or something else is wrong, open the OSD while it happens and pick **Save Diagnostic Report**, the last line of the menu. The game keeps running; MiSTer's info box says the report is saved in `games/dnk/diagnostics/` on the SD card. Send that file (`DXXRebirth_<date>_<time>.zip`) with a few words on what went wrong.

The report has the setup (versions, the video and audio lines of `MiSTer.ini`, the OSD settings), how the last 60 seconds went, the game's log and a screenshot. Nothing else: no network settings, addresses, saved games or lists of your files.

## Support

If you enjoy this project, you can support my work on [Patreon](https://www.patreon.com/itsdanik).

## Credits

- **[DXX-Rebirth](https://www.dxx-rebirth.com/)** ([source](https://github.com/dxx-rebirth/dxx-rebirth)) by Kp, Christian Beckhäuser and the DXX-Rebirth contributors, based on the Descent and Descent II source code released by Parallax Software.
- **[PhysicsFS](https://icculus.org/physfs/)** by Ryan C. Gordon, **[libADLMIDI](https://github.com/Wohlstand/libADLMIDI)** by Vitaly Novichkov and Joel Yliluoma (the music's sequencer and instruments), **SDL_image** and **SDL_mixer**.
- **[SDL](https://libsdl.org)** by Sam Lantinga and contributors.
- **[GeneralUser GS](https://www.schristiancollins.com/generaluser.php)** by S. Christian Collins: the SoundFont of the core's MIDI synthesizer, which comes with the port, its licence next to it.
- **[MiSTer](https://github.com/MiSTer-devel)** by Sorgelig and the MiSTer-devel contributors: the framework and Template_MiSTer.
- **[MiSTer Frontier](https://github.com/MiSTerOrganize/MiSTer_Frontier)** by MiSTer Organize: thank you for the inspiration. Hybrid cores on the MiSTer, and the way their game is launched (a daemon that watches the loaded core and runs a script from its games folder), come from MiSTer Frontier. Our launcher is a separate implementation and does not need MiSTer Frontier installed.

This project and its maintainers are in no way associated with or endorsed by Parallax Software, Interplay Entertainment or the DXX-Rebirth project. It does not include any game data.

## License

The top-level scripts, tools and documentation are licensed under the [GPL-3.0](LICENSE). The components keep their own licenses: the shared framework in `hybrid/` is GPL-3.0 except where its files say otherwise, DXX-Rebirth is under its own license (`dxxrebirth/COPYING.txt`: the Parallax license for the original source, GPL-3.0 for what was added since), PhysFS and SDL_image are zlib, libADLMIDI is LGPL-3.0, SDL and the SDL drivers in `hybrid/sdl2` are zlib, the FPGA core and the MiSTer framework are GPL-2.0 (`core/LICENSE`, with the core's own sources GPL-2.0-or-later).
