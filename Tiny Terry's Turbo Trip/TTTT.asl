state("Tiny Terry's Turbo Trip"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Bo] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Hauntii";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "Items", true, "Items", "Splits" },
				{ "Pipe", true,	"Get Pipe", "Items" },
				{ "Shovel", true, "Get Shovel", "Items" },
				{ "BugNet", true, "Get Bug Net", "Items" },
				{ "Paraglider", true, "Get Bug Net", "Items" },
				{ "Wrench", true, "Get Wrench", "Items" },
			{ "TurboTrashcan", true, "Split on Turbo Trash Can collection", "Splits" },
			{ "Space", true, "End Split - Ride into Space", "Splits" },
	};
	
	vars.Helper.Settings.Create(_settings);

	vars.VisitedLevels = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var g = mono["TTTT", "TTTT.Global"];
		var pr = mono["TTTT", "TTTT.PlayerReferences"];
		var so = mono["TTTT", "TTTT.SOItem"];
		var sl = mono["TTTT", "TTTT.SceneLoader"];
		var ls = mono["TTTT", "TTTT.LiminalSpace"];
		vars.Helper["isTransitioning"] = g.Make<bool>("_id", "_sceneLoader", sl["isTransitioning"]);
		vars.Helper["holeTransitionRoutineBusy"] = g.Make<bool>("_id", "_sceneLoader", sl["holeTransitionRoutineBusy"]);
		vars.Helper["itemTurboJunk"] = g.Make<byte>("_id", "_playerReferences", pr["itemTurboJunk"], so["playerOwned"]);
		vars.Helper["itemMoney"] = g.Make<byte>("_id", "_playerReferences", pr["itemMoney"], so["playerOwned"]);
		vars.Helper["itemTurboUp"] = g.Make<byte>("_id", "_playerReferences", pr["itemTurboUp"], so["playerOwned"]);
		vars.Helper["itemPipe"] = g.Make<byte>("_id", "_playerReferences", pr["itemPipe"], so["playerOwned"]);
		vars.Helper["itemShovel"] = g.Make<byte>("_id", "_playerReferences", pr["itemShovel"], so["playerOwned"]);
		vars.Helper["itemBugNet"] = g.Make<byte>("_id", "_playerReferences", pr["itemBugNet"], so["playerOwned"]);
		vars.Helper["itemParaGlider"] = g.Make<byte>("_id", "_playerReferences", pr["itemParaGlider"], so["playerOwned"]);
		vars.Helper["itemWrench"] = g.Make<byte>("_id", "_playerReferences", pr["itemWrench"], so["playerOwned"]);
		vars.Helper["TurboTrashCan"] = ls.Make<bool>("active");
		return true;
	});

	current.activeScene = "";
	current.loadingScene = "";
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	
	if (old.itemTurboJunk != current.itemTurboJunk) vars.Log("Current Turbo Junk: " + current.itemTurboJunk.ToString());
	if (old.itemMoney != current.itemMoney) vars.Log("Current Money: " + current.itemMoney.ToString());

}

onStart
{
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
}

start
{
	return old.activeScene == "Title Screen" && current.activeScene == "Job Application Center";
}

split
{
	// split on collecting item
	if (settings["Pipe"] && old.itemPipe == 0 && current.itemPipe == 1)
	{
		return true;
	}
	if (settings["Shovel"] && old.itemShovel == 0 && current.itemShovel == 1)
	{
		return true;
	}
	if (settings["BugNet"] && old.itemBugNet == 0 && current.itemBugNet == 1)
	{
		return true;
	}
	if (settings["Paraglider"] && old.itemParaGlider == 0 && current.itemParaGlider == 1)
	{
		return true;
	}
	if (settings["Wrench"] && old.itemWrench == 0 && current.itemWrench == 1)
	{
		return true;
	}

	// split on finished Turbo Trash Can
	if (settings["TurboTrashcan"] && old.TurboTrashCan == true && current.TurboTrashCan == false)
	{
		return true;
	}
	// Final Split
	if (settings["Space"] && old.activeScene == "Spranklewater" && current.activeScene == "Sky Tower Ending Scene")
	{
		return true;
	}
}

isLoading
{
	return current.isTransitioning;
}