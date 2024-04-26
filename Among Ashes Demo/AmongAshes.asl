state("Among Ashes") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Lone Ruin";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var gsm = mono["GameStateManager"];
		var mm = mono["MainMenu"];
		var dm = mono["DataManager"];
        // var ui = mono["UIManager"];

		vars.Helper["mainStoryEvent"] = gsm.Make<int>("instance", "currentMainStoryEvent");
		vars.Helper["runningStoryEvent"] = gsm.Make<bool>("instance", "runningStoryEvent");
		vars.Helper["gameStarted"] = mm.Make<bool>("instance", "gameStarted");
		vars.Helper["amongAshesGameTime"] = dm.Make<int>("instance", "amongAshesGameTime");
        // vars.Helper["fadingToBlack"] = ui.Make<float>("instance", "fadingToBlack");
        

		return true;
	});

	vars.Scene = "";
}

update
{
    current.Scene = vars.Helper.Scenes.Active.Name;
	if (old.Scene != current.Scene) print("Scene Change: " + current.Scene);
    if (old.mainStoryEvent != current.mainStoryEvent) print("mainStoryEvent: " + current.mainStoryEvent);
    if (old.runningStoryEvent != current.runningStoryEvent) print("runningStoryEvent: " + current.runningStoryEvent);
    if (old.gameStarted != current.gameStarted) print("gameStarted: " + current.gameStarted);
    if (old.amongAshesGameTime != current.amongAshesGameTime) print("amongAshesGameTime: " + current.amongAshesGameTime);
    // if (old.fadingToBlack != current.fadingToBlack) print("fadingToBlack: " + current.fadingToBlack);

}