using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace Livesplit.SWORN
{
    public static class Utility
    {
        public static void Log(object value)
        {
            if (value == null) value = String.Empty;
            Trace.WriteLine(value.ToString());
        }

        public static string StripHtmlTags(string value)
        {
            if (value == null) return null;
            return Regex.Replace(value, "<.*?>", string.Empty);
        }
    }
}
