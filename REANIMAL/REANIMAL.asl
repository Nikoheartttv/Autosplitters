state("REANIMAL") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.Settings.CreateFromXml("Components/REANIMAL.Splits.xml");
    vars.Uhara.AlertLoadless();
    vars.CompletedSplits = new List<string>();
}

init
{
    vars.SpawnFadeDataFadeAmount = 0x750;
    string MD5Hash;
	using (var md5 = System.Security.Cryptography.MD5.Create())
	using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
	MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	print("Hash is: " + MD5Hash);
	
	switch(MD5Hash){
        case "32E8C699071E08366ECE8EBF63C64227": 
            version = "Steam (Version 356579)";
            vars.SpawnFadeDataFadeAmount = 0x700;
            break;
		default: 
            version = "Steam";
            vars.SpawnFadeDataFadeAmount = 0x750;
            break;
	}

    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

    vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<bool>("TransitionType", vars.Utils.GEngine, 0xBBB);
    vars.Resolver.Watch<float>("CameraDepth", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x3AC);
    vars.Resolver.WatchString("SavedCheckpointPlayerStart", vars.Utils.GEngine, 0x10A8, 0x250, 0x20, 0x0);
    vars.Resolver.Watch<uint>("SavedCheckpointAssetPathName", vars.Utils.GEngine, 0x10A8, 0x250, 0x18);
    vars.Resolver.Watch<uint>("CheckpointFName", vars.Events.FunctionParentPtr("BP_CheckpointVolume_C", "", "OnBeginTriggerOverlap"), 0x18);

    vars.Resolver.Watch<IntPtr>("PersistentActorsData", vars.Utils.GWorld, 0x30, 0xA0);
    vars.Resolver.Watch<int>("PersistentActorsNum", vars.Utils.GWorld, 0x30, 0xA8);
    vars.Resolver.Watch<IntPtr>("LevelsData", vars.Utils.GWorld, 0x88);
    vars.Resolver.Watch<int>("LevelsNum", vars.Utils.GWorld, 0x90);
    vars.Resolver.Watch<double>("SpawnFadeData_FadeAmount", vars.Utils.GWorld, 0x160, vars.SpawnFadeDataFadeAmount);

    vars.IsAllowedDeathHandler = (Func<string, bool>)(name =>
    {
        if (string.IsNullOrEmpty(name)) return false;
        if (name.Contains("BaseDeathEffects")) return false;

        return name.StartsWith("DeathHandler_") || name.StartsWith("PlayerDeathHandler_") || name.StartsWith("DLC_DeathHandler_");
    });

    vars.Events.FunctionFlag("IntroCutscene", "SEQ_DeadLambAndGirl_Vinjette_01_DirectorBP_C", "SEQ_DeadLambAndGirl_Vinjette_01_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_DeadLambAndGirl_Vinjette_01_DirectorBP");
    vars.Events.FunctionFlag("CameraFadeIn", "BP_EverholmGameState_C", "BP_EverholmGameState_C", "CameraFadeIn__UpdateFunc");
    vars.Events.FunctionFlag("Chapter1IL", "BP_IceCreamTruckForest_C", "BP_IceCreamTruck_C", "ExecuteUbergraph_BP_IceCreamTruckForest");
    vars.Events.FunctionFlag("Chapter2IL", "SEQ_ForestRoad_SnifferEndingSuccess_DirectorBP_C", "SEQ_ForestRoad_SnifferEndingSuccess_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_ForestRoad_SnifferEndingSuccess_DirectorBP");
    vars.Events.FunctionFlag("Chapter3IL", "SEQ_WaitingOnBus_DirectorBP_C", "SEQ_WaitingOnBus_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_WaitingOnBus_DirectorBP");
    vars.Events.FunctionFlag("Chapter4IL", "PuzzleManager_Orphanage_Entrance_FoyerCombat_C", "PuzzleManager_Orphanage_Entrance_FoyerCombat_C", "HIP_HideCrownMesh");
    vars.Events.FunctionFlag("Chapter5IL", "BP_MilitaryTruckKids_C", "BP_MilitaryTruckBandage_C", "CE_HoistPlayerInteract*");
    vars.Events.FunctionFlag("Chapter6IL", "BP_Interaction_SetPiece_HoistPiggybackGirlThroughWindow_C", "BP_Interaction_SetPiece_HoistPlayerInteract*ThroughWindow_C", "");
    vars.Events.FunctionFlag("Chapter7IL", "BP_Coop_Interaction_SqueezeGap_C", "BP_Coop_Interaction_SqueezeGap_C", "BndEvt__BP_Coop_Interaction_SqueezeGap_InteractionComponent_K2Node_ComponentBoundEvent_0_InteractionComponentEvent__DelegateSignature");
    vars.Events.FunctionFlag("Chapter7RunThroughTheDoor", "SEQ_RunThroughTheDoor_DirectorBP_C", "SEQ_RunThroughTheDoor_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_RunThroughTheDoor_DirectorBP");
    vars.Events.FunctionFlag("Chapter8IL", "BP_TankActor_C", "BP_TankActor_C", "BndEvt__BP_TankActor_PassengerInteraction_K2Node_ComponentBoundEvent_0_InteractionComponentEvent__DelegateSignature");
    vars.Events.FunctionFlag("RabbitEndSplit", "SEQ_AmbushStart_01_DirectorBP_C", "SEQ_AmbushStart_01_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_AmbushStart_01_DirectorBP");
    vars.Events.FunctionFlag("DLCPrisonerStart", "SEQ_IntroInsidePlaneStart_02_DirectorBP_C", "SEQ_IntroInsidePlaneStart_02_DirectorBP_C", "ExecuteUbergraph_SEQ_IntroInsidePlaneStart_02_DirectorBP");
    vars.Events.FunctionFlag("DLCPrisonerEnd", "BP_DLCMother_BikeChase_01_C", "BP_DLCMother_BikeChase_01_C", "HIP_Chase End");
    vars.Events.FunctionFlag("TeleportPlayers", "BP_TeleportPlayers_SIG_C", "BP_TeleportPlayers_SIG_C", "HIP_TeleportPlayers");
    vars.Events.FunctionFlag("TeleportPlayersFinished", "BP_TeleportPlayers_SIG_C", "BP_TeleportPlayers_SIG_C", "OnTeleportFinished");

    vars.Loading = false;
    vars.Chpt1ILIntro = false;
    vars.Chapter7ILSafeguard = false;
    vars.Chapter7Split = false;
    vars.Chapter8ILSafeguard = false;
    vars.LastUpdatedWorld = "";

    current.World = "";
    current.CheckpointName = "";
    current.AssetPathName = "";
    current.ComboCheckpoint = "";
    current.ActorIsDead = false;
    current.DyingEverholmCharacter = IntPtr.Zero;
    current.SimpleRagdollCharacterName = "";
    current.bInFlames = false;
    current.InFlamesCounter = 0;
    current.RequiredTimeInFireBeforeDeath = 0;

    vars.DeathHandlerPtr = IntPtr.Zero;
    vars.DeathHandlerName = "";
    vars.DeathHandlerSource = "";
    vars.DeathHandlerLevel = "";

    vars.StreamedLoadedLevel = IntPtr.Zero;
    vars.StreamedActorsData = IntPtr.Zero;
    vars.StreamedActorsNum = -1;
    vars.LevelsDataLast = IntPtr.Zero;
    vars.LevelsNumLast = -1;

    vars.FNameToString = (Func<ulong, string>)(fName =>
    {
        int nameIdx = (int)(fName & 0xFFFF);
        int chunkIdx = (int)((fName >> 16) & 0xFFFF);
        ulong number = fName >> 32;

        IntPtr chunk = vars.Resolver.Read<IntPtr>(vars.Utils.FNames + 0x10 + chunkIdx * 0x8);
        IntPtr entry = chunk + nameIdx * sizeof(short);
        int length = vars.Resolver.Read<short>(entry) >> 6;
        string name = vars.Resolver.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

        return number == 0 ? name : name + "_" + number;
    });

    vars.GetName = (Func<IntPtr, string>)(ptr =>
    {
        if (ptr == IntPtr.Zero) return "";
        return vars.FNameToString(vars.Resolver.Read<ulong>(ptr + 0x18));
    });

    vars.ScanActors = (Func<IntPtr, int, string, bool, bool>)((actorsData, actorsNum, levelName, isPersistent) =>
    {
        if (actorsData == IntPtr.Zero || actorsNum <= 0 || actorsNum > 300) return false;

        bool found = false;

        try
        {
            for (int i = 0; i < actorsNum; i++)
            {
                IntPtr actorPtr = vars.Resolver.Read<IntPtr>(actorsData + i * 0x8);
                if (actorPtr == IntPtr.Zero) continue;

                string actorName = vars.GetName(actorPtr);
                if (string.IsNullOrEmpty(actorName)) continue;
                if (!vars.IsAllowedDeathHandler(actorName)) continue;

                found = true;

                if (vars.DeathHandlerPtr == IntPtr.Zero)
                {
                    vars.DeathHandlerPtr = actorPtr;
                    vars.DeathHandlerName = actorName;
                    vars.DeathHandlerSource = isPersistent ? "PersistentLevel" : "StreamedLevel";
                    vars.DeathHandlerLevel = isPersistent ? "" : levelName;
                }
            }
        }
        catch {}

        return found;
    });

    vars.ResolveStreamedLevel = (Func<bool>)(() =>
    {
        if (current.LevelsData == IntPtr.Zero || current.LevelsNum <= 0 || current.LevelsNum > 300)
            return false;

        int count = Math.Min(current.LevelsNum, 300);

        for (int i = 0; i < count; i++)
        {
            try
            {
                IntPtr entry = vars.Resolver.Read<IntPtr>(current.LevelsData + i * 0x8);
                if (entry == IntPtr.Zero) continue;

                IntPtr loadedLevel = vars.Resolver.Read<IntPtr>(entry + 0x158);
                if (loadedLevel == IntPtr.Zero) continue;

                IntPtr outerWorld = vars.Resolver.Read<IntPtr>(loadedLevel + 0x20);
                if (outerWorld == IntPtr.Zero) continue;

                string levelName = vars.FNameToString(vars.Resolver.Read<ulong>(outerWorld + 0x18));
                if (levelName != "SLVL_WorldBoat") continue;

                // Always update the cached pointer if it differs
                if (vars.StreamedLoadedLevel != loadedLevel)
                {
                    vars.StreamedLoadedLevel = loadedLevel;
                    vars.StreamedActorsData = IntPtr.Zero;
                    vars.StreamedActorsNum = -1;
                }

                return true;
            }
            catch {}
        }

        vars.StreamedLoadedLevel = IntPtr.Zero;
        vars.StreamedActorsData = IntPtr.Zero;
        vars.StreamedActorsNum = -1;
        return false;
    });

    vars.ScanStreamedActors = (Func<bool>)(() =>
    {
        if (vars.StreamedLoadedLevel == IntPtr.Zero) return false;

        IntPtr actorsData = vars.Resolver.Read<IntPtr>(vars.StreamedLoadedLevel + 0xA0);
        int actorsNum = vars.Resolver.Read<int>(vars.StreamedLoadedLevel + 0xA8);

        if (actorsData == IntPtr.Zero || actorsNum <= 0 || actorsNum > 300) return false;

        // No "if unchanged, return false" here
        vars.StreamedActorsData = actorsData;
        vars.StreamedActorsNum = actorsNum;

        return vars.ScanActors(actorsData, actorsNum, "SLVL_WorldBoat", false);
    });
}

