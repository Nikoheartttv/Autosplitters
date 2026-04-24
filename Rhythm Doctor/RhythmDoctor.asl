state("Rhythm Doctor") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.Settings.CreateFromXml("Components/RhythmDoctor.Settings.xml");
	vars.Uhara.AlertLoadless();

	vars.bossLevels = new List<string>() 
	{ 
		"OrientalInsomniac", "InsomniacHard", "Boss2", "Bitterness", 
		"Lesmis", "AthleteFinale", "PaigesReckoning", "Montage2"
	};
	vars.noCompletionLevels = new List<string>(){ "Intro", "EdegaRave", "Montage" };
	vars.rank = new dynamic[,]
	{
		{ 0, -10, "Fminus" }, { 1, 0, "F" }, { 2, 10, "Fplus" },
		{ 3, -11, "Dminus" }, { 4, 1, "D" }, { 5, 11, "Dplus" },
		{ 6, -12, "Cminus" }, { 7, 2, "C" }, { 8, 12, "Cplus" },
		{ 9, -13, "Bminus" }, { 10, 3, "B" }, { 11, 13, "Bplus" },
		{ 12, -14, "Aminus" }, { 13, 4, "A" }, { 14, 14, "Aplus" },
		{ 15, -15, "Sminus" }, { 16, 5, "S" }, { 17, 15, "Splus" }
	};
	vars.GetLocalRank = new Func<int, int>(rank => 
	{
		for (var i = 0; i < vars.rank.GetLength(0); i++)
			if (vars.rank[i, 1] == rank) return vars.rank[i, 0];
		return 0;
	});
	vars.VisitedLevel = new List<string>();
	vars.levelCompleted = false;
}

