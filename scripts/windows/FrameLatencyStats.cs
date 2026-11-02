// PresentMon 2.x CSV (etl_file modu, date_time) ozetleyici. Measure-FrameLatency.ps1 kullanir.
// Pencere, son karenin zamanindan geriye saniye cinsinden verilir: [son - fromEnd0, son - fromEnd1).
// Zaman damgalari sifirsiz olabilir ("2026-11-3 1:08:29.36"), bu yuzden ':' ile bolunerek okunur. Gece yarisi donusu duzeltilir.
// Donus: kare, FPS, kare suresi p50/p99/p99.9, takilma (kare > 2 x medyan), kare > 4 ms, kare baslangici->ekran ort/p50/p99, PC gecikmesi n/ort/p50/p99.
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;

public static class FrameLatencyStats
{
    static readonly CultureInfo Ic = CultureInfo.InvariantCulture;
    static double Sec(string s)
    {
        int i = s.IndexOf(' ');
        string[] t = s.Substring(i + 1).Split(':');
        return int.Parse(t[0], Ic) * 3600 + int.Parse(t[1], Ic) * 60 + double.Parse(t[2], NumberStyles.Float, Ic);
    }
    static double P(List<double> v, double p) { if (v.Count == 0) return double.NaN; return v[Math.Min(v.Count - 1, (int)Math.Floor(p / 100.0 * v.Count))]; }

    public static double[] Run(string csv, string app, double fromEnd0, double fromEnd1)
    {
        string[] lines = File.ReadAllLines(csv);
        string[] h = lines[0].Split(',');
        int iA = Array.IndexOf(h, "Application"), iT = Array.IndexOf(h, "TimeInDateTime"), iC = Array.IndexOf(h, "CPUStartDateTime"),
            iU = Array.IndexOf(h, "MsUntilDisplayed"), iB = Array.IndexOf(h, "MsBetweenPresents"), iP = Array.IndexOf(h, "MsPCLatency");
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
        var ft = new List<double>(); var lat = new List<double>(); var pcl = new List<double>();
        for (int k = 1; k < lines.Length; k++)
        {
            if (double.IsNaN(t[k]) || t[k] < a || t[k] >= b) continue;
            string[] f = lines[k].Split(',');
            double v;
            if (double.TryParse(f[iB], NumberStyles.Float, Ic, out v)) ft.Add(v);
            double u;
            if (double.TryParse(f[iU], NumberStyles.Float, Ic, out u))
            {
                double cs = Sec(f[iC]); if (cs < first - 43200) cs += 86400;
                lat.Add((t[k] - cs) * 1000.0 + u);
            }
            double pc;
            if (iP >= 0 && double.TryParse(f[iP], NumberStyles.Float, Ic, out pc)) pcl.Add(pc);
        }
        double avgFt = ft.Count > 0 ? ft.Average() : double.NaN;
        ft.Sort(); lat.Sort(); pcl.Sort();
        double med = P(ft, 50);
        int stutter = ft.Count(x => x > 2.0 * med);
        int over4 = ft.Count(x => x > 4.0);
        return new double[] { ft.Count, 1000.0 / avgFt, med, P(ft, 99), P(ft, 99.9), stutter, over4,
            lat.Count > 0 ? lat.Average() : double.NaN, P(lat, 50), P(lat, 99),
            pcl.Count, pcl.Count > 0 ? pcl.Average() : double.NaN, P(pcl, 50), P(pcl, 99) };
    }
}
