state("Subliminal-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Demo", true, "Demo", null },
			{ "DemoSplit", true, "Demo Credits Split", "Demo" },
		{ "FullGame", true, "Full Game", null },
			{ "Intro", true, "Intro", "FullGame" },
				{ "IntroSplit", true, "Enter Basement", "Intro" },
			{ "Basement", true , "Basement", null },
				{ "KnockKnock", false, "Knock Knock Completed", "Basement" },
				{ "WaterWorks1", true, "Enter Water Works", "Basement" },
			{ "WaterWorks", false, "Water Works", null },
				{ "WaterWorks2", false, "Enter Split Decision", "WaterWorks" },
				{ "DarkPath", false, "Dark Path", "WaterWorks" },
					{ "WaterWorks2ROT", false, "Enter Deep Storage", "DarkPath" },
					{ "DarkChildhoodMemories1", false, "Enter Childhood Memories (Dark)", "DarkPath"},
				{ "NormalPath", false, "Normal Path", "WaterWorks" },
					{ "WaterWorks3", false, "Enter Maintence Door", "WaterWorks" }, 
					{ "ChildhoodMemories3" , false, "Enter Childhood Memories (Normal)", "WaterWorks" },
			{ "ChildhoodMemories", false, "Childhood Memories", null },
				{ "DarkChildhoodMemories", false, "Dark Childhood Memories", "ChildhoodMemories" },
					{ "DarkChildhoodMemories2", false, "Enter Small Playplace", "DarkChildhoodMemories" },
					{ "DarkChildhoodMemories3", false, "Escape Smile Mini-Chase", "DarkChildhoodMemories" },
				{ "PlayplaceMainArea", true, "Enter Playplace Main Area", "ChildhoodMemories" },
				{ "PlayplaceMaintenceHalls", false, "Enter Playplace Maintence Halls", "ChildhoodMemories" },
				{ "Erase", false, "Erase Ending", "ChildhoodMemories" },
					{ "EraseIntro", false, "Enter Erase Ending Intro", "Erase" },
					{ "EraseEnding", false, "Erase Ending Split (Just Before Shutdown)", "Erase" },
				{ "ChildhoodMemories5", false, "Enter Memory Lane", "ChildhoodMemories" },
				{ "BounceHousePt1", false, "Enter Bounce House", "ChildhoodMemories" },
			{ "BounceHouse", false, "Bounce House", null },
				{ "BounceHouseRecollection", false, "Enter Recollection", "BounceHouse" },
				{ "BounceHousePt4", false, "Enter Memory Crack", "BounceHouse" },
			{ "EndSplit", false, "End Split (Rotten/Into The Pit/A Trip Down Memory Lane)", "FullGame" },
	};
	
	vars.CompletedSplits = new List<string>();
	vars.Uhara.Settings.Create(_settings);

	vars.DoSplit = (Func<string, bool, string, bool>)((flag, enabled, key) =>
	{
		if (!vars.Resolver.CheckFlag(flag)) return false;
		if (!enabled) return false;
		if (vars.CompletedSplits.Contains(key)) return false;

		vars.CompletedSplits.Add(key);
		return true;
	});
}

