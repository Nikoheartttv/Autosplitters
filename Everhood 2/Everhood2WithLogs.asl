state("Everhood 2")
{
	float currentHP : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x88, 0x130;
	float enemyHP : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60,0x148, 0x60, 0xD4;
	float TimePlayed : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x178, 0xB0, 0x60;
	bool GameplayEnemyDefeated : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x145;
	bool GameplayEnemyInitiated : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x146;
	bool continuousBattle_state : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x148, 0x14B;
	string250 playerScene : "UnityPlayer.dll", 0x1B3B040, 0x8, 0x18, 0xB8, 0x48, 0x60, 0x178, 0x60, 0x68, 0x10, 0x14;
	byte Q4YesExecutionCount : "UnityPlayer.dll", 0x1B462E8, 0x110, 0x8C0, 0x28, 0x20, 0x94;
	// bool CreditsCanvas : "UnityPlayer.dll", 0x1A921C0, 0x10, 0x0, 0x618;
	bool CreditsCanvas : "UnityPlayer.dll", 0x1AF48F8, 0x1A0, 0xD0, 0x8, 0x1C8, 0x268, 0x0, 0x28;
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

	// vars.EnemyDefeated = new List<string>();
	vars.LevelVisited = new List<string>();
}

init
{
	vars.TotalIGT = 0f;
	vars.CurrentIGT = 0f;
	vars.StartOffset = 0f;
	current.loadingScene = "";
	vars.OutOfBattle = true;
	vars.Spaceship = false;
	vars.GetSettingSafe = (Func<string, bool>)(name =>
	{
		if (!settings.ContainsKey(name)) return false;
		return settings[name];
	});
}

onStart
{
	vars.TotalIGT = 0f;
	vars.CurrentIGT = 0f;
	vars.StartOffset = current.TimePlayed;
	// vars.EnemyDefeated.Clear();
	vars.LevelVisited.Clear();
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
	if (old.loadingScene != current.loadingScene && current.loadingScene.Contains("Battle")) vars.OutOfBattle = false;
	if (old.playerScene != current.playerScene) vars.Log("PlayerScene: " + current.playerScene);

	if (current.TimePlayed != 0)
	{
		if (current.TimePlayed < vars.CurrentIGT) vars.TotalIGT += vars.CurrentIGT;
		vars.CurrentIGT = current.TimePlayed;
	}

	if(settings["Current HP"]){vars.SetTextComponent("Current HP",current.currentHP.ToString());}
	if(settings["Enemy HP"]){vars.SetTextComponent("Enemy HP: ",current.enemyHP.ToString());}
	if(current.loadingScene == "Tutorial_Spaceship" || current.loadingScene == "BoatmanDock-Final" || current.loadingScene == "Final_Spaceship") vars.Spaceship = true;
	if(current.loadingScene == "Dimitri-Battle" || current.loadingScene == "Tutorial_Spaceship-Intermission" || current.loadingScene == "ShadeEnding-0-BoboRoom") vars.Spaceship = false;
	if (vars.Spaceship && !old.GameplayEnemyInitiated && current.GameplayEnemyInitiated) vars.OutOfBattle = false;
}

