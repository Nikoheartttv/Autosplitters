state("DeadTake") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    // Assembly.Load(File.ReadAllBytes("Components/uhara7")).CreateInstance("Main");
	vars.Helper.GameName = "Dead Take";
	vars.Helper.AlertLoadless();

    dynamic[,] _settings =
	{
		{ "EndSplit", true, "Split when Credits play", null },
	};
	vars.Helper.Settings.Create(_settings);
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
    IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B ?? ?? ?? ?? ?? 48 85 C9 74 16 48 8B 89 E8");
	IntPtr FNamePool = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || FNamePool == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

		// IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr chunk = vars.Helper.Read<IntPtr>(FNamePool + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Helper.Read<short>(entry) >> 6;
		string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});

	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	vars.Helper["GameState"] = vars.Helper.Make<int>(gEngine, 0x1248, 0x108, 0x50, 0x40);
    vars.Helper["MovementMode"] = vars.Helper.Make<byte>(gEngine, 0x1248, 0x38, 0x0, 0x30, 0x2F8, 0x330, 0x231);
    vars.Helper["CreditsPlaying"] = vars.Helper.Make<bool>(gEngine, 0x1248, 0x5C0);

    current.World = "";
    current.ProgressSceneTitle = "";
    current.MovementMode = 0;
    current.CreditsPlaying = false;
}

start
{
    return old.World == "L_FrontEnd" && current.World == "L_Mansion";
}

update
{
    vars.Helper.Update();
	vars.Helper.MapPointers();

    var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Log("World: " + current.World);
    if (old.MovementMode != current.MovementMode) vars.Log("MovementMode: " + current.MovementMode);
}

split
{
    if (old.CreditsPlaying == false && current.CreditsPlaying == true && settings["EndSplit"])
    {
        return true;
    }
}

isLoading
{
	return current.GameState == 0 || current.GameState == 7 || current.GameState == 9 || current.MovementMode == 3;
}