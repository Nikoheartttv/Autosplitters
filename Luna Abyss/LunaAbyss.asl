state("LunaAbyss-Win64-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();

	dynamic[,] _settings =
	{
		{ "Demo", false, "Demo Splits", null },
			{ "DemoSorrowsCanyon", true, "Demo - Sorrows Canyon", "Demo" },
				{ "SorrowsCanyon", false, "Sorrows Entrance", "DemoSorrowsCanyon" },
				{ "FirstArenaStart", false, "Sorrows Canyon", "DemoSorrowsCanyon" },
				{ "FirstArenaEnd", false, "First Arena", "DemoSorrowsCanyon" },
				{ "TheWaif", false, "Oops", "DemoSorrowsCanyon" },
				{ "SorrowTowerClimb", false, "The Waif", "DemoSorrowsCanyon" },
				{ "Tower", false, "Sorrow Tower Climb I", "DemoSorrowsCanyon" },
				{ "ArenaBridge", false, "Sorrow Tower Climb II", "DemoSorrowsCanyon" },
				{ "BeforeShieldbreaker", false, "Arena Bridge", "DemoSorrowsCanyon" },
				{ "ShieldBreakerRavine", false, "Shieldbreaker", "DemoSorrowsCanyon" },
				{ "SecondArenaStart", false, "Shieldbreaker Ravine", "DemoSorrowsCanyon" },
				{ "AfterShieldbreakerHardCombat", false, "Second Arena", "DemoSorrowsCanyon" },
				{ "SecondArenaEnd", false, "Second Arena End?", "DemoSorrowsCanyon" },
				{ "SorrowsCanyonEnd", false, "Sorrows Canyon End", "DemoSorrowsCanyon" },
			{ "DemoScourgeCrater", true, "Demo - Scourge Crater", "Demo" },
				{ "MeadowsCrater", false, "Scourge Ravine", "DemoScourgeCrater" },
				{ "PostSniperTutorial", false, "Meadows Crater", "DemoScourgeCrater" },
				{ "CraterPathway", false, "Post Sniper Tutorial", "DemoScourgeCrater" },
				{ "ReactorEntrance", false, "Crater Pathway", "DemoScourgeCrater" },
				{ "MeadowsReactorClimb", false, "Reactor Entrance", "DemoScourgeCrater" },
				{ "MeadowsReactor", false, "Drift Reactor Climb", "DemoScourgeCrater" },
				{ "MeadowsBoss", false, "Drift Reactor Discovered", "DemoScourgeCrater" },
				{ "ScourgeCraterEnd", false, "Scourge Crater End", "DemoScourgeCrater" },
		{ "FullGame", false, "Full Game Splits", null },
			{ "ILStart", false, "IL Start", "FullGame" },
			{ "ChapterSplits", true, "Chapter Splits", "FullGame" },
				{ "ChpPrologue", true, "Prologue", "ChapterSplits" },
					{ "D2StgID1", true, "A New Scout", "ChpPrologue" },
				{ "Chapter1", true, "Chapter 1", "ChapterSplits" },
					{ "D2StgID2", true, "Sorrows Canyon", "Chapter1" },
					{ "D3StgID1", true, "Wardens Regret", "Chapter1" },
				{ "Chapter2", true, "Chapter 2", "ChapterSplits" },
					{ "D3StgID2", true, "New Orders", "Chapter2" },
					{ "D3StgID5", true, "King's Reach", "Chapter2" },
					{ "D3StgID7", true, "Weeping Meadows", "Chapter2" },
					{ "D3StgID8", true, "Scourge Crater", "Chapter2" },
					{ "D4StgID1", true, "Tortured Adrift", "Chapter2" },
				{ "Chapter3", true, "Chapter 3", "ChapterSplits" },
					{ "D4StgID2", true, "To the Mines", "Chapter3" },
					{ "D4StgID4", true, "The Second Seal", "Chapter3" },
					{ "D4StgID5", true, "The Drift Mines", "Chapter3" },
					{ "D4StgID6", true, "Riding the Rails", "Chapter3" },
					{ "D5StgID1", true, "Rotten Adrift", "Chapter3" },
				{ "Chapter4", true, "Chapter 4", "ChapterSplits" },
					{ "D5StgID2", true, "The Lost City", "Chapter4" },
					{ "D5StgID3", true, "The Crescent Mile", "Chapter4" },
					{ "D5StgID4", true, "Greymont Underpass", "Chapter4" },
					{ "D5StgID6", true, "The City of Greymont", "Chapter4" },
					{ "D6StgID1", true, "The Catacombs", "Chapter4" },
				{ "Chapter5", true, "Chapter 5", "ChapterSplits" },
					{ "D6StgID2", true, "Luna Child Aylin", "Chapter5" },
					{ "D6StgID4", true, "One Last Job", "Chapter5" },
					{ "D6StgID5", true, "Pillar of Ash", "Chapter5" },
					{ "D6StgID6", true, "The Hanging Towers", "Chapter5" },
					{ "D6StgID7", true, "Mani's Folly", "Chapter5" },
					{ "D7StgID1", true, "Mani the Betrayer", "Chapter5" },
				{ "Chapter6", true, "Chapter 6", "ChapterSplits" },
					{ "D7StgID2", true, "The Heart of the Abyss", "Chapter6" },
					{ "EndGameFinalDialogue", true, "The Womb of Silence", "Chapter6" },
			// { "CheckpointSplits", true, "Checkpoint Splits", "FullGame" },
			// 	{ "Checkpoint_Chapter1", true, "Chapter 1", "CheckpointSplits" },
			// 		{ "Checkpoint_Chapter1_1", true, "Sorrows Canyon", "Checkpoint_Chapter1" },
			// 			{ "Checkpoint_Chapter1_SorrowsCanyon", false, "Sorrows Entrance", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_FirstArenaStart", false, "Sorrows Canyon", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_FirstArenaEnd", false, "First Arena", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_TheWaif", false, "Oops", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_SorrowTowerClimb", false, "The Waif", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_Tower", false, "Sorrow Tower Climb I", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_SorrowTowerPuzzleEnd", false, "Sorrow Tower Climb II", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_ArenaBridge", false, "Arena Bridge", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_Pipeways", false, "Pipeways", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_BeforeShieldbreaker", false, "Before Shieldbreaker", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_Shieldbreaker", false, "Shieldbreaker", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_ShieldBreakerRavine", false, "Shieldbreaker Ravine", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_RavineEnd", false, "Ravine End", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_FirstHealthChest", false, "First Health Chest", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_SecondArenaStart", false, "Second Arena Start", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_AfterShieldbreakerHardCombat", false, "After Shieldbreaker Hard Combat", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_SecondArenaEnd", false, "Second Arena End", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_HydraulicWallButton", false, "Hydraulic Wall Button", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_PathToRegret", false, "Path to Regret", "Checkpoint_Chapter1_1" },
			// 			{ "Checkpoint_Chapter1_WardenEntrance", false, "Wardens Entrance", "Checkpoint_Chapter1_1" },

			// 		{ "Checkpoint_Chapter1_2", true, "Wardens Regret", "Checkpoint_Chapter1" },
			// 			{ "Checkpoint_Chapter1_WardenDrop", false, "Wardens Drop", "Checkpoint_Chapter1_2" },
			// 			{ "Checkpoint_Chapter1_RegretPipes", false, "Regret Pipes", "Checkpoint_Chapter1_2" },
			// 			{ "Checkpoint_Chapter1_PlacentalSteps", false, "Placental Steps", "Checkpoint_Chapter1_2" },
			// 			{ "Checkpoint_Chapter1_DriftFawkes", false, "Drift Fawkes", "Checkpoint_Chapter1_2" },

			// 		{ "Checkpoint_Chapter1_3", true, "Wardens Regret Return", "Checkpoint_Chapter1" },
			// 			{ "Checkpoint_Chapter1_PreWatcherTutorial", false, "Pre Watcher Tutorial", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_afterDriftFawkes", false, "After Drift Fawkes", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WatcherAscent", false, "Watcher Ascent", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WatcherSequence", false, "Watcher Sequence", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_watcherTutorial", false, "Watcher Tutorial", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WatcherTutorialFinale", false, "Watcher Tutorial Finale", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WardenEntranceReturn", false, "Wardens Entrance Return", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WardenPipes", false, "Wardens Pipes", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WardenPipes01", false, "Wardens Pipes I", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WardenPipes02", false, "Wardens Pipes II", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_WardenPipe03", false, "Wardens Pipes III", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_AbsalomBoss", false, "Absalom", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_PreAbsalom", false, "Pre Absalom", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_AfterAbsolom", false, "After Absalom", "Checkpoint_Chapter1_3" },
			// 			{ "Checkpoint_Chapter1_EliLiftFinish", false, "Eli Lift Finish", "Checkpoint_Chapter1_3" },

			// 		{ "Checkpoint_Chapter1_4", true, "New Orders", "Checkpoint_Chapter1" },
			// 			{ "Checkpoint_Chapter1_Furnace", false, "Furnace", "Checkpoint_Chapter1_4" },
			// 			{ "Checkpoint_Chapter1_FallEndButton", false, "Fall End Button", "Checkpoint_Chapter1_4" },
			// 			{ "Checkpoint_Chapter1_MeadowsTrailEntrance", false, "Meadows Trail Entrance", "Checkpoint_Chapter1_4" },

			// 	{ "Checkpoint_Chapter2", true, "Chapter 2", "CheckpointSplits" },
			// 		{ "Checkpoint_Chapter2_1", true, "Kings Reach", "Checkpoint_Chapter2" },
			// 			{ "Checkpoint_Chapter2_LaserTunnel", false, "Laser Tunnel", "Checkpoint_Chapter2_1" },
			// 			{ "Checkpoint_Chapter2_DoubleJumpChest", false, "Double Jump Chest", "Checkpoint_Chapter2_1" },
			// 			{ "Checkpoint_Chapter2_DoubleJumpTutorial", false, "Double Jump Tutorial", "Checkpoint_Chapter2_1" },
			// 			{ "Checkpoint_Chapter2_SlideDrop", false, "Slide Drop", "Checkpoint_Chapter2_1" },
			// 			{ "Checkpoint_Chapter2_VastCatacombs", false, "Vast Catacombs", "Checkpoint_Chapter2_1" },
			// 			{ "Checkpoint_Chapter2_EndOfCatacombs", false, "End Of Catacombs", "Checkpoint_Chapter2_1" },
			// 			{ "Checkpoint_Chapter2_MeadowsEntrance", false, "Meadows Entrance", "Checkpoint_Chapter2_1" },

			// 		{ "Checkpoint_Chapter2_2", true, "Weeping Meadows", "Checkpoint_Chapter2" },
			// 			{ "Checkpoint_Chapter2_VoidStation", false, "Void Station", "Checkpoint_Chapter2_2" },
			// 			{ "Checkpoint_Chapter2_ShieldWorkshop", false, "Shield Workshop", "Checkpoint_Chapter2_2" },
			// 			{ "Checkpoint_Chapter2_WorkshopExit", false, "Workshop Exit", "Checkpoint_Chapter2_2" },
			// 			{ "Checkpoint_Chapter2_MeadowsFirstSoftCombat", false, "Meadows First Soft Combat", "Checkpoint_Chapter2_2" },
			// 			{ "Checkpoint_Chapter2_ButtonPuzzleTutorialEnd", false, "Button Puzzle Tutorial End", "Checkpoint_Chapter2_2" },
			// 			{ "Checkpoint_Chapter2_MeadowsRavine", false, "Meadows Ravine", "Checkpoint_Chapter2_2" },
			// 			{ "Checkpoint_Chapter2_ScourgeRavine", false, "Scourge Ravine", "Checkpoint_Chapter2_2" },

			// 		{ "Checkpoint_Chapter2_3", true, "Scourge Crater", "Checkpoint_Chapter2" },
			// 			{ "Checkpoint_Chapter2_MeadowsCrater", false, "Meadows Crater", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_PostSniperTutorial", false, "Post Sniper Tutorial", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_CraterPathway", false, "Crater Pathway", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_ReactorEntrance", false, "Reactor Entrance", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_MeadowsReactorClimb", false, "Drift Reactor Climb", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_MeadowsReactor", false, "Drift Reactor Discovered", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_MeadowsBoss", false, "Meadows Boss", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_postMedBoss", false, "Post Meadows Boss", "Checkpoint_Chapter2_3" },
			// 			{ "Checkpoint_Chapter2_KingsReachDay4", false, "Kings Reach Day 4", "Checkpoint_Chapter2_3" },

			// 	{ "Checkpoint_Chapter3", true, "Chapter 3", "CheckpointSplits" },
			// 		{ "Checkpoint_Chapter3_1", true, "Tortured Adrift", "Checkpoint_Chapter3" },
			// 			{ "Checkpoint_Chapter3_MinTrailUnlocked", false, "Mine Trail Unlocked", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_TrailEntrance", false, "Trail Entrance", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_MinTrailEntrance", false, "Mine Trail Entrance", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_LaserTrail", false, "Laser Trail", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_SewerPipes", false, "Sewer Pipes", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_MinesTrailBridge2", false, "Mines Trail Bridge II", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_UnderBridge", false, "Under Bridge", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_UnderBridgeMidPoint", false, "Under Bridge Midpoint", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_BridgeChallenges", false, "Bridge Challenges", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_ThePit", false, "The Pit", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_PitBottom", false, "Pit Bottom", "Checkpoint_Chapter3_1" },
			// 			{ "Checkpoint_Chapter3_DescentEntrance", false, "Descent Entrance", "Checkpoint_Chapter3_1" },

			// 		{ "Checkpoint_Chapter3_2", true, "The Second Seal", "Checkpoint_Chapter3" },
			// 			{ "Checkpoint_Chapter3_DriftPlatformGauntlet", false, "Drift Platform Gauntlet", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_EndOfRailOne", false, "End Of Rail One", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_ThirdStation", false, "Third Station", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_DescentTower", false, "Descent Tower", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_PreTowerCombat", false, "Pre Tower Combat", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_AfterTowerHardCombat", false, "After Tower Hard Combat", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_DescentReactor", false, "Descent Reactor", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_MinesReactorEntrance", false, "Mines Reactor Entrance", "Checkpoint_Chapter3_2" },
			// 			{ "Checkpoint_Chapter3_InsideMinesReactor", false, "Inside Mines Reactor", "Checkpoint_Chapter3_2" },

			// 		{ "Checkpoint_Chapter3_3", true, "Riding the Rails", "Checkpoint_Chapter3" },
			// 			{ "Checkpoint_Chapter3_MinesPipes", false, "Mines Pipes", "Checkpoint_Chapter3_3" },
			// 			{ "Checkpoint_Chapter3_MinesBoss", false, "Mines Boss", "Checkpoint_Chapter3_3" },
			// 			{ "Checkpoint_Chapter3_postMinBoss", false, "Post Mines Boss", "Checkpoint_Chapter3_3" },
			// 			{ "Checkpoint_Chapter3_TrainApproach", false, "Train Approach", "Checkpoint_Chapter3_3" },

			// 	{ "Checkpoint_Chapter4", true, "Chapter 4", "CheckpointSplits" },
			// 		{ "Checkpoint_Chapter4_1", true, "The Crescent Mile", "Checkpoint_Chapter4" },
			// 			{ "Checkpoint_Chapter4_ApproachQuarterpoint", false, "Approach Quarterpoint", "Checkpoint_Chapter4_1" },
			// 			{ "Checkpoint_Chapter4_ApproachMidpoint", false, "Approach Midpoint", "Checkpoint_Chapter4_1" },
			// 			{ "Checkpoint_Chapter4_GreymontReveal", false, "Greymont Reveal", "Checkpoint_Chapter4_1" },

			// 		{ "Checkpoint_Chapter4_2", true, "Greymont Underpass", "Checkpoint_Chapter4" },
			// 			{ "Checkpoint_Chapter4_CathedralEntrance", false, "Cathedral Entrance", "Checkpoint_Chapter4_2" },
			// 			{ "Checkpoint_Chapter4_ThroneEntranceActivated", false, "Throne Entrance Activated", "Checkpoint_Chapter4_2" },

			// 		{ "Checkpoint_Chapter4_3", true, "The City of Greymont", "Checkpoint_Chapter4" },
			// 			{ "Checkpoint_Chapter4_PathToThrone", false, "Path To Throne", "Checkpoint_Chapter4_3" },
			// 			{ "Checkpoint_Chapter4_KingsReachDay6", false, "Kings Reach Day 6", "Checkpoint_Chapter4_3" },

			// 	{ "Checkpoint_Chapter5", true, "Chapter 5", "CheckpointSplits" },
			// 		{ "Checkpoint_Chapter5_1", true, "Luna Child Aylin", "Checkpoint_Chapter5" },
			// 			{ "Checkpoint_Chapter5_SkyTrailEntrance", false, "Sky Trail Entrance", "Checkpoint_Chapter5_1" },
			// 			{ "Checkpoint_Chapter5_SkyTrailPlatforms", false, "Sky Trail Platforms", "Checkpoint_Chapter5_1" },
			// 			{ "Checkpoint_Chapter5_SkyTrail", false, "Sky Trail", "Checkpoint_Chapter5_1" },
			// 			{ "Checkpoint_Chapter5_SkyTrailTower", false, "Sky Trail Tower", "Checkpoint_Chapter5_1" },
			// 			{ "Checkpoint_Chapter5_SkyTrailTowerEnd", false, "Sky Trail Tower End", "Checkpoint_Chapter5_1" },
			// 			{ "Checkpoint_Chapter5_PillarofAsh", false, "Pillar of Ash", "Checkpoint_Chapter5_1" },

			// 		{ "Checkpoint_Chapter5_2", true, "One Last Job", "Checkpoint_Chapter5" },
			// 			{ "Checkpoint_Chapter5_PillarEntrance", false, "Pillar Entrance", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_RocketLauncher", false, "Rocket Launcher", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_RocketLauncherTutorialEnd", false, "Rocket Launcher Tutorial End", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_BeforeRocketEnemyTutorial", false, "Before Rocket Enemy Tutorial", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_PillarArena", false, "Pillar Arena", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_PillarHardCombatSaved", false, "Pillar Hard Combat Saved", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_AfterPillarHardCombat", false, "After Pillar Hard Combat", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_MidwayUpPillar", false, "Midway Up Pillar", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_TopOfPillar", false, "Top Of Pillar", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_PillarPeakPuzzle", false, "Pillar Peak Puzzle", "Checkpoint_Chapter5_2" },
			// 			{ "Checkpoint_Chapter5_HangingTowers", false, "Hanging Towers", "Checkpoint_Chapter5_2" },

			// 		{ "Checkpoint_Chapter5_3", true, "The Hanging Towers", "Checkpoint_Chapter5" },
			// 			{ "Checkpoint_Chapter5_TowersRailStation", false, "Towers Rail Station", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_EndOfTowersRail", false, "End Of Towers Rail", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TowerDrop", false, "Tower Drop", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TowerDropBottom", false, "Tower Drop Bottom", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TowersArena_0", false, "Towers Arena", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_afterTowerArena", false, "After Tower Arena", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TowerClimb", false, "Tower Climb", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_WidowArena", false, "Widow Arena", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_afterWidowArena", false, "After Widow Arena", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_WidowWarden", false, "Widow Warden", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_WidowTutorialEnd", false, "Widow Tutorial End", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_WidowPlatformEnd", false, "Widow Platform End", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_WidowWalkways", false, "Widow Walkways", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TowersFinalPush_3", false, "Towers Final Push", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TopOfTower", false, "Top Of Tower", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_TowerExit", false, "Tower Exit", "Checkpoint_Chapter5_3" },
			// 			{ "Checkpoint_Chapter5_PathToChamber", false, "Path To Chamber", "Checkpoint_Chapter5_3" },

			// 		{ "Checkpoint_Chapter5_4", true, "Mani's Folly", "Checkpoint_Chapter5" },
			// 			{ "Checkpoint_Chapter5_SkyChamberReveal", false, "Sky Chamber Reveal", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_SkyChamber", false, "Sky Chamber", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_ChamberTowerBottom", false, "Chamber Tower Bottom", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_ChamberTowerQuarter", false, "Chamber Tower Quarter", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_ChamberTowerMidpoint2", false, "Chamber Tower Midpoint 2", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_SkyChamberPeak_1", false, "Sky Chamber Peak", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_ChamberRailStation", false, "Chamber Rail Station", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_SkyReactorEntrance", false, "Sky Reactor Entrance", "Checkpoint_Chapter5_4" },
			// 			{ "Checkpoint_Chapter5_SkyReactor", false, "Sky Reactor", "Checkpoint_Chapter5_4" },

			// 		{ "Checkpoint_Chapter5_5", true, "Mani the Betrayer", "Checkpoint_Chapter5" },
			// 			{ "Checkpoint_Chapter5_SkyBoss", false, "Sky Boss", "Checkpoint_Chapter5_5" },
			// 			{ "Checkpoint_Chapter5_postSkyBoss", false, "Post Sky Boss", "Checkpoint_Chapter5_5" },
			// 			{ "Checkpoint_Chapter5_ReturntoSteps", false, "Return to Steps", "Checkpoint_Chapter5_5" },

			// 	{ "Checkpoint_Chapter6", true, "Chapter 6", "CheckpointSplits" },
			// 		{ "Checkpoint_Chapter6_1", true, "The Womb of Silence", "Checkpoint_Chapter6" },
			// 			{ "Checkpoint_Chapter6_TheWomb", false, "The Womb", "Checkpoint_Chapter6_1" },
			// 			{ "Checkpoint_Chapter6_AfterAtticusBoss", false, "After Atticus Boss", "Checkpoint_Chapter6_1" },
			// 			{ "Checkpoint_Chapter6_EndGameFinalDialogueFinished", false, "Final Dialogue Finished", "Checkpoint_Chapter6_1" },
													
	};
	
	vars.Uhara.Settings.Create(_settings);
}

