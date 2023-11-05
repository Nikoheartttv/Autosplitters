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
}

init
{
	vars.Helper.TryLoad  = (Func<dynamic, bool>)(mono =>
	{
		var GM = mono["GameMaster", 1];
		vars.Helper["PauseMenu"] = GM.Make<bool>("PAUSEMENUACTIVE");	
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

isLoading
{
	if (!(vars.Helper["PauseMenu"].Current || vars.LoadingScenes.Contains(current.activeScene))) 
	{
		return false;
	}
	return true;
}

exit
{
	timer.IsGameTimePaused = true;
}