state ("Europa-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Europa";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "MainGame", true, "Game Version - Main Game", null },
			{ "MG_Zone1Act2", true, "Chapter 1 - Leaving Home", "MainGame" },
			{ "MG_Zone1Act3", true, "Chapter 2 - A Saga Begins", "MainGame" },
			{ "MG_Zone2Act1", true, "Chapter 3 - Ancient Battlefield", "MainGame" },
			{ "MG_Zone2Act2", true, "Chapter 4 - Amber Horizon", "MainGame" },
			{ "MG_Zone2Act2_b", true, "Chapter 5 - Lost Island", "MainGame" },
			{ "MG_Zone2Act3", true, "Chapter 6 - Deep Ruins", "MainGame" },
			{ "MG_Zone3Act1", true, "Chapter 7 - The Bowl", "MainGame" },
			{ "MG_Zone3Act2", true, "Chapter 8 - Twilight", "MainGame" },
			{ "MG_Zone4Act2", true, "Chapter 9 - Wild Depths", "MainGame" },
			{ "MG_Zone4Act3", true, "Chapter 10 - Crisp Embrace", "MainGame" },
			{ "MG_Zone5Act1", true, "Chapter 11 - Flying High", "MainGame" },
			{ "MG_Zone5Act2", true, "Chapter 12 - Island Ascent", "MainGame" },
			{ "MG_Zone5FinalRush", true, "Chapter 13 - Golden Plains", "MainGame" },
			{ "MG_Zone5FinalFlight", true, "Chapter 14 - Crumbling Escape", "MainGame" },
			{ "MG_Ending", true, "Chapter 15 - Riding Home", "MainGame" },
		{ "Demo", false, "Game Version - Demo", null },
			{ "D_Zone1Act2", true, "Chapter 1 - Leaving Home", "Demo" },
			{ "D_Zone1Act3", true, "Chapter 2 - A Saga Begins & Demo End", "Demo" },
		{ "ZepherExpander", false, "Split on gaining Zepher Expander", null },
		{ "IL", false, "IL Splitting", null },
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
	vars.Sw = new Stopwatch();
}

init
{

	string MD5Hash;
	using (var md5 = System.Security.Cryptography.MD5.Create())
	using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
	MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	print("Hash is: " + MD5Hash);
	
	switch(MD5Hash){
		case "0AE8DFB1031F2D0F0917260A68CC05CE": version = "Steam Demo 1.0"; break;
		case "50EEB91F6397B12F2939313BE06C8CEE": version = "Steam Demo 1.1"; break;
		default: version = "Steam"; break;
	}

	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 89 05 ???????? 48 85 c9 74 ?? e8 ???????? 48 8d 4d");
	IntPtr fNames = vars.Helper.ScanRel(3, "48 8d 05 ???????? eb ?? 48 8d 0d ???????? e8 ???????? c6 05");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

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

	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	// GEngine.GameInstance.LastLoadedLevelName
	vars.Helper["StreamingLevelName"] = vars.Helper.Make<ulong>(gEngine, 0xD28, 0x1B8);
	vars.Helper["Loading"] = vars.Helper.Make<uint>(gEngine, 0xD28, 0x318);
	// GEngine.GameInstance.LocalPlayers[0].PlayerController.MainMenuComponent.bIsGamePaused
	vars.Helper["bIsGamePaused"] = vars.Helper.Make<bool>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x578, 0xB8);
	vars.Helper["bIsPlayerWaiting"] = vars.Helper.Make<byte>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x3D0);
	vars.Helper["ZepherExpandersCollected"] = vars.Helper.Make<int>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x590, 0x113C);

	//GEngine.?.?.?->MainMenuComponentUI->NewGameMainButton or something
	vars.Helper["bAllowFocusLost"] = vars.Helper.Make<bool>(gEngine, 0xD28, 0xD0, 0x170, 0x3E0, 0x310, 0x360, 0x688, 0x678, 0x678);

	current.LevelName = "";
	current.World = "";
}

