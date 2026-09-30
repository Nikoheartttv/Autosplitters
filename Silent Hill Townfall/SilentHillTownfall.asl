state("Townfall-Win64-Shipping") { }
state("Townfall-WinGDK-Shipping") { }

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.GameName = "Townfall";
    vars.Helper.AlertGameTime();

    dynamic[,] _settings =
    {
        { "Splits", true, "Splits", null },
            { "Splits_Part1", true, "Part 1 - Arrival", "Splits" },
                { "3", true, "Cold Open", "Splits_Part1" },
                { "5", true, "Escape", "Splits_Part1" },
                { "6", true, "A Connection", "Splits_Part1" },
                { "7", true, "Searching For Zoe", "Splits_Part1" },

            { "Splits_Part2", true, "Part 2 - Zoe", "Splits" },
                { "10", true, "Zoe: Rounds", "Splits_Part2" },
                { "40", true, "Journey to Medical", "Splits_Part2" },

            { "Splits_Part3", true, "Part 3 - The Patient", "Splits" },
                { "11", true, "Zoe: The Patient", "Splits_Part3" },
                { "12", true, "Many Into One", "Splits_Part3" },

            { "Splits_Part4", true, "Part 4 - Clara Woods", "Splits" },
                { "13", true, "Begin Again", "Splits_Part4" },
                { "14", true, "Missing Parts", "Splits_Part4" },
                { "8", true, "Inside CEG HQ", "Splits_Part4" },

            { "Splits_Part5", true, "Part 5 - Richard", "Splits" },
                { "17", true, "Richard: Getting Inside", "Splits_Part5" },
                { "18", true, "Richard: Another Attempt", "Splits_Part5" },

            { "Splits_Part6", true, "Part 6 - Simon", "Splits" },
                { "21", true, "Fix This", "Splits_Part6" },
                { "23", true, "Trying Again", "Splits_Part6" },
                { "29", true, "Eraser", "Splits_Part6" },
                
            { "FinalSplit", true, "Ending Split (on all Endings)", "Splits" }
    };

    vars.Helper.Settings.Create(_settings);
    vars.CompletedSplits = new HashSet<string>();
}

init
{
    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 8d 7b ?? 4c 8d 47 ?? f2 0f 10 b8");
    IntPtr gEngine = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 48 8b 88 ?? ?? ?? ?? 48 85 c9 74 ?? 48 8b 01 ff 90");
    IntPtr fNames = vars.Helper.ScanRel(3, "48 8d 0d ?? ?? ?? ?? e8 ?? ?? ?? ?? c6 05 ?? ?? ?? ?? ?? 48 83 c4 ?? c3 cc cc cc 40 53");

    if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
        throw new Exception("Not all required addresses could be found by scanning.");

    vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
    vars.Helper["TimePlayed_CurrentPlaythrough"] = vars.Helper.Make<double>(gEngine, 0x1248, 0x450);
    vars.Helper["MissionID"] = vars.Helper.MakeString(gWorld, 0x1A8, 0x3B0, 0x108, 0x0, 0x318, 0x0);
    vars.Helper["PlayTimerStarted"] = vars.Helper.Make<bool>(gEngine, 0x1248, 0x470);
    vars.Helper["PlayTimerFinished"] = vars.Helper.Make<bool>(gEngine, 0x1248, 0x471);

    vars.FNameToString = (Func<ulong, string>)(fName =>
    {
        var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
        var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
        var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

        IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
        if (chunk == IntPtr.Zero) return "";

        IntPtr entry = chunk + (int)nameIdx * sizeof(short);
        int length = vars.Helper.Read<short>(entry) >> 6;
        if (length <= 0) return number == 0 ? "" : "_" + number;

        string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));
        return number == 0 ? name : name + "_" + number;
    });

    current.World = "";
    current.GWorldName = 0UL;
    current.MissionID = "";
    current.PlayTimerStarted = false;
    current.PlayTimerFinished = false;
    current.IGT = 0.0;
    vars.totalTime = 0.0;
}

start
{
    return current.PlayTimerStarted && !old.PlayTimerStarted;
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();

    if (old.GWorldName != current.GWorldName)
    {
        var world = vars.FNameToString(current.GWorldName);
        if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
        if (old.World != current.World) vars.Log("World: " + old.World + " -> " + current.World);
    }

    current.IGT = current.TimePlayed_CurrentPlaythrough;

    if (current.IGT > old.IGT) vars.totalTime += (current.IGT - old.IGT);
}

split
{
    // Ending Split
    if (current.PlayTimerFinished && !old.PlayTimerFinished && settings.ContainsKey("FinalSplit") 
        && settings["FinalSplit"] && !vars.CompletedSplits.Contains("FinalSplit"))
    {
        vars.CompletedSplits.Add("FinalSplit");
        return true;
    }

    // Mission Split
    if (old.MissionID != current.MissionID && !string.IsNullOrEmpty(current.MissionID) && settings.ContainsKey(current.MissionID) 
        && settings[current.MissionID] && !vars.CompletedSplits.Contains(current.MissionID))
    {
        vars.CompletedSplits.Add(current.MissionID);
        return true;
    }
}

isLoading
{
    return true;
}

gameTime
{
    return TimeSpan.FromSeconds(vars.totalTime);
}

onReset
{
    vars.CompletedSplits.Clear();
    vars.totalTime = 0.0;
}

exit
{
    timer.IsGameTimePaused = true;
}