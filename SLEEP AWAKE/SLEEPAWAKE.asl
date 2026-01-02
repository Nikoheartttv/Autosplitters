state("ProjectHProd-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();

	dynamic[,] _settings =
	{
		{ "ChapterSplits", true, "ChapterSplits (On Completed)", null },
			{ "Chapter1", true, "Ch1 - The Fathom", "ChapterSplits" },
				{ "CHP_1", true, "For Fear of Losing Track", "Chapter1" },
				{ "CHP_2", true, "A Hidden Reef", "Chapter1" },
			{ "CHP_3", true, "Ch2 - The Flat: A Remedy For Sleep", "ChapterSplits" },
			{ "Chapter3", true, "Ch3 - The Crush - The Ministry Will Have You Now", "ChapterSplits" },
				{ "CHP_4", true, "Follow Your Path Markers", "Chapter3" },
				{ "CHP_5", true, "Enter Delta Theatre", "Chapter3" },
			{ "CHP_6", true, "Ch4 - The Fathom: In Memory of Light and Language", "ChapterSplits" },
			{ "CHP_7", true, "Ch5 - The Flat: Things Fall Apart", "ChapterSplits" },
			{ "Chapter6", true, "Ch6 - The Crush: Past and Present Tense", "ChapterSplits" },
				{ "CHP_8", true, "The Institute", "Chapter6" },
				{ "CHP_9", true, "Escaping The Hush", "Chapter6" },
			{ "CHP_10", true, "Ch7 - The Fathom: On Bearing Witness", "ChapterSplits" },
			{ "CHP_11", true, "Ch8 - The Flat: Tuning in the Static", "ChapterSplits" },
			{ "CHP_12", true, "Ch9 - The Crush: Dizzy is the Distance Starting Over", "ChapterSplits" },
			{ "CHP_13", true, "Ch10 - The Keep: No One Knows The Passenger", "ChapterSplits" },
			{ "CHP_14", true, "Ch11 - The Depth: The Wreckage of Killing the Secrets of the Heart", "ChapterSplits" },
			{ "EndGame", true, "Ch12 - The Chowk: All Together Now (Splits at End Title Card)", "ChapterSplits" },
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
	vars.Events.FunctionFlag("Ch01FathomDunescapeReturn", "LSA_Ch01_IntroWander_C", "", "OnInteractableTagEvent");
	vars.Events.FunctionFlag("Ch04WinterIchorRising", "LSA_Ch04_Winter_C", "LSA_Ch04_WinterIchorRising", "OnSequencePlayerFinished");
	vars.Events.FunctionFlag("Ch07PharmacyInfusionTake", "BP_GogglesSeed_C", "BP_GogglesSeed1", "EndDisabledState");
	vars.Events.FunctionFlag("Ch07PharmacyReturnAfterInfusion", "BP_VideoProjector_C", "BP_VideoProjector_Mural", "StopVideo");
	vars.Events.FunctionFlag("Ch07WakeUpAfterHushCutscene", "LSA_Ch06_Rails_WakeUp_C", "LSA_Ch06_Rails_WakeUp", "OnLevelSequenceEnded");
	vars.Events.FunctionFlag("Ch09AfterSecretRoom", "Ch09_Crush_Obscura_P_C", "", "OnSetupLoadingVideoDelay");
	vars.Events.FunctionFlag("Ch11AfterVideo", "HypnosChamber_P_C", "", "OnSetupLoadingVideoDelay");
	vars.Events.FunctionFlag("Ch12StartFlyingSequence", "BP_AmmasBedCandle_C", "", "ExecuteUbergraph_BP_AmmasBedCandle");
	vars.Events.FunctionFlag("Ch12AfterFlyingSequence", "CSE_BreathingBase_C", "", "OnEventChanged");
	
	// Game End
	vars.Events.FunctionFlag("EndOfGame", "BP_GameManager_HypnosChamber_C", "", "SleepAwakeTitleCard");

	vars.Resolver.Watch<int>("Loading", vars.Utils.GSync);
	vars.Resolver.Watch<int>("OverallChapterNum", vars.Utils.GEngine, 0xD48, 0x4C8);
	vars.Resolver.WatchString("ChapterGoal", vars.Utils.GEngine, 0xD48, 0x848, 0x28, 0x0);

	// Initial States
	vars.Loading = false;
	vars.FlyingLoading = false;
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
	if (vars.Resolver.CheckFlag("Ch07PharmacyInfusionTake")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("OnLoadingVideoFinished")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch01FathomDunescapeReturn")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch07PharmacyReturnAfterInfusion")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch07WakeUpAfterHushCutscene")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch09AfterSecretRoom")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch11AfterVideo")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("Ch12StartFlyingSequence")) { vars.Loading = true; vars.FlyingLoading = true; }
	if (vars.FlyingLoading && vars.Resolver.CheckFlag("Ch12AfterFlyingSequence")) { vars.Loading = false; vars.FlyingLoading = false; }
	if (old.Loading != current.Loading && current.Loading == 1) vars.Loading = true;
	else if (old.Loading != current.Loading && current.Loading == 0) vars.Loading = false;

	if (old.OverallChapterNum != current.OverallChapterNum) vars.Uhara.Log("Overall Chapter Num: " + current.OverallChapterNum);
	if (old.Loading != current.Loading) vars.Uhara.Log("GSync changed: " + current.Loading);
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