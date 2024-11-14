state("PLAY PAPERHEAD"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Mouthwashing] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "PAPERHEAD EP0";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "SplitActioning", true, "Split Actioning", null },
			{ "onLevelSwap", true, "On Level Swap", "SplitActioning" },
			{ "onRankScreen", false, "On Rank Screen", "SplitActioning" },
		{ "SplitsLevels", true, "Level Splits", null },
			{ "ht_prologue_1_1", true, "Level 1", "SplitsLevels" },
			{ "ht_prologue_1_2", true, "Level 2", "SplitsLevels" },
			{ "ht_prologue_2_cut", true, "Level 3", "SplitsLevels" },
			{ "ht_prologue_3", true, "Level 4", "SplitsLevels" },
			{ "ht_prologue_4", true, "Level 5", "SplitsLevels" },
			{ "40_sl", true, "Level 6", "SplitsLevels"},
		{ "SplitsRankScreen", false, "Rank Screen Splits", null },
			{ "W4ke Up", true, "Level 1 - W4ke Up", "SplitsRankScreen" },
			{ "Volunt33r", true, "Level 2 - Volunt33r", "SplitsRankScreen" },
			{ "0bject 808", true, "Level 3 - 0bject 808", "SplitsRankScreen" },
			{ "Church", true, "Level 4 - Church", "SplitsRankScreen" },
			{ "Drone", true, "Level 5 - Drone", "SplitsRankScreen" },
			{ "40_srs", true, "Level 6 - Host", "SplitsRankScreen" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var GG = mono["GameGlobal"];
		var CGI = mono["Controls.GameInput"];
		vars.Helper["MovementInputTime"] = GG.Make<float>("Instance", "_input", CGI["_movementInputTime"]);
		vars.Helper["hasText"] = mono.Make<bool>("PPRHD_Game", 1, "Instance", "_levelEndScreen", "LevelName", "hasText");
		vars.Helper["latestText"] = mono.MakeString("PPRHD_Game", 1, "Instance", "_levelEndScreen", "LevelName", "latestText");
		vars.Helper["GameUIState"] = mono.Make<int>("PPRHD_UI", 1, "Instance", "GameUIState");
		
		return true;
	});

	current.activeScene = "";
	current.endScreen = "";
}

start
{
	return current.activeScene == "ht_prologue_0" && current.MovementInputTime > 0;
}

onStart
{
	vars.VisitedLevel.Clear();
	current.endScreen = "";
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if (old.GameUIState != current.GameUIState) vars.Log("GameUIState: " + current.GameUIState);

	if (settings["SplitsLevels"] && old.GameUIState == 0 && current.GameUIState == 40) 
	{
		current.endScreen = "40_sl";
	}
	else if (settings["SplitsRankScreen"] && old.GameUIState == 0 && current.GameUIState == 40) 
	{
		current.endScreen = "40_srs";
	}
}

split
{
	if (settings["SplitsLevels"] && old.activeScene != current.activeScene && settings[current.activeScene.ToString()] && !vars.VisitedLevel.Contains(current.activeScene.ToString()))
	{
		vars.VisitedLevel.Add(current.activeScene.ToString());
		return true;
	}
	if (settings["SplitsRankScreen"] && old.latestText != current.latestText && settings[current.latestText.ToString()] && !vars.VisitedLevel.Contains(current.latestText.ToString()))
	{
		vars.VisitedLevel.Add(current.latestText.ToString());
		return true;
	}

	if (old.endScreen != current.endScreen && settings[current.endScreen.ToString()] && !vars.VisitedLevel.Contains(current.endScreen.ToString()))
	{
		vars.VisitedLevel.Add(current.endScreen.ToString());
		return true;
	}
}

isLoading
{
	return current.hasText || current.GameUIState == 10;
}