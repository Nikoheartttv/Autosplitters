state("Partizan"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Partizan";
	vars.MissionComplete = new List<string>();

	#region TextComponent
		vars.lcCache = new Dictionary<string, LiveSplit.UI.Components.ILayoutComponent>();
		vars.SetText = (Action<string, object>)((text1, text2) =>
		{
			const string FileName = "LiveSplit.Text.dll";
			LiveSplit.UI.Components.ILayoutComponent lc;

			if (!vars.lcCache.TryGetValue(text1, out lc))
			{
				lc = timer.Layout.LayoutComponents.Reverse().Cast<dynamic>()
					.FirstOrDefault(llc => llc.Path.EndsWith(FileName) && llc.Component.Settings.Text1 == text1)
					?? LiveSplit.UI.Components.ComponentManager.LoadLayoutComponent(FileName, timer);

				vars.lcCache.Add(text1, lc);
			}

			if (!timer.Layout.LayoutComponents.Contains(lc)) timer.Layout.LayoutComponents.Add(lc);
			dynamic tc = lc.Component;
			tc.Settings.Text1 = text1;
			tc.Settings.Text2 = text2.ToString();
		});
		vars.RemoveText = (Action<string>)(text1 =>
		{
			LiveSplit.UI.Components.ILayoutComponent lc;
			if (vars.lcCache.TryGetValue(text1, out lc))
			{
				timer.Layout.LayoutComponents.Remove(lc);
				vars.lcCache.Remove(text1);
			}
		});
	#endregion

	dynamic[,] _settings =
	{
		{ "AutoReset", true, "Auto Reset", null },
		{ "FirstLevel", true, "First Level", null },
			{ "FindCalhoun", true, "Find Calhoun", "FirstLevel" },
			{ "SaveCalhoun", true, "Save Calhoun", "FirstLevel" },
		{ "Debug", false, "Debug", null },
			{ "Speed", true, "Speed", "Debug" },
	};
	vars.Helper.Settings.Create(_settings);
}

init
{
    var JitSave = vars.Uhara.CreateTool("Unity", "DotNet", "JitSave");

    JitSave.SetOuter("Assembly-CSharp.dll", "World");
    vars.Resolver.Watch<ulong>("Restart", JitSave.AddFlag("SceneHandler", "RestartScene"));
	vars.Resolver.Watch<ulong>("QuitToMenu", JitSave.AddFlag("ApplicationHandler", "QuitToMenu"));
    JitSave.ProcessQueue();

	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		vars.Helper["missions"] = mono.Make<IntPtr>("World.Mission_System.MissionHandler", "missions");
		vars.Helper["timer"] = mono.Make<IntPtr>("World.Mission_System.GlobalMissionHandler", "data");
		vars.Helper["inGameMenu"] = mono.Make<int>("World.Global", "inGameMenu");
		vars.Helper["movementInputx"] = mono.Make<float>("World.Global", "playerHandler", "characterMovement", "movementInput", 0x28);
		
		vars.Helper["velX"] = mono.Make<float>("World.Global", "playerHandler", "tsitskiCharacter", 0xA0);
		vars.Helper["velY"] = mono.Make<float>("World.Global", "playerHandler", "tsitskiCharacter", 0xA4);
		vars.Helper["velZ"] = mono.Make<float>("World.Global", "playerHandler", "tsitskiCharacter", 0xA8);
		vars.Helper["posX"] = mono.Make<float>("World.Global", "playerHandler", "tsitskiCharacter", 0xAC);
		vars.Helper["posY"] = mono.Make<float>("World.Global", "playerHandler", "tsitskiCharacter", 0xB0);
		vars.Helper["posZ"] = mono.Make<float>("World.Global", "playerHandler", "tsitskiCharacter", 0xB4);
		
		return true;
	});

	#region Text Component
		vars.SetTextIfEnabled = (Action<string, object>)((text1, text2) =>
		{
			if (settings[text1]) vars.SetText(text1, text2); 
			else vars.RemoveText(text1);
		});
	#endregion

	current.Placeholder = 0;
	current.time = 0;
	vars.inGame = false;
	current.inGameMenu = 0;
	current.posX = 0;
	current.posY = 0;
	current.posZ = 0;
	current.horizontalSpeed = 0;
}

update
{
	vars.Uhara.Update();

	current.time = vars.Helper.Read<float>(current.timer + 0x38);
	vars.inGame = current.inGameMenu != 0;
	// if (old.posX != current.posX || old.posY != current.posY || old.posZ != current.posZ) vars.Log("X " + current.posX + "Y " + current.posY + "Z " + current.posZ);

	current.horizontalSpeed = Math.Sqrt(current.velX*current.velX + current.velZ*current.velZ);

	#region Debug Prints
	if (settings["Debug"])
	{
		if ((int)old.horizontalSpeed != (int)current.horizontalSpeed) 
		{
			vars.Log("Speed " + ((int)current.horizontalSpeed).ToString());
			vars.SetTextIfEnabled("Speed", ((int)current.horizontalSpeed).ToString());
		}
	}
	#endregion
}

onStart
{
	vars.MissionComplete.Clear();
}

start
{
	return old.movementInputx != current.movementInputx;
}

split
{
	int size = vars.Helper.Read<int>(current.missions + 0x10, 0x20, 0x30, 0x18);
	for (int i = 0; i < size; i++)
	{
		string name = vars.Helper.ReadString(current.missions + 0x10, 0x20, 0x30, 0x10, i * 0x8 + 0x20, 0x10);
		if (!string.IsNullOrEmpty(name) && !vars.MissionComplete.Contains(name))
		{
			vars.MissionComplete.Add(name);
			return true;
		}
	}
}

reset
{
    return vars.Resolver.CheckFlag("Restart") || vars.Resolver.CheckFlag("QuitToMenu");
}