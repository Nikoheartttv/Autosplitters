state("Everhood 2")
{
	float currentHP : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x88, 0x130;
	float enemyHP : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60,0x148, 0x60, 0xD4;
	// float TimePlayed : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x178, 0xB0, 0x60;
	bool GameplayEnemyDefeated : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x145;
	bool GameplayEnemyInitiated : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x146;
	// bool continuousBattle_state : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x14B;
	string250 playerScene : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x178, 0x60, 0x68, 0x10, 0x14;
	// byte Q4YesExecutionCount : "UnityPlayer.dll", 0x1B462E8, 0x110, 0x8C0, 0x28, 0x20, 0x94;
	bool CreditsCanvas : "UnityPlayer.dll", 0x1AF48F8, 0x1A0, 0xD0, 0x8, 0x1C8, 0x268, 0x0, 0x28;
	bool SceneManagerRoot_transitionPlaying : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x10, 0xB0, 0x48, 0x60, 0x150;
	// bool ChartReader_Active : "UnityPlayer.dll", 0x1B623D0, 0x90, 0xE8, 0x10, 0x28, 0x60, 0x70;
	string250 ChartReader_songName : "UnityPlayer.dll", 0x1B623D0, 0x90, 0xE8, 0x10, 0x28, 0x60, 0x18, 0x20, 0x14;
	bool TD_Core_transitionPlaying : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x10, 0x70, 0x1A8, 0xE0, 0x60, 0x140, 0x18, 0x30, 0x38, 0x150;
	bool TD_Core_enemyActive : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x10, 0x70, 0x1A8, 0xE0, 0x60, 0x140, 0x18, 0x98, 0x8C;
	bool TD_Core_chartreader_active : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x10, 0x70, 0x1A8, 0xE0, 0x60, 0x140, 0x18, 0x40, 0x70;
	int TD_WaveUI_wave : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x38, 0x60, 0x28;
	int TD_CurrentEnemies_count : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x28, 0xB8, 0x10, 0x70, 0x1A8, 0xE0, 0x60, 0x140, 0x18, 0xA8, 0x18;
	string250 SLB_Dialog : "UnityPlayer.dll", 0x1AF4A90, 0x0, 0xA60, 0x28, 0x158, 0x38, 0xC0, 0x14;
    // bool SLB_Main_transitionPlaying : "UnityPlayer.dll", 0x1AF48E8, 0x98, 0xE8, 0x0, 0x38, 0x130, 0x30, 0x30, 0x2A8, 0x28, 0x40, 0x40, 0x150;
    bool SLB_Core_chartreader_active : "UnityPlayer.dll", 0x1AF48E8, 0x98, 0xE8, 0x0, 0x38, 0x130, 0x30, 0x30, 0x2A8, 0x28, 0x40, 0x30, 0x70;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Everhood 2";
	vars.Helper.Settings.CreateFromXml("Components/Everhood2.Splits.xml");
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();

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
	timer.Run.Offset = TimeSpan.FromSeconds(9);
}

init
{
	current.loadingScene = "";
	vars.OutOfBattle = true;
	vars.Spaceship = "";
	vars.Spaceship_Exiting = false;
	vars.Spaceship_FirstFight = true;
	vars.Spaceship_Loading = false;
	vars.Spaceship_InBattle = false;
	vars.Spaceship_ExitingFight = false;
	vars.Spaceship_AwaitLoad = false;

	vars.GetSettingSafe = (Func<string, bool>)(name =>
	{
		if (!settings.ContainsKey(name)) return false;
		return settings[name];
	});
}

onStart
{
	vars.LevelVisited.Clear();
	vars.OutOfBattle = true;
	vars.Spaceship = "";
	vars.Spaceship_Exiting = false;
	vars.Spaceship_FirstFight = true;
	vars.Spaceship_Loading = false;
	vars.Spaceship_InBattle = false;
	vars.Spaceship_ExitingFight = false;
	vars.Spaceship_AwaitLoad = false;
	timer.Run.Offset = TimeSpan.FromSeconds(9);
}