start
{
    if (settings["ILSplitting"])
    {
        if (vars.Chpt1ILIntro) return current.CameraDepth < old.CameraDepth && old.CameraDepth > 1f && 
            current.World == "MLVL_EverholmWorld" && (vars.LastUpdatedWorld == "LVL_MainMenu" || vars.LastUpdatedWorld == "");

        return current.World == "MLVL_EverholmWorld" && vars.Resolver.CheckFlag("CameraFadeIn");
    }

    return (current.CameraDepth < old.CameraDepth && old.CameraDepth > 1f && current.World == "MLVL_EverholmWorld" 
        && (vars.LastUpdatedWorld == "LVL_MainMenu" || vars.LastUpdatedWorld == "")) ||
        (vars.Resolver.CheckFlag("DLCPrisonerStart") && current.World == "LVL_DLC_Caves");
}

onStart
{
    vars.CompletedSplits.Clear();
    vars.LastUpdatedWorld = "X";
    vars.Chapter7ILSafeguard = false;
    vars.Chapter8ILSafeguard = false;
    vars.Chapter7Split = false;

    vars.DeathHandlerPtr = IntPtr.Zero;
    vars.DeathHandlerName = "";
    vars.DeathHandlerSource = "";
    vars.DeathHandlerLevel = "";

    vars.StreamedLoadedLevel = IntPtr.Zero;
    vars.StreamedActorsData = IntPtr.Zero;
    vars.StreamedActorsNum = -1;
    vars.LevelsDataLast = IntPtr.Zero;
    vars.LevelsNumLast = -1;
    vars.Loading = false;
}

