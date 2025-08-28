// Observations in GameEngine
// Chitin is the currency


state("SwordOfTheSea-Win64-Shipping") { }

startup
{
    // Load helper components
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    Assembly.Load(File.ReadAllBytes("Components/uhara8")).CreateInstance("Main");

    vars.Helper.GameName = "Sword of the Sea";
    vars.Helper.AlertLoadless();
    vars.Uhara.EnableDebug();

    // Track seen CleanseEvents to avoid duplicates
    vars.SeenCleanseTags = new HashSet<ulong>();
    vars.LastCleanseCount = 0;
}

init
{
    // === Memory Signature Scans ===
    IntPtr gWorld         = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
    IntPtr gEngine        = vars.Helper.ScanRel(3, "48 8B 0D ???????? 41 BE ???????? 41 3B");
    IntPtr fNames         = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");
    IntPtr gSyncLoadCount = vars.Helper.ScanRel(5, "89 43 60 8B 05 ?? ?? ?? ??");

    if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
        throw new Exception("Not all required addresses could be found by scanning.");

    // === FName to String Converter ===
    vars.FNameToString = (Func<ulong, string>)(fName =>
    {
        var nameIdx  = (fName & 0x000000000000FFFF) >> 0x00;
        var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
        var number   = (fName & 0xFFFFFFFF00000000) >> 0x20;

        IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
        IntPtr entry = chunk + (int)nameIdx * sizeof(short);

        int length   = vars.Helper.Read<short>(entry) >> 6;
        string name  = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

        return number == 0 ? name : name + "_" + number;
    });

    vars.EventManager = vars.Uhara.CreateTool("UnrealEngine", "Events");
	IntPtr IntroCutscene = vars.EventManager.InstancePtr("Intro_DirectorBP_C", "Intro_DirectorBP_C");
	IntPtr OceanSeed = vars.EventManager.InstancePtr("OceanSeed_BP_C", "OceanSeed_BP_C");

    // === Helper pointers ===
    vars.Helper["GSync"] = vars.Helper.Make<bool>(gSyncLoadCount);
    vars.Helper["GWorldName"] 				= vars.Helper.Make<ulong>(gWorld, 0x18);
    vars.Helper["CleanseEvents"]      = vars.Helper.Make<IntPtr>(gEngine, 0x10A8, 0x258, 0x490);
    vars.Helper["CleanseEventsCount"] = vars.Helper.Make<int>(gEngine, 0x10A8, 0x258, 0x498);
    vars.Helper["GWorldName"]         = vars.Helper.Make<ulong>(gWorld, 0x18);

    // OceanSeed -> CleanseSequencer -> SequencePlayer -> 
    vars.Helper["OceanSeedStatus"] = vars.Helper.Make<bool>(OceanSeed, 0x3A8, 0x2D0, 0x2A8);
    vars.Helper["OceanSeedFName"] = vars.Helper.Make<bool>(OceanSeed, 0x3A8, 0x2D0, 0x18);

    // Initialize world state
    current.World = "";
}

onStart
{
    vars.SeenCleanseTags.Clear();
}

update
{
    // === Update pointers ===
    vars.Helper.Update();
    vars.Helper.MapPointers();

    // === Track world name ===
    var world = vars.FNameToString(current.GWorldName);
    if (world != null && world != "None") current.World = World;
    if (old.World != current.World) vars.Log("World: " + current.World);

    // === Log CleanseEvents ===
    var cleanseBase = vars.Helper["CleanseEvents"].Current;
    var cleanseCount = vars.Helper["CleanseEventsCount"].Current;

    if (cleanseBase != IntPtr.Zero && cleanseCount > 0)
    {
        if (vars.LastCleanseCount != cleanseCount)
        {
            vars.LastCleanseCount = cleanseCount;
            vars.Log("CleanseEvents count: " + cleanseCount);
        }

        for (int i = 0; i < cleanseCount; i++)
        {
            IntPtr entryBase = cleanseBase + (i * 0x18);
            ulong key = vars.Helper.Read<ulong>(entryBase + 0x0);
            IntPtr cleansedTagsAllocator = vars.Helper.Read<IntPtr>(entryBase + 0x8);
            int cleansedTagsCount = vars.Helper.Read<int>(entryBase + 0x10);
            
            if (cleansedTagsAllocator != IntPtr.Zero && cleansedTagsCount > 0)
            {
                for (int j = 0; j < cleansedTagsCount; j++)
                {
                    ulong tagName = vars.Helper.Read<ulong>(cleansedTagsAllocator + (j * 0x8));
                    if (!vars.SeenCleanseTags.Contains(tagName))
                    {
                        vars.SeenCleanseTags.Add(tagName);
                        vars.Log("New AllocatorInstance Tag: " + vars.FNameToString(tagName) +
                                 " (Entry " + i + ", Index " + j + ")");
                    }
                }
            }
        }
    }

    if (current.OceanSeedStatus == true)
    {
        vars.Log("OceanSeed: " + vars.FNameToString(current.OceanSeedFName));
    }
}

