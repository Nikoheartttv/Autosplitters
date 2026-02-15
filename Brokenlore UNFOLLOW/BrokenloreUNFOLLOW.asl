state("Unfollow-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();

	dynamic[,] _settings =
	{
		{ "ChapterSplits", true, "Chapter Splits", null },
			{ "1", true, "Chapter 1: Home Sweet Home", "ChapterSplits" },
			{ "2", true, "Chapter 2: Back to School", "ChapterSplits" },
			{ "3", true, "Chapter 3: Happy Birthday", "ChapterSplits" },
			{ "4", true, "Chapter 4: Hospital Shift", "ChapterSplits" },
			{ "5", true, "Chapter 5: Night at the Pool", "ChapterSplits" },
			{ "6", true, "Chapter 6: Retro Nightmare", "ChapterSplits" },
            { "EndSplit", true, "Chapter 7: In the Belly of the Beast", "ChapterSplits" },
	};
	vars.Uhara.Settings.Create(_settings);
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("gWorld: " + vars.Utils.GWorld.ToString("X"));
	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("gEngine: " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("fNames: " + vars.Utils.FNames.ToString("X"));

	vars.Resolver.Watch<int>("GSync", vars.Utils.GSync);
	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.WatchString("CheckpointDataLevelName", vars.Utils.GEngine, 0x10A8, 0x1D8, 0x0);
    vars.Resolver.Watch<int>("PlayerHealth", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x338, 0x830);
    vars.Resolver.Watch<int>("CurrentLvl", vars.Utils.GEngine, 0x10A8, 0x97C);
    vars.Resolver.Watch<bool>("CheckpointDataTransitionCheckpoint", vars.Utils.GEngine, 0x10A8, 0x1D0);
    vars.Resolver.Watch<bool>("InTransition", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x338, 0x850);
    vars.Resolver.Watch<bool>("Rest", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x338, 0x851);
    vars.Resolver.Watch<bool>("CanPlay", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x338, 0x852);
	// vars.Resolver.Watch<bool>("CineVideoLock", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x6A8, 0xC0);

	// IntPtr SaveGame = vars.Events.InstancePtr("Routine_SaveGame_C", "");
	current.World = "";
    current.CheckpointDataLevelName = "";

	// vars.Resolver.Watch<IntPtr>("EventComponent", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x2E8, 0x708, 0xA8);
	// vars.Resolver.Watch<int>("EventComponentCount", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x2E8, 0x708, 0xB0);
}

update
{
	vars.Uhara.Update();

	string world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World Change: " + current.World);

    if (old.CheckpointDataLevelName != current.CheckpointDataLevelName) vars.Uhara.Log("Checkpoint Change: " + current.CheckpointDataLevelName);
    if (old.PlayerHealth != current.PlayerHealth) vars.Uhara.Log("Player Health: " + current.PlayerHealth);
    if (old.CurrentLvl != current.CurrentLvl) vars.Uhara.Log("Current Level: " + current.CurrentLvl);
    if (old.CheckpointDataTransitionCheckpoint != current.CheckpointDataTransitionCheckpoint) vars.Uhara.Log("Checkpoint Transition: " + current.CheckpointDataTransitionCheckpoint);
    if (old.InTransition != current.InTransition) vars.Uhara.Log("In Transition: " + current.InTransition);
    if (old.Rest != current.Rest) vars.Uhara.Log("Rest: " + current.Rest);
    if (old.CanPlay != current.CanPlay) vars.Uhara.Log("Can Play: " + current.CanPlay);
    
    // if (current.EventComponentCount > old.EventComponentCount)
	// {
	// 	string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));
	// 	// if (!string.IsNullOrEmpty(name)) vars.Uhara.Log("Last EventComponent FName: " + name);
	// }
	// if (old.GSync != current.GSync) vars.Uhara.Log("GSync changed: " + current.GSync);
}

start
{
    return old.World == "MainMenu" && current.World == "House_Backup";
}

// onStart
// {
// 	timer.IsGameTimePaused = true;
// 	vars.CompletedSplits.Clear();
// }

// split
// {
// 	// Chapter Splits
// 	if (current.EventComponentCount > old.EventComponentCount)
// 	{
// 		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));

// 		if (settings.ContainsKey(name) && settings[name] && !vars.CompletedSplits.Contains(name))
// 		{
// 			vars.CompletedSplits.Add(name);
// 			return true;
// 		}
// 	}

// 	// End Split
// 	if (settings["EndSplit"] && current.World == "Map_Game_Caves_Master" && current.CineVideoLock && !vars.CompletedSplits.Contains("EndSplit"))
// 	{
// 		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));

// 		if (name == "Routine_Data_Event_Caves_Ending")
// 		{
// 			vars.CompletedSplits.Add("EndSplit");
// 			return true;
// 		}
// 	}
// }

isLoading
{
	return current.CheckpointDataTransitionCheckpoint || current.World == "IntroLevel" || current.World == "MainMenu" || current.InTransition;
}