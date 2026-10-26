// NT Kernel Logger ETL dosyasindaki DPC/ISR olaylarini okur (salt okunur, surucu yok).
// Sure = olay zaman damgasi (DPC/ISR bitisi) - InitialTime (giris), ikisi de ham QPC (PROCESS_TRACE_MODE_RAW_TIMESTAMP).
// Rutin adresi, ayni izdeki Image (DCStart/Load/DCEnd) olaylariyla surucu adina eslenir.
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

public static class DpcEtl
{
    const uint RAW_TIMESTAMP = 0x00001000, EVENT_RECORD = 0x10000000;
    static readonly Guid PerfInfo = new Guid("ce1dbfb4-137e-4da6-87b0-3f59aa102cbc");
    static readonly Guid ImageG = new Guid("2cb15d1d-5fc1-11d2-abe1-00a0c911f518");

    [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate void RecCb(IntPtr rec);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct LOGFILE
    {
        [MarshalAs(UnmanagedType.LPWStr)] public string LogFileName;
        [MarshalAs(UnmanagedType.LPWStr)] public string LoggerName;
        public long CurrentTime;
        public uint BuffersRead;
        public uint ProcessTraceMode;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 88)] public byte[] CurrentEvent;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 280)] public byte[] Header;
        public IntPtr BufferCallback;
        public uint BufferSize, Filled, EventsLost;
        public IntPtr EventRecordCallback;
        public uint IsKernelTrace;
        public IntPtr Context;
    }

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, EntryPoint = "OpenTraceW", SetLastError = true)] static extern ulong OpenTrace(ref LOGFILE lf);
    [DllImport("advapi32.dll")] static extern uint ProcessTrace(ulong[] h, uint n, IntPtr s, IntPtr e);
    [DllImport("advapi32.dll")] static extern uint CloseTrace(ulong h);

    class Agg { public long N; public double Sum, Max; public long Over100, Over500, Over1000; }
    class Img { public ulong Base, Size; public string Name; }

    static RecCb cbKeep;
    static List<float> dpcUs, isrUs;
    static Dictionary<ulong, Agg> dpcR, isrR;
    static Dictionary<int, double> cpuUs; static Dictionary<int, long> cpuN;
    static List<Img> imgs;
    static long firstTs, lastTs, bad;

    static void Add(Dictionary<ulong, Agg> d, ulong r, double us)
    {
        Agg a; if (!d.TryGetValue(r, out a)) { a = new Agg(); d[r] = a; }
        a.N++; a.Sum += us; if (us > a.Max) a.Max = us;
        if (us > 100) a.Over100++; if (us > 500) a.Over500++; if (us > 1000) a.Over1000++;
    }

    static double freq;
    static void OnEvent(IntPtr r)
    {
        long ts = Marshal.ReadInt64(r, 16);
        byte[] g = new byte[16]; Marshal.Copy(r + 24, g, 0, 16); var prov = new Guid(g);
        byte op = Marshal.ReadByte(r, 45);
        int cpu = Marshal.ReadByte(r, 80);
        int len = (ushort)Marshal.ReadInt16(r, 86);
        IntPtr ud = Marshal.ReadIntPtr(r, 96);
        // 66 ThreadedDPC, 68 DPC, 69 TimerDPC; 67 ISR, 50 ISR-MSI
        if (prov == PerfInfo && (op == 50 || op == 66 || op == 67 || op == 68 || op == 69) && len >= 16)
        {
            long init = Marshal.ReadInt64(ud, 0);
            ulong routine = (ulong)Marshal.ReadInt64(ud, 8);
            double us = (ts - init) * 1e6 / freq;
            if (us < 0 || us > 1e6) { bad++; return; }
            if (firstTs == 0 || ts < firstTs) firstTs = ts; if (ts > lastTs) lastTs = ts;
            if (op == 67 || op == 50) { isrUs.Add((float)us); Add(isrR, routine, us); } else { dpcUs.Add((float)us); Add(dpcR, routine, us); }
            double c; cpuUs.TryGetValue(cpu, out c); cpuUs[cpu] = c + us;
            long n; cpuN.TryGetValue(cpu, out n); cpuN[cpu] = n + 1;
        }
        else if (prov == ImageG && (op == 3 || op == 4 || op == 10) && len > 58)
        {
            ulong b = (ulong)Marshal.ReadInt64(ud, 0), s = (ulong)Marshal.ReadInt64(ud, 8);
            if (b < 0xFFFF800000000000UL) return; // yalniz cekirdek alani (suruculer)
            string name = Marshal.PtrToStringUni(ud + 56);
            imgs.Add(new Img { Base = b, Size = s, Name = Path.GetFileName(name ?? "?") });
        }
    }

    static string Mod(ulong a)
    {
        foreach (var i in imgs) if (a >= i.Base && a < i.Base + i.Size) return i.Name;
        return "bilinmiyor";
    }

    static double Pct(List<float> v, double p) { if (v.Count == 0) return 0; return v[Math.Min(v.Count - 1, (int)Math.Floor(p / 100.0 * v.Count))]; }

    public static string Analyze(string etl, string csvOut)
    {
        dpcUs = new List<float>(); isrUs = new List<float>(); dpcR = new Dictionary<ulong, Agg>(); isrR = new Dictionary<ulong, Agg>();
        cpuUs = new Dictionary<int, double>(); cpuN = new Dictionary<int, long>(); imgs = new List<Img>(); firstTs = lastTs = bad = 0;
        freq = System.Diagnostics.Stopwatch.Frequency;
        cbKeep = OnEvent;
        var lf = new LOGFILE { LogFileName = etl, ProcessTraceMode = RAW_TIMESTAMP | EVENT_RECORD, CurrentEvent = new byte[88], Header = new byte[280], EventRecordCallback = Marshal.GetFunctionPointerForDelegate(cbKeep) };
        ulong h = OpenTrace(ref lf);
        if (h == ulong.MaxValue) throw new Exception("OpenTrace hata " + Marshal.GetLastWin32Error());
        long hf = BitConverter.ToInt64(lf.Header, 256); if (hf > 0) freq = hf;
        uint lost = BitConverter.ToUInt32(lf.Header, 48), blost = BitConverter.ToUInt32(lf.Header, 276);
        uint rc = ProcessTrace(new[] { h }, 1, IntPtr.Zero, IntPtr.Zero);
        CloseTrace(h);
        imgs = imgs.GroupBy(i => i.Base).Select(x => x.First()).ToList();

        var sb = new StringBuilder(); var ic = CultureInfo.InvariantCulture;
        double sec = (lastTs - firstTs) / freq;
        dpcUs.Sort(); isrUs.Sort();
        sb.AppendLine(string.Format(ic, "Iz suresi {0:0.0} sn | QPC {1} Hz | kayip olay {2}, kayip tampon {3}, gecersiz {4} | surucu imaji {5} | ProcessTrace {6}", sec, freq, lost, blost, bad, imgs.Count, rc));
        foreach (var t in new[] { new { N = "DPC", V = dpcUs }, new { N = "ISR", V = isrUs } })
            sb.AppendLine(string.Format(ic, "{0}: {1} adet ({2:0}/sn) | sure us: medyan {3:0.0}  p99 {4:0.0}  p99.9 {5:0.0}  maks {6:0.0} | >100us {7}  >500us {8}  >1000us {9}",
                t.N, t.V.Count, t.V.Count / Math.Max(sec, 1e-9), Pct(t.V, 50), Pct(t.V, 99), Pct(t.V, 99.9), t.V.Count > 0 ? t.V[t.V.Count - 1] : 0,
                t.V.Count(x => x > 100), t.V.Count(x => x > 500), t.V.Count(x => x > 1000)));
        sb.AppendLine("CPU basina (DPC+ISR): adet | toplam sure % (iz suresine gore)");
        foreach (var k in cpuN.Keys.OrderBy(x => x))
            sb.AppendLine(string.Format(ic, "  CPU {0,2}: {1,8} | %{2:0.00}", k, cpuN[k], cpuUs[k] / (sec * 1e6) * 100));

        var rows = new List<string> { "\"Tur\",\"Surucu\",\"Adet\",\"Adet_sn\",\"Ort_us\",\"Maks_us\",\"Toplam_ms\",\"Gt100us\",\"Gt500us\",\"Gt1000us\"" };
        foreach (var t in new[] { new { N = "DPC", D = dpcR }, new { N = "ISR", D = isrR } })
        {
            var byMod = t.D.GroupBy(kv => Mod(kv.Key)).Select(gp => new
            {
                M = gp.Key, N = gp.Sum(x => x.Value.N), S = gp.Sum(x => x.Value.Sum), Mx = gp.Max(x => x.Value.Max),
                O1 = gp.Sum(x => x.Value.Over100), O5 = gp.Sum(x => x.Value.Over500), O10 = gp.Sum(x => x.Value.Over1000)
            }).OrderByDescending(x => x.Mx).ToList();
            sb.AppendLine(t.N + " surucu bazinda (en yuksek sureye gore):");
            sb.AppendLine("  Surucu                    adet     /sn   ort us  maks us  toplam ms  >100  >500  >1000");
            foreach (var m in byMod.Take(12))
                sb.AppendLine(string.Format(ic, "  {0,-24} {1,7} {2,7:0} {3,8:0.0} {4,8:0.0} {5,10:0.0} {6,5} {7,5} {8,6}", m.M, m.N, m.N / sec, m.S / m.N, m.Mx, m.S / 1000, m.O1, m.O5, m.O10));
            foreach (var m in byMod)
                rows.Add(string.Format(ic, "\"{0}\",\"{1}\",{2},{3:0.0},{4:0.00},{5:0.0},{6:0.000},{7},{8},{9}", t.N, m.M, m.N, m.N / sec, m.S / m.N, m.Mx, m.S / 1000, m.O1, m.O5, m.O10));
        }
        if (!string.IsNullOrEmpty(csvOut)) File.WriteAllLines(csvOut, rows, new UTF8Encoding(false));
        return sb.ToString();
    }
}
