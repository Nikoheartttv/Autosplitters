state ("Europa-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Europa";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Chapter", true, "Speedrun Category - Chapter", null },
			{ "Zone1Act2", true, "Chapter 1 - Leaving Home", "Chapter" },
			{ "Zone1Act3", true, "Chapter 2 - A Saga Begins", "Chapter" },
			{ "Zone2Act1", true, "Chapter 3 - Ancient Battlefield", "Chapter" },
            { "Zone2Act2", true, "Chapter 4 - Amber Horizon", "Chapter" },
            { "Zone2Act2_b", true, "Chapter 5 - Lost Island", "Chapter" },
            { "Zone2Act3", true, "Chapter 6 - Deep Ruins", "Chapter" },
            { "Zone3Act1", true, "Chapter 7 - The Bowl", "Chapter" },
            { "Zone3Act2", true, "Chapter 8 - Twilight", "Chapter" },
            { "Zone4Act2", true, "Chapter 9 - Wild Depths", "Chapter" },
            { "Zone4Act3", true, "Chapter 10 - Crisp Embrace", "Chapter" },
            { "Zone5Act1", true, "Chapter 11 - Flying High", "Chapter" },
            { "Zone5Act2", true, "Chapter 12 - Island Ascent", "Chapter" },
            { "Zone5FinalRush", true, "Chapter 13 - Golden Plains", "Chapter" },
            { "Zone5FinalFlight", true, "Chapter 14 - Crumbling Escape", "Chapter" },
            { "Ending", true, "Chapter 15 - Riding Home", "Chapter" },
        { "ZepherExpander", false, "Split on gaining Zepher Expander", null },
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
    vars.Sw = new Stopwatch();
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 89 05 ???????? 48 85 c9 74 ?? e8 ???????? 48 8d 4d");
	IntPtr fNames = vars.Helper.ScanRel(3, "48 8d 05 ???????? eb ?? 48 8d 0d ???????? e8 ???????? c6 05");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

    vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

		IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Helper.Read<short>(entry) >> 6;
		string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});

    vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
    // GEngine.GameInstance.LastLoadedLevelName
    vars.Helper["StreamingLevelName"] = vars.Helper.Make<ulong>(gEngine, 0xD28, 0x1B8);
    vars.Helper["Loading"] = vars.Helper.Make<uint>(gEngine, 0xD28, 0x318);
    // GEngine.GameInstance.LocalPlayers[0].PlayerController.MainMenuComponent.bIsGamePaused
    vars.Helper["bIsGamePaused"] = vars.Helper.Make<bool>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x578, 0xB8);
    vars.Helper["bIsPlayerWaiting"] = vars.Helper.Make<byte>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x3D0);
    vars.Helper["ZepherExpandersCollected"] = vars.Helper.Make<int>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x590, 0x113C);

    current.LevelName = "";
    current.World = "";
}

onStart
{
    vars.Sw.Reset();
}

start
{
    return old.LevelName == "LiminalSpace_Finale" && current.LevelName == "Zone1Act1";
}

update
{
    vars.Helper.Update();
	vars.Helper.MapPointers();

    if (old.Loading != current.Loading)
	{
        vars.Log(current.Loading);
	}

    var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Log("World: " + current.World);

    var levelname = vars.FNameToString(current.StreamingLevelName);
	if (!string.IsNullOrEmpty(levelname) && levelname != "None") current.LevelName = levelname;
	if (old.LevelName != current.LevelName) vars.Log("LevelName: " + current.LevelName);
}

isLoading
{
    return current.bIsGamePaused || current.LevelName == "LiminalSpace_Finale" || current.World == "MainMenuMap"
    || current.bIsPlayerWaiting != 9 || current.Loading != 0;
}

split
{
    if (old.LevelName != current.LevelName && settings[current.LevelName.ToString()] && !vars.CompletedSplits.Contains(current.LevelName.ToString()))
    {
        vars.CompletedSplits.Add(current.LevelName.ToString());
        return true;
    }
    // Start Stopwatch for End Split
    if (current.LevelName == "Zone5FinalFlight")
    {
        vars.Sw.Start();
    }
    if (settings["Ending"] && current.LevelName == "Zone5FinalFlight" && vars.Sw.Elapsed.TotalSeconds >= 20.0 && old.bIsPlayerWaiting == 9 && current.bIsPlayerWaiting == 11 && !vars.CompletedSplits.Contains("Ending"))
    {
        vars.CompletedSplits.Add("Ending");
        return true;
    }
    if (old.ZepherExpandersCollected != current.ZepherExpandersCollected && !vars.CompletedSplits.Contains(current.ZepherExpandersCollected.ToString()))
    {
        vars.CompletedSplits.Add(current.ZepherExpandersCollected.ToString());
        return true;
    }
}