state("Shotgun Cop Man Demo"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Shotgun Cop Man (Demo)";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "TotalTime", true, "Total Time Tracker", null },
		{ "LevelTime", false, "Level Time Tracker - For IL Splitting", null},
		{ "AllInOne", false, "100% Run - All In One Achievements on each level", null }, 
		{ "Splits", true, "Splits", null },
			{ "Level0", true, "Level 0", "Splits"},
				{ "0-1", true, "Level 0-1", "Level0" },
				{ "0-2", true, "Level 0-2", "Level0" },
				{ "0-3", true, "Level 0-3", "Level0" },
				{ "0-4", true, "Level 0-4", "Level0" },
				{ "0-5", true, "Level 0-5", "Level0" },
				{ "0-6", true, "Level 0-6", "Level0" },
				{ "0-7", true, "Level 0-7", "Level0" },
				{ "0-8", true, "Level 0-8", "Level0" },
				{ "0-9", true, "Level 0-9", "Level0" },
			{ "Level1", true, "Level 1", "Splits"},
				{ "1-1", true, "Level 1-1", "Level1" },
				{ "1-2", true, "Level 1-2", "Level1" },
				{ "1-3", true, "Level 1-3", "Level1" },
				{ "1-4", true, "Level 1-4", "Level1" },
				{ "1-5", true, "Level 1-5", "Level1" },
				{ "1-6", true, "Level 1-6", "Level1" },
				{ "1-7", true, "Level 1-7", "Level1" },
				{ "1-8", true, "Level 1-8", "Level1" },
				{ "1-9", true, "Level 1-9", "Level1" },
				{ "1-10", true, "Level 1-10", "Level1" },
				{ "1-11", true, "Level 1-11", "Level1" },
				{ "1-12", true, "Level 1-12", "Level1" },
				{ "1-13", true, "Level 1-13", "Level1" },
				{ "1-14", true, "Level 1-14", "Level1" },
				{ "1-15", true, "Level 1-15", "Level1" },
				{ "1-16", true, "Level 1-16", "Level1" },
				{ "1-17", true, "Level 1-17 (Boss)", "Level1" },
			{ "SteamNextFest1", false, "Steam Next Fest 1", "Splits"},
				{ "Steam Next Fest 11", true, "Steam Next Fest 1-1", "Level1" },
				{ "Steam Next Fest 12", true, "Steam Next Fest 1-2", "Level1" },
				{ "Steam Next Fest 13", true, "Steam Next Fest 1-3", "Level1" },
				{ "Steam Next Fest 14", true, "Steam Next Fest 1-4", "Level1" },
				{ "Steam Next Fest 15", true, "Steam Next Fest 1-5", "Level1" },
			{ "SteamNextFest2", false, "Steam Next Fest 2", "Splits"},
				{ "Steam Next Fest 21", true, "Steam Next Fest 2-1", "Level1" },
				{ "Steam Next Fest 22", true, "Steam Next Fest 2-2", "Level1" },
				{ "Steam Next Fest 23", true, "Steam Next Fest 2-3", "Level1" },
				{ "Steam Next Fest 24", true, "Steam Next Fest 2-4", "Level1" },
				{ "Steam Next Fest 25", true, "Steam Next Fest 2-5", "Level1" },
			{ "SteamNextFest3", false, "Steam Next Fest 3", "Splits"},
				{ "Steam Next Fest 31", true, "Steam Next Fest 3-1", "Level1" },
				{ "Steam Next Fest 32", true, "Steam Next Fest 3-2", "Level1" },
				{ "Steam Next Fest 33", true, "Steam Next Fest 3-3", "Level1" },
				{ "Steam Next Fest 34", true, "Steam Next Fest 3-4", "Level1" },
				{ "Steam Next Fest 35", true, "Steam Next Fest 3-5", "Level1" },
			{ "SteamNextFest4", false, "Steam Next Fest 4", "Splits"},
				{ "Steam Next Fest 41", true, "Steam Next Fest 4-1", "Level1" },
				{ "Steam Next Fest 42", true, "Steam Next Fest 4-2", "Level1" },
				{ "Steam Next Fest 43", true, "Steam Next Fest 4-3", "Level1" },
				{ "Steam Next Fest 44", true, "Steam Next Fest 4-4", "Level1" },
				{ "Steam Next Fest 45", true, "Steam Next Fest 4-5", "Level1" },
			{ "SteamNextFest5", false, "Steam Next Fest 5", "Splits"},
				{ "Steam Next Fest 51", true, "Steam Next Fest 5-1", "Level1" },
				{ "Steam Next Fest 52", true, "Steam Next Fest 5-2", "Level1" },
				{ "Steam Next Fest 53", true, "Steam Next Fest 5-3", "Level1" },
				{ "Steam Next Fest 54", true, "Steam Next Fest 5-4", "Level1" },
				{ "Steam Next Fest 55", true, "Steam Next Fest 5-5", "Level1" },
			{ "SteamNextFest6", false, "Steam Next Fest 6", "Splits"},
				{ "Steam Next Fest 61", true, "Steam Next Fest 6-1", "Level1" },
				{ "Steam Next Fest 62", true, "Steam Next Fest 6-2", "Level1" },
				{ "Steam Next Fest 63", true, "Steam Next Fest 6-3", "Level1" },
				{ "Steam Next Fest 64", true, "Steam Next Fest 6-4", "Level1" },
				{ "Steam Next Fest 65", true, "Steam Next Fest 6-5", "Level1" },
			{ "SteamNextFest7", false, "Steam Next Fest 7", "Splits"},
				{ "Steam Next Fest 71", true, "Steam Next Fest 7-1", "Level1" },
				{ "Steam Next Fest 72", true, "Steam Next Fest 7-2", "Level1" },
				{ "Steam Next Fest 73", true, "Steam Next Fest 7-3", "Level1" },
				{ "Steam Next Fest 74", true, "Steam Next Fest 7-4", "Level1" },
				{ "Steam Next Fest 75", true, "Steam Next Fest 7-5", "Level1" },
		{ "Autoreset", false, "Auto-Reset when going into Main Menu -> Options", null },
	};
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();
	vars.VisitedLevel = new List<string>();

	// vars.ILTimes = new Dictionary<string, float>
	// {
	// 	{ "10", 0 },
	// 	{ "11", 0 },
	// 	{ "12", 0 },
	// 	{ "8", 0 },
	// 	{ "13", 0 },
	// 	{ "14", 0 },
	// 	{ "15", 0 },
	// 	{ "188", 0 },
	// 	{ "16", 0 },
	// 	{ "3", 0 },
	// 	{ "17", 0 },
	// 	{ "22", 0 },
	// 	{ "51", 0 },
	// 	{ "20", 0 },
	// 	{ "52", 0 },
	// 	{ "53", 0 },
	// 	{ "54", 0 },
	// 	{ "55", 0 },
	// 	{ "50", 0 },
	// 	{ "23", 0 },
	// 	{ "146", 0 },
	// 	{ "144", 0 },
	// 	{ "141", 0 },
	// 	{ "142", 0 },
	// 	{ "143", 0 },
	// 	{ "145", 0 },
	// 	{ "36", 0 }
	// };

	vars.IntroLevels = new List<string>
	{ "10", "11", "12", "8", "13", "14", "15", "188", "16", "3" };
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		vars.Helper["currentActiveMode"] = mono.MakeString("AutoSplitterData", "instance", "currentActiveMode");
		vars.Helper["lvlDisplayName"] = mono.MakeString("AutoSplitterData", "instance", "lvlDisplayName");
		vars.Helper["campaignName"] = mono.MakeString("AutoSplitterData", "instance", "campaignName");
		vars.Helper["totalTime"] = mono.Make<float>("AutoSplitterData", "instance", "totalTime");
		vars.Helper["levelTime"] = mono.Make<float>("AutoSplitterData", "instance", "levelTime");
		vars.Helper["isInGame"] = mono.Make<bool>("AutoSplitterData", "instance", "isInGame");
		vars.Helper["isPaused"] = mono.Make<bool>("AutoSplitterData", "instance", "isPaused");
		vars.Helper["isInMainMenu"] = mono.Make<bool>("AutoSplitterData", "instance", "isInMainMenu");
		vars.Helper["isInSettings"] = mono.Make<bool>("AutoSplitterData", "instance", "isInSettings");
		vars.Helper["isInWorldMap"] = mono.Make<bool>("AutoSplitterData", "instance", "isInWorldMap");
		vars.Helper["isShowingResultsScreen"] = mono.Make<bool>("AutoSplitterData", "instance", "isShowingResultsScreen");
		vars.Helper["lvlCompleted"] = mono.Make<bool>("AutoSplitterData", "instance", "lvlCompleted");
		vars.Helper["challengeAllInOne"] = mono.Make<bool>("AutoSplitterData", "instance", "challengeAllInOne");
		vars.Helper["isShowingResultsScreen"] = mono.Make<bool>("AutoSplitterData", "instance", "isShowingResultsScreen");
		vars.Helper["lvlCompleted"] = mono.Make<bool>("AutoSplitterData", "instance", "lvlCompleted");
		vars.Helper["challengeAllInOne"] = mono.Make<bool>("AutoSplitterData", "instance", "challengeAllInOne");
		vars.Helper["isMainCampaign"] = mono.Make<bool>("AutoSplitterData", "instance", "isMainCampaign");
        vars.Helper["isBonusCampaign"] = mono.Make<bool>("AutoSplitterData", "instance", "isBonusCampaign");
        vars.Helper["isCustomCampaign"] = mono.Make<bool>("AutoSplitterData", "instance", "isCustomCampaign");

		return true;
	});
	vars.FullRun = false;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.VisitedLevel.Clear();
}

