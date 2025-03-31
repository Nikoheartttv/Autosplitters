state("Everhood 2")
{
	float currentHP : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x88, 0x130;
	float enemyHP : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60,0x148, 0x60, 0xD4;
	bool GameplayEnemyDefeated : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x145;
	bool GameplayEnemyInitiated : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x146;
	string250 playerScene : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x178, 0x60, 0x68, 0x10, 0x14;
	bool CreditsCanvas : "UnityPlayer.dll", 0x1AF48F8, 0x1A0, 0xD0, 0x8, 0x1C8, 0x268, 0x0, 0x28; // to fix
	bool SceneManagerRoot_transitionPlaying : "UnityPlayer.dll", 0x1B3F238, 0x8, 0x20, 0x10, 0xB0, 0x48, 0x60, 0x150;
	bool TD_enemyActive : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x10, 0x70, 0x1A8, 0xE0, 0x60, 0x140, 0x18, 0x98, 0x8C;
	int TD_WaveUI_wave : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x38, 0x60, 0x28;
	int TD_CurrentEnemiesCount : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x10, 0x70, 0x1A8, 0xE0, 0x60, 0x140, 0x18, 0xA8, 0x18;
	string250 SLB_Dialog : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x20, 0xB8, 0x38, 0x0, 0x38, 0x58, 0xC0, 0x14;
	bool TopDownPlayerHPBar_init : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x20, 0xB0, 0x0, 0x48, 0x60, 0xA8, 0x30, 0x144;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Everhood 2";
	vars.Helper.Settings.CreateFromXml("Components/Everhood2.Splits.xml");
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
	vars.Stopwatch = new Stopwatch();

	//creates text components for variable information
	vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
			var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
			var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
			if (textSetting == null)
			{
			var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
			var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
			timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
	
			textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
			textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
			}
	
			if (textSetting != null)
			textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
	});

	settings.Add("Variable Information", true, "Variable Information");
	settings.Add("Current HP", false, "Current HP", "Variable Information");
	settings.Add("Enemy HP", false, "Enemy HP", "Variable Information");

	vars.LevelVisited = new List<string>();
	timer.Run.Offset = TimeSpan.FromSeconds(9); // set beginning of run to 9 seconds as determined by speedrun rules
}

init
{
	current.loadingScene = "";
	vars.InBattle = true;
	vars.AwaitLoad = false;
	vars.Spaceship = "";
	vars.Spaceship_Active = false;
	vars.Spaceship_Transition = 0;
	vars.Spaceship_Exiting = false;
	vars.Spaceship_Loading = false;
	vars.TormentRealm = false;
	vars.StartedStopwatch = false;
	vars.ScaryShadeWhiteRoomReady = false;

	vars.GetSettingSafe = (Func<string, bool>)(name =>
	{
		if (!settings.ContainsKey(name)) return false;
		return settings[name];
	});
}

onStart
{
	vars.LevelVisited.Clear();
	vars.InBattle = true;
	vars.AwaitLoad = false;
	vars.Spaceship = "";
	vars.Spaceship_Active = false;
	vars.Spaceship_Transition = 0;
	vars.Spaceship_Exiting = false;
	vars.Spaceship_Loading = false;
	vars.TormentRealm = false;
	vars.StartedStopwatch = false;
	vars.ScaryShadeWhiteRoomReady = false;
	vars.Stopwatch.Reset();
	timer.Run.Offset = TimeSpan.FromSeconds(9);
}

start
{
	return old.loadingScene == "Questionarie" && current.loadingScene == "IntroLevel"; // start after Questionaire
}

