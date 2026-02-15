state("Rhythm Doctor") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Rhythm Doctor";
    vars.Helper.LoadSceneManager = true;

    dynamic[,] _settings =
    {
        { "IL_Mode", false, "IL Splitting", null },
        { "SRC", false, "SR.C Run Categories", null },
            { "Flawless", false, "100% / Flawless Category", "SRC" },
        { "Levels", true, "Levels", null },
            { "Intro", true, "0-1: Intro", "Levels" },
            { "OrientalTechno", true, "1-1: Samurai Techno", "Levels" },
            { "OrientalDubstep", true, "1-1N: Samurai Dubstep", "Levels" },
            { "Intimate", true, "1-2: Intimate", "Levels" },
            { "IntimateH", true, "1-2N: Intimate (Night)", "Levels" },
            { "OrientalInsomniac", true, "1-X: Battleworn Insomniac", "Levels" },
            { "InsomniacHard", true, "1-XN: Super Battleworn Insomniac", "Levels" },
            { "Lofi", true, "2-1: Lo-fi Hip-Hop Beats To Treat Patients To", "Levels" },
            { "CareLess", true, "2-1N: wish i could care less", "Levels" },
            { "SVT", true, "2-2: Supraventricula Tachycardia", "Levels" },
            { "Unreachable", true, "2-2N: Unreachable", "Levels" },
            { "Smokin", true, "2-3: Puff Piece", "Levels" },
            { "Pomeranian", true, "2-3N: Bomb-Sniffing Pomeranian", "Levels" },
            { "SongOfTheSea", true, "2-4: Song of the Sea", "Levels" },
            { "SongOfTheSeaH", true, "2-4N: Song of the Sea (Night)", "Levels" },
            { "BeansHopper", true, "2-B1: Beans Hopper", "Levels" },
            { "Boss2", true, "2-X: All The Times", "Levels" },
            { "Bitterness", true, "2-XN: Bitter Times", "Levels" },
            { "Garden", true, "3-1: Sleepy Garden", "Levels" },
            { "Lounge", true, "3-1N: Lounge", "Levels" },
            { "Classy", true, "3-2: Classy", "Levels" },
            { "ClassyH", true, "3-2N: Classy (Night)", "Levels" },
            { "DistantDuet", true, "3-3: Distant Duet", "Levels" },
            { "DistantDuetH", true, "3-3N: Distant Duet (Night)", "Levels" },
            { "Lesmis", true, "3-X: One Shift More", "Levels" },
            { "Heldbeats", true, "4-1: Training Doctor's Train Ride Performance", "Levels" },
            { "Rollerdisco", true, "4-1N: Rollerdisco Rumble", "Levels" },
            { "Invisible", true, "4-2: Invisible", "Levels" },
            { "InvisibleH", true, "4-2N: Invisible (Night)", "Levels" },
            { "Steinway", true, "4-3: Steinway", "Levels" },
            { "SteinwayH", true, "4-3N: Steinway Reprise", "Levels" },
            { "KnowYou", true, "4-4: Know You", "Levels" },
            { "Murmurs", true, "4-4N: Murmurs", "Levels" },
            { "LuckyBreak", true, "5-1: Lucky Break", "Levels" },
            { "Injury", true, "5-1N: One Slip Too Late", "Levels" },
            { "Freezeshot", true, "5-2: Lo-fi Beats For Patients To Chill To", "Levels" },
            { "FreezeshotH", true, "5-2N: Unsustainable Inconsolable", "Levels" },
            { "AthleteTherapy", true, "5-3: Seventh-Inning Stretch", "Levels" },
            { "StevensonsTango", true, "5-3N: Corazones Viejos", "Levels" },
            { "RhythmWeightlifter", false, "5-B1: Rhythm Weightlifter", "Levels" },
            { "AthleteFinale", true, "5-X: Dreams Don't Stop", "Levels" },
            { "HaileyDuet", true, "6-1: Something To Tell You", "Levels" },
            { "EdegaRave", true, "6-2: Welcome Back", "Levels" },
            { "PaigesReckoning", true, "6-X: Boss Fight", "Levels" },
            { "Blurred", true, "7-1: Blurred", "Levels" },
            { "Montage", true, "7-X: Miracle Defibrillator", "Levels" },
            { "Montage2", true, "7-XN: Miracle Defibrillator (Encore)", "Levels" },
            { "BlackestLuxuryCar", true, "MD-1: Blackest Luxury Car", "Levels" },
            { "TapeStopNight", true, "MD-2: tape/stop/night", "Levels" },
            { "The90sDecision", true, "MD-3: The 90s Decision", "Levels" },
            { "HelpingHands", true, "X-0: Helping Hands", "Levels" },
            { "ArtExercise", true, "X-1: Art Exercise", "Levels" },
            { "Unbeatable", true, "X-WOT: Worn Out Tapes", "Levels" },
            { "MeetAndTweet", true, "X-MAT: Meet And Tweet", "Levels" },
            { "VividStasis", true, "X-FTS: Fixations Towards the Stars", "Levels" },
            { "SparkLine", true, "X-KOB: Kindom of Balloons", "Levels" },
            { "Halloween", true, "1-BOO: theme of really spooky bird", "Levels" },
        { "AutoReset", false, "Auto Reset when going back to Menu", null },
    };

    vars.bossLevels = new List<string>() { "OrientalInsomniac", "InsomniacHard", "Boss2", "Bitterness", "Lesmis", "AthleteFinale", "PaigesReckoning", "Montage", "Montage2" };

    vars.rank = new dynamic[,]
    {
        { 0, -10, "Fminus" }, { 1, 0, "F" }, { 2, 10, "Fplus" },
        { 3, -11, "Dminus" }, { 4, 1, "D" }, { 5, 11, "Dplus" },
        { 6, -12, "Cminus" }, { 7, 2, "C" }, { 8, 12, "Cplus" },
        { 9, -13, "Bminus" }, { 10, 3, "B" }, { 11, 13, "Bplus" },
        { 12, -14, "Aminus" }, { 13, 4, "A" }, { 14, 14, "Aplus" },
        { 15, -15, "Sminus" }, { 16, 5, "S" }, { 17, 15, "Splus" }
    };

    vars.GetLocalRank = new Func<int,int>(rank =>
    {
        for (var i = 0; i < vars.rank.GetLength(0); i++)
            if (vars.rank[i, 1] == rank) return vars.rank[i, 0];
        return 0;
    });

    vars.Helper.Settings.Create(_settings);
    vars.Helper.AlertGameTime();

    vars.VisitedLevel = new List<string>();
    vars.levelCompleted = false;
}

