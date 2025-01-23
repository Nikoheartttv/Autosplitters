state("tattletailWindows"){
    short mainMenu : 0x1082B40, 0x88, 0x20, 0x18, 0x18, 0x14, 0x14, 0x70;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Tattletail";

	dynamic[,] _settings =
	{
		{ "MainSplits", true, "Main Splits", null },
			{ "-1607464073", true, "Level 1 - A Night To Remember", "MainSplits" },
			{ "-93818164", true, "Level 2 - Minor Mischief", "MainSplits" },
			{ "321807425", true, "Level 3 - Mamas Boy", "MainSplits" },
			{ "1884958763", true, "Level 4 - Funny Games (Any% Glitched) (No Ending Autosplit yet)", "MainSplits" },
			{ "303747229", true, "Level 5 - Video Horror System", "MainSplits" },
            { "168260861", true, "Level 6 - The Party", "MainSplits" },
			{ "1574299228", true, "Level 7 - There She Is", "MainSplits" },
			{ "BoxOpen", true, "Level 8 - Christmas (Any% Glitchless) (Ending Autosplit!)", "MainSplits" },
        { "KaleidoscopeSplits", true, "Kaleidoscope Splits", null },
			{ "-1217475852", true, "Memory 1 - Christmas", "KaleidoscopeSplits" },
			{ "164335150", true, "Memory 2 - TeaParty (Any% Glitched) (No Ending Autosplit yet)", "KaleidoscopeSplits" },
			{ "-579662899", true, "Memory 3 - EggThief", "KaleidoscopeSplits" },
			{ "-529790752", true, "Memory 4 - EggTragedy", "KaleidoscopeSplits" },
			{ "131882562", true, "Memory 5 - MamasGift", "KaleidoscopeSplits" },
            { "1198820808", false, "Memory 6 - Opening The Kaleidoscope (Any% Glitchless) (No Ending Autosplit yet)", "KaleidoscopeSplits" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        vars.Helper["currentLevel"] = mono.Make<int>("GD", "currentLevel");
        vars.Helper["loading"] = mono.Make<bool>("RM", "loader", "_isLoading");
        vars.Helper["activePlayer"] = mono.Make<bool>("GS", "activePlayer");
		vars.Helper["questText"] = mono.MakeString("RM", "hud", "questText", "drawText");
		vars.Helper["lastActionText"] = mono.MakeString("RM", "playerActionController", "lastActionText");
	 	return true;
	});

    current.inMainMenu = "0";
}

start
{
    return old.loading == false && current.loading == true;
}

onStart
{
    timer.IsGameTimePaused = true;
	vars.VisitedLevel.Clear();
}

update
{
    if (old.mainMenu != current.mainMenu)
	{
		current.inMainMenu = current.mainMenu.ToString("X");
        vars.Log(current.inMainMenu.ToString());
	}
}

split
{
	// all splits
    if (old.currentLevel != current.currentLevel && settings[current.currentLevel.ToString()] && !vars.VisitedLevel.Contains(current.currentLevel.ToString()))
		{
			vars.VisitedLevel.Add(current.currentLevel.ToString());
			return true;
		}
	// main game end
	if (settings["BoxOpen"] && current.currentLevel == 1574299228 
		&& old.questText == "TASK: Open your present" && current.questText == "TASK: Accept Tattletail's Gifts")
		{
			vars.VisitedLevel.Add(current.currentLevel.ToString());
			return true;
		}
}

isLoading
{
    return current.loading || current.activePlayer == false || current.inMainMenu != "0";
}