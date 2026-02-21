state("REANIMAL"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.Settings.CreateFromXml("Components/REANIMAL.Splits.xml");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Resolver.Watch<bool>("TransitionType", vars.Utils.GEngine, 0xBBB);
	vars.Resolver.Watch<float>("CameraDepth", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x3AC);
	vars.Resolver.WatchString("SavedCheckpointPlayerStart", vars.Utils.GEngine, 0x10A8, 0x250, 0x20, 0x0);
	vars.Resolver.Watch<uint>("SavedCheckpointAssetPathName", vars.Utils.GEngine, 0x10A8, 0x250, 0x18);
	vars.Resolver.Watch<uint>("CheckpointFName", vars.Events.FunctionParentPtr("BP_CheckpointVolume_C", "", "OnBeginTriggerOverlap"), 0x18);
	
	// Death Handler
	vars.Events.FunctionFlag("DeathHandlerPhase1", "DeathHandler_*", "DeathHandler_*", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("DeathHandlerPhase2", "DeathHandler_*", "DeathHandler_*", "OnActorDied");
	vars.Events.FunctionFlag("PlayerDeathHandlerPhase1", "PlayerDeathHandler_*", "PlayerDeathHandler_*", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("PlayerDeathHandlerPhase2", "PlayerDeathHandler_*", "PlayerDeathHandler_*", "OnActorDied");
	vars.Events.FunctionFlag("SimpleRagdollPhase1", "DeathHandler_SimpleRagdoll_C", "DeathHandler_SimpleRagdoll_C", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("SimpleRagdollPhase2", "DeathHandler_SimpleRagdoll_C", "DeathHandler_SimpleRagdoll_C", "OnActorDied");

	// Return from Death
	vars.Events.FunctionFlag("FadeFromBlack", "BP_IngameGameMode_C", "BP_IngameGameMode_C", "K2_OnRestartPlayer");
	
	// IL Starting
	vars.Events.FunctionFlag("IntroCutscene", "SEQ_DeadLambAndGirl_Vinjette_01_DirectorBP_C", "SEQ_DeadLambAndGirl_Vinjette_01_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_DeadLambAndGirl_Vinjette_01_DirectorBP");
	vars.Events.FunctionFlag("CameraFadeIn", "BP_EverholmGameState_C", "BP_EverholmGameState_C", "CameraFadeIn__UpdateFunc");

	// IL Flags
	vars.Events.FunctionFlag("Chapter1IL", "BP_IceCreamTruckForest_C", "BP_IceCreamTruckForest_C", "ExecuteUbergraph_BP_IceCreamTruckForest");
	vars.Events.FunctionFlag("Chapter2IL", "SEQ_ForestRoad_SnifferEndingSuccess_DirectorBP_C", "SEQ_ForestRoad_SnifferEndingSuccess_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_ForestRoad_SnifferEndingSuccess_DirectorBP");
	vars.Events.FunctionFlag("Chapter3IL", "SEQ_WaitingOnBus_DirectorBP_C", "SEQ_WaitingOnBus_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_WaitingOnBus_DirectorBP");
	vars.Events.FunctionFlag("Chapter4IL", "PuzzleManager_Orphanage_Entrance_FoyerCombat_C", "PuzzleManager_Orphanage_Entrance_FoyerCombat_C", "HIP_HideCrownMesh");
	vars.Events.FunctionFlag("Chapter5IL", "LSEQ_DeadMotherTest_PukeCamera_2_DirectorBP_C", "LSEQ_DeadMotherTest_PukeCamera_2_DirectorBP_C", "SequenceEvent__ENTRYPOINTLSEQ_DeadMotherTest_PukeCamera_2_DirectorBP");
	vars.Events.FunctionFlag("Chapter6IL", "BP_Interaction_SetPiece_HoistPiggybackGirlThroughWindow_C", "BP_Interaction_SetPiece_HoistPiggybackGirlThroughWindow_C", "");
	vars.Events.FunctionFlag("Chapter7IL", "BP_Coop_Interaction_SqueezeGap_C", "BP_Coop_Interaction_SqueezeGap_C", "BndEvt__BP_Coop_Interaction_SqueezeGap_InteractionComponent_K2Node_ComponentBoundEvent_0_InteractionComponentEvent__DelegateSignature");
	vars.Events.FunctionFlag("Chapter7RunThroughTheDoor", "SEQ_RunThroughTheDoor_DirectorBP_C", "SEQ_RunThroughTheDoor_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_RunThroughTheDoor_DirectorBP");
	vars.Events.FunctionFlag("Chapter8IL", "BP_TankActor_C", "BP_TankActor_C", "BndEvt__BP_TankActor_PassengerInteraction_K2Node_ComponentBoundEvent_0_InteractionComponentEvent__DelegateSignature");

	// End Split
	vars.Events.FunctionFlag("RabbitEndSplit", "SEQ_AmbushStart_01_DirectorBP_C", "SEQ_AmbushStart_01_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_AmbushStart_01_DirectorBP");

	vars.Loading = false;
	vars.Chpt1ILIntro = false;
	vars.Chapter7ILSafeguard = false;
	current.World = "";
	vars.LastUpdatedWorld = "";
	current.CheckpointName = "";
	current.AssetPathName = "";
	current.ComboCheckpoint = "";
	vars.DeathPhase = 0;
}

start
{
	if (settings["ILSplitting"])
	{
		if (vars.Chpt1ILIntro)
			return current.CameraDepth < old.CameraDepth && old.CameraDepth > 1f &&
				current.World == "MLVL_EverholmWorld" && (vars.LastUpdatedWorld == "LVL_MainMenu" || vars.LastUpdatedWorld == "");
		else 
			return current.World == "MLVL_EverholmWorld" && vars.Resolver.CheckFlag("CameraFadeIn");
	}
	else 
		return current.CameraDepth < old.CameraDepth && old.CameraDepth > 1f &&
			current.World == "MLVL_EverholmWorld" && (vars.LastUpdatedWorld == "LVL_MainMenu" || vars.LastUpdatedWorld == "");
}

onStart
{
	vars.CompletedSplits.Clear();
	vars.LastUpdatedWorld = "X";
	vars.Chapter7ILSafeguard = false;
}

update
{
	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (current.World != old.World) vars.LastUpdatedWorld = old.World;

	var checkpointname = vars.Utils.FNameToString(current.CheckpointFName);
	if (!string.IsNullOrEmpty(checkpointname) && checkpointname != "None") current.CheckpointName = checkpointname;
	if (old.CheckpointName != current.CheckpointName) vars.Uhara.Log("Checkpoint: " + current.CheckpointName);

	var assetpath = vars.Utils.FNameToString(current.SavedCheckpointAssetPathName);
	if (!string.IsNullOrEmpty(assetpath) && assetpath != "None") current.AssetPathName = assetpath;

	if (old.AssetPathName != current.AssetPathName || old.SavedCheckpointPlayerStart != current.SavedCheckpointPlayerStart)
		current.ComboCheckpoint = current.AssetPathName + ":" + current.SavedCheckpointPlayerStart;

	if (vars.Resolver.CheckFlag("IntroCutscene")) vars.Chpt1ILIntro = true;
	
	if (vars.Resolver.CheckFlag("FadeFromBlack")) 
		{ vars.DeathPhase = 0; vars.Loading = false; }
	if (vars.DeathPhase == 0 && (vars.Resolver.CheckFlag("DeathHandlerPhase1") || vars.Resolver.CheckFlag("PlayerDeathHandlerPhase1")))
		vars.DeathPhase = 1;
	if (vars.DeathPhase == 1 && (vars.Resolver.CheckFlag("DeathHandlerPhase2") || vars.Resolver.CheckFlag("PlayerDeathHandlerPhase2")))
		{ vars.DeathPhase = 2; vars.Loading = true;
	}
	if (vars.Resolver.CheckFlag("SimpleRagdollPhase1") || vars.Resolver.CheckFlag("SimpleRagdollPhase2"))
		{ vars.DeathPhase = 0; vars.Loading = false; }

	if (vars.Resolver.CheckFlag("Chapter7RunThroughTheDoor") && !vars.Chapter7ILSafeguard)
	{
		vars.Chapter7ILSafeguard = true;
	}
}

split
{
	// Chapter Combo checkpoint splits (AssetPath:PlayerStart)
	if (old.AssetPathName != current.AssetPathName || old.SavedCheckpointPlayerStart != current.SavedCheckpointPlayerStart)
	{
		if (settings.ContainsKey(current.ComboCheckpoint) && settings[current.ComboCheckpoint] && !vars.CompletedSplits.Contains(current.ComboCheckpoint))
		{ vars.CompletedSplits.Add(current.ComboCheckpoint); return true; }
	}

	// CheckpointFName splits (BP_CheckpointVolume trigger)
	if (old.CheckpointName != current.CheckpointName && !string.IsNullOrEmpty(current.CheckpointName))
	{
		if (settings.ContainsKey(current.CheckpointName) && settings[current.CheckpointName] && !vars.CompletedSplits.Contains(current.CheckpointName))
		{ vars.CompletedSplits.Add(current.CheckpointName); return true; }
	}

	// Main Run End split
	if (vars.Resolver.CheckFlag("RabbitEndSplit"))
	{
		if (settings.ContainsKey("EndSplit") && settings["EndSplit"] && !vars.CompletedSplits.Contains("EndSplit"))
		{ vars.CompletedSplits.Add("EndSplit"); return true;}
	}

	// IL Splits
	if (vars.Resolver.CheckFlag("Chapter1IL") && settings.ContainsKey("ILChapter1") && settings["ILChapter1"] && !vars.CompletedSplits.Contains("ILChapter1")) 
		{ vars.CompletedSplits.Add("ILChapter1"); return true; }
	if (vars.Resolver.CheckFlag("Chapter2IL") && settings.ContainsKey("ILChapter2") && settings["ILChapter2"] && !vars.CompletedSplits.Contains("ILChapter2")) 
		{ vars.CompletedSplits.Add("ILChapter2"); return true; }
	if (vars.Resolver.CheckFlag("Chapter3IL") && settings.ContainsKey("ILChapter3") && settings["ILChapter3"] && !vars.CompletedSplits.Contains("ILChapter3")) 
		{ vars.CompletedSplits.Add("ILChapter3"); return true; }
	if (vars.Resolver.CheckFlag("Chapter4IL") && settings.ContainsKey("ILChapter4") && settings["ILChapter4"] && !vars.CompletedSplits.Contains("ILChapter4")) 
		{ vars.CompletedSplits.Add("ILChapter4"); return true; }
	if (vars.Resolver.CheckFlag("Chapter5IL") && settings.ContainsKey("ILChapter5") && settings["ILChapter5"] && !vars.CompletedSplits.Contains("ILChapter5")) 
		{ vars.CompletedSplits.Add("ILChapter5"); return true; }
	if (vars.Resolver.CheckFlag("Chapter6IL") && settings.ContainsKey("ILChapter6") && settings["ILChapter6"] 
		&& current.CheckpointName == "BP_CP_WarTown_BrokenBasement" && !vars.CompletedSplits.Contains("ILChapter6")) 
		{ vars.CompletedSplits.Add("ILChapter6"); return true; }
	if (vars.Resolver.CheckFlag("Chapter7IL") && settings.ContainsKey("ILChapter7") && settings["ILChapter7"] && vars.Chapter7ILSafeguard
		&& current.CheckpointName == "BP_CP_WarTown_HospitalSheepbeast" && !vars.CompletedSplits.Contains("ILChapter7")) 
		{ vars.CompletedSplits.Add("ILChapter7"); return true; }
	if (vars.Resolver.CheckFlag("Chapter8IL") && settings.ContainsKey("ILChapter8") && settings["ILChapter8"] && !vars.CompletedSplits.Contains("ILChapter8")) 
		{ vars.CompletedSplits.Add("ILChapter8"); return true; }
	if (vars.Resolver.CheckFlag("RabbitEndSplit") && settings.ContainsKey("ILChapter9") && settings["ILChapter9"] && !vars.CompletedSplits.Contains("ILChapter9")) 
		{ vars.CompletedSplits.Add("ILChapter9"); return true; }
}

isLoading
{
	return current.TransitionType || vars.Loading;
}

reset
{
	return settings.ContainsKey("AutoReset") && settings["AutoReset"]
		&& current.World != old.World && current.World == "LVL_MainMenu";
}

onReset
{
	vars.Chpt1ILIntro = false;
	vars.Chapter7ILSafeguard = false;
}

exit
{
	timer.IsGameTimePaused = true;
}