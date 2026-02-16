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

	vars.Events.FunctionFlag("DeathHandlerPhase1", "DeathHandler_*", "DeathHandler_*", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("DeathHandlerPhase2", "DeathHandler_*", "DeathHandler_*", "OnActorDied");
	vars.Events.FunctionFlag("PlayerDeathHandlerPhase1", "PlayerDeathHandler_*", "PlayerDeathHandler_*", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("PlayerDeathHandlerPhase2", "PlayerDeathHandler_*", "PlayerDeathHandler_*", "OnActorDied");
	// vars.Events.FunctionFlag("BoatSpawn", "BP_PlayersMontageOverride_C", "BP_PlayersMontageOverride_C", "HIP_Girl Play Montage");
	vars.Events.FunctionFlag("FadeFromBlack", "BP_IngameGameMode_C", "BP_IngameGameMode_C", "K2_OnRestartPlayer");
	vars.Events.FunctionFlag("RabbitEndSplit", "SEQ_AmbushStart_01_DirectorBP_C", "SEQ_AmbushStart_01_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_AmbushStart_01_DirectorBP");
	vars.Events.FunctionFlag("SimpleRagdollPhase1", "DeathHandler_SimpleRagdoll_C", "DeathHandler_SimpleRagdoll_C", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("SimpleRagdollPhase2", "DeathHandler_SimpleRagdoll_C", "DeathHandler_SimpleRagdoll_C", "OnActorDied");

	vars.Loading = false;
	current.World = "";
	vars.LastUpdatedWorld = "";
	current.CheckpointName = "";
	current.AssetPathName = "";
	current.ComboCheckpoint = "";
	vars.DeathPhase = 0;
}

start
{
	return current.CameraDepth < old.CameraDepth && old.CameraDepth > 1f &&
		current.World == "MLVL_EverholmWorld" && (vars.LastUpdatedWorld == "LVL_MainMenu" || vars.LastUpdatedWorld == "");
}

onStart
{
	vars.CompletedSplits.Clear();
	vars.LastUpdatedWorld = "X";
}

update
{
	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (current.World != old.World) vars.LastUpdatedWorld = old.World;

	var checkpointname = vars.Utils.FNameToString(current.CheckpointFName);
	if (!string.IsNullOrEmpty(checkpointname) && checkpointname != "None") current.CheckpointName = checkpointname;

	var assetpath = vars.Utils.FNameToString(current.SavedCheckpointAssetPathName);
	if (!string.IsNullOrEmpty(assetpath) && assetpath != "None") current.AssetPathName = assetpath;

	if (old.AssetPathName != current.AssetPathName || old.SavedCheckpointPlayerStart != current.SavedCheckpointPlayerStart)
		current.ComboCheckpoint = current.AssetPathName + ":" + current.SavedCheckpointPlayerStart;

	if (vars.Resolver.CheckFlag("FadeFromBlack")) 
	{
		vars.DeathPhase = 0;
		vars.Loading = false;
	}
	if (vars.DeathPhase == 0 && (vars.Resolver.CheckFlag("DeathHandlerPhase1") || vars.Resolver.CheckFlag("PlayerDeathHandlerPhase1")))
		vars.DeathPhase = 1;
	if (vars.DeathPhase == 1 && (vars.Resolver.CheckFlag("DeathHandlerPhase2") || vars.Resolver.CheckFlag("PlayerDeathHandlerPhase2")))
	{
		vars.DeathPhase = 2;
		vars.Loading = true;
	}
	if (vars.Resolver.CheckFlag("SimpleRagdollPhase1") || vars.Resolver.CheckFlag("SimpleRagdollPhase2"))
	{
		vars.DeathPhase = 0;
		vars.Loading = false;
	}
}

split
{
	// Chapter Combo checkpoint splits (AssetPath:PlayerStart)
	if (old.AssetPathName != current.AssetPathName || old.SavedCheckpointPlayerStart != current.SavedCheckpointPlayerStart)
	{
		if (settings.ContainsKey(current.ComboCheckpoint) && settings[current.ComboCheckpoint] && !vars.CompletedSplits.Contains(current.ComboCheckpoint))
		{
			vars.CompletedSplits.Add(current.ComboCheckpoint);
			return true;
		}
	}

	// CheckpointFName splits (BP_CheckpointVolume trigger)
	if (old.CheckpointName != current.CheckpointName && !string.IsNullOrEmpty(current.CheckpointName))
	{
		if (settings.ContainsKey(current.CheckpointName) && settings[current.CheckpointName] && !vars.CompletedSplits.Contains(current.CheckpointName))
		{
			vars.CompletedSplits.Add(current.CheckpointName);
			return true;
		}
	}

	// End split
	if (vars.Resolver.CheckFlag("RabbitEndSplit"))
	{
		if (settings.ContainsKey("EndSplit") && settings["EndSplit"] && !vars.CompletedSplits.Contains("EndSplit"))
		{
			vars.CompletedSplits.Add("EndSplit");
			return true;
		}
	}
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
