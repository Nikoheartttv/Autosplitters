state("ProjectNeon-Win64-Shipping") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Levels", true, "Levels", null },
			{ "Stage 1", true, "Stage 1", "Levels" },
				{ "Level_1_2", true, "Stage 1 - Urban Rampart", "Stage 1" },
                { "Level_1_3", true, "Stage 1 - Obsidian Street", "Stage 1" },
				{ "Level_1_4", true, "Stage 1 - Capital Square", "Stage 1" },
				{ "Level_1_5", true, "Stage 1 - Mr. Buff", "Stage 1" },
				{ "Level_2_6", true, "Bonus Level - Surf.EXE", "Stage 1" },
			{ "Stage 2", true, "Stage 2", "Levels" },
				{ "Level_2_2", true, "Stage 2 - Assembly Floor", "Stage 2" },
                { "Level_2_3", true, "Stage 2 - Manufacturing Bay", "Stage 2" },
				{ "Level_2_4", true, "Stage 2 - Heat Sink", "Stage 2"},
                { "Level_2_5", true, "Stage 2 - Sunflower Noodle", "Stage 2" },
                { "Level_3_4", true, "Bonus Level - Evade.EXE", "Stage 2" },
				{ "Level_6_3", true, "Stage 2 - Waste Disposal Facility", "Stage 2" },
			{ "Stage 3", true, "Stage 3", "Levels" },
				{ "Level_3_2", true, "Stage 3 - Violet Zone", "Stage 3" },
				{ "Level_3_3", true, "Stage 3 - Crimson Zone", "Stage 3" },
				{ "Level_3_5", true, "Stage 3 - Apex Tower", "Stage 3" },
				{ "Level_3_6", true, "Stage 3 - Top Floors", "Stage 3" },
                { "Level_3_7", true, "Stage 3 - Tentacle Tangle", "Stage 3" },
				{ "Level_4_8", true, "Bonus Level - Focus.EXE", "Stage 3" },
				{ "Level_6_4", true, "Stage 3 - Concrete Playground", "Stage 3" },
			{ "Stage 4", true, "Stage 4", "Levels" },
				{ "Level_4_2", true, "Stage 4 - Dawn Station", "Stage 4" },
				{ "Level_4_3", true, "Stage 4 - Industrial Water Park", "Stage 4" },
				{ "Level_4_4", true, "Stage 4 - Chokepoint", "Stage 4" },
				{ "Level_4_6", true, "Stage 4 - Clockwork Heart", "Stage 4" },
				{ "Level_4_7", true, "Stage 4 - Machine Onslaught", "Stage 4" },
				{ "Level_5_7", true, "Bonus Level - Blindfold.EXE", "Stage 4" },
				{ "Level_6_2", true, "Stage 4 - Waterrise", "Stage 4" },
			{ "Stage 5", true, "Stage 5", "Levels" },
				{ "Level_5_2", true, "Stage 5 - Gravity's Sinkhole", "Stage 5" },
				{ "Level_5_3", true, "Stage 5 - Misterium", "Stage 5" },
				{ "Level_5_4", true, "Stage 5 - Glassfall", "Stage 5" },
				{ "Level_5_5", true, "Stage 5 - Leap of Faith", "Stage 5" },
				{ "Level_5_6", true, "Stage 5 - War-O", "Stage 5" },
				{ "Level_6_7", true, "Bonus Level - Minotaur.EXE", "Stage 5" },
				{ "Level_6_5", true, "Stage 5 - Stairway to the Sky", "Stage 5" },
			{ "Stage 6", true, "Stage 6", "Levels"},
				{ "Level_7_16", true, "Stage 6 - The Digital Depths", "Stage 6" },
				{ "Level_7_3", true, "Stage 6 - The Flying Bastion", "Stage 6" },
				{ "Level_7_4", true, "Stage 6 - Inner Highway", "Stage 6" },
				{ "Level_7_5", true, "Stage 6 - Gray Inferno", "Stage 6" },
				{ "Level_7_6", true, "Stage 6 - Mega Buff", "Stage 6" },
				{ "Level_7_7", true, "Bonus Level - Minotaur.EXE", "Stage 6" },
		{ "AutoReset", false, "Auto Reset when returning to Main Menu", null },
	};

    vars.Uhara.Settings.Create(_settings);
    vars.CompletedSplits = new HashSet<string>();
}

init
{
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X"));
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

    vars.Resolver.Watch<ulong>("GWorldName", vars.Utils.GWorld, 0x18);

    current.World = "";
    vars.Loading = false;

    vars.Events.FunctionFlag("ShowLoading", "WBP_Loading_C", "WBP_Loading_C", "ShowLoadingScreen");
    vars.Events.FunctionFlag("HideLoading", "WBP_Loading_C", "WBP_Loading_C", "HideLoadingScreen");
    vars.Events.FunctionFlag("ResultsShown", "WBP_EndLevelView_C", "WBP_EndLevelView_C", "ExecuteUbergraph_WBP_EndLevelView");

    vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

		IntPtr chunk = vars.Resolver.Read<IntPtr>(vars.Utils.FNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Resolver.Read<short>(entry) >> 6;
		string name = vars.Resolver.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});
}

onStart
{
	vars.CompletedSplits.Clear();
	timer.IsGameTimePaused = true;
}

start
{
	return old.World == "MainMenu" && current.World == "Level_1_2";
}

update
{
    vars.Uhara.Update();

    var world = vars.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

    if (vars.Resolver.CheckFlag("ShowLoading")) vars.Loading = true;
    if (vars.Resolver.CheckFlag("HideLoading")) vars.Loading = false;
}

split
{	
	if (current.World != "Level_7_6")
	{
		if (old.World != current.World && (current.World != "MainMenu" || current.World != "Hideout") 
            && settings.ContainsKey(current.World) && (!vars.CompletedSplits.Contains(current.World)))
		{
			vars.CompletedSplits.Add(current.World);
			return true;
		}
	}
	else if (current.World == "Level_7_6")
	{
		if (settings.ContainsKey(current.World) && (!vars.CompletedSplits.Contains(current.World))
			&& vars.Resolver.CheckFlag("ResultsShown"))
		{
			vars.CompletedSplits.Add(current.World);
			return true;
		}
	}
}

isLoading
{
    return vars.Loading;
}

reset
{
	return settings["AutoReset"] && old.World != "MainMenu" && current.World == "MainMenu";
}

exit
{
	//pauses timer if the game crashes
	timer.IsGameTimePaused = true;
}