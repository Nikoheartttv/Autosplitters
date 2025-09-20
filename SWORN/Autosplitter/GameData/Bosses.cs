using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Livesplit.SWORN
{
    public static partial class GameData
    {

        public static Dictionary<string, string> Bosses { get; private set; } = new Dictionary<string, string>
        {
            { "Questing", "The Questing Beast" },
            { "Treant", "The Treant Scourge" },
            { "SirGawain", "Gawain, Butcher of Wirral" },
            { "Blight", "The Raving Blight" },
            { "MaulerRat", "Mauler Rat" },
            { "SirPercival", "Sir Percival, The Pestilent Overseer" },
            { "AbyssalWatcher", "The Abyssal Watcher" },
            { "GalvanicWitch", "The Galvanic Witch" },
            { "LadyBedivere", "Lady Bedivere" },
            { "KingArthur", "King Arthur, Lord of Camelot" },
            { "KingArthurTyrant", "King Arthur, Grail Corrupted Tyrant" },
            { "Morgana", "Morgana, The Mutinous Fae" },
            { "Morgana2", "Morgana, The Source Of Corruption" }
        };

        public static Dictionary<string, string> BossesInverted { get; private set; } = GetInvertedBosses();

        private static Dictionary<string, string> GetInvertedBosses()
        {
            var invertedBosses = new Dictionary<string, string>();

            foreach (var boss in Bosses)
                invertedBosses.Add(boss.Value, boss.Key);

            return invertedBosses;
        }

    }
}
