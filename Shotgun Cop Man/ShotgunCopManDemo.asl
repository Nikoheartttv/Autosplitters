
state("Shotgun Cop Man Demo"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Shotgun Cop Man (Demo)";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "11", true, "Level 0-1", "Splits" },
			{ "12", true, "Level 0-2", "Splits" },
			{ "8", true, "Level 0-3", "Splits" },
			{ "13", true, "Level 0-4", "Splits" },
			{ "14", true, "Level 0-5", "Splits" },
			{ "15", true, "Level 0-6", "Splits" },
			{ "188", true, "Level 0-7", "Splits" },
			{ "16", true, "Level 0-8", "Splits" },
			{ "3", true, "Level 0-9", "Splits" },
			{ "17", true, "Level 1-1", "Splits" },
			{ "22", true, "Level 1-2", "Splits" },
			{ "51", true, "Level 1-3", "Splits" },
			{ "20", true, "Level 1-4", "Splits" },
			{ "52", true, "Level 1-5", "Splits" },
			{ "53", true, "Level 1-6", "Splits" },
			{ "54", true, "Level 1-7", "Splits" },
			{ "55", true, "Level 1-8", "Splits" },
			{ "50", true, "Level 1-9", "Splits" },
			{ "23", true, "Level 1-10", "Splits" },
			{ "146", true, "Level 1-11", "Splits" },
			{ "144", true, "Level 1-12", "Splits" },
			{ "141", true, "Level 1-13", "Splits" },
			{ "142", true, "Level 1-14", "Splits" },
			{ "143", true, "Level 1-15", "Splits" },
			{ "145", true, "Level 1-16", "Splits" },
			{ "36", true, "Level 1-17 (Boss)", "Splits" },
		{ "Autoreset", false, "Auto-Reset when going into Main Menu", null },
	};
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();
	vars.VisitedLevel = new List<string>();

	vars.deadTime = (float)0;
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
		vars.Helper["beenTriggered"] = mono.Make<bool>("RatingScreenScript", "instance", "beenTriggered");
		vars.Helper["dead"] = mono.Make<bool>("PlayerScript", "instance", "dead");
		vars.Helper["time"] = mono.Make<float>("RootScript", "rootInstance", "time");
		vars.Helper["IGTpaused"] = mono.Make<bool>("RootScript", "rootInstance", "paused");
		vars.Helper["totalTime"] = mono.MakeString("InGameTimerScript", "instance", "totalTimeText", "m_text");
		vars.Helper["lvlBuiltAtTime"] = mono.Make<float>("LvlBuilderScript", "instance", "lvlBuiltAtTime");
		return true;
	});
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.VisitedLevel.Clear();
	vars.deadTime = (float)0;
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
}

start
{
	return current.lvlName == "10" && old.lvlBuiltAtTime != current.lvlBuiltAtTime;
}

update
{
	if (vars.ILTimes.ContainsKey(current.lvlName) && 
		current.time > vars.ILTimes[current.lvlName] && current.time < vars.ILTimes[current.lvlName] + 3)
	{
		vars.ILTimes[current.lvlName] = current.time;
	}
	
	if (current.dead)
	{
		vars.deadTime += vars.ILTimes[current.lvlName];
		vars.ILTimes[current.lvlName] = 0;
	}
}

split
{
	// Intro Levels
	if (old.lvlName != current.lvlName && vars.IntroLevels.Contains(old.lvlName)
		&& settings[old.lvlName.ToString()] && !vars.VisitedLevel.Contains(old.lvlName.ToString()))
		{
			vars.VisitedLevel.Add(old.lvlName.ToString());
			vars.Log("INTRO SPLIT DONE");
			return settings[old.lvlName.ToString()];
		}

	// World 1 Levels
	if (!old.beenTriggered && current.beenTriggered && settings[current.lvlName.ToString()] && !vars.VisitedLevel.Contains(current.lvlName.ToString()))
	{
		vars.VisitedLevel.Add(current.lvlName.ToString());
		vars.Log("MAIN SPLIT DONE");
		return settings[current.lvlName.ToString()];
	}
}

isLoading
{
	return true;
}

gameTime
{
	return TimeSpan.Parse(current.totalTime);
	float totalTime = 0;
	foreach (var key in vars.ILTimes.Keys)
	{
		totalTime += vars.ILTimes[key];
	}
	totalTime += vars.deadTime;
	return TimeSpan.FromSeconds(totalTime);
}