state("LoneRuin") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Lone Ruin";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
    
	vars.visitedLevels = new List<string>();
    
	vars.lastLevel = 0;
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var gm = mono["GameManager", 1];
		var rm = mono["RunManager", 1];
		var lvl = mono["Level"];
		var p = mono["Player"];

		vars.Helper["IGPause"] = gm.Make<int>("_instance", "pausers", 0xc);
		vars.Helper["runStartTime"] = rm.Make<float>("_instance", "runStartTime");
		vars.Helper["Level"] = rm.MakeString("_instance", "CurrentLevel", lvl["Name"]);
		vars.Helper["ControlState"] = rm.Make<int>("_instance", "Player", p["State"]);
		vars.Helper["pausers"] = gm.MakeList<IntPtr>("_instance", "pausers");
		vars.Helper["instance"] = gm.Make<IntPtr>("_instance");

		return true;
	});

	current.lastLevelPauses = 0;
	vars.Scene = "";
}

update
{
	current.Paused = vars.Helper["pausers"].Current.Count > 0;
	if (old.Paused != current.Paused) vars.Log(current.Paused);
	// current.Count = memory.ReadValue<int>((IntPtr)current.pausers[0] + 0x20);
	// vars.Log(current.instance.ToString("X"));
	current.Scene = vars.Helper.Scenes.Active.Name;
	if (old.Scene != current.Scene) print("Scene Change: " + current.Scene);
	if (old.runStartTime != current.runStartTime) vars.Log("runStartTime change: " + current.runStartTime.ToString());
	if (old.Level != current.Level) vars.Log("Level change: " + current.Level.ToString());
	if (old.ControlState != current.ControlState) vars.Log("ControlState change: " + current.ControlState.ToString());
	if (vars.lastLevel == 1 && old.ControlState != 1 && current.ControlState == 1) current.lastLevelPauses++;
	if (current.lastLevelPauses != old.lastLevelPauses) vars.Log("LastLevelPauses update: " + current.lastLevelPauses.ToString());
	
 	if ((old.Level != current.Level) &&
	(current.Level == "Goop Temple - 7/8"
	|| current.Level == "Slijmtempel - 7/8"
	|| current.Level == "Temple souillé - 7/8"
	|| current.Level == "Schleimtempel - 7/8"
	|| current.Level == "汚染の寺院 - 7/8"
	|| current.Level == "끈적이는 사원 - 7/8"
	|| current.Level == "Templi pringoso - 7/8"
	|| current.Level == "古普寺 - 7/8"
	|| current.Level == "黏稠神廟 - 7/8"
	|| current.Level == "Templo de Gosma - 7/8"))
	{
 		vars.lastLevel = 1;
		vars.Log("LastLevel change: " + vars.lastLevel.ToString());
	}
}

start
{
	return current.ControlState == 2;
}

onStart
{
	if (current.ControlState != 2) timer.IsGameTimePaused = true;
	current.lastLevelPauses = 0;
	vars.lastLevel = 0;
	vars.visitedLevels.Add(current.Level);
	vars.Log("START");
}

split
{
	if (vars.lastLevel == 1 && current.lastLevelPauses > 1) return true;
	if ((old.Level != current.Level) && (!vars.visitedLevels.Contains(current.Level)))
	{
		return true;
		vars.Log("SPLIT");
	}
}

reset
{
    return old.runStartTime > 0 && current.runStartTime == 0;
}

onReset
{
    vars.lastLevel = 0;
    vars.Log("RESETTING");
}

isLoading
{
    return current.ControlState == 1 || current.Paused;
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}
