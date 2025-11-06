state("Sorry We're Closed"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Sorry We're Closed] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Sorry We're Closed";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "NewGamePlus", false, "New Game Plus Start - from Phone Booth", null },
		{ "Splits", true, "Splits", null },
	 		{ "D1Combat_Station_Boss", true, "Day 1 - Jenny", "Splits" },
	 		{ "D2Combat_Aquarium_Boss", true, "Day 2 - Matilda", "Splits" },
	 		{ "D3Combat_Crypt", true, "Day 3 - Gabriele", "Splits" },
	 		{ "D3Combat_Palace_Boss", true, "Day 3 - Dream Eater", "Splits" },
	 		{ "D4Combat_Hotel_Boss_Outro", false, "Day 4? - The Duchess", "Splits" },
			{ "End_Credits", true, "Day X - Go To Work", "Splits" },
			{ "Artifacts", false, "On Artifact Collected (16 Splits)", "Splits" },
				{ "Artifacts1", true, "Artifact 1", "Artifacts" },
				{ "Artifacts2", true, "Artifact 2", "Artifacts" },
				{ "Artifacts3", true, "Artifact 3", "Artifacts" },
				{ "Artifacts4", true, "Artifact 4", "Artifacts" },
				{ "Artifacts5", true, "Artifact 5", "Artifacts" },
				{ "Artifacts6", true, "Artifact 6", "Artifacts" },
				{ "Artifacts7", true, "Artifact 7", "Artifacts" },
				{ "Artifacts8", true, "Artifact 8", "Artifacts" },
				{ "Artifacts9", true, "Artifact 9", "Artifacts" },
				{ "Artifacts10", true, "Artifact 10", "Artifacts" },
				{ "Artifacts11", true, "Artifact 11", "Artifacts" },
				{ "Artifacts12", true, "Artifact 12", "Artifacts" },
				{ "Artifacts13", true, "Artifact 13", "Artifacts" },
				{ "Artifacts14", true, "Artifact 14", "Artifacts" },
				{ "Artifacts15", true, "Artifact 15", "Artifacts" },
				{ "Artifacts16", true, "Artifact 16", "Artifacts" },
			{ "Critters", false, "On Critter Crushed (26 Splits)", "Splits" },
				{ "Critters1", true, "Critter 1", "Critters" },
				{ "Critters2", true, "Critter 2", "Critters" },
				{ "Critters3", true, "Critter 3", "Critters" },
				{ "Critters4", true, "Critter 4", "Critters" },
				{ "Critters5", true, "Critter 5", "Critters" },
				{ "Critters6", true, "Critter 6", "Critters" },
				{ "Critters7", true, "Critter 7", "Critters" },
				{ "Critters8", true, "Critter 8", "Critters" },
				{ "Critters9", true, "Critter 9", "Critters" },
				{ "Critters10", true, "Critter 10", "Critters" },
				{ "Critters11", true, "Critter 11", "Critters" },
				{ "Critters12", true, "Critter 12", "Critters" },
				{ "Critters13", true, "Critter 13", "Critters" },
				{ "Critters14", true, "Critter 14", "Critters" },
				{ "Critters15", true, "Critter 15", "Critters" },
				{ "Critters16", true, "Critter 16", "Critters" },
				{ "Critters17", true, "Critter 17", "Critters" },
				{ "Critters18", true, "Critter 18", "Critters" },
				{ "Critters19", true, "Critter 19", "Critters" },
				{ "Critters20", true, "Critter 20", "Critters" },
				{ "Critters21", true, "Critter 21", "Critters" },
				{ "Critters22", true, "Critter 22", "Critters" },
				{ "Critters23", true, "Critter 23", "Critters" },
				{ "Critters24", true, "Critter 24", "Critters" },
				{ "Critters25", true, "Critter 25", "Critters" },
				{ "Critters26", true, "Critter 26", "Critters" },
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
		vars.Helper["artifactsCollectedTown"] = mono.Make<int>("StatsManager", "inst", "stats", "town", "artifactsCollected");
		vars.Helper["artifactsCollectedStation"] = mono.Make<int>("StatsManager", "inst", "stats", "station", "artifactsCollected");
		vars.Helper["artifactsCollectedAquarium"] = mono.Make<int>("StatsManager", "inst", "stats", "aquarium", "artifactsCollected");
		vars.Helper["artifactsCollectedCrypt"] = mono.Make<int>("StatsManager", "inst", "stats", "crypt", "artifactsCollected");
		vars.Helper["artifactsCollectedPalace"] = mono.Make<int>("StatsManager", "inst", "stats", "palace", "artifactsCollected");
		vars.Helper["artifactsCollectedHotel"] = mono.Make<int>("StatsManager", "inst", "stats", "hotel", "artifactsCollected");
		vars.Helper["crittersCrushedTown"] = mono.Make<int>("StatsManager", "inst", "stats", "town", "crittersCrushed");
		vars.Helper["crittersCrushedStation"] = mono.Make<int>("StatsManager", "inst", "stats", "station", "crittersCrushed");
		vars.Helper["crittersCrushedAquarium"] = mono.Make<int>("StatsManager", "inst", "stats", "aquarium", "crittersCrushed");
		vars.Helper["crittersCrushedCrypt"] = mono.Make<int>("StatsManager", "inst", "stats", "crypt", "crittersCrushed");
		vars.Helper["crittersCrushedPalace"] = mono.Make<int>("StatsManager", "inst", "stats", "palace", "crittersCrushed");
		vars.Helper["crittersCrushedHotel"] = mono.Make<int>("StatsManager", "inst", "stats", "hotel", "crittersCrushed");

		return true;
	});

	vars.DayAnnounce = false;
	current.artifacts = 0;
	current.critters = 0;
}

start
{
if (settings["NewGamePlus"])
    {return old.activeScene == "_Main_Menu" && current.activeScene == "D0_Town";
    } else
    {return old.activeScene == "_Welcome" && current.activeScene == "D0_Michelle_Store";
    }
}

onStart
{
	vars.CompletedSplits.Clear();
	current.artifacts = 0;
	current.critters = 0;
}

update
{
	{
		var sum = current.artifactsCollectedTown + current.artifactsCollectedStation + current.artifactsCollectedAquarium + current.artifactsCollectedCrypt + current.artifactsCollectedPalace + current.artifactsCollectedHotel;
		if (sum > current.artifacts) current.artifacts = sum;
	}
	{
		var sum1 = current.crittersCrushedTown + current.crittersCrushedStation + current.crittersCrushedAquarium + current.crittersCrushedCrypt + current.crittersCrushedPalace + current.crittersCrushedHotel;
		if (sum1 > current.critters) current.critters = sum1;
	}

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
	if (old.artifacts < current.artifacts)
	{
		if (settings["Artifacts"] && settings["Artifacts" + current.artifacts.ToString()] && !vars.CompletedSplits.Contains("Artifacts" + current.artifacts.ToString()))
		{
			vars.CompletedSplits.Add("Artifacts" + current.artifacts.ToString());
			vars.Log("Artifact " + current.artifacts + " collected!");
			return true;
		}
	}
	if (old.critters < current.critters)
	{
		if (settings["Critters"] && settings["Critters" + current.critters.ToString()] && !vars.CompletedSplits.Contains("Critters" + current.critters.ToString()))
		{
			vars.CompletedSplits.Add("Critters" + current.critters.ToString());
			vars.Log("Critter " + current.critters + " crushed!");
			return true;
		}
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
