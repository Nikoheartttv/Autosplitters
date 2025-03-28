state("Rhythm Doctor") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Rhythm Doctor";
    vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "IL_Mode", false, "IL Splitting", null },
		{ "SRC", false, "SR.C Run Categories", null },
			{ "Flawless", false, "100% / Flawless Category", "SRC" },
		{ "Levels", true, "Levels", null },
			{ "Intro", true, "0-1: Intro", "Levels" },
			{ "OrientalTechno", true, "1-1: Samurai Techno", "Levels" },
			{ "OrientalDubstep", true, "1-1N: Samurai Dubstep", "Levels" },
			{ "Intimate", true, "1-2: Intimate", "Levels" },
			{ "IntimateH", true, "1-2N: Intimate (Night)", "Levels" },
			{ "OrientalInsomniac", true, "1-X: Battleworn Insomniac", "Levels" },
			{ "InsomniacHard", true, "1-XN: Super Battleworn Insomniac", "Levels" },
			{ "Lofi", true, "2-1: Lo-fi Hip-Hop Beats To Treat Patients To", "Levels" },
			{ "CareLess", true, "2-1N: wish i could care less", "Levels" },
			{ "SVT", true, "2-2: Supraventricula Tachycardia", "Levels" },
			{ "Unreachable", true, "2-2N: Unreachable", "Levels" },
			{ "Smokin", true, "2-3: Puff Piece", "Levels" },
			{ "Pomeranian", true, "2-3N: Bomb-Sniffing Pomeranian", "Levels" },
			{ "SongOfTheSea", true, "2-4: Song of the Sea", "Levels" },
			{ "SongOfTheSeaH", true, "2-4N: Song of the Sea (Night)", "Levels" },
			{ "BeansHopper", true, "2-B1: Beans Hopper", "Levels" },
			{ "Boss2", true, "2-X: All The Times", "Levels" },
			{ "Garden", true, "3-1: Sleepy Garden", "Levels" },
			{ "Lounge", true, "3-1N: Lounge", "Levels" },
			{ "Classy", true, "3-2: Classy", "Levels" },
			{ "ClassyH", true, "3-2N: Classy (Night)", "Levels" },
			{ "DistantDuet", true, "3-3: Distant Duet", "Levels" },
			{ "DistantDuetH", true, "3-3N: Distant Duet (Night)", "Levels" },
			{ "Lesmis", true, "3-X: One Shift More", "Levels" },
			{ "Heldbeats", true, "4-1: Training Doctor's Train Ride Performance", "Levels" },
			{ "Rollerdisco", true, "4-1N: Rollerdisco Rumble", "Levels" },
			{ "Invisible", true, "4-2: Invisible", "Levels" },
			{ "InvisibleH", true, "4-2N: Invisible (Night)", "Levels" },
			{ "Steinway", true, "4-3: Steinway", "Levels" },
			{ "SteinwayH", true, "4-3N: Steinway Reprise", "Levels" },
			{ "KnowYou", true, "4-4: Know You", "Levels" },
			{ "Murmurs", true, "4-4N: Murmurs", "Levels" },
			{ "LuckyBreak", true, "5-1: Lucky Break", "Levels" },
			{ "Injury", true, "5-1N: One Slip Too Late", "Levels" },
			{ "Freezeshot", true, "5-2: Lo-fi Beats For Patients To Chill To", "Levels" },
			{ "FreezeshotH", true, "5-2N: Unsustainable Inconsolable", "Levels" },
			{ "AthleteTherapy", true, "5-3: Seventh-Inning Stretch", "Levels" },
			{ "RhythmWeightlifter", false, "5-B1: Rhythm Weightlifter", "Levels" },
			{ "AthleteFinale", true, "5-X: Dreams Don't Stop", "Levels" },
			{ "BlackestLuxuryCar", true, "MD-1: Blackest Luxury Car", "Levels" },
			{ "TapeStopNight", true, "MD-2: tape/stop/night", "Levels" },
			{ "The90sDecision", true, "MD-3: The 90s Decision", "Levels" },
			{ "HelpingHands", true, "X-0: Helping Hands", "Levels" },
			{ "ArtExercise", true, "X-1: Art Exercise", "Levels" },
			{ "Unbeatable", true, "X-WOT: Worn Out Tapes", "Levels" },
			{ "MeetAndTweet", true, "X-MAT: Meet And Tweet", "Levels" },
			{ "VividStasis", true, "X-FTS: Fixations Towards the Stars", "Levels" },
			{ "SparkLine", true, "X-KOB: Kindom of Balloons", "Levels" },
			{ "Halloween", true, "1-BOO: theme of really spooky bird", "Levels" },
		{ "AutoReset", false, "Auto Reset when going back to Menu", null },
	};

	vars.bossLevels = new List<string>() { "OrientalInsomniac", "InsomniacHard", "Boss2", "Lesmis", "AthleteFinale" };

	vars.rank = new dynamic[,]
	{
    	{ 0, -10, "Fminus" },
    	{ 1, 0, "F" },
    	{ 2, 10, "Fplus" },
    	{ 3, -11, "Dminus" },
    	{ 4, 1, "D" },
    	{ 5, 11, "Dplus" },
    	{ 6, -12, "Cminus" },
    	{ 7, 2, "C" },
    	{ 8, 12, "Cplus" },
    	{ 9, -13, "Bminus" },
    	{ 10, 3, "B" },
    	{ 11, 13, "Bplus" },
    	{ 12, -14, "Aminus" },
    	{ 13, 4, "A" },
    	{ 14, 14, "Aplus" },
   		{ 15, -15, "Sminus" },
    	{ 16, 5, "S" },
    	{ 17, 15, "Splus"}
	};

	vars.GetLocalRank = new Func<int, int>(rank => 
	{
		for (var i = 0; i < vars.rank.GetLength(0); i++)
			{
				if (vars.rank[i, 1] == rank) return vars.rank[i, 0];
			}
		return 0;
	});

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();

	vars.VisitedLevel = new List<string>();
    vars.levelCompleted = false;
}