init
{
    vars.Helper.TryLoad = (Func<dynamic,bool>)(mono =>
    {
        vars.Mono = mono;
        vars.Assembly = mono.Images["Assembly-CSharp"];

        var scnGame = mono["scnGame", 1];
        var scnGame2 = mono["scnGame"];
        var scnMenu = mono["scnMenu", 1];
        var MM = mono["MistakesManager"];
        dynamic HUD = null;

        // Core release number
        // vars.Helper["releaseNumber"] = mono.Make<int>("Releases", "releaseNumber");
        // int release = vars.Helper["releaseNumber"].Current;
        // vars.Log("Detected release number: " + release);

        vars.Helper["releaseNumber"] = mono.Make<int>("Releases", "releaseNumber");
        vars.Log("Watcher created: " + (vars.Helper["releaseNumber"] != null));
        vars.Log("Current releaseNumber value: " + vars.Helper["releaseNumber"]?.Current);

        if (scnGame == null || vars.Helper["releaseNumber"] == null)
        {
            vars.Log("Release number not recognized: " + release);
            return false; // Retry next frame
        }

        // Only setup watchers once per release
        if (vars.Helper["inGame"] == null)
        {
            vars.Log("Setting up MemoryWatchers for release: " + release);

            switch(release)
            {
                case 42: // v1.0.1
                case 41: // v1.0.0
                    var SV = mono["SpeedrunValues"];
                    var LevelBase = mono["LevelBase"];
                    var Rankscreen = mono["Rankscreen"];
                    vars.Helper["inGame"] = SV.Make<bool>("inGame");
                    vars.Helper["isLoading"] = SV.Make<bool>("isLoading");
                    vars.Helper["Level"] = SV.MakeString("currentLevel");
                    vars.Helper["rank"] = SV.Make<int>("rank");
                    vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
                    vars.Helper["GameState"] = SV.Make<int>("currentGameState");
                    vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");
                    vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "rankscreen", Rankscreen["trueGameover"]);
                    break;

                case 40: // v0.19.0
                case 39: // v0.18.1
                    SV = mono["SpeedrunValues"];
                    HUD = mono["HUD"];
                    vars.Helper["inGame"] = SV.Make<bool>("inGame");
                    vars.Helper["isLoading"] = SV.Make<bool>("isLoading");
                    vars.Helper["Level"] = SV.MakeString("currentLevel");
                    vars.Helper["rank"] = SV.Make<int>("rank");
                    vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
                    vars.Helper["GameState"] = SV.Make<int>("currentGameState");
                    vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");
                    vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "hud", HUD["trueGameover"]);
                    break;

                case 35: // v0.17.0
                case 34: // v0.16.1
                case 33: // v0.16.0
                    SV = mono["SpeedrunValues"];
                    HUD = mono["HUD"];
                    vars.Helper["inGame"] = SV.Make<bool>("inGame");
                    vars.Helper["isLoading"] = SV.Make<bool>("isLoading");
                    vars.Helper["Level"] = SV.MakeString("currentLevel");
                    vars.Helper["rank"] = SV.Make<int>("rank");
                    vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
                    vars.Helper["GameState"] = SV.Make<int>("currentGameState");
                    vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");
                    vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "hud", HUD["trueGameover"]);
                    break;

                case 32: // v0.15.1
                case 31: // v0.15.0
                case 30: // v0.14.0
                case 29: // v0.13.1
                case 28: // v0.13.0
                case 27: // v0.12.0
                    SV = mono["SpeedrunValues"];
                    HUD = mono["HUD"];
                    vars.Helper["inGame"] = SV.Make<bool>("inGame");
                    vars.Helper["isLoading"] = SV.Make<bool>("isLoading");
                    vars.Helper["Level"] = SV.MakeString("currentLevel");
                    vars.Helper["rank"] = SV.Make<int>("rank");
                    vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
                    vars.Helper["GameState"] = SV.Make<int>("currentGameState");
                    vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");
                    vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "hud", HUD["trueGameover"]);
                    break;

                case 26: // v0.11.6
                case 25: // v0.11.5
                case 16: // v0.10.1
                    HUD = mono["HUD"];
                    vars.Helper["rank"] = scnGame.Make<int>("_instance", "hud", HUD["mRank"]);
                    vars.Helper["Level"] = mono.MakeString("scnGame", "internalIdentifier");
                    vars.Helper["slotOpen"] = scnMenu.Make<bool>("_instance", "slotOpen");
                    vars.Helper["transitioningToAnotherScene"] = scnMenu.Make<bool>("_instance", "transitioningToAnotherScene");
                    vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
                    vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");
                    vars.Helper["GameState"] = scnGame.Make<int>("_instance", "_gameState");
                    vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "hud", HUD["trueGameover"]);
                    break;

                default:
                    vars.Log("Release number not handled: " + release);
                    return false;
            }

            vars.Log("MemoryWatchers setup complete for release: " + release);
        }

        return true;
    });
}
