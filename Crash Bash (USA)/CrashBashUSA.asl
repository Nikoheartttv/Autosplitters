state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");

	// var levels = new Dictionary<string, string>()
	// {
	// 	{ "14", "Crashball" },
	// 	{ "19", "Polar Panic" },
	// 	{ "10", "Pogo Painter" },
	// 	{ "0", "Jungle Bash" },
	// 	{ "4", "Papu Pummel" },
	// 	{ "15", "Beach Ball" },
	// 	{ "18", "Tilt Panic" },
	// 	{ "11", "Pogo-a-Gogo" },
	// 	{ "1", "Space Bash" },
	// 	{ "6", "Desert Fox" },
	// 	{ "22", "Bearminator" },
	// 	{ "16", "N. Ballism" },
	// 	{ "20", "Melt Panic" },
	// 	{ "12", "El Pogo Loco" },
	// 	{ "2", "Snow Bash" },
	// 	{ "8", "Metal Fox" },
	// 	{ "23", "Dot Dash" },
	// 	{ "9", "Big Bad Fox" },
	// 	{ "17", "Sky Balls" },
	// 	{ "21", "Manic Panic" },
	// 	{ "13", "Pogo Padlock" },
	// 	{ "3", "Drain Bash" },
	// 	{ "7", "Jungle Fox" },
	// 	{ "24", "Toxic Dash" },
	// 	{ "27", "Ring Ding" },
	// 	{ "31", "Oxide Ride" },
	// 	{ "25", "Splash Dash" },
	// 	{ "28", "Dragon Drop" },
	// 	{ "29", "Mallet Mash" },
	// 	{ "5", "Swamp Fox" },
	// 	{ "30", "Keg Kaboom" },
	// 	{ "32", "Dante's Dash" },
	// };

	// settings.Add("levels", true, "Split on end of level");
	// foreach (var level in levels.Keys)
	// {
	// 	settings.Add(level, true, levels[level], "levels");
	// }

	vars.CompletedSplits = new HashSet<string>();
}

init
{
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		// emu.Make<byte>("GameMode", 0x8005a63b);
		emu.Make<byte>("SceneID", 0x8005A648);
		emu.Make<byte>("OxideCompletion", 0x8005A79B);
		emu.Make<byte>("Loading", 0x800A0292);
		// emu.Make<int>("CharacterChoice", 0x8005a660);

		// Trophys
		emu.Make<byte>("TrophyCrashball", 0x8005a706);
		emu.Make<byte>("TrophyPolarPanic", 0x8005a70b);
		emu.Make<byte>("TrophyPogoPainter", 0x8005a702);
		emu.Make<byte>("TrophyJungleBash", 0x8005a702);

		return true;
	});
	vars.PreLoading = 0;
}

start
{
	// you have control immediately after loading
	// potential manual trigger for start time?
	return current.SceneID == 33 && old.Loading == 28 && current.Loading == 0;
}
update
{
	if (old.SceneID != current.SceneID) print("SceneID: " + current.SceneID.ToString());
	// if (old.OxideCompletion != current.OxideCompletion) print("OxideCompletion: " + current.OxideCompletion.ToString());
	if (old.Loading != current.Loading) print("Loading: " + current.Loading.ToString());
	if (old.TrophyCrashball != current.TrophyCrashball) print("TrophyCrashball: " + current.TrophyCrashball.ToString());

}

split
{
	// main splitting idea
	// once trophy has been achieved, split once SceneID changes
	// so needs to be a TrophyXXX check then against the settings
	// only issue with above var levels is it SPAMS "can't find 33"

	// below is kind of concept
	// 	if (settings[old.SceneID.ToString()] && !vars.CompletedSplits.Contains(old.SceneID.ToString())
	// 		&& old.SceneID != current.Scene && current.TrophyCrashball == 1 && current.SceneID == 33)
	// 	{
	// 		vars.CompletedSplits.Add(old.SceneID.ToString());
	//         return true;
	// 	}

	// this works
	if (!vars.CompletedSplits.Contains(old.SceneID.ToString())
		&& old.SceneID == 14 && current.SceneID == 33 && current.TrophyCrashball == 1)
	{
		vars.CompletedSplits.Add(old.SceneID.ToString());
        return true;
	}
}

onReset
{
}