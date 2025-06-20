state("Confronted-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Confronted (Demo)";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Level01_Intro", true, "Level 1 (Intro)", null },
		{ "Level01", true, "Level 1", null },
	};
	vars.Helper.Settings.Create(_settings);
	vars.VisitedLevel = new List<string>();
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");
	IntPtr gSyncLoadCount = vars.Helper.ScanRel(5, "89 43 60 8B 05 ?? ?? ?? ??");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	// GSync
	vars.Helper["GSync"] = vars.Helper.Make<bool>(gSyncLoadCount);
	// GWorld.FName
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	// GEngine.GameInstance.DemoCompleted
	vars.Helper["DemoCompleted"] = vars.Helper.Make<bool>(gEngine, 0x11F8, 0x584);
	// GEngine.GameInstance.LocalPlayer[0].PlayerController.AcknowledgedPawn.CutsceneActive
	vars.Helper["DemoCompleted"] = vars.Helper.Make<bool>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0xC61);

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
}

start
{
	return old.World == "Journal_Intro" && current.World == "Level01_Intro";
}

onStart
{
	vars.VisitedLevel.Clear();
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World)vars.Log("World: " + current.World);
}

split
{
	if (old.World != current.World && settings[old.World] && !vars.VisitedLevel.Contains(old.World))
    {
            vars.VisitedLevel.Add(old.World);
            return true;
    }
}

isLoading
{
	return current.GSync;
}