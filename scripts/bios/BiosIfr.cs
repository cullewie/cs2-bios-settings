// BIOS kapsülünden (AMI Aptio .CAP) ayar sözlüğü çıkarır: FV -> FFS -> bölümler (LZMA / Tiano) -> PE32 -> HII paketleri -> IFR.
// Yalnız okur; girdi dosyasını değiştirmez.
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

public static class Lzma
{
    static byte[] ib; static int ip, iend; static uint range, code; static ushort[] P;
    static uint Rd() { return ip < iend ? (uint)ib[ip++] : 0u; }
    static int Bit(int i)
    {
        uint v = P[i]; uint bound = (range >> 11) * v; int b;
        if (code < bound) { range = bound; P[i] = (ushort)(v + ((2048 - v) >> 5)); b = 0; }
        else { range -= bound; code -= bound; P[i] = (ushort)(v - (v >> 5)); b = 1; }
        if (range < 0x1000000) { range <<= 8; code = (code << 8) | Rd(); }
        return b;
    }
    static int Tree(int bas, int nb) { int m = 1; for (int i = 0; i < nb; i++) m = (m << 1) + Bit(bas + m); return m - (1 << nb); }
    static int RevTree(int bas, int nb) { int m = 1, sym = 0; for (int i = 0; i < nb; i++) { int b = Bit(bas + m); m = (m << 1) + b; sym |= b << i; } return sym; }
    static uint Direct(int n)
    {
        uint res = 0;
        for (; n > 0; n--)
        {
            range >>= 1; code -= range; uint t = 0 - (code >> 31); code += range & t;
            if (range < 0x1000000) { range <<= 8; code = (code << 8) | Rd(); }
            res = (res << 1) + t + 1;
        }
        return res;
    }
    static int DecLen(int bas, int ps)
    {
        if (Bit(bas) == 0) return Tree(bas + 2 + (ps << 3), 3);
        if (Bit(bas + 1) == 0) return 8 + Tree(bas + 2 + 128 + (ps << 3), 3);
        return 16 + Tree(bas + 2 + 256, 8);
    }
    const int IsMatch = 0, IsRep = 192, IsRepG0 = 204, IsRepG1 = 216, IsRepG2 = 228, IsRep0Long = 240,
              PosSlot = 432, SpecPos = 688, Align = 803, LenCoder = 819, RepLenCoder = 1333, Literal = 1847;

