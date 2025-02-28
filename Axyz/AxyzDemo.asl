state("Axyz"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Axyz (Demo)";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Any%", true, "Any%" , null },
		{ "100%", false, "100%", null },
		{ "Splits", true, "Splits", null },
			{ "world1", true, "World 1", "Splits" },
				{ "level1", true, "Level 1", "world1" },
				{ "level2", true, "Level 2", "world1" },
				{ "level3", true, "Level 3", "world1" },
				{ "level4", true, "Level 4", "world1" },
				{ "level5", true, "Level 5", "world1" },
				{ "level6", true, "Level 6", "world1" },
				{ "level7", true, "Level 7", "world1" },
				{ "level8", true, "Level 8", "world1" },
				{ "level9", true, "Level 9", "world1" },
				{ "level10", true, "Level 10", "world1" },
				{ "level1A", true, "Level 1A", "world1" },
				{ "level1B", true, "Level 1B", "world1" },
				{ "level1C", true, "Level 1C", "world1" },
				{ "level1D", true, "Level 1D", "world1" },
				{ "level1E", true, "Level 1E", "world1" },
			{ "world2", true, "World 2", "Splits" },
				{ "level31", true, "Level 11", "world1" },
				{ "level32", true, "Level 12", "world1" },
	};
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();
	vars.CompletedLevels = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{	
		var SD = mono["PuzzleBall", "PuzzleBall.App.SpeedrunData"];
		vars.Helper["LevelID"] = mono.MakeString(SD, "LevelID");
		vars.Helper["WorldID"] = mono.MakeString(SD, "WorldID");
		vars.Helper["LevelState"] = mono.MakeString(SD, "LevelState");
		vars.Helper["IsPaused"] = mono.Make<bool>(SD, "IsPaused");
		vars.Helper["IsInLevelScene"] = mono.Make<bool>(SD, "IsInLevelScene");
		vars.Helper["MaxScore"] = mono.Make<int>(SD, "MaxScore");
		vars.Helper["CurrentScore"] = mono.Make<int>(SD, "CurrentScore");
		vars.Helper["TotalLevelKeys"] = mono.Make<int>(SD, "TotalLevelKeys");
		vars.Helper["CurrentLevelKeys"] = mono.Make<int>(SD, "CurrentLevelKeys");
		vars.Helper["TotalLevelTapes"] = mono.Make<int>(SD, "TotalLevelTapes");
		vars.Helper["CurrentLevelTapes"] = mono.Make<int>(SD, "CurrentLevelTapes");
		vars.Helper["TotalLevelBronzeCoins"] = mono.Make<int>(SD, "TotalLevelBronzeCoins");
		vars.Helper["CurrentLevelBronzeCoins"] = mono.Make<int>(SD, "CurrentLevelBronzeCoins");
		vars.Helper["TotalLevelSilverCoins"] = mono.Make<int>(SD, "TotalLevelSilverCoins");
		vars.Helper["CurrentLevelSilverCoins"] = mono.Make<int>(SD, "CurrentLevelSilverCoins");
		vars.Helper["TotalLevelGoldCoins"] = mono.Make<int>(SD, "TotalLevelGoldCoins");
		vars.Helper["CurrentLevelGoldCoins"] = mono.Make<int>(SD, "CurrentLevelGoldCoins");
		vars.Helper["TotalLevelGems"] = mono.Make<int>(SD, "TotalLevelGems");
		vars.Helper["CurrentLevelGems"] = mono.Make<int>(SD, "CurrentLevelGems");
		return true;
	});
}

start
{
	return !old.IsInLevelScene && current.IsInLevelScene;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.CompletedLevels.Clear();
}

split
{
	// Any% Splits
	if (settings["Any%"] && old.LevelState == "playing" && current.LevelState == "victory" && settings[current.LevelID] && !vars.CompletedLevels.Contains(current.LevelID))
		{
			vars.CompletedLevels.Add(current.LevelID);
			return true;
		}
	// 100% Splits
	if (settings["100%"] && old.LevelState == "playing" && current.LevelState == "victory" && 
		settings[current.LevelID] && !vars.CompletedLevels.Contains(current.LevelID)
		&& current.MaxScore == current.CurrentScore
		&& current.TotalLevelKeys == current.CurrentLevelKeys
		&& current.TotalLevelTapes == current.CurrentLevelTapes
		&& current.TotalLevelBronzeCoins == current.CurrentLevelBronzeCoins
		&& current.TotalLevelSilverCoins == current.CurrentLevelSilverCoins
		&& current.TotalLevelGoldCoins == current.CurrentLevelGoldCoins
		&& current.TotalLevelGems == current.CurrentLevelGems)
		{
			vars.CompletedLevels.Add(current.LevelID);
			return true;
		}
}

update
{
	if (old.WorldID != current.WorldID) vars.Log("WorldID: " + current.WorldID);
	if (old.LevelID != current.LevelID) vars.Log("LevelID: " + current.LevelID);
	if (old.LevelState != current.LevelState) vars.Log("LevelState: " + current.LevelState);
}

isLoading
{
	return current.LevelState != "playing" || current.LevelState == "" || current.IsPaused;
}