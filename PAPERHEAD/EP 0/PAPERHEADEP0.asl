state("PLAY PAPERHEAD"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Mouthwashing] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "PAPERHEAD EP0";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "ILMode", false, "Individual Level Splitting - Mode Toggle", null },
		{ "SplitActioning", true, "Split Actioning", null },
			{ "onLevelSwap", true, "On Level Swap", "SplitActioning" },
			{ "onRankScreen", false, "On Rank Screen", "SplitActioning" },
		{ "SplitsLevels", true, "Level Splits", null },
			{ "2", true, "Level 1", "SplitsLevels" },
			{ "3", true, "Level 2", "SplitsLevels" },
			{ "4", true, "Level 3", "SplitsLevels" },
			{ "5", true, "Level 4", "SplitsLevels" },
			{ "6", true, "Level 5", "SplitsLevels" },
			{ "6_end", true, "Level 6", "SplitsLevels"},
		{ "SplitsRankScreen", false, "Rank Screen Splits", null },
			{ "W4ke Up", true, "Level 1 - W4ke Up", "SplitsRankScreen" },
			{ "Volunt33r", true, "Level 2 - Volunt33r", "SplitsRankScreen" },
			{ "0bject 808", true, "Level 3 - 0bject 808", "SplitsRankScreen" },
			{ "Church", true, "Level 4 - Church", "SplitsRankScreen" },
			{ "Drone", true, "Level 5 - Drone", "SplitsRankScreen" },
			{ "Host", true, "Level 6 - Host", "SplitsRankScreen" },
		{ "AutoReset", false, "Auto Reset on New Game or Load Last Checkpoint (IL Mode Only)", null },
	};

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var AD = mono["AutosplitData"];
		vars.Helper["state"] = AD.Make<int>("state");
        vars.Helper["stateName"] = AD.MakeString("stateName");
        vars.Helper["stateID"] = AD.Make<int>("stateId");
		vars.Helper["levelName"] = AD.MakeString("levelName");
		vars.Helper["levelID"] = AD.Make<int>("levelID");	
        vars.Helper["isRunning"] = AD.Make<int>("isRunning");
		return true;
	});
}

start
{
	if (settings["ILMode"])
	{
		if (current.levelID == 1 && old.stateName == "Cinematic" && current.stateName == "Play") return true;
		if (current.levelID != 1 && old.stateName == "Loading" && current.stateName == "Play") return true;
	}
	return !settings["ILMode"] && old.state == 6 && current.state == 2;
}

onStart
{
	vars.VisitedLevel.Clear();
}

split
{
	if (settings["ILMode"])
	{
		return old.stateName == "Play" && current.stateName == "Victory" 
		|| current.levelID == 6 && old.stateName == "Play" && current.stateName == "Cinematic";
	}
	else if (!settings["ILMode"])
	{
		if (settings["SplitsLevels"] && old.levelID != current.levelID && settings[current.levelID.ToString()] && !vars.VisitedLevel.Contains(current.levelID.ToString()))
		{
			vars.VisitedLevel.Add(current.levelID.ToString());
			return true;
		}
		if (settings["SplitsLevels"] && current.levelID == 6 && old.state == 2 && current.state == 6 && settings["6_end"] && !vars.VisitedLevel.Contains("6_end"))
		{
			vars.VisitedLevel.Add("6_end");
			return true;
		}
		if (settings["SplitsRankScreen"] && old.state == 2 && current.state == 4 && settings[current.levelName.ToString()] && !vars.VisitedLevel.Contains(current.levelName.ToString()))
		{
			vars.VisitedLevel.Add(current.levelName.ToString());
			return true;
		}
		if (settings["SplitsRankScreen"] && current.levelName == "Host" && old.state == 2 && current.state == 6 && settings[current.levelName.ToString()] && !vars.VisitedLevel.Contains(current.levelName.ToString()))
		{
			vars.VisitedLevel.Add(current.levelName.ToString());
			return true;
		}
	}
}

isLoading
{
	return current.state == 1 || current.state >= 3;
}

reset
{
	if (settings["ILMode"])
	{
		if (old.stateName == "Pause" && current.stateName == "Loading") return true;
	}
	else if (!settings["ILMode"]) 
	{
		if (old.stateName != "Menu" && current.stateName == "Menu") return true;
		if (current.levelID == 1 && old.stateName == "Pause" && current.stateName == "Loading") return true;
	}
}