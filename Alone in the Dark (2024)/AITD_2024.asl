// Made by Nikoehart & TheDementedSalad
// Big shoutouts to the Ero for assistance within the Items logic and splitting
// Shoutouts to Rumii & Hntd for their assistance within for all the efforts of finding some of the values needed 
state("AloneInTheDark-Win64-Shipping") {}

startup
{
	vars.ItemSettingFormat = "[{0}] {1} ({2})";
	
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.Settings.CreateFromXml("Components/AITD_2024.Settings.xml");
	vars.Helper.GameName = "Alone in the Dark (2024)";
	//vars.Helper.StartFileLogger("AitD_Log.txt");
	
	vars.CompletedSplits = new HashSet<string>();
	vars.Inventory = new Dictionary<ulong, int>();
	vars.EnteredCutscenes = new HashSet<string>();
}

onStart
{
	vars.CompletedSplits.Clear();
	vars.Inventory.Clear();
	
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 39 35 ?? ?? ?? ?? 0F 85 ?? ?? ?? ?? 48 8B 0D");
	IntPtr fNames = vars.Helper.ScanRel(13, "89 5C 24 ?? 89 44 24 ?? 74 ?? 48 8D 15");
	var cutscenename = vars.Helper.ScanRel(3, "48 8B 05 ?? ?? ?? ?? F6 87");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	// GWorld.Name
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	
	// GWorld.OwningGameInstance.SubsystemCollection.SubsystemMap[12].Item2.? (PiecesSaveSubsystem + 0xA0)
	vars.Helper["Paused"] = vars.Helper.Make<bool>(gEngine, 0xD30, 0xE8 + 0x8, 0x18 * 12 + 0x8, 0xA0);
	
	// GWorld.OwningGameInstance.SubsystemCollection.SubsystemMap[24].Item2.? (UPiecesWorldTransition_Subsystem + 0x50)
	vars.Helper["Loading"] = vars.Helper.Make<bool>(gEngine, 0xD30,  0xE8 + 0x8, 0x18 * 24 + 0x8, 0x50);

	// GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.Inventory.InventoryItems.AllocatorInstance
	vars.Helper["Items"] = vars.Helper.Make<IntPtr>(gEngine, 0xD30, 0x38, 0x0 * 0x8, 0x30, 0x660, 0x1A0 + 0x0);

	// GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.Inventory.InventoryItems.ArrayNum
	vars.Helper["ItemCount"] = vars.Helper.Make<int>(gEngine, 0xD30, 0x38, 0x0 * 0x8, 0x30, 0x660, 0x1A0 + 0x8);

	vars.Helper["CutsceneName"] = vars.Helper.MakeString(cutscenename, 0x70, 0x420, 0x290, 0x50, 0x40, 0x20, 0x268, 0x308, 0x3D8, 0x90, 0x40, 0x8, 0x58, 0x0, 0x548, 0x0);

	vars.Helper["CutsceneName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

	vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx  = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number   = (fName & 0xFFFFFFFF00000000) >> 0x20;

		IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Helper.Read<short>(entry) >> 6;
		string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});
	
	vars.FNameToShortString = (Func<ulong, string>)(fName =>
	{
		string name = vars.FNameToString(fName);

		int dot = name.LastIndexOf('.');
		int slash = name.LastIndexOf('/');

		return name.Substring(Math.Max(dot, slash) + 1);
	});

	current.World = "";
	current.Cutscene = "";

	vars.Ending = new List<string>()
    {"LS_EndTransition_Edw", "LS_EndTransition_Eml", "cin_600_silly_ending", 
	"cin_550_emi_alternative_ending", "cin_280_edw_alternative_ending_A",};
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	var cutscene = current.CutsceneName;
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;
	
	if (!string.IsNullOrEmpty(cutscene))
		current.Cutscene = cutscene;
	if (old.Cutscene != current.Cutscene)
	vars.Log("Cutscene: " + old.Cutscene + " -> " + current.Cutscene); 
}

start
{
	return old.World == "FrontSide_P" && current.World == "ActWorld_1_P";
}

split
{
	const string ItemFormat = "[{0}] {1} ({2})";
	
	// Item splits.
	for (int i = 0; i < current.ItemCount; i++)
	{
		string setting = "";

		// ...[i].Item1.ObjectID.AssetPathName
		ulong item = vars.Helper.Read<ulong>(current.Items + 0x50 * i + 0x00 + 0x00 + 0x10);

		// ...[i].Item2.Amount
		int amount = vars.Helper.Read<int>(current.Items + 0x50 * i + 0x28 + 0x00);

		int oldAmount;
		if (vars.Inventory.TryGetValue(item, out oldAmount)) // If the item already existed in the inventory.
		{
			if (oldAmount < amount) // If the amount increased.
			{
				// Builds a string like "[+] ID_Flashlight_Emily (1)".
				setting = string.Format(ItemFormat, '+', vars.FNameToShortString(item), amount);
			}
			else if (oldAmount > amount) // If the amount decreased (includes 0).
			{
				// Builds a string like "[-] ID_Flashlight_Emily (0)".
				setting = string.Format(ItemFormat, '-', vars.FNameToShortString(item), amount);
			}
		}
		else // If the item didn't exist in the inventory before.
		{
			// Builds a string like "[+] ID_Flashlight_Emily (!)".
			setting = string.Format(ItemFormat, '+', vars.FNameToShortString(item), '!');
		}

		vars.Inventory[item] = amount;

		// Split if the setting exists, is enabled and hasn't been added to the completed splits yet.
		if (settings.ContainsKey(setting) && settings[setting]
			&& vars.CompletedSplits.Add(setting))
		{
			return true;
		}
	}
	
	if (old.World != current.World
		&& settings.ContainsKey(current.World) && settings[current.World]
		&& vars.CompletedSplits.Add(old.World))
	{
		return true;
	}

	if (old.Cutscene != current.Cutscene
		&& settings.ContainsKey(current.Cutscene) && settings[current.Cutscene]
		&& vars.CompletedSplits.Add(old.Cutscene))
	{
		return true;
	}
}

isLoading
{
return current.Paused || current.Loading || !string.IsNullOrEmpty(current.CutsceneName) && (current.CutsceneName != "LS_Grapple_Ceme_Start" || current.CutsceneName != "LS_Grapple_Ceme_Success");
}

reset
{
	return old.World == "MainMenu" && current.World == "FrontSide_P";
}

exit
{
    //pauses timer if the game crashes
    timer.IsGameTimePaused = true;
}
