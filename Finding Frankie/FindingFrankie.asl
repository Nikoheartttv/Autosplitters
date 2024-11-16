// Finding Frankie Autosplliter
// Developed by Lox and Nikoheart

state("FF_Train_test-Win64-Shipping") 
{
	bool bossflipped : "FF_Train_test-Win64-Shipping.exe", 0x07FE2548, 0x110, 0x68, 0xA0, 0x840, 0x90, 0x2F4;
	bool bossabletopull : "FF_Train_test-Win64-Shipping.exe", 0x07FE2548, 0x110, 0x68, 0xA0, 0x840, 0x90, 0x328;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Finding Frankie";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
        { "Inbounds", false, "Speedrun Category - Inbounds", null},
            { "frankie_pipe", true, "Falling Down Frankie Pipe", "Inbounds" },
			{ "has_deputy_duck", true, "Deputy Duck Pickup", "Inbounds" },
			{ "henry_hotline_chase_end", true, "Henry Hotline Chase End", "Inbounds" },
			{ "water_section_warp", true, "Water Section Warp", "Inbounds" },
			{ "lever_trampoline", true, "Hitting Level in Trampoline Park", "Inbounds" },
			{ "key_trampoline", true, "Collecting Key in Trampoline Park", "Inbounds" },
			{ "start_bossfight", true, "Start Hexa Havoc Bossfight", "Inbounds" },
			{ "end_bossfight_inb", true, "End Hexa Havoc Bossfight", "Inbounds" },
        { "OutOfBounds", false, "Speedrun Category - Out of Bounds", null },
            { "ElevatorPressed", true, "Elevator Button Pressed", "OutOfBounds" },
            { "end_bossfight_oob", true, "End Hexa Havoc Bossfight", "OutOfBounds" },
        { "AutoReset", true, "Auto-Reset when returning to Main Menu", null },
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
	var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);

	vars.Watcher = new FileSystemWatcher()
	{
		Path = localAppData + @"\FF_Train_test\Saved\SaveGames",
		Filter = "Key*.sav",
		EnableRaisingEvents = true
	};

	vars.Watcher.Changed += new FileSystemEventHandler((sender, e) => vars.CerealBoxKey = true);
	vars.CerealBoxKey = false;
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	vars.Helper["MovementMode"] = vars.Helper.Make<byte>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x2E0, 0x320, 0x201);
	vars.Helper["TransitionType"] = vars.Helper.Make<byte>(gEngine, 0xBBB);
	vars.Helper["Incutscene"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x2E0, 0xA28);
	vars.Helper["has_deputy_duck"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x338, 0x791);
	vars.Helper["bossbegun"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x2E0, 0xA58);
	vars.Helper["Curbreaker"] = vars.Helper.Make<int>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x2E0, 0xA0C);
	vars.Helper["Curbreaker"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Helper["TrampolineLever"] = vars.Helper.Make<bool>(gWorld, 0x30, 0x158, 0x60, 0x160, 0x60, 0x2EC);
	vars.Helper["TrampolineWonga"] = vars.Helper.Make<bool>(gWorld, 0x30, 0x158, 0x60, 0x160, 0x60, 0x378);
    vars.Helper["ElevatorButtonPress"] = vars.Helper.Make<bool>(gWorld, 0x30, 0x158, 0x60, 0x880, 0x60, 0x470);
	vars.Helper["POVX"] = vars.Helper.Make<double>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x348, 0x330);
	vars.Helper["POVY"] = vars.Helper.Make<double>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x348, 0x338);
	vars.Helper["POVZ"] = vars.Helper.Make<double>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x348, 0x340);
    
	vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

		// IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Helper.Read<short>(entry) >> 6;
		string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});

	current.World = "";
	vars.StartFlag = false;
	vars.FallingDownFrankiePipe = false;
	vars.IncutsceneAfterCurbreaker8 = false;
	vars.StartBossfight = 0;
	vars.BossFlippedLever = false;
	vars.BossReadyToPull = false;
	vars.TrampolineWon = false;
}

onStart
{
	vars.FallingDownFrankiePipe = false;
	vars.IncutsceneAfterCurbreaker8 = false;
	vars.StartBossfight = 0;
	vars.BossFlippedLever = false;
	vars.BossReadyToPull = false;
	vars.TrampolineWon = false;
	vars.CerealBoxKey = false;
	vars.CompletedSplits.Clear();
	timer.IsGameTimePaused = true;
}