    public static byte[] Decode(byte[] src, int off, int len)
    {
        int pr = src[off]; int lc = pr % 9; pr /= 9; int lp = pr % 5; int pb = pr / 5;
        ulong usz = BitConverter.ToUInt64(src, off + 5);
        if (usz > 0x30000000UL) throw new Exception("lzma boyut " + usz);
        int n = (int)usz;
        byte[] o = new byte[n];
        ib = src; ip = off + 13; iend = off + len;
        if (src[ip] != 0) throw new Exception("lzma baslangic bayti");
        ip++; code = 0; range = 0xFFFFFFFF;
        for (int i = 0; i < 4; i++) code = (code << 8) | Rd();
        int total = Literal + (0x300 << (lc + lp));
        P = new ushort[total]; for (int i = 0; i < total; i++) P[i] = 1024;
        int state = 0; uint rep0 = 0, rep1 = 0, rep2 = 0, rep3 = 0; int op = 0;
        int pbMask = (1 << pb) - 1, lpMask = (1 << lp) - 1;
        while (op < n)
        {
            int ps = op & pbMask;
            if (Bit(IsMatch + (state << 4) + ps) == 0)
            {
                int prev = op > 0 ? o[op - 1] : 0;
                int litState = ((op & lpMask) << lc) + (prev >> (8 - lc));
                int pbase = Literal + 0x300 * litState;
                int sym = 1;
                if (state >= 7)
                {
                    int mb = o[op - (int)rep0 - 1];
                    do
                    {
                        int matchBit = (mb >> 7) & 1; mb <<= 1;
                        int bit = Bit(pbase + ((1 + matchBit) << 8) + sym);
                        sym = (sym << 1) | bit;
                        if (matchBit != bit) break;
                    } while (sym < 0x100);
                }
                while (sym < 0x100) sym = (sym << 1) | Bit(pbase + sym);
                o[op++] = (byte)sym;
                state = state < 4 ? 0 : (state < 10 ? state - 3 : state - 6);
                continue;
            }
            int l;
            if (Bit(IsRep + state) != 0)
            {
                if (op == 0) throw new Exception("lzma rep@0");
                if (Bit(IsRepG0 + state) == 0)
                {
                    if (Bit(IsRep0Long + (state << 4) + ps) == 0)
                    {
                        state = state < 7 ? 9 : 11;
                        o[op] = o[op - (int)rep0 - 1]; op++;
                        continue;
                    }
                }
                else
                {
                    uint dist;
                    if (Bit(IsRepG1 + state) == 0) dist = rep1;
                    else
                    {
                        if (Bit(IsRepG2 + state) == 0) dist = rep2;
                        else { dist = rep3; rep3 = rep2; }
                        rep2 = rep1;
                    }
                    rep1 = rep0; rep0 = dist;
                }
                l = DecLen(RepLenCoder, ps);
                state = state < 7 ? 8 : 11;
            }
            else
            {
                rep3 = rep2; rep2 = rep1; rep1 = rep0;
                l = DecLen(LenCoder, ps);
                state = state < 7 ? 7 : 10;
                int ls = l > 3 ? 3 : l;
                int slot = Tree(PosSlot + (ls << 6), 6);
                uint dist;
                if (slot < 4) dist = (uint)slot;
                else
                {
                    int nd = (slot >> 1) - 1;
                    dist = (2u | ((uint)slot & 1)) << nd;
                    if (slot < 14) dist += (uint)RevTree(SpecPos + (int)dist - slot, nd);
                    else { dist += Direct(nd - 4) << 4; dist += (uint)RevTree(Align, 4); }
                }
                rep0 = dist;
                if (rep0 == 0xFFFFFFFF) break;
            }
            l += 2;
            if ((long)rep0 + 1 > op) throw new Exception("lzma mesafe");
            for (int k = 0; k < l && op < n; k++) { o[op] = o[op - (int)rep0 - 1]; op++; }
        }
        if (op != n) throw new Exception("lzma erken bitti " + op + "/" + n);
        return o;
    }
}

public class Blob { public string Name; public byte[] Data; public string Kind; }

public class VS { public string Name; public Guid G; public int Size; }
public class Frame { public int Op; public bool IsSup; public bool ConstTrue; public bool Pending; public bool IsGray; }
public class Q
{
    public string Blob, FormSet, Form, Parent, Kind, Prompt, Help, VarName, Opts, Sup, Gray;
    public int FormId, QId, VarId, VarOff, Size, TargetForm;
    public List<string> Options = new List<string>();
    public List<string> Defs = new List<string>();
    public string Def = "";
}

public static class Prog
{
    static List<Blob> blobs = new List<Blob>();
    static StringBuilder sum = new StringBuilder();
    static Guid G_FFS2 = new Guid("8C8CE578-8A3D-4F1C-9935-896185C32DD3");
    static Guid G_FFS3 = new Guid("5473C07A-3DCB-4DCA-BD6F-1E9689E7349A");
    static Guid G_LZMA = new Guid("EE4E5898-3914-4259-9D6E-DC7BD79403CF");
    static Guid G_LZMAF86 = new Guid("D42AE6BD-1352-4BFB-909A-CA72A6EAE889");
    static Guid G_TIANO = new Guid("A31280AD-481E-41B6-95E8-127F4C984779");
    static int fvCount, fileCount, sectCount, lzmaCount, tianoCount, f86Count, errCount;
    static List<Q> all = new List<Q>();
    static string dumpForm = null;
    static StringBuilder dump = new StringBuilder();

