state("PAPERHEAD"){}

startup
{
    vars.Log = (Action<object>)(output => print("[PAPERHEAD] " + output));
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "PAPERHEAD";
    vars.Helper.LoadSceneManager = true;

    dynamic[,] _settings =
    {
		{ "ILMode", false, "Individual Level Splitting - Mode Toggle", null },
        { "SplitsLevels", true, "Level Splits", null },
            { "1", true, "Chapter 1: TH3 D3SC3ND", "SplitsLevels" },
            { "2", true, "Chpater 2: PRØJ3CT G,3,P,P,3,T,T,0", "SplitsLevels" },
            { "3", true, "Chapter 3: ØBJ3CT 808", "SplitsLevels" },
            { "4", true, "Chapter 4: L3T's T4LK", "SplitsLevels" },
            { "5", true, "Chapter 5: SUBJ3CTZ", "SplitsLevels" },
            { "6", true, "Chapter 6: TH3 SH3LT3R", "SplitsLevels"},
			{ "7", true, "Chapter 7: HUNT1NG GRØUNDS", "SplitsLevels"},
			{ "8", true, "Chapter 8: ØN TH3 W4Y TØ...?", "SplitsLevels"},
			{ "9", true, "Chapter 9: TH3 F4RM", "SplitsLevels"},
			{ "10", true, "Chapter 10: NØ DATA / CRITICAL ERROR", "SplitsLevels"},
			{ "11", true, "Chapter 11: DEPTH DWELL3R", "SplitsLevels"},
			{ "12", true, "Chapter 12: BRØK3N P4PER M4N", "SplitsLevels"},
			{ "13", true, "Chapter 13: G.PRJ HQ", "SplitsLevels"},
			{ "14", true, "Chapter 14: N3W PRØJ3CT", "SplitsLevels"},
			{ "15", true, "Chapter 15: V1V1S3CTØR", "SplitsLevels"},
			{ "16", true, "Chapter 16: R1TU4LS", "SplitsLevels"},
			{ "17", true, "Chapter 17: 4SSALT", "SplitsLevels"},
			{ "18", true, "Chapter 18: THE M4NAGER", "SplitsLevels"},
        { "AutoReset", false, "Auto Reset on New Game or Load Last Checkpoint (IL Mode Only)", null },
    };

    vars.Helper.Settings.Create(_settings);
    vars.Helper.AlertLoadless();
    vars.VisitedLevel = new List<string>();
    vars.TotalTime = 0.0f;
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        var AD = mono["AutosplitData"];
        vars.Helper["state"] = AD.Make<int>("state");
        vars.Helper["stateID"] = AD.Make<int>("stateId");
        vars.Helper["levelName"] = AD.MakeString("levelName");
        vars.Helper["levelID"] = AD.Make<int>("levelID");   
        vars.Helper["isRunning"] = AD.Make<int>("isRunning");
        vars.Helper["inGameTime"] = AD.Make<double>("inGameTime");
        return true;
    });
}

start
{
    vars.TotalTime = 0.0f;

    if (settings["ILMode"])
    {
        if (current.levelID == 1 && old.stateID == 6 && current.stateID == 2) return true;
        if (current.levelID != 1 && old.stateID == 3 && current.stateID == 2) return true;
    }
    return !settings["ILMode"] && old.stateID == 6 && current.stateID == 2;
}

onStart
{
    vars.VisitedLevel.Clear();
    vars.TotalTime = 0.0f;
}

update
{
    if (current.inGameTime < old.inGameTime)
    {
        vars.TotalTime += old.inGameTime;
    }	
}

gameTime
{
    return TimeSpan.FromSeconds(current.inGameTime + vars.TotalTime);
}

split
{
	if (settings["SplitsLevels"] && settings[current.levelID.ToString()] && current.stateID == 4 && settings[current.levelID.ToString()] && !vars.VisitedLevel.Contains(current.levelID.ToString()))
	{
		vars.VisitedLevel.Add(current.levelID.ToString());
		return true;
	}
}

isLoading
{
    return true;
}

reset
{
	if (settings["ILMode"])
	{
		if (old.stateID == 7 && current.stateID == 3) return true;
	}
	else if (!settings["ILMode"]) 
	{
		if (old.stateID != 0 && current.stateID == 0) return true;
		if (current.levelID == 1 && old.stateID == 7 && current.stateID == 3) return true;
	}
}

onReset
{
	vars.TotalTime = 0.0f;
}