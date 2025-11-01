state("VanWheelGone-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Helper.GameName = "Van Wheel Gone";
	vars.Helper.AlertLoadless();
	
	dynamic[,] _settings =
	{
		{ "AutoReset", false, "Auto Reset on return to Main Menu", null},
		{ "Splits", true, "Splits", null },
			{ "Levels", true, "Levels", "Splits"},
				{ "Lvl_Limbo", true, "Limbo", "Levels"},
				{ "Lvl_Lust", true, "Lust", "Levels"},
				{ "Lvl_Gluttony", true, "Gluttony", "Levels"},
				{ "Lvl_Greed", true, "Greed", "Levels"},
				{ "Lvl_Wrath", true, "Wrath", "Levels"},
				{ "Lvl_Heresy", true, "Heresy", "Levels"},
				{ "Lvl_Violence", true, "Violence", "Levels"},
				{ "Lvl_Fraud", true, "Fraud", "Levels"},
				{ "FinalBossGone", true, "Treachery", "Levels"},
			{ "CatsCollected", false, "Cats", "Splits" },
				{ "Cat1", true, "Cat 1 - Limbo", "CatsCollected" },
				{ "Cat2", true, "Cat 2 - Lust", "CatsCollected" },
				{ "Cat3", true, "Cat 3 - Gluttony", "CatsCollected" },
				{ "Cat4", true, "Cat 4 - Greed", "CatsCollected" },
				{ "Cat5", true, "Cat 5 - Wrath", "CatsCollected" },
				{ "Cat6", true, "Cat 6 - Heresy", "CatsCollected" },
				{ "Cat7", true, "Cat 7 - Violence", "CatsCollected" },
				{ "Cat8", true, "Cat 8 - Fraud", "CatsCollected" },
				{ "Cat9", true, "Cat 9 - Treachery", "CatsCollected" },
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
	vars.Helper["CatSpeedRunCheck"] = vars.Helper.Make<IntPtr>(gEngine, 0x1248, 0x390);
	vars.CatsCollected = new bool[9];

	current.SpeedRunTimer = 0.0;
	current.World = "";
	current.FinalBossGone = false;
	vars.LandInbetweenCount = 0;
	vars.TotalTime = TimeSpan.Zero;
}

start
{
    if ((old.World == "Lvl_Intro" || old.SpeedRunTimer == 0.0) && current.World != "Lvl_Intro" && current.SpeedRunTimer > 0.0)
        return true;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.TotalTime = TimeSpan.Zero;
	vars.CompletedSplits.Clear();
	vars.LandInbetweenCount = 0;
	for (int i = 0; i < vars.CatsCollected.Length; i++)
	{
		vars.CatsCollected[i] = false;
	}
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	string world = vars.Events.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World && current.World == "LandInBetween") vars.LandInbetweenCount++;
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

	if (current.CatSpeedRunCheck != IntPtr.Zero)
	{
		for (int i = 0; i < 9; i++)
		{
			bool isCollected = vars.Helper.Read<byte>(current.CatSpeedRunCheck + i) != 0;

			if (!vars.CatsCollected[i] && isCollected)
			{
				if (settings["Cat" + (i + 1)] && !vars.CompletedSplits.Contains("Cat" + (i + 1)))
				{
					vars.CompletedSplits.Add("Cat" + (i + 1));
					vars.Log("Cat" + (i + 1) + " collected! Split triggered.");
					return true;
				}
			}

			vars.CatsCollected[i] = isCollected;
		}
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
