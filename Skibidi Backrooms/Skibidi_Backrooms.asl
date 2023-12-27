state("MultiplayerBlueprintLobby-Win64-Shipping"){
	int paused : 0x5676B28;
	byte ingame : 0x57876AC;
	byte loading : 0x5676B2C;
    //loading values
    // Main Menu - 18 / 20 
    // Loading into Lobby - 24
    // Lobby - 24
    // Lobby Menu - 28
    // Loading - 8
    // In Game - 32
    // In Game Pause - 12 / 28
    // In Game Unpause - 6
    // don't press Esc multiple times potentially at this rate, do in one full run
}

startup
{
    vars.Log = (Action<object>)((output) => print("[Skibidi Backrooms]" + output));
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var timingMessage = MessageBox.Show (
			"This game uses Time without Loads (Game Time) as the main timing method.\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time?",
			"LiveSplit | Skibidi Backrooms",
			MessageBoxButtons.YesNo,MessageBoxIcon.Question
		);

		if (timingMessage == DialogResult.Yes)
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}
}

start
{
    return old.loading != 32 && current.loading == 32;
}

onStart
{
	timer.IsGameTimePaused = true;
}

// update
// {
// 	if(current.paused != old.paused) print("paused: " + current.paused.ToString());
// }

// split
// {
//     if (old.ingame == 95 && current.ingame == 0)
//     {
//         return true;
//     }
// }

isLoading
{
	if (current.loading == 8 || current.loading == 14 || current.loading == 18 || 
        current.loading == 20 || current.loading == 24 || current.loading == 28)
	{
		return true;
	}
	else if (current.loading == 6 || current.loading == 12 || 
            current.loading == 32 || current.loading == 36)
    {
        return false;
    }
}