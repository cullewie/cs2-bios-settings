# Minidump ozeti (23.10, CS2 cokmesi): istisna kodu/adresi, hatali modul + ofset, cokme anindaki yigindan (Rsp'den yukari) modul icine dusen degerler (sezgisel).
# Salt okunur. Kullanim: Get-DumpSummary.ps1 -Path <dosya.dmp|.mdmp> [-StackHits 30]
param([Parameter(Mandatory = $true)][string]$Path, [int]$StackHits = 30)
Add-Type @'
using System; using System.IO; using System.Text; using System.Collections.Generic;
public static class MiniDump {
  public class Mod { public ulong Base; public uint Size; public string Name; }
  static byte[] b;
  static uint U32(long o) { return BitConverter.ToUInt32(b, (int)o); }
  static ulong U64(long o) { return BitConverter.ToUInt64(b, (int)o); }
  static string Str(uint rva) { uint len = U32(rva); return Encoding.Unicode.GetString(b, (int)rva + 4, (int)len); }
  public static string Run(string path, int hits) {
    b = File.ReadAllBytes(path);
    var sb = new StringBuilder();
    if (U32(0) != 0x504D444D) return "MDMP imzasi yok";
    uint n = U32(8), dir = U32(12);
    long exc = -1, mods = -1, threads = -1, mem64 = -1, mem = -1;
    for (uint i = 0; i < n; i++) { long d = dir + i * 12; uint t = U32(d); uint rva = U32(d + 8);
      if (t == 6) exc = rva; else if (t == 4) mods = rva; else if (t == 3) threads = rva; else if (t == 9) mem64 = rva; else if (t == 5) mem = rva; }
    var ml = new List<Mod>();
    if (mods >= 0) { uint mc = U32(mods); for (uint i = 0; i < mc; i++) { long m = mods + 4 + i * 108; ml.Add(new Mod { Base = U64(m), Size = U32(m + 8), Name = Path.GetFileName(Str(U32(m + 20))) }); } }
    Func<ulong, string> Where = a => { foreach (var m in ml) if (a >= m.Base && a < m.Base + m.Size) return m.Name + "+0x" + (a - m.Base).ToString("X"); return null; };
    if (exc < 0) { sb.AppendLine("istisna akisi yok"); return sb.ToString(); }
    uint tid = U32(exc); uint code = U32(exc + 8); ulong addr = U64(exc + 24); uint np = U32(exc + 32);
    sb.AppendLine(string.Format("istisna: kod 0x{0:X8} | adres 0x{1:X} = {2} | is parcacigi {3}", code, addr, Where(addr) ?? "(modul disi)", tid));
    var ps = new List<string>(); for (uint i = 0; i < np && i < 4; i++) ps.Add("0x" + U64(exc + 40 + i * 8).ToString("X")); sb.AppendLine("parametreler: " + string.Join(", ", ps));
    uint ctxSize = U32(exc + 160), ctxRva = U32(exc + 164);
    ulong rsp = 0, rip = 0; if (ctxSize >= 0x100) { rsp = U64(ctxRva + 0x98); rip = U64(ctxRva + 0xF8); sb.AppendLine(string.Format("baglam: Rip 0x{0:X} ({1}) Rsp 0x{2:X}", rip, Where(rip) ?? "?", rsp)); }
    // yigin: is parcacigi listesindeki yigin bellegi (Rsp'den itibaren)
    if (threads >= 0 && rsp != 0) { uint tc = U32(threads);
      for (uint i = 0; i < tc; i++) { long t = threads + 4 + i * 48; if (U32(t) != tid) continue;
        ulong st = U64(t + 24); uint sz = U32(t + 32); uint srva = U32(t + 36);
        int found = 0; var seen = new List<string>();
        for (ulong a = Math.Max(rsp, st); a + 8 <= st + sz && found < hits; a += 8) { ulong v = U64(srva + (long)(a - st)); string w = Where(v); if (w != null) { seen.Add(w); found++; } }
        sb.AppendLine("yigin (Rsp'den yukari, modul ici degerler): " + (seen.Count > 0 ? string.Join(" | ", seen) : "(yigin bellegi Rsp'yi kapsamiyor)")); }
    }
    sb.AppendLine("modul sayisi " + ml.Count);
    return sb.ToString();
  }
}
'@
[MiniDump]::Run((Resolve-Path $Path).Path, $StackHits)
