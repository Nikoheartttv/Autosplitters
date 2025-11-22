state("ProjectHProd-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Helper.GameName = "SLEEP AWAKE Demo";
	vars.Helper.AlertLoadless();
	vars.Uhara.EnableDebug();
	vars.CompletedSplits = new HashSet<string>();
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8b 1D ???????? 48 85 DB 74 ?? 41 B0");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
	IntPtr fNames = vars.Helper.ScanRel(3, "48 8D 0D ???????? 48 63 FA 75");
	
	if (gWorld != IntPtr.Zero) vars.Log("gWorld: " + gWorld.ToString("X"));
    if (gEngine != IntPtr.Zero) vars.Log("gEngine: " + gEngine.ToString("X"));
    if (fNames != IntPtr.Zero) vars.Log("fNames: " + fNames.ToString("X"));

	vars.Helper.Update();
	vars.Helper.MapPointers();

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

	vars.FindSubsystem = (Func<string, IntPtr>)(name =>
    {
		// PHGameEngine.GameInstance.currentnumberofsubsystems
        var subsystems = vars.Helper.Read<int>(gEngine, 0xD48, 0x118);
        for (int i = 0; i < subsystems; i++)
        {
			//GEngine.GameInstance.subsystem finds on every 0x18 plus 0x8
            var subsystem = vars.Helper.Deref(gEngine, 0xD48, 0x110, 0x18 * i + 0x8);
            var sysName = vars.FNameToString(vars.Helper.Read<ulong>(subsystem, 0x18));

            if (sysName.StartsWith(name))
            {
                return subsystem;
            }
        }

        throw new InvalidOperationException("Subsystem not found: " + name);
    });
	vars.PHCheckpointManager = IntPtr.Zero;
	vars.LoadingScreenSubsystem = IntPtr.Zero;

	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	// vars.Helper["SequencePlayerPlay"] = vars.Helper.Make<ulong>(vars.Events.FunctionFlag("", "", "OnSequencePlayerPlay"));
	// vars.Helper["SequencePlayerStop"] = vars.Helper.Make<ulong>(vars.Events.FunctionFlag("", "", "OnSequencePlayerStop"));


	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	// vars.Helper["Checkpoint"] = vars.Helper.MakeString(gEngine, 0xD48, 0x110, 0xF8, 0xE0, 0x28)



	current.World = "";
	current.CurrentSlotInfoName = "";
	current.CurrentSlotInfoChapterName = "";
	current.CurrentSlotInfoChapterGoal = "";
	current.CurrentSlotInfoActivePlayerTaskName = "";
	current.CurrentSlotInfoMapName = "";
}