update
{
    vars.Uhara.Update();

    var world = vars.Utils.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

    if (current.World != old.World)
    {
        vars.LastUpdatedWorld = old.World;
        vars.DeathHandlerPtr = IntPtr.Zero;
        vars.DeathHandlerName = "";
        vars.DeathHandlerSource = "";
        vars.DeathHandlerLevel = "";

        vars.StreamedLoadedLevel = IntPtr.Zero;
        vars.StreamedActorsData = IntPtr.Zero;
        vars.StreamedActorsNum = -1;
        vars.LevelsDataLast = IntPtr.Zero;
        vars.LevelsNumLast = -1;
        vars.Loading = false;
        vars.Uhara.Log("World: " + current.World);
    }

    var checkpointName = vars.Utils.FNameToString(current.CheckpointFName);
    if (!string.IsNullOrEmpty(checkpointName) && checkpointName != "None") current.CheckpointName = checkpointName;
    if (old.CheckpointName != current.CheckpointName) vars.Uhara.Log("Checkpoint: " + current.CheckpointName);

    var assetPath = vars.Utils.FNameToString(current.SavedCheckpointAssetPathName);
    if (!string.IsNullOrEmpty(assetPath) && assetPath != "None") current.AssetPathName = assetPath;

    if (old.AssetPathName != current.AssetPathName || old.SavedCheckpointPlayerStart != current.SavedCheckpointPlayerStart)
        current.ComboCheckpoint = current.AssetPathName + ":" + current.SavedCheckpointPlayerStart;

    if (old.SpawnFadeData_FadeAmount > 1 && current.SpawnFadeData_FadeAmount < 1)
    {
        vars.DeathHandlerPtr = IntPtr.Zero;
        vars.DeathHandlerName = "";
        vars.DeathHandlerSource = "";
        vars.DeathHandlerLevel = "";

        current.ActorIsDead = false;
        current.DyingEverholmCharacter = IntPtr.Zero;
        current.SimpleRagdollCharacterName = "";
        current.bInFlames = false;
        current.InFlamesCounter = 0;
        current.RequiredTimeInFireBeforeDeath = 0;
        vars.Loading = false;
        vars.Uhara.Log("Loading: False");
    }

    if (vars.DeathHandlerPtr == IntPtr.Zero && current.PersistentActorsData != IntPtr.Zero && current.PersistentActorsNum > 0 && (current.PersistentActorsData != old.PersistentActorsData || current.PersistentActorsNum != old.PersistentActorsNum))
        vars.ScanActors(current.PersistentActorsData, current.PersistentActorsNum, "PersistentLevel", true);

    if (vars.DeathHandlerPtr == IntPtr.Zero && (current.LevelsData != vars.LevelsDataLast || current.LevelsNum != vars.LevelsNumLast))
    {
        vars.LevelsDataLast = current.LevelsData;
        vars.LevelsNumLast = current.LevelsNum;
        vars.ResolveStreamedLevel();
    }

    if (vars.DeathHandlerPtr == IntPtr.Zero)
    {
        vars.ResolveStreamedLevel();
        vars.ScanStreamedActors();
    }

    if (vars.DeathHandlerPtr != IntPtr.Zero)
    {
        try
        {
            string handlerName = vars.GetName(vars.DeathHandlerPtr);
            bool allowed = vars.IsAllowedDeathHandler(handlerName);

            if (!allowed)
            {
                vars.DeathHandlerPtr = IntPtr.Zero;
                vars.DeathHandlerName = "";
                vars.DeathHandlerSource = "";
                vars.DeathHandlerLevel = "";
            }
            else
            {
                vars.DeathHandlerName = handlerName;
                current.ActorIsDead = vars.Resolver.Read<bool>(vars.DeathHandlerPtr + 0x2D0);
                current.DyingEverholmCharacter = vars.Resolver.Read<IntPtr>(vars.DeathHandlerPtr + 0x340);

                current.bInFlames = false;
                current.InFlamesCounter = 0;
                current.RequiredTimeInFireBeforeDeath = 0;

                if (handlerName.StartsWith("DeathHandler_SimpleRagdoll") && current.DyingEverholmCharacter != IntPtr.Zero)
                {
                    current.SimpleRagdollCharacterName = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.DyingEverholmCharacter + 0x18));

                    if (current.SimpleRagdollCharacterName.StartsWith("BP_CrawlingSoldier"))
                    {
                        current.ActorIsDead = false;
                        current.DyingEverholmCharacter = IntPtr.Zero;
                        current.SimpleRagdollCharacterName = "";

                        vars.DeathHandlerPtr = IntPtr.Zero;
                        vars.DeathHandlerName = "";
                        vars.DeathHandlerSource = "";
                        vars.DeathHandlerLevel = "";
                    }
                }

                if (vars.DeathHandlerPtr != IntPtr.Zero && handlerName.StartsWith("DeathHandler_Fire") && current.DyingEverholmCharacter != IntPtr.Zero)
                {
                    current.bInFlames = vars.Resolver.Read<bool>(current.DyingEverholmCharacter + 0xB70, 0xB0);
                    current.InFlamesCounter = vars.Resolver.Read<double>(current.DyingEverholmCharacter + 0xB70, 0xC0);
                    current.RequiredTimeInFireBeforeDeath = vars.Resolver.Read<double>(current.DyingEverholmCharacter + 0xB70, 0xC8);
                }

                if (vars.DeathHandlerPtr != IntPtr.Zero)
                {
                    bool deathLoad = current.ActorIsDead || (handlerName.StartsWith("DeathHandler_Fire") && current.bInFlames && current.InFlamesCounter >= current.RequiredTimeInFireBeforeDeath);

                    if (deathLoad && !vars.Loading)
                    {
                        vars.Loading = true;
                        vars.Uhara.Log("Loading | Handler='" + handlerName + "' | Source='" + vars.DeathHandlerSource + "' | ActorIsDead=" + current.ActorIsDead + " | bInFlames=" + current.bInFlames);
                    }
                }
            }
        }
        catch
        {
            vars.DeathHandlerPtr = IntPtr.Zero;
            vars.DeathHandlerName = "";
            vars.DeathHandlerSource = "";
            vars.DeathHandlerLevel = "";
        }
    }

    if (vars.Resolver.CheckFlag("TeleportPlayers") && !vars.Loading)
    {
        vars.Loading = true;
        vars.Uhara.Log("Loading: True (Teleporting)");
    }

    if (vars.Resolver.CheckFlag("TeleportPlayersFinished"))
    {
        vars.DeathHandlerPtr = IntPtr.Zero;
        vars.DeathHandlerName = "";
        vars.DeathHandlerSource = "";
        vars.DeathHandlerLevel = "";
        vars.Loading = false;
        vars.Uhara.Log("Loading: False (Teleporting)");
    }

    if (vars.Resolver.CheckFlag("IntroCutscene")) vars.Chpt1ILIntro = true;

    if (vars.Resolver.CheckFlag("Chapter7RunThroughTheDoor") && !vars.Chapter7ILSafeguard) vars.Chapter7ILSafeguard = true;

    if (vars.Resolver.CheckFlag("Chapter7IL") && vars.Chapter7ILSafeguard) vars.Chapter7Split = true;

    if (old.CheckpointName != current.CheckpointName && current.CheckpointName == "BP_CP_WarTown_SheepbeastClimbsHouse") vars.Chapter8ILSafeguard = true;
}