onStart
{
	vars.Sw.Reset();
	timer.IsGameTimePaused = true;
}

start
{
	if (!settings["IL"])
	{
		return current.World == "LevelStreamingFullMap" && current.LevelName == "LiminalSpace_Finale";
	}
	else if (settings["IL"])
	{
		if (current.LevelName != "Zone2Act2_b") return current.World == "LevelStreamingFullMap" && current.bIsPlayerWaiting == 11;
		else if (current.LevelName == "Zone2Act2_b") return current.World == "LevelStreamingFullMap" && current.bIsPlayerWaiting == 9;
		
	}
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	if (old.Loading != current.Loading)
	{
		vars.Log(current.Loading);
	}

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Log("World: " + current.World);

	var levelname = vars.FNameToString(current.StreamingLevelName);
	if (!string.IsNullOrEmpty(levelname) && levelname != "None") current.LevelName = levelname;
	if (old.LevelName != current.LevelName) vars.Log("LevelName: " + current.LevelName);
	if (old.bIsPlayerWaiting != current.bIsPlayerWaiting) vars.Log("bIsPlayerWaiting: " + current.bIsPlayerWaiting);
}

isLoading
{
	switch (version){
		case "Steam Demo 1.0": 
			return current.bIsGamePaused || current.LevelName == "LiminalSpace_Finale" || current.World == "MainMenuMap"
			|| current.bIsPlayerWaiting != 9;
			break;
		case "Steam Demo 1.1":
			return current.bIsGamePaused || current.LevelName == "LiminalSpace_Finale" || current.World == "MainMenuMap"
			|| current.bIsPlayerWaiting != 9 || current.Loading != 0;
			break;
		default:
			return current.bIsGamePaused || current.LevelName == "LiminalSpace_Finale" || current.World == "MainMenuMap"
			|| current.bIsPlayerWaiting != 9 || current.Loading != 0;
			break;
	}
	
}

split
{
	switch (version){
		case "Steam Demo 1.0":
			if (settings["Demo"] && old.LevelName != current.LevelName && settings["D_" + current.LevelName.ToString()] && !vars.CompletedSplits.Contains("D_" + current.LevelName.ToString()))
			{
				vars.CompletedSplits.Add("D_" + current.LevelName.ToString());
				return true;
			}
			break;
		case "Steam Demo 1.1":
			if (settings["Demo"] && old.LevelName != current.LevelName && settings["D_" + current.LevelName.ToString()] && !vars.CompletedSplits.Contains("D_" + current.LevelName.ToString()))
			{
				vars.CompletedSplits.Add("D_" + current.LevelName.ToString());
				return true;
			}
			break;
		default:
			if (settings["MainGame"] && old.LevelName != current.LevelName && settings["MG_" + current.LevelName.ToString()] && !vars.CompletedSplits.Contains("MG_" + current.LevelName.ToString()))
			{
				vars.CompletedSplits.Add("MG_" + current.LevelName.ToString());
				return true;
			}
			// Start Stopwatch for End Split
			if (settings["MainGame"] && current.LevelName == "Zone5FinalFlight")
			{
				vars.Sw.Start();
			}
			if (settings["MainGame"] && settings["MG_Ending"] && current.LevelName == "Zone5FinalFlight" && vars.Sw.Elapsed.TotalSeconds >= 20.0 && old.bIsPlayerWaiting == 9 && current.bIsPlayerWaiting == 11 && !vars.CompletedSplits.Contains("MG_Ending"))
			{
				vars.CompletedSplits.Add("MG_Ending");
				return true;
			}
			if (settings["MainGame"] && settings["ZepherExpander"] && old.ZepherExpandersCollected != current.ZepherExpandersCollected && !vars.CompletedSplits.Contains(current.ZepherExpandersCollected.ToString()))
			{
				vars.CompletedSplits.Add(current.ZepherExpandersCollected.ToString());
				return true;
			}
			break;
		}	
}