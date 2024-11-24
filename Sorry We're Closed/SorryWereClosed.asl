state("Sorry We're Closed"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Sorry We're Closed] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Sorry We're Closed";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
	 		{ "D1Combat_Station_Boss", true, "Day 1 - Jenny", "Splits" },
	 		{ "D2Combat_Aquarium_Boss", true, "Day 2 - Matilda", "Splits" },
	 		{ "D3Combat_Crypt", true, "Day 3 - Gabriele", "Splits" },
	 		{ "D3Combat_Palace_Boss", true, "Day 3 - Dream Eater", "Splits" },
	 		{ "D4Combat_Hotel_Boss_Outro", false, "Day 4? - The Duchess", "Splits" },
			{ "End_Credits", true, "Day X - Go To Work", "Splits" },
	 	{ "AutoReset", false, "Auto Reset when return to Main Menu", null },
	};

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.CompletedSplits = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var GM = mono["GameManager"];
        var AD = mono["AddressablesManager"];	
		vars.Helper["isMainMenu"] = GM.Make<bool>("inst", "isMainMenu");
        vars.Helper["changingLevel"] = GM.Make<bool>("inst","changingLevel");
        vars.Helper["loading"] = AD.Make<bool>("loadingScene");
		vars.Helper["complete"] = mono.Make<bool>("StatsManager", "inst", "sceneStats", "complete");
		return true;
	});
}

start
{
	return old.activeScene == "_Welcome" && current.activeScene == "D0_Michelle_Store";
}

onStart
{
	vars.CompletedSplits.Clear();
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name == null ? current.loadingScene : vars.Helper.Scenes.Loaded[0].Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");
}

split
{
	if (current.activeScene != "End_Credits" && current.complete && !vars.CompletedSplits.Contains(current.activeScene.ToString()))
	{
		vars.CompletedSplits.Add(current.activeScene.ToString());
		return settings[current.activeScene.ToString()];
	}
	if (old.activeScene == "DX_Town" && current.activeScene == "End_Credits")
	{
		vars.CompletedSplits.Add(current.activeScene.ToString());
		return settings[current.activeScene.ToString()];
	}
}

isLoading
{
	if (current.loadingScene != "End_Credits")
	{
		return current.changingLevel || current.loading || current.complete
		|| current.activeScene == "D1_Announce" || current.activeScene == "D2_Announce" || current.activeScene == "D3_Announce" || current.activeScene == "D4_Announce" || current.activeScene == "DX_Announce";
	}
	else if (current.loadingScene == "End_Credits") return true;
}

reset
{
	return settings["AutoReset"] && old.isMainMenu == false && current.isMainMenu == true;
}