init
{
	string exeDir = Path.GetDirectoryName(game.MainModule.FileName);
	string pakPath = Path.GetFullPath(Path.Combine(exeDir, "..", "..", "Content", "Paks", "LunaAbyss-WindowsNoEditor.pak"));
	vars.Uhara.Log("Pak path: " + pakPath);

	if (File.Exists(pakPath))
	{
		long pakSize = new FileInfo(pakPath).Length;
		vars.Uhara.Log("Pak size: " + pakSize);

		if (pakSize < 5000000000L)
			version = "Demo";
		else
			version = "Full Game";
		}
	else
	{
		vars.Uhara.Log("Pak not found: " + pakPath);
		version = "Full Game";
	}

	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

	vars.Resolver.Watch<int>("GSync", vars.Utils.GSync);
	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Resolver.Watch<bool>("isInGame", vars.Utils.GEngine, 0xD28, 0x648);
	if (version == "Demo")
	{
		vars.Resolver.Watch<IntPtr>("OpenWidgets", vars.Utils.GEngine, 0xD28, 0x528, 0x240);
		vars.Resolver.Watch<int>("OpenedWidgetsCount", vars.Utils.GEngine, 0xD28, 0x528, 0x248);
	}
	else 
	{
		vars.Resolver.Watch<IntPtr>("OpenWidgets", vars.Utils.GEngine, 0xD28, 0x528, 0x248);
		vars.Resolver.Watch<int>("OpenedWidgetsCount", vars.Utils.GEngine, 0xD28, 0x528, 0x250);
	}
	vars.Resolver.WatchString("CheckpointName", vars.Utils.GEngine, 0xD28, 0x378, 0x0);
	vars.Resolver.Watch<bool>("isFadingToWidget", vars.Utils.GEngine, 0xD28, 0x570, 0x48);
	vars.Resolver.Watch<bool>("isFadingFromWidget", vars.Utils.GEngine, 0xD28, 0x570, 0x49);

	vars.Resolver.Watch<int>("DayNumber", vars.Utils.GEngine, 0xD28, 0x5EC);
	vars.Resolver.Watch<int>("StageID", vars.Utils.GEngine, 0xD28, 0x5F0);

	// Function Flags
	vars.Events.FunctionFlag("UrienRegretLatch", "CAN_Regret_ENEMY_C", "CAN_Regret_ENEMY_C", "ExecuteUbergraph_CAN_Regret_ENEMY");
	vars.Events.FunctionFlag("UrienRegretDialogComplete", "BP_CutsceneSequencer_Urien_Regret_C", "BP_CutsceneSequencer_Urien_Regret_C", "DialogComplete");	
	vars.Events.FunctionFlag("FMCutToBlack", "BP_FadeManager_C", "BP_FadeManager_C", "OnCutToBlack");
	vars.Events.FunctionFlag("StreamLoad", "WBP_StreamLoad_C", "WBP_StreamLoad_C", "PreConstruct");
	vars.Events.FunctionFlag("PostStreamLoad", "BP_PostStreamTrigger_C", "", "*PostStreamTrigger");
	vars.Events.FunctionFlag("PostStreamObjectives", "BP_ObjectiveManager_C", "BP_ObjectiveManager_C", "FindObjectiveMarkersInNewLevel");
	vars.Events.FunctionFlag("EndGameFinalDialogueFinished", "BP_MemoryOrb_Sadie_C", "BP_MemoryOrb_Sadie_C", "DialogPostMemoryComplete");

	// Demo Function Flags
	vars.Events.FunctionFlag("SorrowsCanyonStart", "CAN_Sorrow_GEO_C", "CAN_Sorrow_GEO_C", "Intro Complete");
	vars.Events.FunctionFlag("ScourgeCraterStart", "MED_Crater_GEO_C", "MED_Crater_GEO_C", "OpeningCutsceneComplete");
	vars.Events.FunctionFlag("EndOfDemoSorrow", "CAN_Sorrow_GEO_C", "CAN_Sorrow_GEO_C", "End of Demo Event"); // removed?
	vars.Events.FunctionFlag("EndOfDemoScourge", "MED_Crater_GEO_C", "MED_Crater_GEO_C", "End of Demo Event"); // removed?
	vars.Events.FunctionFlag("DemoEnd", "WBP_Demo_EndSlate_C", "WBP_Demo_EndSlate_C", "");

	vars.Loading = false;
	vars.ILStartArmed = false;
	vars.DemoEndTriggered = false;
	vars.DemoRoute = "";
	vars.IgnoreNextCutToBlack = false;
	current.CheckpointName = "";
	current.Loading = false;
	current.IsILConfirmScreen = false;
	current.OpenWidgets = IntPtr.Zero;
	current.OpenedWidgets = "";
	current.ActiveDialogID = "";
	current.DayAndStageID = "";
	current.World = "";
}