start
{
	return old.loadingScene == "Questionarie" && current.loadingScene == "IntroLevel";
}

update
{
	try
	{
		if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name)) current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;
	}
	catch
	{
		current.loadingScene = "NO SCENE";
	}
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");
	if (vars.Spaceship == "" && old.loadingScene != current.loadingScene && current.loadingScene.Contains("Battle")) 
	{
		vars.OutOfBattle = false;
		vars.Log("Out Of Battle: " + vars.OutOfBattle.ToString());
	}
	if (old.loadingScene != "Tutorial_Spaceship" && current.loadingScene == "Tutorial_Spaceship" 
		|| old.loadingScene != "Final_Spaceship" && current.loadingScene == "Final_Spaceship" 
		|| old.loadingScene != "ShadeEnding-5-RileySpaceship+Newgame" &&  current.loadingScene == "ShadeEnding-5-RileySpaceship+Newgame") 
		{
			vars.Spaceship = current.loadingScene;
			vars.Spaceship_FirstFight = true;
			vars.Spaceship_Loading = false;
			vars.Log("ENTERED THE SPACESHIP - State: " + vars.Spaceship);
		}
	if (old.loadingScene != "Dmitri-Battle" && current.loadingScene == "Dmitri-Battle"  
		|| old.loadingScene != "Evren2-Battle" && current.loadingScene == "Evren2-Battle" 
		|| old.loadingScene != "ShadeEnding-0-BoboRoom" && current.loadingScene == "ShadeEnding-0-BoboRoom"
		|| old.loadingScene != "Pandemonium" && current.loadingScene == "Pandemonium")
		{
			vars.Spaceship = "";
			vars.Spaceship_Exiting = false;
			vars.Spaceship_Loading = false;
			vars.Log("LEFT THE SPACESHIP - State: " + vars.Spaceship);
			if (current.loadingScene.Contains("Battle")) vars.OutOfBattle = false;
		}
	if (vars.Spaceship == "")
	{
		vars.isLoading = game.ReadValue<int>((IntPtr)vars.Helper.Scenes.Loaded[0].Address + 0x9C) != 2;
	}
	if (vars.Spaceship == "Tutorial_Spaceship" || vars.Spaceship == "Final_Spaceship")
	{
		if (current.TD_Core_chartreader_active)
		{
			if (vars.Spaceship_FirstFight)
			{
				if (old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false) 
					{
						vars.Spaceship_Loading = true;
						vars.Log("SpaceshipLoading First Fight - Going Into Battle: " + vars.Spaceship_Loading.ToString());
					}
				if (vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true)
					{
						vars.Spaceship_Loading = false;
						vars.Spaceship_FirstFight = false;
						vars.Spaceship_InBattle = true;
						vars.OutOfBattle = false;
						vars.Log("SpaceshipLoading First Fight - In Battle: " + vars.Spaceship_Loading.ToString());
					}
			}
			if (!vars.Spaceship_FirstFight)
			{
				if (!vars.Spaceship_Loading && !current.GameplayEnemyInitiated && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false && current.TD_Core_enemyActive && !vars.Spaceship_InBattle && !vars.Spaceship_ExitingFight) 
				{
					vars.Spaceship_Loading = true;
					vars.Log("SpaceshipLoading - Going Into Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true && !vars.Spaceship_InBattle)
				{
					vars.Spaceship_Loading = false;
					vars.Spaceship_InBattle = true;
					vars.OutOfBattle = false;
					vars.Log("SpaceshipLoading - In Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (!vars.Spaceship_Loading && !current.GameplayEnemyInitiated && current.GameplayEnemyDefeated && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false && vars.Spaceship_InBattle && !vars.Spaceship_ExitingFight)
				{
					vars.Spaceship_Loading = true;
					vars.Spaceship_ExitingFight = true;
					vars.Log("SpaceshipLoading - Going Out Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true && vars.Spaceship_InBattle && vars.Spaceship_ExitingFight)
				{
					vars.Spaceship_Loading = false;
					vars.OutOfBattle = true;
					vars.Log("SpaceshipLoading - Out of Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (!vars.Spaceship_Loading && old.TD_Core_enemyActive && !current.TD_Core_enemyActive && vars.Spaceship_ExitingFight)
				{
					vars.Spaceship_InBattle = false;
					vars.Spaceship_ExitingFight = false;
				}
			}
			if (vars.Spaceship == "Tutorial_Spaceship" && current.TD_WaveUI_wave == 4 && old.TD_CurrentEnemies_count >= 3 && current.TD_CurrentEnemies_count == 0 && !vars.Spaceship_InBattle)
			{
				vars.Log("PREPARE TO LEAVE");
				if (current.SceneManagerRoot_transitionPlaying == true)
				{
					vars.Spaceship_Exiting = true;
				}
				if (vars.Spaceship_Exiting && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false)
				{
					vars.Spaceship_Loading = true;
					vars.Log("BYEEEEEEEEEEEEEEEEEEEEEEEEEEE");
				}
			}
			if (vars.Spaceship == "Final_Spaceship" && current.TD_WaveUI_wave == 6 && old.TD_CurrentEnemies_count >= 2 && current.TD_CurrentEnemies_count == 0 && !vars.Spaceship_InBattle)
			{
				vars.Log("PREPARE TO LEAVE");
				if (current.SceneManagerRoot_transitionPlaying == true)
				{
					vars.Spaceship_Exiting = true;
				}
				if (vars.Spaceship_Exiting && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false)
				{
					vars.Spaceship_Loading = true;
					vars.Log("BYEEEEEEEEEEEEEEEEEEEEEEEEEEE");
				}
			}
		}
	}
	if (vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame")
	{
		if (current.ChartReader_Active && current.ChartReader_songName == "Batte - Riley's Fortress (FINISHED)")
		{
			if (vars.Spaceship_FirstFight)
			{
				if (!vars.Spaceship_Loading && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false) 
				{
					vars.Spaceship_Loading = true;
					vars.Log("SpaceshipLoading First Fight - Going Into Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true)
				{
					vars.Spaceship_Loading = false;
					vars.Spaceship_FirstFight = false;
					vars.Spaceship_InBattle = true;
					vars.OutOfBattle = false;
					vars.Log("SpaceshipLoading First Fight - In Battle: " + vars.Spaceship_Loading.ToString());
				}
			}
			if (!vars.Spaceship_FirstFight)
			{
				if (!vars.Spaceship_Loading && (current.SLB_Dialog.Contains("DIE!") || current.SLB_Dialog.Contains("HERETIC!") || current.SLB_Dialog.Contains("DESTROYER OF WORLDS!"))
					&& current.SceneManagerRoot_transitionPlaying == true && !vars.Spaceship_InBattle && !vars.Spaceship_ExitingFight) 
				{
					vars.Spaceship_AwaitLoad = true;
					vars.Log("SpaceshipLoading - Going Into Battle - Await");
				}
				if (vars.Spaceship_AwaitLoad == true && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false)
				{
					vars.Spaceship_Loading = true;
					vars.Spaceship_AwaitLoad = false;
					vars.Log("SpaceshipLoading - Going Into Battle - Load: " + vars.Spaceship_Loading.ToString());
				}
				if (vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true && !vars.Spaceship_InBattle)
				{
					vars.Spaceship_Loading = false;
					vars.Spaceship_InBattle = true;
					vars.OutOfBattle = false;
					vars.Log("SpaceshipLoading - In Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (!vars.Spaceship_Loading && old.enemyHP > 1 && current.enemyHP == 0 && vars.Spaceship_InBattle && !vars.Spaceship_ExitingFight)
				{
					if (old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false)
					{
						vars.Spaceship_Loading = true;
						vars.Spaceship_ExitingFight = true;
						vars.Log("SpaceshipLoading - Going Out Battle: " + vars.Spaceship_Loading.ToString());
					}
				}
				if (vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true && vars.Spaceship_InBattle && vars.Spaceship_ExitingFight)
				{
					vars.Spaceship_Loading = false;
					vars.OutOfBattle = true;
					vars.Log("SpaceshipLoading - Out of Battle: " + vars.Spaceship_Loading.ToString());
				}
				if (!vars.Spaceship_Loading && old.SLB_Dialog != current.SLB_Dialog && vars.Spaceship_ExitingFight)
				{
					vars.Spaceship_InBattle = false;
					vars.Spaceship_ExitingFight = false;
				}
			}
			if (vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame" && current.SLB_Dialog.Contains("Suit"))
			{
				if (!vars.Spaceship_Loading && current.SceneManagerRoot_transitionPlaying == true)
				{
					vars.Spaceship_Exiting = true;
				}
				if (vars.Spaceship_Exiting && old.SceneManagerRoot_transitionPlaying == true && current.SceneManagerRoot_transitionPlaying == false)
				{
					vars.Spaceship_Loading = true;
					vars.Log("BYEEEEEEEEEEEEEEEEEEEEEEEEEEE");
				}
			}
		}
	}
	if(settings["Current HP"]){vars.SetTextComponent("Current HP",current.currentHP.ToString());}
    if(settings["Enemy HP"]){vars.SetTextComponent("Enemy HP: ",current.enemyHP.ToString());}
}

split
{
	//Split after transition out of battle
	if (vars.Spaceship == "" && !vars.OutOfBattle && old.loadingScene != current.loadingScene 
		&& (current.GameplayEnemyDefeated || old.loadingScene == "Tutorial-Movement-Battle"
			|| old.loadingScene == "Melon-Battle" || old.loadingScene == "ShamanTunnel-Battle" || old.loadingScene == "JudgeMushroom-Battle"
			|| old.loadingScene == "Bobo-Battle" || old.loadingScene == "Sun-Battle")
			&& old.loadingScene.Contains("Battle") && !current.loadingScene.Contains("Battle"))
		{
		vars.OutOfBattle = true;
		if (vars.GetSettingSafe("E-" + old.loadingScene)) return true;
	}

	//  helps for spaceship splitting
	if ((vars.Spaceship == "Tutorial_Spaceship" || vars.Spaceship == "Final_Spaceship" || vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame") && !vars.OutOfBattle && current.GameplayEnemyDefeated) 
		{
			vars.OutOfBattle = true;
			if (vars.GetSettingSafe("SE-" + current.loadingScene)) return true;
		}
	
	// Raven Tutorial Fight - Major Cosmic Hub Enemies split instead of General Enemies
	if (old.loadingScene == "Tutorial2-Battle" && current.loadingScene == "IntroLevel")
	{
		vars.Log("THIS SHOULD SPLIT1!!!!");
		vars.OutOfBattle = true;
		if (vars.GetSettingSafe("E-RavenTutorialFight")) return true;
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
	if (settings["E-RileyCredits"] && current.loadingScene == "ShadeEnding-7-Credits+Newgame" 
		&& !old.CreditsCanvas && current.CreditsCanvas)
		{
			return true;
		}

	// Double D's Arena Gauntlet
	if (vars.OutOfBattle == false && old.loadingScene != current.loadingScene 
		&& current.GameplayEnemyDefeated == true 
		&& old.loadingScene.Contains("DD") && current.loadingScene == "DoubleDsArenaBattle")
		{
			vars.OutOfBattle = true;
			if (vars.GetSettingSafe("DD-" + old.loadingScene)) return true;
		}
}

isLoading
{
	if (vars.Spaceship == "") return vars.isLoading;
	else if (vars.Spaceship == "Tutorial_Spaceship" || vars.Spaceship == "Final_Spaceship" || vars.Spaceship == "ShadeEnding-5-RileySpaceship+Newgame") return vars.Spaceship_Loading;
}