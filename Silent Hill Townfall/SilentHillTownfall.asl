state("Townfall-Win64-Shipping") { }
state("Townfall-WinGDK-Shipping") { }

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.GameName = "Townfall";
    vars.Helper.AlertLoadless();

    // dynamic[,] _settings =
	// {
	// 	{ "Splits", true, "Splits", null },
			// { "Cold Open", true, "Cold Open", "Splits" },
			// { "4", true, "Prologue - Calibration", "Splits"},
			// { "PrologueDone", true, "Prologue - Body Removal", "Splits"},
			// { "13", true, "Chapter 1 - Black Water", "Splits"},
			// { "ChaseAndEscape", true, "Chapter 1 - Chase & Escape", "Splits"},
			// { "15", true, "Chapter 1 - TV Tower", "Splits"},
			// { "16", true, "Chapter 1 - Stamping Letters", "Splits"},
			// { "12", true, "Chapter 1 - The Chase", "Splits"},
			// { "Ending", true, "Chapter 1 - Demo End", "Splits"},
	// };

	// vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
}

init
{
    // These are the same signature scans used by the Uhara version.
    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 8d 7b ?? 4c 8d 47 ?? f2 0f 10 b8");
    IntPtr gEngine = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 48 8b 88 ?? ?? ?? ?? 48 85 c9 74 ?? 48 8b 01 ff 90");
    IntPtr fNames = vars.Helper.ScanRel(3, "48 8d 0d ?? ?? ?? ?? e8 ?? ?? ?? ?? c6 05 ?? ?? ?? ?? ?? 48 83 c4 ?? c3 cc cc cc 40 53");

    if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
        throw new Exception("Not all required addresses could be found by scanning.");

    vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);

    vars.Helper["TimePlayed_CurrentPlaythrough"] = vars.Helper.Make<double>(gEngine, 0x1248, 0x450);
    vars.Helper["TimePlayed_CurrentMission"] = vars.Helper.Make<double>(gEngine, 0x1248, 0x458);
    vars.Helper["bPlayTimerStarted_CurrentPlaythrough"] = vars.Helper.Make<bool>(gEngine, 0x1248, 0x470);
    vars.Helper["bPlayTimerFinished_CurrentPlaythrough"] = vars.Helper.Make<bool>(gEngine, 0x1248, 0x471);

    // ActiveMissions[0].MissionID / MissionName.
    vars.Helper["MissionID"] = vars.Helper.MakeString(gWorld, 0x1A8, 0x3B0, 0x108, 0x0, 0x318, 0x0);
    vars.Helper["MissionName"] = vars.Helper.MakeString(gWorld, 0x1A8, 0x3B0, 0x108, 0x0, 0x328, 0x0);

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

    current.World = "";
    current.IGT = 0.0;
    current.TimePlayed_CurrentMission = 0.0;
    current.bPlayTimerStarted_CurrentPlaythrough = false;
    current.bPlayTimerFinished_CurrentPlaythrough = false;
    current.MissionName = "";
    current.MissionID = "";
    vars.totalTime = 0.0;
}

start
{
    return old.World == "Level_MainMenu" && current.World == "Level_Townfall";
}

onStart
{
    timer.IsGameTimePaused = true;
    vars.totalTime = 0.0;
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();

    var world = vars.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None")  current.World = world;
    if (old.World != current.World) vars.Log("World: " + old.World + " -> " + current.World);

    if (old.MissionName != current.MissionName) vars.Log("Mission Name: " + current.MissionName);
    if (old.MissionID != current.MissionID) vars.Log("Mission ID: " + current.MissionID);

    current.IGT = current.TimePlayed_CurrentPlaythrough;

    if (current.IGT >= old.IGT) vars.totalTime += current.IGT - old.IGT;
}

isLoading
{
    return true;
}

gameTime
{
    return TimeSpan.FromSeconds(vars.totalTime);
}

exit
{
    timer.IsGameTimePaused = true;
}