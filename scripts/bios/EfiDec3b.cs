using System;
public class EfiDec3 {
  byte[] src; int sp; long compSize; ulong bitBuf; uint subBitBuf; int bitCount; int blockSize;
  ushort[] cLen=new ushort[510], ptLen=new ushort[128], cTable=new ushort[4096], ptTable=new ushort[256], left=new ushort[2048], right=new ushort[2048];
  const int NC=510, NT=19, TBIT=5, CBIT=9, MAXNP=31; int pbit;
  void Fill(int n){
    bitBuf = n>=32 ? 0 : (bitBuf<<n)&0xFFFFFFFFUL;
    while(n>bitCount){ n-=bitCount; bitBuf |= ((ulong)subBitBuf<<n)&0xFFFFFFFFUL;
      if(compSize>0){compSize--; subBitBuf = sp<src.Length? src[sp++]:0u;} else subBitBuf=0; bitCount=8; }
    bitCount-=n; bitBuf |= (ulong)(subBitBuf>>bitCount);
  }
  uint Get(int n){ uint r=(uint)(bitBuf>>(32-n)); Fill(n); return r; }
  void MakeTable(int nc, ushort[] bl, int tb, ushort[] table){
    int[] count=new int[17], weight=new int[17]; int[] start=new int[18];
    for(int i=0;i<nc;i++) count[bl[i]]++;
    for(int i=1;i<=16;i++) start[i+1]=start[i]+(count[i]<<(16-i));
    if((start[17]&0xFFFF)!=0 || start[17]>0x10000) throw new Exception("bad table nc="+nc);
    int ju=16-tb; int k;
    for(k=1;k<=tb;k++){ start[k]>>=ju; weight[k]=1<<(tb-k); }
    while(k<=16){ weight[k]=1<<(16-k); k++; }
    int ii=start[tb+1]>>ju;
    if(ii!=0){ int kk=1<<tb; while(ii!=kk) table[ii++]=0; }
    int avail=nc; int mask=1<<(15-tb);
    for(int ch=0;ch<nc;ch++){ int len=bl[ch]; if(len==0) continue;
      int next=start[len]+weight[len];
      if(len<=tb){ for(int i=start[len];i<next;i++) table[i]=(ushort)ch; }
      else { int idx3=start[len]; ushort[] arr=table; int pi=idx3>>ju; int i=len-tb;
        while(i!=0){ if(arr[pi]==0){ right[avail]=left[avail]=0; arr[pi]=(ushort)avail++; }
          int node=arr[pi]; if((idx3&mask)!=0){arr=right;} else {arr=left;} pi=node; idx3<<=1; i--; }
        arr[pi]=(ushort)ch; }
      start[len]=next; }
  }
  void ReadPT(int nn,int nbit,int special){
    int number=(int)Get(nbit);
    if(number==0){ int c=(int)Get(nbit); for(int i=0;i<nn;i++) ptLen[i]=0; for(int i=0;i<256;i++) ptTable[i]=(ushort)c; return; }
    int index=0;
    while(index<number){ int c=(int)(bitBuf>>29);
      if(c==7){ ulong m=1UL<<28; while((m&bitBuf)!=0){m>>=1;c++;} }
      Fill(c<7?3:c-3); ptLen[index++]=(ushort)c;
      if(index==special){ c=(int)Get(2); while(--c>=0) ptLen[index++]=0; } }
    while(index<nn) ptLen[index++]=0;
    MakeTable(nn,ptLen,8,ptTable);
  }
  void ReadC(){
    int number=(int)Get(CBIT);
    if(number==0){ int c=(int)Get(CBIT); for(int i=0;i<NC;i++) cLen[i]=0; for(int i=0;i<4096;i++) cTable[i]=(ushort)c; return; }
    int index=0;
    while(index<number){ int c=ptTable[bitBuf>>24];
      if(c>=NT){ ulong m=1UL<<23; do{ c=((bitBuf&m)!=0)?right[c]:left[c]; m>>=1; }while(c>=NT); }
      Fill(ptLen[c]);
      if(c<=2){ if(c==0)c=1; else if(c==1)c=(int)Get(4)+3; else c=(int)Get(CBIT)+20; while(--c>=0) cLen[index++]=0; }
      else cLen[index++]=(ushort)(c-2); }
    while(index<NC) cLen[index++]=0;
    MakeTable(NC,cLen,12,cTable);
  }
  int DecodeC(){
    if(blockSize==0){ blockSize=(int)Get(16); ReadPT(NT,TBIT,3); ReadC(); ReadPT(MAXNP,pbit,-1); }
    blockSize--;
    int i2=cTable[bitBuf>>20];
    if(i2>=NC){ ulong m=1UL<<19; do{ i2=((bitBuf&m)!=0)?right[i2]:left[i2]; m>>=1; }while(i2>=NC); }
    Fill(cLen[i2]); return i2;
  }
  int DecodeP(){
    int v=ptTable[bitBuf>>24];
    if(v>=MAXNP){ ulong m=1UL<<23; do{ v=((bitBuf&m)!=0)?right[v]:left[v]; m>>=1; }while(v>=MAXNP); }
    Fill(ptLen[v]);
    return v>1 ? (1<<(v-1))+(int)Get(v-1) : v;
  }
  public static byte[] Run(byte[] data,int off,int pbit){
    var d=new EfiDec3(); d.src=data; d.pbit=pbit;
    long comp=BitConverter.ToUInt32(data,off), orig=BitConverter.ToUInt32(data,off+4);
    if(comp<=0 || comp>data.Length-off || orig<=0 || orig>400000000) throw new Exception("bad header");
    d.sp=off+8; d.compSize=comp; d.Fill(32);
    byte[] dst=new byte[orig]; int pos=0;
    while(pos<orig){ int c=d.DecodeC();
      if(c<256) dst[pos++]=(byte)c;
      else { int rem=c-253; int di=pos-d.DecodeP()-1; if(di<0) throw new Exception("bad dist @"+pos);
        while(rem-->0 && pos<orig){ dst[pos++]=dst[di++]; } } }
    return dst;
  }
}

