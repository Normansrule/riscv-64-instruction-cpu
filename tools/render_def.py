# =============================================================================
# tools/render_def.py: draw a placed-and-routed chip from its DEF file
#
#   python3 tools/render_def.py original/eecs151-rv32i/physical-design/riscv_top.def.gz docs/img/silicon
#
# Standard-cell widths are inferred from the placement rows (Innovus fills every row with filler
# cells, so each cell ends where the next begins); SRAM macro sizes from the gaps they leave.
# Colours follow the instance hierarchy (cpu/alu, cpu/register_file, mem/icache, ...).
# Needs: pip install pillow
# =============================================================================
import gzip, re, collections, sys, os, json
from PIL import Image, ImageDraw, ImageFont
DEF = sys.argv[1] if len(sys.argv) > 1 else 'original/eecs151-rv32i/physical-design/riscv_top.def.gz'
OUT = sys.argv[2] if len(sys.argv) > 2 else 'docs/img/silicon'
os.makedirs(OUT, exist_ok=True)
txt=gzip.open(DEF,'rt').read()
UNIT=1000
comp=txt[txt.index('\nCOMPONENTS'):txt.index('END COMPONENTS')]
ents=re.findall(r'-\s+(\S+)\s+(\S+)\s+([^;]*);',comp)
ROWH=4140
cells=[]; macros=[]
for name,cell,rest in ents:
    p=re.search(r'\+\s+(PLACED|FIXED)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\S+)',rest)
    if not p: continue
    x,y=int(p.group(2)),int(p.group(3))
    (macros if cell.startswith('sram22') else cells).append((name,cell,x,y))
rows=collections.defaultdict(list)
for c in cells: rows[c[3]].append(c)
CORE_R=2980000
widths={}
for y,lst in rows.items():
    lst.sort(key=lambda c:c[2])
    for i,c in enumerate(lst):
        nx=lst[i+1][2] if i+1<len(lst) else CORE_R
        widths[c[0]]=nx-c[2]
# per-cell-type width = most common observed width (robust to gaps next to macros)
tw=collections.defaultdict(collections.Counter)
for n,cell,x,y in cells: tw[cell][widths[n]]+=1
cw={cell:min(cnt.most_common(1)[0][0], 40000) for cell,cnt in tw.items()}
# macro extents: rows covering macro start y; right edge = first cell x > macro x in row y+ROWH
rowys=sorted(rows)
mrect=[]
for name,cell,x,y in macros:
    ry=[r for r in rowys if r>=y][0]
    xs=[c[2] for c in rows[ry] if c[2]>x]
    nxt=[mx for (mn,mc,mx,my) in macros if my==y and mx>x]
    right=min(xs+[m-4600 for m in nxt]) if (xs or nxt) else x+300000
    # height: go up rows until a cell starts inside [x,right)
    top=y
    for r in rowys:
        if r< y: continue
        if any(x<=c[2]<right-2000 for c in rows[r]): top=r; break
    above=[my for (mn,mc,mx,my) in macros if mx==x and my>y]
    if above: top=min(top, min(above)-4740)
    mrect.append((name,cell,x,y,right-x,top-y))
tmin={}
for n,c,x,y,w,h in mrect:
    a=tmin.get(c,(w,h)); tmin[c]=(min(a[0],w),min(a[1],h))
mrect=[(n,c,x,y)+tmin[c] for n,c,x,y,w,h in mrect]
def cat(name,cell):
    if cell.startswith('FILL') or cell=='ANTENNA': return 'fill'
    if name.startswith('mem/icache'): return 'icache'
    if name.startswith('mem/dcache'): return 'dcache'
    if name.startswith('mem/'): return 'memctl'
    if 'CTS_' in name: return 'clock'
    n=name.lower()
    if n.startswith('cpu/alu'): return 'alu'
    if 'register_file' in n: return 'regfile'
    if 'gshare' in n: return 'gshare'
    if 'control_status' in n or 'csr' in n.split('/')[1] if '/' in n else False: return 'cpu'
    if n.startswith('cpu/'): return 'cpu'
    return 'other'
COL={'fill':(233,236,229),'sram':(96,125,139),'icache':(66,165,245),'dcache':(38,166,154),'memctl':(126,87,194),
     'clock':(255,193,7),'alu':(239,108,0),'regfile':(171,71,188),'gshare':(0,121,107),'cpu':(211,47,47),'other':(158,158,158)}
stat=collections.Counter(); area=collections.Counter()
for n,cell,x,y in cells:
    c=cat(n,cell); stat[c]+=1; area[c]+=cw[cell]*ROWH/1e6
