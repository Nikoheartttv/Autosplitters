state("Tiny Terry's Turbo Trip"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Tiny Terry's Turbo Trip] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Tiny Terry's Turbo Trip";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "JobGet", true, "Get Job", "Splits" },
			{ "Items", true, "Items", "Splits" },
				{ "Pipe", true,	"Get Pipe", "Items" },
				{ "Shovel", true, "Get Shovel", "Items" },
				{ "BugNet", true, "Get Bug Net", "Items" },
				{ "Paraglider", true, "Get Bug Net", "Items" },
				{ "Wrench", true, "Get Wrench", "Items" },
			{ "TurboTrashcan", true, "Turbo Trash Cans", "Splits" },
				{ "jatkleuter", true, "Jatkleuter Trashcan", "TurboTrashcan" },
				{ "snekfret", true, "Snekfret Trashcan", "TurboTrashcan" },
				{ "pert", true, "Pert Trashcan", "TurboTrashcan" },
				{ "yoga", true, "Yoga Trashcan", "TurboTrashcan" },
				{ "soccer", true, "Soccer Trashcan", "TurboTrashcan" },
				{ "steelkees", true, "Steelkees Trashcan", "TurboTrashcan" },
				{ "griatta", true, "Griatta Trashcan", "TurboTrashcan" },
				{ "spepely", true, "Spepely Trashcan", "TurboTrashcan" },
				{ "olger", true, "Olger Trashcan", "TurboTrashcan" },
			{ "Space", true, "End Split - Ride into Space", "Splits" },
	};
	
	vars.Helper.Settings.Create(_settings);

	vars.VariableInstanceCache = new Dictionary<string, int>();
	vars.ReadVariableInstance = (Func<string, bool>)(key =>
	{
		int i;

        if (vars.VariableInstanceCache.TryGetValue(key, out i))
        {
            if  (i < vars.Helper["variableInstances"].Current.Count && 
                vars.Helper.ReadString(vars.Helper["variableInstances"].Current[i] + 0x18, 0x10) == key)
            {
                return vars.Helper.Read<bool>(vars.Helper["variableInstances"].Current[i] + 0x20);
            }
		}
			
        // Time to do it the hard way
        vars.VariableInstanceCache.Remove(key);
        for (i = 0; i < vars.Helper["variableInstances"].Current.Count; i++)
        {
            if (key == vars.Helper.ReadString(vars.Helper["variableInstances"].Current[i] + 0x18, 0x10))
            {
                vars.VariableInstanceCache.Add(key, i);
                return vars.Helper.Read<bool>(vars.Helper["variableInstances"].Current[i] + 0x20);
            }
        }

        throw new Exception("ReadIntVariable: Variable not found!");
	});
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
		var gp = mono["TTTT", "TTTT.GameProgress"];
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
        vars.Helper["variableInstances"] = g.MakeList<IntPtr>("_id", "gameProgress", gp["copyOfAllVariableInstancesInTheGame"]);

		// vars.Helper["TurboTrashCan"] = ls.Make<bool>("active");
		return true;
	});

	current.activeScene = "";
	current.loadingScene = "";
	current.TTC_jatkleuter = false;
	current.TTC_snekfret = false;
	current.TTC_pert = false;
	current.TTC_yoga = false;
	current.TTC_soccer = false;
	current.TTC_steelkees = false;
	current.TTC_griatta = false;
	current.TTC_spepely = false;
	current.TTC_olger = false;
	current.itemWrench = 0;
	current.itemPipe = 0;
	current.itemTurboJunk = 0;
	current.itemTurboUp = 0;
	current.itemShovel = 0;
	current.itemBugNet = 0;
	current.itemParaGlider = 0;
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");

	current.TTC_jatkleuter = vars.ReadVariableInstance("$TTC_jatkleuter");
	current.TTC_snekfret = vars.ReadVariableInstance("$TTC_snekfret");
	current.TTC_pert = vars.ReadVariableInstance("$TTC_pert");
	current.TTC_yoga = vars.ReadVariableInstance("$TTC_yoga");
	current.TTC_soccer = vars.ReadVariableInstance("$TTC_soccer");
	current.TTC_steelkees = vars.ReadVariableInstance("$TTC_steelkees");
	current.TTC_griatta = vars.ReadVariableInstance("$TTC_griatta");
	current.TTC_spepely = vars.ReadVariableInstance("$TTC_spepely");
	current.TTC_olger = vars.ReadVariableInstance("$TTC_olger");

	if (old.TTC_jatkleuter != current.TTC_jatkleuter)
	{
		print("TTC_jatkleuter changed from " + old.TTC_jatkleuter.ToString() + " to " + current.TTC_jatkleuter.ToString());
	}
	if (old.TTC_snekfret != current.TTC_snekfret)
	{
		print("TTC_snekfret changed from " + old.TTC_snekfret.ToString() + " to " + current.TTC_snekfret.ToString());
	}
	if (old.TTC_pert != current.TTC_pert)
	{
		print("TTC_pertr changed from " + old.TTC_pert.ToString() + " to " + current.TTC_pert.ToString());
	}
	if (old.TTC_yoga != current.TTC_yoga)
	{
		print("TTC_yoga changed from " + old.TTC_yoga.ToString() + " to " + current.TTC_yoga.ToString());
	}
	if (old.TTC_soccer != current.TTC_soccer)
	{
		print("TTC_soccer changed from " + old.TTC_soccer.ToString() + " to " + current.TTC_soccer.ToString());
	}
	if (old.TTC_steelkees != current.TTC_steelkees)
	{
		print("TTC_steelkees changed from " + old.TTC_steelkees.ToString() + " to " + current.TTC_steelkees.ToString());
	}
	if (old.TTC_griatta != current.TTC_griatta)
	{
		print("TTC_griatta changed from " + old.TTC_griatta.ToString() + " to " + current.TTC_griatta.ToString());
	}
	if (old.TTC_spepely != current.TTC_spepely)
	{
		print("TTC_spepely changed from " + old.TTC_spepely.ToString() + " to " + current.TTC_spepely.ToString());
	}
	if (old.TTC_olger != current.TTC_olger)
	{
		print("TTC_olger changed from " + old.TTC_olger.ToString() + " to " + current.TTC_olger.ToString());
	}

	// if (old.itemTurboJunk != current.itemTurboJunk) vars.Log("Current Turbo Junk: " + current.itemTurboJunk.ToString());
	// if (old.itemMoney != current.itemMoney) vars.Log("Current Money: " + current.itemMoney.ToString());
	// if (old.gameProgressItemList != current.gameProgressItemList) vars.Log(current.gameProgressItemList.ToString());

}

