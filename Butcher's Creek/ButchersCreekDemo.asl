state("Butcher's Creek"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Butcher's Creek [Demo]";
	vars.Helper.LoadSceneManager = true;

    dynamic[,] _settings =
	{
		{ "PassageToBarn", true, "Passage To Barn", null },
        { "MAP_Barn", true, "Exit Barn", null },
        { "MAP02_Demo", true, "In Cage", null },
        { "DemoEndScene", true, "Demo End", null },
    };

    vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.CompletedSplits = new List<string>();
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;

	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");
}

onStart
{
    vars.CompletedSplits.Clear();
}

start
{
	return old.activeScene == "OpeningTextScene" && current.activeScene == "MAP01";
}

split
{
    if (old.activeScene != current.activeScene && !vars.CompletedSplits.Contains(current.activeScene.ToString()))
    {
	    vars.CompletedSplits.Add(current.activeScene);
	    return true;
	}
}

isLoading
{
    return current.loadingScene != current.activeScene;
}