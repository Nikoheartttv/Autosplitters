state("Butcher's Creek"){
    int EndCreditsCurrentText : "UnityPlayer.dll", 0x163E740, 0x88, 0x180, 0x1F8, 0x80, 0x80, 0x28, 0x68;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Butcher's Creek";
	vars.Helper.LoadSceneManager = true;

    dynamic[,] _settings =
	{
		{ "PassageToBarn", true, "Abandoned Trailer", null },
        { "MAP_Barn", true, "The Tunnel", null },
        { "MAP02", true, "Sawmill", null },
        { "DungeonScene", true, "Capture", null },
        { "RadioStationMap", true, "Old Mine", null },
        { "MAP_House", true, "Forest Path", null },
        { "PonyScene", true, "The Magic Fairy Castle", null },
        { "MAP04", true, "The Magic Fairy Depths", null},
        { "StripClubScene", true, "Thunderstorm", null },
        { "UnderClub1", true, "The Chapel of Exhibition", null },
        { "UnderClub2", true, "The Descent", null },
        { "End", true, "Inner Sanctum", null },
		{ "AutoReset", false, "Auto Reset upon return to Menu", null },
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
	    return settings[current.activeScene.ToString()];
	}
    if (settings["End"] && current.activeScene == "WatcherScene" && old.EndCreditsCurrentText == 0 && current.EndCreditsCurrentText != 0) 
    {
        vars.CompletedSplits.Add("End");
        return true;
    }
}

isLoading
{
    return current.loadingScene != current.activeScene;
}

reset
{
	return settings["AutoReset"] && old.activeScene != "TitleScene" && current.activeScene == "TitleScene";
}