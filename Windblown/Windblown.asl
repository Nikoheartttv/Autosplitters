state("Windblown"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Windblown] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Windblown";
	vars.Helper.LoadSceneManager = true;

	// dynamic[,] _settings =
	// {
	// 	{ "Splits", true, "Splits", null },
	// 		{ "JobGet", true, "Get Job", "Splits" },
	// 		{ "Items", true, "Items", "Splits" },
	// 			{ "Pipe", true,	"Get Pipe", "Items" },
	// 			{ "Shovel", true, "Get Shovel", "Items" },
	// 			{ "BugNet", true, "Get Bug Net", "Items" },
	// 			{ "Paraglider", true, "Get Bug Net", "Items" },
	// 			{ "Wrench", true, "Get Wrench", "Items" },
	// 		{ "TurboTrashcan", true, "Turbo Trash Cans", "Splits" },
	// 			{ "ttc_jatkleuter", true, "Jatkleuter Trashcan", "TurboTrashcan" },
	// 			{ "ttc_snekfret", true, "Snekfret Trashcan", "TurboTrashcan" },
	// 			{ "ttc_pert", true, "Pert Trashcan", "TurboTrashcan" },
	// 			{ "ttc_yoga", true, "Yoga Trashcan", "TurboTrashcan" },
	// 			{ "ttc_soccer", true, "Soccer Trashcan", "TurboTrashcan" },
	// 			{ "ttc_steelkees", true, "Steelkees Trashcan", "TurboTrashcan" },
	// 			{ "ttc_griatta", true, "Griatta Trashcan", "TurboTrashcan" },
	// 			{ "ttc_spepely", true, "Spepely Trashcan", "TurboTrashcan" },
	// 			{ "ttc_olger", true, "Olger Trashcan", "TurboTrashcan" },
	// 		{ "Space", true, "End Split - Ride into Space", "Splits" },
	// };
	
	// vars.Helper.Settings.Create(_settings);

	vars.CompletedSplits = new HashSet<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var g = mono["Bosco", "GameManager"];
		// var pr = mono["TTTT", "TTTT.PlayerReferences"];
		// var so = mono["TTTT", "TTTT.SOItem"];
		// var sl = mono["TTTT", "TTTT.SceneLoader"];
		// var ls = mono["TTTT", "TTTT.LiminalSpace"];
		// var gp = mono["TTTT", "TTTT.GameProgress"];
		// vars.Helper["isNewRunStarting"] = g.Make<bool>("Instance", "_isNewRunStarting");
		// vars.Helper["holeTransitionRoutineBusy"] = g.Make<bool>("_id", "_sceneLoader", sl["holeTransitionRoutineBusy"]);
		// vars.Helper["itemTurboJunk"] = g.Make<byte>("_id", "_playerReferences", pr["itemTurboJunk"], so["playerOwned"]);
		// vars.Helper["itemMoney"] = g.Make<byte>("_id", "_playerReferences", pr["itemMoney"], so["playerOwned"]);
		// vars.Helper["itemTurboUp"] = g.Make<byte>("_id", "_playerReferences", pr["itemTurboUp"], so["playerOwned"]);
		// vars.Helper["itemPipe"] = g.Make<byte>("_id", "_playerReferences", pr["itemPipe"], so["playerOwned"]);
		// vars.Helper["itemShovel"] = g.Make<byte>("_id", "_playerReferences", pr["itemShovel"], so["playerOwned"]);
		// vars.Helper["itemBugNet"] = g.Make<byte>("_id", "_playerReferences", pr["itemBugNet"], so["playerOwned"]);
		// vars.Helper["itemParaGlider"] = g.Make<byte>("_id", "_playerReferences", pr["itemParaGlider"], so["playerOwned"]);
		// vars.Helper["itemWrench"] = g.Make<byte>("_id", "_playerReferences", pr["itemWrench"], so["playerOwned"]);
        // vars.Helper["variableInstances"] = g.MakeList<IntPtr>("_id", "gameProgress", gp["copyOfAllVariableInstancesInTheGame"]);

		// vars.Helper["TurboTrashCan"] = ls.Make<bool>("active");
		return true;
	});

	current.activeScene = "";
	current.loadingScene = "";

}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;

	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");

	if (old.isNewRunStarting != current.isNewRunStarting) vars.Log("isNewRunStarting: " + current.isNewRunStarting);
	// if (old.itemMoney != current.itemMoney) vars.Log("Current Money: " + current.itemMoney.ToString());
	// if (old.gameProgressItemList != current.gameProgressItemList) vars.Log(current.gameProgressItemList.ToString());

}

onStart
{
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
}

start
{
	return old.activeScene == "Title Screen" && current.activeScene == "Job Application Center";
}

split
{
	// Split after leaving Job centre
}

onSplit
{
	print("-- SPLITTING --");
}

isLoading
{
	// return current.isTransitioning;
}