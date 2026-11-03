// PresentMon 2.x CSV (etl_file modu, --date_time) icin kare kararliligi (akicilik) ozeti. Measure-FrameLatency.ps1 ve Compare-PowerPlan.ps1 kullanir.
// Pencere FrameLatencyStats ile ayni: son karenin zamanindan geriye [son - fromEnd0, son - fromEnd1).
// Donus dizisi (indeks: anlam):
//  0 kare sayisi | 1 kare suresi ort | 2 kare suresi std sapma | 3 p50 | 4 p99 | 5 p99.9 | 6 maks
//  7 kareden kareye fark |dt| ort | 8 |dt| p99 | 9 |dt| p99.9
// 10 saniyelik en kotu kare: medyan | 11 saniyelik en kotu kare: p95 | 12 saniye sayisi
// 13 kare > 4 ms | 14 kare > 6 ms | 15 kare > 8 ms
// 16 |animasyon hatasi| ort | 17 |animasyon hatasi| p99 | 18 |animasyon hatasi| p99.9 | 19 animasyon hatasi n
// 20 simulasyon araligi std sapma | 21 simulasyon araligi |dt| ort
// 22 PC gecikmesi ort | 23 PC gecikmesi std sapma | 24 PC gecikmesi p99 | 25 PC gecikmesi p99.9
// Zaman damgalari sifirsiz olabilir ("2026-11-3 1:08:29.36"); ':' ile bolunerek okunur. Gece yarisi donusu duzeltilir. Yalniz ASCII.
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;

public static class FrameStabilityStats
{
    static readonly CultureInfo Ic = CultureInfo.InvariantCulture;
    static double Sec(string s)
    {
        int i = s.IndexOf(' ');
        string[] t = s.Substring(i + 1).Split(':');
        return int.Parse(t[0], Ic) * 3600 + int.Parse(t[1], Ic) * 60 + double.Parse(t[2], NumberStyles.Float, Ic);
    }
    static double P(List<double> v, double p) { if (v.Count == 0) return double.NaN; return v[Math.Min(v.Count - 1, (int)Math.Floor(p / 100.0 * v.Count))]; }
    static double Sd(List<double> v) { if (v.Count < 2) return double.NaN; double m = v.Average(); double s = 0; foreach (double x in v) s += (x - m) * (x - m); return Math.Sqrt(s / (v.Count - 1)); }
    static bool Num(string s, out double v) { return double.TryParse(s, NumberStyles.Float, Ic, out v); }

    public static double[] Run(string csv, string app, double fromEnd0, double fromEnd1)
    {
        string[] lines = File.ReadAllLines(csv);
        string[] h = lines[0].TrimStart((char)0xFEFF).Split(',');
        int iA = Array.IndexOf(h, "Application"), iT = Array.IndexOf(h, "TimeInDateTime"), iB = Array.IndexOf(h, "MsBetweenPresents"),
            iP = Array.IndexOf(h, "MsPCLatency"), iE = Array.IndexOf(h, "MsAnimationError"), iS = Array.IndexOf(h, "MsBetweenSimulationStart");
        var t = new double[lines.Length];
        double first = double.NaN, last = double.MinValue;
        for (int k = 1; k < lines.Length; k++)
        {
            string[] f = lines[k].Split(',');
            if (f.Length < h.Length || !string.Equals(f[iA], app, StringComparison.OrdinalIgnoreCase)) { t[k] = double.NaN; continue; }
            double x = Sec(f[iT]);
            if (double.IsNaN(first)) first = x;
            if (x < first - 43200) x += 86400;
            t[k] = x; if (x > last) last = x;
        }
        double a = last - fromEnd0, b = last - fromEnd1;
        var ft = new List<double>(); var dft = new List<double>(); var ae = new List<double>(); var sim = new List<double>(); var dsim = new List<double>(); var pcl = new List<double>();
        var worst = new Dictionary<int, double>();
        double prevFt = double.NaN, prevSim = double.NaN;
        for (int k = 1; k < lines.Length; k++)
        {
            if (double.IsNaN(t[k]) || t[k] < a || t[k] >= b) continue;
            string[] f = lines[k].Split(',');
            double v;
            if (Num(f[iB], out v))
            {
                ft.Add(v);
                if (!double.IsNaN(prevFt)) dft.Add(Math.Abs(v - prevFt));
                prevFt = v;
                int sec = (int)Math.Floor(t[k] - a);
                double w; if (!worst.TryGetValue(sec, out w) || v > w) worst[sec] = v;
            }
            double e; if (iE >= 0 && Num(f[iE], out e)) ae.Add(Math.Abs(e));
            double s; if (iS >= 0 && Num(f[iS], out s)) { sim.Add(s); if (!double.IsNaN(prevSim)) dsim.Add(Math.Abs(s - prevSim)); prevSim = s; }
            double pc; if (iP >= 0 && Num(f[iP], out pc)) pcl.Add(pc);
        }
        double ftAvg = ft.Count > 0 ? ft.Average() : double.NaN, ftSd = Sd(ft);
        double simSd = Sd(sim), pclAvg = pcl.Count > 0 ? pcl.Average() : double.NaN, pclSd = Sd(pcl);
        var ws = worst.Values.ToList();
        ft.Sort(); dft.Sort(); ae.Sort(); pcl.Sort(); ws.Sort();
        return new double[] {
            ft.Count, ftAvg, ftSd, P(ft, 50), P(ft, 99), P(ft, 99.9), ft.Count > 0 ? ft[ft.Count - 1] : double.NaN,
            dft.Count > 0 ? dft.Average() : double.NaN, P(dft, 99), P(dft, 99.9),
            P(ws, 50), P(ws, 95), ws.Count,
            ft.Count(x => x > 4.0), ft.Count(x => x > 6.0), ft.Count(x => x > 8.0),
            ae.Count > 0 ? ae.Average() : double.NaN, P(ae, 99), P(ae, 99.9), ae.Count,
            simSd, dsim.Count > 0 ? dsim.Average() : double.NaN,
            pclAvg, pclSd, P(pcl, 99), P(pcl, 99.9) };
    }
}
