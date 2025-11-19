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

    IntPtr GG_Speedrunning = vars.Events.InstancePtr("GG_SpeedrunningViewModel", "GG_SpeedrunningViewModel");

    vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<int>("CurrentLevelIndex", vars.Utils.GEngine, 0x1248, 0x1E0);
    vars.Resolver.Watch<float>("GameTime", GG_Speedrunning, 0x68);
    vars.Resolver.Watch<IntPtr>("Objectives", vars.Utils.GEngine, 0x1248, 0x110, 0x368, 0xC8);
    vars.Resolver.Watch<int>("ObjectivesNum", vars.Utils.GEngine, 0x1248, 0x110, 0x368, 0xD0);

    current.World = "";
    current.GameTime = 0;
	vars.LastGameTime = 0;
    vars.WaitingForZero = true;
	vars.readyObjective = false;
}

onStart
{
    current.GameTime = 0;
    timer.IsGameTimePaused = true;
    vars.WaitingForZero = true;
    vars.CompletedSplits.Clear();
    vars.CompletedObjectives.Clear();
}

start
{
    return old.World == "P_MainMenu" && current.World == "BBR_KrustyKrabRestaurant";
}

update
{
    vars.Uhara.Update();

    var world = vars.Utils.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

    if (current.Objectives != IntPtr.Zero && current.ObjectivesNum > 0)
    {
        for (int i = 0; i < current.ObjectivesNum; i++)
        {
            string name = vars.Utils.FNameToString(vars.Resolver.Read<uint>(current.Objectives + i * 0x38 + 0x10));
            bool completed = vars.Resolver.Read<bool>(current.Objectives + i * 0x38 + 0x28);

            if (string.IsNullOrEmpty(name))
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
    if (old.World != current.World && !vars.CompletedSplits.Contains(old.World))
    {
        vars.CompletedSplits.Add(old.World);
        if (settings.ContainsKey(old.World) && settings[old.World]) return true;
    }

    foreach (var obj in vars.CompletedObjectives)
    {
        if (settings.ContainsKey(obj) && settings[obj] && !vars.CompletedSplits.Contains(obj))
        {
            vars.CompletedSplits.Add(obj);
            return true;
        }
    }
}

gameTime
{
    if (vars.WaitingForZero)
    {
        if (current.GameTime <= 0.1) vars.WaitingForZero = false;
        return TimeSpan.Zero;
    }
    if (current.GameTime > vars.LastGameTime) vars.LastGameTime = current.GameTime;
    return TimeSpan.FromSeconds(vars.LastGameTime);
}

isLoading
{
    return true;
}
