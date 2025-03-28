state("Axyz"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Axyz";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Any%", true, "Any%" , null },
		{ "100%", false, "100%", null },
		{ "Splits", true, "Splits", null },
			{ "world1", true, "World 1", "Splits" },
				{ "level1", true, "Level 1 - breathe", "world1" },
				{ "level2", true, "Level 2 - starstruck", "world1" },
				{ "level3", true, "Level 3 - jump around", "world1" },
				{ "level4", true, "Level 4 - go down", "world1" },
				{ "level5", true, "Level 5 - learning curve", "world1" },
				{ "level6", true, "Level 6 - gravity", "world1" },
				{ "level7", true, "Level 7 - ", "world1" },
				{ "level8", true, "Level 8 - 2-step", "world1" },
				{ "level9", true, "Level 9 - plastic love", "world1" },
				{ "level10", true, "Level 10 - odyssey", "world1" },
				{ "level1A", true, "Level 1A - arms", "world1" },
				{ "level1B", true, "Level 1B - rubix", "world1" },
				{ "level1C", true, "Level 1C - shades", "world1" },
				{ "level1D", true, "Level 1D - block party", "world1" },
				{ "level1E", true, "Level 1E - upward spiral", "world1" },
			{ "world2", true, "World 2", "Splits" },
				{ "level11", true, "Level 11 - oceansize", "world2" },
				{ "level12", true, "Level 12 - glossy", "world2" },
				{ "level13", true, "Level 13 - arch", "world2" },
				{ "level14", true, "Level 14 - loomer", "world2" },
				{ "level15", true, "Level 15 - humming", "world2" },
				{ "level16", true, "Level 16 - breakbeat", "world2" },
				{ "level17", true, "Level 17 - omen", "world2" },
				{ "level18", true, "Level 18 - thrice", "world2" },
				{ "level19", true, "Level 19 - trident", "world2" },
				{ "level20", true, "Level 20 - pew pew", "world2" },
				{ "level2A", true, "Level 2A - stack 'em", "world2" },
				{ "level2B", true, "Level 2B - here", "world2" },
				{ "level2C", true, "Level 2C - twobix", "world2" },
				{ "level2D", true, "Level 2D - ocean strike", "world2" },
				{ "level2E", true, "Level 2E - whip it", "world2" },
			{ "world3", true, "World 3", "Splits" },
				{ "level21", true, "Level 21 - no_future", "world3" },
				{ "level22", true, "Level 22 - crossfit", "world3" },
				{ "level23", true, "Level 23 - boingy boingy", "world3" },
				{ "level24", true, "Level 24 - zig and zag", "world3" },
				{ "level25", true, "Level 25 - emerald", "world3" },
				{ "level26", true, "Level 26 - know your enemy", "world3" },
				{ "level27", true, "Level 27 - break on through", "world3" },
				{ "level28", true, "Level 28 - shifty", "world3" },
				{ "level29", true, "Level 29 - squarish", "world3" },
				{ "level30", true, "Level 30 - emotion sickness", "world3" },
				{ "level3A", true, "Level 3A - hollywood", "world3" },
				{ "level3B", true, "Level 3B - handy", "world3" },
				{ "level3C", true, "Level 3C - the great gate", "world3" },
				{ "level3D", true, "Level 3D - topside", "world3" },
				{ "level3E", true, "Level 3E - 95", "world3" },
			{ "world4", true, "World 4", "Splits" },
				{ "level31", true, "Level 31 - sinking feeling", "world4" },
				{ "level32", true, "Level 32 - shopping", "world4" },
				{ "level33", true, "Level 33 - centered", "world4" },
				{ "level34", true, "Level 34 - slowdive", "world4" },
				{ "level35", true, "Level 35 - debaser", "world4" },
				{ "level36", true, "Level 36 - weighed down", "world4" },
				{ "level37", true, "Level 37 - twisty", "world4" },
				{ "level38", true, "Level 38 - THREEBIX", "world4" },
				{ "level39", true, "Level 39 - owlhead", "world4" },
				{ "level40", true, "Level 40 - virtual fantasy", "world4" },
				{ "level4A", true, "Level 4A - blocteau twins", "world4" },
				{ "level4B", true, "Level 4B - big boi", "world4" },
				{ "level4C", true, "Level 4C - bitsy", "world4" },
				{ "level4D", true, "Level 4D - burning bridges", "world4" },
				{ "level4E", true, "Level 4E - break stuff", "world4" },
			{ "world5", true, "World 5", "Splits" },
				{ "level41", true, "Level 41 - kick some ice", "world5" },
				{ "level42", true, "Level 42 - trapped under ice", "world5" },
				{ "level43", true, "Level 43 - frieza", "world5" },
				{ "level44", true, "Level 44 - mr frosty", "world5" },
				{ "level45", true, "Level 45 - palace", "world5" },
				{ "level46", true, "Level 46 - forward thinking", "world5" },
				{ "level47", true, "Level 47 - cross town traffic", "world5" },
				{ "level48", true, "Level 48 - blossom", "world5" },
				{ "level49", true, "Level 49 - positive energy", "world5" },
				{ "level50", true, "Level 50 - the thin icey", "world5" },
				{ "level5A", true, "Level 5A - simon", "world5" },
				{ "level5B", true, "Level 5B - be quick or be dead", "world5" },
				{ "level5C", true, "Level 5C - one way", "world5" },
				{ "level5D", true, "Level 5D - gridlock", "world5" },
				{ "level5E", true, "Level 5E - cold reception", "world5" },
			{ "world6", true, "World 6", "Splits" },
				{ "level51", true, "Level 51 - canned heat", "world6" },
				{ "level52", true, "Level 52 - crusher/destroyer", "world6" },
				{ "level53", true, "Level 53 - fyre", "world6" },
				{ "level54", true, "Level 54 - heating up", "world6" },
				{ "level55", true, "Level 55 - test icicles", "world6" },
				{ "level56", true, "Level 56 - instant transmission", "world6" },
				{ "level57", true, "Level 57 - road eyes", "world6" },
				{ "level58", true, "Level 58 - hot hot heat", "world6" },
				{ "level59", true, "Level 59 - flameboy", "world6" },
				{ "level60", true, "Level 60 - vanquish", "world6" },
				{ "level6A", true, "Level 6A - neverender", "world6" },
				{ "level6B", true, "Level 6B - hotscotch", "world6" },
				{ "level6C", true, "Level 6C - inside", "world6" },
				{ "level6D", true, "Level 6D - faster", "world6" },
				{ "level6E", true, "Level 6E - firestarter", "world6" },
			{ "world7", true, "World 7", "Splits" },
				{ "level61", true, "Level 61 - paradi$e", "world7" },
				{ "level62", true, "Level 62 - beaming", "world7" },
				{ "level63", true, "Level 63 - finelines", "world7" },
				{ "level64", true, "Level 64 - cooler world", "world7" },
				{ "level65", true, "Level 65 - mechazord", "world7" },
				{ "level66", true, "Level 66 - ethereal", "world7" },
				{ "level67", true, "Level 67 - loop de loop", "world7" },
				{ "level68", true, "Level 68 - chase the sun", "world7" },
				{ "level69", true, "Level 69 - pandemonium", "world7" },
				{ "level70", true, "Level 70 - sundowner", "world7" },
				{ "level7A", true, "Level 7A - neverender", "world7" },
				{ "level7B", true, "Level 7B - hotscotch", "world7" },
				{ "level7C", true, "Level 7C - inside", "world7" },
				{ "level7D", true, "Level 7D - faster", "world7" },
				{ "level7E", true, "Level 7E - firestarter", "world7" },
			{ "world8", true, "World 8", "Splits" },
				{ "level71", true, "Level 71 - spaced", "world8" },
				{ "level72", true, "Level 72 - crossfire", "world8" },
				{ "level73", true, "Level 73 - satallite", "world8" },
				{ "level74", true, "Level 74 - galaxy", "world8" },
				{ "level75", true, "Level 75 - bliss", "world8" },
				{ "level76", true, "Level 76 - heat", "world8" },
				{ "level77", true, "Level 77 - blazer", "world8" },
				{ "level78", true, "Level 78 - shield", "world8" },
				{ "level79", true, "Level 79 - sector x", "world8" },
				{ "level80", true, "Level 80 - axyz", "world8" },
				{ "level8A", true, "Level 8A - x & o", "world8" },
				{ "level8B", true, "Level 8B - the key, the secret", "world8" },
				{ "level8C", true, "Level 8C - fantastic", "world8" },
				{ "level8D", true, "Level 8D - gauntlet", "world8" },
				{ "level8E", true, "Level 8E - fin", "world8" },

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