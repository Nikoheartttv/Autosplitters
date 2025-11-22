state("Ghost-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.Uhara.Settings.CreateFromXml("Components/SpongebobTitansoftheTide.Splits.xml");
	vars.CompletedSplits = new List<string>();
	vars.CompletedObjectives = new List<string>();
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Events.FunctionFlag("LoadScreenShowing", "GG_SpeedrunningSubsystem", "GG_SpeedrunningSubsystem", "OnLoadingScreenShowing");
	vars.Events.FunctionFlag("LoadScreenHidden", "GG_SpeedrunningSubsystem", "GG_SpeedrunningSubsystem", "OnLoadingScreenHidden");

	vars.FindSubsystem = (Func<string, IntPtr>)(name =>
	{
		var subsystems = vars.Resolver.Read<int>(vars.Utils.GEngine, 0x1248, 0x118);
		for (int i = 0; i < subsystems; i++)
		{
			var subsystem = vars.Resolver.Deref(vars.Utils.GEngine, 0x1248, 0x110, 0x18 * i + 0x8);
			var sysName = vars.Utils.FNameToString(vars.Resolver.Read<uint>(subsystem, 0x18));
			if (sysName.StartsWith(name)) return subsystem;
		}
		throw new InvalidOperationException("Subsystem not found: " + name);
	});
	vars.GG_PersistenceSystem = IntPtr.Zero;

	//Plankton's Portal Challenges DLC 1
	vars.Events.FunctionFlag("PPDLC1SandyV1", "LS_DLC1_V1_Outro_DirectorBP_C", "", "*_DLC1_V1_Outro_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1SandyV2", "LS_DLC1_V2_Outro_DirectorBP_C", "", "*_DLC1_V2_Outro_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1SandyV3", "LS_DLC1_V3_Outro_DirectorBP_C", "", "*_DLC1_V3_Outro_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1SquidwardV1", "LS_DLC1_P1_Outro_DirectorBP_C", "", "*_DLC1_P1_Outro_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1SquidwardV2", "LS_DLC1_P2_Outro_DirectorBP_C", "", "*_DLC1_P2_Outro_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1SquidwardV3", "LS_DLC1_FinishedPlatforming3_DirectorBP_C", "", "*_DLC1_FinishedPlatforming3_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1KrabsV1", "LS_DLC1_C1_Outro_02_DirectorBP_C", "", "*_DLC1_C1_Outro_02_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1KrabsV2", "LS_DLC1_C2_Outro_02_DirectorBP_C", "", "*_DLC1_C2_Outro_02_DirectorBP");
	vars.Events.FunctionFlag("PPDLC1KrabsV3", "LS_DLC1_C3_Outro_DirectorBP_C", "", "*_DLC1_C3_Outro_DirectorBP");

	//Planton's Portal Challenge DLC 2
	vars.Events.FunctionFlag("PPDLC2Platforming1", "LS_01_Platforming1_Finished_DirectorBP_C", "", "*_01_Platforming1_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Jellyfish1", "LS_02_Jellyfish1_Finished_DirectorBP_C", "", "*_02_Jellyfish1_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Combat1", "LS_03_Combat1_Finished_DirectorBP_C", "", "*_03_Combat1_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Cubes1", "LS_04_Cubes1_Finished_DirectorBP_C", "", "*_04_Cubes1_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Platforming2", "LS_05_Platforming2_Finished_DirectorBP_C", "", "*_05_Platforming2_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Jellyfish2", "LS_06_Jellyfish2_Finished_DirectorBP_C", "", "*_06_Jellyfish2_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Cubes2", "LS_07_Cubes2_Finished_DirectorBP_C", "", "*_07_Cubes2_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLCPlatforming3", "LS_08_Platforming3_Finished_DirectorBP_C", "", "*_08_Platforming3_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Jellyfish3", "LS_09_Jellyfish3_Finished_DirectorBP_C", "", "*_09_Jellyfish3_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Combat2", "LS_10_Combat2_Finished_DirectorBP_C", "", "*_10_Combat2_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Combat3", "LS_11_Combat3_Finished_DirectorBP_C", "", "*_11_Combat3_Finished_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Cubes3", "LS_12_Cubes3_Finished_DirectorBP_C", "", "*_12_Cubes3_Finished_DirectorBP");

	//Boss Fights
	// Dutchman Fight - in WP_GoldFishIsland
	vars.Events.FunctionFlag("PPDLC2Dutchman", "LS_GFI_A4_BossOutro_BossTrial_DirectorBP_C", "*_BossTrial_DirectorBP_C", "*_BossTrial_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2NeptunesStatue", "LS_ATL_Boss_Outro_05_DirectorBP_C", "*_Boss_Outro_05_DirectorBP_C", "_Boss_Outro_05_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2HibernationSandy", "LS_JFF_A4_BossOutro_3_SandyFalls_New_DirectorBP_C", "*_BossOutro_3_SandyFalls_New_DirectorBP_C", "*_BossOutro_3_SandyFalls_New_DirectorBP");
	vars.Events.FunctionFlag("PPDLC2Titans", "WBP_ChallengeResultDialog_C", "WBP_ChallengeResultDialog_C", "");

	// Search For Squarepants
	vars.Events.FunctionFlag("SFSComplete", "LS_DLC2_SI_Outro_04_DirectorBP_C", "*_Outro_04_DirectorBP_C", "*_Outro_04_DirectorBP");

	current.World = "";
	vars.readyObjective = false;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
	vars.CompletedObjectives.Clear();
}

