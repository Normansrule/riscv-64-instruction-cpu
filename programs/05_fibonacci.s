# =============================================================================
# 05_fibonacci.s: iterative Fibonacci, fib(50) in a 64-bit register
#
#   fib(0)=0, fib(1)=1, fib(n)=fib(n-1)+fib(n-2)
# fib(50) = 12,586,269,025 does NOT fit in 32 bits: this needs RV64.
#
# EXPECT: a0 = 12586269025
# =============================================================================
    li   a1, 50          # n
    li   a0, 0           # a = fib(0)
    li   a2, 1           # b = fib(1)
loop:
    beqz a1, done
    add  a3, a0, a2      # t = a + b
    mv   a0, a2          # a = b
    mv   a2, a3          # b = t
    addi a1, a1, -1
    j    loop
done:
    halt
