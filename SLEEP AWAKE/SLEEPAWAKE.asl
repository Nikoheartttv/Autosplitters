state("ProjectHProd-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();

	dynamic[,] _settings =
	{
		{ "ChapterSplits", true, "ChapterSplits (On Completed)", null },
			{ "Chapter1", true, "Chapter 1 - The Fathom", "ChapterSplits" },
				{ "CHP_1", true, "For Fear of Losing Track", "Chapter1" },
				{ "CHP_2", true, "A Hidden Reef", "Chapter1" },
			{ "Chapter2", true, "Chapter 2 - The Flat", "ChapterSplits" },
				{ "CHP_3", true, "A Remedy For Sleep", "Chapter2" },
			{ "Chapter3", true, "Chapter 3 - The Crush", "ChapterSplits" },
				{ "CHP_4", true, "The Ministry Will Have You Now - Follow Your Path Markers", "Chapter3" },
				{ "CHP_5", true, "The Ministry Will Have You Now - Enter Delta Theatre", "Chapter3" },
			{ "Chapter4", true, "Chapter 4 - The Fathom", "ChapterSplits" },
				{ "CHP_6", true, "In Memory of Light and Language", "Chapter4" },
			{ "Chapter5", true, "Chapter 5 - The Flat", "ChapterSplits" },
				{ "CHP_7", true, "Things Fall Apart", "Chapter5" },
			{ "Chapter6", true, "Chapter 6 - The Crush", "ChapterSplits" },
				{ "CHP_8", true, "Past and Present Tense - The Institute", "Chapter6" },
				{ "CHP_9", true, "Past and Present Tense - Escaping The Hush", "Chapter6" },
			{ "Chapter7", true, "Chapter 7 - The Fathom", "ChapterSplits" },
				{ "CHP_10", true, "On Bearing Witness", "Chapter7" },
			{ "Chapter8", true, "Chapter 8 - The Flat", "ChapterSplits" },
				{ "CHP_11", true, "Tuning in the Static", "Chapter8" },
			{ "Chapter9", true, "Chapter 9 - The Crush", "ChapterSplits" },
				{ "CHP_12", true, "Dizzy is the Distance Starting Over", "Chapter9" },
			{ "Chapter10", true, "Chapter 10 - The Keep", "ChapterSplits" },
				{ "CHP_13", true, "No One Knows The Passenger", "Chapter10" },
			{ "Chapter11", true, "Chapter 11 - The Depth", "ChapterSplits" },
				{ "CHP_14", true, "The Wreckage of Killing the Secrets of the Heart", "Chapter11" },
			{ "Chapter12", true, "Chapter 12 - The Chowk", "ChapterSplits" },
				{ "EndGame", true, "All Together Now (Splits at End Title Card)", "Chapter12" },
	};
	vars.Uhara.Settings.Create(_settings);
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	// Loading Functions
	vars.Events.FunctionFlag("OnLoadingVideoFinished", "BP_LoadingScreenSubsystem_C", "", "OnLoadingMovieFinished");
	vars.Events.FunctionFlag("VideoTransitionInTimeline", "BP_LoadingVideoManager_C", "", "VideoTransitionInTimeline__FinishedFunc");
	// Chapter 1 Player Return during video playing
	vars.Events.FunctionFlag("Ch01FathomDunescapeReturn", "LSA_Ch01_IntroWander_C", "", "OnInteractableTagEvent");
	// Chapter 4 Failsafe Video Play
	vars.Events.FunctionFlag("Ch04WinterIchorRising", "LSA_Ch04_Winter_C", "LSA_Ch04_WinterIchorRising", "OnSequencePlayerFinished");
	// Chapter 7 Small Video after infusion take
	vars.Events.FunctionFlag("Ch07PharmacyInfusionTake", "BP_GogglesSeed_C", "BP_GogglesSeed1", "EndDisabledState");
	vars.Events.FunctionFlag("Ch07PharmacyReturnAfterInfusion", "BP_VideoProjector_C", "BP_VideoProjector_Mural", "StopVideo");
	vars.Events.FunctionFlag("Ch07WakeUpAfterHushCutscene", "LSA_Ch06_Rails_WakeUp_C", "LSA_Ch06_Rails_WakeUp", "OnLevelSequenceEnded");
	// Chapter 9 After Secret Room
	vars.Events.FunctionFlag("Ch09AfterSecretRoom", "Ch09_Crush_Obscura_P_C", "", "OnSetupLoadingVideoDelay");
	// Chapter 11 After Video into Hypnos Chamber
	vars.Events.FunctionFlag("Ch10AfterVideo", "HypnosChamber_P_C", "", "OnSetupLoadingVideoDelay");
	// Chapter 12 Flying Sequence
	vars.Events.FunctionFlag("Ch11StartFlyingSequence", "BP_AmmasBedCandle_C", "", "ExecuteUbergraph_BP_AmmasBedCandle");
	vars.Events.FunctionFlag("Ch11AfterFlyingSequence", "CSE_BreathingBase_C", "", "OnEventChanged");
	vars.Loading = false;
	vars.FlyingLoading = false;

	// Game Start / End
	// vars.Events.FunctionFlag("OnGameStart", "BP_InventorySubsystem_C", "", "OnNewGameEvent");
    vars.Start = true;
	vars.Events.FunctionFlag("EndOfGame", "BP_GameManager_HypnosChamber_C", "", "SleepAwakeTitleCard");

	vars.Resolver.Watch<int>("OverallChapterNum", vars.Utils.GEngine, 0xD48, 0x4C8);
	vars.Resolver.WatchString("ChapterGoal", vars.Utils.GEngine, 0xD48, 0x848, 0x28, 0x0);

	current.OverallChapterNum = 0;
}

start
{
	return vars.Resolver.CheckFlag("VideoTransitionInTimeline");
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.FlyingLoading = false;
	vars.CompletedSplits.Clear();
}

update
{
	vars.Uhara.Update();

	// vars.Loading Checks
	if (vars.Resolver.CheckFlag("VideoTransitionInTimeline")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("OnPlayLoadingVideo")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("VideoTimelineTransitionIn")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("Ch04WinterIchorRising")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("Ch76PharmacyInfusionTake")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("OnLoadingVideoFinished")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch01FathomDunescapeReturn")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch07PharmacyReturnAfterInfusion")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch07WakeUpAfterHushCutscene")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch09AfterSecretRoom")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch11AfterVideo")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch12StartFlyingSequence")) { vars.Loading = true; vars.FlyingLoading = true; }
	if (vars.FlyingLoading && vars.Resolver.CheckFlag("Ch12AfterFlyingSequence")) { vars.Loading = false; vars.FlyingLoading = false; }

	if (old.OverallChapterNum != current.OverallChapterNum) vars.Uhara.Log("Overall Chapter Num: " + current.OverallChapterNum);
}

split
{
	if (old.OverallChapterNum != current.OverallChapterNum && settings["CHP_" + old.OverallChapterNum] && !vars.CompletedSplits.Contains("CHP_" + old.OverallChapterNum))
	{
		vars.CompletedSplits.Add("CHP_" + old.OverallChapterNum);
		vars.Uhara.Log("Split: Chapter " + old.OverallChapterNum);
		return true;
	}

	if (vars.Resolver.CheckFlag("EndOfGame") && settings["EndGame"] && !vars.CompletedSplits.Contains("EndGame"))
	{
		vars.CompletedSplits.Add("EndGame");
		vars.Uhara.Log("Split: End of Game");
		return true;
	}
}

isLoading
{
	return vars.Loading;
}