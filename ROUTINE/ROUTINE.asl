state("Routine-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();

	dynamic[,] _settings =
	{
		{ "ChapterSplits", true, "Chapter Splits", null },
			{ "Routine_Data_Chapter_02", true, "Chapter 1: Birth", "ChapterSplits" },
			{ "Routine_Data_Chapter_03", true, "Chapter 2: Incision", "ChapterSplits" },
			{ "Routine_Data_Chapter_04", true, "Chapter 3: Re-Create", "ChapterSplits" },
			{ "Routine_Data_Chapter_05", true, "Chapter 4: Adrift", "ChapterSplits" },
			{ "Routine_Data_Chapter_06", true, "Chapter 5: Endure", "ChapterSplits" },
			{ "EndSplit", true, "Chapter 6: Legacy", "ChapterSplits" },
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
	vars.Resolver.Watch<bool>("CineVideoLock", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x6A8, 0xC0);

	IntPtr SaveGame = vars.Events.InstancePtr("Routine_SaveGame_C", "");
	// GEngine -> Game Instance -> LocalPlayers[0] -> PlayerController -> AcknowledgedPawn -> NoteComponent -> Notes[AllocatorInstance]
	vars.Resolver.Watch<IntPtr>("NoteComponent", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x710, 0xA8);
	vars.Resolver.Watch<int>("NoteComponentCount", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x710, 0xB0);
	current.World = "";

	vars.Resolver.Watch<IntPtr>("EventComponent", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x2E8, 0x708, 0xA8);
	vars.Resolver.Watch<int>("EventComponentCount", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x2E8, 0x708, 0xB0);
}

update
{
	vars.Uhara.Update();

	// --- World tracking ---
	string world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World Change: " + current.World);

	if (current.EventComponentCount > old.EventComponentCount)
	{
		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));

		if (!string.IsNullOrEmpty(name)) vars.Uhara.Log("Last EventComponent FName: " + name);
	}
	if (old.GSync != current.GSync) vars.Uhara.Log("GSync changed: " + current.GSync);
}

start
{
	return old.World == "Map_Menu_Main" && current.World == "Map_Game_Arrivals_Master" && current.CineVideoLock;
}

onStart
{
	vars.CompletedSplits.Clear();
}

split
{
	// Chapter Splits
	if (current.EventComponentCount > old.EventComponentCount)
	{
		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));

		if (settings.ContainsKey(name) && settings[name] && !vars.CompletedSplits.Contains(name))
		{
			vars.CompletedSplits.Add(name);
			return true;
		}
	}

	// End Split
	if (settings["EndSplit"] && current.World == "Map_Game_Caves_Master" && current.CineVideoLock && !vars.CompletedSplits.Contains("EndSplit"))
	{
		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));

		if (name == "Routine_Data_Event_Caves_Ending")
		{
			vars.CompletedSplits.Add("EndSplit");
			return true;
		}
	}
}

isLoading
{
	return current.World == "Map_Engine_Launch" || current.World == "Map_Menu_Main" || current.CineVideoLock || current.GSync > 0;
}