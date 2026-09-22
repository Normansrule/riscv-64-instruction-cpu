# =============================================================================
# 09_primes_sieve.s — Sieve of Eratosthenes: count primes below 1000
#
# Uses a 1000-byte array (SB/LBU), nested loops and MUL for p*p.
# EXPECT: a0 = 168
# =============================================================================
    la   s0, sieve           # sieve[i] = 1 means "i is composite"
    li   s1, 1000            # N
    li   t0, 2               # p = 2
outer:
    mul  t1, t0, t0          # p*p
    bge  t1, s1, count
    add  t2, s0, t0
    lbu  t3, 0(t2)
    bnez t3, next_p          # p already composite
mark:
    bge  t1, s1, next_p
    add  t2, s0, t1
    li   t3, 1
    sb   t3, 0(t2)
    add  t1, t1, t0          # j += p
    j    mark
next_p:
    addi t0, t0, 1
    j    outer
count:
    li   a0, 0
    li   t0, 2
count_loop:
    bge  t0, s1, done
    add  t2, s0, t0
    lbu  t3, 0(t2)
    bnez t3, skip
    addi a0, a0, 1
skip:
    addi t0, t0, 1
    j    count_loop
done:
    ecall

sieve:
    .zero 1000
