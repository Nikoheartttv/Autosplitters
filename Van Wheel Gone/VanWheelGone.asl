state("VanWheelGone-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Helper.GameName = "Van Wheel Gone";
	vars.Helper.AlertLoadless();
	
	dynamic[,] _settings =
	{
		{ "AutoReset", false, "Auto Reset on return to Main Menu or Try Again", null},
		{ "Splits", true, "Splits", null },
			{ "Lvl_Limbo", true, "Limbo", "Splits"},
			{ "Lvl_Lust", true, "Lust", "Splits"},
			{ "Lvl_Gluttony", true, "Gluttony", "Splits"},
			{ "Lvl_Greed", true, "Greed", "Splits"},
			{ "Lvl_Wrath", true, "Wrath", "Splits"},
			{ "Lvl_Heresy", true, "Heresy", "Splits"},
			{ "Lvl_Violence", true, "Violence", "Splits"},
			{ "Lvl_Fraud", true, "Fraud", "Splits"},
			{ "FinalBossGone", true, "Treachery", "Splits"},
		{ "LandInBetween", false, "Split on Landing in Between Levels", null}
	};
	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 48 8B 89 ???????? E8");
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");

    vars.Helper.Update();
	vars.Helper.MapPointers();

    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    IntPtr WB_SpeedFinished_C = vars.Events.InstancePtr("WB_SpeedFinished_C", "");
	vars.Helper["FinishedTimer"] = vars.Helper.Make<double>(WB_SpeedFinished_C, 0xAD0);
	vars.Helper["FinishedTimer"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Helper["GWorldName"] = vars.Helper.Make<uint>(gWorld, 0x18);
	vars.Helper["FinalBossGone"] = vars.Helper.Make<bool>(gEngine, 0x1248, 0x208, 0x800);
	vars.Helper["SpeedRunTimer"] = vars.Helper.Make<double>(gEngine, 0x1248, 0x308);

	current.SpeedRunTimer = 0.0;
	current.World = "";
	vars.LandInbetweenCount = 0;
	vars.TotalTime = TimeSpan.Zero;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	string world = vars.Events.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World && current.World == "LandInBetween") vars.LandInbetweenCount++;
}

start
{
    if ((old.World == "Lvl_Intro" || old.SpeedRunTimer == 0.0) && current.World != "Lvl_Intro" && current.SpeedRunTimer > 0.0)
        return true;
}

onStart
{
	vars.CompletedSplits.Clear();
	vars.TotalTime = TimeSpan.Zero;
	vars.LandInbetweenCount = 0;
	timer.IsGameTimePaused = true;
}

split
{
	if (old.World != "LandInBetween" && old.World != "Lvl_Intro" && current.World != "Lvl_Intro")
	{
		if (old.World != current.World && !vars.CompletedSplits.Contains(old.World))
		{
			vars.CompletedSplits.Add(old.World);
			vars.Log("Completed Splits: " + old.World);
			if (settings[old.World]) return true;
		}
	}
	
	if (old.World != current.World && old.World == "LandInBetween" 
		&& settings["LandInBetween"] && !vars.CompletedSplits.Contains("LandInBetween" + vars.LandInbetweenCount))
	{
		vars.CompletedSplits.Add("LandInBetween" + vars.LandInbetweenCount);
		vars.Log("Completed Land In Between Split");
		if (settings[old.World]) return true;
	}

	if (old.FinalBossGone != current.FinalBossGone && current.FinalBossGone == true && !vars.CompletedSplits.Contains("FinalBossGone"))
	{
		vars.CompletedSplits.Add("FinalBossGone");
		vars.Log("Completed Splits: Final Boss Gone");
		if (settings["FinalBossGone"]) return true;
	}
}

gameTime
{
    if (old.SpeedRunTimer > current.SpeedRunTimer && current.SpeedRunTimer == 0.0)
    {
        vars.TotalTime += TimeSpan.FromSeconds(old.SpeedRunTimer);
    }

    return vars.TotalTime + TimeSpan.FromSeconds(current.FinishedTimer > 0 ? current.FinishedTimer : current.SpeedRunTimer);
}

isLoading
{
    return true;
}

reset
{
	if (settings["AutoReset"] && (old.World != "Lvl_Intro" && current.World == "Lvl_Intro")) return true;
}
