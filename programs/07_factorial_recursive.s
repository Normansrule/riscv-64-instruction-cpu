# =============================================================================
# 07_factorial_recursive.s: recursion, the stack, CALL and RET
#
#   long fact(long n) { return n <= 1 ? 1 : n * fact(n - 1); }
#
# Every call pushes the return address (ra) and n onto the stack with SD and
# pops them with LD. "call" is JAL ra: FETCH2 redirects it (1 bubble).
# "ret" is JALR zero, 0(ra): its target is in a register, so EXECUTE always
# flushes (3 bubbles). fact(20) = 2,432,902,008,176,640,000
# is the largest factorial that fits in a signed 64-bit register.
#
# EXPECT: a0 = 2432902008176640000
# =============================================================================
    li   sp, 0xF000          # stack grows down from here
    li   a0, 20
    call fact
    halt

fact:
    li   t0, 1
    ble  a0, t0, base        # n <= 1 -> return 1
    addi sp, sp, -16         # push frame
    sd   ra, 8(sp)
    sd   a0, 0(sp)
    addi a0, a0, -1
    call fact                # a0 = fact(n-1)
    ld   t1, 0(sp)           # t1 = n
    ld   ra, 8(sp)
    addi sp, sp, 16          # pop frame
    mul  a0, a0, t1          # n * fact(n-1)
    ret
base:
    li   a0, 1
    ret
