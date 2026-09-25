# =============================================================================
# 08_gcd_euclid.s: greatest common divisor with REM (M extension)
#
#   while (b != 0) { t = a % b; a = b; b = t; }
#
# EXPECT: a0 = 21
# =============================================================================
    li   a0, 1071
    li   a1, 462
loop:
    beqz a1, done
    rem  t0, a0, a1
    mv   a0, a1
    mv   a1, t0
    j    loop
done:
    halt
