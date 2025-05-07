state("Shotgun Cop Man"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Shotgun Cop Man";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "TotalTime", true, "Total Time Tracker", null },
		{ "TotalTimeAnywhere", false, "Total Time Tracker from Any Level/Stage", null },
		{ "LevelTime", false, "Level Time Tracker - For IL Splitting", null},
		{ "AllInOne", false, "100% Run - All In One Achievements on each level", null }, 
		{ "Autoreset", false, "Auto-Reset when going into Main Menu -> Options", null },
		{ "Splits", true, "Main Campaign Splits", null },
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
				{ "1-17", true, "Level 1-17", "Level1" },
			{ "Level2", true, "Level 2", "Splits"},
				{ "2-1", true, "Level 2-1", "Level2" },
				{ "2-2", true, "Level 2-2", "Level2" },
				{ "2-3", true, "Level 2-3", "Level2" },
				{ "2-4", true, "Level 2-4", "Level2" },
				{ "2-5", true, "Level 2-5", "Level2" },
				{ "2-6", true, "Level 2-6", "Level2" },
				{ "2-7", true, "Level 2-7", "Level2" },
				{ "2-8", true, "Level 2-8", "Level2" },
				{ "2-9", true, "Level 2-9", "Level2" },
				{ "2-10", true, "Level 2-10", "Level2" },
				{ "2-11", true, "Level 2-11", "Level2" },
				{ "2-12", true, "Level 2-12", "Level2" },
				{ "2-13", true, "Level 2-13", "Level2" },
				{ "2-14", true, "Level 2-14", "Level2" },
				{ "2-15", true, "Level 2-15", "Level2" },
				{ "2-16", true, "Level 2-16", "Level2" },
				{ "2-17", true, "Level 2-17", "Level2" },
			{ "Level3", true, "Level 3", "Splits"},
				{ "3-1", true, "Level 3-1", "Level3" },
				{ "3-2", true, "Level 3-2", "Level3" },
				{ "3-3", true, "Level 3-3", "Level3" },
				{ "3-4", true, "Level 3-4", "Level3" },
				{ "3-5", true, "Level 3-5", "Level3" },
				{ "3-6", true, "Level 3-6", "Level3" },
				{ "3-7", true, "Level 3-7", "Level3" },
				{ "3-8", true, "Level 3-8", "Level3" },
				{ "3-9", true, "Level 3-9", "Level3" },
				{ "3-10", true, "Level 3-10", "Level3" },
				{ "3-11", true, "Level 3-11", "Level3" },
				{ "3-12", true, "Level 3-12", "Level3" },
				{ "3-13", true, "Level 3-13", "Level3" },
				{ "3-14", true, "Level 3-14", "Level3" },
				{ "3-15", true, "Level 3-15", "Level3" },
				{ "3-16", true, "Level 3-16", "Level3" },
				{ "3-17", true, "Level 3-17", "Level3" },
			{ "Level4", true, "Level 4", "Splits"},
				{ "4-1", true, "Level 4-1", "Level4" },
				{ "4-2", true, "Level 4-2", "Level4" },
				{ "4-3", true, "Level 4-3", "Level4" },
				{ "4-4", true, "Level 4-4", "Level4" },
				{ "4-5", true, "Level 4-5", "Level4" },
				{ "4-6", true, "Level 4-6", "Level4" },
				{ "4-7", true, "Level 4-7", "Level4" },
				{ "4-8", true, "Level 4-8", "Level4" },
				{ "4-9", true, "Level 4-9", "Level4" },
				{ "4-10", true, "Level 4-10", "Level4" },
				{ "4-11", true, "Level 4-11", "Level4" },
				{ "4-12", true, "Level 4-12", "Level4" },
				{ "4-13", true, "Level 4-13", "Level4" },
				{ "4-14", true, "Level 4-14", "Level4" },
				{ "4-15", true, "Level 4-15", "Level4" },
				{ "4-16", true, "Level 4-16", "Level4" },
				{ "4-17", true, "Level 4-17", "Level4" },
			{ "Level5", true, "Level 5", "Splits"},
				{ "5-1", true, "Level 5-1", "Level5" },
				{ "5-2", true, "Level 5-2", "Level5" },
				{ "5-3", true, "Level 5-3", "Level5" },
				{ "5-4", true, "Level 5-4", "Level5" },
				{ "5-5", true, "Level 5-5", "Level5" },
				{ "5-6", true, "Level 5-6", "Level5" },
				{ "5-7", true, "Level 5-7", "Level5" },
				{ "5-8", true, "Level 5-8", "Level5" },
				{ "5-9", true, "Level 5-9", "Level5" },
				{ "5-10", true, "Level 5-10", "Level5" },
				{ "5-11", true, "Level 5-11", "Level5" },
				{ "5-12", true, "Level 5-12", "Level5" },
				{ "5-13", true, "Level 5-13", "Level5" },
				{ "5-14", true, "Level 5-14", "Level5" },
				{ "5-15", true, "Level 5-15", "Level5" },
				{ "5-16", true, "Level 5-16", "Level5" },
				{ "5-17", true, "Level 5-17", "Level5" },
			{ "Level6", true, "Level 6", "Splits"},
				{ "6-1", true, "Level 6-1", "Level6" },
				{ "6-2", true, "Level 6-2", "Level6" },
				{ "6-3", true, "Level 6-3", "Level6" },
				{ "6-4", true, "Level 6-4", "Level6" },
				{ "6-5", true, "Level 6-5", "Level6" },
				{ "6-6", true, "Level 6-6", "Level6" },
				{ "6-7", true, "Level 6-7", "Level6" },
				{ "6-8", true, "Level 6-8", "Level6" },
				{ "6-9", true, "Level 6-9", "Level6" },
				{ "6-10", true, "Level 6-10", "Level6" },
				{ "6-11", true, "Level 6-11", "Level6" },
				{ "6-12", true, "Level 6-12", "Level6" },
				{ "6-13", true, "Level 6-13", "Level6" },
				{ "6-14", true, "Level 6-14", "Level6" },
				{ "6-15", true, "Level 6-15", "Level6" },
				{ "6-16", true, "Level 6-16", "Level6" },
				{ "6-17", true, "Level 6-17", "Level6" },
			{ "Level7", true, "Level 7", "Splits"},
				{ "7-1", true, "Level 7-1", "Level7" },
				{ "7-2", true, "Level 7-2", "Level7" },
				{ "7-3", true, "Level 7-3", "Level7" },
				{ "7-4", true, "Level 7-4", "Level7" },
				{ "7-5", true, "Level 7-5", "Level7" },
				{ "7-6", true, "Level 7-6", "Level7" },
				{ "7-7", true, "Level 7-7", "Level7" },
				{ "7-8", true, "Level 7-8", "Level7" },
				{ "7-9", true, "Level 7-9", "Level7" },
				{ "7-10", true, "Level 7-10", "Level7" },
				{ "7-11", true, "Level 7-11", "Level7" },
				{ "7-12", true, "Level 7-12", "Level7" },
				{ "7-13", true, "Level 7-13", "Level7" },
				{ "7-14", true, "Level 7-14", "Level7" },
				{ "7-15", true, "Level 7-15", "Level7" },
				{ "7-16", true, "Level 7-16", "Level7" },
				{ "7-17", true, "Level 7-17", "Level7" },
			{ "Level8", true, "Level 8", "Splits"},
				{ "8-1", true, "Level 8-1", "Level8" },
				{ "8-2", true, "Level 8-2", "Level8" },
				{ "8-3", true, "Level 8-3", "Level8" },
				{ "8-4", true, "Level 8-4", "Level8" },
				{ "8-5", true, "Level 8-5", "Level8" },
				{ "8-6", true, "Level 8-6", "Level8" },
				{ "8-7", true, "Level 8-7", "Level8" },
				{ "8-8", true, "Level 8-8", "Level8" },
				{ "8-9", true, "Level 8-9", "Level8" },
				{ "8-10", true, "Level 8-10", "Level8" },
				{ "8-11", true, "Level 8-11", "Level8" },
				{ "8-12", true, "Level 8-12", "Level8" },
				{ "8-13", true, "Level 8-13", "Level8" },
				{ "8-14", true, "Level 8-14", "Level8" },
				{ "8-15", true, "Level 8-15", "Level8" },
				{ "8-16", true, "Level 8-16", "Level8" },
				{ "8-17", true, "Level 8-17", "Level8" },
			{ "Level9", true, "Level 9", "Splits"},
				{ "9-1", true, "Level 9-1", "Level9" },
				{ "9-2", true, "Level 9-2", "Level9" },
				{ "9-3", true, "Level 9-3", "Level9" },
				{ "9-4", true, "Level 9-4", "Level9" },
				{ "9-5", true, "Level 9-5", "Level9" },
				{ "9-6", true, "Level 9-6", "Level9" },
				{ "9-7", true, "Level 9-7", "Level9" },
				{ "9-8", true, "Level 9-8", "Level9" },
				{ "9-9", true, "Level 9-9", "Level9" },
				{ "9-10", true, "Level 9-10", "Level9" },
				{ "9-11", true, "Level 9-11", "Level9" },
				{ "9-12", true, "Level 9-12", "Level9" },
				{ "9-13", true, "Level 9-13", "Level9" },
				{ "9-14", true, "Level 9-14", "Level9" },
				{ "9-15", true, "Level 9-15", "Level9" },
				{ "9-16", true, "Level 9-16", "Level9" },
				{ "9-17", true, "Level 9-17", "Level9" },
	};
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();
	vars.VisitedLevel = new List<string>();

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
	// Main Campaign Start
	if (settings["TotalTime"] && old.currentActiveMode == "WorldMap" && current.currentActiveMode == "Game" && current.lvlDisplayName == "0-1") return true;
	else if (settings["TotalTimeAnywhere"] && old.currentActiveMode == "WorldMap" && current.currentActiveMode == "Game") return true;
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
	if (settings["TotalTimeAnywhere"])
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
