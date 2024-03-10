state("REVEIL", "v1.0.3f4"){
	byte loading : "UnityPlayer.dll", 0x1C175C0, 0x220;
	byte endSplit : "GameAssembly.dll", 0x3027B60, 0x2B0, 0x170, 0x90, 0x148;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "REVEIL";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertGameTime();

	dynamic[,] _settings =
	{
		{ "Levels", true, "Levels", null },
			{ "Chapter 1", true, "Chapter 1", "Levels" },
				{ "Akt 1 - House", true, "Chapter 1 - House", "Chapter 1" },
				{ "Akt 1 - Circus_Day", true, "Chapter 1 - The Circus", "Chapter 1" },
				{ "Akt 1 - Circus_Funhouse", true, "Chapter 1 - Funhouse", "Chapter 1" },
				{ "Akt 0 - Part 1", true, "Chapter 1 - Strange Apartment", "Chapter 1" },
			{ "Chapter 2", true, "Chapter 2", "Levels" },
				{ "Akt 2 - House 1", true, "Chapter 2 - Home Together", "Chapter 2" },
				{ "Akt 2 - House 2", true, "Chapter 2 - Another Dream", "Chapter 2" },
				{ "Akt 2 - Train", true, "Chapter 2 - Circus Train", "Chapter 2" },
			{ "Chapter 3", true, "Chapter 3", "Levels" },
				{ "Akt 0 - Part 2", true, "Chapter 3  - A Phone Booth", "Chapter 3" },
				{ "Akt 3 - Circus_Night", true, "Chapter 3 - Fortune Teller", "Chapter 3" },
			{ "Chapter 4", true, "Chapter 4", "Levels" },
				{ "Akt 4 - Forest", true, "Chapter 4 - The Forest of Memories", "Chapter 4" },
				{ "Akt 4 - Ghosttrain", true, "Chapter 4 - Ghost Train", "Chapter 4" },
			{ "Chapter 5", true, "Chapter 5", "Levels" },
				{ "Akt 5 - House", true, "Chapter 5 - The House", "Chapter 5" },
				{ "Akt 5 - Facility1", true, "Chapter 5 - Facility", "Chapter 5" },
				{ "Akt 0 - Part 3", true, "Chapter 5 - The Apartment Again", "Chapter 5" },
				{ "Akt 5 - Facility2", true, "Chapter 5 - The Machine", "Chapter 5" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.VisitedLevel = new List<string>();
	
}

init
{
	current.activeScene = "";
	vars.facilityNo = 0;
	vars.facilityScene = "Akt 5 - Facility";

	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
    {
        using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            exeMD5HashBytes = md5.ComputeHash(s);
        }
    }

	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    vars.MD5Hash = MD5Hash;
    print("MD5: " + MD5Hash);

	switch(MD5Hash){
		case "20CD9AD2DD536DF5BA0775BB17A9ABC8" :
			version = "v1.0.3f4";
			break;
		default:
			version = "Unknown version";
			break;
	}
}

start
{
	return old.activeScene == "Main_Menu" && current.activeScene == "Akt 0 - Nightmare START";
}

onStart
{
	timer.IsGameTimePaused = true;
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loading != old.loading) vars.Log("Loading: " + current.loading.ToString());
}

split
{
	if (old.activeScene != current.activeScene)
	{
		if (!vars.VisitedLevel.Contains(current.activeScene))
		{
			if (current.activeScene == "Akt 5 - Facility")
			{ 	
				vars.facilityNo++;
				vars.facilityScene = "Akt 5 - Facility" + vars.facilityNo.ToString();
				vars.VisitedLevel.Add(vars.facilityScene.ToString());
				// vars.Log(vars.facilityScene.ToString());
				return settings[vars.facilityScene]; 
			}
			else if (current.activeScene != "Akt 5 - Facility")
			{
				vars.VisitedLevel.Add(current.activeScene);
				return settings[current.activeScene];
			}
		}
	}
	if (old.activeScene == "Akt 0 - Nightmare (Endings)" && 
		(current.activeScene == "Akt 5 - Exit Ending Facility" || 
		current.activeScene == "Akt Repeat - House"))
		{
			return old.endSplit == 1 && current.endSplit == 2;
		}
}

isLoading
{
	return current.loading == 2;
}

onReset
{
	vars.facilityNo = 0;
	vars.VisitedLevel.Clear();
}
