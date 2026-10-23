// DXXRebirth: what the launcher starts. DXX-Rebirth is two programs, one for
// Descent and one for Descent II. This looks which of the two has its game
// data, lets the player pick one on the screen if both do, and becomes that
// program. Without any data it says which files go where.
//
// Environment (set by danik_hybrid_launch.sh):
//   DXX_D1_DATA, DXX_D2_DATA   folders with the data of Descent and Descent II
//   DXX_LAST_GAME              file that remembers the last pick
// The programs d1x-rebirth and d2x-rebirth are next to this one.
// Their settings and saved games are where D1X_REBIRTH_HOME and
// D2X_REBIRTH_HOME say.

#include <ctype.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>
#include <unistd.h>

#include <mister_hybrid.h>

#define EXIT_TO_MENU 0

static const char *const TITLE = "DXX-Rebirth";

// The SD card does not care about upper and lower case, the PC does
static int has_file(const char *dir, const char *name)
{
    DIR *d = opendir(dir);
    struct dirent *e;
    int found = 0;

    if (!d)
        return 0;
    while (!found && (e = readdir(d)))
        found = !strcasecmp(e->d_name, name);
    closedir(d);
    return found;
}

static int has_descent(const char *dir)
{
    return has_file(dir, "descent.hog") && has_file(dir, "descent.pig");
}

static int has_descent2(const char *dir)
{
    return (has_file(dir, "descent2.hog") && has_file(dir, "descent2.ham")) ||
           (has_file(dir, "d2demo.hog") && has_file(dir, "d2demo.ham"));
}

static int read_last(const char *path)
{
    FILE *f = path ? fopen(path, "r") : NULL;
    int last = 0;

    if (f) {
        if (fscanf(f, "%d", &last) != 1)
            last = 0;
        fclose(f);
    }
    return last == 1;
}

static void write_last(const char *path, int pick)
{
    FILE *f = path ? fopen(path, "w") : NULL;

    if (f) {
        fprintf(f, "%d\n", pick);
        fclose(f);
    }
}

static const char *env(const char *name, const char *fallback)
{
    const char *value = getenv(name);
    return value && *value ? value : fallback;
}

int main(int argc, char **argv)
{
    static const char *const names[2] = { "Descent", "Descent II" };
    static const char *const programs[2] = { "d1x-rebirth", "d2x-rebirth" };
    const char *data[2];
    const char *last_path = getenv("DXX_LAST_GAME");
    char program[4096];
    struct stat st;
    char *slash;
    int have[2];
    int pick;

    (void)argc;
    data[0] = env("DXX_D1_DATA", "/media/fat/games/d1x-rebirth");
    data[1] = env("DXX_D2_DATA", "/media/fat/games/d2x-rebirth");
    have[0] = has_descent(data[0]);
    have[1] = has_descent2(data[1]);

    if (!have[0] && !have[1]) {
        if (MH_Open()) {
            MH_UI_Message(TITLE,
                "No game data found.\n\n"
                "Descent: copy descent.hog and descent.pig to games/d1x-rebirth on the SD card.\n\n"
                "Descent II: copy descent2.hog, descent2.ham, descent2.s11, descent2.s22 and the "
                "six .pig files to games/d2x-rebirth.",
                MH_UI_WAIT | MH_UI_ERROR);
            MH_Close();
        }
        fprintf(stderr, "no game data in %s or %s\n", data[0], data[1]);
        return EXIT_TO_MENU;
    }

    if (have[0] && have[1]) {
        if (!MH_Open()) {
            fprintf(stderr, "the core is not loaded\n");
            return EXIT_TO_MENU;
        }
        pick = MH_UI_Menu(TITLE, "Select a game:", names, 2, read_last(last_path));
        if (pick < 0 || pick > 1) {
            MH_Close();
            return EXIT_TO_MENU;
        }
        write_last(last_path, pick);
        MH_UI_Message(TITLE, pick ? "Loading Descent II..." : "Loading Descent...", 0);
        MH_Close();
        // quitting the game comes back here
        setenv("MISTER_HYBRID_FROM_LIST", "1", 1);
    } else {
        pick = have[1];
    }

    snprintf(program, sizeof(program) - 32, "%s", argv[0]);
    slash = strrchr(program, '/');
    strcpy(slash ? slash + 1 : program, programs[pick]);
    // in the build tree each program is in a folder of its name
    if (stat(program, &st) == 0 && S_ISDIR(st.st_mode)) {
        strcat(program, "/");
        strcat(program, programs[pick]);
    }
    execl(program, program, "-hogdir", data[pick], (char *)NULL);
    perror(program);
    return EXIT_TO_MENU;
}