start
{
	return old.World == "P_MainMenu" && current.World == "BBR_KrustyKrabRestaurant";
}

update
{
	IntPtr gm;
	if (!vars.Resolver.TryRead<IntPtr>(out gm, vars.GG_PersistenceSystem))
	{
		vars.GG_PersistenceSystem = vars.FindSubsystem("GG_PersistenceSystem");
		vars.Resolver.Watch<IntPtr>("Objectives", vars.GG_PersistenceSystem, 0xC8);
		vars.Resolver.Watch<int>("ObjectivesNum", vars.GG_PersistenceSystem, 0xD0);
	}

	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

	if (current.Objectives != IntPtr.Zero && current.ObjectivesNum > 0)
	{
		for (int i = 0; i < current.ObjectivesNum; i++)
		{
			string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.Objectives + i * 0x38 + 0x10));
			bool completed = vars.Resolver.Read<bool>(current.Objectives + i * 0x38 + 0x28);

			if (!string.IsNullOrEmpty(name))
			{
				if (name == "DA_BBR2_E_ReachTheKK")
				{
					string kkCount = !vars.CompletedObjectives.Contains("DA_BBR2_E_FirstReachKK") ? "First" : "Second";

					if (!completed) vars.readyObjective = true;
					else if (completed && vars.readyObjective)
					{
						if (!vars.CompletedObjectives.Contains("DA_BBR2_E_" + kkCount + "ReachKK") &&
							settings.ContainsKey("DA_BBR2_E_" + kkCount + "ReachKK") && settings["DA_BBR2_E_" + kkCount + "ReachKK"])
						{
							vars.CompletedObjectives.Add("DA_BBR2_E_" + kkCount + "ReachKK");
							vars.readyObjective = false;
						}
					}
				}
				else if (name == "DA_ATL_H_MakeWayToPoseidome")
				{
					string poseCount = !vars.CompletedObjectives.Contains("DA_ATL_H_FirstMakeWay") ? "First" : "Second";

					if (!completed) vars.readyObjective = true;
					else if (completed && vars.readyObjective)
					{
						if (!vars.CompletedObjectives.Contains("DA_ATL_H_" + poseCount + "MakeWay") &&
							settings.ContainsKey("DA_ATL_H_" + poseCount + "MakeWay") && settings["DA_ATL_H_" + poseCount + "MakeWay"])
						{
							vars.CompletedObjectives.Add("DA_ATL_H_" + poseCount + "MakeWay");
							vars.readyObjective = false;
						}
					}
				}
				else if (completed && !vars.CompletedObjectives.Contains(name)) vars.CompletedObjectives.Add(name);
			}
		}
	}
}

split
{
	if (old.World != current.World && !vars.CompletedSplits.Contains(old.World) && settings.ContainsKey(old.World) && settings[old.World])
	{
		vars.Uhara.Log("Split: " + old.World);
		vars.CompletedSplits.Add(old.World);
		return true;
	}

	foreach (var obj in vars.CompletedObjectives)
	{
		if (settings.ContainsKey(obj) && settings[obj] && !vars.CompletedSplits.Contains(obj))
		{
			vars.CompletedSplits.Add(obj);
			vars.Uhara.Log("Split: " + obj);
			return true;
		}
	}

	// DLC / FunctionFlag splits
	string[] dlcFlags = new string[]
	{
		// Plankton's Portal DLC 1
		"PPDLC1SandyV1","PPDLC1SandyV2","PPDLC1SandyV3",
		"PPDLC1SquidwardV1","PPDLC1SquidwardV2","PPDLC1SquidwardV3",
		"PPDLC1KrabsV1","PPDLC1KrabsV2","PPDLC1KrabsV3",

		// Plankton's Portal DLC 2
		"PPDLC2Platforming1","PPDLC2Jellyfish1","PPDLC2Combat1","PPDLC2Cubes1",
		"PPDLC2Platforming2","PPDLC2Jellyfish2","PPDLC2Cubes2",
		"PPDLCPlatforming3","PPDLC2Jellyfish3","PPDLC2Combat2","PPDLC2Combat3","PPDLC2Cubes3",

		// Boss Fights
		"PPDLC2Dutchman","PPDLC2NeptunesStatue","PPDLC2HibernationSandy",

		// Search for Squarepants
		"SFSComplete"
	};

	foreach (var flag in dlcFlags)
	{
		if (vars.Resolver.CheckFlag(flag) && settings.ContainsKey(flag) && settings[flag] && !vars.CompletedSplits.Contains(flag))
		{
			vars.CompletedSplits.Add(flag);
			vars.Uhara.Log("Split: " + flag);
			return true;
		}
	}

	// Edge Case for Titans
	if (current.World == "WP_HauntedBikiniBottom" && vars.Resolver.CheckFlag("PPDLC2Titans") && settings["PPDLC2Titans"] && !vars.CompletedSplits.Contains("PPDLC2Titans"))
	{
		vars.CompletedSplits.Add("PPDLC2Titans");
		vars.Uhara.Log("Split: PPDLC2Titans");
		return true;
	}
}

isLoading
{
	if (vars.Resolver.CheckFlag("LoadScreenShowing")) return true;
	else if (current.World == "P_Intro" || current.World == "P_MainMenu") return true;
	else if (vars.Resolver.CheckFlag("LoadScreenHidden")) return false;
}


exit
{
	timer.IsGameTimePaused = true;
}
