state("MultiplayerBlueprintLobby-Win64-Shipping"){
	int paused : 0x5676B28;
	byte gameStart : 0x57876AC;
	byte loading : 0x5676B2C;
}

state("MultiplayerBlueprintLobby-Win64-Shipping"){}

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
    // return old.gameStart == 0 && current.gameStart == 95;
    return old.loading != 32 && current.loading == 32;
}

onStart
{
	timer.IsGameTimePaused = true;
}

update
{
	if(current.paused != old.paused) print("paused: " + current.paused.ToString());
}

isLoading
{
	if (current.loading == 8 || current.loading == 14 || current.loading == 18 || 
        current.loading == 20 || current.loading == 24 || current.loading == 28)
	{
		return true;
	}
	else if (current.loading == 12 || current.loading == 32 || current.loading == 36)
    {
        return false;
    }
    
	// return current.gameStart == 0;
}