update
{
	// prevents illegal characters from affecting Spaceship
    try
	{
		if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name)) current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;
	}
	catch
	{
		current.loadingScene = "NO SCENE";
	}

    // set which Spaceship you are in - log for validation
    if (old.loadingScene != "Tutorial_Spaceship" && current.loadingScene == "Tutorial_Spaceship" 
		|| old.loadingScene != "Final_Spaceship" && current.loadingScene == "Final_Spaceship" 
		|| old.loadingScene != "ShadeEnding-5-RileySpaceship+Newgame" && current.loadingScene == "ShadeEnding-5-RileySpaceship+Newgame") 
		{
			vars.Spaceship = current.loadingScene;
			vars.Spaceship_Loading = false;
			vars.InBattle = false;
			vars.Spaceship_Transition = 0;
			vars.Spaceship_Active = false;
			vars.Log("ENTERED THE " + vars.Spaceship + " SPACESHIP");
		}

	// when no longer in Spaceship, set the vars to nothing
	if (old.loadingScene != "Dmitri-Battle" && current.loadingScene == "Dmitri-Battle"  
		|| old.loadingScene != "Evren2-Battle" && current.loadingScene == "Evren2-Battle" 
		|| old.loadingScene != "ShadeEnding-0-BoboRoom" && current.loadingScene == "ShadeEnding-0-BoboRoom"
		|| old.loadingScene != "Pandemonium" && current.loadingScene == "Pandemonium")
		{
			vars.Spaceship = "";
			vars.Spaceship_Exiting = false;
			vars.Spaceship_Loading = false;
			vars.Log("LEFT THE SPACESHIP - State: " + vars.Spaceship);
			if (current.loadingScene.Contains("Battle")) vars.InBattle = true;
		}

	// logic for ensuring you're in battle - may not need?
    if (vars.Spaceship == "" && !old.loadingScene.Contains("Battle") && current.loadingScene.Contains("Battle")) 
	{
		vars.InBattle = true;
		vars.Log("Out Of Battle: " + vars.InBattle.ToString());
	}

	// for runs that utilise entering the Torment Realm
	if (current.loadingScene == "ShadeEnding-2-Tormentrealm") vars.TormentRealm = true;

	// load removal for normal play and Torment Realm edge case !!!!!!!!!!! DOUBLE CHECK THIS !!!!!!!!!!!
	if (vars.Spaceship == "")
	{
		if (vars.TormentRealm)
		{
			if (current.loadingScene == "ShadeEnding-2-Tormentrealm") vars.isLoading = game.ReadValue<int>((IntPtr)vars.Helper.Scenes.Loaded[0].Address + 0x9C) != 2; // Beginning Torment Realm works fine with normal load removal
			// As soon as you enter ShadeDemon-Battle, it loads two scene consecutively, which is where timer will freak out.
			// Preventative measure here
			if (current.loadingScene == "ShadeDemon-Battle" || old.loadingScene == "ShadeEnding-3-White-room" && current.loadingScene == "ShadeDemon-Battle")
			{
				vars.isLoading = false; // transition into white room is instanteous, so set load removal to false
			}
			if (old.TopDownPlayerHPBar_init && !current.TopDownPlayerHPBar_init)
			{
				vars.AwaitLoad = true; // check for just before going into Sun fight
				{
					if (vars.AwaitLoad && old.SceneManagerRoot_transitionPlaying && !current.SceneManagerRoot_transitionPlaying)
					{
						vars.isLoading = true;
						if (current.loadingScene == "Sun-Battle") vars.TormentRealm = false; // heading into Sun Fight, return back to normal load removal
					}
				}
			}
		}
		if (!vars.TormentRealm && (current.loadingScene == "Evren2-Battle" || old.loadingScene == "Evren2-Battle"))	vars.isLoading = false;
		else if (!vars.TormentRealm)	vars.isLoading = game.ReadValue<int>((IntPtr)vars.Helper.Scenes.Loaded[0].Address + 0x9C) != 2;
	}

	// Load Removal workaround for Spaceship Sections
	if (vars.Spaceship == "Tutorial_Spaceship" || vars.Spaceship == "Final_Spaceship")
	{
		if (vars.Spaceship == "Tutorial_Spaceship" && current.SLB_Dialog.Contains("Are you ready?")) vars.Spaceship_Active = true;
		if (vars.Spaceship == "Tutorial_Spaceship" && current.SLB_Dialog.Contains("We have arrived.")) vars.Spaceship_Active = false;
		if (vars.Spaceship == "Final_Spaceship" && current.SLB_Dialog.Contains("Are you ready?")) vars.Spaceship_Active = true;
		if (vars.Spaceship == "Final_Spaceship" && current.SLB_Dialog.Contains("It seems I have to do everything myself!")) vars.Spaceship_Active = false;
		if (vars.Spaceship_Active) vars.Spaceship_Loading = false;
		if (vars.Spaceship == "Tutorial_Spaceship" && current.SLB_Dialog.Contains("There is only one way of teaching your kind understands."))
			{
				if (old.SceneManagerRoot_transitionPlaying && !current.SceneManagerRoot_transitionPlaying)	vars.Spaceship_Loading = true;
			}
		if (vars.Spaceship == "Final_Spaceship" && current.SLB_Dialog.Contains("Let's make this a bit more interesting!"))
		{
			if (old.SceneManagerRoot_transitionPlaying == true && !current.SceneManagerRoot_transitionPlaying) vars.Spaceship_Loading = true;
		}
	}
	if (vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame")
	{
		if (current.SLB_Dialog.Contains("Lead the way cap'n.")) vars.Spaceship_Active = true;
		if (current.SLB_Dialog.Contains("We have arrived.")) vars.Spaceship_Active = false;
		if (vars.Spaceship_Active) vars.Spaceship_Loading = false;
		if (current.SLB_Dialog.Contains("Suit yourself!!"))
		{
			if (old.SceneManagerRoot_transitionPlaying && !current.SceneManagerRoot_transitionPlaying) vars.Spaceship_Loading = true;
		} 
	}
 
	if (old.loadingScene == "ShadeEnding-3-White-room" && current.loadingScene == "ShadeDemon-Battle") vars.ScaryShadeWhiteRoomReady = true;

	// logging
	if(settings["Current HP"]){vars.SetTextComponent("Current HP",current.currentHP.ToString());}
    if(settings["Enemy HP"]){vars.SetTextComponent("Enemy HP: ",current.enemyHP.ToString());}
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");
	// if (old.SLB_Dialog != current.SLB_Dialog) vars.Log(current.SLB_Dialog);
}

