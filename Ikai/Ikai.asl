state("Ikai-Win64-Shipping")
{
    int ChapterSaved : 0x04423B88, 0xED0, 0X0, 0X120, 0X78;
    string40 InGame : 0x045595B0, 0x8B0, 0X20;
    bool Pause : 0x045595B0, 0x8A8;
}

init
{
    vars.Log = (Action<object>)(value => print(String.Concat("[Ikai] ", value)));
    vars.doneMaps = new List<string>(); 
    vars.LastValue = 0; // The Value ChapterSaved gets constantly write that the old. doesn't work
    vars.Counter = 1;
    vars.SplitCounter = 0;
    vars.EndSplitDone = 0;
}

onStart
{
	print("\nNew run started!\n----------------\n");
}

startup
{
    settings.Add("missions", true, "Missions");

	vars.missions = new Dictionary<string,string> 
	{ 
        //{"243800", "start"},
        {"1", "grab broom"},
        {"2", "return to the real world"},
        {"3", "grab laundry"},
        {"4", "open puzzle door"},
        {"5", "idk lol"},
        {"6", "see no evil"},
        {"7", "right of the rick"},
        {"8", "trust no one"},
        {"9", "grab knife"},
        {"10", "fire escape"},
        {"11", "returning to the shrine"},
        {"12", "in shrine"},
        {"13", "entering damned shrine"},
        {"14", "grab mask"},
        {"15", "hand hallway"},
        {"16", "start drawing"},
        {"17", "see death "},
        {"18", "regrab mask"},
        {"19", "run away from uncle"},
        {"20", "push drawer"},
        {"21", "being locked behind the door"},
        {"22", "begind writing"},
        {"23", "lock door"},
        {"24", "open the metal lock"},
        {"25", "fall down hole"},
        {"26", "slide down tunnel"},
        {"27", "enter underground house"},
        {"28", "rope breaks"},
        {"29", "outside after climbing back up the rope"},
        {"30", "entering second shrine"},
        {"31", "through double doors"},
        {"32", "entering hallway to redo symbols"},
        {"33", "symbol remade"},
        {"34", "reach lamp"},
        {"35", "getting close to prized possessions"}, // (possible RNG)
        {"36", "seek for more ink"},
        {"37", "grab ink"},
        {"38", "seal made"}, // Guitar is random but missing strings
        {"39", "seal placed"},
        {"40", "enter red robe"}, // make sure all doors are closed
        {"41", "grab paper"},
        {"42", "return to the real world (again)"},
        {"43", "door opens"},
        {"44", "drawing puzzle"}, // super specific be accurate
        {"45", "grab katannae"},
        {"46", "drink alcohol"},
        {"47", "house fell on you"},
        {"48", "kill your sister"},
        {"49", "blindfolded by your sister"},
        {"50", "pickup sword off the floor"},
        {"51", "open sacred cabin"},
        {"52", "stab the door"}
	};
	foreach (var Tag in vars.missions)
	{
		settings.Add(Tag.Key, true, Tag.Value, "missions");
    };
}

start
{
    return ((current.ChapterSaved != 0) && (current.InGame != "MainMenu"));
    
}

onStart
{
    print("\nNew run started!\n----------------\n");
    vars.LastValue = current.ChapterSaved;
    vars.doneMaps.Add(current.ChapterSaved.ToString());
}

update
{
    if (old.ChapterSaved != current.ChapterSaved) vars.Log(String.Concat("ChapterSaved Value: ", current.ChapterSaved.ToString()));
}

split
{
    if (settings[vars.Counter.ToString()] && (!vars.doneMaps.Contains(current.ChapterSaved.ToString()) && (current.ChapterSaved != vars.LastValue)))
    {
        vars.LastValue = current.ChapterSaved;
        vars.Counter++;
        vars.SplitCounter++;
        vars.doneMaps.Add(current.ChapterSaved.ToString());
        return true;
    }
    if ((old.ChapterSaved == 1257295 || current.ChapterSaved == 1248150 || old.ChapterSaved == 1248150) && current.InGame == "MainMenu" && vars.EndSplitDone == 0)
    {
        vars.EndSplitDone++;
        return true;
    }
}

onSplit
{
	vars.Log(String.Concat("SplitCounter Number: ", vars.SplitCounter.ToString()));
    print("\nSplit\n-----\n");
    
}

reset
{
    if (current.InGame == "MainMenu" && old.ChapterSaved != 1257295 && current.ChapterSaved != 1248150)
    {
        return true;
    }
    
}

onReset
{
    vars.doneMaps.Clear();
    vars.Counter = 1;
    vars.SplitCounter = 0;
    print("\nRESET\n-----\n");
}

isLoading
{
    return (current.Pause == true);
}