update
{
	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

	// Chapter Splitting Setup - Day and Stage ID
	if (old.DayNumber != current.DayNumber || old.StageID != current.StageID)
	{
		current.DayAndStageID = "D" + current.DayNumber + "StgID" + current.StageID;
		vars.Uhara.Log("DayAndStageID: " + current.DayAndStageID);
	}

	// Open Widgets
	current.ActiveDialogID = "";
	current.OpenedWidgets = "";
	current.IsILConfirmScreen = false;

	// Detecting Dialog ID and current Open Widgets
	if (current.OpenWidgets != IntPtr.Zero && current.OpenedWidgetsCount > 0 && current.World == "Abyss_PERSISTENT")
	{
		for (int i = 0; i < current.OpenedWidgetsCount; i++)
		{
			var widgetPtr = vars.Resolver.Read<IntPtr>(current.OpenWidgets + i * 0x8);
			if (widgetPtr == IntPtr.Zero) continue;

			var classFName = vars.Resolver.Read<uint>(widgetPtr + 0x18);
			var className = vars.Utils.FNameToString(classFName);

			if (string.IsNullOrEmpty(className) || className == "None") continue;

			if (string.IsNullOrEmpty(current.OpenedWidgets)) current.OpenedWidgets = className;
			else current.OpenedWidgets += ", " + className;

			if (className == "WBP_Dialog_C" && string.IsNullOrEmpty(current.ActiveDialogID))
				current.ActiveDialogID = vars.Resolver.ReadString(widgetPtr + 0x3F8, 0x230, 0x0) ?? "";
		}
	}

	// IL Confirm Screen
	current.IsILConfirmScreen = current.OpenedWidgets.Contains("WBP_OverlayMessage_C") &&
								current.OpenedWidgets.Contains("WBP_LevelSelect_C") &&
								current.OpenedWidgets.Contains("WBP_VS_Pause_C");

	if (!old.IsILConfirmScreen && current.IsILConfirmScreen)
	{
		vars.ILStartArmed = true;
		vars.Uhara.Log("IL Start Armed");
	}

	// Loading Block
	if (current.DayAndStageID == "D2StgID2" && current.CheckpointName == "PlacentalSteps" && vars.Resolver.CheckFlag("UrienRegretLatch")) vars.IgnoreNextCutToBlack = true;

	if (vars.Resolver.CheckFlag("FMCutToBlack"))
	{
		if (!(current.DayAndStageID == "D2StgID2" && current.CheckpointName == "PlacentalSteps" && vars.IgnoreNextCutToBlack)) vars.Loading = true;
	}

	if (current.DayAndStageID == "D2StgID2" && current.CheckpointName == "PlacentalSteps" && vars.Resolver.CheckFlag("UrienRegretDialogComplete")) vars.IgnoreNextCutToBlack = false;

	if (current.isFadingToWidget) vars.Loading = true;
	if (current.isFadingFromWidget) vars.Loading = false;
	if (vars.Resolver.CheckFlag("StreamLoad")) vars.Loading = true;
	if (vars.Resolver.CheckFlag("PostStreamLoad")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("PostStreamObjectives")) vars.Loading = false;

	current.Loading = vars.Loading;

	// Safety reset for IL arming
	if (!current.isInGame && !current.IsILConfirmScreen) vars.ILStartArmed = false;

	// Logs
	if (old.OpenedWidgetsCount != current.OpenedWidgetsCount) vars.Uhara.Log("OpenedWidgetsCount: " + current.OpenedWidgetsCount);
	if (old.OpenedWidgets != current.OpenedWidgets) vars.Uhara.Log("OpenedWidgets: " + current.OpenedWidgets);
	if (old.ActiveDialogID != current.ActiveDialogID) vars.Uhara.Log("ActiveDialogID: " + current.ActiveDialogID);
	if (old.CheckpointName != current.CheckpointName) vars.Uhara.Log("Checkpoint Name: " + current.CheckpointName);
}

