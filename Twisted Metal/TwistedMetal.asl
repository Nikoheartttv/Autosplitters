state("LiveSplit") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");

    vars.Helper.Load = (Func<dynamic, bool>)(emu => 
    {
        emu.Make<int>("MapNoNo", 0x8018ed04);
        emu.Make<int>("Win", 0x80197558);
        
        return true;
    });
}

init
{
    vars.RoofTopCombatWinCount = 0;
}

update
{
    if (old.MapNo != current.MapNo) print("MapNo: " + current.MapNo.ToString());
    if (old.Win != current.Win) print("Win: " + current.Win.ToString());
    if (current.MapNo == 6 && old.Win == 3 && current.Win == 0)
    {
        vars.RoofTopCombatWinCount++;
        print(vars.RoofTopCombatWinCount.ToString());
    }
}

split
{
    // Normal Splits
    if (current.MapNo != 6 && old.Win == 3 && current.Win == 0)
    {
        return true;
    }
    // Rooftop Combat Split
    if (current.MapNo == 6 && vars.RoofTopCombatWinCount == 2 && old.Win == 3 && current.Win == 0)
    {
        return true;
    }
}

onReset
{
    vars.RoofTopCombatWinCount = 0;
}