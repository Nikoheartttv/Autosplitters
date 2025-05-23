state("KarmaU54-Win64-Shipping") { }

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Karma: The Dark World";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "ActOne", true, "Act One", "Splits" },
				{ "SC003", true, "Act 1 - Ward", "ActOne" },
				{ "SC005", true, "Act 1 - Cultivation", "ActOne" },
				{ "C01", true, "Act 1 - Blackwater", "ActOne" },
			{ "ActTwoPartOne", true, "Act Two - Part One", "Splits" },
				{ "Corridor", true, "Act 2-1 - Research Institute", "ActTwoPartOne" },
				{ "PT_Start", true, "Act 2-1 - Investigation", "ActTwoPartOne" },
				{ "NightStreet", true, "Act 2-1 - Guilty", "ActTwoPartOne" },
				{ "HomeRoom", true, "Act 2-1 - Night Street", "ActTwoPartOne" },
				{ "HallPast_01", true, "Act 2-1 - Thought Bureau", "ActTwoPartOne" },
				{ "Analog_05", true, "Act 2-1 - Monster", "ActTwoPartOne" },
				{ "Interrogatoion_Ch01_02", true, "Act 2-1 - Work", "ActTwoPartOne" },
				{ "B3_AfterWind", true, "Act 2-1 - Trade", "ActTwoPartOne" },
				{ "DanielhouseMemo1", true, "Act 2-1 - Nightmare", "ActTwoPartOne" },
				{ "BathRoom", true, "Act 2-1 - Childhood", "ActTwoPartOne" },
			{ "ActTwoPartTwo", true, "Act Two - Part Two", "Splits" },
				{ "DanielHouse_1F_WakeUp", true, "Act 2-2 - Home Room", "ActTwoPartOne" },
				{ "DanielHouse_B1_AfterCam", true, "Act 2-2 - Mom", "ActTwoPartTwo" },
				{ "RachelHouse", true, "Act 2-2 - Illusion", "ActTwoPartTwo" },
				{ "Alley", true, "Act 2-2 - Filthy", "ActTwoPartTwo" },
				{ "WhiteCore_Paradise", true, "Act 2-2 - Freedom", "ActTwoPartTwo" },
				{ "RachelBossFight_Intro", true, "Act 2-2 - Love", "ActTwoPartTwo" },
				{ "FredOffice_Rachel", true, "Act 2-2 - Heart", "ActTwoPartTwo" },
				{ "SC301_FredOffice", true, "Act 2-2 - The Lamb's", "ActTwoPartTwo" },
			{ "ActThree", true, "Act Three", "Splits" },
				{ "SC302_DivingRoom", true, "Act 3 - Amber Blood", "ActThree" },
				{ "SC302_Father_Chasing", true, "Act 3 - Truth", "ActThree" },
				{ "SC302_Lisa_Tunnel", true, "Act 3 - Virus", "ActThree" },
				{ "End", true, "Act 3 - Siblings", "ActThree" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
}

onStart
{
	vars.CompletedSplits.Clear();
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(10, "80 7C 24 ?? 00 ?? ?? 48 8B 3D ???????? 48");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 89 05 ???????? 48 85 c9 74 ?? e8 ???????? 48 8d 4d");
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ?? ?? ?? ?? EB");

	if (gWorld == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}
	// GWorld.FNameIndex
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
    // GWorld.OwningGameInstance.AcknowledgedPawn.GameProgress
    vars.Helper["GameProgress"] = vars.Helper.Make<byte>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x338, 0x996);
	// GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.AcknowledgedPawn.NoControl
	vars.Helper["NoControl"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x338, 0x900);
	// GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.AcknowledgedPawn.IsDie
	vars.Helper["IsDie"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x338, 0x995);
	// // GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.AcknowledgedPawn.CurrentPlayStartID
    vars.Helper["CurrentPlayStartID"] = vars.Helper.Make<ulong>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x338, 0xA0C);
	// GWorld.OwningGameInstance.stopParam
	vars.Helper["stopParam"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x378);
	// GWorld.OwningGameInstance.inMainMenu
	vars.Helper["inMainMenu"] = vars.Helper.Make<bool>(gWorld, 0x1D8, 0x37A);
	vars.Helper["bPlayerIsWaiting"] = vars.Helper.Make<int>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x4B0);
	//GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.AcknowledgedPawn.CameraGun.
	vars.Helper["FinalCameraShot"] = vars.Helper.Make<float>(gWorld, 0x1D8, 0x38, 0x0, 0x30, 0x338, 0x1168, 0x318);

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
	current.inMainMenu = false;
	current.stopParam = false;
	current.Level = "";
}

start
{
	return current.World.Contains("MenuRoot") && current.World == "PrefaceRoot";
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;
		if (old.World != current.World) vars.Log("World: " + old.World + " -> " + current.World);
	var level = vars.FNameToString(current.CurrentPlayStartID);
	if (!string.IsNullOrEmpty(level) && level != "None")
		current.Level = level;
		if (old.Level != current.Level) vars.Log("Level: " + old.Level + " -> " + current.Level);
	// if (old.bPlayerIsWaiting != current.bPlayerIsWaiting) vars.Log("bPlayerIsWaiting:" + current.bPlayerIsWaiting);
	// if (old.FinalCameraShot != current.FinalCameraShot) vars.Log("FinalCameraShot:" + current.FinalCameraShot);
}

split
{
	if (old.Level != current.Level && settings[current.Level] && !vars.CompletedSplits.Contains(current.Level))
	{
		vars.CompletedSplits.Add(current.Level);
		return true;
	}
	if (settings["End"] && current.Level == "SC303_Daniel_BackHome" && old.FinalCameraShot == 0 && current.FinalCameraShot != 0 & !vars.CompletedSplits.Contains("End"))
	{
		vars.CompletedSplits.Add("End");
		return true;
	}
}

isLoading
{
	return current.stopParam || current.NoControl || current.IsDie || current.inMainMenu || current.World.Contains("MenuRoot");
}