start
{
	// Demo Starts
	if (settings["Demo"])
	{ 
		if (vars.Resolver.CheckFlag("SorrowsCanyonStart"))
		{
			vars.DemoRoute = "Sorrows";
			return true;
		}

		if (vars.Resolver.CheckFlag("ScourgeCraterStart"))
		{
			vars.DemoRoute = "Scourge";
			return true;
		}
	}

	// Individual Level Start
	if (settings["ILStart"])
	{
		return vars.ILStartArmed && old.Loading && !current.Loading;
	} // Full Game Start
	else if (settings["FullGame"])
	{
		return current.isInGame && old.ActiveDialogID != "CELL-2-1-0" && current.ActiveDialogID == "CELL-2-1-0";
	}
}

onStart
{
	vars.ILStartArmed = false;
	vars.DemoEndTriggered = false;
}

split
{
	if (old.DayAndStageID != current.DayAndStageID && settings.ContainsKey(current.DayAndStageID) && !vars.CompletedSplits.Contains(current.DayAndStageID))
	{
		vars.CompletedSplits.Add(current.DayAndStageID);
		return settings[current.DayAndStageID];
	}

	if (old.CheckpointName != current.CheckpointName && settings.ContainsKey(current.CheckpointName) && !vars.CompletedSplits.Contains(current.CheckpointName))
	{
		vars.CompletedSplits.Add(current.CheckpointName);
		vars.Uhara.Log("Checkpoint Split: " + current.CheckpointName);
		return settings[current.CheckpointName];
	}

	// Full Game End Split
	if (vars.Resolver.CheckFlag("EndGameFinalDialogueFinished") && settings.ContainsKey("EndGameFinalDialogue") && !vars.CompletedSplits.Contains("EndGameFinalDialogue"))
	{
		vars.CompletedSplits.Add("EndGameFinalDialogue");
		return settings["EndGameFinalDialogue"];
	}

	
	// Demo End Splits
	if (!vars.DemoEndTriggered && vars.Resolver.CheckFlag("DemoEnd"))
	{
		vars.DemoEndTriggered = true;

		if (vars.DemoRoute == "Sorrows" && settings.ContainsKey("SorrowsCanyonEnd"))
		{
			vars.CompletedSplits.Add("SorrowsCanyonEnd");
			return settings["SorrowsCanyonEnd"];
		}

		if (vars.DemoRoute == "Scourge" && settings.ContainsKey("ScourgeCraterEnd"))
		{
			vars.CompletedSplits.Add("ScourgeCraterEnd");
			return settings["ScourgeCraterEnd"];
		}
	}
}

isLoading
{
	return vars.Loading || current.GSync != 0 || current.World == "MainMenuMap";
}

onReset
{
	vars.CompletedSplits.Clear();
	vars.DemoEndTriggered = false;
	vars.ILStartArmed = false;
}