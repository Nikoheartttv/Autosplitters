state("LiveSplit") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");

    vars.Helper.Load = (Func<dynamic, bool>)(emu => 
    {
        emu.Make<int>("TargetsLeft", 0x800d3234);
        emu.Make<int>("inGame", 0x800d2d40);
        emu.Make<int>("ChosenWorld", 0x800d27b8);
        emu.Make<int>("TournamentWon", 0x800d2d68);
        emu.Make<int>("LevelWin", 0x800d2d6c);
        emu.Make<int>("Map", 0x801fff10);
        
        return true;
    });
}

init
{
    vars.mapWinCondition = false;
}

start
{
    return old.inGame != current.inGame && current.inGame == 3;
}

split
{
    if (current.Map != 35 && vars.mapWinCondition == true && old.TargetsLeft == 1 && current.TargetsLeft == 0)
    {
        vars.mapWinCondition = false;
        return true;
    }

    if (current.Map == 35 && old.TournamentWon == 0 && current.TournamentWon == 1)
    {
        return true;
    }
}

update
{
    if (old.TargetsLeft != current.TargetsLeft) print("Targets Left: " + current.TargetsLeft.ToString());
    if (old.inGame != current.inGame) print("inGame: " + current.inGame.ToString());
    if (old.ChosenWorld != current.ChosenWorld) print("ChosenWorld: " + current.ChosenWorld.ToString());
    if (old.TournamentWon != current.TournamentWon) print("TournamentWon: " + current.TournamentWon.ToString());
    if (old.LevelWin != current.LevelWin) print("LevelWin: " + current.LevelWin.ToString());
    if (old.Map != current.Map) print("Map: " + current.Map.ToString());

    if(old.LevelWin == 0 && current.LevelWin == 1)
    {
        vars.mapWinCondition = true;
    }
}

onReset
{
    vars.mapWinCondition = false;
}