    static Guid GuidAt(byte[] d, int o) { byte[] g = new byte[16]; Array.Copy(d, o, g, 0, 16); return new Guid(g); }
    static byte[] Slice(byte[] d, int o, int n) { byte[] r = new byte[n]; Array.Copy(d, o, r, 0, n); return r; }
    static int U16(byte[] b, int o) { return b[o] | (b[o + 1] << 8); }
    static uint U32(byte[] b, int o) { return BitConverter.ToUInt32(b, o); }

    static byte[] DecTiano(byte[] d, int ds, bool tianoFirst)
    {
        int a = tianoFirst ? 5 : 4, b = tianoFirst ? 4 : 5;
        try { return EfiDec3.Run(d, ds, a); } catch (Exception) { return EfiDec3.Run(d, ds, b); }
    }

    static void ParseFv(byte[] d, int start, int fvLen, int depth, string path)
    {
        fvCount++;
        Guid fs = GuidAt(d, start + 16);
        bool ffs3 = (fs == G_FFS3);
        int hl = U16(d, start + 48);
        int pos = start + hl; pos = start + ((pos - start + 7) & ~7);
        int end = start + fvLen;
        while (pos + 24 <= end)
        {
            bool erased = true; for (int k = 0; k < 24; k++) if (d[pos + k] != 0xFF) { erased = false; break; }
            if (erased) break;
            Guid name = GuidAt(d, pos);
            int type = d[pos + 18]; int attr = d[pos + 19];
            int size = d[pos + 20] | (d[pos + 21] << 8) | (d[pos + 22] << 16);
            int hs = 24;
            if (ffs3 && (attr & 1) != 0) { size = (int)BitConverter.ToUInt64(d, pos + 24); hs = 32; }
            if (size < hs || pos + size > end) break;
            fileCount++;
            if (type != 0xF0 && type != 0xFF && type != 0x00)
            {
                try
                {
                    ParseSections(d, pos + hs, pos + size, path + "/" + name.ToString().ToUpper(), depth);
                }
                catch (Exception ex) { errCount++; sum.AppendLine("HATA dosya " + name + ": " + ex.Message); }
            }
            pos += size; pos = start + ((pos - start + 7) & ~7);
        }
    }

    static void ParseSections(byte[] d, int start, int end, string path, int depth)
    {
        int firstBlob = blobs.Count; string ui = null;
        int pos = start;
        while (pos + 4 <= end)
        {
            int size = d[pos] | (d[pos + 1] << 8) | (d[pos + 2] << 16); int type = d[pos + 3]; int hs = 4;
            if (size == 0xFFFFFF) { size = (int)U32(d, pos + 4); hs = 8; }
            if (size < hs || pos + size > end) break;
            sectCount++;
            int bs = pos + hs, be = pos + size;
            try
            {
                switch (type)
                {
                    case 0x01:
                        {
                            int ctype = d[bs + 4]; int ds = bs + 5;
                            if (ctype == 0) ParseSections(d, ds, be, path, depth + 1);
                            else { tianoCount++; byte[] dec = DecTiano(d, ds, false); ParseSections(dec, 0, dec.Length, path, depth + 1); }
                            break;
                        }
                    case 0x02:
                        {
                            Guid g = GuidAt(d, bs); int dofs = U16(d, bs + 16); int ds = pos + dofs;
                            if (g == G_LZMA || g == G_LZMAF86)
                            {
                                if (g == G_LZMAF86) f86Count++;
                                lzmaCount++;
                                byte[] dec = Lzma.Decode(d, ds, be - ds);
                                ParseSections(dec, 0, dec.Length, path, depth + 1);
                            }
                            else if (g == G_TIANO)
                            {
                                tianoCount++;
                                byte[] dec = DecTiano(d, ds, true);
                                ParseSections(dec, 0, dec.Length, path, depth + 1);
                            }
                            else ParseSections(d, ds, be, path, depth + 1);
                            break;
                        }
                    case 0x10:
                    case 0x12:
                        {
                            Blob bl = new Blob(); bl.Name = path; bl.Kind = type == 0x10 ? "PE32" : "TE"; bl.Data = Slice(d, bs, be - bs);
                            blobs.Add(bl); break;
                        }
                    case 0x15: ui = Encoding.Unicode.GetString(d, bs, be - bs).TrimEnd('\0'); break;
                    case 0x17:
                        {
                            ulong fl = BitConverter.ToUInt64(d, bs + 32);
                            int fvl = (int)Math.Min((ulong)(be - bs), fl);
                            ParseFv(d, bs, fvl, depth + 1, path + "/FV"); break;
                        }
                    case 0x19:
                        {
                            if (be - bs > 4096) { Blob bl = new Blob(); bl.Name = path; bl.Kind = "RAW"; bl.Data = Slice(d, bs, be - bs); blobs.Add(bl); }
                            break;
                        }
                }
            }
            catch (Exception ex) { errCount++; sum.AppendLine("HATA " + path + " bolum 0x" + type.ToString("X2") + ": " + ex.Message); }
            pos += size; pos = start + ((pos - start + 3) & ~3);
        }
        if (ui != null) for (int i = firstBlob; i < blobs.Count; i++) blobs[i].Name = blobs[i].Name + " [" + ui + "]";
    }