onStart
{
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
	current.TTC_jatkleuter = false;
	current.TTC_snekfret = false;
	current.TTC_pert = false;
	current.TTC_yoga = false;
	current.TTC_soccer = false;
	current.TTC_steelkees = false;
	current.TTC_griatta = false;
	current.TTC_spepely = false;
	current.TTC_olger = false;
}

start
{
	return old.activeScene == "Title Screen" && current.activeScene == "Job Application Center";
}

split
{
	// Split after leaving Job centre
	if (settings["JobGet"] && old.activeScene == "Job Application Center" && current.activeScene == "Sprankelwater") return true;
	// split on collecting item
	if (settings["Pipe"] && old.itemPipe == 0 && current.itemPipe == 1) return true;
	if (settings["Shovel"] && old.itemShovel == 0 && current.itemShovel == 1) return true;
	if (settings["BugNet"] && old.itemBugNet == 0 && current.itemBugNet == 1) return true;
	if (settings["Paraglider"] && old.itemParaGlider == 0 && current.itemParaGlider == 1) return true;
	if (settings["Wrench"] && old.itemWrench == 0 && current.itemWrench == 1) return true;

	// Final Split
	if (settings["Space"] && old.activeScene == "Sprankelwater" && current.activeScene == "Sky Tower Ending Scene")	return true;

	// Turbo Trash Can Splits
	if (settings["jatkleuter"] && !old.TTC_jatkleuter && current.TTC_jatkleuter) return true;
	if (settings["snekfret"] && !old.TTC_snekfret && current.TTC_snekfret) return true;
	if (settings["pert"] && !old.TTC_pert && current.TTC_pert) return true;
	if (settings["yoga"] && !old.TTC_yoga && current.TTC_yoga) return true;
	if (settings["soccer"] && !old.TTC_soccer && current.TTC_soccer) return true;
	if (settings["steelkees"] && !old.TTC_steelkees && current.TTC_steelkees) return true;
	if (settings["griatta"] && !old.TTC_griatta && current.TTC_griatta) return true;
	if (settings["spepely"] && !old.TTC_spepely && current.TTC_spepely) return true;
	if (settings["olger"] && !old.TTC_olger && current.TTC_olger) return true;
}

onSplit
{
	print("-- SPLITTING --");
}

isLoading
{
	return current.isTransitioning;
}