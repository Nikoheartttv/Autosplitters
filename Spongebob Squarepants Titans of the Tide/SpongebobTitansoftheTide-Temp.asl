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

	vars.Resolver.Watch<float>("GameTime", GG_Speedrunning, 0x68);

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

	current.GameTime = 0;
	vars.LastGameTime = 0;
	vars.WaitingForZero = true;
	current.Test2 = "";
}

onStart
{
	vars.LastGameTime = 0;
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
	IntPtr gm;
	if (!vars.Resolver.TryRead<IntPtr>(out gm, vars.GG_PersistenceSystem))
	{
		vars.GG_PersistenceSystem = vars.FindSubsystem("GG_PersistenceSystem");
		vars.Resolver.Watch<IntPtr>("Objectives", vars.GG_PersistenceSystem, 0xC8);
		vars.Resolver.Watch<int>("ObjectivesNum", vars.GG_PersistenceSystem, 0xD0);
	}

	vars.Uhara.Update();
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
