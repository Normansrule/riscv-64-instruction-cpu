M=1<<64
def u(x): return x % M
def s(x): x%=M; return x-M if x>>63 else x
def s32(x): x%=1<<32; return x-(1<<32) if x>>31 else x
def u32(x): return x % (1<<32)
def sx(x): return u(s32(x))
def tdiv(a,b): q=abs(a)//abs(b); return q if (a<0)==(b<0) else -q
def trem(a,b): return a - tdiv(a,b)*b
MIN=1<<63
def div(a,b):
    if b==0: return M-1
    if a==MIN and b==M-1: return a
    return u(tdiv(s(a),s(b)))
def rem(a,b):
    if b==0: return a
    if a==MIN and b==M-1: return 0
    return u(trem(s(a),s(b)))
def divw(a,b):
    x,y=s32(a),s32(b)
    if y==0: return M-1
    if x==-(1<<31) and y==-1: return sx(x)
    return sx(tdiv(x,y))
def remw(a,b):
    x,y=s32(a),s32(b)
    if y==0: return sx(x)
    if x==-(1<<31) and y==-1: return 0
    return sx(trem(x,y))
R = {
 'add':lambda a,b:u(a+b),'sub':lambda a,b:u(a-b),'sll':lambda a,b:u(a<<(b&63)),
 'slt':lambda a,b:int(s(a)<s(b)),'sltu':lambda a,b:int(a<b),'xor':lambda a,b:a^b,
 'srl':lambda a,b:a>>(b&63),'sra':lambda a,b:u(s(a)>>(b&63)),'or':lambda a,b:a|b,'and':lambda a,b:a&b,
 'addw':lambda a,b:sx(a+b),'subw':lambda a,b:sx(a-b),'sllw':lambda a,b:sx(a<<(b&31)),
 'srlw':lambda a,b:sx(u32(a)>>(b&31)),'sraw':lambda a,b:sx(s32(a)>>(b&31)),
 'mul':lambda a,b:u(a*b),'mulh':lambda a,b:u((s(a)*s(b))>>64),'mulhsu':lambda a,b:u((s(a)*b)>>64),
 'mulhu':lambda a,b:(a*b)>>64,'div':div,'divu':lambda a,b:M-1 if b==0 else a//b,'rem':rem,
 'remu':lambda a,b:a if b==0 else a%b,'mulw':lambda a,b:sx(a*b),'divw':divw,
 'divuw':lambda a,b:M-1 if u32(b)==0 else sx(u32(a)//u32(b)),'remw':remw,
 'remuw':lambda a,b:sx(u32(a)) if u32(b)==0 else sx(u32(a)%u32(b)),
}
I = {
 'addi':lambda a,i:u(a+i),'slti':lambda a,i:int(s(a)<i),'sltiu':lambda a,i:int(a<u(i)),
 'xori':lambda a,i:a^u(i),'ori':lambda a,i:a|u(i),'andi':lambda a,i:a&u(i),
 'slli':lambda a,i:u(a<<i),'srli':lambda a,i:a>>i,'srai':lambda a,i:u(s(a)>>i),
 'addiw':lambda a,i:sx(a+i),'slliw':lambda a,i:sx(a<<i),'srliw':lambda a,i:sx(u32(a)>>i),'sraiw':lambda a,i:sx(s32(a)>>i),
}
B = {'beq':lambda a,b:a==b,'bne':lambda a,b:a!=b,'blt':lambda a,b:s(a)<s(b),'bge':lambda a,b:s(a)>=s(b),
     'bltu':lambda a,b:a<b,'bgeu':lambda a,b:a>=b}
V=[0,1,u(-1),7,u(-7),MIN,MIN-1,0x80000000,0x7fffffff,u(-0x80000000),0x123456789abcdef0,0xfedcba9876543210,63,64,33]
pairs=[(V[i],V[j]) for i in range(len(V)) for j in range(len(V)) if (i*7+j*3)%11==0 or i==j or j in (0,1,2)]
out=[]; n=0
h=lambda v:'0x%x'%v
def check(reg,exp):
    global n
    out.append(f"    li   t6, {h(exp)}"); out.append(f"    beq  {reg}, t6, t{n}_ok"); out.append("    j    fail"); out.append(f"t{n}_ok:")
for op,f in R.items():
    sel = pairs[::3] if op in('div','divu','rem','remu','divw','divuw','remw','remuw','mulh','mulhsu','mulhu','mul') else pairs[::7]
    for a,b in sel:
        n+=1; out.append(f"t{n}: # {op} {h(a)}, {h(b)}"); out.append(f"    li   a0, {n}")
        out.append(f"    li   a1, {h(a)}"); out.append(f"    li   a2, {h(b)}"); out.append(f"    {op} a3, a1, a2"); check('a3',f(a,b))
IMM=[0,1,-1,2047,-2048,0x555,-0x800+3]
SH=[0,1,31,32,63]
for op,f in I.items():
    imms = SH if op in('slli','srli','srai') else [x for x in SH if x<32] if op in('slliw','srliw','sraiw') else IMM
    for a in V[::4]:
        for i in imms:
            n+=1; out.append(f"t{n}: # {op} {h(a)}, {i}"); out.append(f"    li   a0, {n}")
            out.append(f"    li   a1, {h(a)}"); out.append(f"    {op} a3, a1, {i}"); check('a3',f(a,i))
for op,f in B.items():
    for a,b in pairs[::9]:
        n+=1; out+= [f"t{n}: # {op} {h(a)}, {h(b)}", f"    li   a0, {n}", f"    li   a1, {h(a)}", f"    li   a2, {h(b)}",
            f"    li   a3, 0", f"    {op} a1, a2, t{n}_taken", f"    j    t{n}_chk", f"t{n}_taken:", f"    li   a3, 1", f"t{n}_chk:"]
        check('a3',int(f(a,b)))
# lui / auipc
for imm in [0,1,0x7ffff,0x80000,0xfffff,0x12345]:
    n+=1; out+=[f"t{n}: # lui {h(imm)}", f"    li   a0, {n}", f"    lui  a3, {h(imm)}"]; check('a3',u(s32(imm<<12)))
    n+=1; out+=[f"t{n}: # auipc {h(imm)}", f"    li   a0, {n}", f"t{n}_pc:", f"    auipc a3, {h(imm)}", f"    la   t5, t{n}_pc",
                f"    li   t6, {h(u(s32(imm<<12)))}", f"    add  t5, t5, t6", f"    beq  a3, t5, t{n}_ok", "    j    fail", f"t{n}_ok:"]
# jal / jalr
n+=1; out+=[f"t{n}: # jal link + target", f"    li   a0, {n}", f"    jal  ra, t{n}_tgt", f"t{n}_ret:", f"    j    fail",
            f"t{n}_tgt:", f"    la   t6, t{n}_ret", f"    beq  ra, t6, t{n}_ok", "    j    fail", f"t{n}_ok:"]
n+=1; out+=[f"t{n}: # jalr clears bit 0 of the target", f"    li   a0, {n}", f"    la   t0, t{n}_tgt", f"    jalr ra, 1(t0)", f"t{n}_ret:", f"    j    fail",
            f"t{n}_tgt:", f"    la   t6, t{n}_ret", f"    beq  ra, t6, t{n}_ok", "    j    fail", f"t{n}_ok:"]
n+=1; out+=[f"t{n}: # jal x0 (no link) and rd=x0 writes are dropped", f"    li   a0, {n}", f"    jal  zero, t{n}_tgt", f"    j    fail",
            f"t{n}_tgt:", f"    addi zero, zero, 5", f"    beqz zero, t{n}_ok", "    j    fail", f"t{n}_ok:"]
# loads / stores
pat=0x8182838485868788
mem={}
def st(addr,val,size):
    for k in range(size): mem[addr+k]=(val>>(8*k))&0xff
def ld(addr,size,signed):
    v=sum(mem.get(addr+k,0)<<(8*k) for k in range(size))
    if signed and v>>(8*size-1): v-=1<<(8*size)
    return u(v)
out_mem=[]
n+=1; out+=[f"t{n}: # sd then every load width", f"    li   a0, {n}", "    la   s0, scratch", f"    li   t0, {h(pat)}", "    sd   t0, 0(s0)"]
st(0,pat,8)
for op,size,sg in [('lb',1,1),('lbu',1,0),('lh',2,1),('lhu',2,0),('lw',4,1),('lwu',4,0),('ld',8,0)]:
    for off in [0,1,2,4] if size<8 else [0]:
        if off % size: continue
        n+=1; out+=[f"t{n}: # {op} {off}", f"    li   a0, {n}", f"    {op}   a3, {off}(s0)"]; check('a3',ld(off,size,sg))
for op,size in [('sb',1),('sh',2),('sw',4),('sd',8)]:
    n+=1; val=0x0102030405060708 ^ (size*0x1111)
    out+=[f"t{n}: # {op} then ld", f"    li   a0, {n}", f"    li   t0, {h(pat)}", "    sd   t0, 8(s0)", f"    li   t1, {h(val)}",
          f"    {op}   t1, 8(s0)", "    ld   a3, 8(s0)"]
    st(8,pat,8); st(8,val & ((1<<(8*size))-1),size); check('a3',ld(8,8,0))
n+=1; out+=[f"t{n}: # negative offset", f"    li   a0, {n}", "    addi s1, s0, 16", "    ld   a3, -16(s1)"]; check('a3',pat)
n+=1; out+=[f"t{n}: # fence is a no-op", f"    li   a0, {n}", "    li   a3, 9", "    fence", "    addi a3, a3, 1"]; check('a3',10)

# ---------------- Zicsr (status CSR 0x50A is read/write; counters are read-only) ----------------
def csr_case(desc, lines, reg, exp):
    global n
    n+=1; out.append(f"t{n}: # {desc}"); out.append(f"    li   a0, {n}"); out.extend(lines); check(reg, exp)
csr_case("csrrw returns old value", ["    li   t0, 0x5a", "    csrw status, t0", "    li   t1, 0x33", "    csrrw a3, status, t1"], 'a3', 0x5a)
csr_case("csrrw wrote new value", ["    csrr a3, status"], 'a3', 0x33)
csr_case("csrrs sets bits", ["    li   t0, 0x0c", "    csrrs a3, status, t0", "    csrr a3, status"], 'a3', 0x3f)
csr_case("csrrc clears bits", ["    li   t0, 0x0f", "    csrrc a3, status, t0", "    csrr a3, status"], 'a3', 0x30)
csr_case("csrrs with x0 does not write", ["    csrrs a3, status, x0", "    csrr a4, status", "    sub  a3, a3, a4"], 'a3', 0)
csr_case("csrrwi", ["    csrrwi a3, status, 17", "    csrr a3, status"], 'a3', 17)
csr_case("csrrsi", ["    csrrsi a3, status, 8", "    csrr a3, status"], 'a3', 25)
csr_case("csrrci", ["    csrrci a3, status, 1", "    csrr a3, status"], 'a3', 24)
csr_case("csr read then forward to next instruction", ["    csrwi status, 5", "    csrr t0, status", "    addi a3, t0, 1"], 'a3', 6)
csr_case("hartid reads 0", ["    csrr a3, hartid"], 'a3', 0)
csr_case("mhartid reads 0", ["    csrr a3, mhartid"], 'a3', 0)
csr_case("cycle counter moves forward", ["    rdcycle t0", "    nop", "    nop", "    rdcycle t1", "    sltu a3, t0, t1"], 'a3', 1)
csr_case("instret counts 3 retired instructions between reads (3 nops first so no earlier bubble is still draining)", ["    nop", "    nop", "    nop", "    rdinstret t0", "    nop", "    nop", "    rdinstret t1", "    sub  a3, t1, t0"], 'a3', 3)
csr_case("cycle counter is read-only", ["    rdcycle t0", "    csrw cycle, zero", "    rdcycle t1", "    sltu a3, t0, t1"], 'a3', 1)

hdr=f"""# =============================================================================
# tests/isa_selfcheck.s: AUTO-GENERATED self-checking test of every RV64IM +
# Zicsr instruction ({n} test cases, expected values computed by an independent
# Python reference model). Uses the riscv-tests convention:
#   PASS: tohost = 1           FAIL: tohost = (test number << 1) | 1
# so the testbench prints "FAIL in test N": search for "tN:" below.
#
# EXPECT: a0 = 0
# =============================================================================
"""
body="\n".join(out)
tail="""
pass:
    li   a0, 0
    halt               # tohost = 1: PASS
fail:
    slli t0, a0, 1     # a0 holds the failing test number
    ori  t0, t0, 1
    csrw tohost, t0    # tohost = (n << 1) | 1: FAIL in test n
    j    .

    .align 3
scratch:
    .zero 32
"""
open('tests/isa_selfcheck.s','w').write(hdr+body+tail)
print(n,"tests")
