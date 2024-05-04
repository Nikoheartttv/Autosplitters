state("Indika-Win64-Shipping") { }

startup
{
	// vars.ItemSettingFormat = "[{0}] {1} ({2})";

	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Indika";
	vars.Helper.AlertGameTime();
	vars.CompletedSplits = new HashSet<string>();

	dynamic[,] _settings =
	{
		{ "Levels", true, "Levels", null },
			{ "Base_RiverCross", true, "Tihon", "Levels" },
			{ "Base_Village", true, "Train Wreck", "Levels" },
			{ "BASE_BikeRoad_2", true, "Chase", "Levels" },
			{ "Pixel_Bike_v2", true, "Mirko", "Levels" },
			{ "BASE_BikeRoad_3", true, "Road", "Levels" },
			{ "Base_Mill_Enter", true, "Village", "Levels" },
			{ "Base_Ambar", true, "Barn", "Levels" },
			{ "Base_Mill_Center", true, "Under The Mill", "Levels" },
			{ "Base_MillInt", true, "Mill", "Levels" },
			{ "Base_Mill_Station", true, "Station", "Levels" },
			{ "L_UD_PixelTown_02", true, "Roof", "Levels" },
			{ "Base_Fish_Factory_BeforeVat", true, "Fish Factory", "Levels" },
			{ "Base_FiFaInt", true, "Stroboscopic Effect", "Levels" },
			{ "L_UnrealDima_LakePuzzle_V3", true, "Pond", "Levels" },
			{ "Base_TownWall", true, "Spasov", "Levels" },
			{ "BASE_CityBell", true, "Kudets", "Levels" },
			{ "L_ShopMiniGame_v2", true, "Bicycle Shop", "Levels" },
			{ "BASE_CityBell_Makar", true, "Makar the Scytheman", "Levels" },
			{ "BASE_CityBell_Bottom", true, "Pawn Shop", "Levels" },
		{ "EndSplit", true, "End Split (Always On)", null}
	};

	vars.Helper.Settings.Create(_settings);
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 39 35 ?? ?? ?? ?? 0F 85 ?? ?? ?? ?? 48 8B 0D");
	IntPtr fNames = vars.Helper.ScanRel(13, "89 5C 24 ?? 89 44 24 ?? 74 ?? 48 8D 15");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	// GWorld.Name
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);

	vars.Helper["Points"] = vars.Helper.Make<int>(gEngine, 0xD28, 0x310);

	vars.Helper["LevelUpWidget"] = vars.Helper.Make<long>(gEngine, 0xD28, 0x440);

	vars.Helper["CutScenePlaying"] = vars.Helper.Make<bool>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x63C);

	vars.Helper["MouseControl"] = vars.Helper.Make<bool>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x63E);

	vars.Helper["Loading"] = vars.Helper.Make<byte>(gEngine, 0xD28, 0x448, 0xD8);

	vars.Helper["FinalEnabled"] = vars.Helper.Make<bool>(gEngine, 0xD28, 0x38, 0x0, 0x30, 0x2B8, 0xE90, 0x2D4);

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
	vars.PawnShopLevelUpWidget = 0;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None" && world != "Base_EmptyLoader")
		current.World = world;
	if(old.World != current.World) vars.Log("World: " + current.World.ToString());

	if(old.CutScenePlaying != current.CutScenePlaying) vars.Log("CutscenePlaying: " + current.CutScenePlaying.ToString());
	if(old.Loading != current.Loading) vars.Log("Loading: " + current.Loading.ToString());
}

onStart
{
	vars.CompletedSplits.Clear();
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
}

start
{
	return old.World == "Menu_Lamp" && current.World == "Base_Monastery_3";
}

isLoading
{
	return current.CutScenePlaying || current.Loading == 0;
}

split
{
	if (old.World != current.World && settings.ContainsKey(current.World) && settings[current.World]
		&& vars.CompletedSplits.Add(current.World))
	{
		return true;
	}

	if (current.World == "Lavka" && old.FinalEnabled == false && current.FinalEnabled == true && settings["EndSplit"])
	{
		return true;
	}
}

exit
{
	//pauses timer if the game crashes
	timer.IsGameTimePaused = true;
}