for m in mrect: stat['sram']+=1; area['sram']+=m[4]*m[5]/1e6
print({k:(stat[k],round(area[k])) for k in stat})
print('macros', [(m[0], m[4]/1000, m[5]/1000) for m in mrect][:3])
FONT=next((f for f in ['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf','/usr/share/fonts/TTF/DejaVuSans.ttf'] if os.path.exists(f)), None)
def draw(out, box, px, title, routes=False, labels=True):
    X0,Y0,X1,Y1=[v*UNIT for v in box]
    s=px/max(X1-X0,Y1-Y0); W=int((X1-X0)*s); H=int((Y1-Y0)*s)
    img=Image.new('RGB',(W,H+120),(251,252,248)); d=ImageDraw.Draw(img)
    def R(x,y,w,h,col,outline=None,width=1):
        a=((x-X0)*s, H-(y+h-Y0)*s, (x+w-X0)*s, H-(y-Y0)*s)
        if a[2]<0 or a[0]>W or a[3]<0 or a[1]>H: return
        d.rectangle(a,fill=col,outline=outline,width=width)
    R(20000,20000,2960000,2960000,(245,246,242),(200,205,198))
    for pri in ['fill','other','memctl','icache','dcache','clock','cpu','regfile','gshare','alu']:
        for n,cell,x,y in cells:
            if cat(n,cell)==pri: R(x,y,cw[cell],ROWH,COL[pri])
    for n,cell,x,y,w,h in mrect: R(x,y,w,h,COL['sram'],(55,71,79),2)
    if routes:
        net=txt[txt.index('\nNETS'):txt.index('END NETS')]
        LC={'met1':(123,31,162,90),'met2':(21,101,192,90),'met3':(46,125,50,90),'met4':(230,81,0,110),'met5':(183,28,28,110)}
        ov=Image.new('RGBA',img.size,(0,0,0,0)); od=ImageDraw.Draw(ov)
        for seg in re.finditer(r'(?:ROUTED|NEW)\s+(met\d)\s+(?:\d+\s+)?\(\s*(-?\d+)\s+(-?\d+)[^)]*\)\s*\(\s*(-?\d+|\*)\s+(-?\d+|\*)',net):
            ly,x1,y1,x2,y2=seg.groups(); x1=int(x1); y1=int(y1)
            x2=x1 if x2=='*' else int(x2); y2=y1 if y2=='*' else int(y2)
            od.line(((x1-X0)*s,H-(y1-Y0)*s,(x2-X0)*s,H-(y2-Y0)*s),fill=LC.get(ly,(0,0,0,60)),width=max(1,round(s*250)))
        img=Image.alpha_composite(img.convert('RGBA'),ov).convert('RGB'); d=ImageDraw.Draw(img)
    F=ImageFont.truetype(FONT,max(14,px//80)) if FONT else ImageFont.load_default(); Fs=ImageFont.truetype(FONT,max(12,px//105)) if FONT else ImageFont.load_default()
    if labels:
        for n,cell,x,y,w,h in mrect:
            if (x-X0)*s>0 and (x-X0)*s<W:
                lab=('I$ ' if 'icache' in n else 'D$ ')+n.split('/')[-1].replace('Cache_','').replace('Data','D')
                d.text(((x-X0)*s+6, H-(y+h-Y0)*s+6), lab, fill=(255,255,255), font=Fs)
    d.text((16,H+12),title,fill=(23,37,29),font=F)
    items=[('cpu','CPU pipeline'),('alu','ALU'),('regfile','register file'),('gshare','gshare'),('icache','I-cache'),('dcache','D-cache'),('memctl','memory ctl'),('sram','SRAM macro'),('clock','clock tree'),('fill','filler/decap')]
    xx=16; yy=H+56
    for k,lab in items:
        d.rectangle((xx,yy,xx+20,yy+20),fill=COL[k],outline=(120,120,120)); d.text((xx+26,yy),lab,fill=(23,37,29),font=Fs); xx+=26+int(d.textlength(lab,font=Fs))+20
        if xx>W-200: xx=16; yy+=28
    img.save(out,optimize=True); print(out,img.size)
json.dump({'counts':stat,'area_um2':{k:round(v) for k,v in area.items()},'macros':[(m[0],m[1],m[4]/1000,m[5]/1000) for m in mrect]},open(os.path.join(OUT,'chip_stats.json'),'w'),indent=1)
D=OUT+'/'
draw(D+'your_chip_full.png',(0,0,3000,3000),1500,'riscv_top (EECS 151, Spring 2026): 3.0 x 3.0 mm die, SkyWater sky130, placed and routed by Cadence Innovus')
draw(D+'your_chip_cpu_zoom.png',(480,100,1680,1300),1500,'Zoom on the Riscv151 core (1.2 x 1.2 mm): standard cells colored by module')
draw(D+'your_chip_caches.png',(0,0,1100,900),1400,'Caches: 8 data SRAMs + 2 tag SRAMs (sram22 macros) and their controllers')
draw(D+'your_chip_routing.png',(480,100,1680,1300),1500,'The same core with its metal wiring: met1 purple, met2 blue, met3 green, met4 orange, met5 red',routes=True,labels=False)
