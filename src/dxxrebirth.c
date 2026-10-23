// DXXRebirth: what the launcher starts. DXX-Rebirth is two programs, one for
// Descent and one for Descent II. This picks the game (MH_PickGame(): the
// menu entry's, or from the list of the games whose files are there) and
// becomes that program. The game's logo, shown with the pick, goes over to
// it (MH_Close() before execv(), host version 17). Without the game's files
// the core's picture says which go where.
//
// The data of both games is in the current folder (games/dnk/DXXRebirth/,
// DATADIR of danik_hybrid_launch.sh); d1x-rebirth and d2x-rebirth are next
// to this program. Their settings and saved games are where
// D1X_REBIRTH_HOME and D2X_REBIRTH_HOME say (descent/ and descent2/ there).
// The games look for their data in those folders first, as DXX-Rebirth does
// in ~/.d1x-rebirth and ~/.d2x-rebirth, so a player who knows it may have
// put it there: a game is there in either place.

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include <mister_hybrid.h>

#define EXIT_TO_MENU 0

static const char *const DESCENT_FILES[] = { "descent.hog", "descent.pig", NULL };
static const char *const DESCENT2_FILES[] = {
    "descent2.hog", "descent2.ham", "descent2.s11", "descent2.s22", "alien1.pig", "alien2.pig",
    "fire.pig", "groupa.pig", "ice.pig", "water.pig", NULL };
static const char *const DESCENT2_DEMO_FILES[] = { "d2demo.hog", "d2demo.ham", "d2demo.pig", NULL };

// The shareware of Descent has the full game's file names
static const mh_game GAMES[] = {
    { "d1", "Descent", DESCENT_FILES, NULL,
      "Descent is not there. Copy all the files of your Descent (full game or shareware: "
      "descent.hog and descent.pig among them) into %s." },
    { "d2", "Descent II", DESCENT2_FILES, NULL,
      "Descent II is not there. Copy all the files of your Descent II (descent2.hog, "
      "descent2.ham, descent2.s11, descent2.s22 and six .pig files among them) into %s." },
    { "d2demo", "Descent II (demo)", DESCENT2_DEMO_FILES, "d2", NULL },
};
#define NUM_GAMES (int)(sizeof(GAMES) / sizeof(GAMES[0]))

// The folder of each game's settings, in the folder of the data
static const char *const HOMES[NUM_GAMES] = { "descent", "descent2", "descent2" };
#define MAX_FILES 16

// games[i] with its files in its settings folder, where they are there and
// not in the folder of the data
static void find_at_home(mh_game *games, char paths[NUM_GAMES][MAX_FILES][32],
                         const char *lists[NUM_GAMES][MAX_FILES + 1])
{
    mh_game at_home;
    int i, j;

    for (i = 0; i < NUM_GAMES; i++) {
        if (MH_GameFound(&games[i], NULL))
            continue;
        for (j = 0; games[i].files[j] != NULL && j < MAX_FILES; j++) {
            snprintf(paths[i][j], sizeof(paths[i][j]), "%s/%s", HOMES[i], games[i].files[j]);
            lists[i][j] = paths[i][j];
        }
        lists[i][j] = NULL;
        at_home = games[i];
        at_home.files = lists[i];
        if (MH_GameFound(&at_home, NULL))
            games[i].files = lists[i];
    }
}

static const char *const NO_GAME =
    "No game found. Copy all the files of your Descent (descent.hog, descent.pig) or "
    "Descent II (descent2.hog, .ham, .s11, .s22, six .pig files) into %s.";

int main(int argc, char **argv)
{
    static const char *const programs[NUM_GAMES] = { "d1x-rebirth", "d2x-rebirth", "d2x-rebirth" };
    static char paths[NUM_GAMES][MAX_FILES][32];
    static const char *lists[NUM_GAMES][MAX_FILES + 1];
    mh_game games[NUM_GAMES];
    char program[PATH_MAX + 32], data[PATH_MAX];
    struct stat st;
    char *slash;
    int pick, listed = 0;

    (void)argc;
    if (!MH_Open()) {
        fprintf(stderr, "the core is not loaded\n");
        return EXIT_TO_MENU;
    }
    // the game's logo and the lines under it ("Loading <name>..." the last)
    // come with the pick
    memcpy(games, GAMES, sizeof(games));
    find_at_home(games, paths, lists);
    pick = MH_PickGame(games, NUM_GAMES, NULL, NO_GAME, &listed);
    if (pick < 0) {
        MH_Close();
        return EXIT_TO_MENU;
    }
    // quitting a game picked from the list shows the list again (exit code 42)
    if (listed)
        setenv("MISTER_HYBRID_FROM_LIST", "1", 1);
    // the logo stays and goes over to the game's program
    MH_Close();

    snprintf(program, sizeof(program) - 32, "%s", argv[0]);
    slash = strrchr(program, '/');
    strcpy(slash ? slash + 1 : program, programs[pick]);
    // in the build tree each program is in a folder of its name
    if (stat(program, &st) == 0 && S_ISDIR(st.st_mode)) {
        strcat(program, "/");
        strcat(program, programs[pick]);
    }
    if (!getcwd(data, sizeof(data)))
        strcpy(data, ".");
    execl(program, program, "-hogdir", data, (char *)NULL);
    perror(program);
    return EXIT_TO_MENU;
}
