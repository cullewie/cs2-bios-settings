// PresentMon 2.x CSV (--date_time, v2 metrikleri) akisla okunur; verilen zaman pencereleri (yerel saat, gunun saniyesi) icin ozet.
// Gecikme (kare baslangici -> ekran) = (TimeInDateTime - CPUStartDateTime) + MsUntilDisplayed, yalniz ekrana cikan kareler.
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

public static class PmRapor
{
    class W
    {
        public string Name; public double A, B;
        public List<double> Ft = new List<double>(), Lat = new List<double>(), Ud = new List<double>();
        public double CpuBusy, GpuBusy, GpuWait, CpuWait, InPresent; public long N, Shown, Busy;
        public Dictionary<string, long> Modes = new Dictionary<string, long>();
    }

    static double Sec(string s) // "YYYY-MM-DD hh:mm:ss.fffffffff" -> gunun saniyesi
    {
        int i = s.IndexOf(' ');
        string t = s.Substring(i + 1);
        return int.Parse(t.Substring(0, 2)) * 3600 + int.Parse(t.Substring(3, 2)) * 60 + double.Parse(t.Substring(6), CultureInfo.InvariantCulture);
    }
    static bool D(string s, out double v) { return double.TryParse(s, NumberStyles.Float, CultureInfo.InvariantCulture, out v); }
    static double P(List<double> v, double p) { if (v.Count == 0) return double.NaN; return v[Math.Min(v.Count - 1, (int)Math.Floor(p / 100.0 * v.Count))]; }

    // wins: "ad=bas-bit;..." bas/bit gunun saniyesi (yerel). offsetSec: PresentMon saati - yerel saat.
    public static string Run(string csv, string wins, double offsetSec)
    {
        var ws = new List<W>();
        foreach (var part in wins.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
        {
            var kv = part.Split('='); var ab = kv[1].Split('-');
            ws.Add(new W { Name = kv[0], A = double.Parse(ab[0], CultureInfo.InvariantCulture), B = double.Parse(ab[1], CultureInfo.InvariantCulture) });
        }
        using (var sr = new StreamReader(csv))
        {
            var h = sr.ReadLine().Split(',');
            Func<string, int> c = n => Array.IndexOf(h, n);
            int iMode = c("PresentMode"), iT = c("TimeInDateTime"), iCs = c("CPUStartDateTime"), iBp = c("MsBetweenPresents"), iUd = c("MsUntilDisplayed"),
                iCb = c("MsCPUBusy"), iCw = c("MsCPUWait"), iGb = c("MsGPUBusy"), iGw = c("MsGPUWait"), iIp = c("MsInPresentAPI");
            string line;
            while ((line = sr.ReadLine()) != null)
            {
                var f = line.Split(',');
                if (f.Length < h.Length) continue;
                double t = Sec(f[iT]) - offsetSec;
                W w = null; foreach (var x in ws) if (t >= x.A && t < x.B) { w = x; break; }
                if (w == null) continue;
                double bp; if (!D(f[iBp], out bp)) continue;
                w.N++; w.Ft.Add(bp);
                long m; w.Modes.TryGetValue(f[iMode], out m); w.Modes[f[iMode]] = m + 1;
                double v;
                if (D(f[iCb], out v)) { w.CpuBusy += v; w.Busy++; }
                if (D(f[iCw], out v)) w.CpuWait += v;
                if (D(f[iGb], out v)) w.GpuBusy += v;
                if (D(f[iGw], out v)) w.GpuWait += v;
                if (D(f[iIp], out v)) w.InPresent += v;
                double ud;
                if (D(f[iUd], out ud))
                {
                    w.Shown++; w.Ud.Add(ud);
                    double cs = Sec(f[iCs]) - offsetSec;
                    w.Lat.Add((t - cs) * 1000 + ud);
                }
            }
        }
        var ic = CultureInfo.InvariantCulture; var sb = new StringBuilder();
        sb.AppendLine("Kosu  kare     Avg     P1    P0.1 | gecikme(bas->ekran) ort  p50   p99  | sunum->ekran ort | ekrana cikan % | CPUBusy GPUBusy CPUWait GPUWait InPresent | mod");
        foreach (var w in ws)
        {
            if (w.N == 0) { sb.AppendLine(w.Name + "  veri yok"); continue; }
            double avgFt = w.Ft.Average(); w.Ft.Sort(); w.Lat.Sort();
            string mode = string.Join(" ", w.Modes.OrderByDescending(x => x.Value).Select(x => x.Key.Replace("Hardware: ", "HW:").Replace(" ", "") + "=" + (100.0 * x.Value / w.N).ToString("0.#", ic) + "%"));
            sb.AppendLine(string.Format(ic, "{0,-4} {1,6} {2,7:0.0} {3,6:0.0} {4,6:0.0} |        {5,6:0.000} {6,6:0.000} {7,6:0.000} |     {8,6:0.000}     |     {9,5:0.0}     | {10,6:0.000} {11,6:0.000} {12,6:0.000} {13,6:0.000} {14,6:0.000} | {15}",
                w.Name, w.N, 1000 / avgFt, 1000 / P(w.Ft, 99), 1000 / P(w.Ft, 99.9), w.Lat.Count > 0 ? w.Lat.Average() : double.NaN, P(w.Lat, 50), P(w.Lat, 99),
                w.Ud.Count > 0 ? w.Ud.Average() : double.NaN, 100.0 * w.Shown / w.N,
                w.CpuBusy / w.Busy, w.GpuBusy / w.Busy, w.CpuWait / w.Busy, w.GpuWait / w.Busy, w.InPresent / w.Busy, mode));
        }
        return sb.ToString();
    }
}
