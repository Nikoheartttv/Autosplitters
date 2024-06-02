// Made by Nikoheart & TheDementedSalad
// Big shoutouts to the Ero for assistance within the Items logic and splitting
// Shoutouts to Rumii & Hntd for their assistance within for all the efforts of finding some of the values needed
// Extra shoutout to Rumii for adding code to finally fix the cutscene issues
state("ProjectNeon-Win64-Shipping", "1.0.0.648-20240516") { 
	byte loading : 0x56062E4;
	byte results : 0x55B7848;
}

state("ProjectNeon-Win64-Shipping", "1.0.1.649-20240527") { 
	byte loading : 0x539D138;
	byte results : 0x55B8848;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "RKGK / Rakugaki";

	dynamic[,] _settings =
	{
		{ "Splitting", true, "Splitting", null },
			{ "SplitLvl", false, "Split upon Level change", "Splitting" },
			{ "SplitResults", true, "Split on Results Screen", "Splitting"},
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

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
	vars.stopwatch = null;
}

init
{
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
    {
        using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            exeMD5HashBytes = md5.ComputeHash(s);
        }
    }

	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    vars.MD5Hash = MD5Hash;
    print("MD5: " + MD5Hash);

	switch(MD5Hash){
		case "C0851CDE0F095EC05124EFF834C10617" :
			version = "1.0.0.648-20240516";
			break;
		case "C6A54A424739CF2C086E14F855C18928" :
			version = "1.0.1.649-20240527";
			break;
		default:
			version = "Unknown Version";
            MessageBox.Show(timer.Form,
                "RKGK / Rakugaki Autosplitter Error:\n\n"
                + "This autosplitter does not support this game version.\n"
                + "Please contact Nikoheart (@nikoheart on Discord)\n"
                + "with the following string and the game's version number.\n\n"
                + "MD5Hash: " + MD5Hash + "\n\n"
                + "Defaulting to the most recent known memory addesses...",
                  "RKGK / Rakugaki Autosplitter Error",
                  MessageBoxButtons.OK,
                  MessageBoxIcon.Error);
			break;
	}

	IntPtr gEngine = vars.Helper.ScanRel(3, "48 89 05 ?? ?? ?? ?? 48 85 c9 74 ?? e8 ?? ?? ?? ?? 48 8d 4d");
	IntPtr fNames = vars.Helper.ScanRel(13, "89 5C 24 ?? 89 44 24 ?? 74 ?? 48 8D 15");

	// if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
    if (gEngine == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	// GWorld.Name
	// vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gEngine, 0x780, 0x78, 0x18);
	// vars.Helper["ResultsScreen"] = vars.Helper.Make<byte>(gEngine, 0x38, 0x0, 0xA8, 0x8, 0x4E8);
	// vars.Helper["Loading"] = vars.Helper.Make<byte>(gEngine, 0xD28, 0x230, 0x278, 0x6F8);

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
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;
	if (old.World != current.World) vars.Log("GWorldName: " + current.World.ToString());

	if (old.World != current.World) vars.stopwatch = Stopwatch.StartNew();
}

onStart
{
	vars.stopwatch = Stopwatch.StartNew();
	vars.CompletedSplits.Clear();
	// vars.Inventory.Clear();

	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
}

start
{
	return old.World == "MainMenu" && current.World == "Level_1_2";
}

split
{	
	if (settings["SplitLvl"])
	{
		if (current.World != "Level_7_6")
		{
			if (old.World != current.World && (current.World != "MainMenu" || current.World != "Hideout") && settings.ContainsKey(current.World)
			&& (!vars.CompletedSplits.Contains(current.World)))
			{
				vars.stopwatch = Stopwatch.StartNew();
				vars.CompletedSplits.Add(current.World);
				return true;
			}
		}
		else if (current.World == "Level_7_6")
		{
			if (settings.ContainsKey(current.World) && (!vars.CompletedSplits.Contains(current.World))
				&& old.results == 0 && current.results == 1 && vars.stopwatch.ElapsedMilliseconds >= 30000)
			{
				vars.stopwatch = Stopwatch.StartNew();
				vars.CompletedSplits.Add(current.World);
				return true;
			}
		}
		
	}
	if (settings["SplitResults"])
	{
		if (settings.ContainsKey(current.World) && (!vars.CompletedSplits.Contains(current.World))
			&& old.results == 0 && current.results == 1 && vars.stopwatch.ElapsedMilliseconds >= 30000)
		{
			vars.stopwatch = Stopwatch.StartNew();
			vars.CompletedSplits.Add(current.World);
			return true;
		}
	}
}

isLoading
{
	return current.loading == 0;
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