init
{
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
    {
        using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            exeMD5HashBytes = md5.ComputeHash(s);
        }
    }

	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    vars.MD5Hash = MD5Hash;
    print("MD5: " + MD5Hash);

	switch(MD5Hash){
		case "698DC0773B480B5B9127112DD55A7A60" :
			version = "v0.10.1 (r16)";
			break;
		case "C379A9CEB2C154815BA55821901D53D5" :
			version = "v0.11.5 (r25)";
			break;
		case "2874D1A2C359615190E9781B78771CF1" :
			version = "v0.11.6 (r26)";
			break;
		case "6B7877D3378B120385151B07B2EDF32A" :
			version = "v0.12.0 (r27)";
			break;
		case "A2715D7A27D579C3AD2E76DC44E2CAC7" :
			version = "v0.13.0 (r28)";
			break;
		case "4F6E03AFB7695F2E9F56398587B5508F" :
			version = "v0.13.1 (r29)";
			break;
		case "6DB3C6A773E02712E541D4F0F47FD41E" :
			version = "v0.14.0 (r30)";
			break;
		case "89A9039F6D8583885E6178B7CCC93AFF" :
			version = "v0.15.0 (r31)";
			break;
		case "E41A7BCFDA01F513D60EAAE1F8056A1E" :
			version = "v0.16.0 / v0.17.0 (r32/r33)";
			break;
		default:
			version = "Unknown version";
			break;
	}

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Mono = mono;
        vars.Assembly = mono.Images["Assembly-CSharp"];
        
		var scnGame = mono["scnGame", 1];
		var scnGame2 = mono["scnGame"];
        var HUD = mono["HUD"];
        var MM = mono["MistakesManager"];
        var Level_Custom = mono["Level_Custom"];
		var scnMenu = mono["scnMenu", 1];
		var scrC = mono["scrConductor"];

		switch(version)
		{
			case "Unknown version":
			case "v0.16.0 / v0.17.0 (r32/r33)":
				var SV2 = mono["SpeedrunValues"];
				vars.Helper["inGame"] = SV2.Make<bool>("inGame");
				vars.Helper["isLoading"] = SV2.Make<bool>("isLoading");
				vars.Helper["Level"] = SV2.MakeString("currentLevel");
				vars.Helper["rank"] = SV2.Make<int>("rank");
				vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
				vars.Helper["GameState"] = SV2.Make<int>("currentGameState");
				vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");

				break;
			case "v0.15.0 (r31)":
			case "v0.14.0 (r30)":
			case "v0.13.1 (r29)":
			case "v0.13.0 (r28)":
			case "v0.12.0 (r27)":
				// SpeedrunValues
				var SV = mono["SpeedrunValues"];
				vars.Helper["inGame"] = SV.Make<bool>("inGame");
				vars.Helper["isLoading"] = SV.Make<bool>("isLoading");
				vars.Helper["Level"] = SV.MakeString("currentLevel");
				vars.Helper["rank"] = SV.Make<int>("rank");
				vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
				vars.Helper["GameState"] = SV.Make<int>("currentGameState");
				vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");

				break;

			case "v0.11.6 (r26)":
			case "v0.11.5 (r25)":
			case "v0.10.1 (r16)":
				// Misc
				vars.Helper["rank"] = scnGame.Make<int>("_instance", "hud", HUD["mRank"]);
				//vars.Helper["Level"] = scnGame2.MakeString("internalIdentifier");
				vars.Helper["Level"] = mono.MakeString("scnGame", "internalIdentifier");
				vars.Helper["slotOpen"] = scnMenu.Make<bool>("_instance", "slotOpen");
				vars.Helper["transitioningToAnotherScene"] = scnMenu.Make<bool>("_instance", "transitioningToAnotherScene");
				vars.Helper["currentLevelPath"] = scnGame2.MakeString("currentLevelPath");
				vars.Helper["attemptToLoadTutorial"] = scnGame2.Make<bool>("attemptToLoadTutorial");
				vars.Helper["GameState"] = scnGame.Make<int>("_instance", "_gameState");

				break;
		}

        vars.Helper["failedLevel"] = scnGame.Make<bool>("_instance", "failedLevel");

		switch(version)
		{
			case "v0.10.1 (r16)":
				vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "hud", HUD["mGameover"]);
				break;
			default:
				vars.Helper["trueGameover"] = scnGame.Make<int>("_instance", "hud", HUD["trueGameover"]);
				break;
		}
        vars.Helper["mistakesCountP1"] = scnGame.Make<float>("_instance", "mistakesManager", MM["mistakesCountP1"]);
		
        // Beans Values
        vars.Helper["barNumber"] = mono.Make<int>("scrConductor", "_instance", "barNumber");
        vars.Helper["score"] = scnGame.Make<int>("_instance", "currentLevel", Level_Custom["i1"]);
        vars.Helper["noGetSet"] = scnGame.Make<bool>("_instance", "currentLevel", Level_Custom["noGetSet"]);

        return true;
    });

    vars.WLClassFound = false;
	vars.WLHasShownEnding = false;
	vars.WLScore = 0;

	current.Scene = "";
	current.Level = "";
	current.inGame = false;
}

