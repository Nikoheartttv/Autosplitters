state("Goosebumps_DeadOfNight")
{
	int IsSlappyDead : "fmodstudio.dll", 0x002B7DF0, 0x18, 0x18, 0x170, 0x8, 0x88, 0x20, 0x28;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Goosebumps Dead of Night";
	vars.Helper.LoadSceneManager = true;
		
	dynamic[,] _settings =
	{
		{ "Scenes", true, "Scenes", null },
			{ "Conservatory_Interactive", true, "Conservatory", "Scenes" },
			{ "TeslaTowerExt_Interactive", true, "Telsa Tower (Outside)", "Scenes" },
			{ "Tesla_Tower_Interactive", false, "Telsa Tower (Inside)", "Scenes" },
			{ "Tesla_Tower_Basement_Interactive", false, "Telsa Tower (Basement)", "Scenes" },
			{ "Tesla_Witches_Transition_Interactive", false, "Telsa Tower (Witches Catwalk)", "Scenes" },
			{ "Tesla_Tower_Top_Interactive", true, "Telsa Tower (Slappy Fight)", "Scenes" },
		{ "Final_Hit", true, "Detect Final Hit of Slappy for End Split", null },
		{ "IL_Timer", false, "IL Runs (Start from Chapter)", null } 
	};
	
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();

	vars.VisitedLevel = new List<string>();
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name ?? current.activeScene;
	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name ?? current.loadingScene;

	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");
}

onStart
{
	timer.IsGameTimePaused = true;
}

start
{
	if (settings["IL_Timer"])
	{
		return (old.activeScene == "House_Slappy_Room_Menu" && current.activeScene == "Loader");
	}
	else return (old.activeScene == "IntroCutscene" && current.activeScene == "Loader");
}

split
{
	if (old.activeScene != current.activeScene) 
	{ 
        	if (!vars.VisitedLevel.Contains(current.activeScene))
		{
			vars.VisitedLevel.Add(current.activeScene);
			return settings[current.activeScene];
		}
	}
	if (old.IsSlappyDead == 0 && current.IsSlappyDead == 1)
	{
		return settings["Final_Hit"];
	}
}

reset
{
	return (current.activeScene == "House_Slappy_Room_Menu");
}

isLoading
{
	return (current.activeScene == "Loader");
}