start
{
	if (old.World == "FinalMenu" && current.World == "test1" || old.World == "game_intro" && current.World == "test1")
	{
		vars.StartFlag = true;
	}
	return vars.StartFlag == true && (old.MovementMode == 0 || old.MovementMode == 3) && current.MovementMode == 1;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

	if (current.POVY < -5300 && current.POVZ < -2400 && !vars.CompletedSplits.Contains("frankie_pipe")) vars.FallingDownFrankiePipe = true;
	if (vars.CompletedSplits.Contains("henry_hotline_chase_end") && old.Incutscene == true && current.Incutscene == false) vars.IncutsceneAfterCurbreaker8 = true;
	if (old.bossbegun == false && current.bossbegun == true) vars.StartBossfight++;
	if (old.TrampolineLever == false && current.TrampolineLever == true) vars.CerealBoxKey = false;
	if (settings["key_trampoline"] && old.TrampolineWonga == false && current.TrampolineWonga == true) vars.TrampolineWon = true;
	if (settings["start_bossfight"] && old.bossflipped == false && current.bossflipped == true && vars.CompletedSplits.Contains("start_bossfight"))
	{
		vars.BossFlippedLever = true;
	} 
    else if (!settings["start_bossfight"] && old.bossflipped == false && current.bossflipped == true && vars.StartBossFight >= 2)
	{
		vars.BossFlippedLever = true;
	}
    if (!settings["OutOfBounds"])
    {
        if (settings["start_bossfight"] && old.bossabletopull == false && current.bossabletopull == true && vars.CompletedSplits.Contains("start_bossfight"))
        {
            vars.BossReadyToPull = true;
        } 
        else if (!settings["start_bossfight"] && old.bossabletopull == false && current.bossabletopull == true && vars.StartBossFight >= 2)
        {
            vars.BossFlippedLever = true;
        }
    }
    else if (settings["OutOfBounds"] && old.bossabletopull == false && current.bossabletopull == true && vars.StartBossFight >= 2) vars.BossFlippedLever = true;
}

split
{
	if (settings["Inbounds"] && settings["frankie_pipe"] && !vars.CompletedSplits.Contains("frankie_pipe") && vars.FallingDownFrankiePipe == true && old.TransitionType == 1 && current.TransitionType == 0)
	{
		vars.CompletedSplits.Add("frankie_pipe");
		return true;
	}

	if (settings["Inbounds"] && settings["has_deputy_duck"] && !vars.CompletedSplits.Contains("has_deputy_duck") && old.has_deputy_duck != current.has_deputy_duck && current.has_deputy_duck == true)
	{
		vars.CompletedSplits.Add("has_deputy_duck");
		return true;
	}

	if (settings["Inbounds"] && settings["henry_hotline_chase_end"] && !vars.CompletedSplits.Contains("henry_hotline_chase_end") && old.Curbreaker == 8 && current.Curbreaker == 0)
	{
		vars.CompletedSplits.Add("henry_hotline_chase_end");
		return true;
	}

	if (settings["Inbounds"] && settings["water_section_warp"] && !vars.CompletedSplits.Contains("water_section_warp") && vars.CompletedSplits.Contains("henry_hotline_chase_end") && vars.IncutsceneAfterCurbreaker8 == true && old.Incutscene == false && current.Incutscene == true)
	{
		vars.CompletedSplits.Add("water_section_warp");
		return true;
	}

	if (settings["Inbounds"] && settings["lever_trampoline"] && !vars.CompletedSplits.Contains("lever_trampoline") && old.TrampolineLever == false && current.TrampolineLever == true)
	{
		vars.CompletedSplits.Add("lever_trampoline");
		return true;
	}

	if (settings["Inbounds"] && settings["key_trampoline"] && !vars.CompletedSplits.Contains("key_trampoline") && vars.TrampolineWon == true && vars.CerealBoxKey == true)
	{
		vars.CompletedSplits.Add("key_trampoline");
		return true;
	}

	if (settings["Inbounds"] && settings["start_bossfight"] && !vars.CompletedSplits.Contains("start_bossfight") && vars.StartBossfight >= 2)
	{
		vars.CompletedSplits.Add("start_bossfight");
		return true;
	}

	if (settings["ElevatorPressed"] && old.ElevatorButtonPress == false && current.ElevatorButtonPress == true)
	{
		vars.CompletedSplits.Add("ElevatorPressed");
		return true;
	}

	if ((settings["Inbounds"] || settings["OutOfBounds"]) && (settings["end_bossfight_inb"] || settings["end_bossfight_oob"]) && !vars.CompletedSplits.Contains("end_bossfight")
		&& vars.BossFlippedLever == true && vars.BossReadyToPull == true)
	{
		vars.CompletedSplits.Add("end_bossfight");
		return true;
	}
}

isLoading
{
	if (current.World == "FinalMenu")
	{
		return true;
	}
	else if (!current.Incutscene) return current.MovementMode == 0 || current.TransitionType == 1;
}

reset
{
	return settings["AutoReset"] && old.World == "test1" && current.World == "FinalMenu";
}