init
{
	string hash = vars.Uhara.GetHashRelative("..\\..\\Content\\Paks\\Subliminal-Windows.pak");
	vars.Uhara.Log("Hash is: " + hash);

	switch (hash)
	{
		case "8C9DA073AC171C0DAE471B6C853DEB34":
			version = "Demo v1.0 (31.10.25)";
			break;
		case "55C7D8D5222640C7A487B3BCC1F2B015":
			version = "Demo v1.0 (01.11.25)";
			break;
		case "5FCB38D4CA569D28AE83A50D0F1E8BA4":
			version = "Demo v1.0 (03.11.25 / 09:04:22)";
			break;
		case "36535E6318174642D6D11BA3CDACA27E":
			version = "Demo v1.0 (03.11.25 / 10:22:57)";
			break;
		case "F371E1BABA72024BD7312364FC1CD59D":
			version = "Demo v1.0 (03.11.25 / 10:47:55)";
			break;
		case "AE39B60205A5CD5A370A4A8EBFE76DDA":
			version = "Demo v1.2 (08.11.25)";
			break;
		case "BBFF9D02B91A9AC916C8EAF9F89B9FC9":
			version = "Demo v1.2.1 (19.11.25)";
			break;
		case "19073EC5686B10EB51C70E0BD6C65D7C":
			version = "Demo v1.3 (21.12.25)";
			break;
		case "0B362B31C7D04190F819EEE16655BD88":
			version = "Demo v1.3.5 (03.02.26)";
			break;
		case "24AEFCCFD08A01B61779648348DB60A1":
			version = "Demo v1.3.6 (10.02.26)";
			break;
		case "B1D193CEC1C9CBAB99404E7AE505D8D0":
			version = "Demo v1.3.7 (19.02.26)";
			break;
		case "1C76ED484191D7F281B466F0E4FAFEAB":
			version = "Demo v1.4 (07.03.26)";
			break;
		case "566DD1BE737C3AD8F0E807069DE5738A":
			version = "Demo v1.4.1 (23.03.26)";
			break;
		case "47F0AAA11466D2425DF50FC914FABEA6":
			version = "Demo v1.5.0 (31.03.26)";
			break;
		// Full Game
		case "2D6CD096F55F8236D567DCD3BB125F90":
			version = "Full Game v1.5";
			break;
		case "3144D6CC89DB3932F0E447E1657A15D3":
			version = "Full Game v1.5.1";
			break;
		default:
			version = "Full Game v1.5";
			break;
	}

	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	vars.Utils.ExpandScanUtilitySignatures("UObject_BeginDestroy", "40 53 48 83 EC 40 8B 41 08 48 8B D9 0F BA E0 0F 72");

	vars.Utils.GEngine = vars.Uhara.ScanRel(3, "48 89 05 ?? ?? ?? ?? E8 ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 72 ?? 48");
	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

	switch(version)
	{
		case "Demo v1.0 (31.10.25)":
		case "Demo v1.0 (01.11.25)":
		case "Demo v1.0 (03.11.25 / 09:04:22)":
		case "Demo v1.0 (03.11.25 / 10:22:57)":
		case "Demo v1.0 (03.11.25 / 10:47:55)":
		case "Demo v1.2 (08.11.25)":
		case "Demo v1.2.1 (19.11.25)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x90C);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x1248, 0x1D8, 0x948);
			break;
		case "Demo v1.3 (21.12.25)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x8B9);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x1248, 0x1D8, 0x8E0);
			break;
		case "Demo v1.3.5 (03.02.26)":
		case "Demo v1.3.6 (10.02.26)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x8B1);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x1248, 0x1D8, 0x8C1);
			break;
		case "Demo v1.3.7 (19.02.26)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x891);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x1248, 0x1D8, 0x8A1);
			break;
		case "Demo v1.4.0 (07.03.26)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x891);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x8A1);
			break;
		case "Demo v1.4.1 (23.03.26)":
		case "Demo v1.5.0 (31.03.26)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x8A1);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x8B1);
			break;
		case "Full Game v1.5":
		case "Full Game v1.5.1":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x8A1);
			vars.Resolver.Watch<bool>("IsAlive", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x8B1);
			vars.Resolver.Watch<bool>("Paused", vars.Utils.GEngine, 0x12C8, 0x1E0, 0xAD0);
			vars.Resolver.Watch<bool>("Loading", vars.Utils.GEngine, 0x12C8, 0x1E0, 0xFF9);
			vars.Resolver.Watch<int>("CurrentLevel", vars.Utils.GWorld, 0x30, 0xA0, 0xC0, 0x3C8);
			break;
	}

	if (version.Contains("Demo"))
	{
		vars.Events.FunctionFlag("EmptySpaceStart", "BP_EmptySpace_Intro_C", "BP_EmptySpace_Intro_C", "ExecuteUbergraph_BP_EmptySpace_Intro");
		vars.Events.FunctionFlag("EndCardTrigger", "BP_EndcardTrigger_SNF_C", "BP_EndcardTrigger_SNF_C", "ExecuteUbergraph_BP_EndcardTrigger_SNF");
		vars.Events.FunctionFlag("TitleScreenEnter", "BP_TitleScreen_NextFest_C", "BP_TitleScreen_C", "ExecuteUbergraph_BP_TitleScreen_NextFest");
	}
	else 
	{
		vars.Events.FunctionFlag("EmptySpaceStart", "BP_EmptySpace_Intro_C", "BP_EmptySpace_Intro_C", "ExecuteUbergraph_BP_EmptySpace_Intro");
		vars.Events.FunctionFlag("TitleScreenEnter", "BP_TitleScreen_C", "BP_TitleScreen_C", "ExecuteUbergraph_BP_TitleScreen");
		// Intro
		vars.Events.FunctionFlag("TransitionToBasement", "BP_EmptySpace_Intro_C", "BP_EmptySpace_Intro_C", "Start Transition");
		//Basement
		vars.Events.FunctionFlag("KnockKnockCompleted", "BP_BS_KnockKnockMaster_C", "BP_BS_KnockKnockMaster_C", "Completed Final");
		vars.Events.FunctionFlag("WaterWorks1Split", "BP_WWIntro_C", "BP_WWIntro_C", "ExecuteUbergraph_BP_WWIntro");
		// Waterworks
		vars.Events.FunctionFlag("WaterWorks2Split", "BP_WWPt2_Intro_C", "BP_WWSplitDecisionIntro_C", "ExecuteUbergraph_BP_WWPt2_Intro");
		vars.Events.FunctionFlag("WaterWorks2ROTSplit", "BP_WWPt2_ROTDecisionTrigger_C", "BP_WWPt2_ROTDecisionTrigger_C", "ExecuteUbergraph_BP_WWPt2_ROTDecisionTrigger");
		vars.Events.FunctionFlag("DarkChildhoodMemories1Split", "BP_CMDarkPt1Intro_C", "BP_CMDarkPt1Intro_C", "ExecuteUbergraph_BP_CMDarkPt1Intro");
		vars.Events.FunctionFlag("WaterWorks3Split", "BP_WWPt3Intro_C", "BP_WWMaintenanceDoorNarrationPt2Trigger_C", "ExecuteUbergraph_BP_WWPt3Intro");
		vars.Events.FunctionFlag("ChildhoodMemories3Split", "BP_CMPt3Intro_Light_C", "BP_CMPt3Intro_Light_C", "ExecuteUbergraph_BP_CMPt3Intro_Light");
		// Childhood Memories
		vars.Events.FunctionFlag("DarkChildhoodMemories2Split", "BP_CMDarkFloorIntro_C", "BP_CMDarkFloorIntro_C", "ExecuteUbergraph_BP_CMDarkFloorIntro");
		vars.Events.FunctionFlag("DarkChildhoodMemories3Split", "BP_CMSmileMiniChase_Master_C", "BP_CMSmileEating_C", "ExecuteUbergraph_BP_CMSmileMiniChase_Master");
		vars.Events.FunctionFlag("PlayplaceMainAreaSplit", "BP_PlayplaceMainAreaIntroTrigger_C", "BP_PlayplaceMainAreaIntroTrigger_C", "ExecuteUbergraph_BP_PlayplaceMainAreaIntroTrigger");
		vars.Events.FunctionFlag("PlayplaceMaintenanceHallsSplit", "BP_CM_BacktoWWMaintenanceHallTrigger_C", "BP_CM_BacktoWWMaintenanceHallTrigger_C", "ExecuteUbergraph_BP_CM_BacktoWWMaintenanceHallTrigger");
		vars.Events.FunctionFlag("EraseIntroTrigger", "BP_EraseIntroTrigger_C", "BP_EraseIntroTrigger_C", "ExecuteUbergraph_BP_EraseIntroTrigger");
		vars.Events.FunctionFlag("EraseEndingTrigger", "BP_EraseEnding_Master_C", "BP_EraseEnding_Master_C", "Full Erase");
		vars.Events.FunctionFlag("EraseEndingShutdown", "GameInstance_Main_C", "GameInstance_Main_C", "ReceiveShutdown");
		vars.Events.FunctionFlag("ChildhoodMemories5Split", "BP_CMPt5_Intro_C", "BP_CMPt5_Intro_C", "ExecuteUbergraph_BP_CMPt5_Intro");
		vars.Events.FunctionFlag("ChildhoodMemories5BackupSplit", "BP_CMPt5_Intro_C", "BP_CMPt5_Intro_C", "");
		// Bounce House
		vars.Events.FunctionFlag("BounceHousePt1Split", "BP_BHPt1_Intro_C", "BP_BHPt1_Intro_C", "ExecuteUbergraph_BP_BHPt1_Intro");
		vars.Events.FunctionFlag("BounceHouseRecollectionSplit", "BP_BHPt3_Intro_C", "BP_BHPt3_Intro_C", "");
		vars.Events.FunctionFlag("BounceHousePt4Split", "BP_BHPt4_MemoryCrackMaster_C", "BP_BHPt4_MemoryCrackMaster_C", "BndEvt__BP_BHPt4_MemoryCrackMaster_Collision_Unlock_K2Node_ComponentBoundEvent_2_ComponentBeginOverlapSignature__DelegateSignature");
		// End Credits
		vars.Events.FunctionFlag("CreditsSplit", "BP_Credits_C", "BP_Credits_C", "ExecuteUbergraph_BP_Credits");
	}
	current.CanMove = false;
	current.World = "";
	current.Loading = false;
	current.CurrentLevel = 0;
	vars.EraseEndingTrigger = false;
	vars.CreditsActive = false;
	vars.NewGameStart = false;
}