update
{
    if (!vars.WLClassFound && current.Scene == "scnRhythmWeightlifter")
	{
		var WL = vars.Assembly["RhythmWeightlifter.scnRhythmWeightlifter"];
		vars.Level = vars.Assembly["RhythmWeightlifter.Level"];
		if (WL.Static != IntPtr.Zero)
		{
			vars.WLClassFound = true;
			vars.Helper["shouldShowEnding"] = WL.Make<bool>("gameInstance", "shouldShowEnding");
			vars.Helper["lastLevelPlayed"] = WL.Make<bool>("gameInstance", "lastLevelPlayed");
			vars.Helper["rwpaused"] = WL.Make<bool>("gameInstance", "paused");
			vars.Helper["WLlevels"] = WL.MakeArray<IntPtr>("gameInstance", "levels");
		}
	}

	if (vars.WLClassFound && current.Scene == "scnRhythmWeightlifter" && current.shouldShowEnding) vars.WLHasShownEnding = true;

	if (vars.WLClassFound && current.Scene == "scnRhythmWeightlifter" && vars.WLScore < 2000)
	{
		int totalScore = 0;
		for (var i = 0; i < vars.Helper["WLlevels"].Current.Length; i++)
		{
			totalScore += vars.Helper.Read<int>(vars.Helper["WLlevels"].Current[i] + vars.Level["score"]);
		}

		vars.WLScore = totalScore;
	}

	// if (old.GameState != current.GameState) vars.Log("GameState changed from " + old.GameState.ToString() + " to " + current.GameState.ToString());
	if (!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.Scene = vars.Helper.Scenes.Active.Name;

	if (old.Scene != current.Scene) vars.Log("Scene changed from " + old.Scene + " to " + current.Scene);

	// Initialise checks at level start
	if ((old.Scene == "scnLevelSelect" && current.Scene == "scnGame"))
	{
		vars.levelCompleted = false;
	}

	switch (version)
	{
		case "Unknown version":
		case "v0.16.0 / v0.17.0 (r32/r33)":
		case "v0.15.0 (r31)":
		case "v0.14.0 (r30)":
		case "v0.13.1 (r29)":
		case "v0.13.0 (r28)":
		case "v0.12.0 (r27)":
			// Boss Levels
			if (vars.bossLevels.Contains(current.Level))
			{
				if ((current.trueGameover > 0 && current.trueGameover < 5)
					&& (!current.failedLevel && !(current.mistakesCountP1 > 0.0 && settings["Flawless"])))
				{
					vars.levelCompleted = true;
				}
			}
			break;

		case "v0.11.6 (r26)":
		case "v0.11.5 (r25)":
        case "v0.10.1 (r16)":
			// Special Cases
			if (current.Level == "BeansHopper" && current.noGetSet && (!settings["Flawless"] || current.score >= 60)) vars.levelCompleted = true;

			// Standard Levels
			if (current.trueGameover > 0 && current.trueGameover < 5)
			{
				if (vars.bossLevels.Contains(current.Level))
				{ // Boss Level
					if (!current.failedLevel && !(current.mistakesCountP1 > 0.0 && settings["Flawless"])) vars.levelCompleted = true;
				}
				else
				{ // Normal Level
					if (vars.GetLocalRank(current.rank) >= 10 && !(current.mistakesCountP1 > 0.0 && settings["Flawless"])) vars.levelCompleted = true;
				}
			}
			break;
	}

	if (old.Level != current.Level) vars.Log("Level Change: " + current.Level);
}

start
{
	if (!settings["IL_Mode"])
	{
		switch(version)
		{
			case "Unknown version":
			case "v0.16.0 / v0.17.0 (r32/r33)":
			case "v0.15.0 (r31)":
			case "v0.14.0 (r30)":
			case "v0.13.1 (r29)":
			case "v0.13.0 (r28)":
			case "v0.12.0 (r27)":
				return !old.inGame && current.inGame;
				break;

			case "v0.11.6 (r26)":
			case "v0.11.5 (r25)":
            case "v0.10.1 (r16)":
				return !(old.slotOpen && old.transitioningToAnotherScene) && (current.slotOpen && current.transitioningToAnotherScene);
				break;
		}
	}
	else if (current.Scene == "scnGame" && current.Level != "BeansHopper")
	{
		if (current.Scene == "scnGame" && current.attemptToLoadTutorial == false && !current.currentLevelPath.Contains("tutorial") && current.GameState == 1) return true;
	}
	else if (current.Scene == "scnGame" && current.Level == "BeansHopper")
	{
		if (current.barNumber == 3) return true;
	}
}

onStart
{
	vars.levelCompleted = false;
	vars.Log("START");
	vars.VisitedLevel.Clear();
	vars.WLClassFound = false;
	vars.WLHasShownEnding = false;
	vars.WLScore = 0;
}

split
{
	if (!settings["IL_Mode"])
	{
		switch(version)
		{
			case "Unknown version":
			case "v0.16.0 / v0.17.0 (r32/r33)":
				if (old.Level == "Intro" && current.Level == "OrientalTechno")
					{
						vars.VisitedLevel.Add("Intro");
						return settings["Intro"];
					}

				if (old.Scene == "scnGame" && current.Scene != "scnGame")
					{
						if (!vars.VisitedLevel.Contains(current.Level))
						{
							bool doSplit = false;
							if (current.Level == "BeansHopper")
								{ if (!settings["Flawless"] || current.score >= 60) doSplit = true; }
							else if (vars.bossLevels.Contains(current.Level))
								{ if (vars.levelCompleted) doSplit = true; }
							else if (current.Level == "HelpingHands")
								{ if (!settings["Flawless"] || vars.GetLocalRank(current.rank) == 17) doSplit = true; }
							else 
								{ if (vars.GetLocalRank(current.rank) >= 10 && (!settings["Flawless"] || vars.GetLocalRank(current.rank) == 17)) doSplit = true; }

							if (doSplit)
							{
								vars.VisitedLevel.Add(current.Level);
								return settings[current.Level];
							}
						}
					}

                if (!vars.VisitedLevel.Contains("RhythmWeightlifter"))
                {
					if (old.Scene == "scnRhythmWeightlifter" && current.Scene == "scnLevelSelect")
					{
						if (vars.WLScore >= 2400 || (vars.WLHasShownEnding && !settings["Flawless"]))
						{
							vars.VisitedLevel.Add("RhythmWeightlifter");
                            return settings["RhythmWeightlifter"];
						}
					}
                }
	
				break;
			case "v0.15.0 (r31)":
			case "v0.14.0 (r30)":
			case "v0.13.1 (r29)":
			case "v0.13.0 (r28)":
			case "v0.12.0 (r27)":
				if (old.Level == "Intro" && current.Level == "OrientalTechno")
					{
						vars.VisitedLevel.Add("Intro");
						return settings["Intro"];
					}

				if (old.Scene == "scnGame" && current.Scene != "scnGame")
					{
						if (!vars.VisitedLevel.Contains(current.Level))
						{
							bool doSplit = false;
							if (current.Level == "BeansHopper")
								{ if (!settings["Flawless"] || current.score >= 60) doSplit = true; }
							else if (vars.bossLevels.Contains(current.Level))
								{ if (vars.levelCompleted) doSplit = true; }
							else if (current.Level == "HelpingHands")
								{ if (!settings["Flawless"] || vars.GetLocalRank(current.rank) == 17) doSplit = true; }
							else 
								{ if (vars.GetLocalRank(current.rank) >= 10 && (!settings["Flawless"] || vars.GetLocalRank(current.rank) == 17)) doSplit = true; }

							if (doSplit)
							{
								vars.VisitedLevel.Add(current.Level);
								return settings[current.Level];
							}
						}
					}
				break;

			case "v0.11.6 (r26)":
			case "v0.11.5 (r25)":
            case "v0.10.1 (r16)":
				if (old.Level == "Intro" && current.Level == "OrientalTechno")
					{
						vars.VisitedLevel.Add("Intro");
						return settings["Intro"];
					}

				if (vars.levelCompleted && (old.Scene == "scnGame" && current.Scene != "scnGame"))
					{
						if (!vars.VisitedLevel.Contains(current.Level))
						{
							vars.VisitedLevel.Add(current.Level);
							return settings[current.Level];
						}
					}
				break;
		}
	}
	else switch (version)
	{
		case "Unknown version":
		case "v0.16.0 / v0.17.0 (r32/r33)":
		case "v0.15.0 (r31)":
		case "v0.14.0 (r30)":
		case "v0.13.1 (r29)":
		case "v0.13.0 (r28)":
		case "v0.12.0 (r27)":
			if (current.Level != "BeansHopper")
			{
				if (old.GameState == 1 && current.GameState == 6) return true;
			}
			else if (current.Level == "BeansHopper")
			{
				return (!old.noGetSet && current.noGetSet);
			}
			break;

		case "v0.11.6 (r26)":
		case "v0.11.5 (r25)":
        case "v0.10.1 (r16)":
			if (current.Level != "BeansHopper")
			{
				if (current.GameState == 3 && old.rank == 0 && current.rank != 0) return true;
			}
			else if (current.Level == "BeansHopper")
			{
				return (!old.noGetSet && current.noGetSet);
			}
			break;
	}
}

onSplit
{
	vars.Log("SPLIT");
}

isLoading
{
	switch(version)
	{
		case "Unknown version":
		case "v0.16.0 / v0.17.0 (r32/r33)":
		case "v0.15.0 (r31)":
		case "v0.14.0 (r30)":
		case "v0.13.1 (r29)":
		case "v0.13.0 (r28)":
		case "v0.12.0 (r27)":
		    return current.isLoading;
			break;

		case "v0.11.6 (r26)":
		case "v0.11.5 (r25)":
        case "v0.10.1 (r16)":
			return String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name);
			break;
	}
}

reset
{
	switch(version)
	{
		case "Unknown version":
		case "v0.16.0 / v0.17.0 (r32/r33)":
		case "v0.15.0 (r31)":
		case "v0.14.0 (r30)":
		case "v0.13.1 (r29)":
		case "v0.13.0 (r28)":
		case "v0.12.0 (r27)":
		    return old.inGame && !current.inGame && settings["AutoReset"] && current.Level != "HelpingHands";
			break;

		case "v0.11.6 (r26)":
		case "v0.11.5 (r25)":
        case "v0.10.1 (r16)":
			
			return old.Scene != "scnMenu" && current.Scene == "scnMenu" && settings["AutoReset"] && current.Level != "HelpingHands";
			break;
	}
}

onReset
{
	vars.Log("RESET");
}

exit
{
    vars.Helper.Dispose();
}

shutdown
{
    vars.Helper.Dispose();
}