split
{
	//Split after transition out of battle
	if (vars.Spaceship == "" && vars.InBattle && old.loadingScene != current.loadingScene 
		&& (current.GameplayEnemyDefeated || old.loadingScene == "Tutorial-Movement-Battle"
		|| old.loadingScene == "Melon-Battle" || old.loadingScene == "ShamanTunnel-Battle" || old.loadingScene == "JudgeMushroom-Battle"
		|| old.loadingScene == "Bobo-Battle" || old.loadingScene == "Sun-Battle")
		&& old.loadingScene.Contains("Battle") && !current.loadingScene.Contains("Battle"))
		{
			vars.InBattle = false;
			if (vars.GetSettingSafe("E-" + old.loadingScene)) return true;
		}

	// dragon 1 & 2 splits
	if ((old.loadingScene == "DragonPart1-Battle" && current.loadingScene == "DragonPart2-Battle") || (old.loadingScene == "DragonPart2-Battle" && current.loadingScene == "DragonPart3-Battle"))
		{
			if (vars.GetSettingSafe("E-" + old.loadingScene)) return true;
		}

	//  helps for spaceship splitting
	if ((vars.Spaceship == "Tutorial_Spaceship" || vars.Spaceship == "Final_Spaceship" || vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame") && vars.InBattle && current.GameplayEnemyDefeated) 
	{
		vars.InBattle = false;
		if (vars.GetSettingSafe("SE-" + current.loadingScene)) return true;
	}
	
	// Raven Tutorial Fight - Major Cosmic Hub Enemies split instead of General Enemies
	if (old.loadingScene == "Tutorial2-Battle" && current.loadingScene == "IntroLevel")
	{
		vars.InBattle = false;
		if (vars.GetSettingSafe("E-RavenTutorialFight")) return true;
	}

	// Scary Shade (Die Into White Room - For Any% No Battle Replay Warp)

	if (settings["E-ScaryShadeDie"] && current.loadingScene == "ShadeDemon-Battle" && vars.ScaryShadeDie && old.currentHP >= 1 && current.currentHP == 0)
	{
		vars.InBattle = false;
		if (vars.GetSettingSafe("E-ScaryShadeDie")) return true;
	}

	// 2 times going into Hillbert Room 1
	if (old.loadingScene == "Neon_HotelEntrance" && current.loadingScene == "Neon_Hillbert_Room1")
	{
		vars.HillbertRoom1++;
		if (vars.GetSettingSafe("L-" + current.loadingScene + "_" + vars.HillbertRoom1.ToString())) return true;
	}

	// revamp to only check levels
	if (settings["Levels"] && old.loadingScene != current.loadingScene && !vars.LevelVisited.Contains(current.loadingScene))
	{
		vars.LevelVisited.Add(current.loadingScene);
		if (vars.GetSettingSafe("L-" + current.loadingScene)) return true;
	}

	// God Machine split
	if (settings["E-GodMachine"] && settings.ContainsKey("E-GodMachine") 
		&& old.loadingScene == "Marzian_Part3Bear_Temple" && current.loadingScene == "CosmicHubInfinity")
		{
			return true;
		}

	// Final split
	if (!vars.StartedStopwatch && current.loadingScene == "ShadeEnding-7-Credits+Newgame" && current.SLB_Dialog.Contains("W"))
	{
		vars.StartedStopwatch = true;
		vars.Stopwatch.Start();
		vars.Log("Stopwatch Started");
	}
	if (vars.Stopwatch.Elapsed.TotalSeconds >= 10 && current.loadingScene == "ShadeEnding-7-Credits+Newgame")
	{ 
		vars.Stopwatch.Reset();
		if (vars.GetSettingSafe("E-RileyCredits")) return true;
	}

	// Double D's Arena Gauntlet
	if (vars.InBattle && old.loadingScene != current.loadingScene 
		&& current.GameplayEnemyDefeated 
		&& old.loadingScene.Contains("DD") && current.loadingScene == "DoubleDsArenaBattle")
		{
			vars.InBattle = false;
			if (vars.GetSettingSafe("DD-" + old.loadingScene)) return true;
		}
}

isLoading
{
	if (vars.Spaceship == "") return vars.isLoading;
	else if (vars.Spaceship == "Tutorial_Spaceship" || vars.Spaceship == "Final_Spaceship" || vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame") return vars.Spaceship_Loading;
}