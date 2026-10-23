DXXRebirth for MiSTer - Descent and Descent II as a hybrid core
==============================================================

The games (DXX-Rebirth, the source port of the Descent and Descent II
engines, with its software renderer) run on the MiSTer's ARM CPU; the
DXXRebirth FPGA core provides native 15kHz video (CRT, VGA and HDMI) at
320x200, audio and input.

Disclaimer: AI is being used to speed up development of this project.

Requirements
  - danik_hybrid_cores, the launcher that comes with this release
    (Scripts/danik_hybrid_cores.sh): copy it to /media/fat/Scripts/ and run
    it ONCE from the MiSTer's Scripts menu. It starts the game whenever
    the core is loaded, keeps running after a reboot, and serves all our
    hybrid cores. Every hybrid core brings the launcher along and the
    newest version is the one that runs, so it never has to be run again
    after an update. Without it the core only shows colour bars.
  - Game data. It is not included: your own copy of Descent and/or
    Descent II (the versions sold by GOG and Steam work), or the free
    shareware and demo versions. One of the two games is enough.

Install
  1. Copy _Other/DXXRebirth_*.rbf to /media/fat/_Other/
  2. Copy games/DXXRebirth/ to /media/fat/games/DXXRebirth/
  3. Copy the game data to the SD card. Each game has a folder of its own:
       Descent           /media/fat/games/d1x-rebirth/
                           descent.hog descent.pig
                           (the shareware version has the same file names)
       Descent II        /media/fat/games/d2x-rebirth/
                           descent2.hog descent2.ham descent2.s11
                           descent2.s22 alien1.pig alien2.pig fire.pig
                           groupa.pig ice.pig water.pig
                           for the movies: intro-l.mvl other-l.mvl
                           robots-l.mvl
       Descent II demo   /media/fat/games/d2x-rebirth/
                           d2demo.hog d2demo.ham d2demo.pig
     Of the Descent II movies the low resolution ones (-l.mvl) are the size
     of the screen; if only the high resolution ones (-h.mvl) are there,
     they are scaled down. Missions (.hog with .msn or .mn2) go into a
     "missions" folder inside the game's folder.
  4. Run danik_hybrid_cores from the Scripts menu, if you have not done so
     before (see Requirements).
  5. Load DXXRebirth from the Other menu.
  With the data of both games on the card, a list asks which one to play;
  quitting a game returns to it, and so does loading the core again from
  the MiSTer menu.

OSD options
  Aspect ratio, Scale, Scandoubler Fx, Stereo Mix as in other cores.
  Sound Volume, Music Volume
                on top of the volumes in the game's own "Sound effects &
                music" options.
  Menu OK, Menu Back
                the gamepad button that confirms / goes back in the game's
                menus, whatever it does in the game. MiSTer (default) uses
                the OK/Back buttons of your MiSTer menu.

Controls
  Keyboard and mouse:
    Arrow keys, mouse           Turn and pitch
    W / S                       Accelerate / reverse
    A / D                       Slide left / right
    C / X                       Slide up / down
    Q / E                       Bank left / right
    Left Alt                    Slide: the arrow keys slide while held
    Ctrl, left mouse button     Fire primary weapon
    Space, right mouse button   Fire secondary weapon
    F                           Fire flare
    B                           Drop bomb
    1-5 / 6-0                   Select primary / secondary weapon
    , / .                       Next primary / secondary weapon
    R                           Rear view
    Tab                         Automap
    Left Shift / H / T          Afterburner / headlight / energy to shield
                                (Descent II)
    Esc                         Game menu (automap, options, save, load,
                                abort)
    F2 / Alt+F2 / Alt+F3        Options / save game / load game
    F3                          Cockpit, status bar or full screen view
    F1                          Help: all keys
    All of them can be changed in the game under Options, Controls.
  Gamepad (default mapping):
    Left stick, D-pad                   Turn and pitch
    Right stick                         Slide left / right and up / down
    Y (Xbox X / PlayStation Square)     Fire primary weapon
    X (Xbox Y / PlayStation Triangle)   Fire secondary weapon
    B (Xbox A / PlayStation Cross)      Accelerate
    A (Xbox B / PlayStation Circle)     Reverse
    L (LB / L1)                         Slide: the left stick and the D-pad
                                        slide while it is held
    R (RB / R1)                         Next primary weapon
    Select                              Next secondary weapon
    Start                               Game menu: automap, options, save,
                                        load, abort. Closes the automap and
                                        the menus too
  Nothing needs a keyboard. Where the game asks for text (the name of a
  pilot, the description of a saved game), the D-pad types: up and down
  change the last character, right adds one, left removes one. A game saved
  without a description gets the date and time. Start, Menu OK and Menu
  Back skip a movie.
  The actions of the buttons can also be changed in the game under Options,
  Controls, Customize joystick; there, Select clears a binding and holding
  Start resets all of them.
  Change the buttons in the OSD under "Define DXXRebirth buttons". "Menu OK" and
  "Menu Back" there are only needed for a button without a game function;
  MiSTer doesn't let you assign a button twice, so to confirm with a button
  that also has a game function, pick it in the OSD's Menu OK/Menu Back
  options instead.

Files
  /media/fat/games/DXXRebirth/descent/    pilots, settings, saved games and
  /media/fat/games/DXXRebirth/descent2/   demos of the two games
  /media/fat/logs/DXXRebirth/dxxrebirth.log   the game's log

Credits
  DXX-Rebirth (https://www.dxx-rebirth.com/) by Kp, Christian Beckhaeuser
  and the DXX-Rebirth contributors, based on the Descent and Descent II
  source code released by Parallax Software.
  PhysicsFS by Ryan C. Gordon. libADLMIDI by Vitaly Novichkov and Joel
  Yliluoma (the music, with the DOSBox OPL3 emulator). SDL_image and
  SDL_mixer.
  SDL by Sam Lantinga and contributors.
  MiSTer by Sorgelig and the MiSTer-devel contributors.
  MiSTer Frontier by MiSTer Organize
  (https://github.com/MiSTerOrganize/MiSTer_Frontier): thank you for the
  inspiration. Hybrid cores on the MiSTer, and the way their game is
  launched, come from MiSTer Frontier. Our launcher is a separate
  implementation and does not need MiSTer Frontier installed.

License
  DXX-Rebirth: its own license, the Parallax license for the original
    source and GPL-3.0 for what was added since (LICENSE-dxxrebirth.txt,
    LICENSE-dxxrebirth-gpl3.txt)
  SDL, SDL_image, SDL_mixer, PhysicsFS: zlib (LICENSE-sdl.txt,
    LICENSE-sdl_image.txt, LICENSE-sdl_mixer.txt, LICENSE-physfs.txt)
  libADLMIDI (libADLMIDI.so): LGPL-3.0 (LICENSE-libadlmidi.txt)
  The launcher scripts: GPL-3.0 (LICENSE-gpl3.txt)
  The FPGA core: GPL-2.0
  Source: https://github.com/ItsDanik/DXXRebirth_MiSTer
          https://github.com/ItsDanik/Hybrid_MiSTer (launcher, framework)