    static List<int> FindPkgLists(byte[] b)
    {
        List<int> res = new List<int>();
        for (int i = 0; i + 28 <= b.Length; i += 4)
        {
            uint plen = U32(b, i + 16);
            if (plen < 28 || plen > 0x4000000 || (long)i + plen > b.Length) continue;
            uint h = U32(b, i + 20); int t = (int)(h >> 24); int l = (int)(h & 0xFFFFFF);
            if (l < 4 || l > plen - 20) continue;
            if (!(t == 1 || t == 2 || t == 4 || t == 5 || t == 6 || t == 7 || t == 8 || t == 9 || t == 0xA || t == 0xDF)) continue;
            int p = 20; bool ok = false; int count = 0;
            while (p + 4 <= plen)
            {
                uint hh = U32(b, i + p); int tt = (int)(hh >> 24); int ll = (int)(hh & 0xFFFFFF);
                if (ll < 4 || p + ll > plen) break;
                p += ll; count++;
                if (tt == 0xDF) { ok = (p == plen); break; }
            }
            if (ok && count >= 2) { res.Add(i); i += (int)plen - 4; }
        }
        return res;
    }

    static string AsciiZ(byte[] b, int s, int max)
    {
        int e = s; while (e < s + max && e < b.Length && b[e] != 0) e++;
        return Encoding.ASCII.GetString(b, s, e - s);
    }