update
{
	IntPtr gm;
    // if (!vars.Helper.TryRead<IntPtr>(out gm, vars.PHCheckpointManager))
    // {
    //     vars.PHCheckpointManager = vars.FindSubsystem("PHCheckpointManager");
    //     // if (vars.ChaptersManager != IntPtr.Zero) vars.Log("MNQuestObjectiveSubsystem: " + vars.ChaptersManager.ToString("X"));
    //     // vars.Helper["CheckpointSaveBeginEventChapterName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE0, 0x28, 0xE8, 0x28, 0x0);
	// 	// vars.Helper["CheckpointSaveBeginEventName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE0, 0x28, 0x90, 0x28, 0x0);
	// 	// vars.Helper["CheckpointSaveBeginEventChapterGoal"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE0, 0x28, 0x100, 0x30, 0x20);
	// 	// vars.Helper["CheckpointSaveBeginEventActivePlayerTaskName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE0, 0x28, 0x118, 0x28, 0x0);
	// 	// vars.Helper["CheckpointSaveFinishedEventChapterName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE8, 0x28, 0xE8, 0x28, 0x0);
	// 	// vars.Helper["CheckpointSaveFinishedEventName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE8, 0x28, 0x90, 0x28, 0x0);
	// 	// vars.Helper["CheckpointSaveFinishedEventChapterGoal"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE8, 0x28, 0x100, 0x30, 0x20);
	// 	// vars.Helper["CheckpointSaveFinishedEventActivePlayerTaskName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xE8, 0x28, 0x118, 0x28, 0x0);
	// 	vars.Helper["CurrentSlotInfoName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x90, 0x28, 0x0);
	// 	vars.Helper["CurrentSlotInfoChapterName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0xE8, 0x28, 0x0);
	// 	vars.Helper["CurrentSlotInfoChapterGoal"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x100, 0x30, 0x20);
	// 	vars.Helper["CurrentSlotInfoActivePlayerTaskName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x118, 0x28, 0x0);
	// 	vars.Helper["CurrentSlotInfoMapName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x130, 0x0);
    // }

	if (!vars.Helper.TryRead<IntPtr>(out gm, vars.PHCheckpointManager) ||
        !vars.Helper.TryRead<IntPtr>(out gm, vars.LoadingScreenSubsystem))
    {
        // Find PHCheckpointManager if needed
        if (vars.PHCheckpointManager == IntPtr.Zero)
            vars.PHCheckpointManager = vars.FindSubsystem("PHCheckpointManager");

        // Find SomeOtherSubsystem if needed
        if (vars.LoadingScreenSubsystem == IntPtr.Zero)
            vars.LoadingScreenSubsystem = vars.FindSubsystem("BP_LoadingScreenSubsystem_C");

        // Setup MakeString etc for PHCheckpointManager
        if (vars.PHCheckpointManager != IntPtr.Zero)
        {
            vars.Helper["CurrentSlotInfoName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x90, 0x28, 0x0);
            vars.Helper["CurrentSlotInfoChapterName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0xE8, 0x28, 0x0);
            vars.Helper["CurrentSlotInfoChapterGoal"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x100, 0x30, 0x20);
            vars.Helper["CurrentSlotInfoActivePlayerTaskName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x118, 0x28, 0x0);
            vars.Helper["CurrentSlotInfoMapName"] = vars.Helper.MakeString(vars.PHCheckpointManager, 0xA8, 0x130, 0x0);
        }

		if (vars.LoadingScreenSubsystem != IntPtr.Zero)
        {
            vars.Helper["LoadingScreenMovieName"] = vars.Helper.MakeString(vars.LoadingScreenSubsystem, 0x48, 0x30, 0x0);
			vars.Helper["LoadingScreenMovieTime"] = vars.Helper.Make<float>(vars.LoadingScreenSubsystem, 0x48, 0x40);
        }
    }

	vars.Helper.Update();
	vars.Helper.MapPointers();

	string world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Log("World: " + current.World);

	if (old.CurrentSlotInfoName != current.CurrentSlotInfoName) vars.Log("Checkpoint Slot Name: " + current.CurrentSlotInfoName);
	if (old.CurrentSlotInfoChapterName != current.CurrentSlotInfoChapterName) vars.Log("Checkpoint Chapter Name: " + current.CurrentSlotInfoChapterName);
	if (old.CurrentSlotInfoChapterGoal != current.CurrentSlotInfoChapterGoal) vars.Log("Checkpoint Chapter Goal: " + current.CurrentSlotInfoChapterGoal);
	if (old.CurrentSlotInfoActivePlayerTaskName != current.CurrentSlotInfoActivePlayerTaskName) vars.Log("Checkpoint Active Player Task Name: " + current.CurrentSlotInfoActivePlayerTaskName);
	if (old.CurrentSlotInfoMapName != current.CurrentSlotInfoMapName) vars.Log("Checkpoint Map Name: " + current.CurrentSlotInfoMapName);
	// if (old.LoadingScreenMovieName != current.LoadingScreenMovieName) vars.Log("Loading Screen Movie Name: " + current.LoadingScreenMovieName);
	// if (old.LoadingScreenMovieTime != current.LoadingScreenMovieTime) vars.Log("Loading Screen Movie Time: " + current.LoadingScreenMovieTime);
}

// isLoading
// {
//     if (current.SequencePlayerPlay != current.SequencePlayerStop)
// 	{
// 		return true;
// 	} else return false;
// }