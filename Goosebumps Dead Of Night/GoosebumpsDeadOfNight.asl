state("Goosebumps_DeadOfNight")
{
	int IsSlappyDead : "fmodstudio.dll", 0x002B7DF0, 0x18, 0x18, 0x170, 0x8, 0x88, 0x20, 0x28;
}

startup
{
	vars.Log = (Action<object>)(value => print(String.Concat("[Goosebumps_DeadOfNight] ", value)));
	var bytes = File.ReadAllBytes(@"Components\LiveSplit.ASLHelper.bin");
	var type = Assembly.Load(bytes).GetType("ASLHelper.Unity");
	vars.Helper = Activator.CreateInstance(type, timer, this);
	vars.Helper.LoadSceneManager = true;
		
	dynamic[,] settingsArray =
	{
		{ "Scenes", true, "Scenes", null },
			{ "Conservatory_Interactive", true,	"Conservatory", "Scenes" },
			{ "TeslaTowerExt_Interactive", true, "Telsa Tower (Outside)", "Scenes" },
			{ "Tesla_Tower_Interactive", false, "Telsa Tower (Inside)", "Scenes" },
			{ "Tesla_Tower_Basement_Interactive", false, "Telsa Tower (Basement)", "Scenes" },
			{ "Tesla_Witches_Transition_Interactive", false, "Telsa Tower (Witches Catwalk)", "Scenes" },
			{ "Tesla_Tower_Top_Interactive", true, "Telsa Tower (Slappy Fight)", "Scenes" },
		{ "Final_Hit", true, "Detect Final Hit of Slappy for End Split", null },
		{ "IL_Timer", false, "IL Runs (Start from Chapter)", null } 
	};
	
	vars.settingsArray = settingsArray;

	for (int i = 0; i < vars.settingsArray.GetLength(0); i++)
	{
		var name = vars.settingsArray[i, 0];
		var defaultSetting = vars.settingsArray[i, 1];
		var description = vars.settingsArray[i, 2];
		var parent = vars.settingsArray[i, 3];

		settings.Add(name, defaultSetting, description, parent);
	}

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var messageBox = MessageBox.Show(
			"The game is run in IGT (Time without Loads - Game Time).\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time?",
			"LiveSplit | Goosebumps: Dead of Night", 
			MessageBoxButtons.YesNo, MessageBoxIcon.Question);
		if (messageBox == DialogResult.Yes)
			timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

init
{
	current.KeyScene = String.Empty;
	vars.Helper.Load();
}

update
{
	if (!vars.Helper.Update()) return false;

	current.Scene = vars.Helper.Scenes.Active.Name;
	if (old.Scene != current.Scene) vars.Log(String.Concat("Scene Change: ", current.Scene));

	for (var i = 0; i < vars.settingsArray.GetLength(0); i++)
	{
		var name = vars.settingsArray[i, 0];
		var parent = vars.settingsArray[i, 3];

		if (parent == "Scenes" && current.Scene == name) current.KeyScene = name;
	}
}

onStart
{
	timer.IsGameTimePaused = true;
	print("\nSTART\n-----\n");
	current.KeyScene = String.Empty;
	for (var i = 0; i < vars.settingsArray.GetLength(0); i++)
	{
		var name = vars.settingsArray[i, 0];
		var parent = vars.settingsArray[i, 3];

		if (parent == "Scenes" && current.Scene == name)
		{
			current.KeyScene = name;
			current.KeyScene = name;
		} 
	}
}

start
{
	if (settings["IL_Timer"])
	{
		return (old.Scene == "House_Slappy_Room_Menu" && current.Scene == "Loader");
	}
	else return (old.Scene == "IntroCutscene" && current.Scene == "Loader");
}

split
{
	if (old.KeyScene != current.KeyScene)
	{
		vars.Log("Key Scene: " + current.KeyScene + " reached!");
		return settings[current.KeyScene];
	}
	if (old.IsSlappyDead == 0 && current.IsSlappyDead == 1)
	{
		print("\nFinal Hit!\n----------------\n");
		return settings["Final_Hit"];
	}
}

onSplit
{
	print("\nSplit\n-----\n");
}

reset
{
	return (current.Scene == "House_Slappy_Room_Menu");
}

onReset
{
	print("\nRESET\n-----\n");
}

isLoading
{
	return (current.Scene == "Loader");
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}
