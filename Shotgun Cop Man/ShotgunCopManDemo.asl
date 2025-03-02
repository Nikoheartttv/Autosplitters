state("Shotgun Cop Man Demo"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Shotgun Cop Man (Demo)";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "Level0", true, "Level 0", "Splits"},
				{ "10", true, "Level 0-1", "Level0" },
				{ "11", true, "Level 0-2", "Level0" },
				{ "12", true, "Level 0-3", "Level0" },
				{ "8", true, "Level 0-4", "Level0" },
				{ "13", true, "Level 0-5", "Level0" },
				{ "14", true, "Level 0-6", "Level0" },
				{ "15", true, "Level 0-7", "Level0" },
				{ "188", true, "Level 0-8", "Level0" },
				{ "16", true, "Level 0-9", "Level0" },
			{ "Level1", true, "Level 1", "Splits"},
				{ "17", true, "Level 1-1", "Level1" },
				{ "22", true, "Level 1-2", "Level1" },
				{ "51", true, "Level 1-3", "Level1" },
				{ "20", true, "Level 1-4", "Level1" },
				{ "52", true, "Level 1-5", "Level1" },
				{ "53", true, "Level 1-6", "Level1" },
				{ "54", true, "Level 1-7", "Level1" },
				{ "55", true, "Level 1-8", "Level1" },
				{ "50", true, "Level 1-9", "Level1" },
				{ "23", true, "Level 1-10", "Level1" },
				{ "146", true, "Level 1-11", "Level1" },
				{ "144", true, "Level 1-12", "Level1" },
				{ "141", true, "Level 1-13", "Level1" },
				{ "142", true, "Level 1-14", "Level1" },
				{ "143", true, "Level 1-15", "Level1" },
				{ "145", true, "Level 1-16", "Level1" },
				{ "36", true, "Level 1-17 (Boss)", "Level1" },
			{ "SteamNextFest1", true, "Steam Next Fest 1", "Splits"},
				{ "Steam Next Fest 11", true, "Steam Next Fest 1-1", "Level1" },
				{ "Steam Next Fest 12", true, "Steam Next Fest 1-2", "Level1" },
				{ "Steam Next Fest 13", true, "Steam Next Fest 1-3", "Level1" },
				{ "Steam Next Fest 14", true, "Steam Next Fest 1-4", "Level1" },
				{ "Steam Next Fest 15", true, "Steam Next Fest 1-5", "Level1" },
			{ "SteamNextFest2", true, "Steam Next Fest 2", "Splits"},
				{ "Steam Next Fest 21", true, "Steam Next Fest 2-1", "Level1" },
				{ "Steam Next Fest 22", true, "Steam Next Fest 2-2", "Level1" },
				{ "Steam Next Fest 23", true, "Steam Next Fest 2-3", "Level1" },
				{ "Steam Next Fest 24", true, "Steam Next Fest 2-4", "Level1" },
				{ "Steam Next Fest 25", true, "Steam Next Fest 2-5", "Level1" },
			{ "SteamNextFest3", true, "Steam Next Fest 3", "Splits"},
				{ "Steam Next Fest 31", true, "Steam Next Fest 3-1", "Level1" },
				{ "Steam Next Fest 32", true, "Steam Next Fest 3-2", "Level1" },
				{ "Steam Next Fest 33", true, "Steam Next Fest 3-3", "Level1" },
				{ "Steam Next Fest 34", true, "Steam Next Fest 3-4", "Level1" },
				{ "Steam Next Fest 35", true, "Steam Next Fest 3-5", "Level1" },
			{ "SteamNextFest4", true, "Steam Next Fest 4", "Splits"},
				{ "Steam Next Fest 41", true, "Steam Next Fest 4-1", "Level1" },
				{ "Steam Next Fest 42", true, "Steam Next Fest 4-2", "Level1" },
				{ "Steam Next Fest 43", true, "Steam Next Fest 4-3", "Level1" },
				{ "Steam Next Fest 44", true, "Steam Next Fest 4-4", "Level1" },
				{ "Steam Next Fest 45", true, "Steam Next Fest 4-5", "Level1" },
			{ "SteamNextFest5", true, "Steam Next Fest 5", "Splits"},
				{ "Steam Next Fest 51", true, "Steam Next Fest 5-1", "Level1" },
				{ "Steam Next Fest 52", true, "Steam Next Fest 5-2", "Level1" },
				{ "Steam Next Fest 53", true, "Steam Next Fest 5-3", "Level1" },
				{ "Steam Next Fest 54", true, "Steam Next Fest 5-4", "Level1" },
				{ "Steam Next Fest 55", true, "Steam Next Fest 5-5", "Level1" },
			{ "SteamNextFest6", true, "Steam Next Fest 6", "Splits"},
				{ "Steam Next Fest 61", true, "Steam Next Fest 6-1", "Level1" },
				{ "Steam Next Fest 62", true, "Steam Next Fest 6-2", "Level1" },
				{ "Steam Next Fest 63", true, "Steam Next Fest 6-3", "Level1" },
				{ "Steam Next Fest 64", true, "Steam Next Fest 6-4", "Level1" },
				{ "Steam Next Fest 65", true, "Steam Next Fest 6-5", "Level1" },
			{ "SteamNextFest7", true, "Steam Next Fest 7", "Splits"},
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

	vars.ILTimes = new Dictionary<string, float>
	{
		{ "10", 0 },
		{ "11", 0 },
		{ "12", 0 },
		{ "8", 0 },
		{ "13", 0 },
		{ "14", 0 },
		{ "15", 0 },
		{ "188", 0 },
		{ "16", 0 },
		{ "3", 0 },
		{ "17", 0 },
		{ "22", 0 },
		{ "51", 0 },
		{ "20", 0 },
		{ "52", 0 },
		{ "53", 0 },
		{ "54", 0 },
		{ "55", 0 },
		{ "50", 0 },
		{ "23", 0 },
		{ "146", 0 },
		{ "144", 0 },
		{ "141", 0 },
		{ "142", 0 },
		{ "143", 0 },
		{ "145", 0 },
		{ "36", 0 }
	};

	vars.IntroLevels = new List<string>
	{ "10", "11", "12", "8", "13", "14", "15", "188", "16", "3" };
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		vars.Helper["lvlName"] = mono.MakeString("LvlBuilderScript", "lvlName");
		vars.Helper["worldLvlName"] = mono.MakeString("WorldMapScript", "instance", "levelText", "m_text");
        vars.Helper["time"] = mono.Make<float>("RootScript", "rootInstance", "time");
        vars.Helper["totalTime"] = mono.MakeString("InGameTimerScript", "instance", "totalTimeText", "m_text");
		vars.Helper["beenTriggered"] = mono.Make<bool>("RatingScreenScript", "instance", "beenTriggered");
		vars.Helper["lvlBuiltAtTime"] = mono.Make<float>("LvlBuilderScript", "instance", "lvlBuiltAtTime");
		vars.Helper["isGeneralOptionsMenu"] = mono.Make<bool>("GameOptionsHandler", "instance", "isGeneralOptionsMenu");
		vars.Helper["activeCampaignName"] = mono.MakeString("CampaignHandler", "activeCampaign", "name");
		return true;
	});
	vars.FullRun = false;
	current.Lvl0Start = "00:00:00.00";
}