start
{
	// return old.lvlBuiltAtTime != current.lvlBuiltAtTime;
	if (settings["TotalTime"] && old.currentActiveMode == "WorldMap" && current.currentActiveMode == "Game" && current.lvlDisplayName == "0-1") return true;
	else if (settings["LevelTime"] && old.currentActiveMode == "WorldMap" && current.currentActiveMode == "Game") return true;
}

split
{
	// Intro Levels
	if (current.currentActiveMode == "Game" && old.lvlDisplayName != current.lvlDisplayName && old.lvlDisplayName.Contains("0-")
		&& settings[old.lvlDisplayName] && !vars.VisitedLevel.Contains(old.lvlDisplayName))
		{
			vars.VisitedLevel.Add(old.lvlDisplayName);
			return settings[old.lvlDisplayName];
		}

	// World 1 Levels
	if (!settings["AllInOne"])
	{
		if (current.currentActiveMode == "Game" && !old.isShowingResultsScreen && current.isShowingResultsScreen 
			&& settings[current.lvlDisplayName] && !vars.VisitedLevel.Contains(current.lvlDisplayName))
		{
			vars.VisitedLevel.Add(current.lvlDisplayName);
			return settings[current.lvlDisplayName];
		}
	} else if (settings["AllInOne"])
	{
		if (current.currentActiveMode == "Game" && !old.isShowingResultsScreen && current.isShowingResultsScreen 
			&& settings[current.lvlDisplayName] && !vars.VisitedLevel.Contains(current.lvlDisplayName) && current.challengeAllInOne)
		{
			vars.VisitedLevel.Add(current.lvlDisplayName);
			return settings[current.lvlDisplayName];
		}
	}
}

isLoading
{
	return true;
}

gameTime
{
	if (settings["TotalTime"])
	{
		return TimeSpan.FromSeconds(current.totalTime);
	}
	else if (settings["LevelTime"])
	{
		return TimeSpan.FromSeconds(current.levelTime);
	}
}

reset
{
	return settings["Autoreset"] && old.isInSettings && !current.isInSettings;
}