    static void ParseStrings(byte[] b, int p, int l, Dictionary<string, Dictionary<int, string>> langs)
    {
        int infoOff = (int)U32(b, p + 8);
        string lang = AsciiZ(b, p + 46, 64);
        Dictionary<int, string> d = new Dictionary<int, string>();
        int id = 1; int q = p + infoOff; int end = p + l;
        while (q < end)
        {
            int bt = b[q];
            if (bt == 0x00) break;
            int cnt, s, e;
            switch (bt)
            {
                case 0x10: s = q + 1; e = s; while (b[e] != 0) e++; d[id++] = Encoding.UTF8.GetString(b, s, e - s); q = e + 1; break;
                case 0x11: s = q + 2; e = s; while (b[e] != 0) e++; d[id++] = Encoding.UTF8.GetString(b, s, e - s); q = e + 1; break;
                case 0x12: cnt = U16(b, q + 1); q += 3; for (int k = 0; k < cnt; k++) { s = q; e = s; while (b[e] != 0) e++; d[id++] = Encoding.UTF8.GetString(b, s, e - s); q = e + 1; } break;
                case 0x13: cnt = U16(b, q + 2); q += 4; for (int k = 0; k < cnt; k++) { s = q; e = s; while (b[e] != 0) e++; d[id++] = Encoding.UTF8.GetString(b, s, e - s); q = e + 1; } break;
                case 0x14: s = q + 1; e = s; while (!(b[e] == 0 && b[e + 1] == 0)) e += 2; d[id++] = Encoding.Unicode.GetString(b, s, e - s); q = e + 2; break;
                case 0x15: s = q + 2; e = s; while (!(b[e] == 0 && b[e + 1] == 0)) e += 2; d[id++] = Encoding.Unicode.GetString(b, s, e - s); q = e + 2; break;
                case 0x16: cnt = U16(b, q + 1); q += 3; for (int k = 0; k < cnt; k++) { s = q; e = s; while (!(b[e] == 0 && b[e + 1] == 0)) e += 2; d[id++] = Encoding.Unicode.GetString(b, s, e - s); q = e + 2; } break;
                case 0x17: cnt = U16(b, q + 2); q += 4; for (int k = 0; k < cnt; k++) { s = q; e = s; while (!(b[e] == 0 && b[e + 1] == 0)) e += 2; d[id++] = Encoding.Unicode.GetString(b, s, e - s); q = e + 2; } break;
                case 0x20: { int dup = U16(b, q + 1); string v; d[id] = d.TryGetValue(dup, out v) ? v : ""; id++; q += 3; break; }
                case 0x21: id += U16(b, q + 1); q += 3; break;
                case 0x22: id += b[q + 1]; q += 2; break;
                case 0x30: q += b[q + 2]; break;
                case 0x31: q += U16(b, q + 2); break;
                case 0x32: q += (int)U32(b, q + 2); break;
                default: q = end; break;
            }
        }
        string key = lang; int n = 1; while (langs.ContainsKey(key)) { key = lang + "#" + n; n++; }
        langs[key] = d;
    }

    static string S(Dictionary<int, string> strs, int id)
    {
        string v; if (strs != null && strs.TryGetValue(id, out v)) return v.Replace("\t", " ").Replace("\r", " ").Replace("\n", " ");
        return id == 0 ? "" : "#" + id;
    }

    static string ValStr(byte[] b, int o, int type, int avail)
    {
        switch (type)
        {
            case 0: return avail >= 1 ? b[o].ToString() : "?";
            case 1: return avail >= 2 ? U16(b, o).ToString() : "?";
            case 2: return avail >= 4 ? U32(b, o).ToString() : "?";
            case 3: return avail >= 8 ? BitConverter.ToUInt64(b, o).ToString() : "?";
            case 4: return avail >= 1 ? b[o].ToString() : "?";
            default: return "t" + type;
        }
    }

