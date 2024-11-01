state("Pagoda-Win64-Shipping") { }

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Karma: The Dark World DEMO";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "3", true, "Prologue - Wake Up", "Splits" },
			{ "4", true, "Prologue - Calibration", "Splits"},
			{ "PrologueDone", true, "Prologue - Body Removal", "Splits"},
			{ "13", true, "Chapter 1 - Black Water", "Splits"},
			{ "ChaseAndEscape", true, "Chapter 1 - Chase & Escape", "Splits"},
			{ "15", true, "Chapter 1 - TV Tower", "Splits"},
			{ "16", true, "Chapter 1 - Stamping Letters", "Splits"},
			{ "12", true, "Chapter 1 - The Chase", "Splits"},
			{ "Ending", true, "Chapter 1 - Demo End", "Splits"},
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
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ?? ?? ?? ?? EB");

	if (gWorld == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}
	// GWorld.FNameIndex
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
    // GWorld.OwningGameInstance.GameMainUI.GM_Chapter.FNameIndex
    vars.Helper["GameProgress"] = vars.Helper.Make<byte>(gWorld, 0x1B8, 0x38, 0x0, 0x30, 0x338, 0x95E);
	// GWorld.OwningGameInstance.stopParam
	vars.Helper["stopParam"] = vars.Helper.Make<bool>(gWorld, 0x1B8, 0x350);
	// GWorld.OwningGameInstance.inMainMenu
	vars.Helper["inMainMenu"] = vars.Helper.Make<bool>(gWorld, 0x1B8, 0x352);

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

	vars.GameProgress14 = 0;
	vars.EndingPrep = 0;
}

start
{
	return (old.World == "MenuRoot_CH0" || old.World == "MenuRoot_CH1") && current.World == "PrefaceRoot";
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;
		if (old.World != current.World) vars.Log("World: " + old.World + " -> " + current.World);
	if (old.inMainMenu != current.inMainMenu) vars.Log("inMainMenu:" + current.inMainMenu);

	if (old.GameProgress != current.GameProgress) vars.Log("GameProgress: " + old.GameProgress + " -> " + current.GameProgress);
	if (old.GameProgress == 13 && current.GameProgress == 14) vars.GameProgress14++;
	if (old.GameProgress == 16 && current.GameProgress == 12) vars.EndingPrep++;

}

split
{
	if (old.GameProgress != 4 && current.GameProgress != 2 || old.GameProgress != 13 && current.GameProgress == 14|| old.GameProgress != 12 && current.GameProgress == 13)
	{
		if (old.GameProgress != current.GameProgress && settings[current.GameProgress.ToString()] && !vars.CompletedSplits.Contains(current.GameProgress.ToString()))
		{
			vars.CompletedSplits.Add(current.GameProgress.ToString());
        	return true;
		}
	}
	if (old.GameProgress == 4 && current.GameProgress == 2 && settings["PrologueDone"])
	{
		vars.CompletedSplits.Add(current.GameProgress.ToString() + "_Prologue");
		return true;
	}
	if (old.GameProgress == 13 && current.GameProgress == 14 && vars.GameProgress14 == 2 && settings["ChaseAndEscape"])
	{
		vars.CompletedSplits.Add(current.GameProgress.ToString() + "_ChaseAndEscape");
		return true;
	}
	if (old.GameProgress == 12 && current.GameProgress == 13 && vars.EndingPrep == 1 && settings["Ending"])
	{
		vars.CompletedSplits.Add(current.GameProgress.ToString() + "_Ending");
		return true;
	}
}

isLoading
{
	return current.stopParam;
}