onStart
{
	if (vars.FullRun == true)
	{
		vars.StartTime = TimeSpan.Parse(current.Lvl0Start);
	}
	else if (vars.FullRun == false)
	{
		vars.StartTime = TimeSpan.Parse(current.totalTime);
	}
	timer.IsGameTimePaused = true;
	vars.VisitedLevel.Clear();
}

start
{
	// return old.lvlBuiltAtTime != current.lvlBuiltAtTime;
	return TimeSpan.Parse(old.totalTime) < TimeSpan.Parse(current.totalTime);
}

split
{
	// Intro Levels
	if (current.activeCampaignName == "" && old.lvlName != current.lvlName && vars.IntroLevels.Contains(old.lvlName)
		&& settings[old.lvlName.ToString()] && !vars.VisitedLevel.Contains(old.lvlName.ToString()))
		{
			vars.VisitedLevel.Add(old.lvlName.ToString());
			return settings[old.lvlName.ToString()];
		}

	// World 1 Levels
	if (current.activeCampaignName == "" && !old.beenTriggered && current.beenTriggered && settings[current.lvlName.ToString()] && !vars.VisitedLevel.Contains(current.lvlName.ToString()))
	{
		vars.VisitedLevel.Add(current.lvlName.ToString());
		return settings[current.lvlName.ToString()];
	}

	// Bonus Campaigns
	if (current.activeCampaignName.Contains("Steam Next Fest") && !old.beenTriggered && current.beenTriggered && settings[current.activeCampaignName + current.lvlName.ToString()] && !vars.VisitedLevel.Contains(current.activeCampaignName + current.lvlName.ToString()))
	{
		vars.VisitedLevel.Add(current.activeCampaignName + current.lvlName.ToString());
		return settings[current.activeCampaignName + current.lvlName.ToString()];
	}
}

update
{
	if (old.isGeneralOptionsMenu != current.isGeneralOptionsMenu && current.isGeneralOptionsMenu == false)
	{
		vars.FullRun = true;
	}
	if (old.lvlName != current.lvlName) vars.Log("lvlName: " + current.lvlName);
	if (old.activeCampaignName != current.activeCampaignName) vars.Log("Active Campaign: " + current.activeCampaignName);
}

isLoading
{
	return true;
}

gameTime
{
	return TimeSpan.Parse(current.totalTime) - vars.StartTime;
}

reset
{
	return settings["Autoreset"] && old.isGeneralOptionsMenu && !current.isGeneralOptionsMenu;
}

onReset
{
	vars.FullRun = false;
}