    static void ParseForms(byte[] b, int fp, Dictionary<int, string> strs, string blobName)
    {
        int l = (int)(U32(b, fp) & 0xFFFFFF);
        int pos = fp + 4, end = fp + l;
        string fsTitle = ""; string formTitle = ""; int formId = -1;
        Dictionary<int, VS> vstores = new Dictionary<int, VS>();
        Dictionary<int, string> formNames = new Dictionary<int, string>();
        Dictionary<int, string> formParent = new Dictionary<int, string>();
        List<Frame> stack = new List<Frame>();
        List<Q> local = new List<Q>();
        Q cur = null;
        while (pos + 2 <= end)
        {
            int op = b[pos]; int len = b[pos + 1] & 0x7F; bool scope = (b[pos + 1] & 0x80) != 0;
            if (len < 2 || pos + len > end) break;
            if (stack.Count > 0)
            {
                Frame top = stack[stack.Count - 1];
                if (top.Pending && op != 0x29) { top.Pending = false; top.ConstTrue = (op == 0x46); }
            }
            Frame nf = scope ? new Frame() : null;
            if (nf != null) nf.Op = op;
            switch (op)
            {
                case 0x0E: fsTitle = S(strs, U16(b, pos + 18)); break;
                case 0x01:
                    formId = U16(b, pos + 2); formTitle = S(strs, U16(b, pos + 4));
                    formNames[formId] = formTitle; break;
                case 0x24:
                    {
                        VS v = new VS(); v.G = GuidAt(b, pos + 2); v.Size = U16(b, pos + 20); v.Name = AsciiZ(b, pos + 22, len - 22);
                        vstores[U16(b, pos + 18)] = v; break;
                    }
                case 0x26:
                    {
                        VS v = new VS(); v.G = GuidAt(b, pos + 4); v.Size = U16(b, pos + 24); v.Name = AsciiZ(b, pos + 26, len - 26);
                        vstores[U16(b, pos + 2)] = v; break;
                    }
                case 0x05: case 0x06: case 0x07: case 0x1C: case 0x23: case 0x08: case 0x0F: case 0x0C:
                    {
                        Q q = new Q();
                        q.Blob = blobName; q.FormSet = fsTitle; q.Form = formTitle; q.FormId = formId;
                        q.Prompt = S(strs, U16(b, pos + 2)); q.Help = S(strs, U16(b, pos + 4));
                        q.QId = U16(b, pos + 6); q.VarId = U16(b, pos + 8); q.VarOff = U16(b, pos + 10);
                        VS vs; q.VarName = vstores.TryGetValue(q.VarId, out vs) ? vs.Name : (q.VarId == 0 ? "" : "var" + q.VarId);
                        q.Kind = op == 0x05 ? "OneOf" : op == 0x06 ? "CheckBox" : op == 0x07 ? "Numeric" : op == 0x1C ? "String" : op == 0x23 ? "OrderedList" : op == 0x08 ? "Password" : op == 0x0F ? "Menu" : "Action";
                        if (op == 0x05 || op == 0x07)
                        {
                            int fl = b[pos + 13]; int ty = fl & 3; q.Size = 1 << ty;
                            int vo = pos + 14; int av = pos + len - vo;
                            int sz = q.Size;
                            if (av >= 3 * sz) q.Def = "min=" + ValStr(b, vo, ty, av) + " max=" + ValStr(b, vo + sz, ty, av - sz) + " step=" + ValStr(b, vo + 2 * sz, ty, av - 2 * sz);
                        }
                        else if (op == 0x06) { q.Size = 1; q.Options.Add("0=Disabled"); q.Options.Add("1=Enabled"); }
                        else if (op == 0x0F && len >= 15) { q.TargetForm = U16(b, pos + 13); if (!formParent.ContainsKey(q.TargetForm)) formParent[q.TargetForm] = formTitle; }
                        local.Add(q); cur = q;
                        break;
                    }
                case 0x09:
                    {
                        if (cur != null)
                        {
                            int fl = b[pos + 4]; int ty = b[pos + 5];
                            string val = ValStr(b, pos + 6, ty, pos + len - (pos + 6));
                            string def = ((fl & 0x10) != 0 ? "*" : "") + ((fl & 0x20) != 0 ? "m" : "");
                            cur.Options.Add(val + "=" + S(strs, U16(b, pos + 2)) + def);
                        }
                        break;
                    }
                case 0x5B:
                    if (cur != null && len >= 6) { cur.Defs.Add(U16(b, pos + 2).ToString("X") + ":" + ValStr(b, pos + 5, b[pos + 4], pos + len - (pos + 5))); }
                    break;
                case 0x0A: if (nf != null) { nf.IsSup = true; nf.Pending = true; } break;
                case 0x19: case 0x1E: if (nf != null) nf.IsGray = true; break;
            }
            if (dumpForm != null && formTitle == dumpForm)
            {
                StringBuilder sb = dump;
                sb.Append(string.Format("{0:X5} op={1:X2} len={2,3}{3} ", pos, op, len, scope ? " S" : "  "));
                int nb = Math.Min(len, 30);
                for (int k = 0; k < nb; k++) sb.Append(b[pos + k].ToString("X2")).Append(' ');
                if (op == 0x05 || op == 0x06 || op == 0x07 || op == 0x1C || op == 0x23 || op == 0x08 || op == 0x0F || op == 0x0C || op == 0x0D || op == 0x02 || op == 0x03)
                    sb.Append(" P=\"" + S(strs, U16(b, pos + 2)) + "\"");
                if (op == 0x09) sb.Append(" O=\"" + S(strs, U16(b, pos + 2)) + "\"");
                if (op == 0x5B && len >= 6) sb.Append(" DEFAULT id=0x" + U16(b, pos + 2).ToString("X") + " val=" + ValStr(b, pos + 5, b[pos + 4], pos + len - (pos + 5)));
                if (op == 0x0D && len >= 8) sb.Append(" RESET defid=0x" + U16(b, pos + 6).ToString("X"));
                sb.AppendLine();
            }
            // questions and menus are marked at creation; capture current suppress state for new Q
            if (op == 0x05 || op == 0x06 || op == 0x07 || op == 0x1C || op == 0x23 || op == 0x08 || op == 0x0F || op == 0x0C)
            {
                Q q = local[local.Count - 1];
                int constN = 0, condN = 0; bool gray = false;
                for (int k = 0; k < stack.Count; k++)
                {
                    if (stack[k].IsSup) { if (stack[k].ConstTrue) constN++; else condN++; }
                    if (stack[k].IsGray) gray = true;
                }
                q.Sup = constN > 0 ? "GIZLI" : (condN > 0 ? "KOSUL" : "");
                q.Gray = gray ? "GRI" : "";
            }
            if (op == 0x29) { if (stack.Count > 0) stack.RemoveAt(stack.Count - 1); }
            else if (nf != null) stack.Add(nf);
            pos += len;
        }
        foreach (Q q in local) { string par; q.Parent = formParent.TryGetValue(q.FormId, out par) ? par : ""; all.Add(q); }
    }

