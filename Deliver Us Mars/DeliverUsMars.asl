state("DeliverUsMars-Win64-Shipping"){}

startup
{
	settings.Add("Check", true, "Deliver Us Mars");
	vars.chaptersVisited = new List<string>();

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{        
		var timingMessage = MessageBox.Show (
			"This game uses Time without Loads (Game Time) as the main timing method.\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time?",
			"LiveSplit | Deliver Us Mars",
			MessageBoxButtons.YesNo,MessageBoxIcon.Question
		);
		if (timingMessage == DialogResult.Yes)
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}

	vars.chapterSplits = new Dictionary<string, string>{
		{ "1000_JohansonHouse_Persistent", "Prologue" },
		{ "010_Earth_Campus_Persistent", "Chapter 1" },
		{ "020_ZephyrScuba_Persistent", "Chapter 2" },
		{ "030_Labos_Persistent", "Chapter 3" },
		{ "040_HerschelQuarry_Persistent", "Chapter 4" },
		{ "1050_Habitas_Persistent", "Chapter 5" },
		{ "060_Odum_Persistent", "Chapter 6" },
		{ "2050_Habitas_Persistent", "Chapter 7" },
		{ "080_Labos_Wreckage_Persistent", "Chapter 8" },
		{ "2000_JohansonHouse_Persistent", "Chapter 9" },
		{ "100_Vita_Persistent", "Epliogue" },
	};

	foreach (var Tag in vars.chapterSplits)
	{
		settings.Add(Tag.Key, true, Tag.Value, "Check");
	};
	
	vars.doneSplit = new List<string>();	
}

init
{
	vars.TimesToHabitas = 1;
	vars.TimesToJohansonHouse = 1;

	vars.GetStaticPointerFromSig = (Func<string, int, IntPtr>) ( (signature, instructionOffset) => {
		var scanner = new SignatureScanner(game, modules.First().BaseAddress, (int)modules.First().ModuleMemorySize);
		var pattern = new SigScanTarget(signature);
		var location = scanner.Scan(pattern);
		if (location == IntPtr.Zero) return IntPtr.Zero;
		int offset = game.ReadValue<int>((IntPtr)location + instructionOffset);
		return (IntPtr)location + offset + instructionOffset + 0x4;
	});

	vars.GetNameFromFName = (Func<long, string>) ( longKey => {
		int key = (int)(longKey & uint.MaxValue);
		int partial = (int)(longKey >> 32);
		int chunkOffset = key >> 16;
		int nameOffset = (ushort)key;
		IntPtr namePoolChunk = memory.ReadValue<IntPtr>((IntPtr)vars.FNamePool + (chunkOffset+2) * 0x8);
		Int16 nameEntry = game.ReadValue<Int16>((IntPtr)namePoolChunk + 2 * nameOffset);
		int nameLength = nameEntry >> 6;
		string output = game.ReadString((IntPtr)namePoolChunk + 2 * nameOffset + 2, nameLength);
		return (partial == 0) ? output : output + "_" + partial.ToString();
	});

	vars.FNamePool = vars.GetStaticPointerFromSig("74 09 48 8D 15 ?? ?? ?? ?? EB 16", 0x5);
	vars.UWorld = vars.GetStaticPointerFromSig("0F 2E ?? 74 ?? 48 8B 1D ?? ?? ?? ?? 48 85 DB 74", 0x8);
	vars.GameEngine = vars.GetStaticPointerFromSig("48 89 05 ?? ?? ?? ?? 48 85 C9 74 05 E8 ?? ?? ?? ?? 48 8D 4D E0 E8", 0x3);
	vars.Loading = vars.GetStaticPointerFromSig("89 05 ?? ?? ?? ?? 85 C9 74", 0x2);
	vars.Loading2 = vars.GetStaticPointerFromSig("89 05 ?? ?? ?? ?? C3 CC CC CC CC CC CC 48 89 5C 24 ?? 48 89 74 24", 0x2);
	vars.Credits = vars.GetStaticPointerFromSig("0F B6 05 ?? ?? ?? ?? C3 CC CC CC CC CC CC CC CC 48 8B C4", 0x3);

	if(vars.FNamePool == IntPtr.Zero || vars.UWorld == IntPtr.Zero || vars.GameEngine == IntPtr.Zero)
	{
		throw new Exception("FNamePool/UWorld/GameEngine not initialized - trying again");
	}
	
	string MD5Hash;
	using (var md5 = System.Security.Cryptography.MD5.Create())
	using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
	MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	print("Hash is: " + MD5Hash);
	
	switch(MD5Hash){
		case "7C99533B59A26DD4B471B0E1C35957ED": version = "Steam 1.0.0"; break;
		case "C20DBCEA3BA9F1CD2BEECA03C194B87E": version = "Steam 1.0.1"; break;
		default: version = "Steam"; break;
	}
	
	vars.watchers = new MemoryWatcherList
	{
		new MemoryWatcher<long>(new DeepPointer(vars.UWorld, 0x18)) { Name = "worldFName"},
		new MemoryWatcher<byte>(new DeepPointer(vars.Loading)) { Name = "load"},
		new MemoryWatcher<byte>(new DeepPointer(vars.Credits)) { Name = "credits"},
		new MemoryWatcher<byte>(new DeepPointer(vars.Loading2)) { Name = "load2"},
	};

	current.gameState = 0;
	current.map = "";
}

update
{
	vars.watchers.UpdateAll(game);
	
	current.loading = vars.watchers["load"].Current;
	current.loading2 = vars.watchers["load2"].Current;
	vars.map = vars.GetNameFromFName(vars.watchers["worldFName"].Current);
	current.endSplit = vars.watchers["credits"].Current;
	
	if(!String.IsNullOrEmpty(vars.map) && vars.map != "None")
	{
		current.map = vars.map;

		if (current.map == "050_Habitas_Persistent")
		{
			current.map = (vars.TimesToHabitas.ToString() + "050_Habitas_Persistent");
		}
		
		if (current.map == "000_JohansonHouse_Persistent")
		{
			current.map = (vars.TimesToHabitas.ToString() + "000_JohansonHouse_Persistent");
		}
	}

	if(current.map != old.map) print("current map: " + current.map);

	if (vars.doneSplit.Contains("1050_Habitas_Persistent") && (current.map == "060_Odum_Persistent"))
	{
		vars.TimesToHabitas = 2;
	}
	if (vars.doneSplit.Contains("1000_JohansonHouse_Persistent") && (current.map == "080_Labos_Wreckage_Persistent"))
	{
		vars.TimesToHabitas = 2;
	}
}

onStart
{
	vars.doneSplit.Add(current.map);
}

start
{
	if(old.map == "L_Mars_Menu" && current.map != "L_Mars_Menu")
	{
		timer.IsGameTimePaused = true;
		return true;
	}
}

split
{
	if ((old.map != current.map) && (current.map != "L_Mars_Menu") && (settings[(current.map)]) && (!vars.doneSplit.Contains(current.map)))
	{
		print("Split");
		vars.doneSplit.Add(current.map);
		return true;
    }
	if (current.map == "100_Vita_Persistent" && (old.endSplit == 2 && current.endSplit == 1))
	{
		print("Split");
		return true;
	}

}

isLoading
{
	return (current.loading != 0 || current.loading2 != 0);
}

onReset
{
	vars.doneSplit.Clear();
	vars.TimesToHabitas = 1;
	vars.TimesToJohansonHouse = 1;
}
