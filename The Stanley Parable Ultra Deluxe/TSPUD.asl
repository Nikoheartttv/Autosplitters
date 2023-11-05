state("The Stanley Parable Ultra Deluxe"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "The Stanley Parable: Ultra Deluxe";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertGameTime();
	
	vars.LoadingScenes = new List<string>()
	{
		"LoadingScene_UD_MASTER",
		"Menu_UD_MASTER",
	};
	
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var timingMessage = MessageBox.Show(
			"The game is run in RTA w/o Loads as the main timing method.\n"
			+ "LiveSplit is currently set to show Real Time (RTA).\n"
			+ "Would you like to set the timing method to RTA w/o Loads?",
			"LiveSplit | The Stanley Parable Ultra Deluxe", 
			MessageBoxButtons.YesNo, MessageBoxIcon.Question);
		if (timingMessage == DialogResult.Yes)
			timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}
	
init
{
	vars.Helper.TryLoad  = (Func<dynamic, bool>)(mono =>
	{
		// var ST = helper.GetClass("Assembly-CSharp", "Singleton`1");
		var GM = mono["GameMaster", 1];
		var FOC = mono["FigleyOverlayController"];
		var SC = mono["StanleyController"];

		vars.Helper["PauseMenu"] = GM.Make<bool>("PAUSEMENUACTIVE");
		vars.Helper["CollectedFigley"] = FOC.Make<int>("Instance", "count");
		vars.Helper["Movement"] = SC.Make<Vector3f>("_instance", "movementInput");
		vars.Helper["MouseMoved"] = GM.Make<int>("_instance", "MouseMoved");
	
		return true;
	});
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;

	    
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");
}

start
{
	return (current.activeScene == "map1_UD_MASTER" && ((vars.Helper["MouseMoved"].Changed) || (vars.Helper["Movement"].Changed)));
}

onStart
{
	print("\nNew run started!\n----------------\n");
}

split
{
	return ((current.activeScene == "map1_UD_MASTER" && old.activeScene == "LoadingScene_UD_MASTER") 
			|| (current.activeScene == "MemoryzonePartTwo_UD_MASTER" && old.activeScene == "LoadingScene_UD_MASTER")
			|| (current.activeScene == "MemoryzonePartThree_UD_MASTER" && old.activeScene == "LoadingScene_UD_MASTER"));
}

onSplit
{
	print("\nSplit\n-----\n");
}

isLoading
{
	if (!(vars.Helper["PauseMenu"].Current || vars.LoadingScenes.Contains(current.activeScene))) 
	{
		return false;
	}
	return true;
}

onReset
{
	print("\nRESET\n-----\n");
}