start
{
	if (vars.NewGameStart)
		return old.CanMove != current.CanMove && current.CanMove;

	if (version.Contains("Full Game") && !vars.NewGameStart)
    	return current.CanMove && old.Loading && !current.Loading;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.CreditsActive = false;
	vars.CompletedSplits.Clear();
}

update
{
	vars.Uhara.Update();

	if (vars.Resolver.CheckFlag("EmptySpaceStart")) vars.NewGameStart = true;
	if (vars.Resolver.CheckFlag("EraseEndingTrigger")) vars.EraseEndingTrigger = true;
	if (!vars.Resolver.CheckFlag("CreditsSplit")) vars.CreditsActive = true;
}

split
{
	// Demo
	if (vars.DoSplit("EndCardTrigger", settings["Demo"], "DemoSplit")) return true;

	// Full Game
	// Intro
	if (vars.DoSplit("TransitionToBasement", settings["Intro"], "IntroSplit")) return true;

	// Basement
	if (vars.DoSplit("KnockKnockCompleted", settings["KnockKnock"], "KnockKnock")) return true;
	if (vars.DoSplit("WaterWorks1Split", settings["WaterWorks1"], "WaterWorks1")) return true;

	// Water Works
	if (vars.DoSplit("WaterWorks2Split", settings["WaterWorks2"], "WaterWorks2")) return true;
	if (vars.DoSplit("WaterWorks2ROTSplit", settings["WaterWorks2ROT"], "WaterWorks2ROT")) return true;
	if (vars.DoSplit("DarkChildhoodMemories1Split", settings["DarkChildhoodMemories1"], "DarkChildhoodMemories1")) return true;
	if (vars.DoSplit("WaterWorks3Split", settings["WaterWorks3"], "WaterWorks3")) return true;
	if ((vars.Resolver.CheckFlag("ChildhoodMemories3Split") || current.CurrentLevel == 1) && settings["ChildhoodMemories3"] && !vars.CompletedSplits.Contains("ChildhoodMemories3")) 
	{
		vars.CompletedSplits.Add("ChildhoodMemories3");
		return true;
	}

	// Childhood Memories
	if (vars.DoSplit("DarkChildhoodMemories2Split", settings["DarkChildhoodMemories2"], "DarkChildhoodMemories2")) return true;
	if (vars.DoSplit("DarkChildhoodMemories3Split", settings["DarkChildhoodMemories3"], "DarkChildhoodMemories3")) return true;
	if (vars.DoSplit("PlayplaceMainAreaSplit", settings["PlayplaceMainArea"], "PlayplaceMainArea")) return true;
	if (vars.DoSplit("PlayplaceMaintenanceHallsSplit", settings["PlayplaceMaintenceHalls"], "PlayplaceMaintenceHalls")) return true;
	if (vars.DoSplit("EraseIntroTrigger", settings["EraseIntro"], "EraseIntro")) return true;
	if (vars.EraseEndingTrigger && vars.DoSplit("EraseEndingShutdown", settings["EraseEnding"], "EraseEnding")) return true;
	if (vars.DoSplit("ChildhoodMemories5Split", settings["ChildhoodMemories5"], "ChildhoodMemories5")) return true;
	if (vars.DoSplit("BounceHousePt1Split", settings["BounceHousePt1"], "BounceHousePt1")) return true;

	// Bounce House
	if (vars.DoSplit("BounceHouseRecollectionSplit", settings["BounceHouseRecollection"], "BounceHouseRecollection")) return true;
	if (vars.DoSplit("BounceHousePt4Split", settings["BounceHousePt4"], "BounceHousePt4")) return true;

	// End Split
	if (vars.CreditsActive && vars.DoSplit("CreditsSplit", settings["EndSplit"], "EndSplit")) 
	{
		vars.CreditsActive = false;
		return true;
	}
}

isLoading
{
	return current.Loading || !current.IsAlive;
}

onReset
{
	vars.NewGameStart = false;
	vars.CreditsActive = false;
	vars.CompletedSplits.Clear();
}

exit
{
	timer.IsGameTimePaused = true;
}