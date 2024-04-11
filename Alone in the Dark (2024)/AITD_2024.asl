// Made by Nikoehart & TheDementedSalad
// Big shoutouts to the Ero for assistance within the Items logic and splitting
// Shoutouts to Rumii & Hntd for their assistance within for all the efforts of finding some of the values needed
// Extra shoutout to Rumii for adding code to finally fix the cutscene issues
state("AloneInTheDark-Win64-Shipping") { }

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
	vars.Helper["Loading"] = vars.Helper.Make<bool>(gEngine, 0xD30, 0xE8 + 0x8, 0x18 * 24 + 0x8, 0x50);

	// GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.Inventory.InventoryItems.AllocatorInstance
	vars.Helper["Items"] = vars.Helper.Make<IntPtr>(gEngine, 0xD30, 0x38, 0x0 * 0x8, 0x30, 0x660, 0x1A0 + 0x0);

	// GWorld.OwningGameInstance.LocalPlayers[0].PlayerController.Inventory.InventoryItems.ArrayNum
	vars.Helper["ItemCount"] = vars.Helper.Make<int>(gEngine, 0xD30, 0x38, 0x0 * 0x8, 0x30, 0x660, 0x1A0 + 0x8);

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

	// -----------------------------------

	vars.piecesLevelSequencePlayer = 0; vars.cutsceneStatus = 0;
	vars.currentCutscene = ""; vars.oldCutscene = "";
	vars.sequencePlayerFunction = vars.Helper.Scan("AloneInTheDark-Win64-Shipping.exe", 0xC, "48 8B C8 E8 ?? ?? ?? ?? 0F 10 45 D7");

	if (vars.sequencePlayerFunction != IntPtr.Zero)
	{
		vars.allocatedMemory = memory.AllocateMemory(0x200);

		if (vars.allocatedMemory != IntPtr.Zero)
		{
			vars.piecesLevelSequencePlayer = vars.allocatedMemory + 0x100;

			byte[] gutBytes = { 0x49, 0x8B, 0x06, 0x4C, 0x8D, 0x4D, 0x77, 0x0F, 0x10, 0x4D, 0xE7, 0x48, 0x8D, 0x55, 0xA7 };
			byte[] gutBytesInjected = { 0xFF, 0x25, 0x00, 0x00, 0x00, 0x00 };

			byte[] foundBytes = memory.ReadBytes((IntPtr)vars.sequencePlayerFunction, 0x0F);
			byte[] foundBytesInjected = memory.ReadBytes((IntPtr)vars.sequencePlayerFunction, 0x06);

			if (gutBytes.SequenceEqual(foundBytes) || gutBytesInjected.SequenceEqual(foundBytesInjected))
			{
				byte[] s1 = { 0xFF, 0x25, 0x00, 0x00, 0x00, 0x00 };
				byte[] s2 = BitConverter.GetBytes((ulong)vars.allocatedMemory);
				byte[] s3 = { 0x90 };
				byte[] start = s1.Concat(s2).Concat(s3).ToArray();

				byte[] e1 = { 0x4C, 0x89, 0x35 };
				byte[] e2 = BitConverter.GetBytes((int)0xF9);
				byte[] e3 = gutBytes;
				byte[] e4 = { 0xFF, 0x25, 0x00, 0x00, 0x00, 0x00 };
				byte[] e5 = BitConverter.GetBytes((ulong)vars.sequencePlayerFunction + 0x0F);
				byte[] end = e1.Concat(e2).Concat(e3).Concat(e4).Concat(e5).ToArray();

				memory.WriteBytes((IntPtr)vars.allocatedMemory, end);
				memory.WriteBytes((IntPtr)vars.sequencePlayerFunction, start);
			}
		}
	}
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	// -----------------------------------

	ulong resolveHookPointer = memory.ReadValue<ulong>((IntPtr)(vars.piecesLevelSequencePlayer));

	if (resolveHookPointer != 0)
    {
		vars.cutsceneStatus = memory.ReadValue<byte>((IntPtr)(resolveHookPointer + 0x2B0));

		ulong sequence = memory.ReadValue<ulong>((IntPtr)(resolveHookPointer + 0x2B8));
		if (sequence != 0)
        {
			ulong sequencePrivate = memory.ReadValue<ulong>((IntPtr)(sequence + 0x18));
			if (sequencePrivate != 0 && vars.cutsceneStatus == 1) vars.currentCutscene = vars.FNameToShortString((ulong)(sequencePrivate));
		}
    }

	// -----------------------------------

	var world = vars.FNameToString(current.GWorldName);
	var cutscene = vars.currentCutscene;
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;


	if (!string.IsNullOrEmpty(cutscene))
		vars.currentCutscene = cutscene;
	if (vars.oldCutscene != vars.currentCutscene)
		vars.Log("Cutscene: " + vars.oldCutscene + " -> " + vars.currentCutscene);
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

	if (vars.oldCutscene != vars.currentCutscene
		&& settings.ContainsKey(vars.currentCutscene) && settings[vars.currentCutscene]
		&& vars.CompletedSplits.Add(vars.oldCutscene))
	{
		return true;
	}

	if (vars.oldCutscene != vars.currentCutscene && vars.Ending.Contains(vars.currentCutscene) && !vars.CompletedSplits.Contains(vars.currentCutscene) &&
		vars.CompletedSplits.Add(vars.oldCutscene))
	{
		return true;
	}

	// -----------------------------------

	vars.oldCutscene = vars.currentCutscene;
}

isLoading
{
	return current.Paused || current.Loading || vars.cutsceneStatus == 1 && (vars.currentCutscene != "LS_Grapple_Ceme_Start" || vars.currentCutscene != "LS_Grapple_Ceme_Success" || vars.currentCutscene != "LS_DSS_Wing_PureIntroduction");
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
