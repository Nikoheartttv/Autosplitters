state("VampireSurvivors"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
    vars.Uhara.EnableDebug();
	vars.Helper.GameName = "Vampire Survivors";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
}

init
{
	var Instance = vars.Uhara.CreateTool("Unity", "Il2Cpp", "Instance");
	Instance.SetDefaultNames("VampireSurvivors.Runtime", "VampireSurvivors.Framework");
	var IGM = Instance.Get("GameManager", "_isGameRunning");
	// var GM = Instance.Get("VampireSurvivors.Runtime:VampireSurvivors.Framework:GameManager", "_isGameRunning");
	vars.Helper["isGameRunning"] = vars.Helper.Make<bool>(IGM.Base, IGM.Offsets);
	vars.Helper["isGameRunning"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

	current.isGameRunning = false;
}

onStart
{
	timer.IsGameTimePaused = true;
}

start
{
	// return current.activeScene == "Gameplay" && old.isGameRunning == false && current.isGameRunning == true;
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();

    if (old.isGameRunning != current.isGameRunning) vars.Log("isGameRunning: " + current.isGameRunning);

	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;

	// if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	// if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");

	// if (old.runCoins != current.runCoins)
	// {
	// 	vars.GoldInLevel = Math.Round(current.runCoins, 0);
	// 	vars.Log("Gold In Level: " + vars.GoldInLevel);
	// }

	// vars.Log(vars.Helper.Scenes.Loaded.Count);

	
	// vars.Log(current.UnlockedCharacters.Count.ToString());

	// var len = vars.Helper.Read<int>(current.Items[current.Items.Count - 1] + 0x10);
	// var name = vars.Helper.ReadString(len * 2, ReadStringType.UTF16, current.Items[current.Items.Count - 1] + 0x14);
	// vars.Log(name);
}





isLoading
{
	return current.activeScene == "MainMenu" || current.loadingScene == "ScenePreloader" || current.isPaused || current.activeScene == "Gameplay" && current.isGameRunning == 0;
}