split
{
	//Split after transition out of battle
	if (!vars.Spaceship && vars.OutOfBattle == false && old.loadingScene != current.loadingScene 
		&& (current.GameplayEnemyDefeated == true || old.loadingScene == "Tutorial-Movement-Battle" || 
			old.loadingScene == "Melon-Battle" || old.loadingScene == "ShamanTunnel-Battle" || old.loadingScene == "JudgeMushroom-Battle")
		&& old.loadingScene.Contains("Battle") && !current.loadingScene.Contains("Battle"))
		// && !vars.EnemyDefeated.Contains(old.loadingScene))
		{
			vars.Log(old.loadingScene.ToString() + " SPLIT ---");
			vars.OutOfBattle = true;
			vars.Log("Out Of Battle " + vars.OutOfBattle.ToString());
			// vars.EnemyDefeated.Add("E-" + old.loadingScene);
			return vars.GetSettingSafe("E-" + old.loadingScene);
		}

	//  helps for spaceship splitting
	if (vars.Spaceship && vars.OutOfBattle == false && current.GameplayEnemyDefeated == true) 
		// && !vars.EnemyDefeated.Contains(current.loadingScene))
		{
			vars.Log(current.loadingScene.ToString() + " SPLIT ---");
			vars.OutOfBattle = true;
			vars.Log("Out Of Battle " + vars.OutOfBattle.ToString());
			// vars.EnemyDefeated.Add("E-" + current.loadingScene);
			return vars.GetSettingSafe("E-" + current.loadingScene);
		}
	
	// Raven Tutorial Fight - Major Cosmic Hub Enemies split instead of General Enemies
	if (settings["E-RavenTutorialFight"] && old.loadingScene == "Tutorial2-Battle" && !current.loadingScene.Contains("Battle"))
	//  && !vars.EnemyDefeated.Contains(old.loadingScene))
	{
		vars.Log("Raven Tutorial Fight SPLIT ---");
		vars.OutOfBattle = true;
		vars.Log("Out Of Battle " + vars.OutOfBattle.ToString());
		// vars.EnemyDefeated.Add("E-RavenTutorialFight");
		return vars.GetSettingSafe("E-RavenTutorialFight");
	}
	
	// 2 times going into Hillbert Room 1
	if (old.loadingScene == "Neon_HotelEntrance" && current.loadingScene == "Neon_Hillbert_Room1")
	{
		vars.HillbertRoom1++;
		return vars.GetSettingSafe("L-" + current.loadingScene + "_" + vars.HillbertRoom1.ToString());
	}

	// revamp to only check levels
	if (settings["Levels"] && old.loadingScene != current.loadingScene && !vars.LevelVisited.Contains(current.loadingScene))
	{
		vars.Log("--- SPLIT AT " + current.loadingScene + " FROM " + old.loadingScene);
		vars.LevelVisited.Add(current.loadingScene);
		return vars.GetSettingSafe("L-" + current.loadingScene);
	}

	// God Machine split
	if (settings["E-GodMachine"] && settings.ContainsKey("E-GodMachine") 
		&& old.loadingScene == "Marzian_Part3Bear_Temple" && current.loadingScene == "CosmicHubInfinity")
		// && !vars.EnemyDefeated.Contains("E-GodMachine"))
		{
			// vars.EnemyDefeated.Add("E-GodMachine");
			return true;
		}

	// Final split
	if (settings["E-RileyCredits"] && current.loadingScene == "ShadeEnding-7-Credits+Newgame" 
		&& !old.CreditsCanvas && current.CreditsCanvas)
		//  && !vars.EnemyDefeated.Contains("E-RileyCredits"))
		{
			// vars.EnemyDefeated.Add("E-RileyCredits");
			return true;
		}

	// Double D's Arena Gauntlet
	if (vars.OutOfBattle == false && old.loadingScene != current.loadingScene 
		&& current.GameplayEnemyDefeated == true 
		&& old.loadingScene.Contains("DD") && current.loadingScene == "DoubleDsArenaBattle")
		{
				vars.Log(old.loadingScene.ToString() + " SPLIT ---");
				vars.OutOfBattle = true;
				vars.Log("Out Of Battle " + vars.OutOfBattle.ToString());
				// vars.EnemyDefeated.Add("DD-" + old.loadingScene);
				return vars.GetSettingSafe("DD-" + old.loadingScene);
		}
}

// onSplit
// {
//     vars.Log("Either Split at: " + old.loadingScene + " for Enemy or: " + current.loadingScene + " for Level");
// }

gameTime
{
	return TimeSpan.FromSeconds(vars.TotalIGT + vars.CurrentIGT - vars.StartOffset + 9);
}

isLoading
{
	return true;
}