    static void ParseHiiBlob(Blob bl)
    {
        byte[] b = bl.Data;
        List<int> lists = FindPkgLists(b);
        foreach (int off in lists)
        {
            int plen = (int)U32(b, off + 16);
            Dictionary<string, Dictionary<int, string>> langs = new Dictionary<string, Dictionary<int, string>>();
            int p = off + 20; int endp = off + plen;
            List<int> forms = new List<int>();
            while (p + 4 <= endp)
            {
                uint h = U32(b, p); int t = (int)(h >> 24); int l = (int)(h & 0xFFFFFF);
                if (l < 4) break;
                if (t == 4) { try { ParseStrings(b, p, l, langs); } catch (Exception ex) { errCount++; sum.AppendLine("HATA dizgi " + bl.Name + ": " + ex.Message); } }
                else if (t == 2) forms.Add(p);
                if (t == 0xDF) break;
                p += l;
            }
            if (forms.Count == 0) continue;
            Dictionary<int, string> strs = null;
            foreach (KeyValuePair<string, Dictionary<int, string>> kv in langs) { if (kv.Key.StartsWith("en")) { strs = kv.Value; break; } }
            if (strs == null) foreach (KeyValuePair<string, Dictionary<int, string>> kv in langs) { strs = kv.Value; break; }
            int before = all.Count;
            foreach (int fp in forms) { try { ParseForms(b, fp, strs, bl.Name); } catch (Exception ex) { errCount++; sum.AppendLine("HATA ifr " + bl.Name + ": " + ex.Message); } }
            sum.AppendLine("HII " + bl.Kind + " " + bl.Name + " @0x" + off.ToString("X") + " pkt=" + plen + " diller=" + string.Join(",", new List<string>(langs.Keys).ToArray()) + " sorular=" + (all.Count - before));
        }
    }