init
{
	vars.Utils = vars.Uhara.CreateTool("Unity", "Utils");
	vars.Instance = vars.Uhara.CreateTool("Unity", "DotNet", "Instance");
	
	vars.Version = null;
	vars.Instance.Watch<byte>("releaseNumber", "Releases", "releaseNumber");

	vars.Uhara.Update();

	if (current.releaseNumber == null) return false;
	var releaseToVersion = new Dictionary<int, string>()
	{
		{ 16, "v0.10.1" }, { 25, "v0.11.5" }, { 26, "v0.11.6" },
		{ 27, "v0.12.0" }, { 28, "v0.13.0" }, { 29, "v0.13.1" },
		{ 30, "v0.14.0" }, { 31, "v0.15.0" }, { 32, "v0.15.1" },
		{ 33, "v0.16.0" }, { 34, "v0.16.1" }, { 35, "v0.17.0" },
		{ 39, "v0.18.1" }, { 40, "v0.19.0" }, { 41, "v1.0.0" }, { 42, "v1.0.1+" }
	};
	vars.Version = releaseToVersion.ContainsKey(current.releaseNumber) ? releaseToVersion[current.releaseNumber] : "v1.0.1+";
	vars.Uhara.Log("Release Number: " + current.releaseNumber + " -> version " + vars.Version);

	switch((string)vars.Version)
	{
		case "v1.0.1+": case "v1.0.0":
		{
			string[] path0 = vars.Instance.GetPathString("scnGame", "failedLevel");
			vars.Instance.Watch<int>("failedLevel", "scnBase", "_instance", path0[0]);
			string[] path1 = vars.Instance.GetPathString("scnGame", "mistakesManager", "mistakesCountP1");
			vars.Instance.Watch<int>("mistakesCountP1", "scnBase", "_instance", path1[0], path1[0]);
			vars.Instance.Watch<bool>("inGame", "SpeedrunValues", "inGame");
			vars.Instance.Watch<bool>("isLoading", "SpeedrunValues", "isLoading");
			var currentLevel = vars.Instance.Get("SpeedrunValues", "currentLevel", "0x14");
			vars.Resolver.WatchString("Level", currentLevel.Base, currentLevel.Offsets);
			vars.Instance.Watch<int>("rank", "SpeedrunValues", "rank");
			var levelPath = vars.Instance.Get("scnGame", "currentLevelPath", "0x14");
			vars.Resolver.WatchString("currentLevelPath", levelPath.Base, levelPath.Offsets);
			vars.Uhara["currentLevelPath"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
			vars.Instance.Watch<int>("GameState", "SpeedrunValues", "currentGameState");
			vars.Instance.Watch<bool>("attemptToLoadTutorial", "scnGame", "attemptToLoadTutorial");
			string[] path2 = vars.Instance.GetPathString("scnGame", "rankscreen", "trueGameover");
			vars.Instance.Watch<int>("trueGameover", "scnBase", "_instance", path2[0], path2[1]);
			vars.Uhara["trueGameover"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
			vars.Uhara.Log("Using v1.0.x pointers");
		}
		break;
		
		case "v0.19.0": case "v0.18.1": 
		{
			string[] path0 = vars.Instance.GetPathString("scnGame", "failedLevel");
			vars.Instance.Watch<int>("failedLevel", "scnBase", "_instance", path0[0]);
			string[] path1 = vars.Instance.GetPathString("scnGame", "mistakesManager", "mistakesCountP1");
			vars.Instance.Watch<int>("mistakesCountP1", "scnBase", "_instance", path1[0], path1[0]);
			vars.Instance.Watch<bool>("inGame", "SpeedrunValues", "inGame");
			vars.Instance.Watch<bool>("isLoading", "SpeedrunValues", "isLoading");
			var currentLevel = vars.Instance.Get("SpeedrunValues", "currentLevel", "0x14");
			vars.Resolver.WatchString("Level", currentLevel.Base, currentLevel.Offsets);
			vars.Instance.Watch<int>("rank", "SpeedrunValues", "rank");
			var levelPath = vars.Instance.Get("scnGame", "currentLevelPath", "0x14");
			vars.Resolver.WatchString("currentLevelPath", levelPath.Base, levelPath.Offsets);
			vars.Uhara["currentLevelPath"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
			vars.Instance.Watch<int>("GameState", "SpeedrunValues", "currentGameState");
			vars.Instance.Watch<bool>("attemptToLoadTutorial", "scnGame", "attemptToLoadTutorial");
			string[] path2 = vars.Instance.GetPathString("scnGame", "hud", "trueGameover");
			vars.Instance.Watch<int>("trueGameover", "scnBase", "_instance", path2[0], path2[1]);
			vars.Uhara["trueGameover"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
			vars.Uhara.Log("Using v0.18-0.19 pointers");
		}
		break;

		case "v0.17.0": case "v0.16.1": case "v0.16.0": case "v0.15.1": 
		case "v0.15.0": case "v0.14.0": case "v0.13.1": case "v0.13.0": case "v0.12.0":
		{
			string[] path0 = vars.Instance.GetPathString("scnGame", "failedLevel");
			vars.Instance.Watch<int>("failedLevel", "scnBase", "_instance", path0[0]);
			string[] path1 = vars.Instance.GetPathString("scnGame", "mistakesManager", "mistakesCountP1");
			vars.Instance.Watch<int>("mistakesCountP1", "scnBase", "_instance", path1[0], path1[0]);
			vars.Instance.Watch<bool>("inGame", "SpeedrunValues", "inGame");
			vars.Instance.Watch<bool>("isLoading", "SpeedrunValues", "isLoading");
			var currentLevel = vars.Instance.Get("SpeedrunValues", "currentLevel", "0x14");
			vars.Resolver.WatchString("Level", currentLevel.Base, currentLevel.Offsets);
			vars.Instance.Watch<int>("rank", "SpeedrunValues", "rank");
			var levelPath = vars.Instance.Get("scnGame", "currentLevelPath", "0x14");
			vars.Resolver.WatchString("currentLevelPath", levelPath.Base, levelPath.Offsets);
			vars.Uhara["currentLevelPath"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
			vars.Instance.Watch<int>("GameState", "SpeedrunValues", "currentGameState");
			vars.Instance.Watch<bool>("attemptToLoadTutorial", "scnGame", "attemptToLoadTutorial");
			string[] path2 = vars.Instance.GetPathString("scnGame", "hud", "trueGameover");
			vars.Instance.Watch<int>("trueGameover", "scnBase", "_instance", path2[0], path2[1]);
			vars.Uhara["trueGameover"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
			vars.Uhara.Log("Using v0.16-0.17 pointers");
		}
		break;

		case "v0.11.6": case "v0.11.5": case "v0.10.1":
		{
			string[] path0 = vars.Instance.GetPathString("scnGame", "failedLevel");
			vars.Instance.Watch<int>("failedLevel", "scnBase", "_instance", path0[0]);
			string[] path1 = vars.Instance.GetPathString("scnGame", "mistakesManager", "mistakesCountP1");
			vars.Instance.Watch<int>("mistakesCountP1", "scnBase", "_instance", path1[0], path1[0]);
			string[] path2 = vars.Instance.GetPathString("scnGame", "hud", "mRank");
			vars.Instance.Watch<int>("rank", "scnBase", "_instance", path2[0], path2[1]);
			var internalId = vars.Instance.Get("scnGame", "internalIdentifier", "0x14");
			vars.Resolver.WatchString("Level", internalId.Base, internalId.Offsets);
			vars.Instance.Watch<bool>("slotOpen", "scnMenu", "_instance", "slotOpen");
			vars.Instance.Watch<bool>("transitioningToAnotherScene", "scnMenu", "_instance", "transitioningToAnotherScene");
			var levelPath = vars.Instance.Get("scnGame", "currentLevelPath", "0x14");
			vars.Resolver.WatchString("currentLevelPath", levelPath.Base, levelPath.Offsets);
			vars.Uhara["currentLevelPath"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
			vars.Instance.Watch<bool>("attemptToLoadTutorial", "scnGame", "attemptToLoadTutorial");
			string[] path3 = vars.Instance.GetPathString("scnGame", "_gameState");
			vars.Instance.Watch<int>("GameState", "scnBase", "_instance", path3[0]);


			if (vars.Version == "v0.10.1")
			{
				string[] path4 = vars.Instance.GetPathString("scnGame", "hud", "mGameover");
				vars.Instance.Watch<int>("trueGameover", "scnBase", "_instance", path4[0], path4[1]);
			}
			else
			{
				string[] path5 = vars.Instance.GetPathString("scnGame", "hud", "trueGameover");
				vars.Instance.Watch<int>("trueGameover", "scnBase", "_instance", path5[0], path5[1]);
			}
			vars.Uhara["trueGameover"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
			vars.Uhara.Log("Using v0.10-0.11 pointers");
		}
		break;
	}

	vars.Instance.Watch<bool>("barNumber", "scrConductor", "_instance", "barNumber");
	var i1 = vars.Instance.GetPathString("scnGame", "currentLevel", "i1");
	vars.Instance.Watch<int>("score", "scnBase", "_instance", i1[0], i1[1]);
	var nGS = vars.Instance.GetPathString("scnGame", "currentLevel", "noGetSet");
	vars.Instance.Watch<int>("noGetSet", "scnBase", "_instance", nGS[0], nGS[1]);
	var rwls = vars.Instance.GetPathString("RhythmWeightlifter:scnRhythmWeightlifter", "shouldShowEnding");
	vars.Instance.Watch<bool>("shouldShowEnding", "scnBase", "_instance", rwls[0]);
	var rwlllp = vars.Instance.GetPathString("RhythmWeightlifter:scnRhythmWeightlifter", "lastLevelPlayed");
	vars.Instance.Watch<bool>("lastLevelPlayed", "scnBase", "_instance", rwlllp[0]);
	var bs = vars.Instance.Get("scnBase", "_instance");
    var ff1 = new int[bs.Offsets.Length + 1];
    var ff2 = vars.Instance.GetPathInt("RhythmWeightlifter:scnRhythmWeightlifter", "levels");
	for (int i = 0; i < bs.Offsets.Length; i++) ff1[i] = bs.Offsets[i];
    ff1[ff1.Length - 1] = ff2[0];
    vars.Resolver.WatchArray<IntPtr>("levels", bs.Base, ff1);

	vars.WLHasShownEnding = false;
	vars.WLScore = 0;
	vars.BeansHopperScore = 0;
	current.ActiveScene = "";
	current.Level = "";
	current.inGame = false;
}

update
{
	vars.Uhara.Update();

	if (!String.IsNullOrWhiteSpace(vars.Utils.GetActiveSceneName())) current.ActiveScene = vars.Utils.GetActiveSceneName();
	if (old.ActiveScene != current.ActiveScene) vars.Uhara.Log("Scene changed from " + old.ActiveScene + " to " + current.ActiveScene);
	if (old.Level != current.Level) vars.Uhara.Log("Level Change: " + current.Level);
	if ((old.ActiveScene == "scnLevelSelect" && current.ActiveScene == "scnGame")) vars.levelCompleted = false;

	if (current.ActiveScene == "scnRhythmWeightlifter")
	{
		if (current.shouldShowEnding)
			vars.WLHasShownEnding = true;

		int totalScore = 0;
		for (int i = 0; i < current.levels.Length; i++)
			totalScore += vars.Resolver.Read<int>(current.levels[i] + 0x3C);

		vars.WLScore = totalScore;
	}

	switch ((string)vars.Version)
	{
		case "v1.0.1+": case "v1.0.0":
		case "v0.19.0": case "v0.18.1":
		case "v0.17.0": case "v0.16.1": case "v0.16.0":
		case "v0.15.1": case "v0.15.0":
		case "v0.14.0": case "v0.13.1": case "v0.13.0": case "v0.12.0":
			if (vars.bossLevels.Contains(current.Level) &&
				current.trueGameover > 0 && current.trueGameover < 5 &&
				!current.failedLevel && !(current.mistakesCountP1 > 0.0 && settings["Flawless"]))
			{
				vars.levelCompleted = true;
			}
			break;

		case "v0.11.6": case "v0.11.5": case "v0.10.1":
			if ((current.Level == "BeansHopper" && current.noGetSet && 
				(!settings["Flawless"] || current.score >= 60)) ||
				(current.trueGameover > 0 && current.trueGameover < 5 &&
				((vars.bossLevels.Contains(current.Level) && !current.failedLevel) ||
				(!vars.bossLevels.Contains(current.Level) && vars.GetLocalRank(current.rank) >= 10)) &&
				!(current.mistakesCountP1 > 0.0 && settings["Flawless"])))
			{
				vars.levelCompleted = true;
			}
			break;
	}

	if (current.ActiveScene == "scnGame" && current.Level == "BeansHopper")
	{
		if (current.score >= 0 && current.score < 1000)
			vars.BeansHopperScore = current.score;
	}
}

start
{
	if (!settings["IL_Mode"])
	{
		switch((string)vars.Version)
		{
			case "v1.0.1+": case "v1.0.0":
			case "v0.19.0": case "v0.18.1":
			case "v0.17.0": case "v0.16.1": case "v0.16.0":
			case "v0.15.1": case "v0.15.0":
			case "v0.14.0": case "v0.13.1": case "v0.13.0": case "v0.12.0":
				return !old.inGame && current.inGame;
				break;

			case "v0.11.6": case "v0.11.5": case "v0.10.1":
				return !(old.slotOpen && old.transitioningToAnotherScene) && (current.slotOpen && current.transitioningToAnotherScene);
				break;
		}
	}
	else if (current.ActiveScene == "scnGame")
    {
        if (current.Level != "BeansHopper")
            return !current.attemptToLoadTutorial && !current.currentLevelPath.Contains("tutorial") && current.GameState == 1;
        else
            return current.barNumber == 3;
    }
}

onStart
{
	vars.levelCompleted = false;
	vars.Uhara.Log("--- START");
	vars.VisitedLevel.Clear();
	vars.WLHasShownEnding = false;
	vars.WLScore = 0;
	vars.BeansHopperScore = 0;
}

split
{
    bool flawlessOn = settings["Flawless"];
    bool ilModeOn = settings["IL_Mode"];

    if (!ilModeOn)
    {
        if (old.ActiveScene == "scnGame" && current.ActiveScene != "scnGame")
        {
            bool isNoCompletion = vars.noCompletionLevels.Contains(old.Level);
            string splitLevel = isNoCompletion ? old.Level : current.Level;
            int localRank = vars.GetLocalRank(current.rank);

            bool beansHopperSplit = splitLevel == "BeansHopper" && !old.noGetSet && current.noGetSet && (!flawlessOn || vars.BeansHopperScore >= 60);
            bool bossSplit = vars.bossLevels.Contains(splitLevel) && vars.levelCompleted;
            bool helpingHandsSplit = splitLevel == "HelpingHands" && (!flawlessOn || localRank == 17);
            bool normalRankSplit = !isNoCompletion && splitLevel != "BeansHopper" 
									&& splitLevel != "HelpingHands" && localRank >= 10 && (!flawlessOn || localRank == 17);
            bool doSplit = isNoCompletion || beansHopperSplit || bossSplit || helpingHandsSplit || normalRankSplit;

            if (!vars.VisitedLevel.Contains(splitLevel) && doSplit)
            {
                vars.Uhara.Log("--- SPLIT: " + splitLevel);
                vars.VisitedLevel.Add(splitLevel);
                return settings[splitLevel];
            }
        }

        if (!vars.VisitedLevel.Contains("RhythmWeightlifter") &&
            old.ActiveScene == "scnRhythmWeightlifter" &&
            current.ActiveScene == "scnLevelSelect" &&
            (vars.WLScore >= 2400 || (vars.WLHasShownEnding && !flawlessOn)))
        {
            vars.VisitedLevel.Add("RhythmWeightlifter");
            return settings["RhythmWeightlifter"];
        }
    }
    else
    {
        switch ((string)vars.Version)
        {
            case "v1.0.1+": case "v1.0.0":
            case "v0.19.0": case "v0.18.1":
            case "v0.17.0": case "v0.16.1": case "v0.16.0":
            case "v0.15.1": case "v0.15.0":
            case "v0.14.0": case "v0.13.1": case "v0.13.0": case "v0.12.0":
                return current.Level != "BeansHopper"
                    ? old.GameState == 1 && current.GameState == 6
                    : !old.noGetSet && current.noGetSet;

            case "v0.11.6": case "v0.11.5": case "v0.10.1":
                return current.Level != "BeansHopper"
                    ? current.GameState == 3 && old.rank == 0 && current.rank != 0
                    : !old.noGetSet && current.noGetSet;
        }
    }
}
