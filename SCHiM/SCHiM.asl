state("SCHiM"){}

startup
{
	vars.Log = (Action<object>)(output => print("[SCHiM] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "SCHiM Demo";
	vars.Helper.LoadSceneManager = true;

	// dynamic[,] _settings =
	// {
	// 	{ "Splits", true, "Splits", null },
	// 		{ "Game Tutorial Child", true, "Level 1", "Splits" },
	// 		{ "Garden", true, "Level 2", "Splits" },
	// 		{ "Tutorial Tricycle", true, "Level 3", "Splits" },
	// 		{ "Geeuwkade 1", true, "Level 4", "Splits" },
	// 		{ "Growing Up", true, "Level 5", "Splits"},
	// 		{ "Office Interactable Scene", true, "Level 6", "Splits"},
	// 		{ "Chase Scene Winkelstraat", true, "Level 7", "Splits"},
	// };

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits on Scene Change", null },
			{ "Game Tutorial Child", true, "Level 1", "Splits" },
			{ "Garden", true, "Level 2", "Splits" },
			{ "Tutorial Tricycle", true, "Level 3", "Splits" },
			{ "Geeuwkade 1", true, "Level 4", "Splits" },
			{ "Growing Up", true, "Level 5", "Splits"},
			{ "Office Interactable Scene", true, "Level 6", "Splits"},
			{ "Chase Scene Winkelstraat", true, "Level 7", "Splits"},
	};
	
	vars.Helper.Settings.Create(_settings);

	vars.CompletedSplits = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var g = mono["GameManager"];
		vars.Helper["loading"] = g.Make<byte>("state");
		vars.Helper["hasCompletedLevel"] = g.Make<bool>("hasCompletedLevel");
		vars.Helper["currentLevel"] = g.Make<int>("currentLevel");
		vars.Helper["lastFinishedLevel"] = g.Make<int>("lastFinishedLevel");
		return true;
	});

}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if (old.currentLevel != current.currentLevel) vars.Log("currentLevel: " + current.currentLevel);
	if (old.hasCompletedLevel != current.hasCompletedLevel) vars.Log("hasCompletedLevel: " + current.hasCompletedLevel);
	if (old.lastFinishedLevel != current.lastFinishedLevel) vars.Log("lastFinishedLevel: " + current.lastFinishedLevel);

}

onStart
{
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
}

start
{
	return old.activeScene == "Menu" && current.activeScene == "Panning Intro";
}

split
{
	if (settings["Splits"] && old.currentLevel != current.currentLevel)
	{
		vars.CompletedSplits.Add(current.activeScene);
		return settings[current.activeScene];
	}
}

onSplit
{
	print("-- SPLITTING --");
}

isLoading
{
	return current.activeScene == "Panning Intro";
	return current.loading == 1;

}