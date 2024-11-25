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
			{ "Artifacts", false, "All 16 Artifacts Collected", "Splits" },
			{ "Critters", false, "All 26 Critters Crushed", "Splits" },
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
		vars.Helper["isMainMenu"] = mono.Make<bool>("GameManager", "inst", "isMainMenu");
        vars.Helper["changingLevel"] = mono.Make<bool>("GameManager", "inst", "changingLevel");
        vars.Helper["loading"] = mono.Make<bool>("AddressablesManager", "loadingScene");
		vars.Helper["complete"] = mono.Make<bool>("StatsManager", "inst", "sceneStats", "complete");
		vars.Helper["artifactsCollected"] = mono.Make<int>("StatsManager", "inst", "sceneStats", "artifactsCollected");
		vars.Helper["crittersCrushed"] = mono.Make<int>("StatsManager", "inst", "sceneStats", "crittersCrushed");
		return true;
	});

	vars.DayAnnounce = false;
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
	if (settings["Artifacts"] && current.artifactsCollected == 16 && !vars.CompletedSplits.Contains("Artifacts"))
	{
		vars.CompletedSplits.Add("Artifacts");
		return true;
	}
	if (settings["Critters"] && current.crittersCrushed == 26 && !vars.CompletedSplits.Contains("Critters"))
	{
		vars.CompletedSplits.Add("Critters");
		return true;
	}

}

isLoading
{
	if (current.loadingScene != "End_Credits")
	{
		return current.changingLevel || current.loading || current.complete
		|| current.activeScene == "D1_Announce" || current.activeScene == "D2_Announce" || current.activeScene == "D3_Announce" || current.activeScene == "D4_Announce" || current.activeScene == "DX_Announce"
		|| current.loadingScene == "D1_Announce" || current.loadingScene == "D2_Announce" || current.loadingScene == "D3_Announce" || current.loadingScene == "D4_Announce" || current.loadingScene == "DX_Announce";
	}
	else if (current.loadingScene == "End_Credits") return true;
}

reset
{
	return settings["AutoReset"] && old.isMainMenu == false && current.isMainMenu == true;
}