split
{
    if (old.AssetPathName != current.AssetPathName || old.SavedCheckpointPlayerStart != current.SavedCheckpointPlayerStart)
    {
        if (settings.ContainsKey(current.ComboCheckpoint) && settings[current.ComboCheckpoint] && !vars.CompletedSplits.Contains(current.ComboCheckpoint))
        {
            vars.CompletedSplits.Add(current.ComboCheckpoint);
            return true;
        }
    }

    if (old.CheckpointName != current.CheckpointName && !string.IsNullOrEmpty(current.CheckpointName))
    {
        if (settings.ContainsKey(current.CheckpointName) && settings[current.CheckpointName] && !vars.CompletedSplits.Contains(current.CheckpointName))
        {
            vars.CompletedSplits.Add(current.CheckpointName);
            return true;
        }
    }

    if (vars.Resolver.CheckFlag("RabbitEndSplit") && settings.ContainsKey("EndSplit") && settings["EndSplit"] && !vars.CompletedSplits.Contains("EndSplit"))
    {
        vars.CompletedSplits.Add("EndSplit");
        return true;
    }

    if (vars.Resolver.CheckFlag("DLCPrisonerEnd") && settings.ContainsKey("DLC1EndSplit") && settings["DLC1EndSplit"] && !vars.CompletedSplits.Contains("DLC1EndSplit"))
    {
        vars.CompletedSplits.Add("DLC1EndSplit");
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter1IL") && settings.ContainsKey("ILChapter1") && settings["ILChapter1"] && !vars.CompletedSplits.Contains("ILChapter1"))
    {
        vars.CompletedSplits.Add("ILChapter1");
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter2IL") && settings.ContainsKey("ILChapter2") && settings["ILChapter2"] && !vars.CompletedSplits.Contains("ILChapter2"))
    {
        vars.CompletedSplits.Add("ILChapter2");
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter3IL") && settings.ContainsKey("ILChapter3") && settings["ILChapter3"] && !vars.CompletedSplits.Contains("ILChapter3"))
    {
        vars.CompletedSplits.Add("ILChapter3");
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter4IL") && settings.ContainsKey("ILChapter4") && settings["ILChapter4"] && !vars.CompletedSplits.Contains("ILChapter4"))
    {
        vars.CompletedSplits.Add("ILChapter4");
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter5IL") && settings.ContainsKey("ILChapter5") && settings["ILChapter5"] && !vars.CompletedSplits.Contains("ILChapter5"))
    {
        vars.CompletedSplits.Add("ILChapter5");
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter6IL") && settings.ContainsKey("ILChapter6") && settings["ILChapter6"] && current.CheckpointName == "BP_CP_WarTown_BrokenBasement" && !vars.CompletedSplits.Contains("ILChapter6"))
    {
        vars.CompletedSplits.Add("ILChapter6");
        return true;
    }

    if (vars.Chapter7Split && settings.ContainsKey("ILChapter7") && settings["ILChapter7"] && !vars.CompletedSplits.Contains("ILChapter7"))
    {
        vars.CompletedSplits.Add("ILChapter7");
        vars.Chapter7Split = false;
        return true;
    }

    if (vars.Resolver.CheckFlag("Chapter8IL") && settings.ContainsKey("ILChapter8") && vars.Chapter8ILSafeguard && settings["ILChapter8"] && !vars.CompletedSplits.Contains("ILChapter8"))
    {
        vars.CompletedSplits.Add("ILChapter8");
        return true;
    }

    if (vars.Resolver.CheckFlag("RabbitEndSplit") && settings.ContainsKey("ILChapter9") && settings["ILChapter9"] && !vars.CompletedSplits.Contains("ILChapter9"))
    {
        vars.CompletedSplits.Add("ILChapter9");
        return true;
    }
}

isLoading
{
    return current.TransitionType || vars.Loading;
}

reset
{
    return settings.ContainsKey("AutoReset") && settings["AutoReset"] && current.World != old.World && current.World == "LVL_MainMenu";
}

onReset
{
    vars.Chpt1ILIntro = false;
    vars.Chapter7ILSafeguard = false;
    vars.Chapter7Split = false;
    vars.Chapter8ILSafeguard = false;

    vars.DeathHandlerPtr = IntPtr.Zero;
    vars.DeathHandlerName = "";
    vars.DeathHandlerSource = "";
    vars.DeathHandlerLevel = "";

    vars.StreamedLoadedLevel = IntPtr.Zero;
    vars.StreamedActorsData = IntPtr.Zero;
    vars.StreamedActorsNum = -1;
    vars.LevelsDataLast = IntPtr.Zero;
    vars.LevelsNumLast = -1;
    vars.Loading = false;
}

exit
{
    timer.IsGameTimePaused = true;
}