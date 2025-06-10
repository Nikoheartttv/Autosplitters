state("AzaranDemo") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Azaran: Island of the Jinn";
	vars.Helper.LoadSceneManager = true;
    vars.Helper.AlertRealTime();

    dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "300", false, "Throw Puzzle Solved", "Splits" },
			{ "310", false, "Fountain Puzzle Solved", "Splits" },
			{ "101", true, "Shield & Sword Get", "Splits" },
			{ "301", false, "Sword Arena Completed", "Splits" },
			{ "302", false, "Tunnel Worm Defeated", "Splits" },
			{ "102", true, "Bow Get", "Splits" },
			{ "304", false, "Bow Pool Cliffs Unlocked", "Splits" },
			{ "309", false, "Beginning Room opened with bow", "Splits" },
			{ "801", false, "Archery Token 01 - Bow Upgrade", "Splits" },
			{ "306", false, "UnusedB??", "Splits" },
			{ "831", false, "Corum 01 - Veil Between Planes Wears Thin??????", "Splits" },
			{ "303", false, "Boulder Worm Defeated", "Splits" },
			{ "313", false, "Bomb Pot Boss Defeated", "Splits" },
			{ "103", true, "Bombs Get", "Splits" },
			{ "811", false, "Blast Token 01 - Bomb Upgrade", "Splits" },
			{ "308", false, "Boulders Exit Exploded", "Splits" },
			{ "833", false, "Corum 03 - Veil Between Planes Wears Thin??????", "Splits" }, 
			{ "311", false, "Prep Room Unlocked", "Splits"},
			{ "EndSplit", true, "Split upon entering Boss Sequence", "Splits" },
	};

    vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        // vars.Helper["isPaused"] = mono.Make<bool>("GameController", "instance", "menuPaused");
        vars.Helper["cutscenePaused"] = mono.Make<bool>("GameController", "instance", "cutscenePaused");
        vars.Helper["loadTime"] = mono.Make<float>("GameController", "instance", "loadTime");
        vars.Helper["roomName"] = mono.MakeString("SceneController", "instance", "debugRoom", "m_text");
        vars.Helper["roomName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
        vars.Helper["SaveFlags"] = mono.MakeList<int>("GameController", "instance", "saveData", "flags");
        vars.Helper["timeInStatePuzzleSolve"] = mono.Make<float>("StateMachine", "instance", "sPuzzleSolve", "timeInState");

		return true;
	});
    current.loadTime = 0;
    current.roomName = "";
}

start
{
    return old.loadTime != current.loadTime;
}

onStart
{
	vars.CompletedSplits.Clear();
}

update
{
    if (old.loadTime != current.loadTime) vars.Log("Load Time: " + current.loadTime);
    if (old.roomName != current.roomName) vars.Log("Room Name: " + current.roomName);
    if (vars.Helper["SaveFlags"].Current.Count > vars.Helper["SaveFlags"].Old.Count)
	{
		int s = vars.Helper["SaveFlags"].Current[vars.Helper["SaveFlags"].Current.Count - 1];
        vars.Log("Save Flag: " + s);
	}
}

split
{
    if (vars.Helper["SaveFlags"].Current.Count > vars.Helper["SaveFlags"].Old.Count)
	{
		int s = vars.Helper["SaveFlags"].Current[vars.Helper["SaveFlags"].Current.Count - 1];
		if (settings[s.ToString()] && !vars.CompletedSplits.Contains(s.ToString())) 
        {
            vars.CompletedSplits.Add(s.ToString());
            return true;
	    }
    }

    if (current.roomName == "Rm_Caves_Boss" && current.timeInStatePuzzleSolve != 0 && settings["EndSplit"] && !vars.CompletedSplits.Contains("EndSplit")) 
    {
        vars.CompletedSplits.Add("EndSplit");
        return true;
    }
}