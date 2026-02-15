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
			{ "Seed", false, "Seed Log", null },
	};
	vars.Uhara.Settings.Create(_settings);

	var desktop = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
	var path = Path.Combine(desktop, "EventComponentLog.txt");
	vars.Writer = new StreamWriter(path, true); // append mode

	#region TextComponent
	//Dictionary to cache created/reused layout components by their left-hand label (Text1)
	vars.lcCache = new Dictionary<string, LiveSplit.UI.Components.ILayoutComponent>();
	//Function to set (or update) a text component
	vars.SetText = (Action<string, object>)((text1, text2) =>
	{
		const string FileName = "LiveSplit.Text.dll";
		LiveSplit.UI.Components.ILayoutComponent lc;

		//Try to find an existing layout component with matching Text1 (label)
		if (!vars.lcCache.TryGetValue(text1, out lc))
		{
			lc = timer.Layout.LayoutComponents.Reverse().Cast<dynamic>()
				.FirstOrDefault(llc => llc.Path.EndsWith(FileName) && llc.Component.Settings.Text1 == text1)
				?? LiveSplit.UI.Components.ComponentManager.LoadLayoutComponent(FileName, timer);

			//Cache it for later reference
			vars.lcCache.Add(text1, lc);
		}

		//If it hasn't been added to the layout yet, add it
		if (!timer.Layout.LayoutComponents.Contains(lc))
			timer.Layout.LayoutComponents.Add(lc);

		//Set the label (Text1) and value (Text2) of the text component
		dynamic tc = lc.Component;
		tc.Settings.Text1 = text1;
		tc.Settings.Text2 = text2.ToString();
	});

	//Function to remove a single text component by its label
	vars.RemoveText = (Action<string>)(text1 =>
	{
		LiveSplit.UI.Components.ILayoutComponent lc;

		//If it's cached, remove it from the layout and the cache
		if (vars.lcCache.TryGetValue(text1, out lc))
		{
			timer.Layout.LayoutComponents.Remove(lc);
			vars.lcCache.Remove(text1);
		}
	});

	//Function to remove all text components that were added via this script
	vars.RemoveAllTexts = (Action)(() =>
	{
		//Remove each one from the layout
		foreach (var lc in vars.lcCache.Values)
			timer.Layout.LayoutComponents.Remove(lc);

		//Clear the cache
		vars.lcCache.Clear();
	});
    #endregion
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
	current.World = "";
	vars.Resolver.Watch<bool>("CineVideoLock", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x6A8, 0xC0);

	IntPtr SaveGame = vars.Events.InstancePtr("Routine_SaveGame_C", "");
	vars.Resolver.Watch<int>("Seed", SaveGame, 0xF8);
	
	vars.Resolver.Watch<IntPtr>("EventComponent", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x2E8, 0x708, 0xA8);
	vars.Resolver.Watch<int>("EventComponentCount", vars.Utils.GEngine, 0x11F8, 0x38, 0x0, 0x30, 0x2E8, 0x708, 0xB0);

	current.Seed = 0;

	//Helper function that sets or removes text depending on whether the setting is enabled - only works in `init` or later because `startup` cannot read setting values
	vars.SetTextIfEnabled = (Action<string, object>)((text1, text2) =>
	{
		if (settings[text1])            //If the matching setting is checked
			vars.SetText(text1, text2); //Show the text
		else
			vars.RemoveText(text1);     //Otherwise, remove it
	});
}

update
{
	vars.Uhara.Update();

	string world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World Change: " + current.World);

	if (current.EventComponentCount > old.EventComponentCount)
	{
		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18));

		if (!string.IsNullOrEmpty(name))
		{
			vars.Uhara.Log("Last EventComponent FName: " + name);

			TimeSpan realTime = timer.CurrentTime.RealTime.HasValue ? timer.CurrentTime.RealTime.Value : TimeSpan.Zero;
			string timeStr = realTime.ToString(@"hh\:mm\:ss");

			vars.Writer.WriteLine(timeStr + " - " + name);
			vars.Writer.Flush();
		}
	}

	if (old.GSync != current.GSync) vars.Uhara.Log("GSync changed: " + current.GSync);
	//More text component stuff - checking for setting and then generating the text. No need for .ToString since we do that previously
	vars.SetTextIfEnabled("Seed",current.Seed);
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
		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18)
		);

		if (settings.ContainsKey(name) && settings[name] && !vars.CompletedSplits.Contains(name))
		{
			vars.CompletedSplits.Add(name);
			return true;
		}
	}

	// End Split
	if (settings.ContainsKey("EndSplit") && settings["EndSplit"] && current.World == "Map_Game_Caves_Master" && current.CineVideoLock && !vars.CompletedSplits.Contains("EndSplit"))
	{
		string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.EventComponent + 0x10 * (current.EventComponentCount - 1), 0x18)
		);

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

shutdown
{
	vars.Writer.Close();
}