    public static int Main(string[] args)
    {
        string cap = args[0]; string outDir = args[1];
        if (args.Length > 2) dumpForm = args[2];
        Directory.CreateDirectory(outDir);
        byte[] allb = File.ReadAllBytes(cap);
        int hdr = (int)BitConverter.ToUInt32(allb, 16);
        byte[] rom = Slice(allb, hdr, allb.Length - hdr);
        sum.AppendLine("ROM boyutu: " + rom.Length);
        for (int i = 40; i + 0x38 < rom.Length; i++)
        {
            if (rom[i] == 0x5F && rom[i + 1] == 0x46 && rom[i + 2] == 0x56 && rom[i + 3] == 0x48)
            {
                int s = i - 40;
                ulong fvl = BitConverter.ToUInt64(rom, s + 32);
                int hl = U16(rom, s + 48);
                if (fvl < 0x48 || (long)fvl > rom.Length - s || hl < 0x38 || hl > 0x400) continue;
                Guid fs = GuidAt(rom, s + 16);
                sum.AppendLine("FV @0x" + s.ToString("X") + " uzunluk=0x" + fvl.ToString("X") + " fs=" + fs);
                if (fs == G_FFS2 || fs == G_FFS3)
                {
                    try { ParseFv(rom, s, (int)fvl, 0, "FV" + s.ToString("X")); } catch (Exception ex) { errCount++; sum.AppendLine("HATA FV: " + ex.Message); }
                    i = s + (int)fvl - 1;
                }
            }
        }
        sum.AppendLine("FV=" + fvCount + " dosya=" + fileCount + " bolum=" + sectCount + " lzma=" + lzmaCount + " (f86=" + f86Count + ") tiano=" + tianoCount + " hata=" + errCount + " PE/TE/RAW=" + blobs.Count);
        foreach (Blob bl in blobs) { try { ParseHiiBlob(bl); } catch (Exception ex) { errCount++; sum.AppendLine("HATA hii: " + ex.Message); } }
        StringBuilder csv = new StringBuilder();
        csv.AppendLine("Blob\tFormSet\tParent\tForm\tFormId\tKind\tPrompt\tVarStore\tOffsetHex\tSize\tSup\tGray\tQId\tTarget\tRange\tOptions\tHelp\tDefaults");
        foreach (Q q in all)
        {
            csv.AppendLine(q.Blob + "\t" + q.FormSet + "\t" + q.Parent + "\t" + q.Form + "\t" + q.FormId + "\t" + q.Kind + "\t" + q.Prompt + "\t" + q.VarName + "\t" +
                (q.VarId == 0 ? "" : q.VarOff.ToString("X4")) + "\t" + q.Size + "\t" + q.Sup + "\t" + q.Gray + "\t" + q.QId + "\t" + (q.Kind == "Menu" ? q.TargetForm.ToString() : "") + "\t" + q.Def + "\t" + string.Join("; ", q.Options.ToArray()) + "\t" + q.Help + "\t" + string.Join("; ", q.Defs.ToArray()));
        }
        File.WriteAllText(Path.Combine(outDir, "ifr_all.tsv"), csv.ToString(), new UTF8Encoding(false));
        if (dumpForm != null) File.WriteAllText(Path.Combine(outDir, "ifr_dump.txt"), dump.ToString(), new UTF8Encoding(false));
        if (args.Length > 3)
        {
            int bn = 0;
            foreach (Blob bl in blobs)
            {
                if (bl.Name.Contains(args[3])) { File.WriteAllBytes(Path.Combine(outDir, "blob_" + bn + "_" + bl.Kind + ".bin"), bl.Data); sum.AppendLine("blob kaydedildi: " + bn + " " + bl.Name + " boyut=" + bl.Data.Length); bn++; }
            }
        }
        sum.AppendLine("Toplam soru/öğe: " + all.Count);
        File.WriteAllText(Path.Combine(outDir, "ifr_summary.txt"), sum.ToString(), new UTF8Encoding(false));
        Console.WriteLine(sum.ToString());
        return 0;
    }
}
