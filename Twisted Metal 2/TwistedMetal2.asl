state("LiveSplit") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");
    vars.Helper.Load = (Func<dynamic, bool>)(emu => 
    {
        emu.Make<int>("Start", 0x8019B4F8);
        emu.Make<int>("MapNo", 0x80164774);
        emu.Make<int>("Win", 0x80181170);
         
        return true;
    });
    settings.Add("Run", true, "Run Type");
        settings.Add("Deathmatch", true, "Deathmatch", "Run");
        settings.Add("Challenge", false, "Challenge", "Run");
}

init
{
    vars.AmazonianWinCount = 0;
    vars.HongKongWinCount = 0;
}

start
{
    if (settings["Deathmatch"])
    {
        return old.Start == 0 && current.Start == 8;
    }
    
}
update
{
    if (old.Start != current.Start) print("Start: " + current.Start.ToString());
    if (old.MapNo != current.MapNo) print("MapNo: " + current.MapNo.ToString());
    if (old.Win != current.Win) print("Win: " + current.Win.ToString());
    if (current.MapNo == 4 && old.Win == 3 && current.Win == 0)
    {
        vars.AmazonianWinCount++;
        print(vars.AmazonianWinCount.ToString());
    }
    if (current.MapNo == 8 && old.Win == 3 && current.Win == 0)
    {
        vars.HongKongWinCount++;
        print(vars.HongKongWinCount.ToString());
    }
}

split
{
    // Normal Splits
    if (current.MapNo != 4 && current.MapNo != 8 && old.Win == 3 && current.Win == 0)
    {
        return true;
    }
    // Amazonian Split
    if (current.MapNo == 4 && vars.AmazonianWinCount == 2 && old.Win == 3 && current.Win == 0)
    {
        return true;
    }
    // HongKong Split
    if (current.MapNo == 8 && vars.HongKongWinCount == 3 && old.Win == 3 && current.Win == 0)
    {
        return true;
    }
}

onReset
{
    vars.AmazonianWinCount = 0;
    vars.HongKongWinCount = 0;
}