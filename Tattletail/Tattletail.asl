state("tattletailWindows")
{
    short MainMenu : 0x1082B40, 0x88, 0x20, 0x18, 0x18, 0x14, 0x14, 0x70;
    string64 Scene : 0x106BF90, 0x24, 0xC, 0x0;
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Tattletail";

    dynamic[,] _settings =
    {
        // { "ILMode", false, "Individual Level Splitting - Mode Toggle", null },
        { "MainSplits", true, "Main Splits", null },
            { "-1607464073", true, "Level 1 - A Night To Remember", "MainSplits" },
            { "-93818164", true, "Level 2 - Minor Mischief", "MainSplits" },
            { "321807425", true, "Level 3 - Mamas Boy", "MainSplits" },
            { "1884958763", true, "Level 4 - Funny Games (Any% Glitched)", "MainSplits" },
            { "303747229", true, "Level 5 - Video Horror System", "MainSplits" },
            { "168260861", true, "Level 6 - The Party", "MainSplits" },
            { "1574299228", true, "Level 7 - There She Is", "MainSplits" },
            { "BoxOpen", true, "Level 8 - Christmas (Any% Glitchless)", "MainSplits" },
        { "KaleidoscopeSplits", true, "Kaleidoscope Splits", null },
            { "-1217475852", true, "Memory 1 - Christmas", "KaleidoscopeSplits" },
            { "164335150", true, "Memory 2 - TeaParty (Any% Glitched)", "KaleidoscopeSplits" },
            { "-579662899", true, "Memory 3 - EggThief", "KaleidoscopeSplits" },
            { "-529790752", true, "Memory 4 - EggTragedy", "KaleidoscopeSplits" },
            { "131882562", true, "Memory 5 - MamasGift", "KaleidoscopeSplits" },
            { "1198820808", false, "Memory 6 - Opening The Kaleidoscope (Any% Glitchless)", "KaleidoscopeSplits" },
    };

    vars.Helper.Settings.Create(_settings);
    vars.Helper.AlertLoadless();

    vars.VisitedLevels = new HashSet<int>();
}

onStart
{
    timer.IsGameTimePaused = true;
    vars.VisitedLevels.Clear();
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["Level"] = mono.Make<int>("GD", "currentLevel");
        vars.Helper["IsPlayerActive"] = mono.Make<bool>("GS", "activePlayer");
        vars.Helper["Loading"] = mono.Make<bool>("RM", "loader", "_isLoading");
        vars.Helper["Quest"] = mono.MakeString("RM", "hud", "questText", "drawText");

        return true;
    });
}

update
{
    current.Scene = Path.GetFileNameWithoutExtension(current.Scene) ?? old.Scene;
}

start
{
    return !old.Loading && current.Loading;
}

split
{
    // all splits
    if (old.Level != current.Level && settings[current.Level.ToString()] && vars.VisitedLevels.Add(current.Level))
    {
        return true;
    }

	// split on credits
	if(old.Scene != current.Scene && current.Scene == "Credits")
	{
		return true;
	}

    // main game end
    if (settings["BoxOpen"] && current.Level == 1574299228
        && old.Quest == "TASK: Open your present" && current.Quest == "TASK: Accept Tattletail's Gifts"
        && vars.VisitedLevels.Add(current.Level))
    {
        return true;
    }
}

isLoading
{
    return current.Loading || !current.IsPlayerActive || current.MainMenu != 0;
}
