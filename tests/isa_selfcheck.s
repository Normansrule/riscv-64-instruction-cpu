# =============================================================================
# tests/isa_selfcheck.s: AUTO-GENERATED self-checking test of every RV64IM +
# Zicsr + Zba + Zbb + Zbs + trap instruction (1624 test cases, expected values computed by an independent
# Python reference model). Uses the riscv-tests convention:
#   PASS: tohost = 1           FAIL: tohost = (test number << 1) | 1
# so the testbench prints "FAIL in test N": search for "tN:" below.
#
# EXPECT: a0 = 0
# =============================================================================
t1: # add 0x0, 0x0
    li   a0, 1
    li   a1, 0x0
    li   a2, 0x0
    add a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1_ok
    j    fail
t1_ok:
t2: # add 0x1, 0x8000000000000000
    li   a0, 2
    li   a1, 0x1
    li   a2, 0x8000000000000000
    add a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t2_ok
    j    fail
t2_ok:
t3: # add 0x7, 0xffffffffffffffff
    li   a0, 3
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    add a3, a1, a2
    li   t6, 0x6
    beq  a3, t6, t3_ok
    j    fail
t3_ok:
t4: # add 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 4
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    add a3, a1, a2
    li   t6, 0xffffffff7ffffff9
    beq  a3, t6, t4_ok
    j    fail
t4_ok:
t5: # add 0x7fffffffffffffff, 0x0
    li   a0, 5
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    add a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t5_ok
    j    fail
t5_ok:
t6: # add 0x80000000, 0xffffffffffffffff
    li   a0, 6
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    add a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t6_ok
    j    fail
t6_ok:
t7: # add 0x7fffffff, 0x7fffffff
    li   a0, 7
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    add a3, a1, a2
    li   t6, 0xfffffffe
    beq  a3, t6, t7_ok
    j    fail
t7_ok:
t8: # add 0x123456789abcdef0, 0x1
    li   a0, 8
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    add a3, a1, a2
    li   t6, 0x123456789abcdef1
    beq  a3, t6, t8_ok
    j    fail
t8_ok:
t9: # add 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 9
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    add a3, a1, a2
    li   t6, 0xfdb97530eca86420
    beq  a3, t6, t9_ok
    j    fail
t9_ok:
t10: # add 0x40, 0x1
    li   a0, 10
    li   a1, 0x40
    li   a2, 0x1
    add a3, a1, a2
    li   t6, 0x41
    beq  a3, t6, t10_ok
    j    fail
t10_ok:
t11: # add 0x21, 0xfffffffffffffff9
    li   a0, 11
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    add a3, a1, a2
    li   t6, 0x1a
    beq  a3, t6, t11_ok
    j    fail
t11_ok:
t12: # sub 0x0, 0x0
    li   a0, 12
    li   a1, 0x0
    li   a2, 0x0
    sub a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t12_ok
    j    fail
t12_ok:
t13: # sub 0x1, 0x8000000000000000
    li   a0, 13
    li   a1, 0x1
    li   a2, 0x8000000000000000
    sub a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t13_ok
    j    fail
t13_ok:
t14: # sub 0x7, 0xffffffffffffffff
    li   a0, 14
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    sub a3, a1, a2
    li   t6, 0x8
    beq  a3, t6, t14_ok
    j    fail
t14_ok:
t15: # sub 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 15
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    sub a3, a1, a2
    li   t6, 0x7ffffff9
    beq  a3, t6, t15_ok
    j    fail
t15_ok:
t16: # sub 0x7fffffffffffffff, 0x0
    li   a0, 16
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    sub a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t16_ok
    j    fail
t16_ok:
t17: # sub 0x80000000, 0xffffffffffffffff
    li   a0, 17
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sub a3, a1, a2
    li   t6, 0x80000001
    beq  a3, t6, t17_ok
    j    fail
t17_ok:
t18: # sub 0x7fffffff, 0x7fffffff
    li   a0, 18
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    sub a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t18_ok
    j    fail
t18_ok:
t19: # sub 0x123456789abcdef0, 0x1
    li   a0, 19
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    sub a3, a1, a2
    li   t6, 0x123456789abcdeef
    beq  a3, t6, t19_ok
    j    fail
t19_ok:
t20: # sub 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 20
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    sub a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t20_ok
    j    fail
t20_ok:
t21: # sub 0x40, 0x1
    li   a0, 21
    li   a1, 0x40
    li   a2, 0x1
    sub a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t21_ok
    j    fail
t21_ok:
t22: # sub 0x21, 0xfffffffffffffff9
    li   a0, 22
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sub a3, a1, a2
    li   t6, 0x28
    beq  a3, t6, t22_ok
    j    fail
t22_ok:
t23: # sll 0x0, 0x0
    li   a0, 23
    li   a1, 0x0
    li   a2, 0x0
    sll a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t23_ok
    j    fail
t23_ok:
t24: # sll 0x1, 0x8000000000000000
    li   a0, 24
    li   a1, 0x1
    li   a2, 0x8000000000000000
    sll a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t24_ok
    j    fail
t24_ok:
t25: # sll 0x7, 0xffffffffffffffff
    li   a0, 25
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    sll a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t25_ok
    j    fail
t25_ok:
t26: # sll 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 26
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    sll a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t26_ok
    j    fail
t26_ok:
t27: # sll 0x7fffffffffffffff, 0x0
    li   a0, 27
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    sll a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t27_ok
    j    fail
t27_ok:
t28: # sll 0x80000000, 0xffffffffffffffff
    li   a0, 28
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sll a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t28_ok
    j    fail
t28_ok:
t29: # sll 0x7fffffff, 0x7fffffff
    li   a0, 29
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    sll a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t29_ok
    j    fail
t29_ok:
t30: # sll 0x123456789abcdef0, 0x1
    li   a0, 30
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    sll a3, a1, a2
    li   t6, 0x2468acf13579bde0
    beq  a3, t6, t30_ok
    j    fail
t30_ok:
t31: # sll 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 31
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    sll a3, a1, a2
    li   t6, 0xba98765432100000
    beq  a3, t6, t31_ok
    j    fail
t31_ok:
t32: # sll 0x40, 0x1
    li   a0, 32
    li   a1, 0x40
    li   a2, 0x1
    sll a3, a1, a2
    li   t6, 0x80
    beq  a3, t6, t32_ok
    j    fail
t32_ok:
t33: # sll 0x21, 0xfffffffffffffff9
    li   a0, 33
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sll a3, a1, a2
    li   t6, 0x4200000000000000
    beq  a3, t6, t33_ok
    j    fail
t33_ok:
t34: # slt 0x0, 0x0
    li   a0, 34
    li   a1, 0x0
    li   a2, 0x0
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t34_ok
    j    fail
t34_ok:
t35: # slt 0x1, 0x8000000000000000
    li   a0, 35
    li   a1, 0x1
    li   a2, 0x8000000000000000
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t35_ok
    j    fail
t35_ok:
t36: # slt 0x7, 0xffffffffffffffff
    li   a0, 36
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t36_ok
    j    fail
t36_ok:
t37: # slt 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 37
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t37_ok
    j    fail
t37_ok:
t38: # slt 0x7fffffffffffffff, 0x0
    li   a0, 38
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t38_ok
    j    fail
t38_ok:
t39: # slt 0x80000000, 0xffffffffffffffff
    li   a0, 39
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t39_ok
    j    fail
t39_ok:
t40: # slt 0x7fffffff, 0x7fffffff
    li   a0, 40
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t40_ok
    j    fail
t40_ok:
t41: # slt 0x123456789abcdef0, 0x1
    li   a0, 41
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t41_ok
    j    fail
t41_ok:
t42: # slt 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 42
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t42_ok
    j    fail
t42_ok:
t43: # slt 0x40, 0x1
    li   a0, 43
    li   a1, 0x40
    li   a2, 0x1
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t43_ok
    j    fail
t43_ok:
t44: # slt 0x21, 0xfffffffffffffff9
    li   a0, 44
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    slt a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t44_ok
    j    fail
t44_ok:
t45: # sltu 0x0, 0x0
    li   a0, 45
    li   a1, 0x0
    li   a2, 0x0
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t45_ok
    j    fail
t45_ok:
t46: # sltu 0x1, 0x8000000000000000
    li   a0, 46
    li   a1, 0x1
    li   a2, 0x8000000000000000
    sltu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t46_ok
    j    fail
t46_ok:
t47: # sltu 0x7, 0xffffffffffffffff
    li   a0, 47
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    sltu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t47_ok
    j    fail
t47_ok:
t48: # sltu 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 48
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t48_ok
    j    fail
t48_ok:
t49: # sltu 0x7fffffffffffffff, 0x0
    li   a0, 49
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t49_ok
    j    fail
t49_ok:
t50: # sltu 0x80000000, 0xffffffffffffffff
    li   a0, 50
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sltu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t50_ok
    j    fail
t50_ok:
t51: # sltu 0x7fffffff, 0x7fffffff
    li   a0, 51
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t51_ok
    j    fail
t51_ok:
t52: # sltu 0x123456789abcdef0, 0x1
    li   a0, 52
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t52_ok
    j    fail
t52_ok:
t53: # sltu 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 53
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t53_ok
    j    fail
t53_ok:
t54: # sltu 0x40, 0x1
    li   a0, 54
    li   a1, 0x40
    li   a2, 0x1
    sltu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t54_ok
    j    fail
t54_ok:
t55: # sltu 0x21, 0xfffffffffffffff9
    li   a0, 55
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sltu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t55_ok
    j    fail
t55_ok:
t56: # xor 0x0, 0x0
    li   a0, 56
    li   a1, 0x0
    li   a2, 0x0
    xor a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t56_ok
    j    fail
t56_ok:
t57: # xor 0x1, 0x8000000000000000
    li   a0, 57
    li   a1, 0x1
    li   a2, 0x8000000000000000
    xor a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t57_ok
    j    fail
t57_ok:
t58: # xor 0x7, 0xffffffffffffffff
    li   a0, 58
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    xor a3, a1, a2
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t58_ok
    j    fail
t58_ok:
t59: # xor 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 59
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    xor a3, a1, a2
    li   t6, 0x7ffffff9
    beq  a3, t6, t59_ok
    j    fail
t59_ok:
t60: # xor 0x7fffffffffffffff, 0x0
    li   a0, 60
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    xor a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t60_ok
    j    fail
t60_ok:
t61: # xor 0x80000000, 0xffffffffffffffff
    li   a0, 61
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    xor a3, a1, a2
    li   t6, 0xffffffff7fffffff
    beq  a3, t6, t61_ok
    j    fail
t61_ok:
t62: # xor 0x7fffffff, 0x7fffffff
    li   a0, 62
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    xor a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t62_ok
    j    fail
t62_ok:
t63: # xor 0x123456789abcdef0, 0x1
    li   a0, 63
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    xor a3, a1, a2
    li   t6, 0x123456789abcdef1
    beq  a3, t6, t63_ok
    j    fail
t63_ok:
t64: # xor 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 64
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    xor a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t64_ok
    j    fail
t64_ok:
t65: # xor 0x40, 0x1
    li   a0, 65
    li   a1, 0x40
    li   a2, 0x1
    xor a3, a1, a2
    li   t6, 0x41
    beq  a3, t6, t65_ok
    j    fail
t65_ok:
t66: # xor 0x21, 0xfffffffffffffff9
    li   a0, 66
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    xor a3, a1, a2
    li   t6, 0xffffffffffffffd8
    beq  a3, t6, t66_ok
    j    fail
t66_ok:
t67: # srl 0x0, 0x0
    li   a0, 67
    li   a1, 0x0
    li   a2, 0x0
    srl a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t67_ok
    j    fail
t67_ok:
t68: # srl 0x1, 0x8000000000000000
    li   a0, 68
    li   a1, 0x1
    li   a2, 0x8000000000000000
    srl a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t68_ok
    j    fail
t68_ok:
t69: # srl 0x7, 0xffffffffffffffff
    li   a0, 69
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    srl a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t69_ok
    j    fail
t69_ok:
t70: # srl 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 70
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    srl a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t70_ok
    j    fail
t70_ok:
t71: # srl 0x7fffffffffffffff, 0x0
    li   a0, 71
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    srl a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t71_ok
    j    fail
t71_ok:
t72: # srl 0x80000000, 0xffffffffffffffff
    li   a0, 72
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    srl a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t72_ok
    j    fail
t72_ok:
t73: # srl 0x7fffffff, 0x7fffffff
    li   a0, 73
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    srl a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t73_ok
    j    fail
t73_ok:
t74: # srl 0x123456789abcdef0, 0x1
    li   a0, 74
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    srl a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f78
    beq  a3, t6, t74_ok
    j    fail
t74_ok:
t75: # srl 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 75
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    srl a3, a1, a2
    li   t6, 0xfedcba987654
    beq  a3, t6, t75_ok
    j    fail
t75_ok:
t76: # srl 0x40, 0x1
    li   a0, 76
    li   a1, 0x40
    li   a2, 0x1
    srl a3, a1, a2
    li   t6, 0x20
    beq  a3, t6, t76_ok
    j    fail
t76_ok:
t77: # srl 0x21, 0xfffffffffffffff9
    li   a0, 77
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    srl a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t77_ok
    j    fail
t77_ok:
t78: # sra 0x0, 0x0
    li   a0, 78
    li   a1, 0x0
    li   a2, 0x0
    sra a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t78_ok
    j    fail
t78_ok:
t79: # sra 0x1, 0x8000000000000000
    li   a0, 79
    li   a1, 0x1
    li   a2, 0x8000000000000000
    sra a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t79_ok
    j    fail
t79_ok:
t80: # sra 0x7, 0xffffffffffffffff
    li   a0, 80
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    sra a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t80_ok
    j    fail
t80_ok:
t81: # sra 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 81
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    sra a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t81_ok
    j    fail
t81_ok:
t82: # sra 0x7fffffffffffffff, 0x0
    li   a0, 82
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    sra a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t82_ok
    j    fail
t82_ok:
t83: # sra 0x80000000, 0xffffffffffffffff
    li   a0, 83
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sra a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t83_ok
    j    fail
t83_ok:
t84: # sra 0x7fffffff, 0x7fffffff
    li   a0, 84
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    sra a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t84_ok
    j    fail
t84_ok:
t85: # sra 0x123456789abcdef0, 0x1
    li   a0, 85
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    sra a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f78
    beq  a3, t6, t85_ok
    j    fail
t85_ok:
t86: # sra 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 86
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    sra a3, a1, a2
    li   t6, 0xfffffedcba987654
    beq  a3, t6, t86_ok
    j    fail
t86_ok:
t87: # sra 0x40, 0x1
    li   a0, 87
    li   a1, 0x40
    li   a2, 0x1
    sra a3, a1, a2
    li   t6, 0x20
    beq  a3, t6, t87_ok
    j    fail
t87_ok:
t88: # sra 0x21, 0xfffffffffffffff9
    li   a0, 88
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sra a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t88_ok
    j    fail
t88_ok:
t89: # or 0x0, 0x0
    li   a0, 89
    li   a1, 0x0
    li   a2, 0x0
    or a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t89_ok
    j    fail
t89_ok:
t90: # or 0x1, 0x8000000000000000
    li   a0, 90
    li   a1, 0x1
    li   a2, 0x8000000000000000
    or a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t90_ok
    j    fail
t90_ok:
t91: # or 0x7, 0xffffffffffffffff
    li   a0, 91
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    or a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t91_ok
    j    fail
t91_ok:
t92: # or 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 92
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    or a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t92_ok
    j    fail
t92_ok:
t93: # or 0x7fffffffffffffff, 0x0
    li   a0, 93
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    or a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t93_ok
    j    fail
t93_ok:
t94: # or 0x80000000, 0xffffffffffffffff
    li   a0, 94
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    or a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t94_ok
    j    fail
t94_ok:
t95: # or 0x7fffffff, 0x7fffffff
    li   a0, 95
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    or a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t95_ok
    j    fail
t95_ok:
t96: # or 0x123456789abcdef0, 0x1
    li   a0, 96
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    or a3, a1, a2
    li   t6, 0x123456789abcdef1
    beq  a3, t6, t96_ok
    j    fail
t96_ok:
t97: # or 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 97
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    or a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t97_ok
    j    fail
t97_ok:
t98: # or 0x40, 0x1
    li   a0, 98
    li   a1, 0x40
    li   a2, 0x1
    or a3, a1, a2
    li   t6, 0x41
    beq  a3, t6, t98_ok
    j    fail
t98_ok:
t99: # or 0x21, 0xfffffffffffffff9
    li   a0, 99
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    or a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t99_ok
    j    fail
t99_ok:
t100: # and 0x0, 0x0
    li   a0, 100
    li   a1, 0x0
    li   a2, 0x0
    and a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t100_ok
    j    fail
t100_ok:
t101: # and 0x1, 0x8000000000000000
    li   a0, 101
    li   a1, 0x1
    li   a2, 0x8000000000000000
    and a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t101_ok
    j    fail
t101_ok:
t102: # and 0x7, 0xffffffffffffffff
    li   a0, 102
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    and a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t102_ok
    j    fail
t102_ok:
t103: # and 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 103
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    and a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t103_ok
    j    fail
t103_ok:
t104: # and 0x7fffffffffffffff, 0x0
    li   a0, 104
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    and a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t104_ok
    j    fail
t104_ok:
t105: # and 0x80000000, 0xffffffffffffffff
    li   a0, 105
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    and a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t105_ok
    j    fail
t105_ok:
t106: # and 0x7fffffff, 0x7fffffff
    li   a0, 106
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    and a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t106_ok
    j    fail
t106_ok:
t107: # and 0x123456789abcdef0, 0x1
    li   a0, 107
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    and a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t107_ok
    j    fail
t107_ok:
t108: # and 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 108
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    and a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t108_ok
    j    fail
t108_ok:
t109: # and 0x40, 0x1
    li   a0, 109
    li   a1, 0x40
    li   a2, 0x1
    and a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t109_ok
    j    fail
t109_ok:
t110: # and 0x21, 0xfffffffffffffff9
    li   a0, 110
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    and a3, a1, a2
    li   t6, 0x21
    beq  a3, t6, t110_ok
    j    fail
t110_ok:
t111: # addw 0x0, 0x0
    li   a0, 111
    li   a1, 0x0
    li   a2, 0x0
    addw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t111_ok
    j    fail
t111_ok:
t112: # addw 0x1, 0x8000000000000000
    li   a0, 112
    li   a1, 0x1
    li   a2, 0x8000000000000000
    addw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t112_ok
    j    fail
t112_ok:
t113: # addw 0x7, 0xffffffffffffffff
    li   a0, 113
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    addw a3, a1, a2
    li   t6, 0x6
    beq  a3, t6, t113_ok
    j    fail
t113_ok:
t114: # addw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 114
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    addw a3, a1, a2
    li   t6, 0x7ffffff9
    beq  a3, t6, t114_ok
    j    fail
t114_ok:
t115: # addw 0x7fffffffffffffff, 0x0
    li   a0, 115
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    addw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t115_ok
    j    fail
t115_ok:
t116: # addw 0x80000000, 0xffffffffffffffff
    li   a0, 116
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    addw a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t116_ok
    j    fail
t116_ok:
t117: # addw 0x7fffffff, 0x7fffffff
    li   a0, 117
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    addw a3, a1, a2
    li   t6, 0xfffffffffffffffe
    beq  a3, t6, t117_ok
    j    fail
t117_ok:
t118: # addw 0x123456789abcdef0, 0x1
    li   a0, 118
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    addw a3, a1, a2
    li   t6, 0xffffffff9abcdef1
    beq  a3, t6, t118_ok
    j    fail
t118_ok:
t119: # addw 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 119
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    addw a3, a1, a2
    li   t6, 0xffffffffeca86420
    beq  a3, t6, t119_ok
    j    fail
t119_ok:
t120: # addw 0x40, 0x1
    li   a0, 120
    li   a1, 0x40
    li   a2, 0x1
    addw a3, a1, a2
    li   t6, 0x41
    beq  a3, t6, t120_ok
    j    fail
t120_ok:
t121: # addw 0x21, 0xfffffffffffffff9
    li   a0, 121
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    addw a3, a1, a2
    li   t6, 0x1a
    beq  a3, t6, t121_ok
    j    fail
t121_ok:
t122: # subw 0x0, 0x0
    li   a0, 122
    li   a1, 0x0
    li   a2, 0x0
    subw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t122_ok
    j    fail
t122_ok:
t123: # subw 0x1, 0x8000000000000000
    li   a0, 123
    li   a1, 0x1
    li   a2, 0x8000000000000000
    subw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t123_ok
    j    fail
t123_ok:
t124: # subw 0x7, 0xffffffffffffffff
    li   a0, 124
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    subw a3, a1, a2
    li   t6, 0x8
    beq  a3, t6, t124_ok
    j    fail
t124_ok:
t125: # subw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 125
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    subw a3, a1, a2
    li   t6, 0x7ffffff9
    beq  a3, t6, t125_ok
    j    fail
t125_ok:
t126: # subw 0x7fffffffffffffff, 0x0
    li   a0, 126
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    subw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t126_ok
    j    fail
t126_ok:
t127: # subw 0x80000000, 0xffffffffffffffff
    li   a0, 127
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    subw a3, a1, a2
    li   t6, 0xffffffff80000001
    beq  a3, t6, t127_ok
    j    fail
t127_ok:
t128: # subw 0x7fffffff, 0x7fffffff
    li   a0, 128
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    subw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t128_ok
    j    fail
t128_ok:
t129: # subw 0x123456789abcdef0, 0x1
    li   a0, 129
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    subw a3, a1, a2
    li   t6, 0xffffffff9abcdeef
    beq  a3, t6, t129_ok
    j    fail
t129_ok:
t130: # subw 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 130
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    subw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t130_ok
    j    fail
t130_ok:
t131: # subw 0x40, 0x1
    li   a0, 131
    li   a1, 0x40
    li   a2, 0x1
    subw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t131_ok
    j    fail
t131_ok:
t132: # subw 0x21, 0xfffffffffffffff9
    li   a0, 132
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    subw a3, a1, a2
    li   t6, 0x28
    beq  a3, t6, t132_ok
    j    fail
t132_ok:
t133: # sllw 0x0, 0x0
    li   a0, 133
    li   a1, 0x0
    li   a2, 0x0
    sllw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t133_ok
    j    fail
t133_ok:
t134: # sllw 0x1, 0x8000000000000000
    li   a0, 134
    li   a1, 0x1
    li   a2, 0x8000000000000000
    sllw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t134_ok
    j    fail
t134_ok:
t135: # sllw 0x7, 0xffffffffffffffff
    li   a0, 135
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    sllw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t135_ok
    j    fail
t135_ok:
t136: # sllw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 136
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    sllw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t136_ok
    j    fail
t136_ok:
t137: # sllw 0x7fffffffffffffff, 0x0
    li   a0, 137
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    sllw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t137_ok
    j    fail
t137_ok:
t138: # sllw 0x80000000, 0xffffffffffffffff
    li   a0, 138
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sllw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t138_ok
    j    fail
t138_ok:
t139: # sllw 0x7fffffff, 0x7fffffff
    li   a0, 139
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    sllw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t139_ok
    j    fail
t139_ok:
t140: # sllw 0x123456789abcdef0, 0x1
    li   a0, 140
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    sllw a3, a1, a2
    li   t6, 0x3579bde0
    beq  a3, t6, t140_ok
    j    fail
t140_ok:
t141: # sllw 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 141
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    sllw a3, a1, a2
    li   t6, 0x32100000
    beq  a3, t6, t141_ok
    j    fail
t141_ok:
t142: # sllw 0x40, 0x1
    li   a0, 142
    li   a1, 0x40
    li   a2, 0x1
    sllw a3, a1, a2
    li   t6, 0x80
    beq  a3, t6, t142_ok
    j    fail
t142_ok:
t143: # sllw 0x21, 0xfffffffffffffff9
    li   a0, 143
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sllw a3, a1, a2
    li   t6, 0x42000000
    beq  a3, t6, t143_ok
    j    fail
t143_ok:
t144: # srlw 0x0, 0x0
    li   a0, 144
    li   a1, 0x0
    li   a2, 0x0
    srlw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t144_ok
    j    fail
t144_ok:
t145: # srlw 0x1, 0x8000000000000000
    li   a0, 145
    li   a1, 0x1
    li   a2, 0x8000000000000000
    srlw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t145_ok
    j    fail
t145_ok:
t146: # srlw 0x7, 0xffffffffffffffff
    li   a0, 146
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    srlw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t146_ok
    j    fail
t146_ok:
t147: # srlw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 147
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    srlw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t147_ok
    j    fail
t147_ok:
t148: # srlw 0x7fffffffffffffff, 0x0
    li   a0, 148
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    srlw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t148_ok
    j    fail
t148_ok:
t149: # srlw 0x80000000, 0xffffffffffffffff
    li   a0, 149
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    srlw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t149_ok
    j    fail
t149_ok:
t150: # srlw 0x7fffffff, 0x7fffffff
    li   a0, 150
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    srlw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t150_ok
    j    fail
t150_ok:
t151: # srlw 0x123456789abcdef0, 0x1
    li   a0, 151
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    srlw a3, a1, a2
    li   t6, 0x4d5e6f78
    beq  a3, t6, t151_ok
    j    fail
t151_ok:
t152: # srlw 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 152
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    srlw a3, a1, a2
    li   t6, 0x7654
    beq  a3, t6, t152_ok
    j    fail
t152_ok:
t153: # srlw 0x40, 0x1
    li   a0, 153
    li   a1, 0x40
    li   a2, 0x1
    srlw a3, a1, a2
    li   t6, 0x20
    beq  a3, t6, t153_ok
    j    fail
t153_ok:
t154: # srlw 0x21, 0xfffffffffffffff9
    li   a0, 154
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    srlw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t154_ok
    j    fail
t154_ok:
t155: # sraw 0x0, 0x0
    li   a0, 155
    li   a1, 0x0
    li   a2, 0x0
    sraw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t155_ok
    j    fail
t155_ok:
t156: # sraw 0x1, 0x8000000000000000
    li   a0, 156
    li   a1, 0x1
    li   a2, 0x8000000000000000
    sraw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t156_ok
    j    fail
t156_ok:
t157: # sraw 0x7, 0xffffffffffffffff
    li   a0, 157
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    sraw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t157_ok
    j    fail
t157_ok:
t158: # sraw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 158
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    sraw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t158_ok
    j    fail
t158_ok:
t159: # sraw 0x7fffffffffffffff, 0x0
    li   a0, 159
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    sraw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t159_ok
    j    fail
t159_ok:
t160: # sraw 0x80000000, 0xffffffffffffffff
    li   a0, 160
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sraw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t160_ok
    j    fail
t160_ok:
t161: # sraw 0x7fffffff, 0x7fffffff
    li   a0, 161
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    sraw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t161_ok
    j    fail
t161_ok:
t162: # sraw 0x123456789abcdef0, 0x1
    li   a0, 162
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    sraw a3, a1, a2
    li   t6, 0xffffffffcd5e6f78
    beq  a3, t6, t162_ok
    j    fail
t162_ok:
t163: # sraw 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 163
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    sraw a3, a1, a2
    li   t6, 0x7654
    beq  a3, t6, t163_ok
    j    fail
t163_ok:
t164: # sraw 0x40, 0x1
    li   a0, 164
    li   a1, 0x40
    li   a2, 0x1
    sraw a3, a1, a2
    li   t6, 0x20
    beq  a3, t6, t164_ok
    j    fail
t164_ok:
t165: # sraw 0x21, 0xfffffffffffffff9
    li   a0, 165
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sraw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t165_ok
    j    fail
t165_ok:
t166: # mul 0x0, 0x0
    li   a0, 166
    li   a1, 0x0
    li   a2, 0x0
    mul a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t166_ok
    j    fail
t166_ok:
t167: # mul 0x0, 0xfedcba9876543210
    li   a0, 167
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    mul a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t167_ok
    j    fail
t167_ok:
t168: # mul 0x1, 0xffffffffffffffff
    li   a0, 168
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    mul a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t168_ok
    j    fail
t168_ok:
t169: # mul 0xffffffffffffffff, 0x1
    li   a0, 169
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    mul a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t169_ok
    j    fail
t169_ok:
t170: # mul 0x7, 0x0
    li   a0, 170
    li   a1, 0x7
    li   a2, 0x0
    mul a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t170_ok
    j    fail
t170_ok:
t171: # mul 0x7, 0x7
    li   a0, 171
    li   a1, 0x7
    li   a2, 0x7
    mul a3, a1, a2
    li   t6, 0x31
    beq  a3, t6, t171_ok
    j    fail
t171_ok:
t172: # mul 0xfffffffffffffff9, 0x1
    li   a0, 172
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    mul a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t172_ok
    j    fail
t172_ok:
t173: # mul 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 173
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    mul a3, a1, a2
    li   t6, 0x380000000
    beq  a3, t6, t173_ok
    j    fail
t173_ok:
t174: # mul 0x8000000000000000, 0xffffffffffffffff
    li   a0, 174
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    mul a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t174_ok
    j    fail
t174_ok:
t175: # mul 0x8000000000000000, 0x21
    li   a0, 175
    li   a1, 0x8000000000000000
    li   a2, 0x21
    mul a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t175_ok
    j    fail
t175_ok:
t176: # mul 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 176
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    mul a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t176_ok
    j    fail
t176_ok:
t177: # mul 0x80000000, 0x0
    li   a0, 177
    li   a1, 0x80000000
    li   a2, 0x0
    mul a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t177_ok
    j    fail
t177_ok:
t178: # mul 0x80000000, 0x80000000
    li   a0, 178
    li   a1, 0x80000000
    li   a2, 0x80000000
    mul a3, a1, a2
    li   t6, 0x4000000000000000
    beq  a3, t6, t178_ok
    j    fail
t178_ok:
t179: # mul 0x7fffffff, 0x1
    li   a0, 179
    li   a1, 0x7fffffff
    li   a2, 0x1
    mul a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t179_ok
    j    fail
t179_ok:
t180: # mul 0x7fffffff, 0x7fffffff
    li   a0, 180
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    mul a3, a1, a2
    li   t6, 0x3fffffff00000001
    beq  a3, t6, t180_ok
    j    fail
t180_ok:
t181: # mul 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 181
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    mul a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t181_ok
    j    fail
t181_ok:
t182: # mul 0x123456789abcdef0, 0x0
    li   a0, 182
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    mul a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t182_ok
    j    fail
t182_ok:
t183: # mul 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 183
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    mul a3, a1, a2
    li   t6, 0xedcba98765432110
    beq  a3, t6, t183_ok
    j    fail
t183_ok:
t184: # mul 0xfedcba9876543210, 0x1
    li   a0, 184
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    mul a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t184_ok
    j    fail
t184_ok:
t185: # mul 0x3f, 0x0
    li   a0, 185
    li   a1, 0x3f
    li   a2, 0x0
    mul a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t185_ok
    j    fail
t185_ok:
t186: # mul 0x3f, 0x8000000000000000
    li   a0, 186
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    mul a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t186_ok
    j    fail
t186_ok:
t187: # mul 0x40, 0x1
    li   a0, 187
    li   a1, 0x40
    li   a2, 0x1
    mul a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t187_ok
    j    fail
t187_ok:
t188: # mul 0x40, 0x40
    li   a0, 188
    li   a1, 0x40
    li   a2, 0x40
    mul a3, a1, a2
    li   t6, 0x1000
    beq  a3, t6, t188_ok
    j    fail
t188_ok:
t189: # mul 0x21, 0xffffffffffffffff
    li   a0, 189
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    mul a3, a1, a2
    li   t6, 0xffffffffffffffdf
    beq  a3, t6, t189_ok
    j    fail
t189_ok:
t190: # mulh 0x0, 0x0
    li   a0, 190
    li   a1, 0x0
    li   a2, 0x0
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t190_ok
    j    fail
t190_ok:
t191: # mulh 0x0, 0xfedcba9876543210
    li   a0, 191
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t191_ok
    j    fail
t191_ok:
t192: # mulh 0x1, 0xffffffffffffffff
    li   a0, 192
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t192_ok
    j    fail
t192_ok:
t193: # mulh 0xffffffffffffffff, 0x1
    li   a0, 193
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t193_ok
    j    fail
t193_ok:
t194: # mulh 0x7, 0x0
    li   a0, 194
    li   a1, 0x7
    li   a2, 0x0
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t194_ok
    j    fail
t194_ok:
t195: # mulh 0x7, 0x7
    li   a0, 195
    li   a1, 0x7
    li   a2, 0x7
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t195_ok
    j    fail
t195_ok:
t196: # mulh 0xfffffffffffffff9, 0x1
    li   a0, 196
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t196_ok
    j    fail
t196_ok:
t197: # mulh 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 197
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t197_ok
    j    fail
t197_ok:
t198: # mulh 0x8000000000000000, 0xffffffffffffffff
    li   a0, 198
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t198_ok
    j    fail
t198_ok:
t199: # mulh 0x8000000000000000, 0x21
    li   a0, 199
    li   a1, 0x8000000000000000
    li   a2, 0x21
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffef
    beq  a3, t6, t199_ok
    j    fail
t199_ok:
t200: # mulh 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 200
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t200_ok
    j    fail
t200_ok:
t201: # mulh 0x80000000, 0x0
    li   a0, 201
    li   a1, 0x80000000
    li   a2, 0x0
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t201_ok
    j    fail
t201_ok:
t202: # mulh 0x80000000, 0x80000000
    li   a0, 202
    li   a1, 0x80000000
    li   a2, 0x80000000
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t202_ok
    j    fail
t202_ok:
t203: # mulh 0x7fffffff, 0x1
    li   a0, 203
    li   a1, 0x7fffffff
    li   a2, 0x1
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t203_ok
    j    fail
t203_ok:
t204: # mulh 0x7fffffff, 0x7fffffff
    li   a0, 204
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t204_ok
    j    fail
t204_ok:
t205: # mulh 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 205
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t205_ok
    j    fail
t205_ok:
t206: # mulh 0x123456789abcdef0, 0x0
    li   a0, 206
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t206_ok
    j    fail
t206_ok:
t207: # mulh 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 207
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    mulh a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f77
    beq  a3, t6, t207_ok
    j    fail
t207_ok:
t208: # mulh 0xfedcba9876543210, 0x1
    li   a0, 208
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t208_ok
    j    fail
t208_ok:
t209: # mulh 0x3f, 0x0
    li   a0, 209
    li   a1, 0x3f
    li   a2, 0x0
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t209_ok
    j    fail
t209_ok:
t210: # mulh 0x3f, 0x8000000000000000
    li   a0, 210
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffe0
    beq  a3, t6, t210_ok
    j    fail
t210_ok:
t211: # mulh 0x40, 0x1
    li   a0, 211
    li   a1, 0x40
    li   a2, 0x1
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t211_ok
    j    fail
t211_ok:
t212: # mulh 0x40, 0x40
    li   a0, 212
    li   a1, 0x40
    li   a2, 0x40
    mulh a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t212_ok
    j    fail
t212_ok:
t213: # mulh 0x21, 0xffffffffffffffff
    li   a0, 213
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    mulh a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t213_ok
    j    fail
t213_ok:
t214: # mulhsu 0x0, 0x0
    li   a0, 214
    li   a1, 0x0
    li   a2, 0x0
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t214_ok
    j    fail
t214_ok:
t215: # mulhsu 0x0, 0xfedcba9876543210
    li   a0, 215
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t215_ok
    j    fail
t215_ok:
t216: # mulhsu 0x1, 0xffffffffffffffff
    li   a0, 216
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t216_ok
    j    fail
t216_ok:
t217: # mulhsu 0xffffffffffffffff, 0x1
    li   a0, 217
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    mulhsu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t217_ok
    j    fail
t217_ok:
t218: # mulhsu 0x7, 0x0
    li   a0, 218
    li   a1, 0x7
    li   a2, 0x0
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t218_ok
    j    fail
t218_ok:
t219: # mulhsu 0x7, 0x7
    li   a0, 219
    li   a1, 0x7
    li   a2, 0x7
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t219_ok
    j    fail
t219_ok:
t220: # mulhsu 0xfffffffffffffff9, 0x1
    li   a0, 220
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    mulhsu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t220_ok
    j    fail
t220_ok:
t221: # mulhsu 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 221
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    mulhsu a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t221_ok
    j    fail
t221_ok:
t222: # mulhsu 0x8000000000000000, 0xffffffffffffffff
    li   a0, 222
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    mulhsu a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t222_ok
    j    fail
t222_ok:
t223: # mulhsu 0x8000000000000000, 0x21
    li   a0, 223
    li   a1, 0x8000000000000000
    li   a2, 0x21
    mulhsu a3, a1, a2
    li   t6, 0xffffffffffffffef
    beq  a3, t6, t223_ok
    j    fail
t223_ok:
t224: # mulhsu 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 224
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    mulhsu a3, a1, a2
    li   t6, 0x7ffffffffffffffe
    beq  a3, t6, t224_ok
    j    fail
t224_ok:
t225: # mulhsu 0x80000000, 0x0
    li   a0, 225
    li   a1, 0x80000000
    li   a2, 0x0
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t225_ok
    j    fail
t225_ok:
t226: # mulhsu 0x80000000, 0x80000000
    li   a0, 226
    li   a1, 0x80000000
    li   a2, 0x80000000
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t226_ok
    j    fail
t226_ok:
t227: # mulhsu 0x7fffffff, 0x1
    li   a0, 227
    li   a1, 0x7fffffff
    li   a2, 0x1
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t227_ok
    j    fail
t227_ok:
t228: # mulhsu 0x7fffffff, 0x7fffffff
    li   a0, 228
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t228_ok
    j    fail
t228_ok:
t229: # mulhsu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 229
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    mulhsu a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t229_ok
    j    fail
t229_ok:
t230: # mulhsu 0x123456789abcdef0, 0x0
    li   a0, 230
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t230_ok
    j    fail
t230_ok:
t231: # mulhsu 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 231
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    mulhsu a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f77
    beq  a3, t6, t231_ok
    j    fail
t231_ok:
t232: # mulhsu 0xfedcba9876543210, 0x1
    li   a0, 232
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    mulhsu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t232_ok
    j    fail
t232_ok:
t233: # mulhsu 0x3f, 0x0
    li   a0, 233
    li   a1, 0x3f
    li   a2, 0x0
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t233_ok
    j    fail
t233_ok:
t234: # mulhsu 0x3f, 0x8000000000000000
    li   a0, 234
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    mulhsu a3, a1, a2
    li   t6, 0x1f
    beq  a3, t6, t234_ok
    j    fail
t234_ok:
t235: # mulhsu 0x40, 0x1
    li   a0, 235
    li   a1, 0x40
    li   a2, 0x1
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t235_ok
    j    fail
t235_ok:
t236: # mulhsu 0x40, 0x40
    li   a0, 236
    li   a1, 0x40
    li   a2, 0x40
    mulhsu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t236_ok
    j    fail
t236_ok:
t237: # mulhsu 0x21, 0xffffffffffffffff
    li   a0, 237
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    mulhsu a3, a1, a2
    li   t6, 0x20
    beq  a3, t6, t237_ok
    j    fail
t237_ok:
t238: # mulhu 0x0, 0x0
    li   a0, 238
    li   a1, 0x0
    li   a2, 0x0
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t238_ok
    j    fail
t238_ok:
t239: # mulhu 0x0, 0xfedcba9876543210
    li   a0, 239
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t239_ok
    j    fail
t239_ok:
t240: # mulhu 0x1, 0xffffffffffffffff
    li   a0, 240
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t240_ok
    j    fail
t240_ok:
t241: # mulhu 0xffffffffffffffff, 0x1
    li   a0, 241
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t241_ok
    j    fail
t241_ok:
t242: # mulhu 0x7, 0x0
    li   a0, 242
    li   a1, 0x7
    li   a2, 0x0
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t242_ok
    j    fail
t242_ok:
t243: # mulhu 0x7, 0x7
    li   a0, 243
    li   a1, 0x7
    li   a2, 0x7
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t243_ok
    j    fail
t243_ok:
t244: # mulhu 0xfffffffffffffff9, 0x1
    li   a0, 244
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t244_ok
    j    fail
t244_ok:
t245: # mulhu 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 245
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    mulhu a3, a1, a2
    li   t6, 0xffffffff7ffffff9
    beq  a3, t6, t245_ok
    j    fail
t245_ok:
t246: # mulhu 0x8000000000000000, 0xffffffffffffffff
    li   a0, 246
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    mulhu a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t246_ok
    j    fail
t246_ok:
t247: # mulhu 0x8000000000000000, 0x21
    li   a0, 247
    li   a1, 0x8000000000000000
    li   a2, 0x21
    mulhu a3, a1, a2
    li   t6, 0x10
    beq  a3, t6, t247_ok
    j    fail
t247_ok:
t248: # mulhu 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 248
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    mulhu a3, a1, a2
    li   t6, 0x7ffffffffffffffe
    beq  a3, t6, t248_ok
    j    fail
t248_ok:
t249: # mulhu 0x80000000, 0x0
    li   a0, 249
    li   a1, 0x80000000
    li   a2, 0x0
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t249_ok
    j    fail
t249_ok:
t250: # mulhu 0x80000000, 0x80000000
    li   a0, 250
    li   a1, 0x80000000
    li   a2, 0x80000000
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t250_ok
    j    fail
t250_ok:
t251: # mulhu 0x7fffffff, 0x1
    li   a0, 251
    li   a1, 0x7fffffff
    li   a2, 0x1
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t251_ok
    j    fail
t251_ok:
t252: # mulhu 0x7fffffff, 0x7fffffff
    li   a0, 252
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t252_ok
    j    fail
t252_ok:
t253: # mulhu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 253
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    mulhu a3, a1, a2
    li   t6, 0xffffffff7fffffff
    beq  a3, t6, t253_ok
    j    fail
t253_ok:
t254: # mulhu 0x123456789abcdef0, 0x0
    li   a0, 254
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t254_ok
    j    fail
t254_ok:
t255: # mulhu 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 255
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    mulhu a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f77
    beq  a3, t6, t255_ok
    j    fail
t255_ok:
t256: # mulhu 0xfedcba9876543210, 0x1
    li   a0, 256
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t256_ok
    j    fail
t256_ok:
t257: # mulhu 0x3f, 0x0
    li   a0, 257
    li   a1, 0x3f
    li   a2, 0x0
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t257_ok
    j    fail
t257_ok:
t258: # mulhu 0x3f, 0x8000000000000000
    li   a0, 258
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    mulhu a3, a1, a2
    li   t6, 0x1f
    beq  a3, t6, t258_ok
    j    fail
t258_ok:
t259: # mulhu 0x40, 0x1
    li   a0, 259
    li   a1, 0x40
    li   a2, 0x1
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t259_ok
    j    fail
t259_ok:
t260: # mulhu 0x40, 0x40
    li   a0, 260
    li   a1, 0x40
    li   a2, 0x40
    mulhu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t260_ok
    j    fail
t260_ok:
t261: # mulhu 0x21, 0xffffffffffffffff
    li   a0, 261
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    mulhu a3, a1, a2
    li   t6, 0x20
    beq  a3, t6, t261_ok
    j    fail
t261_ok:
t262: # div 0x0, 0x0
    li   a0, 262
    li   a1, 0x0
    li   a2, 0x0
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t262_ok
    j    fail
t262_ok:
t263: # div 0x0, 0xfedcba9876543210
    li   a0, 263
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    div a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t263_ok
    j    fail
t263_ok:
t264: # div 0x1, 0xffffffffffffffff
    li   a0, 264
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t264_ok
    j    fail
t264_ok:
t265: # div 0xffffffffffffffff, 0x1
    li   a0, 265
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t265_ok
    j    fail
t265_ok:
t266: # div 0x7, 0x0
    li   a0, 266
    li   a1, 0x7
    li   a2, 0x0
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t266_ok
    j    fail
t266_ok:
t267: # div 0x7, 0x7
    li   a0, 267
    li   a1, 0x7
    li   a2, 0x7
    div a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t267_ok
    j    fail
t267_ok:
t268: # div 0xfffffffffffffff9, 0x1
    li   a0, 268
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    div a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t268_ok
    j    fail
t268_ok:
t269: # div 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 269
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    div a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t269_ok
    j    fail
t269_ok:
t270: # div 0x8000000000000000, 0xffffffffffffffff
    li   a0, 270
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    div a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t270_ok
    j    fail
t270_ok:
t271: # div 0x8000000000000000, 0x21
    li   a0, 271
    li   a1, 0x8000000000000000
    li   a2, 0x21
    div a3, a1, a2
    li   t6, 0xfc1f07c1f07c1f08
    beq  a3, t6, t271_ok
    j    fail
t271_ok:
t272: # div 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 272
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    div a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t272_ok
    j    fail
t272_ok:
t273: # div 0x80000000, 0x0
    li   a0, 273
    li   a1, 0x80000000
    li   a2, 0x0
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t273_ok
    j    fail
t273_ok:
t274: # div 0x80000000, 0x80000000
    li   a0, 274
    li   a1, 0x80000000
    li   a2, 0x80000000
    div a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t274_ok
    j    fail
t274_ok:
t275: # div 0x7fffffff, 0x1
    li   a0, 275
    li   a1, 0x7fffffff
    li   a2, 0x1
    div a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t275_ok
    j    fail
t275_ok:
t276: # div 0x7fffffff, 0x7fffffff
    li   a0, 276
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    div a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t276_ok
    j    fail
t276_ok:
t277: # div 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 277
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    div a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t277_ok
    j    fail
t277_ok:
t278: # div 0x123456789abcdef0, 0x0
    li   a0, 278
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t278_ok
    j    fail
t278_ok:
t279: # div 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 279
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    div a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t279_ok
    j    fail
t279_ok:
t280: # div 0xfedcba9876543210, 0x1
    li   a0, 280
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    div a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t280_ok
    j    fail
t280_ok:
t281: # div 0x3f, 0x0
    li   a0, 281
    li   a1, 0x3f
    li   a2, 0x0
    div a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t281_ok
    j    fail
t281_ok:
t282: # div 0x3f, 0x8000000000000000
    li   a0, 282
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    div a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t282_ok
    j    fail
t282_ok:
t283: # div 0x40, 0x1
    li   a0, 283
    li   a1, 0x40
    li   a2, 0x1
    div a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t283_ok
    j    fail
t283_ok:
t284: # div 0x40, 0x40
    li   a0, 284
    li   a1, 0x40
    li   a2, 0x40
    div a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t284_ok
    j    fail
t284_ok:
t285: # div 0x21, 0xffffffffffffffff
    li   a0, 285
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    div a3, a1, a2
    li   t6, 0xffffffffffffffdf
    beq  a3, t6, t285_ok
    j    fail
t285_ok:
t286: # divu 0x0, 0x0
    li   a0, 286
    li   a1, 0x0
    li   a2, 0x0
    divu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t286_ok
    j    fail
t286_ok:
t287: # divu 0x0, 0xfedcba9876543210
    li   a0, 287
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t287_ok
    j    fail
t287_ok:
t288: # divu 0x1, 0xffffffffffffffff
    li   a0, 288
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t288_ok
    j    fail
t288_ok:
t289: # divu 0xffffffffffffffff, 0x1
    li   a0, 289
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    divu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t289_ok
    j    fail
t289_ok:
t290: # divu 0x7, 0x0
    li   a0, 290
    li   a1, 0x7
    li   a2, 0x0
    divu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t290_ok
    j    fail
t290_ok:
t291: # divu 0x7, 0x7
    li   a0, 291
    li   a1, 0x7
    li   a2, 0x7
    divu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t291_ok
    j    fail
t291_ok:
t292: # divu 0xfffffffffffffff9, 0x1
    li   a0, 292
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    divu a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t292_ok
    j    fail
t292_ok:
t293: # divu 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 293
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    divu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t293_ok
    j    fail
t293_ok:
t294: # divu 0x8000000000000000, 0xffffffffffffffff
    li   a0, 294
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t294_ok
    j    fail
t294_ok:
t295: # divu 0x8000000000000000, 0x21
    li   a0, 295
    li   a1, 0x8000000000000000
    li   a2, 0x21
    divu a3, a1, a2
    li   t6, 0x3e0f83e0f83e0f8
    beq  a3, t6, t295_ok
    j    fail
t295_ok:
t296: # divu 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 296
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t296_ok
    j    fail
t296_ok:
t297: # divu 0x80000000, 0x0
    li   a0, 297
    li   a1, 0x80000000
    li   a2, 0x0
    divu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t297_ok
    j    fail
t297_ok:
t298: # divu 0x80000000, 0x80000000
    li   a0, 298
    li   a1, 0x80000000
    li   a2, 0x80000000
    divu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t298_ok
    j    fail
t298_ok:
t299: # divu 0x7fffffff, 0x1
    li   a0, 299
    li   a1, 0x7fffffff
    li   a2, 0x1
    divu a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t299_ok
    j    fail
t299_ok:
t300: # divu 0x7fffffff, 0x7fffffff
    li   a0, 300
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    divu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t300_ok
    j    fail
t300_ok:
t301: # divu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 301
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t301_ok
    j    fail
t301_ok:
t302: # divu 0x123456789abcdef0, 0x0
    li   a0, 302
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    divu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t302_ok
    j    fail
t302_ok:
t303: # divu 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 303
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t303_ok
    j    fail
t303_ok:
t304: # divu 0xfedcba9876543210, 0x1
    li   a0, 304
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    divu a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t304_ok
    j    fail
t304_ok:
t305: # divu 0x3f, 0x0
    li   a0, 305
    li   a1, 0x3f
    li   a2, 0x0
    divu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t305_ok
    j    fail
t305_ok:
t306: # divu 0x3f, 0x8000000000000000
    li   a0, 306
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t306_ok
    j    fail
t306_ok:
t307: # divu 0x40, 0x1
    li   a0, 307
    li   a1, 0x40
    li   a2, 0x1
    divu a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t307_ok
    j    fail
t307_ok:
t308: # divu 0x40, 0x40
    li   a0, 308
    li   a1, 0x40
    li   a2, 0x40
    divu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t308_ok
    j    fail
t308_ok:
t309: # divu 0x21, 0xffffffffffffffff
    li   a0, 309
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    divu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t309_ok
    j    fail
t309_ok:
t310: # rem 0x0, 0x0
    li   a0, 310
    li   a1, 0x0
    li   a2, 0x0
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t310_ok
    j    fail
t310_ok:
t311: # rem 0x0, 0xfedcba9876543210
    li   a0, 311
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t311_ok
    j    fail
t311_ok:
t312: # rem 0x1, 0xffffffffffffffff
    li   a0, 312
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t312_ok
    j    fail
t312_ok:
t313: # rem 0xffffffffffffffff, 0x1
    li   a0, 313
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t313_ok
    j    fail
t313_ok:
t314: # rem 0x7, 0x0
    li   a0, 314
    li   a1, 0x7
    li   a2, 0x0
    rem a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t314_ok
    j    fail
t314_ok:
t315: # rem 0x7, 0x7
    li   a0, 315
    li   a1, 0x7
    li   a2, 0x7
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t315_ok
    j    fail
t315_ok:
t316: # rem 0xfffffffffffffff9, 0x1
    li   a0, 316
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t316_ok
    j    fail
t316_ok:
t317: # rem 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 317
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    rem a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t317_ok
    j    fail
t317_ok:
t318: # rem 0x8000000000000000, 0xffffffffffffffff
    li   a0, 318
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t318_ok
    j    fail
t318_ok:
t319: # rem 0x8000000000000000, 0x21
    li   a0, 319
    li   a1, 0x8000000000000000
    li   a2, 0x21
    rem a3, a1, a2
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t319_ok
    j    fail
t319_ok:
t320: # rem 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 320
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t320_ok
    j    fail
t320_ok:
t321: # rem 0x80000000, 0x0
    li   a0, 321
    li   a1, 0x80000000
    li   a2, 0x0
    rem a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t321_ok
    j    fail
t321_ok:
t322: # rem 0x80000000, 0x80000000
    li   a0, 322
    li   a1, 0x80000000
    li   a2, 0x80000000
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t322_ok
    j    fail
t322_ok:
t323: # rem 0x7fffffff, 0x1
    li   a0, 323
    li   a1, 0x7fffffff
    li   a2, 0x1
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t323_ok
    j    fail
t323_ok:
t324: # rem 0x7fffffff, 0x7fffffff
    li   a0, 324
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t324_ok
    j    fail
t324_ok:
t325: # rem 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 325
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t325_ok
    j    fail
t325_ok:
t326: # rem 0x123456789abcdef0, 0x0
    li   a0, 326
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    rem a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t326_ok
    j    fail
t326_ok:
t327: # rem 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 327
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    rem a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t327_ok
    j    fail
t327_ok:
t328: # rem 0xfedcba9876543210, 0x1
    li   a0, 328
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t328_ok
    j    fail
t328_ok:
t329: # rem 0x3f, 0x0
    li   a0, 329
    li   a1, 0x3f
    li   a2, 0x0
    rem a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t329_ok
    j    fail
t329_ok:
t330: # rem 0x3f, 0x8000000000000000
    li   a0, 330
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    rem a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t330_ok
    j    fail
t330_ok:
t331: # rem 0x40, 0x1
    li   a0, 331
    li   a1, 0x40
    li   a2, 0x1
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t331_ok
    j    fail
t331_ok:
t332: # rem 0x40, 0x40
    li   a0, 332
    li   a1, 0x40
    li   a2, 0x40
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t332_ok
    j    fail
t332_ok:
t333: # rem 0x21, 0xffffffffffffffff
    li   a0, 333
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    rem a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t333_ok
    j    fail
t333_ok:
t334: # remu 0x0, 0x0
    li   a0, 334
    li   a1, 0x0
    li   a2, 0x0
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t334_ok
    j    fail
t334_ok:
t335: # remu 0x0, 0xfedcba9876543210
    li   a0, 335
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t335_ok
    j    fail
t335_ok:
t336: # remu 0x1, 0xffffffffffffffff
    li   a0, 336
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    remu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t336_ok
    j    fail
t336_ok:
t337: # remu 0xffffffffffffffff, 0x1
    li   a0, 337
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t337_ok
    j    fail
t337_ok:
t338: # remu 0x7, 0x0
    li   a0, 338
    li   a1, 0x7
    li   a2, 0x0
    remu a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t338_ok
    j    fail
t338_ok:
t339: # remu 0x7, 0x7
    li   a0, 339
    li   a1, 0x7
    li   a2, 0x7
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t339_ok
    j    fail
t339_ok:
t340: # remu 0xfffffffffffffff9, 0x1
    li   a0, 340
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t340_ok
    j    fail
t340_ok:
t341: # remu 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 341
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    remu a3, a1, a2
    li   t6, 0x7ffffff9
    beq  a3, t6, t341_ok
    j    fail
t341_ok:
t342: # remu 0x8000000000000000, 0xffffffffffffffff
    li   a0, 342
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    remu a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t342_ok
    j    fail
t342_ok:
t343: # remu 0x8000000000000000, 0x21
    li   a0, 343
    li   a1, 0x8000000000000000
    li   a2, 0x21
    remu a3, a1, a2
    li   t6, 0x8
    beq  a3, t6, t343_ok
    j    fail
t343_ok:
t344: # remu 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 344
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    remu a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t344_ok
    j    fail
t344_ok:
t345: # remu 0x80000000, 0x0
    li   a0, 345
    li   a1, 0x80000000
    li   a2, 0x0
    remu a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t345_ok
    j    fail
t345_ok:
t346: # remu 0x80000000, 0x80000000
    li   a0, 346
    li   a1, 0x80000000
    li   a2, 0x80000000
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t346_ok
    j    fail
t346_ok:
t347: # remu 0x7fffffff, 0x1
    li   a0, 347
    li   a1, 0x7fffffff
    li   a2, 0x1
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t347_ok
    j    fail
t347_ok:
t348: # remu 0x7fffffff, 0x7fffffff
    li   a0, 348
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t348_ok
    j    fail
t348_ok:
t349: # remu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 349
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    remu a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t349_ok
    j    fail
t349_ok:
t350: # remu 0x123456789abcdef0, 0x0
    li   a0, 350
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    remu a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t350_ok
    j    fail
t350_ok:
t351: # remu 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 351
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    remu a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t351_ok
    j    fail
t351_ok:
t352: # remu 0xfedcba9876543210, 0x1
    li   a0, 352
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t352_ok
    j    fail
t352_ok:
t353: # remu 0x3f, 0x0
    li   a0, 353
    li   a1, 0x3f
    li   a2, 0x0
    remu a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t353_ok
    j    fail
t353_ok:
t354: # remu 0x3f, 0x8000000000000000
    li   a0, 354
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    remu a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t354_ok
    j    fail
t354_ok:
t355: # remu 0x40, 0x1
    li   a0, 355
    li   a1, 0x40
    li   a2, 0x1
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t355_ok
    j    fail
t355_ok:
t356: # remu 0x40, 0x40
    li   a0, 356
    li   a1, 0x40
    li   a2, 0x40
    remu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t356_ok
    j    fail
t356_ok:
t357: # remu 0x21, 0xffffffffffffffff
    li   a0, 357
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    remu a3, a1, a2
    li   t6, 0x21
    beq  a3, t6, t357_ok
    j    fail
t357_ok:
t358: # mulw 0x0, 0x0
    li   a0, 358
    li   a1, 0x0
    li   a2, 0x0
    mulw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t358_ok
    j    fail
t358_ok:
t359: # mulw 0x1, 0x8000000000000000
    li   a0, 359
    li   a1, 0x1
    li   a2, 0x8000000000000000
    mulw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t359_ok
    j    fail
t359_ok:
t360: # mulw 0x7, 0xffffffffffffffff
    li   a0, 360
    li   a1, 0x7
    li   a2, 0xffffffffffffffff
    mulw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t360_ok
    j    fail
t360_ok:
t361: # mulw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 361
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    mulw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t361_ok
    j    fail
t361_ok:
t362: # mulw 0x7fffffffffffffff, 0x0
    li   a0, 362
    li   a1, 0x7fffffffffffffff
    li   a2, 0x0
    mulw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t362_ok
    j    fail
t362_ok:
t363: # mulw 0x80000000, 0xffffffffffffffff
    li   a0, 363
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    mulw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t363_ok
    j    fail
t363_ok:
t364: # mulw 0x7fffffff, 0x7fffffff
    li   a0, 364
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    mulw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t364_ok
    j    fail
t364_ok:
t365: # mulw 0x123456789abcdef0, 0x1
    li   a0, 365
    li   a1, 0x123456789abcdef0
    li   a2, 0x1
    mulw a3, a1, a2
    li   t6, 0xffffffff9abcdef0
    beq  a3, t6, t365_ok
    j    fail
t365_ok:
t366: # mulw 0xfedcba9876543210, 0xfedcba9876543210
    li   a0, 366
    li   a1, 0xfedcba9876543210
    li   a2, 0xfedcba9876543210
    mulw a3, a1, a2
    li   t6, 0xffffffffa44a4100
    beq  a3, t6, t366_ok
    j    fail
t366_ok:
t367: # mulw 0x40, 0x1
    li   a0, 367
    li   a1, 0x40
    li   a2, 0x1
    mulw a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t367_ok
    j    fail
t367_ok:
t368: # mulw 0x21, 0xfffffffffffffff9
    li   a0, 368
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    mulw a3, a1, a2
    li   t6, 0xffffffffffffff19
    beq  a3, t6, t368_ok
    j    fail
t368_ok:
t369: # divw 0x0, 0x0
    li   a0, 369
    li   a1, 0x0
    li   a2, 0x0
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t369_ok
    j    fail
t369_ok:
t370: # divw 0x0, 0xfedcba9876543210
    li   a0, 370
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    divw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t370_ok
    j    fail
t370_ok:
t371: # divw 0x1, 0xffffffffffffffff
    li   a0, 371
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t371_ok
    j    fail
t371_ok:
t372: # divw 0xffffffffffffffff, 0x1
    li   a0, 372
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t372_ok
    j    fail
t372_ok:
t373: # divw 0x7, 0x0
    li   a0, 373
    li   a1, 0x7
    li   a2, 0x0
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t373_ok
    j    fail
t373_ok:
t374: # divw 0x7, 0x7
    li   a0, 374
    li   a1, 0x7
    li   a2, 0x7
    divw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t374_ok
    j    fail
t374_ok:
t375: # divw 0xfffffffffffffff9, 0x1
    li   a0, 375
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    divw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t375_ok
    j    fail
t375_ok:
t376: # divw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 376
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    divw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t376_ok
    j    fail
t376_ok:
t377: # divw 0x8000000000000000, 0xffffffffffffffff
    li   a0, 377
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    divw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t377_ok
    j    fail
t377_ok:
t378: # divw 0x8000000000000000, 0x21
    li   a0, 378
    li   a1, 0x8000000000000000
    li   a2, 0x21
    divw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t378_ok
    j    fail
t378_ok:
t379: # divw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 379
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    divw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t379_ok
    j    fail
t379_ok:
t380: # divw 0x80000000, 0x0
    li   a0, 380
    li   a1, 0x80000000
    li   a2, 0x0
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t380_ok
    j    fail
t380_ok:
t381: # divw 0x80000000, 0x80000000
    li   a0, 381
    li   a1, 0x80000000
    li   a2, 0x80000000
    divw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t381_ok
    j    fail
t381_ok:
t382: # divw 0x7fffffff, 0x1
    li   a0, 382
    li   a1, 0x7fffffff
    li   a2, 0x1
    divw a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t382_ok
    j    fail
t382_ok:
t383: # divw 0x7fffffff, 0x7fffffff
    li   a0, 383
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    divw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t383_ok
    j    fail
t383_ok:
t384: # divw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 384
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    divw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t384_ok
    j    fail
t384_ok:
t385: # divw 0x123456789abcdef0, 0x0
    li   a0, 385
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t385_ok
    j    fail
t385_ok:
t386: # divw 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 386
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    divw a3, a1, a2
    li   t6, 0x65432110
    beq  a3, t6, t386_ok
    j    fail
t386_ok:
t387: # divw 0xfedcba9876543210, 0x1
    li   a0, 387
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    divw a3, a1, a2
    li   t6, 0x76543210
    beq  a3, t6, t387_ok
    j    fail
t387_ok:
t388: # divw 0x3f, 0x0
    li   a0, 388
    li   a1, 0x3f
    li   a2, 0x0
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t388_ok
    j    fail
t388_ok:
t389: # divw 0x3f, 0x8000000000000000
    li   a0, 389
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    divw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t389_ok
    j    fail
t389_ok:
t390: # divw 0x40, 0x1
    li   a0, 390
    li   a1, 0x40
    li   a2, 0x1
    divw a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t390_ok
    j    fail
t390_ok:
t391: # divw 0x40, 0x40
    li   a0, 391
    li   a1, 0x40
    li   a2, 0x40
    divw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t391_ok
    j    fail
t391_ok:
t392: # divw 0x21, 0xffffffffffffffff
    li   a0, 392
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    divw a3, a1, a2
    li   t6, 0xffffffffffffffdf
    beq  a3, t6, t392_ok
    j    fail
t392_ok:
t393: # divuw 0x0, 0x0
    li   a0, 393
    li   a1, 0x0
    li   a2, 0x0
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t393_ok
    j    fail
t393_ok:
t394: # divuw 0x0, 0xfedcba9876543210
    li   a0, 394
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t394_ok
    j    fail
t394_ok:
t395: # divuw 0x1, 0xffffffffffffffff
    li   a0, 395
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t395_ok
    j    fail
t395_ok:
t396: # divuw 0xffffffffffffffff, 0x1
    li   a0, 396
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t396_ok
    j    fail
t396_ok:
t397: # divuw 0x7, 0x0
    li   a0, 397
    li   a1, 0x7
    li   a2, 0x0
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t397_ok
    j    fail
t397_ok:
t398: # divuw 0x7, 0x7
    li   a0, 398
    li   a1, 0x7
    li   a2, 0x7
    divuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t398_ok
    j    fail
t398_ok:
t399: # divuw 0xfffffffffffffff9, 0x1
    li   a0, 399
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    divuw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t399_ok
    j    fail
t399_ok:
t400: # divuw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 400
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    divuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t400_ok
    j    fail
t400_ok:
t401: # divuw 0x8000000000000000, 0xffffffffffffffff
    li   a0, 401
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t401_ok
    j    fail
t401_ok:
t402: # divuw 0x8000000000000000, 0x21
    li   a0, 402
    li   a1, 0x8000000000000000
    li   a2, 0x21
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t402_ok
    j    fail
t402_ok:
t403: # divuw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 403
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    divuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t403_ok
    j    fail
t403_ok:
t404: # divuw 0x80000000, 0x0
    li   a0, 404
    li   a1, 0x80000000
    li   a2, 0x0
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t404_ok
    j    fail
t404_ok:
t405: # divuw 0x80000000, 0x80000000
    li   a0, 405
    li   a1, 0x80000000
    li   a2, 0x80000000
    divuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t405_ok
    j    fail
t405_ok:
t406: # divuw 0x7fffffff, 0x1
    li   a0, 406
    li   a1, 0x7fffffff
    li   a2, 0x1
    divuw a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t406_ok
    j    fail
t406_ok:
t407: # divuw 0x7fffffff, 0x7fffffff
    li   a0, 407
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    divuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t407_ok
    j    fail
t407_ok:
t408: # divuw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 408
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t408_ok
    j    fail
t408_ok:
t409: # divuw 0x123456789abcdef0, 0x0
    li   a0, 409
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t409_ok
    j    fail
t409_ok:
t410: # divuw 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 410
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t410_ok
    j    fail
t410_ok:
t411: # divuw 0xfedcba9876543210, 0x1
    li   a0, 411
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    divuw a3, a1, a2
    li   t6, 0x76543210
    beq  a3, t6, t411_ok
    j    fail
t411_ok:
t412: # divuw 0x3f, 0x0
    li   a0, 412
    li   a1, 0x3f
    li   a2, 0x0
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t412_ok
    j    fail
t412_ok:
t413: # divuw 0x3f, 0x8000000000000000
    li   a0, 413
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    divuw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t413_ok
    j    fail
t413_ok:
t414: # divuw 0x40, 0x1
    li   a0, 414
    li   a1, 0x40
    li   a2, 0x1
    divuw a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t414_ok
    j    fail
t414_ok:
t415: # divuw 0x40, 0x40
    li   a0, 415
    li   a1, 0x40
    li   a2, 0x40
    divuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t415_ok
    j    fail
t415_ok:
t416: # divuw 0x21, 0xffffffffffffffff
    li   a0, 416
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    divuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t416_ok
    j    fail
t416_ok:
t417: # remw 0x0, 0x0
    li   a0, 417
    li   a1, 0x0
    li   a2, 0x0
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t417_ok
    j    fail
t417_ok:
t418: # remw 0x0, 0xfedcba9876543210
    li   a0, 418
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t418_ok
    j    fail
t418_ok:
t419: # remw 0x1, 0xffffffffffffffff
    li   a0, 419
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t419_ok
    j    fail
t419_ok:
t420: # remw 0xffffffffffffffff, 0x1
    li   a0, 420
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t420_ok
    j    fail
t420_ok:
t421: # remw 0x7, 0x0
    li   a0, 421
    li   a1, 0x7
    li   a2, 0x0
    remw a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t421_ok
    j    fail
t421_ok:
t422: # remw 0x7, 0x7
    li   a0, 422
    li   a1, 0x7
    li   a2, 0x7
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t422_ok
    j    fail
t422_ok:
t423: # remw 0xfffffffffffffff9, 0x1
    li   a0, 423
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t423_ok
    j    fail
t423_ok:
t424: # remw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 424
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    remw a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t424_ok
    j    fail
t424_ok:
t425: # remw 0x8000000000000000, 0xffffffffffffffff
    li   a0, 425
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t425_ok
    j    fail
t425_ok:
t426: # remw 0x8000000000000000, 0x21
    li   a0, 426
    li   a1, 0x8000000000000000
    li   a2, 0x21
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t426_ok
    j    fail
t426_ok:
t427: # remw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 427
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t427_ok
    j    fail
t427_ok:
t428: # remw 0x80000000, 0x0
    li   a0, 428
    li   a1, 0x80000000
    li   a2, 0x0
    remw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t428_ok
    j    fail
t428_ok:
t429: # remw 0x80000000, 0x80000000
    li   a0, 429
    li   a1, 0x80000000
    li   a2, 0x80000000
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t429_ok
    j    fail
t429_ok:
t430: # remw 0x7fffffff, 0x1
    li   a0, 430
    li   a1, 0x7fffffff
    li   a2, 0x1
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t430_ok
    j    fail
t430_ok:
t431: # remw 0x7fffffff, 0x7fffffff
    li   a0, 431
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t431_ok
    j    fail
t431_ok:
t432: # remw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 432
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t432_ok
    j    fail
t432_ok:
t433: # remw 0x123456789abcdef0, 0x0
    li   a0, 433
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    remw a3, a1, a2
    li   t6, 0xffffffff9abcdef0
    beq  a3, t6, t433_ok
    j    fail
t433_ok:
t434: # remw 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 434
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t434_ok
    j    fail
t434_ok:
t435: # remw 0xfedcba9876543210, 0x1
    li   a0, 435
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t435_ok
    j    fail
t435_ok:
t436: # remw 0x3f, 0x0
    li   a0, 436
    li   a1, 0x3f
    li   a2, 0x0
    remw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t436_ok
    j    fail
t436_ok:
t437: # remw 0x3f, 0x8000000000000000
    li   a0, 437
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    remw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t437_ok
    j    fail
t437_ok:
t438: # remw 0x40, 0x1
    li   a0, 438
    li   a1, 0x40
    li   a2, 0x1
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t438_ok
    j    fail
t438_ok:
t439: # remw 0x40, 0x40
    li   a0, 439
    li   a1, 0x40
    li   a2, 0x40
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t439_ok
    j    fail
t439_ok:
t440: # remw 0x21, 0xffffffffffffffff
    li   a0, 440
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    remw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t440_ok
    j    fail
t440_ok:
t441: # remuw 0x0, 0x0
    li   a0, 441
    li   a1, 0x0
    li   a2, 0x0
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t441_ok
    j    fail
t441_ok:
t442: # remuw 0x0, 0xfedcba9876543210
    li   a0, 442
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t442_ok
    j    fail
t442_ok:
t443: # remuw 0x1, 0xffffffffffffffff
    li   a0, 443
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    remuw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t443_ok
    j    fail
t443_ok:
t444: # remuw 0xffffffffffffffff, 0x1
    li   a0, 444
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t444_ok
    j    fail
t444_ok:
t445: # remuw 0x7, 0x0
    li   a0, 445
    li   a1, 0x7
    li   a2, 0x0
    remuw a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t445_ok
    j    fail
t445_ok:
t446: # remuw 0x7, 0x7
    li   a0, 446
    li   a1, 0x7
    li   a2, 0x7
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t446_ok
    j    fail
t446_ok:
t447: # remuw 0xfffffffffffffff9, 0x1
    li   a0, 447
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t447_ok
    j    fail
t447_ok:
t448: # remuw 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 448
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    remuw a3, a1, a2
    li   t6, 0x7ffffff9
    beq  a3, t6, t448_ok
    j    fail
t448_ok:
t449: # remuw 0x8000000000000000, 0xffffffffffffffff
    li   a0, 449
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t449_ok
    j    fail
t449_ok:
t450: # remuw 0x8000000000000000, 0x21
    li   a0, 450
    li   a1, 0x8000000000000000
    li   a2, 0x21
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t450_ok
    j    fail
t450_ok:
t451: # remuw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 451
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t451_ok
    j    fail
t451_ok:
t452: # remuw 0x80000000, 0x0
    li   a0, 452
    li   a1, 0x80000000
    li   a2, 0x0
    remuw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t452_ok
    j    fail
t452_ok:
t453: # remuw 0x80000000, 0x80000000
    li   a0, 453
    li   a1, 0x80000000
    li   a2, 0x80000000
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t453_ok
    j    fail
t453_ok:
t454: # remuw 0x7fffffff, 0x1
    li   a0, 454
    li   a1, 0x7fffffff
    li   a2, 0x1
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t454_ok
    j    fail
t454_ok:
t455: # remuw 0x7fffffff, 0x7fffffff
    li   a0, 455
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t455_ok
    j    fail
t455_ok:
t456: # remuw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 456
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    remuw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t456_ok
    j    fail
t456_ok:
t457: # remuw 0x123456789abcdef0, 0x0
    li   a0, 457
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    remuw a3, a1, a2
    li   t6, 0xffffffff9abcdef0
    beq  a3, t6, t457_ok
    j    fail
t457_ok:
t458: # remuw 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 458
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    remuw a3, a1, a2
    li   t6, 0xffffffff9abcdef0
    beq  a3, t6, t458_ok
    j    fail
t458_ok:
t459: # remuw 0xfedcba9876543210, 0x1
    li   a0, 459
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t459_ok
    j    fail
t459_ok:
t460: # remuw 0x3f, 0x0
    li   a0, 460
    li   a1, 0x3f
    li   a2, 0x0
    remuw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t460_ok
    j    fail
t460_ok:
t461: # remuw 0x3f, 0x8000000000000000
    li   a0, 461
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    remuw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t461_ok
    j    fail
t461_ok:
t462: # remuw 0x40, 0x1
    li   a0, 462
    li   a1, 0x40
    li   a2, 0x1
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t462_ok
    j    fail
t462_ok:
t463: # remuw 0x40, 0x40
    li   a0, 463
    li   a1, 0x40
    li   a2, 0x40
    remuw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t463_ok
    j    fail
t463_ok:
t464: # remuw 0x21, 0xffffffffffffffff
    li   a0, 464
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    remuw a3, a1, a2
    li   t6, 0x21
    beq  a3, t6, t464_ok
    j    fail
t464_ok:
t465: # addi 0x0, 0
    li   a0, 465
    li   a1, 0x0
    addi a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t465_ok
    j    fail
t465_ok:
t466: # addi 0x0, 1
    li   a0, 466
    li   a1, 0x0
    addi a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t466_ok
    j    fail
t466_ok:
t467: # addi 0x0, -1
    li   a0, 467
    li   a1, 0x0
    addi a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t467_ok
    j    fail
t467_ok:
t468: # addi 0x0, 2047
    li   a0, 468
    li   a1, 0x0
    addi a3, a1, 2047
    li   t6, 0x7ff
    beq  a3, t6, t468_ok
    j    fail
t468_ok:
t469: # addi 0x0, -2048
    li   a0, 469
    li   a1, 0x0
    addi a3, a1, -2048
    li   t6, 0xfffffffffffff800
    beq  a3, t6, t469_ok
    j    fail
t469_ok:
t470: # addi 0x0, 1365
    li   a0, 470
    li   a1, 0x0
    addi a3, a1, 1365
    li   t6, 0x555
    beq  a3, t6, t470_ok
    j    fail
t470_ok:
t471: # addi 0x0, -2045
    li   a0, 471
    li   a1, 0x0
    addi a3, a1, -2045
    li   t6, 0xfffffffffffff803
    beq  a3, t6, t471_ok
    j    fail
t471_ok:
t472: # addi 0xfffffffffffffff9, 0
    li   a0, 472
    li   a1, 0xfffffffffffffff9
    addi a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t472_ok
    j    fail
t472_ok:
t473: # addi 0xfffffffffffffff9, 1
    li   a0, 473
    li   a1, 0xfffffffffffffff9
    addi a3, a1, 1
    li   t6, 0xfffffffffffffffa
    beq  a3, t6, t473_ok
    j    fail
t473_ok:
t474: # addi 0xfffffffffffffff9, -1
    li   a0, 474
    li   a1, 0xfffffffffffffff9
    addi a3, a1, -1
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t474_ok
    j    fail
t474_ok:
t475: # addi 0xfffffffffffffff9, 2047
    li   a0, 475
    li   a1, 0xfffffffffffffff9
    addi a3, a1, 2047
    li   t6, 0x7f8
    beq  a3, t6, t475_ok
    j    fail
t475_ok:
t476: # addi 0xfffffffffffffff9, -2048
    li   a0, 476
    li   a1, 0xfffffffffffffff9
    addi a3, a1, -2048
    li   t6, 0xfffffffffffff7f9
    beq  a3, t6, t476_ok
    j    fail
t476_ok:
t477: # addi 0xfffffffffffffff9, 1365
    li   a0, 477
    li   a1, 0xfffffffffffffff9
    addi a3, a1, 1365
    li   t6, 0x54e
    beq  a3, t6, t477_ok
    j    fail
t477_ok:
t478: # addi 0xfffffffffffffff9, -2045
    li   a0, 478
    li   a1, 0xfffffffffffffff9
    addi a3, a1, -2045
    li   t6, 0xfffffffffffff7fc
    beq  a3, t6, t478_ok
    j    fail
t478_ok:
t479: # addi 0x7fffffff, 0
    li   a0, 479
    li   a1, 0x7fffffff
    addi a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t479_ok
    j    fail
t479_ok:
t480: # addi 0x7fffffff, 1
    li   a0, 480
    li   a1, 0x7fffffff
    addi a3, a1, 1
    li   t6, 0x80000000
    beq  a3, t6, t480_ok
    j    fail
t480_ok:
t481: # addi 0x7fffffff, -1
    li   a0, 481
    li   a1, 0x7fffffff
    addi a3, a1, -1
    li   t6, 0x7ffffffe
    beq  a3, t6, t481_ok
    j    fail
t481_ok:
t482: # addi 0x7fffffff, 2047
    li   a0, 482
    li   a1, 0x7fffffff
    addi a3, a1, 2047
    li   t6, 0x800007fe
    beq  a3, t6, t482_ok
    j    fail
t482_ok:
t483: # addi 0x7fffffff, -2048
    li   a0, 483
    li   a1, 0x7fffffff
    addi a3, a1, -2048
    li   t6, 0x7ffff7ff
    beq  a3, t6, t483_ok
    j    fail
t483_ok:
t484: # addi 0x7fffffff, 1365
    li   a0, 484
    li   a1, 0x7fffffff
    addi a3, a1, 1365
    li   t6, 0x80000554
    beq  a3, t6, t484_ok
    j    fail
t484_ok:
t485: # addi 0x7fffffff, -2045
    li   a0, 485
    li   a1, 0x7fffffff
    addi a3, a1, -2045
    li   t6, 0x7ffff802
    beq  a3, t6, t485_ok
    j    fail
t485_ok:
t486: # addi 0x3f, 0
    li   a0, 486
    li   a1, 0x3f
    addi a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t486_ok
    j    fail
t486_ok:
t487: # addi 0x3f, 1
    li   a0, 487
    li   a1, 0x3f
    addi a3, a1, 1
    li   t6, 0x40
    beq  a3, t6, t487_ok
    j    fail
t487_ok:
t488: # addi 0x3f, -1
    li   a0, 488
    li   a1, 0x3f
    addi a3, a1, -1
    li   t6, 0x3e
    beq  a3, t6, t488_ok
    j    fail
t488_ok:
t489: # addi 0x3f, 2047
    li   a0, 489
    li   a1, 0x3f
    addi a3, a1, 2047
    li   t6, 0x83e
    beq  a3, t6, t489_ok
    j    fail
t489_ok:
t490: # addi 0x3f, -2048
    li   a0, 490
    li   a1, 0x3f
    addi a3, a1, -2048
    li   t6, 0xfffffffffffff83f
    beq  a3, t6, t490_ok
    j    fail
t490_ok:
t491: # addi 0x3f, 1365
    li   a0, 491
    li   a1, 0x3f
    addi a3, a1, 1365
    li   t6, 0x594
    beq  a3, t6, t491_ok
    j    fail
t491_ok:
t492: # addi 0x3f, -2045
    li   a0, 492
    li   a1, 0x3f
    addi a3, a1, -2045
    li   t6, 0xfffffffffffff842
    beq  a3, t6, t492_ok
    j    fail
t492_ok:
t493: # slti 0x0, 0
    li   a0, 493
    li   a1, 0x0
    slti a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t493_ok
    j    fail
t493_ok:
t494: # slti 0x0, 1
    li   a0, 494
    li   a1, 0x0
    slti a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t494_ok
    j    fail
t494_ok:
t495: # slti 0x0, -1
    li   a0, 495
    li   a1, 0x0
    slti a3, a1, -1
    li   t6, 0x0
    beq  a3, t6, t495_ok
    j    fail
t495_ok:
t496: # slti 0x0, 2047
    li   a0, 496
    li   a1, 0x0
    slti a3, a1, 2047
    li   t6, 0x1
    beq  a3, t6, t496_ok
    j    fail
t496_ok:
t497: # slti 0x0, -2048
    li   a0, 497
    li   a1, 0x0
    slti a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t497_ok
    j    fail
t497_ok:
t498: # slti 0x0, 1365
    li   a0, 498
    li   a1, 0x0
    slti a3, a1, 1365
    li   t6, 0x1
    beq  a3, t6, t498_ok
    j    fail
t498_ok:
t499: # slti 0x0, -2045
    li   a0, 499
    li   a1, 0x0
    slti a3, a1, -2045
    li   t6, 0x0
    beq  a3, t6, t499_ok
    j    fail
t499_ok:
t500: # slti 0xfffffffffffffff9, 0
    li   a0, 500
    li   a1, 0xfffffffffffffff9
    slti a3, a1, 0
    li   t6, 0x1
    beq  a3, t6, t500_ok
    j    fail
t500_ok:
t501: # slti 0xfffffffffffffff9, 1
    li   a0, 501
    li   a1, 0xfffffffffffffff9
    slti a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t501_ok
    j    fail
t501_ok:
t502: # slti 0xfffffffffffffff9, -1
    li   a0, 502
    li   a1, 0xfffffffffffffff9
    slti a3, a1, -1
    li   t6, 0x1
    beq  a3, t6, t502_ok
    j    fail
t502_ok:
t503: # slti 0xfffffffffffffff9, 2047
    li   a0, 503
    li   a1, 0xfffffffffffffff9
    slti a3, a1, 2047
    li   t6, 0x1
    beq  a3, t6, t503_ok
    j    fail
t503_ok:
t504: # slti 0xfffffffffffffff9, -2048
    li   a0, 504
    li   a1, 0xfffffffffffffff9
    slti a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t504_ok
    j    fail
t504_ok:
t505: # slti 0xfffffffffffffff9, 1365
    li   a0, 505
    li   a1, 0xfffffffffffffff9
    slti a3, a1, 1365
    li   t6, 0x1
    beq  a3, t6, t505_ok
    j    fail
t505_ok:
t506: # slti 0xfffffffffffffff9, -2045
    li   a0, 506
    li   a1, 0xfffffffffffffff9
    slti a3, a1, -2045
    li   t6, 0x0
    beq  a3, t6, t506_ok
    j    fail
t506_ok:
t507: # slti 0x7fffffff, 0
    li   a0, 507
    li   a1, 0x7fffffff
    slti a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t507_ok
    j    fail
t507_ok:
t508: # slti 0x7fffffff, 1
    li   a0, 508
    li   a1, 0x7fffffff
    slti a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t508_ok
    j    fail
t508_ok:
t509: # slti 0x7fffffff, -1
    li   a0, 509
    li   a1, 0x7fffffff
    slti a3, a1, -1
    li   t6, 0x0
    beq  a3, t6, t509_ok
    j    fail
t509_ok:
t510: # slti 0x7fffffff, 2047
    li   a0, 510
    li   a1, 0x7fffffff
    slti a3, a1, 2047
    li   t6, 0x0
    beq  a3, t6, t510_ok
    j    fail
t510_ok:
t511: # slti 0x7fffffff, -2048
    li   a0, 511
    li   a1, 0x7fffffff
    slti a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t511_ok
    j    fail
t511_ok:
t512: # slti 0x7fffffff, 1365
    li   a0, 512
    li   a1, 0x7fffffff
    slti a3, a1, 1365
    li   t6, 0x0
    beq  a3, t6, t512_ok
    j    fail
t512_ok:
t513: # slti 0x7fffffff, -2045
    li   a0, 513
    li   a1, 0x7fffffff
    slti a3, a1, -2045
    li   t6, 0x0
    beq  a3, t6, t513_ok
    j    fail
t513_ok:
t514: # slti 0x3f, 0
    li   a0, 514
    li   a1, 0x3f
    slti a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t514_ok
    j    fail
t514_ok:
t515: # slti 0x3f, 1
    li   a0, 515
    li   a1, 0x3f
    slti a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t515_ok
    j    fail
t515_ok:
t516: # slti 0x3f, -1
    li   a0, 516
    li   a1, 0x3f
    slti a3, a1, -1
    li   t6, 0x0
    beq  a3, t6, t516_ok
    j    fail
t516_ok:
t517: # slti 0x3f, 2047
    li   a0, 517
    li   a1, 0x3f
    slti a3, a1, 2047
    li   t6, 0x1
    beq  a3, t6, t517_ok
    j    fail
t517_ok:
t518: # slti 0x3f, -2048
    li   a0, 518
    li   a1, 0x3f
    slti a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t518_ok
    j    fail
t518_ok:
t519: # slti 0x3f, 1365
    li   a0, 519
    li   a1, 0x3f
    slti a3, a1, 1365
    li   t6, 0x1
    beq  a3, t6, t519_ok
    j    fail
t519_ok:
t520: # slti 0x3f, -2045
    li   a0, 520
    li   a1, 0x3f
    slti a3, a1, -2045
    li   t6, 0x0
    beq  a3, t6, t520_ok
    j    fail
t520_ok:
t521: # sltiu 0x0, 0
    li   a0, 521
    li   a1, 0x0
    sltiu a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t521_ok
    j    fail
t521_ok:
t522: # sltiu 0x0, 1
    li   a0, 522
    li   a1, 0x0
    sltiu a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t522_ok
    j    fail
t522_ok:
t523: # sltiu 0x0, -1
    li   a0, 523
    li   a1, 0x0
    sltiu a3, a1, -1
    li   t6, 0x1
    beq  a3, t6, t523_ok
    j    fail
t523_ok:
t524: # sltiu 0x0, 2047
    li   a0, 524
    li   a1, 0x0
    sltiu a3, a1, 2047
    li   t6, 0x1
    beq  a3, t6, t524_ok
    j    fail
t524_ok:
t525: # sltiu 0x0, -2048
    li   a0, 525
    li   a1, 0x0
    sltiu a3, a1, -2048
    li   t6, 0x1
    beq  a3, t6, t525_ok
    j    fail
t525_ok:
t526: # sltiu 0x0, 1365
    li   a0, 526
    li   a1, 0x0
    sltiu a3, a1, 1365
    li   t6, 0x1
    beq  a3, t6, t526_ok
    j    fail
t526_ok:
t527: # sltiu 0x0, -2045
    li   a0, 527
    li   a1, 0x0
    sltiu a3, a1, -2045
    li   t6, 0x1
    beq  a3, t6, t527_ok
    j    fail
t527_ok:
t528: # sltiu 0xfffffffffffffff9, 0
    li   a0, 528
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t528_ok
    j    fail
t528_ok:
t529: # sltiu 0xfffffffffffffff9, 1
    li   a0, 529
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t529_ok
    j    fail
t529_ok:
t530: # sltiu 0xfffffffffffffff9, -1
    li   a0, 530
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, -1
    li   t6, 0x1
    beq  a3, t6, t530_ok
    j    fail
t530_ok:
t531: # sltiu 0xfffffffffffffff9, 2047
    li   a0, 531
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, 2047
    li   t6, 0x0
    beq  a3, t6, t531_ok
    j    fail
t531_ok:
t532: # sltiu 0xfffffffffffffff9, -2048
    li   a0, 532
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t532_ok
    j    fail
t532_ok:
t533: # sltiu 0xfffffffffffffff9, 1365
    li   a0, 533
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, 1365
    li   t6, 0x0
    beq  a3, t6, t533_ok
    j    fail
t533_ok:
t534: # sltiu 0xfffffffffffffff9, -2045
    li   a0, 534
    li   a1, 0xfffffffffffffff9
    sltiu a3, a1, -2045
    li   t6, 0x0
    beq  a3, t6, t534_ok
    j    fail
t534_ok:
t535: # sltiu 0x7fffffff, 0
    li   a0, 535
    li   a1, 0x7fffffff
    sltiu a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t535_ok
    j    fail
t535_ok:
t536: # sltiu 0x7fffffff, 1
    li   a0, 536
    li   a1, 0x7fffffff
    sltiu a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t536_ok
    j    fail
t536_ok:
t537: # sltiu 0x7fffffff, -1
    li   a0, 537
    li   a1, 0x7fffffff
    sltiu a3, a1, -1
    li   t6, 0x1
    beq  a3, t6, t537_ok
    j    fail
t537_ok:
t538: # sltiu 0x7fffffff, 2047
    li   a0, 538
    li   a1, 0x7fffffff
    sltiu a3, a1, 2047
    li   t6, 0x0
    beq  a3, t6, t538_ok
    j    fail
t538_ok:
t539: # sltiu 0x7fffffff, -2048
    li   a0, 539
    li   a1, 0x7fffffff
    sltiu a3, a1, -2048
    li   t6, 0x1
    beq  a3, t6, t539_ok
    j    fail
t539_ok:
t540: # sltiu 0x7fffffff, 1365
    li   a0, 540
    li   a1, 0x7fffffff
    sltiu a3, a1, 1365
    li   t6, 0x0
    beq  a3, t6, t540_ok
    j    fail
t540_ok:
t541: # sltiu 0x7fffffff, -2045
    li   a0, 541
    li   a1, 0x7fffffff
    sltiu a3, a1, -2045
    li   t6, 0x1
    beq  a3, t6, t541_ok
    j    fail
t541_ok:
t542: # sltiu 0x3f, 0
    li   a0, 542
    li   a1, 0x3f
    sltiu a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t542_ok
    j    fail
t542_ok:
t543: # sltiu 0x3f, 1
    li   a0, 543
    li   a1, 0x3f
    sltiu a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t543_ok
    j    fail
t543_ok:
t544: # sltiu 0x3f, -1
    li   a0, 544
    li   a1, 0x3f
    sltiu a3, a1, -1
    li   t6, 0x1
    beq  a3, t6, t544_ok
    j    fail
t544_ok:
t545: # sltiu 0x3f, 2047
    li   a0, 545
    li   a1, 0x3f
    sltiu a3, a1, 2047
    li   t6, 0x1
    beq  a3, t6, t545_ok
    j    fail
t545_ok:
t546: # sltiu 0x3f, -2048
    li   a0, 546
    li   a1, 0x3f
    sltiu a3, a1, -2048
    li   t6, 0x1
    beq  a3, t6, t546_ok
    j    fail
t546_ok:
t547: # sltiu 0x3f, 1365
    li   a0, 547
    li   a1, 0x3f
    sltiu a3, a1, 1365
    li   t6, 0x1
    beq  a3, t6, t547_ok
    j    fail
t547_ok:
t548: # sltiu 0x3f, -2045
    li   a0, 548
    li   a1, 0x3f
    sltiu a3, a1, -2045
    li   t6, 0x1
    beq  a3, t6, t548_ok
    j    fail
t548_ok:
t549: # xori 0x0, 0
    li   a0, 549
    li   a1, 0x0
    xori a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t549_ok
    j    fail
t549_ok:
t550: # xori 0x0, 1
    li   a0, 550
    li   a1, 0x0
    xori a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t550_ok
    j    fail
t550_ok:
t551: # xori 0x0, -1
    li   a0, 551
    li   a1, 0x0
    xori a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t551_ok
    j    fail
t551_ok:
t552: # xori 0x0, 2047
    li   a0, 552
    li   a1, 0x0
    xori a3, a1, 2047
    li   t6, 0x7ff
    beq  a3, t6, t552_ok
    j    fail
t552_ok:
t553: # xori 0x0, -2048
    li   a0, 553
    li   a1, 0x0
    xori a3, a1, -2048
    li   t6, 0xfffffffffffff800
    beq  a3, t6, t553_ok
    j    fail
t553_ok:
t554: # xori 0x0, 1365
    li   a0, 554
    li   a1, 0x0
    xori a3, a1, 1365
    li   t6, 0x555
    beq  a3, t6, t554_ok
    j    fail
t554_ok:
t555: # xori 0x0, -2045
    li   a0, 555
    li   a1, 0x0
    xori a3, a1, -2045
    li   t6, 0xfffffffffffff803
    beq  a3, t6, t555_ok
    j    fail
t555_ok:
t556: # xori 0xfffffffffffffff9, 0
    li   a0, 556
    li   a1, 0xfffffffffffffff9
    xori a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t556_ok
    j    fail
t556_ok:
t557: # xori 0xfffffffffffffff9, 1
    li   a0, 557
    li   a1, 0xfffffffffffffff9
    xori a3, a1, 1
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t557_ok
    j    fail
t557_ok:
t558: # xori 0xfffffffffffffff9, -1
    li   a0, 558
    li   a1, 0xfffffffffffffff9
    xori a3, a1, -1
    li   t6, 0x6
    beq  a3, t6, t558_ok
    j    fail
t558_ok:
t559: # xori 0xfffffffffffffff9, 2047
    li   a0, 559
    li   a1, 0xfffffffffffffff9
    xori a3, a1, 2047
    li   t6, 0xfffffffffffff806
    beq  a3, t6, t559_ok
    j    fail
t559_ok:
t560: # xori 0xfffffffffffffff9, -2048
    li   a0, 560
    li   a1, 0xfffffffffffffff9
    xori a3, a1, -2048
    li   t6, 0x7f9
    beq  a3, t6, t560_ok
    j    fail
t560_ok:
t561: # xori 0xfffffffffffffff9, 1365
    li   a0, 561
    li   a1, 0xfffffffffffffff9
    xori a3, a1, 1365
    li   t6, 0xfffffffffffffaac
    beq  a3, t6, t561_ok
    j    fail
t561_ok:
t562: # xori 0xfffffffffffffff9, -2045
    li   a0, 562
    li   a1, 0xfffffffffffffff9
    xori a3, a1, -2045
    li   t6, 0x7fa
    beq  a3, t6, t562_ok
    j    fail
t562_ok:
t563: # xori 0x7fffffff, 0
    li   a0, 563
    li   a1, 0x7fffffff
    xori a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t563_ok
    j    fail
t563_ok:
t564: # xori 0x7fffffff, 1
    li   a0, 564
    li   a1, 0x7fffffff
    xori a3, a1, 1
    li   t6, 0x7ffffffe
    beq  a3, t6, t564_ok
    j    fail
t564_ok:
t565: # xori 0x7fffffff, -1
    li   a0, 565
    li   a1, 0x7fffffff
    xori a3, a1, -1
    li   t6, 0xffffffff80000000
    beq  a3, t6, t565_ok
    j    fail
t565_ok:
t566: # xori 0x7fffffff, 2047
    li   a0, 566
    li   a1, 0x7fffffff
    xori a3, a1, 2047
    li   t6, 0x7ffff800
    beq  a3, t6, t566_ok
    j    fail
t566_ok:
t567: # xori 0x7fffffff, -2048
    li   a0, 567
    li   a1, 0x7fffffff
    xori a3, a1, -2048
    li   t6, 0xffffffff800007ff
    beq  a3, t6, t567_ok
    j    fail
t567_ok:
t568: # xori 0x7fffffff, 1365
    li   a0, 568
    li   a1, 0x7fffffff
    xori a3, a1, 1365
    li   t6, 0x7ffffaaa
    beq  a3, t6, t568_ok
    j    fail
t568_ok:
t569: # xori 0x7fffffff, -2045
    li   a0, 569
    li   a1, 0x7fffffff
    xori a3, a1, -2045
    li   t6, 0xffffffff800007fc
    beq  a3, t6, t569_ok
    j    fail
t569_ok:
t570: # xori 0x3f, 0
    li   a0, 570
    li   a1, 0x3f
    xori a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t570_ok
    j    fail
t570_ok:
t571: # xori 0x3f, 1
    li   a0, 571
    li   a1, 0x3f
    xori a3, a1, 1
    li   t6, 0x3e
    beq  a3, t6, t571_ok
    j    fail
t571_ok:
t572: # xori 0x3f, -1
    li   a0, 572
    li   a1, 0x3f
    xori a3, a1, -1
    li   t6, 0xffffffffffffffc0
    beq  a3, t6, t572_ok
    j    fail
t572_ok:
t573: # xori 0x3f, 2047
    li   a0, 573
    li   a1, 0x3f
    xori a3, a1, 2047
    li   t6, 0x7c0
    beq  a3, t6, t573_ok
    j    fail
t573_ok:
t574: # xori 0x3f, -2048
    li   a0, 574
    li   a1, 0x3f
    xori a3, a1, -2048
    li   t6, 0xfffffffffffff83f
    beq  a3, t6, t574_ok
    j    fail
t574_ok:
t575: # xori 0x3f, 1365
    li   a0, 575
    li   a1, 0x3f
    xori a3, a1, 1365
    li   t6, 0x56a
    beq  a3, t6, t575_ok
    j    fail
t575_ok:
t576: # xori 0x3f, -2045
    li   a0, 576
    li   a1, 0x3f
    xori a3, a1, -2045
    li   t6, 0xfffffffffffff83c
    beq  a3, t6, t576_ok
    j    fail
t576_ok:
t577: # ori 0x0, 0
    li   a0, 577
    li   a1, 0x0
    ori a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t577_ok
    j    fail
t577_ok:
t578: # ori 0x0, 1
    li   a0, 578
    li   a1, 0x0
    ori a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t578_ok
    j    fail
t578_ok:
t579: # ori 0x0, -1
    li   a0, 579
    li   a1, 0x0
    ori a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t579_ok
    j    fail
t579_ok:
t580: # ori 0x0, 2047
    li   a0, 580
    li   a1, 0x0
    ori a3, a1, 2047
    li   t6, 0x7ff
    beq  a3, t6, t580_ok
    j    fail
t580_ok:
t581: # ori 0x0, -2048
    li   a0, 581
    li   a1, 0x0
    ori a3, a1, -2048
    li   t6, 0xfffffffffffff800
    beq  a3, t6, t581_ok
    j    fail
t581_ok:
t582: # ori 0x0, 1365
    li   a0, 582
    li   a1, 0x0
    ori a3, a1, 1365
    li   t6, 0x555
    beq  a3, t6, t582_ok
    j    fail
t582_ok:
t583: # ori 0x0, -2045
    li   a0, 583
    li   a1, 0x0
    ori a3, a1, -2045
    li   t6, 0xfffffffffffff803
    beq  a3, t6, t583_ok
    j    fail
t583_ok:
t584: # ori 0xfffffffffffffff9, 0
    li   a0, 584
    li   a1, 0xfffffffffffffff9
    ori a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t584_ok
    j    fail
t584_ok:
t585: # ori 0xfffffffffffffff9, 1
    li   a0, 585
    li   a1, 0xfffffffffffffff9
    ori a3, a1, 1
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t585_ok
    j    fail
t585_ok:
t586: # ori 0xfffffffffffffff9, -1
    li   a0, 586
    li   a1, 0xfffffffffffffff9
    ori a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t586_ok
    j    fail
t586_ok:
t587: # ori 0xfffffffffffffff9, 2047
    li   a0, 587
    li   a1, 0xfffffffffffffff9
    ori a3, a1, 2047
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t587_ok
    j    fail
t587_ok:
t588: # ori 0xfffffffffffffff9, -2048
    li   a0, 588
    li   a1, 0xfffffffffffffff9
    ori a3, a1, -2048
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t588_ok
    j    fail
t588_ok:
t589: # ori 0xfffffffffffffff9, 1365
    li   a0, 589
    li   a1, 0xfffffffffffffff9
    ori a3, a1, 1365
    li   t6, 0xfffffffffffffffd
    beq  a3, t6, t589_ok
    j    fail
t589_ok:
t590: # ori 0xfffffffffffffff9, -2045
    li   a0, 590
    li   a1, 0xfffffffffffffff9
    ori a3, a1, -2045
    li   t6, 0xfffffffffffffffb
    beq  a3, t6, t590_ok
    j    fail
t590_ok:
t591: # ori 0x7fffffff, 0
    li   a0, 591
    li   a1, 0x7fffffff
    ori a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t591_ok
    j    fail
t591_ok:
t592: # ori 0x7fffffff, 1
    li   a0, 592
    li   a1, 0x7fffffff
    ori a3, a1, 1
    li   t6, 0x7fffffff
    beq  a3, t6, t592_ok
    j    fail
t592_ok:
t593: # ori 0x7fffffff, -1
    li   a0, 593
    li   a1, 0x7fffffff
    ori a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t593_ok
    j    fail
t593_ok:
t594: # ori 0x7fffffff, 2047
    li   a0, 594
    li   a1, 0x7fffffff
    ori a3, a1, 2047
    li   t6, 0x7fffffff
    beq  a3, t6, t594_ok
    j    fail
t594_ok:
t595: # ori 0x7fffffff, -2048
    li   a0, 595
    li   a1, 0x7fffffff
    ori a3, a1, -2048
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t595_ok
    j    fail
t595_ok:
t596: # ori 0x7fffffff, 1365
    li   a0, 596
    li   a1, 0x7fffffff
    ori a3, a1, 1365
    li   t6, 0x7fffffff
    beq  a3, t6, t596_ok
    j    fail
t596_ok:
t597: # ori 0x7fffffff, -2045
    li   a0, 597
    li   a1, 0x7fffffff
    ori a3, a1, -2045
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t597_ok
    j    fail
t597_ok:
t598: # ori 0x3f, 0
    li   a0, 598
    li   a1, 0x3f
    ori a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t598_ok
    j    fail
t598_ok:
t599: # ori 0x3f, 1
    li   a0, 599
    li   a1, 0x3f
    ori a3, a1, 1
    li   t6, 0x3f
    beq  a3, t6, t599_ok
    j    fail
t599_ok:
t600: # ori 0x3f, -1
    li   a0, 600
    li   a1, 0x3f
    ori a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t600_ok
    j    fail
t600_ok:
t601: # ori 0x3f, 2047
    li   a0, 601
    li   a1, 0x3f
    ori a3, a1, 2047
    li   t6, 0x7ff
    beq  a3, t6, t601_ok
    j    fail
t601_ok:
t602: # ori 0x3f, -2048
    li   a0, 602
    li   a1, 0x3f
    ori a3, a1, -2048
    li   t6, 0xfffffffffffff83f
    beq  a3, t6, t602_ok
    j    fail
t602_ok:
t603: # ori 0x3f, 1365
    li   a0, 603
    li   a1, 0x3f
    ori a3, a1, 1365
    li   t6, 0x57f
    beq  a3, t6, t603_ok
    j    fail
t603_ok:
t604: # ori 0x3f, -2045
    li   a0, 604
    li   a1, 0x3f
    ori a3, a1, -2045
    li   t6, 0xfffffffffffff83f
    beq  a3, t6, t604_ok
    j    fail
t604_ok:
t605: # andi 0x0, 0
    li   a0, 605
    li   a1, 0x0
    andi a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t605_ok
    j    fail
t605_ok:
t606: # andi 0x0, 1
    li   a0, 606
    li   a1, 0x0
    andi a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t606_ok
    j    fail
t606_ok:
t607: # andi 0x0, -1
    li   a0, 607
    li   a1, 0x0
    andi a3, a1, -1
    li   t6, 0x0
    beq  a3, t6, t607_ok
    j    fail
t607_ok:
t608: # andi 0x0, 2047
    li   a0, 608
    li   a1, 0x0
    andi a3, a1, 2047
    li   t6, 0x0
    beq  a3, t6, t608_ok
    j    fail
t608_ok:
t609: # andi 0x0, -2048
    li   a0, 609
    li   a1, 0x0
    andi a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t609_ok
    j    fail
t609_ok:
t610: # andi 0x0, 1365
    li   a0, 610
    li   a1, 0x0
    andi a3, a1, 1365
    li   t6, 0x0
    beq  a3, t6, t610_ok
    j    fail
t610_ok:
t611: # andi 0x0, -2045
    li   a0, 611
    li   a1, 0x0
    andi a3, a1, -2045
    li   t6, 0x0
    beq  a3, t6, t611_ok
    j    fail
t611_ok:
t612: # andi 0xfffffffffffffff9, 0
    li   a0, 612
    li   a1, 0xfffffffffffffff9
    andi a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t612_ok
    j    fail
t612_ok:
t613: # andi 0xfffffffffffffff9, 1
    li   a0, 613
    li   a1, 0xfffffffffffffff9
    andi a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t613_ok
    j    fail
t613_ok:
t614: # andi 0xfffffffffffffff9, -1
    li   a0, 614
    li   a1, 0xfffffffffffffff9
    andi a3, a1, -1
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t614_ok
    j    fail
t614_ok:
t615: # andi 0xfffffffffffffff9, 2047
    li   a0, 615
    li   a1, 0xfffffffffffffff9
    andi a3, a1, 2047
    li   t6, 0x7f9
    beq  a3, t6, t615_ok
    j    fail
t615_ok:
t616: # andi 0xfffffffffffffff9, -2048
    li   a0, 616
    li   a1, 0xfffffffffffffff9
    andi a3, a1, -2048
    li   t6, 0xfffffffffffff800
    beq  a3, t6, t616_ok
    j    fail
t616_ok:
t617: # andi 0xfffffffffffffff9, 1365
    li   a0, 617
    li   a1, 0xfffffffffffffff9
    andi a3, a1, 1365
    li   t6, 0x551
    beq  a3, t6, t617_ok
    j    fail
t617_ok:
t618: # andi 0xfffffffffffffff9, -2045
    li   a0, 618
    li   a1, 0xfffffffffffffff9
    andi a3, a1, -2045
    li   t6, 0xfffffffffffff801
    beq  a3, t6, t618_ok
    j    fail
t618_ok:
t619: # andi 0x7fffffff, 0
    li   a0, 619
    li   a1, 0x7fffffff
    andi a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t619_ok
    j    fail
t619_ok:
t620: # andi 0x7fffffff, 1
    li   a0, 620
    li   a1, 0x7fffffff
    andi a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t620_ok
    j    fail
t620_ok:
t621: # andi 0x7fffffff, -1
    li   a0, 621
    li   a1, 0x7fffffff
    andi a3, a1, -1
    li   t6, 0x7fffffff
    beq  a3, t6, t621_ok
    j    fail
t621_ok:
t622: # andi 0x7fffffff, 2047
    li   a0, 622
    li   a1, 0x7fffffff
    andi a3, a1, 2047
    li   t6, 0x7ff
    beq  a3, t6, t622_ok
    j    fail
t622_ok:
t623: # andi 0x7fffffff, -2048
    li   a0, 623
    li   a1, 0x7fffffff
    andi a3, a1, -2048
    li   t6, 0x7ffff800
    beq  a3, t6, t623_ok
    j    fail
t623_ok:
t624: # andi 0x7fffffff, 1365
    li   a0, 624
    li   a1, 0x7fffffff
    andi a3, a1, 1365
    li   t6, 0x555
    beq  a3, t6, t624_ok
    j    fail
t624_ok:
t625: # andi 0x7fffffff, -2045
    li   a0, 625
    li   a1, 0x7fffffff
    andi a3, a1, -2045
    li   t6, 0x7ffff803
    beq  a3, t6, t625_ok
    j    fail
t625_ok:
t626: # andi 0x3f, 0
    li   a0, 626
    li   a1, 0x3f
    andi a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t626_ok
    j    fail
t626_ok:
t627: # andi 0x3f, 1
    li   a0, 627
    li   a1, 0x3f
    andi a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t627_ok
    j    fail
t627_ok:
t628: # andi 0x3f, -1
    li   a0, 628
    li   a1, 0x3f
    andi a3, a1, -1
    li   t6, 0x3f
    beq  a3, t6, t628_ok
    j    fail
t628_ok:
t629: # andi 0x3f, 2047
    li   a0, 629
    li   a1, 0x3f
    andi a3, a1, 2047
    li   t6, 0x3f
    beq  a3, t6, t629_ok
    j    fail
t629_ok:
t630: # andi 0x3f, -2048
    li   a0, 630
    li   a1, 0x3f
    andi a3, a1, -2048
    li   t6, 0x0
    beq  a3, t6, t630_ok
    j    fail
t630_ok:
t631: # andi 0x3f, 1365
    li   a0, 631
    li   a1, 0x3f
    andi a3, a1, 1365
    li   t6, 0x15
    beq  a3, t6, t631_ok
    j    fail
t631_ok:
t632: # andi 0x3f, -2045
    li   a0, 632
    li   a1, 0x3f
    andi a3, a1, -2045
    li   t6, 0x3
    beq  a3, t6, t632_ok
    j    fail
t632_ok:
t633: # slli 0x0, 0
    li   a0, 633
    li   a1, 0x0
    slli a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t633_ok
    j    fail
t633_ok:
t634: # slli 0x0, 1
    li   a0, 634
    li   a1, 0x0
    slli a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t634_ok
    j    fail
t634_ok:
t635: # slli 0x0, 31
    li   a0, 635
    li   a1, 0x0
    slli a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t635_ok
    j    fail
t635_ok:
t636: # slli 0x0, 32
    li   a0, 636
    li   a1, 0x0
    slli a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t636_ok
    j    fail
t636_ok:
t637: # slli 0x0, 63
    li   a0, 637
    li   a1, 0x0
    slli a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t637_ok
    j    fail
t637_ok:
t638: # slli 0xfffffffffffffff9, 0
    li   a0, 638
    li   a1, 0xfffffffffffffff9
    slli a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t638_ok
    j    fail
t638_ok:
t639: # slli 0xfffffffffffffff9, 1
    li   a0, 639
    li   a1, 0xfffffffffffffff9
    slli a3, a1, 1
    li   t6, 0xfffffffffffffff2
    beq  a3, t6, t639_ok
    j    fail
t639_ok:
t640: # slli 0xfffffffffffffff9, 31
    li   a0, 640
    li   a1, 0xfffffffffffffff9
    slli a3, a1, 31
    li   t6, 0xfffffffc80000000
    beq  a3, t6, t640_ok
    j    fail
t640_ok:
t641: # slli 0xfffffffffffffff9, 32
    li   a0, 641
    li   a1, 0xfffffffffffffff9
    slli a3, a1, 32
    li   t6, 0xfffffff900000000
    beq  a3, t6, t641_ok
    j    fail
t641_ok:
t642: # slli 0xfffffffffffffff9, 63
    li   a0, 642
    li   a1, 0xfffffffffffffff9
    slli a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t642_ok
    j    fail
t642_ok:
t643: # slli 0x7fffffff, 0
    li   a0, 643
    li   a1, 0x7fffffff
    slli a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t643_ok
    j    fail
t643_ok:
t644: # slli 0x7fffffff, 1
    li   a0, 644
    li   a1, 0x7fffffff
    slli a3, a1, 1
    li   t6, 0xfffffffe
    beq  a3, t6, t644_ok
    j    fail
t644_ok:
t645: # slli 0x7fffffff, 31
    li   a0, 645
    li   a1, 0x7fffffff
    slli a3, a1, 31
    li   t6, 0x3fffffff80000000
    beq  a3, t6, t645_ok
    j    fail
t645_ok:
t646: # slli 0x7fffffff, 32
    li   a0, 646
    li   a1, 0x7fffffff
    slli a3, a1, 32
    li   t6, 0x7fffffff00000000
    beq  a3, t6, t646_ok
    j    fail
t646_ok:
t647: # slli 0x7fffffff, 63
    li   a0, 647
    li   a1, 0x7fffffff
    slli a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t647_ok
    j    fail
t647_ok:
t648: # slli 0x3f, 0
    li   a0, 648
    li   a1, 0x3f
    slli a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t648_ok
    j    fail
t648_ok:
t649: # slli 0x3f, 1
    li   a0, 649
    li   a1, 0x3f
    slli a3, a1, 1
    li   t6, 0x7e
    beq  a3, t6, t649_ok
    j    fail
t649_ok:
t650: # slli 0x3f, 31
    li   a0, 650
    li   a1, 0x3f
    slli a3, a1, 31
    li   t6, 0x1f80000000
    beq  a3, t6, t650_ok
    j    fail
t650_ok:
t651: # slli 0x3f, 32
    li   a0, 651
    li   a1, 0x3f
    slli a3, a1, 32
    li   t6, 0x3f00000000
    beq  a3, t6, t651_ok
    j    fail
t651_ok:
t652: # slli 0x3f, 63
    li   a0, 652
    li   a1, 0x3f
    slli a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t652_ok
    j    fail
t652_ok:
t653: # srli 0x0, 0
    li   a0, 653
    li   a1, 0x0
    srli a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t653_ok
    j    fail
t653_ok:
t654: # srli 0x0, 1
    li   a0, 654
    li   a1, 0x0
    srli a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t654_ok
    j    fail
t654_ok:
t655: # srli 0x0, 31
    li   a0, 655
    li   a1, 0x0
    srli a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t655_ok
    j    fail
t655_ok:
t656: # srli 0x0, 32
    li   a0, 656
    li   a1, 0x0
    srli a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t656_ok
    j    fail
t656_ok:
t657: # srli 0x0, 63
    li   a0, 657
    li   a1, 0x0
    srli a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t657_ok
    j    fail
t657_ok:
t658: # srli 0xfffffffffffffff9, 0
    li   a0, 658
    li   a1, 0xfffffffffffffff9
    srli a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t658_ok
    j    fail
t658_ok:
t659: # srli 0xfffffffffffffff9, 1
    li   a0, 659
    li   a1, 0xfffffffffffffff9
    srli a3, a1, 1
    li   t6, 0x7ffffffffffffffc
    beq  a3, t6, t659_ok
    j    fail
t659_ok:
t660: # srli 0xfffffffffffffff9, 31
    li   a0, 660
    li   a1, 0xfffffffffffffff9
    srli a3, a1, 31
    li   t6, 0x1ffffffff
    beq  a3, t6, t660_ok
    j    fail
t660_ok:
t661: # srli 0xfffffffffffffff9, 32
    li   a0, 661
    li   a1, 0xfffffffffffffff9
    srli a3, a1, 32
    li   t6, 0xffffffff
    beq  a3, t6, t661_ok
    j    fail
t661_ok:
t662: # srli 0xfffffffffffffff9, 63
    li   a0, 662
    li   a1, 0xfffffffffffffff9
    srli a3, a1, 63
    li   t6, 0x1
    beq  a3, t6, t662_ok
    j    fail
t662_ok:
t663: # srli 0x7fffffff, 0
    li   a0, 663
    li   a1, 0x7fffffff
    srli a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t663_ok
    j    fail
t663_ok:
t664: # srli 0x7fffffff, 1
    li   a0, 664
    li   a1, 0x7fffffff
    srli a3, a1, 1
    li   t6, 0x3fffffff
    beq  a3, t6, t664_ok
    j    fail
t664_ok:
t665: # srli 0x7fffffff, 31
    li   a0, 665
    li   a1, 0x7fffffff
    srli a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t665_ok
    j    fail
t665_ok:
t666: # srli 0x7fffffff, 32
    li   a0, 666
    li   a1, 0x7fffffff
    srli a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t666_ok
    j    fail
t666_ok:
t667: # srli 0x7fffffff, 63
    li   a0, 667
    li   a1, 0x7fffffff
    srli a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t667_ok
    j    fail
t667_ok:
t668: # srli 0x3f, 0
    li   a0, 668
    li   a1, 0x3f
    srli a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t668_ok
    j    fail
t668_ok:
t669: # srli 0x3f, 1
    li   a0, 669
    li   a1, 0x3f
    srli a3, a1, 1
    li   t6, 0x1f
    beq  a3, t6, t669_ok
    j    fail
t669_ok:
t670: # srli 0x3f, 31
    li   a0, 670
    li   a1, 0x3f
    srli a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t670_ok
    j    fail
t670_ok:
t671: # srli 0x3f, 32
    li   a0, 671
    li   a1, 0x3f
    srli a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t671_ok
    j    fail
t671_ok:
t672: # srli 0x3f, 63
    li   a0, 672
    li   a1, 0x3f
    srli a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t672_ok
    j    fail
t672_ok:
t673: # srai 0x0, 0
    li   a0, 673
    li   a1, 0x0
    srai a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t673_ok
    j    fail
t673_ok:
t674: # srai 0x0, 1
    li   a0, 674
    li   a1, 0x0
    srai a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t674_ok
    j    fail
t674_ok:
t675: # srai 0x0, 31
    li   a0, 675
    li   a1, 0x0
    srai a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t675_ok
    j    fail
t675_ok:
t676: # srai 0x0, 32
    li   a0, 676
    li   a1, 0x0
    srai a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t676_ok
    j    fail
t676_ok:
t677: # srai 0x0, 63
    li   a0, 677
    li   a1, 0x0
    srai a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t677_ok
    j    fail
t677_ok:
t678: # srai 0xfffffffffffffff9, 0
    li   a0, 678
    li   a1, 0xfffffffffffffff9
    srai a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t678_ok
    j    fail
t678_ok:
t679: # srai 0xfffffffffffffff9, 1
    li   a0, 679
    li   a1, 0xfffffffffffffff9
    srai a3, a1, 1
    li   t6, 0xfffffffffffffffc
    beq  a3, t6, t679_ok
    j    fail
t679_ok:
t680: # srai 0xfffffffffffffff9, 31
    li   a0, 680
    li   a1, 0xfffffffffffffff9
    srai a3, a1, 31
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t680_ok
    j    fail
t680_ok:
t681: # srai 0xfffffffffffffff9, 32
    li   a0, 681
    li   a1, 0xfffffffffffffff9
    srai a3, a1, 32
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t681_ok
    j    fail
t681_ok:
t682: # srai 0xfffffffffffffff9, 63
    li   a0, 682
    li   a1, 0xfffffffffffffff9
    srai a3, a1, 63
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t682_ok
    j    fail
t682_ok:
t683: # srai 0x7fffffff, 0
    li   a0, 683
    li   a1, 0x7fffffff
    srai a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t683_ok
    j    fail
t683_ok:
t684: # srai 0x7fffffff, 1
    li   a0, 684
    li   a1, 0x7fffffff
    srai a3, a1, 1
    li   t6, 0x3fffffff
    beq  a3, t6, t684_ok
    j    fail
t684_ok:
t685: # srai 0x7fffffff, 31
    li   a0, 685
    li   a1, 0x7fffffff
    srai a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t685_ok
    j    fail
t685_ok:
t686: # srai 0x7fffffff, 32
    li   a0, 686
    li   a1, 0x7fffffff
    srai a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t686_ok
    j    fail
t686_ok:
t687: # srai 0x7fffffff, 63
    li   a0, 687
    li   a1, 0x7fffffff
    srai a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t687_ok
    j    fail
t687_ok:
t688: # srai 0x3f, 0
    li   a0, 688
    li   a1, 0x3f
    srai a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t688_ok
    j    fail
t688_ok:
t689: # srai 0x3f, 1
    li   a0, 689
    li   a1, 0x3f
    srai a3, a1, 1
    li   t6, 0x1f
    beq  a3, t6, t689_ok
    j    fail
t689_ok:
t690: # srai 0x3f, 31
    li   a0, 690
    li   a1, 0x3f
    srai a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t690_ok
    j    fail
t690_ok:
t691: # srai 0x3f, 32
    li   a0, 691
    li   a1, 0x3f
    srai a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t691_ok
    j    fail
t691_ok:
t692: # srai 0x3f, 63
    li   a0, 692
    li   a1, 0x3f
    srai a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t692_ok
    j    fail
t692_ok:
t693: # addiw 0x0, 0
    li   a0, 693
    li   a1, 0x0
    addiw a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t693_ok
    j    fail
t693_ok:
t694: # addiw 0x0, 1
    li   a0, 694
    li   a1, 0x0
    addiw a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t694_ok
    j    fail
t694_ok:
t695: # addiw 0x0, -1
    li   a0, 695
    li   a1, 0x0
    addiw a3, a1, -1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t695_ok
    j    fail
t695_ok:
t696: # addiw 0x0, 2047
    li   a0, 696
    li   a1, 0x0
    addiw a3, a1, 2047
    li   t6, 0x7ff
    beq  a3, t6, t696_ok
    j    fail
t696_ok:
t697: # addiw 0x0, -2048
    li   a0, 697
    li   a1, 0x0
    addiw a3, a1, -2048
    li   t6, 0xfffffffffffff800
    beq  a3, t6, t697_ok
    j    fail
t697_ok:
t698: # addiw 0x0, 1365
    li   a0, 698
    li   a1, 0x0
    addiw a3, a1, 1365
    li   t6, 0x555
    beq  a3, t6, t698_ok
    j    fail
t698_ok:
t699: # addiw 0x0, -2045
    li   a0, 699
    li   a1, 0x0
    addiw a3, a1, -2045
    li   t6, 0xfffffffffffff803
    beq  a3, t6, t699_ok
    j    fail
t699_ok:
t700: # addiw 0xfffffffffffffff9, 0
    li   a0, 700
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t700_ok
    j    fail
t700_ok:
t701: # addiw 0xfffffffffffffff9, 1
    li   a0, 701
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, 1
    li   t6, 0xfffffffffffffffa
    beq  a3, t6, t701_ok
    j    fail
t701_ok:
t702: # addiw 0xfffffffffffffff9, -1
    li   a0, 702
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, -1
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t702_ok
    j    fail
t702_ok:
t703: # addiw 0xfffffffffffffff9, 2047
    li   a0, 703
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, 2047
    li   t6, 0x7f8
    beq  a3, t6, t703_ok
    j    fail
t703_ok:
t704: # addiw 0xfffffffffffffff9, -2048
    li   a0, 704
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, -2048
    li   t6, 0xfffffffffffff7f9
    beq  a3, t6, t704_ok
    j    fail
t704_ok:
t705: # addiw 0xfffffffffffffff9, 1365
    li   a0, 705
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, 1365
    li   t6, 0x54e
    beq  a3, t6, t705_ok
    j    fail
t705_ok:
t706: # addiw 0xfffffffffffffff9, -2045
    li   a0, 706
    li   a1, 0xfffffffffffffff9
    addiw a3, a1, -2045
    li   t6, 0xfffffffffffff7fc
    beq  a3, t6, t706_ok
    j    fail
t706_ok:
t707: # addiw 0x7fffffff, 0
    li   a0, 707
    li   a1, 0x7fffffff
    addiw a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t707_ok
    j    fail
t707_ok:
t708: # addiw 0x7fffffff, 1
    li   a0, 708
    li   a1, 0x7fffffff
    addiw a3, a1, 1
    li   t6, 0xffffffff80000000
    beq  a3, t6, t708_ok
    j    fail
t708_ok:
t709: # addiw 0x7fffffff, -1
    li   a0, 709
    li   a1, 0x7fffffff
    addiw a3, a1, -1
    li   t6, 0x7ffffffe
    beq  a3, t6, t709_ok
    j    fail
t709_ok:
t710: # addiw 0x7fffffff, 2047
    li   a0, 710
    li   a1, 0x7fffffff
    addiw a3, a1, 2047
    li   t6, 0xffffffff800007fe
    beq  a3, t6, t710_ok
    j    fail
t710_ok:
t711: # addiw 0x7fffffff, -2048
    li   a0, 711
    li   a1, 0x7fffffff
    addiw a3, a1, -2048
    li   t6, 0x7ffff7ff
    beq  a3, t6, t711_ok
    j    fail
t711_ok:
t712: # addiw 0x7fffffff, 1365
    li   a0, 712
    li   a1, 0x7fffffff
    addiw a3, a1, 1365
    li   t6, 0xffffffff80000554
    beq  a3, t6, t712_ok
    j    fail
t712_ok:
t713: # addiw 0x7fffffff, -2045
    li   a0, 713
    li   a1, 0x7fffffff
    addiw a3, a1, -2045
    li   t6, 0x7ffff802
    beq  a3, t6, t713_ok
    j    fail
t713_ok:
t714: # addiw 0x3f, 0
    li   a0, 714
    li   a1, 0x3f
    addiw a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t714_ok
    j    fail
t714_ok:
t715: # addiw 0x3f, 1
    li   a0, 715
    li   a1, 0x3f
    addiw a3, a1, 1
    li   t6, 0x40
    beq  a3, t6, t715_ok
    j    fail
t715_ok:
t716: # addiw 0x3f, -1
    li   a0, 716
    li   a1, 0x3f
    addiw a3, a1, -1
    li   t6, 0x3e
    beq  a3, t6, t716_ok
    j    fail
t716_ok:
t717: # addiw 0x3f, 2047
    li   a0, 717
    li   a1, 0x3f
    addiw a3, a1, 2047
    li   t6, 0x83e
    beq  a3, t6, t717_ok
    j    fail
t717_ok:
t718: # addiw 0x3f, -2048
    li   a0, 718
    li   a1, 0x3f
    addiw a3, a1, -2048
    li   t6, 0xfffffffffffff83f
    beq  a3, t6, t718_ok
    j    fail
t718_ok:
t719: # addiw 0x3f, 1365
    li   a0, 719
    li   a1, 0x3f
    addiw a3, a1, 1365
    li   t6, 0x594
    beq  a3, t6, t719_ok
    j    fail
t719_ok:
t720: # addiw 0x3f, -2045
    li   a0, 720
    li   a1, 0x3f
    addiw a3, a1, -2045
    li   t6, 0xfffffffffffff842
    beq  a3, t6, t720_ok
    j    fail
t720_ok:
t721: # slliw 0x0, 0
    li   a0, 721
    li   a1, 0x0
    slliw a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t721_ok
    j    fail
t721_ok:
t722: # slliw 0x0, 1
    li   a0, 722
    li   a1, 0x0
    slliw a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t722_ok
    j    fail
t722_ok:
t723: # slliw 0x0, 31
    li   a0, 723
    li   a1, 0x0
    slliw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t723_ok
    j    fail
t723_ok:
t724: # slliw 0xfffffffffffffff9, 0
    li   a0, 724
    li   a1, 0xfffffffffffffff9
    slliw a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t724_ok
    j    fail
t724_ok:
t725: # slliw 0xfffffffffffffff9, 1
    li   a0, 725
    li   a1, 0xfffffffffffffff9
    slliw a3, a1, 1
    li   t6, 0xfffffffffffffff2
    beq  a3, t6, t725_ok
    j    fail
t725_ok:
t726: # slliw 0xfffffffffffffff9, 31
    li   a0, 726
    li   a1, 0xfffffffffffffff9
    slliw a3, a1, 31
    li   t6, 0xffffffff80000000
    beq  a3, t6, t726_ok
    j    fail
t726_ok:
t727: # slliw 0x7fffffff, 0
    li   a0, 727
    li   a1, 0x7fffffff
    slliw a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t727_ok
    j    fail
t727_ok:
t728: # slliw 0x7fffffff, 1
    li   a0, 728
    li   a1, 0x7fffffff
    slliw a3, a1, 1
    li   t6, 0xfffffffffffffffe
    beq  a3, t6, t728_ok
    j    fail
t728_ok:
t729: # slliw 0x7fffffff, 31
    li   a0, 729
    li   a1, 0x7fffffff
    slliw a3, a1, 31
    li   t6, 0xffffffff80000000
    beq  a3, t6, t729_ok
    j    fail
t729_ok:
t730: # slliw 0x3f, 0
    li   a0, 730
    li   a1, 0x3f
    slliw a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t730_ok
    j    fail
t730_ok:
t731: # slliw 0x3f, 1
    li   a0, 731
    li   a1, 0x3f
    slliw a3, a1, 1
    li   t6, 0x7e
    beq  a3, t6, t731_ok
    j    fail
t731_ok:
t732: # slliw 0x3f, 31
    li   a0, 732
    li   a1, 0x3f
    slliw a3, a1, 31
    li   t6, 0xffffffff80000000
    beq  a3, t6, t732_ok
    j    fail
t732_ok:
t733: # srliw 0x0, 0
    li   a0, 733
    li   a1, 0x0
    srliw a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t733_ok
    j    fail
t733_ok:
t734: # srliw 0x0, 1
    li   a0, 734
    li   a1, 0x0
    srliw a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t734_ok
    j    fail
t734_ok:
t735: # srliw 0x0, 31
    li   a0, 735
    li   a1, 0x0
    srliw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t735_ok
    j    fail
t735_ok:
t736: # srliw 0xfffffffffffffff9, 0
    li   a0, 736
    li   a1, 0xfffffffffffffff9
    srliw a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t736_ok
    j    fail
t736_ok:
t737: # srliw 0xfffffffffffffff9, 1
    li   a0, 737
    li   a1, 0xfffffffffffffff9
    srliw a3, a1, 1
    li   t6, 0x7ffffffc
    beq  a3, t6, t737_ok
    j    fail
t737_ok:
t738: # srliw 0xfffffffffffffff9, 31
    li   a0, 738
    li   a1, 0xfffffffffffffff9
    srliw a3, a1, 31
    li   t6, 0x1
    beq  a3, t6, t738_ok
    j    fail
t738_ok:
t739: # srliw 0x7fffffff, 0
    li   a0, 739
    li   a1, 0x7fffffff
    srliw a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t739_ok
    j    fail
t739_ok:
t740: # srliw 0x7fffffff, 1
    li   a0, 740
    li   a1, 0x7fffffff
    srliw a3, a1, 1
    li   t6, 0x3fffffff
    beq  a3, t6, t740_ok
    j    fail
t740_ok:
t741: # srliw 0x7fffffff, 31
    li   a0, 741
    li   a1, 0x7fffffff
    srliw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t741_ok
    j    fail
t741_ok:
t742: # srliw 0x3f, 0
    li   a0, 742
    li   a1, 0x3f
    srliw a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t742_ok
    j    fail
t742_ok:
t743: # srliw 0x3f, 1
    li   a0, 743
    li   a1, 0x3f
    srliw a3, a1, 1
    li   t6, 0x1f
    beq  a3, t6, t743_ok
    j    fail
t743_ok:
t744: # srliw 0x3f, 31
    li   a0, 744
    li   a1, 0x3f
    srliw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t744_ok
    j    fail
t744_ok:
t745: # sraiw 0x0, 0
    li   a0, 745
    li   a1, 0x0
    sraiw a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t745_ok
    j    fail
t745_ok:
t746: # sraiw 0x0, 1
    li   a0, 746
    li   a1, 0x0
    sraiw a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t746_ok
    j    fail
t746_ok:
t747: # sraiw 0x0, 31
    li   a0, 747
    li   a1, 0x0
    sraiw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t747_ok
    j    fail
t747_ok:
t748: # sraiw 0xfffffffffffffff9, 0
    li   a0, 748
    li   a1, 0xfffffffffffffff9
    sraiw a3, a1, 0
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t748_ok
    j    fail
t748_ok:
t749: # sraiw 0xfffffffffffffff9, 1
    li   a0, 749
    li   a1, 0xfffffffffffffff9
    sraiw a3, a1, 1
    li   t6, 0xfffffffffffffffc
    beq  a3, t6, t749_ok
    j    fail
t749_ok:
t750: # sraiw 0xfffffffffffffff9, 31
    li   a0, 750
    li   a1, 0xfffffffffffffff9
    sraiw a3, a1, 31
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t750_ok
    j    fail
t750_ok:
t751: # sraiw 0x7fffffff, 0
    li   a0, 751
    li   a1, 0x7fffffff
    sraiw a3, a1, 0
    li   t6, 0x7fffffff
    beq  a3, t6, t751_ok
    j    fail
t751_ok:
t752: # sraiw 0x7fffffff, 1
    li   a0, 752
    li   a1, 0x7fffffff
    sraiw a3, a1, 1
    li   t6, 0x3fffffff
    beq  a3, t6, t752_ok
    j    fail
t752_ok:
t753: # sraiw 0x7fffffff, 31
    li   a0, 753
    li   a1, 0x7fffffff
    sraiw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t753_ok
    j    fail
t753_ok:
t754: # sraiw 0x3f, 0
    li   a0, 754
    li   a1, 0x3f
    sraiw a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t754_ok
    j    fail
t754_ok:
t755: # sraiw 0x3f, 1
    li   a0, 755
    li   a1, 0x3f
    sraiw a3, a1, 1
    li   t6, 0x1f
    beq  a3, t6, t755_ok
    j    fail
t755_ok:
t756: # sraiw 0x3f, 31
    li   a0, 756
    li   a1, 0x3f
    sraiw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t756_ok
    j    fail
t756_ok:
t757: # sh1add 0x0, 0x0
    li   a0, 757
    li   a1, 0x0
    li   a2, 0x0
    sh1add a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t757_ok
    j    fail
t757_ok:
t758: # sh1add 0x1, 0x1
    li   a0, 758
    li   a1, 0x1
    li   a2, 0x1
    sh1add a3, a1, a2
    li   t6, 0x3
    beq  a3, t6, t758_ok
    j    fail
t758_ok:
t759: # sh1add 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 759
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0xfffffffffffffffd
    beq  a3, t6, t759_ok
    j    fail
t759_ok:
t760: # sh1add 0x7, 0x7
    li   a0, 760
    li   a1, 0x7
    li   a2, 0x7
    sh1add a3, a1, a2
    li   t6, 0x15
    beq  a3, t6, t760_ok
    j    fail
t760_ok:
t761: # sh1add 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 761
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    sh1add a3, a1, a2
    li   t6, 0xffffffffffffffeb
    beq  a3, t6, t761_ok
    j    fail
t761_ok:
t762: # sh1add 0x8000000000000000, 0x7
    li   a0, 762
    li   a1, 0x8000000000000000
    li   a2, 0x7
    sh1add a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t762_ok
    j    fail
t762_ok:
t763: # sh1add 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 763
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0xfffffffffffffffd
    beq  a3, t6, t763_ok
    j    fail
t763_ok:
t764: # sh1add 0x80000000, 0xffffffffffffffff
    li   a0, 764
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0xffffffff
    beq  a3, t6, t764_ok
    j    fail
t764_ok:
t765: # sh1add 0x7fffffff, 0xffffffffffffffff
    li   a0, 765
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0xfffffffd
    beq  a3, t6, t765_ok
    j    fail
t765_ok:
t766: # sh1add 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 766
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0xfffffffeffffffff
    beq  a3, t6, t766_ok
    j    fail
t766_ok:
t767: # sh1add 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 767
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0x2468acf13579bddf
    beq  a3, t6, t767_ok
    j    fail
t767_ok:
t768: # sh1add 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 768
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    sh1add a3, a1, a2
    li   t6, 0xfdb97530eca8641f
    beq  a3, t6, t768_ok
    j    fail
t768_ok:
t769: # sh1add 0x3f, 0x8000000000000000
    li   a0, 769
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    sh1add a3, a1, a2
    li   t6, 0x800000000000007e
    beq  a3, t6, t769_ok
    j    fail
t769_ok:
t770: # sh1add 0x40, 0x123456789abcdef0
    li   a0, 770
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    sh1add a3, a1, a2
    li   t6, 0x123456789abcdf70
    beq  a3, t6, t770_ok
    j    fail
t770_ok:
t771: # sh1add 0x21, 0xfffffffffffffff9
    li   a0, 771
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sh1add a3, a1, a2
    li   t6, 0x3b
    beq  a3, t6, t771_ok
    j    fail
t771_ok:
t772: # sh2add 0x0, 0x0
    li   a0, 772
    li   a1, 0x0
    li   a2, 0x0
    sh2add a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t772_ok
    j    fail
t772_ok:
t773: # sh2add 0x1, 0x1
    li   a0, 773
    li   a1, 0x1
    li   a2, 0x1
    sh2add a3, a1, a2
    li   t6, 0x5
    beq  a3, t6, t773_ok
    j    fail
t773_ok:
t774: # sh2add 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 774
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0xfffffffffffffffb
    beq  a3, t6, t774_ok
    j    fail
t774_ok:
t775: # sh2add 0x7, 0x7
    li   a0, 775
    li   a1, 0x7
    li   a2, 0x7
    sh2add a3, a1, a2
    li   t6, 0x23
    beq  a3, t6, t775_ok
    j    fail
t775_ok:
t776: # sh2add 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 776
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    sh2add a3, a1, a2
    li   t6, 0xffffffffffffffdd
    beq  a3, t6, t776_ok
    j    fail
t776_ok:
t777: # sh2add 0x8000000000000000, 0x7
    li   a0, 777
    li   a1, 0x8000000000000000
    li   a2, 0x7
    sh2add a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t777_ok
    j    fail
t777_ok:
t778: # sh2add 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 778
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0xfffffffffffffffb
    beq  a3, t6, t778_ok
    j    fail
t778_ok:
t779: # sh2add 0x80000000, 0xffffffffffffffff
    li   a0, 779
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0x1ffffffff
    beq  a3, t6, t779_ok
    j    fail
t779_ok:
t780: # sh2add 0x7fffffff, 0xffffffffffffffff
    li   a0, 780
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0x1fffffffb
    beq  a3, t6, t780_ok
    j    fail
t780_ok:
t781: # sh2add 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 781
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0xfffffffdffffffff
    beq  a3, t6, t781_ok
    j    fail
t781_ok:
t782: # sh2add 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 782
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0x48d159e26af37bbf
    beq  a3, t6, t782_ok
    j    fail
t782_ok:
t783: # sh2add 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 783
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    sh2add a3, a1, a2
    li   t6, 0xfb72ea61d950c83f
    beq  a3, t6, t783_ok
    j    fail
t783_ok:
t784: # sh2add 0x3f, 0x8000000000000000
    li   a0, 784
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    sh2add a3, a1, a2
    li   t6, 0x80000000000000fc
    beq  a3, t6, t784_ok
    j    fail
t784_ok:
t785: # sh2add 0x40, 0x123456789abcdef0
    li   a0, 785
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    sh2add a3, a1, a2
    li   t6, 0x123456789abcdff0
    beq  a3, t6, t785_ok
    j    fail
t785_ok:
t786: # sh2add 0x21, 0xfffffffffffffff9
    li   a0, 786
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sh2add a3, a1, a2
    li   t6, 0x7d
    beq  a3, t6, t786_ok
    j    fail
t786_ok:
t787: # sh3add 0x0, 0x0
    li   a0, 787
    li   a1, 0x0
    li   a2, 0x0
    sh3add a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t787_ok
    j    fail
t787_ok:
t788: # sh3add 0x1, 0x1
    li   a0, 788
    li   a1, 0x1
    li   a2, 0x1
    sh3add a3, a1, a2
    li   t6, 0x9
    beq  a3, t6, t788_ok
    j    fail
t788_ok:
t789: # sh3add 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 789
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0xfffffffffffffff7
    beq  a3, t6, t789_ok
    j    fail
t789_ok:
t790: # sh3add 0x7, 0x7
    li   a0, 790
    li   a1, 0x7
    li   a2, 0x7
    sh3add a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t790_ok
    j    fail
t790_ok:
t791: # sh3add 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 791
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    sh3add a3, a1, a2
    li   t6, 0xffffffffffffffc1
    beq  a3, t6, t791_ok
    j    fail
t791_ok:
t792: # sh3add 0x8000000000000000, 0x7
    li   a0, 792
    li   a1, 0x8000000000000000
    li   a2, 0x7
    sh3add a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t792_ok
    j    fail
t792_ok:
t793: # sh3add 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 793
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0xfffffffffffffff7
    beq  a3, t6, t793_ok
    j    fail
t793_ok:
t794: # sh3add 0x80000000, 0xffffffffffffffff
    li   a0, 794
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0x3ffffffff
    beq  a3, t6, t794_ok
    j    fail
t794_ok:
t795: # sh3add 0x7fffffff, 0xffffffffffffffff
    li   a0, 795
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0x3fffffff7
    beq  a3, t6, t795_ok
    j    fail
t795_ok:
t796: # sh3add 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 796
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0xfffffffbffffffff
    beq  a3, t6, t796_ok
    j    fail
t796_ok:
t797: # sh3add 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 797
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f77f
    beq  a3, t6, t797_ok
    j    fail
t797_ok:
t798: # sh3add 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 798
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    sh3add a3, a1, a2
    li   t6, 0xf6e5d4c3b2a1907f
    beq  a3, t6, t798_ok
    j    fail
t798_ok:
t799: # sh3add 0x3f, 0x8000000000000000
    li   a0, 799
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    sh3add a3, a1, a2
    li   t6, 0x80000000000001f8
    beq  a3, t6, t799_ok
    j    fail
t799_ok:
t800: # sh3add 0x40, 0x123456789abcdef0
    li   a0, 800
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    sh3add a3, a1, a2
    li   t6, 0x123456789abce0f0
    beq  a3, t6, t800_ok
    j    fail
t800_ok:
t801: # sh3add 0x21, 0xfffffffffffffff9
    li   a0, 801
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sh3add a3, a1, a2
    li   t6, 0x101
    beq  a3, t6, t801_ok
    j    fail
t801_ok:
t802: # add.uw 0x0, 0x0
    li   a0, 802
    li   a1, 0x0
    li   a2, 0x0
    add.uw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t802_ok
    j    fail
t802_ok:
t803: # add.uw 0x1, 0x1
    li   a0, 803
    li   a1, 0x1
    li   a2, 0x1
    add.uw a3, a1, a2
    li   t6, 0x2
    beq  a3, t6, t803_ok
    j    fail
t803_ok:
t804: # add.uw 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 804
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0xfffffffe
    beq  a3, t6, t804_ok
    j    fail
t804_ok:
t805: # add.uw 0x7, 0x7
    li   a0, 805
    li   a1, 0x7
    li   a2, 0x7
    add.uw a3, a1, a2
    li   t6, 0xe
    beq  a3, t6, t805_ok
    j    fail
t805_ok:
t806: # add.uw 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 806
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    add.uw a3, a1, a2
    li   t6, 0xfffffff2
    beq  a3, t6, t806_ok
    j    fail
t806_ok:
t807: # add.uw 0x8000000000000000, 0x7
    li   a0, 807
    li   a1, 0x8000000000000000
    li   a2, 0x7
    add.uw a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t807_ok
    j    fail
t807_ok:
t808: # add.uw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 808
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0xfffffffe
    beq  a3, t6, t808_ok
    j    fail
t808_ok:
t809: # add.uw 0x80000000, 0xffffffffffffffff
    li   a0, 809
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t809_ok
    j    fail
t809_ok:
t810: # add.uw 0x7fffffff, 0xffffffffffffffff
    li   a0, 810
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0x7ffffffe
    beq  a3, t6, t810_ok
    j    fail
t810_ok:
t811: # add.uw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 811
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t811_ok
    j    fail
t811_ok:
t812: # add.uw 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 812
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0x9abcdeef
    beq  a3, t6, t812_ok
    j    fail
t812_ok:
t813: # add.uw 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 813
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    add.uw a3, a1, a2
    li   t6, 0x7654320f
    beq  a3, t6, t813_ok
    j    fail
t813_ok:
t814: # add.uw 0x3f, 0x8000000000000000
    li   a0, 814
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    add.uw a3, a1, a2
    li   t6, 0x800000000000003f
    beq  a3, t6, t814_ok
    j    fail
t814_ok:
t815: # add.uw 0x40, 0x123456789abcdef0
    li   a0, 815
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    add.uw a3, a1, a2
    li   t6, 0x123456789abcdf30
    beq  a3, t6, t815_ok
    j    fail
t815_ok:
t816: # add.uw 0x21, 0xfffffffffffffff9
    li   a0, 816
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    add.uw a3, a1, a2
    li   t6, 0x1a
    beq  a3, t6, t816_ok
    j    fail
t816_ok:
t817: # sh1add.uw 0x0, 0x0
    li   a0, 817
    li   a1, 0x0
    li   a2, 0x0
    sh1add.uw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t817_ok
    j    fail
t817_ok:
t818: # sh1add.uw 0x1, 0x1
    li   a0, 818
    li   a1, 0x1
    li   a2, 0x1
    sh1add.uw a3, a1, a2
    li   t6, 0x3
    beq  a3, t6, t818_ok
    j    fail
t818_ok:
t819: # sh1add.uw 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 819
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0x1fffffffd
    beq  a3, t6, t819_ok
    j    fail
t819_ok:
t820: # sh1add.uw 0x7, 0x7
    li   a0, 820
    li   a1, 0x7
    li   a2, 0x7
    sh1add.uw a3, a1, a2
    li   t6, 0x15
    beq  a3, t6, t820_ok
    j    fail
t820_ok:
t821: # sh1add.uw 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 821
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    sh1add.uw a3, a1, a2
    li   t6, 0x1ffffffeb
    beq  a3, t6, t821_ok
    j    fail
t821_ok:
t822: # sh1add.uw 0x8000000000000000, 0x7
    li   a0, 822
    li   a1, 0x8000000000000000
    li   a2, 0x7
    sh1add.uw a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t822_ok
    j    fail
t822_ok:
t823: # sh1add.uw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 823
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0x1fffffffd
    beq  a3, t6, t823_ok
    j    fail
t823_ok:
t824: # sh1add.uw 0x80000000, 0xffffffffffffffff
    li   a0, 824
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0xffffffff
    beq  a3, t6, t824_ok
    j    fail
t824_ok:
t825: # sh1add.uw 0x7fffffff, 0xffffffffffffffff
    li   a0, 825
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0xfffffffd
    beq  a3, t6, t825_ok
    j    fail
t825_ok:
t826: # sh1add.uw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 826
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0xffffffff
    beq  a3, t6, t826_ok
    j    fail
t826_ok:
t827: # sh1add.uw 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 827
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0x13579bddf
    beq  a3, t6, t827_ok
    j    fail
t827_ok:
t828: # sh1add.uw 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 828
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    sh1add.uw a3, a1, a2
    li   t6, 0xeca8641f
    beq  a3, t6, t828_ok
    j    fail
t828_ok:
t829: # sh1add.uw 0x3f, 0x8000000000000000
    li   a0, 829
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    sh1add.uw a3, a1, a2
    li   t6, 0x800000000000007e
    beq  a3, t6, t829_ok
    j    fail
t829_ok:
t830: # sh1add.uw 0x40, 0x123456789abcdef0
    li   a0, 830
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    sh1add.uw a3, a1, a2
    li   t6, 0x123456789abcdf70
    beq  a3, t6, t830_ok
    j    fail
t830_ok:
t831: # sh1add.uw 0x21, 0xfffffffffffffff9
    li   a0, 831
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sh1add.uw a3, a1, a2
    li   t6, 0x3b
    beq  a3, t6, t831_ok
    j    fail
t831_ok:
t832: # sh2add.uw 0x0, 0x0
    li   a0, 832
    li   a1, 0x0
    li   a2, 0x0
    sh2add.uw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t832_ok
    j    fail
t832_ok:
t833: # sh2add.uw 0x1, 0x1
    li   a0, 833
    li   a1, 0x1
    li   a2, 0x1
    sh2add.uw a3, a1, a2
    li   t6, 0x5
    beq  a3, t6, t833_ok
    j    fail
t833_ok:
t834: # sh2add.uw 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 834
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x3fffffffb
    beq  a3, t6, t834_ok
    j    fail
t834_ok:
t835: # sh2add.uw 0x7, 0x7
    li   a0, 835
    li   a1, 0x7
    li   a2, 0x7
    sh2add.uw a3, a1, a2
    li   t6, 0x23
    beq  a3, t6, t835_ok
    j    fail
t835_ok:
t836: # sh2add.uw 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 836
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    sh2add.uw a3, a1, a2
    li   t6, 0x3ffffffdd
    beq  a3, t6, t836_ok
    j    fail
t836_ok:
t837: # sh2add.uw 0x8000000000000000, 0x7
    li   a0, 837
    li   a1, 0x8000000000000000
    li   a2, 0x7
    sh2add.uw a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t837_ok
    j    fail
t837_ok:
t838: # sh2add.uw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 838
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x3fffffffb
    beq  a3, t6, t838_ok
    j    fail
t838_ok:
t839: # sh2add.uw 0x80000000, 0xffffffffffffffff
    li   a0, 839
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x1ffffffff
    beq  a3, t6, t839_ok
    j    fail
t839_ok:
t840: # sh2add.uw 0x7fffffff, 0xffffffffffffffff
    li   a0, 840
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x1fffffffb
    beq  a3, t6, t840_ok
    j    fail
t840_ok:
t841: # sh2add.uw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 841
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x1ffffffff
    beq  a3, t6, t841_ok
    j    fail
t841_ok:
t842: # sh2add.uw 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 842
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x26af37bbf
    beq  a3, t6, t842_ok
    j    fail
t842_ok:
t843: # sh2add.uw 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 843
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    sh2add.uw a3, a1, a2
    li   t6, 0x1d950c83f
    beq  a3, t6, t843_ok
    j    fail
t843_ok:
t844: # sh2add.uw 0x3f, 0x8000000000000000
    li   a0, 844
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    sh2add.uw a3, a1, a2
    li   t6, 0x80000000000000fc
    beq  a3, t6, t844_ok
    j    fail
t844_ok:
t845: # sh2add.uw 0x40, 0x123456789abcdef0
    li   a0, 845
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    sh2add.uw a3, a1, a2
    li   t6, 0x123456789abcdff0
    beq  a3, t6, t845_ok
    j    fail
t845_ok:
t846: # sh2add.uw 0x21, 0xfffffffffffffff9
    li   a0, 846
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sh2add.uw a3, a1, a2
    li   t6, 0x7d
    beq  a3, t6, t846_ok
    j    fail
t846_ok:
t847: # sh3add.uw 0x0, 0x0
    li   a0, 847
    li   a1, 0x0
    li   a2, 0x0
    sh3add.uw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t847_ok
    j    fail
t847_ok:
t848: # sh3add.uw 0x1, 0x1
    li   a0, 848
    li   a1, 0x1
    li   a2, 0x1
    sh3add.uw a3, a1, a2
    li   t6, 0x9
    beq  a3, t6, t848_ok
    j    fail
t848_ok:
t849: # sh3add.uw 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 849
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x7fffffff7
    beq  a3, t6, t849_ok
    j    fail
t849_ok:
t850: # sh3add.uw 0x7, 0x7
    li   a0, 850
    li   a1, 0x7
    li   a2, 0x7
    sh3add.uw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t850_ok
    j    fail
t850_ok:
t851: # sh3add.uw 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 851
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    sh3add.uw a3, a1, a2
    li   t6, 0x7ffffffc1
    beq  a3, t6, t851_ok
    j    fail
t851_ok:
t852: # sh3add.uw 0x8000000000000000, 0x7
    li   a0, 852
    li   a1, 0x8000000000000000
    li   a2, 0x7
    sh3add.uw a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t852_ok
    j    fail
t852_ok:
t853: # sh3add.uw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 853
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x7fffffff7
    beq  a3, t6, t853_ok
    j    fail
t853_ok:
t854: # sh3add.uw 0x80000000, 0xffffffffffffffff
    li   a0, 854
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x3ffffffff
    beq  a3, t6, t854_ok
    j    fail
t854_ok:
t855: # sh3add.uw 0x7fffffff, 0xffffffffffffffff
    li   a0, 855
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x3fffffff7
    beq  a3, t6, t855_ok
    j    fail
t855_ok:
t856: # sh3add.uw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 856
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x3ffffffff
    beq  a3, t6, t856_ok
    j    fail
t856_ok:
t857: # sh3add.uw 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 857
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x4d5e6f77f
    beq  a3, t6, t857_ok
    j    fail
t857_ok:
t858: # sh3add.uw 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 858
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    sh3add.uw a3, a1, a2
    li   t6, 0x3b2a1907f
    beq  a3, t6, t858_ok
    j    fail
t858_ok:
t859: # sh3add.uw 0x3f, 0x8000000000000000
    li   a0, 859
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    sh3add.uw a3, a1, a2
    li   t6, 0x80000000000001f8
    beq  a3, t6, t859_ok
    j    fail
t859_ok:
t860: # sh3add.uw 0x40, 0x123456789abcdef0
    li   a0, 860
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    sh3add.uw a3, a1, a2
    li   t6, 0x123456789abce0f0
    beq  a3, t6, t860_ok
    j    fail
t860_ok:
t861: # sh3add.uw 0x21, 0xfffffffffffffff9
    li   a0, 861
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    sh3add.uw a3, a1, a2
    li   t6, 0x101
    beq  a3, t6, t861_ok
    j    fail
t861_ok:
t862: # andn 0x0, 0x0
    li   a0, 862
    li   a1, 0x0
    li   a2, 0x0
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t862_ok
    j    fail
t862_ok:
t863: # andn 0x1, 0x1
    li   a0, 863
    li   a1, 0x1
    li   a2, 0x1
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t863_ok
    j    fail
t863_ok:
t864: # andn 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 864
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t864_ok
    j    fail
t864_ok:
t865: # andn 0x7, 0x7
    li   a0, 865
    li   a1, 0x7
    li   a2, 0x7
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t865_ok
    j    fail
t865_ok:
t866: # andn 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 866
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t866_ok
    j    fail
t866_ok:
t867: # andn 0x8000000000000000, 0x7
    li   a0, 867
    li   a1, 0x8000000000000000
    li   a2, 0x7
    andn a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t867_ok
    j    fail
t867_ok:
t868: # andn 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 868
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t868_ok
    j    fail
t868_ok:
t869: # andn 0x80000000, 0xffffffffffffffff
    li   a0, 869
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t869_ok
    j    fail
t869_ok:
t870: # andn 0x7fffffff, 0xffffffffffffffff
    li   a0, 870
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t870_ok
    j    fail
t870_ok:
t871: # andn 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 871
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t871_ok
    j    fail
t871_ok:
t872: # andn 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 872
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t872_ok
    j    fail
t872_ok:
t873: # andn 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 873
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t873_ok
    j    fail
t873_ok:
t874: # andn 0x3f, 0x8000000000000000
    li   a0, 874
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    andn a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t874_ok
    j    fail
t874_ok:
t875: # andn 0x40, 0x123456789abcdef0
    li   a0, 875
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t875_ok
    j    fail
t875_ok:
t876: # andn 0x21, 0xfffffffffffffff9
    li   a0, 876
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    andn a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t876_ok
    j    fail
t876_ok:
t877: # orn 0x0, 0x0
    li   a0, 877
    li   a1, 0x0
    li   a2, 0x0
    orn a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t877_ok
    j    fail
t877_ok:
t878: # orn 0x1, 0x1
    li   a0, 878
    li   a1, 0x1
    li   a2, 0x1
    orn a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t878_ok
    j    fail
t878_ok:
t879: # orn 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 879
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t879_ok
    j    fail
t879_ok:
t880: # orn 0x7, 0x7
    li   a0, 880
    li   a1, 0x7
    li   a2, 0x7
    orn a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t880_ok
    j    fail
t880_ok:
t881: # orn 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 881
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    orn a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t881_ok
    j    fail
t881_ok:
t882: # orn 0x8000000000000000, 0x7
    li   a0, 882
    li   a1, 0x8000000000000000
    li   a2, 0x7
    orn a3, a1, a2
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t882_ok
    j    fail
t882_ok:
t883: # orn 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 883
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t883_ok
    j    fail
t883_ok:
t884: # orn 0x80000000, 0xffffffffffffffff
    li   a0, 884
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t884_ok
    j    fail
t884_ok:
t885: # orn 0x7fffffff, 0xffffffffffffffff
    li   a0, 885
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t885_ok
    j    fail
t885_ok:
t886: # orn 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 886
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t886_ok
    j    fail
t886_ok:
t887: # orn 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 887
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t887_ok
    j    fail
t887_ok:
t888: # orn 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 888
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    orn a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t888_ok
    j    fail
t888_ok:
t889: # orn 0x3f, 0x8000000000000000
    li   a0, 889
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    orn a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t889_ok
    j    fail
t889_ok:
t890: # orn 0x40, 0x123456789abcdef0
    li   a0, 890
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    orn a3, a1, a2
    li   t6, 0xedcba9876543214f
    beq  a3, t6, t890_ok
    j    fail
t890_ok:
t891: # orn 0x21, 0xfffffffffffffff9
    li   a0, 891
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    orn a3, a1, a2
    li   t6, 0x27
    beq  a3, t6, t891_ok
    j    fail
t891_ok:
t892: # xnor 0x0, 0x0
    li   a0, 892
    li   a1, 0x0
    li   a2, 0x0
    xnor a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t892_ok
    j    fail
t892_ok:
t893: # xnor 0x1, 0x1
    li   a0, 893
    li   a1, 0x1
    li   a2, 0x1
    xnor a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t893_ok
    j    fail
t893_ok:
t894: # xnor 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 894
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t894_ok
    j    fail
t894_ok:
t895: # xnor 0x7, 0x7
    li   a0, 895
    li   a1, 0x7
    li   a2, 0x7
    xnor a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t895_ok
    j    fail
t895_ok:
t896: # xnor 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 896
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    xnor a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t896_ok
    j    fail
t896_ok:
t897: # xnor 0x8000000000000000, 0x7
    li   a0, 897
    li   a1, 0x8000000000000000
    li   a2, 0x7
    xnor a3, a1, a2
    li   t6, 0x7ffffffffffffff8
    beq  a3, t6, t897_ok
    j    fail
t897_ok:
t898: # xnor 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 898
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t898_ok
    j    fail
t898_ok:
t899: # xnor 0x80000000, 0xffffffffffffffff
    li   a0, 899
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t899_ok
    j    fail
t899_ok:
t900: # xnor 0x7fffffff, 0xffffffffffffffff
    li   a0, 900
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t900_ok
    j    fail
t900_ok:
t901: # xnor 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 901
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t901_ok
    j    fail
t901_ok:
t902: # xnor 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 902
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t902_ok
    j    fail
t902_ok:
t903: # xnor 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 903
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    xnor a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t903_ok
    j    fail
t903_ok:
t904: # xnor 0x3f, 0x8000000000000000
    li   a0, 904
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    xnor a3, a1, a2
    li   t6, 0x7fffffffffffffc0
    beq  a3, t6, t904_ok
    j    fail
t904_ok:
t905: # xnor 0x40, 0x123456789abcdef0
    li   a0, 905
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    xnor a3, a1, a2
    li   t6, 0xedcba9876543214f
    beq  a3, t6, t905_ok
    j    fail
t905_ok:
t906: # xnor 0x21, 0xfffffffffffffff9
    li   a0, 906
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    xnor a3, a1, a2
    li   t6, 0x27
    beq  a3, t6, t906_ok
    j    fail
t906_ok:
t907: # min 0x0, 0x0
    li   a0, 907
    li   a1, 0x0
    li   a2, 0x0
    min a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t907_ok
    j    fail
t907_ok:
t908: # min 0x1, 0x1
    li   a0, 908
    li   a1, 0x1
    li   a2, 0x1
    min a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t908_ok
    j    fail
t908_ok:
t909: # min 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 909
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t909_ok
    j    fail
t909_ok:
t910: # min 0x7, 0x7
    li   a0, 910
    li   a1, 0x7
    li   a2, 0x7
    min a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t910_ok
    j    fail
t910_ok:
t911: # min 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 911
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    min a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t911_ok
    j    fail
t911_ok:
t912: # min 0x8000000000000000, 0x7
    li   a0, 912
    li   a1, 0x8000000000000000
    li   a2, 0x7
    min a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t912_ok
    j    fail
t912_ok:
t913: # min 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 913
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t913_ok
    j    fail
t913_ok:
t914: # min 0x80000000, 0xffffffffffffffff
    li   a0, 914
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t914_ok
    j    fail
t914_ok:
t915: # min 0x7fffffff, 0xffffffffffffffff
    li   a0, 915
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t915_ok
    j    fail
t915_ok:
t916: # min 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 916
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t916_ok
    j    fail
t916_ok:
t917: # min 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 917
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t917_ok
    j    fail
t917_ok:
t918: # min 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 918
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    min a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t918_ok
    j    fail
t918_ok:
t919: # min 0x3f, 0x8000000000000000
    li   a0, 919
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    min a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t919_ok
    j    fail
t919_ok:
t920: # min 0x40, 0x123456789abcdef0
    li   a0, 920
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    min a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t920_ok
    j    fail
t920_ok:
t921: # min 0x21, 0xfffffffffffffff9
    li   a0, 921
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    min a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t921_ok
    j    fail
t921_ok:
t922: # minu 0x0, 0x0
    li   a0, 922
    li   a1, 0x0
    li   a2, 0x0
    minu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t922_ok
    j    fail
t922_ok:
t923: # minu 0x1, 0x1
    li   a0, 923
    li   a1, 0x1
    li   a2, 0x1
    minu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t923_ok
    j    fail
t923_ok:
t924: # minu 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 924
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t924_ok
    j    fail
t924_ok:
t925: # minu 0x7, 0x7
    li   a0, 925
    li   a1, 0x7
    li   a2, 0x7
    minu a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t925_ok
    j    fail
t925_ok:
t926: # minu 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 926
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    minu a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t926_ok
    j    fail
t926_ok:
t927: # minu 0x8000000000000000, 0x7
    li   a0, 927
    li   a1, 0x8000000000000000
    li   a2, 0x7
    minu a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t927_ok
    j    fail
t927_ok:
t928: # minu 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 928
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t928_ok
    j    fail
t928_ok:
t929: # minu 0x80000000, 0xffffffffffffffff
    li   a0, 929
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t929_ok
    j    fail
t929_ok:
t930: # minu 0x7fffffff, 0xffffffffffffffff
    li   a0, 930
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t930_ok
    j    fail
t930_ok:
t931: # minu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 931
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t931_ok
    j    fail
t931_ok:
t932: # minu 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 932
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t932_ok
    j    fail
t932_ok:
t933: # minu 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 933
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    minu a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t933_ok
    j    fail
t933_ok:
t934: # minu 0x3f, 0x8000000000000000
    li   a0, 934
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    minu a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t934_ok
    j    fail
t934_ok:
t935: # minu 0x40, 0x123456789abcdef0
    li   a0, 935
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    minu a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t935_ok
    j    fail
t935_ok:
t936: # minu 0x21, 0xfffffffffffffff9
    li   a0, 936
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    minu a3, a1, a2
    li   t6, 0x21
    beq  a3, t6, t936_ok
    j    fail
t936_ok:
t937: # max 0x0, 0x0
    li   a0, 937
    li   a1, 0x0
    li   a2, 0x0
    max a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t937_ok
    j    fail
t937_ok:
t938: # max 0x1, 0x1
    li   a0, 938
    li   a1, 0x1
    li   a2, 0x1
    max a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t938_ok
    j    fail
t938_ok:
t939: # max 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 939
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t939_ok
    j    fail
t939_ok:
t940: # max 0x7, 0x7
    li   a0, 940
    li   a1, 0x7
    li   a2, 0x7
    max a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t940_ok
    j    fail
t940_ok:
t941: # max 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 941
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    max a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t941_ok
    j    fail
t941_ok:
t942: # max 0x8000000000000000, 0x7
    li   a0, 942
    li   a1, 0x8000000000000000
    li   a2, 0x7
    max a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t942_ok
    j    fail
t942_ok:
t943: # max 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 943
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t943_ok
    j    fail
t943_ok:
t944: # max 0x80000000, 0xffffffffffffffff
    li   a0, 944
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t944_ok
    j    fail
t944_ok:
t945: # max 0x7fffffff, 0xffffffffffffffff
    li   a0, 945
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t945_ok
    j    fail
t945_ok:
t946: # max 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 946
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t946_ok
    j    fail
t946_ok:
t947: # max 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 947
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t947_ok
    j    fail
t947_ok:
t948: # max 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 948
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    max a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t948_ok
    j    fail
t948_ok:
t949: # max 0x3f, 0x8000000000000000
    li   a0, 949
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    max a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t949_ok
    j    fail
t949_ok:
t950: # max 0x40, 0x123456789abcdef0
    li   a0, 950
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    max a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t950_ok
    j    fail
t950_ok:
t951: # max 0x21, 0xfffffffffffffff9
    li   a0, 951
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    max a3, a1, a2
    li   t6, 0x21
    beq  a3, t6, t951_ok
    j    fail
t951_ok:
t952: # maxu 0x0, 0x0
    li   a0, 952
    li   a1, 0x0
    li   a2, 0x0
    maxu a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t952_ok
    j    fail
t952_ok:
t953: # maxu 0x1, 0x1
    li   a0, 953
    li   a1, 0x1
    li   a2, 0x1
    maxu a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t953_ok
    j    fail
t953_ok:
t954: # maxu 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 954
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t954_ok
    j    fail
t954_ok:
t955: # maxu 0x7, 0x7
    li   a0, 955
    li   a1, 0x7
    li   a2, 0x7
    maxu a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t955_ok
    j    fail
t955_ok:
t956: # maxu 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 956
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    maxu a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t956_ok
    j    fail
t956_ok:
t957: # maxu 0x8000000000000000, 0x7
    li   a0, 957
    li   a1, 0x8000000000000000
    li   a2, 0x7
    maxu a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t957_ok
    j    fail
t957_ok:
t958: # maxu 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 958
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t958_ok
    j    fail
t958_ok:
t959: # maxu 0x80000000, 0xffffffffffffffff
    li   a0, 959
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t959_ok
    j    fail
t959_ok:
t960: # maxu 0x7fffffff, 0xffffffffffffffff
    li   a0, 960
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t960_ok
    j    fail
t960_ok:
t961: # maxu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 961
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t961_ok
    j    fail
t961_ok:
t962: # maxu 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 962
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t962_ok
    j    fail
t962_ok:
t963: # maxu 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 963
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    maxu a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t963_ok
    j    fail
t963_ok:
t964: # maxu 0x3f, 0x8000000000000000
    li   a0, 964
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    maxu a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t964_ok
    j    fail
t964_ok:
t965: # maxu 0x40, 0x123456789abcdef0
    li   a0, 965
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    maxu a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t965_ok
    j    fail
t965_ok:
t966: # maxu 0x21, 0xfffffffffffffff9
    li   a0, 966
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    maxu a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t966_ok
    j    fail
t966_ok:
t967: # rol 0x0, 0x0
    li   a0, 967
    li   a1, 0x0
    li   a2, 0x0
    rol a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t967_ok
    j    fail
t967_ok:
t968: # rol 0x1, 0x1
    li   a0, 968
    li   a1, 0x1
    li   a2, 0x1
    rol a3, a1, a2
    li   t6, 0x2
    beq  a3, t6, t968_ok
    j    fail
t968_ok:
t969: # rol 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 969
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t969_ok
    j    fail
t969_ok:
t970: # rol 0x7, 0x7
    li   a0, 970
    li   a1, 0x7
    li   a2, 0x7
    rol a3, a1, a2
    li   t6, 0x380
    beq  a3, t6, t970_ok
    j    fail
t970_ok:
t971: # rol 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 971
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    rol a3, a1, a2
    li   t6, 0xf3ffffffffffffff
    beq  a3, t6, t971_ok
    j    fail
t971_ok:
t972: # rol 0x8000000000000000, 0x7
    li   a0, 972
    li   a1, 0x8000000000000000
    li   a2, 0x7
    rol a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t972_ok
    j    fail
t972_ok:
t973: # rol 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 973
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0xbfffffffffffffff
    beq  a3, t6, t973_ok
    j    fail
t973_ok:
t974: # rol 0x80000000, 0xffffffffffffffff
    li   a0, 974
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0x40000000
    beq  a3, t6, t974_ok
    j    fail
t974_ok:
t975: # rol 0x7fffffff, 0xffffffffffffffff
    li   a0, 975
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0x800000003fffffff
    beq  a3, t6, t975_ok
    j    fail
t975_ok:
t976: # rol 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 976
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0x7fffffffc0000000
    beq  a3, t6, t976_ok
    j    fail
t976_ok:
t977: # rol 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 977
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0x91a2b3c4d5e6f78
    beq  a3, t6, t977_ok
    j    fail
t977_ok:
t978: # rol 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 978
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    rol a3, a1, a2
    li   t6, 0x7f6e5d4c3b2a1908
    beq  a3, t6, t978_ok
    j    fail
t978_ok:
t979: # rol 0x3f, 0x8000000000000000
    li   a0, 979
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    rol a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t979_ok
    j    fail
t979_ok:
t980: # rol 0x40, 0x123456789abcdef0
    li   a0, 980
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    rol a3, a1, a2
    li   t6, 0x40000000000000
    beq  a3, t6, t980_ok
    j    fail
t980_ok:
t981: # rol 0x21, 0xfffffffffffffff9
    li   a0, 981
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    rol a3, a1, a2
    li   t6, 0x4200000000000000
    beq  a3, t6, t981_ok
    j    fail
t981_ok:
t982: # ror 0x0, 0x0
    li   a0, 982
    li   a1, 0x0
    li   a2, 0x0
    ror a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t982_ok
    j    fail
t982_ok:
t983: # ror 0x1, 0x1
    li   a0, 983
    li   a1, 0x1
    li   a2, 0x1
    ror a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t983_ok
    j    fail
t983_ok:
t984: # ror 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 984
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t984_ok
    j    fail
t984_ok:
t985: # ror 0x7, 0x7
    li   a0, 985
    li   a1, 0x7
    li   a2, 0x7
    ror a3, a1, a2
    li   t6, 0xe00000000000000
    beq  a3, t6, t985_ok
    j    fail
t985_ok:
t986: # ror 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 986
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    ror a3, a1, a2
    li   t6, 0xfffffffffffffcff
    beq  a3, t6, t986_ok
    j    fail
t986_ok:
t987: # ror 0x8000000000000000, 0x7
    li   a0, 987
    li   a1, 0x8000000000000000
    li   a2, 0x7
    ror a3, a1, a2
    li   t6, 0x100000000000000
    beq  a3, t6, t987_ok
    j    fail
t987_ok:
t988: # ror 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 988
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0xfffffffffffffffe
    beq  a3, t6, t988_ok
    j    fail
t988_ok:
t989: # ror 0x80000000, 0xffffffffffffffff
    li   a0, 989
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0x100000000
    beq  a3, t6, t989_ok
    j    fail
t989_ok:
t990: # ror 0x7fffffff, 0xffffffffffffffff
    li   a0, 990
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0xfffffffe
    beq  a3, t6, t990_ok
    j    fail
t990_ok:
t991: # ror 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 991
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0xffffffff00000001
    beq  a3, t6, t991_ok
    j    fail
t991_ok:
t992: # ror 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 992
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0x2468acf13579bde0
    beq  a3, t6, t992_ok
    j    fail
t992_ok:
t993: # ror 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 993
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    ror a3, a1, a2
    li   t6, 0xfdb97530eca86421
    beq  a3, t6, t993_ok
    j    fail
t993_ok:
t994: # ror 0x3f, 0x8000000000000000
    li   a0, 994
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    ror a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t994_ok
    j    fail
t994_ok:
t995: # ror 0x40, 0x123456789abcdef0
    li   a0, 995
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    ror a3, a1, a2
    li   t6, 0x400000
    beq  a3, t6, t995_ok
    j    fail
t995_ok:
t996: # ror 0x21, 0xfffffffffffffff9
    li   a0, 996
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    ror a3, a1, a2
    li   t6, 0x1080
    beq  a3, t6, t996_ok
    j    fail
t996_ok:
t997: # rolw 0x0, 0x0
    li   a0, 997
    li   a1, 0x0
    li   a2, 0x0
    rolw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t997_ok
    j    fail
t997_ok:
t998: # rolw 0x1, 0x1
    li   a0, 998
    li   a1, 0x1
    li   a2, 0x1
    rolw a3, a1, a2
    li   t6, 0x2
    beq  a3, t6, t998_ok
    j    fail
t998_ok:
t999: # rolw 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 999
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t999_ok
    j    fail
t999_ok:
t1000: # rolw 0x7, 0x7
    li   a0, 1000
    li   a1, 0x7
    li   a2, 0x7
    rolw a3, a1, a2
    li   t6, 0x380
    beq  a3, t6, t1000_ok
    j    fail
t1000_ok:
t1001: # rolw 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 1001
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    rolw a3, a1, a2
    li   t6, 0xfffffffff3ffffff
    beq  a3, t6, t1001_ok
    j    fail
t1001_ok:
t1002: # rolw 0x8000000000000000, 0x7
    li   a0, 1002
    li   a1, 0x8000000000000000
    li   a2, 0x7
    rolw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1002_ok
    j    fail
t1002_ok:
t1003: # rolw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 1003
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1003_ok
    j    fail
t1003_ok:
t1004: # rolw 0x80000000, 0xffffffffffffffff
    li   a0, 1004
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0x40000000
    beq  a3, t6, t1004_ok
    j    fail
t1004_ok:
t1005: # rolw 0x7fffffff, 0xffffffffffffffff
    li   a0, 1005
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0xffffffffbfffffff
    beq  a3, t6, t1005_ok
    j    fail
t1005_ok:
t1006: # rolw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1006
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0x40000000
    beq  a3, t6, t1006_ok
    j    fail
t1006_ok:
t1007: # rolw 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 1007
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0x4d5e6f78
    beq  a3, t6, t1007_ok
    j    fail
t1007_ok:
t1008: # rolw 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 1008
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    rolw a3, a1, a2
    li   t6, 0x3b2a1908
    beq  a3, t6, t1008_ok
    j    fail
t1008_ok:
t1009: # rolw 0x3f, 0x8000000000000000
    li   a0, 1009
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    rolw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t1009_ok
    j    fail
t1009_ok:
t1010: # rolw 0x40, 0x123456789abcdef0
    li   a0, 1010
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    rolw a3, a1, a2
    li   t6, 0x400000
    beq  a3, t6, t1010_ok
    j    fail
t1010_ok:
t1011: # rolw 0x21, 0xfffffffffffffff9
    li   a0, 1011
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    rolw a3, a1, a2
    li   t6, 0x42000000
    beq  a3, t6, t1011_ok
    j    fail
t1011_ok:
t1012: # rorw 0x0, 0x0
    li   a0, 1012
    li   a1, 0x0
    li   a2, 0x0
    rorw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1012_ok
    j    fail
t1012_ok:
t1013: # rorw 0x1, 0x1
    li   a0, 1013
    li   a1, 0x1
    li   a2, 0x1
    rorw a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1013_ok
    j    fail
t1013_ok:
t1014: # rorw 0xffffffffffffffff, 0xffffffffffffffff
    li   a0, 1014
    li   a1, 0xffffffffffffffff
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1014_ok
    j    fail
t1014_ok:
t1015: # rorw 0x7, 0x7
    li   a0, 1015
    li   a1, 0x7
    li   a2, 0x7
    rorw a3, a1, a2
    li   t6, 0xe000000
    beq  a3, t6, t1015_ok
    j    fail
t1015_ok:
t1016: # rorw 0xfffffffffffffff9, 0xfffffffffffffff9
    li   a0, 1016
    li   a1, 0xfffffffffffffff9
    li   a2, 0xfffffffffffffff9
    rorw a3, a1, a2
    li   t6, 0xfffffffffffffcff
    beq  a3, t6, t1016_ok
    j    fail
t1016_ok:
t1017: # rorw 0x8000000000000000, 0x7
    li   a0, 1017
    li   a1, 0x8000000000000000
    li   a2, 0x7
    rorw a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1017_ok
    j    fail
t1017_ok:
t1018: # rorw 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 1018
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1018_ok
    j    fail
t1018_ok:
t1019: # rorw 0x80000000, 0xffffffffffffffff
    li   a0, 1019
    li   a1, 0x80000000
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1019_ok
    j    fail
t1019_ok:
t1020: # rorw 0x7fffffff, 0xffffffffffffffff
    li   a0, 1020
    li   a1, 0x7fffffff
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0xfffffffffffffffe
    beq  a3, t6, t1020_ok
    j    fail
t1020_ok:
t1021: # rorw 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1021
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1021_ok
    j    fail
t1021_ok:
t1022: # rorw 0x123456789abcdef0, 0xffffffffffffffff
    li   a0, 1022
    li   a1, 0x123456789abcdef0
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0x3579bde1
    beq  a3, t6, t1022_ok
    j    fail
t1022_ok:
t1023: # rorw 0xfedcba9876543210, 0xffffffffffffffff
    li   a0, 1023
    li   a1, 0xfedcba9876543210
    li   a2, 0xffffffffffffffff
    rorw a3, a1, a2
    li   t6, 0xffffffffeca86420
    beq  a3, t6, t1023_ok
    j    fail
t1023_ok:
t1024: # rorw 0x3f, 0x8000000000000000
    li   a0, 1024
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    rorw a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t1024_ok
    j    fail
t1024_ok:
t1025: # rorw 0x40, 0x123456789abcdef0
    li   a0, 1025
    li   a1, 0x40
    li   a2, 0x123456789abcdef0
    rorw a3, a1, a2
    li   t6, 0x400000
    beq  a3, t6, t1025_ok
    j    fail
t1025_ok:
t1026: # rorw 0x21, 0xfffffffffffffff9
    li   a0, 1026
    li   a1, 0x21
    li   a2, 0xfffffffffffffff9
    rorw a3, a1, a2
    li   t6, 0x1080
    beq  a3, t6, t1026_ok
    j    fail
t1026_ok:
t1027: # bset 0x0, 0x0
    li   a0, 1027
    li   a1, 0x0
    li   a2, 0x0
    bset a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1027_ok
    j    fail
t1027_ok:
t1028: # bset 0x0, 0xfedcba9876543210
    li   a0, 1028
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    bset a3, a1, a2
    li   t6, 0x10000
    beq  a3, t6, t1028_ok
    j    fail
t1028_ok:
t1029: # bset 0x1, 0xffffffffffffffff
    li   a0, 1029
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    bset a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t1029_ok
    j    fail
t1029_ok:
t1030: # bset 0xffffffffffffffff, 0x1
    li   a0, 1030
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    bset a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1030_ok
    j    fail
t1030_ok:
t1031: # bset 0x7, 0x0
    li   a0, 1031
    li   a1, 0x7
    li   a2, 0x0
    bset a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t1031_ok
    j    fail
t1031_ok:
t1032: # bset 0x7, 0x7
    li   a0, 1032
    li   a1, 0x7
    li   a2, 0x7
    bset a3, a1, a2
    li   t6, 0x87
    beq  a3, t6, t1032_ok
    j    fail
t1032_ok:
t1033: # bset 0xfffffffffffffff9, 0x1
    li   a0, 1033
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    bset a3, a1, a2
    li   t6, 0xfffffffffffffffb
    beq  a3, t6, t1033_ok
    j    fail
t1033_ok:
t1034: # bset 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 1034
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    bset a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t1034_ok
    j    fail
t1034_ok:
t1035: # bset 0x8000000000000000, 0xffffffffffffffff
    li   a0, 1035
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    bset a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t1035_ok
    j    fail
t1035_ok:
t1036: # bset 0x8000000000000000, 0x21
    li   a0, 1036
    li   a1, 0x8000000000000000
    li   a2, 0x21
    bset a3, a1, a2
    li   t6, 0x8000000200000000
    beq  a3, t6, t1036_ok
    j    fail
t1036_ok:
t1037: # bset 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 1037
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    bset a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1037_ok
    j    fail
t1037_ok:
t1038: # bset 0x80000000, 0x0
    li   a0, 1038
    li   a1, 0x80000000
    li   a2, 0x0
    bset a3, a1, a2
    li   t6, 0x80000001
    beq  a3, t6, t1038_ok
    j    fail
t1038_ok:
t1039: # bset 0x80000000, 0x80000000
    li   a0, 1039
    li   a1, 0x80000000
    li   a2, 0x80000000
    bset a3, a1, a2
    li   t6, 0x80000001
    beq  a3, t6, t1039_ok
    j    fail
t1039_ok:
t1040: # bset 0x7fffffff, 0x1
    li   a0, 1040
    li   a1, 0x7fffffff
    li   a2, 0x1
    bset a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t1040_ok
    j    fail
t1040_ok:
t1041: # bset 0x7fffffff, 0x7fffffff
    li   a0, 1041
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    bset a3, a1, a2
    li   t6, 0x800000007fffffff
    beq  a3, t6, t1041_ok
    j    fail
t1041_ok:
t1042: # bset 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1042
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    bset a3, a1, a2
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1042_ok
    j    fail
t1042_ok:
t1043: # bset 0x123456789abcdef0, 0x0
    li   a0, 1043
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    bset a3, a1, a2
    li   t6, 0x123456789abcdef1
    beq  a3, t6, t1043_ok
    j    fail
t1043_ok:
t1044: # bset 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 1044
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    bset a3, a1, a2
    li   t6, 0x923456789abcdef0
    beq  a3, t6, t1044_ok
    j    fail
t1044_ok:
t1045: # bset 0xfedcba9876543210, 0x1
    li   a0, 1045
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    bset a3, a1, a2
    li   t6, 0xfedcba9876543212
    beq  a3, t6, t1045_ok
    j    fail
t1045_ok:
t1046: # bset 0x3f, 0x0
    li   a0, 1046
    li   a1, 0x3f
    li   a2, 0x0
    bset a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t1046_ok
    j    fail
t1046_ok:
t1047: # bset 0x3f, 0x8000000000000000
    li   a0, 1047
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    bset a3, a1, a2
    li   t6, 0x3f
    beq  a3, t6, t1047_ok
    j    fail
t1047_ok:
t1048: # bset 0x40, 0x1
    li   a0, 1048
    li   a1, 0x40
    li   a2, 0x1
    bset a3, a1, a2
    li   t6, 0x42
    beq  a3, t6, t1048_ok
    j    fail
t1048_ok:
t1049: # bset 0x40, 0x40
    li   a0, 1049
    li   a1, 0x40
    li   a2, 0x40
    bset a3, a1, a2
    li   t6, 0x41
    beq  a3, t6, t1049_ok
    j    fail
t1049_ok:
t1050: # bset 0x21, 0xffffffffffffffff
    li   a0, 1050
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    bset a3, a1, a2
    li   t6, 0x8000000000000021
    beq  a3, t6, t1050_ok
    j    fail
t1050_ok:
t1051: # bclr 0x0, 0x0
    li   a0, 1051
    li   a1, 0x0
    li   a2, 0x0
    bclr a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1051_ok
    j    fail
t1051_ok:
t1052: # bclr 0x0, 0xfedcba9876543210
    li   a0, 1052
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    bclr a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1052_ok
    j    fail
t1052_ok:
t1053: # bclr 0x1, 0xffffffffffffffff
    li   a0, 1053
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    bclr a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1053_ok
    j    fail
t1053_ok:
t1054: # bclr 0xffffffffffffffff, 0x1
    li   a0, 1054
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    bclr a3, a1, a2
    li   t6, 0xfffffffffffffffd
    beq  a3, t6, t1054_ok
    j    fail
t1054_ok:
t1055: # bclr 0x7, 0x0
    li   a0, 1055
    li   a1, 0x7
    li   a2, 0x0
    bclr a3, a1, a2
    li   t6, 0x6
    beq  a3, t6, t1055_ok
    j    fail
t1055_ok:
t1056: # bclr 0x7, 0x7
    li   a0, 1056
    li   a1, 0x7
    li   a2, 0x7
    bclr a3, a1, a2
    li   t6, 0x7
    beq  a3, t6, t1056_ok
    j    fail
t1056_ok:
t1057: # bclr 0xfffffffffffffff9, 0x1
    li   a0, 1057
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    bclr a3, a1, a2
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t1057_ok
    j    fail
t1057_ok:
t1058: # bclr 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 1058
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    bclr a3, a1, a2
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t1058_ok
    j    fail
t1058_ok:
t1059: # bclr 0x8000000000000000, 0xffffffffffffffff
    li   a0, 1059
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    bclr a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1059_ok
    j    fail
t1059_ok:
t1060: # bclr 0x8000000000000000, 0x21
    li   a0, 1060
    li   a1, 0x8000000000000000
    li   a2, 0x21
    bclr a3, a1, a2
    li   t6, 0x8000000000000000
    beq  a3, t6, t1060_ok
    j    fail
t1060_ok:
t1061: # bclr 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 1061
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    bclr a3, a1, a2
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1061_ok
    j    fail
t1061_ok:
t1062: # bclr 0x80000000, 0x0
    li   a0, 1062
    li   a1, 0x80000000
    li   a2, 0x0
    bclr a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t1062_ok
    j    fail
t1062_ok:
t1063: # bclr 0x80000000, 0x80000000
    li   a0, 1063
    li   a1, 0x80000000
    li   a2, 0x80000000
    bclr a3, a1, a2
    li   t6, 0x80000000
    beq  a3, t6, t1063_ok
    j    fail
t1063_ok:
t1064: # bclr 0x7fffffff, 0x1
    li   a0, 1064
    li   a1, 0x7fffffff
    li   a2, 0x1
    bclr a3, a1, a2
    li   t6, 0x7ffffffd
    beq  a3, t6, t1064_ok
    j    fail
t1064_ok:
t1065: # bclr 0x7fffffff, 0x7fffffff
    li   a0, 1065
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    bclr a3, a1, a2
    li   t6, 0x7fffffff
    beq  a3, t6, t1065_ok
    j    fail
t1065_ok:
t1066: # bclr 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1066
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    bclr a3, a1, a2
    li   t6, 0x7fffffff80000000
    beq  a3, t6, t1066_ok
    j    fail
t1066_ok:
t1067: # bclr 0x123456789abcdef0, 0x0
    li   a0, 1067
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    bclr a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t1067_ok
    j    fail
t1067_ok:
t1068: # bclr 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 1068
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    bclr a3, a1, a2
    li   t6, 0x123456789abcdef0
    beq  a3, t6, t1068_ok
    j    fail
t1068_ok:
t1069: # bclr 0xfedcba9876543210, 0x1
    li   a0, 1069
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    bclr a3, a1, a2
    li   t6, 0xfedcba9876543210
    beq  a3, t6, t1069_ok
    j    fail
t1069_ok:
t1070: # bclr 0x3f, 0x0
    li   a0, 1070
    li   a1, 0x3f
    li   a2, 0x0
    bclr a3, a1, a2
    li   t6, 0x3e
    beq  a3, t6, t1070_ok
    j    fail
t1070_ok:
t1071: # bclr 0x3f, 0x8000000000000000
    li   a0, 1071
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    bclr a3, a1, a2
    li   t6, 0x3e
    beq  a3, t6, t1071_ok
    j    fail
t1071_ok:
t1072: # bclr 0x40, 0x1
    li   a0, 1072
    li   a1, 0x40
    li   a2, 0x1
    bclr a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t1072_ok
    j    fail
t1072_ok:
t1073: # bclr 0x40, 0x40
    li   a0, 1073
    li   a1, 0x40
    li   a2, 0x40
    bclr a3, a1, a2
    li   t6, 0x40
    beq  a3, t6, t1073_ok
    j    fail
t1073_ok:
t1074: # bclr 0x21, 0xffffffffffffffff
    li   a0, 1074
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    bclr a3, a1, a2
    li   t6, 0x21
    beq  a3, t6, t1074_ok
    j    fail
t1074_ok:
t1075: # binv 0x0, 0x0
    li   a0, 1075
    li   a1, 0x0
    li   a2, 0x0
    binv a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1075_ok
    j    fail
t1075_ok:
t1076: # binv 0x0, 0xfedcba9876543210
    li   a0, 1076
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    binv a3, a1, a2
    li   t6, 0x10000
    beq  a3, t6, t1076_ok
    j    fail
t1076_ok:
t1077: # binv 0x1, 0xffffffffffffffff
    li   a0, 1077
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    binv a3, a1, a2
    li   t6, 0x8000000000000001
    beq  a3, t6, t1077_ok
    j    fail
t1077_ok:
t1078: # binv 0xffffffffffffffff, 0x1
    li   a0, 1078
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    binv a3, a1, a2
    li   t6, 0xfffffffffffffffd
    beq  a3, t6, t1078_ok
    j    fail
t1078_ok:
t1079: # binv 0x7, 0x0
    li   a0, 1079
    li   a1, 0x7
    li   a2, 0x0
    binv a3, a1, a2
    li   t6, 0x6
    beq  a3, t6, t1079_ok
    j    fail
t1079_ok:
t1080: # binv 0x7, 0x7
    li   a0, 1080
    li   a1, 0x7
    li   a2, 0x7
    binv a3, a1, a2
    li   t6, 0x87
    beq  a3, t6, t1080_ok
    j    fail
t1080_ok:
t1081: # binv 0xfffffffffffffff9, 0x1
    li   a0, 1081
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    binv a3, a1, a2
    li   t6, 0xfffffffffffffffb
    beq  a3, t6, t1081_ok
    j    fail
t1081_ok:
t1082: # binv 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 1082
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    binv a3, a1, a2
    li   t6, 0xfffffffffffffff8
    beq  a3, t6, t1082_ok
    j    fail
t1082_ok:
t1083: # binv 0x8000000000000000, 0xffffffffffffffff
    li   a0, 1083
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    binv a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1083_ok
    j    fail
t1083_ok:
t1084: # binv 0x8000000000000000, 0x21
    li   a0, 1084
    li   a1, 0x8000000000000000
    li   a2, 0x21
    binv a3, a1, a2
    li   t6, 0x8000000200000000
    beq  a3, t6, t1084_ok
    j    fail
t1084_ok:
t1085: # binv 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 1085
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    binv a3, a1, a2
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1085_ok
    j    fail
t1085_ok:
t1086: # binv 0x80000000, 0x0
    li   a0, 1086
    li   a1, 0x80000000
    li   a2, 0x0
    binv a3, a1, a2
    li   t6, 0x80000001
    beq  a3, t6, t1086_ok
    j    fail
t1086_ok:
t1087: # binv 0x80000000, 0x80000000
    li   a0, 1087
    li   a1, 0x80000000
    li   a2, 0x80000000
    binv a3, a1, a2
    li   t6, 0x80000001
    beq  a3, t6, t1087_ok
    j    fail
t1087_ok:
t1088: # binv 0x7fffffff, 0x1
    li   a0, 1088
    li   a1, 0x7fffffff
    li   a2, 0x1
    binv a3, a1, a2
    li   t6, 0x7ffffffd
    beq  a3, t6, t1088_ok
    j    fail
t1088_ok:
t1089: # binv 0x7fffffff, 0x7fffffff
    li   a0, 1089
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    binv a3, a1, a2
    li   t6, 0x800000007fffffff
    beq  a3, t6, t1089_ok
    j    fail
t1089_ok:
t1090: # binv 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1090
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    binv a3, a1, a2
    li   t6, 0x7fffffff80000000
    beq  a3, t6, t1090_ok
    j    fail
t1090_ok:
t1091: # binv 0x123456789abcdef0, 0x0
    li   a0, 1091
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    binv a3, a1, a2
    li   t6, 0x123456789abcdef1
    beq  a3, t6, t1091_ok
    j    fail
t1091_ok:
t1092: # binv 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 1092
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    binv a3, a1, a2
    li   t6, 0x923456789abcdef0
    beq  a3, t6, t1092_ok
    j    fail
t1092_ok:
t1093: # binv 0xfedcba9876543210, 0x1
    li   a0, 1093
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    binv a3, a1, a2
    li   t6, 0xfedcba9876543212
    beq  a3, t6, t1093_ok
    j    fail
t1093_ok:
t1094: # binv 0x3f, 0x0
    li   a0, 1094
    li   a1, 0x3f
    li   a2, 0x0
    binv a3, a1, a2
    li   t6, 0x3e
    beq  a3, t6, t1094_ok
    j    fail
t1094_ok:
t1095: # binv 0x3f, 0x8000000000000000
    li   a0, 1095
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    binv a3, a1, a2
    li   t6, 0x3e
    beq  a3, t6, t1095_ok
    j    fail
t1095_ok:
t1096: # binv 0x40, 0x1
    li   a0, 1096
    li   a1, 0x40
    li   a2, 0x1
    binv a3, a1, a2
    li   t6, 0x42
    beq  a3, t6, t1096_ok
    j    fail
t1096_ok:
t1097: # binv 0x40, 0x40
    li   a0, 1097
    li   a1, 0x40
    li   a2, 0x40
    binv a3, a1, a2
    li   t6, 0x41
    beq  a3, t6, t1097_ok
    j    fail
t1097_ok:
t1098: # binv 0x21, 0xffffffffffffffff
    li   a0, 1098
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    binv a3, a1, a2
    li   t6, 0x8000000000000021
    beq  a3, t6, t1098_ok
    j    fail
t1098_ok:
t1099: # bext 0x0, 0x0
    li   a0, 1099
    li   a1, 0x0
    li   a2, 0x0
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1099_ok
    j    fail
t1099_ok:
t1100: # bext 0x0, 0xfedcba9876543210
    li   a0, 1100
    li   a1, 0x0
    li   a2, 0xfedcba9876543210
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1100_ok
    j    fail
t1100_ok:
t1101: # bext 0x1, 0xffffffffffffffff
    li   a0, 1101
    li   a1, 0x1
    li   a2, 0xffffffffffffffff
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1101_ok
    j    fail
t1101_ok:
t1102: # bext 0xffffffffffffffff, 0x1
    li   a0, 1102
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1102_ok
    j    fail
t1102_ok:
t1103: # bext 0x7, 0x0
    li   a0, 1103
    li   a1, 0x7
    li   a2, 0x0
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1103_ok
    j    fail
t1103_ok:
t1104: # bext 0x7, 0x7
    li   a0, 1104
    li   a1, 0x7
    li   a2, 0x7
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1104_ok
    j    fail
t1104_ok:
t1105: # bext 0xfffffffffffffff9, 0x1
    li   a0, 1105
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1105_ok
    j    fail
t1105_ok:
t1106: # bext 0xfffffffffffffff9, 0xffffffff80000000
    li   a0, 1106
    li   a1, 0xfffffffffffffff9
    li   a2, 0xffffffff80000000
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1106_ok
    j    fail
t1106_ok:
t1107: # bext 0x8000000000000000, 0xffffffffffffffff
    li   a0, 1107
    li   a1, 0x8000000000000000
    li   a2, 0xffffffffffffffff
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1107_ok
    j    fail
t1107_ok:
t1108: # bext 0x8000000000000000, 0x21
    li   a0, 1108
    li   a1, 0x8000000000000000
    li   a2, 0x21
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1108_ok
    j    fail
t1108_ok:
t1109: # bext 0x7fffffffffffffff, 0xffffffffffffffff
    li   a0, 1109
    li   a1, 0x7fffffffffffffff
    li   a2, 0xffffffffffffffff
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1109_ok
    j    fail
t1109_ok:
t1110: # bext 0x80000000, 0x0
    li   a0, 1110
    li   a1, 0x80000000
    li   a2, 0x0
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1110_ok
    j    fail
t1110_ok:
t1111: # bext 0x80000000, 0x80000000
    li   a0, 1111
    li   a1, 0x80000000
    li   a2, 0x80000000
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1111_ok
    j    fail
t1111_ok:
t1112: # bext 0x7fffffff, 0x1
    li   a0, 1112
    li   a1, 0x7fffffff
    li   a2, 0x1
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1112_ok
    j    fail
t1112_ok:
t1113: # bext 0x7fffffff, 0x7fffffff
    li   a0, 1113
    li   a1, 0x7fffffff
    li   a2, 0x7fffffff
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1113_ok
    j    fail
t1113_ok:
t1114: # bext 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1114
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1114_ok
    j    fail
t1114_ok:
t1115: # bext 0x123456789abcdef0, 0x0
    li   a0, 1115
    li   a1, 0x123456789abcdef0
    li   a2, 0x0
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1115_ok
    j    fail
t1115_ok:
t1116: # bext 0x123456789abcdef0, 0x7fffffffffffffff
    li   a0, 1116
    li   a1, 0x123456789abcdef0
    li   a2, 0x7fffffffffffffff
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1116_ok
    j    fail
t1116_ok:
t1117: # bext 0xfedcba9876543210, 0x1
    li   a0, 1117
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1117_ok
    j    fail
t1117_ok:
t1118: # bext 0x3f, 0x0
    li   a0, 1118
    li   a1, 0x3f
    li   a2, 0x0
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1118_ok
    j    fail
t1118_ok:
t1119: # bext 0x3f, 0x8000000000000000
    li   a0, 1119
    li   a1, 0x3f
    li   a2, 0x8000000000000000
    bext a3, a1, a2
    li   t6, 0x1
    beq  a3, t6, t1119_ok
    j    fail
t1119_ok:
t1120: # bext 0x40, 0x1
    li   a0, 1120
    li   a1, 0x40
    li   a2, 0x1
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1120_ok
    j    fail
t1120_ok:
t1121: # bext 0x40, 0x40
    li   a0, 1121
    li   a1, 0x40
    li   a2, 0x40
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1121_ok
    j    fail
t1121_ok:
t1122: # bext 0x21, 0xffffffffffffffff
    li   a0, 1122
    li   a1, 0x21
    li   a2, 0xffffffffffffffff
    bext a3, a1, a2
    li   t6, 0x0
    beq  a3, t6, t1122_ok
    j    fail
t1122_ok:
t1123: # slli.uw 0x0, 0
    li   a0, 1123
    li   a1, 0x0
    slli.uw a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t1123_ok
    j    fail
t1123_ok:
t1124: # slli.uw 0x0, 1
    li   a0, 1124
    li   a1, 0x0
    slli.uw a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t1124_ok
    j    fail
t1124_ok:
t1125: # slli.uw 0x0, 13
    li   a0, 1125
    li   a1, 0x0
    slli.uw a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1125_ok
    j    fail
t1125_ok:
t1126: # slli.uw 0x0, 32
    li   a0, 1126
    li   a1, 0x0
    slli.uw a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t1126_ok
    j    fail
t1126_ok:
t1127: # slli.uw 0x0, 63
    li   a0, 1127
    li   a1, 0x0
    slli.uw a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1127_ok
    j    fail
t1127_ok:
t1128: # slli.uw 0x7, 0
    li   a0, 1128
    li   a1, 0x7
    slli.uw a3, a1, 0
    li   t6, 0x7
    beq  a3, t6, t1128_ok
    j    fail
t1128_ok:
t1129: # slli.uw 0x7, 1
    li   a0, 1129
    li   a1, 0x7
    slli.uw a3, a1, 1
    li   t6, 0xe
    beq  a3, t6, t1129_ok
    j    fail
t1129_ok:
t1130: # slli.uw 0x7, 13
    li   a0, 1130
    li   a1, 0x7
    slli.uw a3, a1, 13
    li   t6, 0xe000
    beq  a3, t6, t1130_ok
    j    fail
t1130_ok:
t1131: # slli.uw 0x7, 32
    li   a0, 1131
    li   a1, 0x7
    slli.uw a3, a1, 32
    li   t6, 0x700000000
    beq  a3, t6, t1131_ok
    j    fail
t1131_ok:
t1132: # slli.uw 0x7, 63
    li   a0, 1132
    li   a1, 0x7
    slli.uw a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t1132_ok
    j    fail
t1132_ok:
t1133: # slli.uw 0x7fffffffffffffff, 0
    li   a0, 1133
    li   a1, 0x7fffffffffffffff
    slli.uw a3, a1, 0
    li   t6, 0xffffffff
    beq  a3, t6, t1133_ok
    j    fail
t1133_ok:
t1134: # slli.uw 0x7fffffffffffffff, 1
    li   a0, 1134
    li   a1, 0x7fffffffffffffff
    slli.uw a3, a1, 1
    li   t6, 0x1fffffffe
    beq  a3, t6, t1134_ok
    j    fail
t1134_ok:
t1135: # slli.uw 0x7fffffffffffffff, 13
    li   a0, 1135
    li   a1, 0x7fffffffffffffff
    slli.uw a3, a1, 13
    li   t6, 0x1fffffffe000
    beq  a3, t6, t1135_ok
    j    fail
t1135_ok:
t1136: # slli.uw 0x7fffffffffffffff, 32
    li   a0, 1136
    li   a1, 0x7fffffffffffffff
    slli.uw a3, a1, 32
    li   t6, 0xffffffff00000000
    beq  a3, t6, t1136_ok
    j    fail
t1136_ok:
t1137: # slli.uw 0x7fffffffffffffff, 63
    li   a0, 1137
    li   a1, 0x7fffffffffffffff
    slli.uw a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t1137_ok
    j    fail
t1137_ok:
t1138: # slli.uw 0xffffffff80000000, 0
    li   a0, 1138
    li   a1, 0xffffffff80000000
    slli.uw a3, a1, 0
    li   t6, 0x80000000
    beq  a3, t6, t1138_ok
    j    fail
t1138_ok:
t1139: # slli.uw 0xffffffff80000000, 1
    li   a0, 1139
    li   a1, 0xffffffff80000000
    slli.uw a3, a1, 1
    li   t6, 0x100000000
    beq  a3, t6, t1139_ok
    j    fail
t1139_ok:
t1140: # slli.uw 0xffffffff80000000, 13
    li   a0, 1140
    li   a1, 0xffffffff80000000
    slli.uw a3, a1, 13
    li   t6, 0x100000000000
    beq  a3, t6, t1140_ok
    j    fail
t1140_ok:
t1141: # slli.uw 0xffffffff80000000, 32
    li   a0, 1141
    li   a1, 0xffffffff80000000
    slli.uw a3, a1, 32
    li   t6, 0x8000000000000000
    beq  a3, t6, t1141_ok
    j    fail
t1141_ok:
t1142: # slli.uw 0xffffffff80000000, 63
    li   a0, 1142
    li   a1, 0xffffffff80000000
    slli.uw a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1142_ok
    j    fail
t1142_ok:
t1143: # slli.uw 0x3f, 0
    li   a0, 1143
    li   a1, 0x3f
    slli.uw a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t1143_ok
    j    fail
t1143_ok:
t1144: # slli.uw 0x3f, 1
    li   a0, 1144
    li   a1, 0x3f
    slli.uw a3, a1, 1
    li   t6, 0x7e
    beq  a3, t6, t1144_ok
    j    fail
t1144_ok:
t1145: # slli.uw 0x3f, 13
    li   a0, 1145
    li   a1, 0x3f
    slli.uw a3, a1, 13
    li   t6, 0x7e000
    beq  a3, t6, t1145_ok
    j    fail
t1145_ok:
t1146: # slli.uw 0x3f, 32
    li   a0, 1146
    li   a1, 0x3f
    slli.uw a3, a1, 32
    li   t6, 0x3f00000000
    beq  a3, t6, t1146_ok
    j    fail
t1146_ok:
t1147: # slli.uw 0x3f, 63
    li   a0, 1147
    li   a1, 0x3f
    slli.uw a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t1147_ok
    j    fail
t1147_ok:
t1148: # rori 0x0, 0
    li   a0, 1148
    li   a1, 0x0
    rori a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t1148_ok
    j    fail
t1148_ok:
t1149: # rori 0x0, 1
    li   a0, 1149
    li   a1, 0x0
    rori a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t1149_ok
    j    fail
t1149_ok:
t1150: # rori 0x0, 13
    li   a0, 1150
    li   a1, 0x0
    rori a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1150_ok
    j    fail
t1150_ok:
t1151: # rori 0x0, 32
    li   a0, 1151
    li   a1, 0x0
    rori a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t1151_ok
    j    fail
t1151_ok:
t1152: # rori 0x0, 63
    li   a0, 1152
    li   a1, 0x0
    rori a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1152_ok
    j    fail
t1152_ok:
t1153: # rori 0x7, 0
    li   a0, 1153
    li   a1, 0x7
    rori a3, a1, 0
    li   t6, 0x7
    beq  a3, t6, t1153_ok
    j    fail
t1153_ok:
t1154: # rori 0x7, 1
    li   a0, 1154
    li   a1, 0x7
    rori a3, a1, 1
    li   t6, 0x8000000000000003
    beq  a3, t6, t1154_ok
    j    fail
t1154_ok:
t1155: # rori 0x7, 13
    li   a0, 1155
    li   a1, 0x7
    rori a3, a1, 13
    li   t6, 0x38000000000000
    beq  a3, t6, t1155_ok
    j    fail
t1155_ok:
t1156: # rori 0x7, 32
    li   a0, 1156
    li   a1, 0x7
    rori a3, a1, 32
    li   t6, 0x700000000
    beq  a3, t6, t1156_ok
    j    fail
t1156_ok:
t1157: # rori 0x7, 63
    li   a0, 1157
    li   a1, 0x7
    rori a3, a1, 63
    li   t6, 0xe
    beq  a3, t6, t1157_ok
    j    fail
t1157_ok:
t1158: # rori 0x7fffffffffffffff, 0
    li   a0, 1158
    li   a1, 0x7fffffffffffffff
    rori a3, a1, 0
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1158_ok
    j    fail
t1158_ok:
t1159: # rori 0x7fffffffffffffff, 1
    li   a0, 1159
    li   a1, 0x7fffffffffffffff
    rori a3, a1, 1
    li   t6, 0xbfffffffffffffff
    beq  a3, t6, t1159_ok
    j    fail
t1159_ok:
t1160: # rori 0x7fffffffffffffff, 13
    li   a0, 1160
    li   a1, 0x7fffffffffffffff
    rori a3, a1, 13
    li   t6, 0xfffbffffffffffff
    beq  a3, t6, t1160_ok
    j    fail
t1160_ok:
t1161: # rori 0x7fffffffffffffff, 32
    li   a0, 1161
    li   a1, 0x7fffffffffffffff
    rori a3, a1, 32
    li   t6, 0xffffffff7fffffff
    beq  a3, t6, t1161_ok
    j    fail
t1161_ok:
t1162: # rori 0x7fffffffffffffff, 63
    li   a0, 1162
    li   a1, 0x7fffffffffffffff
    rori a3, a1, 63
    li   t6, 0xfffffffffffffffe
    beq  a3, t6, t1162_ok
    j    fail
t1162_ok:
t1163: # rori 0xffffffff80000000, 0
    li   a0, 1163
    li   a1, 0xffffffff80000000
    rori a3, a1, 0
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1163_ok
    j    fail
t1163_ok:
t1164: # rori 0xffffffff80000000, 1
    li   a0, 1164
    li   a1, 0xffffffff80000000
    rori a3, a1, 1
    li   t6, 0x7fffffffc0000000
    beq  a3, t6, t1164_ok
    j    fail
t1164_ok:
t1165: # rori 0xffffffff80000000, 13
    li   a0, 1165
    li   a1, 0xffffffff80000000
    rori a3, a1, 13
    li   t6, 0x7fffffffc0000
    beq  a3, t6, t1165_ok
    j    fail
t1165_ok:
t1166: # rori 0xffffffff80000000, 32
    li   a0, 1166
    li   a1, 0xffffffff80000000
    rori a3, a1, 32
    li   t6, 0x80000000ffffffff
    beq  a3, t6, t1166_ok
    j    fail
t1166_ok:
t1167: # rori 0xffffffff80000000, 63
    li   a0, 1167
    li   a1, 0xffffffff80000000
    rori a3, a1, 63
    li   t6, 0xffffffff00000001
    beq  a3, t6, t1167_ok
    j    fail
t1167_ok:
t1168: # rori 0x3f, 0
    li   a0, 1168
    li   a1, 0x3f
    rori a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t1168_ok
    j    fail
t1168_ok:
t1169: # rori 0x3f, 1
    li   a0, 1169
    li   a1, 0x3f
    rori a3, a1, 1
    li   t6, 0x800000000000001f
    beq  a3, t6, t1169_ok
    j    fail
t1169_ok:
t1170: # rori 0x3f, 13
    li   a0, 1170
    li   a1, 0x3f
    rori a3, a1, 13
    li   t6, 0x1f8000000000000
    beq  a3, t6, t1170_ok
    j    fail
t1170_ok:
t1171: # rori 0x3f, 32
    li   a0, 1171
    li   a1, 0x3f
    rori a3, a1, 32
    li   t6, 0x3f00000000
    beq  a3, t6, t1171_ok
    j    fail
t1171_ok:
t1172: # rori 0x3f, 63
    li   a0, 1172
    li   a1, 0x3f
    rori a3, a1, 63
    li   t6, 0x7e
    beq  a3, t6, t1172_ok
    j    fail
t1172_ok:
t1173: # roriw 0x0, 0
    li   a0, 1173
    li   a1, 0x0
    roriw a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t1173_ok
    j    fail
t1173_ok:
t1174: # roriw 0x0, 1
    li   a0, 1174
    li   a1, 0x0
    roriw a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t1174_ok
    j    fail
t1174_ok:
t1175: # roriw 0x0, 13
    li   a0, 1175
    li   a1, 0x0
    roriw a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1175_ok
    j    fail
t1175_ok:
t1176: # roriw 0x0, 31
    li   a0, 1176
    li   a1, 0x0
    roriw a3, a1, 31
    li   t6, 0x0
    beq  a3, t6, t1176_ok
    j    fail
t1176_ok:
t1177: # roriw 0x7, 0
    li   a0, 1177
    li   a1, 0x7
    roriw a3, a1, 0
    li   t6, 0x7
    beq  a3, t6, t1177_ok
    j    fail
t1177_ok:
t1178: # roriw 0x7, 1
    li   a0, 1178
    li   a1, 0x7
    roriw a3, a1, 1
    li   t6, 0xffffffff80000003
    beq  a3, t6, t1178_ok
    j    fail
t1178_ok:
t1179: # roriw 0x7, 13
    li   a0, 1179
    li   a1, 0x7
    roriw a3, a1, 13
    li   t6, 0x380000
    beq  a3, t6, t1179_ok
    j    fail
t1179_ok:
t1180: # roriw 0x7, 31
    li   a0, 1180
    li   a1, 0x7
    roriw a3, a1, 31
    li   t6, 0xe
    beq  a3, t6, t1180_ok
    j    fail
t1180_ok:
t1181: # roriw 0x7fffffffffffffff, 0
    li   a0, 1181
    li   a1, 0x7fffffffffffffff
    roriw a3, a1, 0
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1181_ok
    j    fail
t1181_ok:
t1182: # roriw 0x7fffffffffffffff, 1
    li   a0, 1182
    li   a1, 0x7fffffffffffffff
    roriw a3, a1, 1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1182_ok
    j    fail
t1182_ok:
t1183: # roriw 0x7fffffffffffffff, 13
    li   a0, 1183
    li   a1, 0x7fffffffffffffff
    roriw a3, a1, 13
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1183_ok
    j    fail
t1183_ok:
t1184: # roriw 0x7fffffffffffffff, 31
    li   a0, 1184
    li   a1, 0x7fffffffffffffff
    roriw a3, a1, 31
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1184_ok
    j    fail
t1184_ok:
t1185: # roriw 0xffffffff80000000, 0
    li   a0, 1185
    li   a1, 0xffffffff80000000
    roriw a3, a1, 0
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1185_ok
    j    fail
t1185_ok:
t1186: # roriw 0xffffffff80000000, 1
    li   a0, 1186
    li   a1, 0xffffffff80000000
    roriw a3, a1, 1
    li   t6, 0x40000000
    beq  a3, t6, t1186_ok
    j    fail
t1186_ok:
t1187: # roriw 0xffffffff80000000, 13
    li   a0, 1187
    li   a1, 0xffffffff80000000
    roriw a3, a1, 13
    li   t6, 0x40000
    beq  a3, t6, t1187_ok
    j    fail
t1187_ok:
t1188: # roriw 0xffffffff80000000, 31
    li   a0, 1188
    li   a1, 0xffffffff80000000
    roriw a3, a1, 31
    li   t6, 0x1
    beq  a3, t6, t1188_ok
    j    fail
t1188_ok:
t1189: # roriw 0x3f, 0
    li   a0, 1189
    li   a1, 0x3f
    roriw a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t1189_ok
    j    fail
t1189_ok:
t1190: # roriw 0x3f, 1
    li   a0, 1190
    li   a1, 0x3f
    roriw a3, a1, 1
    li   t6, 0xffffffff8000001f
    beq  a3, t6, t1190_ok
    j    fail
t1190_ok:
t1191: # roriw 0x3f, 13
    li   a0, 1191
    li   a1, 0x3f
    roriw a3, a1, 13
    li   t6, 0x1f80000
    beq  a3, t6, t1191_ok
    j    fail
t1191_ok:
t1192: # roriw 0x3f, 31
    li   a0, 1192
    li   a1, 0x3f
    roriw a3, a1, 31
    li   t6, 0x7e
    beq  a3, t6, t1192_ok
    j    fail
t1192_ok:
t1193: # bseti 0x0, 0
    li   a0, 1193
    li   a1, 0x0
    bseti a3, a1, 0
    li   t6, 0x1
    beq  a3, t6, t1193_ok
    j    fail
t1193_ok:
t1194: # bseti 0x0, 1
    li   a0, 1194
    li   a1, 0x0
    bseti a3, a1, 1
    li   t6, 0x2
    beq  a3, t6, t1194_ok
    j    fail
t1194_ok:
t1195: # bseti 0x0, 13
    li   a0, 1195
    li   a1, 0x0
    bseti a3, a1, 13
    li   t6, 0x2000
    beq  a3, t6, t1195_ok
    j    fail
t1195_ok:
t1196: # bseti 0x0, 32
    li   a0, 1196
    li   a1, 0x0
    bseti a3, a1, 32
    li   t6, 0x100000000
    beq  a3, t6, t1196_ok
    j    fail
t1196_ok:
t1197: # bseti 0x0, 63
    li   a0, 1197
    li   a1, 0x0
    bseti a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t1197_ok
    j    fail
t1197_ok:
t1198: # bseti 0x7, 0
    li   a0, 1198
    li   a1, 0x7
    bseti a3, a1, 0
    li   t6, 0x7
    beq  a3, t6, t1198_ok
    j    fail
t1198_ok:
t1199: # bseti 0x7, 1
    li   a0, 1199
    li   a1, 0x7
    bseti a3, a1, 1
    li   t6, 0x7
    beq  a3, t6, t1199_ok
    j    fail
t1199_ok:
t1200: # bseti 0x7, 13
    li   a0, 1200
    li   a1, 0x7
    bseti a3, a1, 13
    li   t6, 0x2007
    beq  a3, t6, t1200_ok
    j    fail
t1200_ok:
t1201: # bseti 0x7, 32
    li   a0, 1201
    li   a1, 0x7
    bseti a3, a1, 32
    li   t6, 0x100000007
    beq  a3, t6, t1201_ok
    j    fail
t1201_ok:
t1202: # bseti 0x7, 63
    li   a0, 1202
    li   a1, 0x7
    bseti a3, a1, 63
    li   t6, 0x8000000000000007
    beq  a3, t6, t1202_ok
    j    fail
t1202_ok:
t1203: # bseti 0x7fffffffffffffff, 0
    li   a0, 1203
    li   a1, 0x7fffffffffffffff
    bseti a3, a1, 0
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1203_ok
    j    fail
t1203_ok:
t1204: # bseti 0x7fffffffffffffff, 1
    li   a0, 1204
    li   a1, 0x7fffffffffffffff
    bseti a3, a1, 1
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1204_ok
    j    fail
t1204_ok:
t1205: # bseti 0x7fffffffffffffff, 13
    li   a0, 1205
    li   a1, 0x7fffffffffffffff
    bseti a3, a1, 13
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1205_ok
    j    fail
t1205_ok:
t1206: # bseti 0x7fffffffffffffff, 32
    li   a0, 1206
    li   a1, 0x7fffffffffffffff
    bseti a3, a1, 32
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1206_ok
    j    fail
t1206_ok:
t1207: # bseti 0x7fffffffffffffff, 63
    li   a0, 1207
    li   a1, 0x7fffffffffffffff
    bseti a3, a1, 63
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1207_ok
    j    fail
t1207_ok:
t1208: # bseti 0xffffffff80000000, 0
    li   a0, 1208
    li   a1, 0xffffffff80000000
    bseti a3, a1, 0
    li   t6, 0xffffffff80000001
    beq  a3, t6, t1208_ok
    j    fail
t1208_ok:
t1209: # bseti 0xffffffff80000000, 1
    li   a0, 1209
    li   a1, 0xffffffff80000000
    bseti a3, a1, 1
    li   t6, 0xffffffff80000002
    beq  a3, t6, t1209_ok
    j    fail
t1209_ok:
t1210: # bseti 0xffffffff80000000, 13
    li   a0, 1210
    li   a1, 0xffffffff80000000
    bseti a3, a1, 13
    li   t6, 0xffffffff80002000
    beq  a3, t6, t1210_ok
    j    fail
t1210_ok:
t1211: # bseti 0xffffffff80000000, 32
    li   a0, 1211
    li   a1, 0xffffffff80000000
    bseti a3, a1, 32
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1211_ok
    j    fail
t1211_ok:
t1212: # bseti 0xffffffff80000000, 63
    li   a0, 1212
    li   a1, 0xffffffff80000000
    bseti a3, a1, 63
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1212_ok
    j    fail
t1212_ok:
t1213: # bseti 0x3f, 0
    li   a0, 1213
    li   a1, 0x3f
    bseti a3, a1, 0
    li   t6, 0x3f
    beq  a3, t6, t1213_ok
    j    fail
t1213_ok:
t1214: # bseti 0x3f, 1
    li   a0, 1214
    li   a1, 0x3f
    bseti a3, a1, 1
    li   t6, 0x3f
    beq  a3, t6, t1214_ok
    j    fail
t1214_ok:
t1215: # bseti 0x3f, 13
    li   a0, 1215
    li   a1, 0x3f
    bseti a3, a1, 13
    li   t6, 0x203f
    beq  a3, t6, t1215_ok
    j    fail
t1215_ok:
t1216: # bseti 0x3f, 32
    li   a0, 1216
    li   a1, 0x3f
    bseti a3, a1, 32
    li   t6, 0x10000003f
    beq  a3, t6, t1216_ok
    j    fail
t1216_ok:
t1217: # bseti 0x3f, 63
    li   a0, 1217
    li   a1, 0x3f
    bseti a3, a1, 63
    li   t6, 0x800000000000003f
    beq  a3, t6, t1217_ok
    j    fail
t1217_ok:
t1218: # bclri 0x0, 0
    li   a0, 1218
    li   a1, 0x0
    bclri a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t1218_ok
    j    fail
t1218_ok:
t1219: # bclri 0x0, 1
    li   a0, 1219
    li   a1, 0x0
    bclri a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t1219_ok
    j    fail
t1219_ok:
t1220: # bclri 0x0, 13
    li   a0, 1220
    li   a1, 0x0
    bclri a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1220_ok
    j    fail
t1220_ok:
t1221: # bclri 0x0, 32
    li   a0, 1221
    li   a1, 0x0
    bclri a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t1221_ok
    j    fail
t1221_ok:
t1222: # bclri 0x0, 63
    li   a0, 1222
    li   a1, 0x0
    bclri a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1222_ok
    j    fail
t1222_ok:
t1223: # bclri 0x7, 0
    li   a0, 1223
    li   a1, 0x7
    bclri a3, a1, 0
    li   t6, 0x6
    beq  a3, t6, t1223_ok
    j    fail
t1223_ok:
t1224: # bclri 0x7, 1
    li   a0, 1224
    li   a1, 0x7
    bclri a3, a1, 1
    li   t6, 0x5
    beq  a3, t6, t1224_ok
    j    fail
t1224_ok:
t1225: # bclri 0x7, 13
    li   a0, 1225
    li   a1, 0x7
    bclri a3, a1, 13
    li   t6, 0x7
    beq  a3, t6, t1225_ok
    j    fail
t1225_ok:
t1226: # bclri 0x7, 32
    li   a0, 1226
    li   a1, 0x7
    bclri a3, a1, 32
    li   t6, 0x7
    beq  a3, t6, t1226_ok
    j    fail
t1226_ok:
t1227: # bclri 0x7, 63
    li   a0, 1227
    li   a1, 0x7
    bclri a3, a1, 63
    li   t6, 0x7
    beq  a3, t6, t1227_ok
    j    fail
t1227_ok:
t1228: # bclri 0x7fffffffffffffff, 0
    li   a0, 1228
    li   a1, 0x7fffffffffffffff
    bclri a3, a1, 0
    li   t6, 0x7ffffffffffffffe
    beq  a3, t6, t1228_ok
    j    fail
t1228_ok:
t1229: # bclri 0x7fffffffffffffff, 1
    li   a0, 1229
    li   a1, 0x7fffffffffffffff
    bclri a3, a1, 1
    li   t6, 0x7ffffffffffffffd
    beq  a3, t6, t1229_ok
    j    fail
t1229_ok:
t1230: # bclri 0x7fffffffffffffff, 13
    li   a0, 1230
    li   a1, 0x7fffffffffffffff
    bclri a3, a1, 13
    li   t6, 0x7fffffffffffdfff
    beq  a3, t6, t1230_ok
    j    fail
t1230_ok:
t1231: # bclri 0x7fffffffffffffff, 32
    li   a0, 1231
    li   a1, 0x7fffffffffffffff
    bclri a3, a1, 32
    li   t6, 0x7ffffffeffffffff
    beq  a3, t6, t1231_ok
    j    fail
t1231_ok:
t1232: # bclri 0x7fffffffffffffff, 63
    li   a0, 1232
    li   a1, 0x7fffffffffffffff
    bclri a3, a1, 63
    li   t6, 0x7fffffffffffffff
    beq  a3, t6, t1232_ok
    j    fail
t1232_ok:
t1233: # bclri 0xffffffff80000000, 0
    li   a0, 1233
    li   a1, 0xffffffff80000000
    bclri a3, a1, 0
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1233_ok
    j    fail
t1233_ok:
t1234: # bclri 0xffffffff80000000, 1
    li   a0, 1234
    li   a1, 0xffffffff80000000
    bclri a3, a1, 1
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1234_ok
    j    fail
t1234_ok:
t1235: # bclri 0xffffffff80000000, 13
    li   a0, 1235
    li   a1, 0xffffffff80000000
    bclri a3, a1, 13
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1235_ok
    j    fail
t1235_ok:
t1236: # bclri 0xffffffff80000000, 32
    li   a0, 1236
    li   a1, 0xffffffff80000000
    bclri a3, a1, 32
    li   t6, 0xfffffffe80000000
    beq  a3, t6, t1236_ok
    j    fail
t1236_ok:
t1237: # bclri 0xffffffff80000000, 63
    li   a0, 1237
    li   a1, 0xffffffff80000000
    bclri a3, a1, 63
    li   t6, 0x7fffffff80000000
    beq  a3, t6, t1237_ok
    j    fail
t1237_ok:
t1238: # bclri 0x3f, 0
    li   a0, 1238
    li   a1, 0x3f
    bclri a3, a1, 0
    li   t6, 0x3e
    beq  a3, t6, t1238_ok
    j    fail
t1238_ok:
t1239: # bclri 0x3f, 1
    li   a0, 1239
    li   a1, 0x3f
    bclri a3, a1, 1
    li   t6, 0x3d
    beq  a3, t6, t1239_ok
    j    fail
t1239_ok:
t1240: # bclri 0x3f, 13
    li   a0, 1240
    li   a1, 0x3f
    bclri a3, a1, 13
    li   t6, 0x3f
    beq  a3, t6, t1240_ok
    j    fail
t1240_ok:
t1241: # bclri 0x3f, 32
    li   a0, 1241
    li   a1, 0x3f
    bclri a3, a1, 32
    li   t6, 0x3f
    beq  a3, t6, t1241_ok
    j    fail
t1241_ok:
t1242: # bclri 0x3f, 63
    li   a0, 1242
    li   a1, 0x3f
    bclri a3, a1, 63
    li   t6, 0x3f
    beq  a3, t6, t1242_ok
    j    fail
t1242_ok:
t1243: # binvi 0x0, 0
    li   a0, 1243
    li   a1, 0x0
    binvi a3, a1, 0
    li   t6, 0x1
    beq  a3, t6, t1243_ok
    j    fail
t1243_ok:
t1244: # binvi 0x0, 1
    li   a0, 1244
    li   a1, 0x0
    binvi a3, a1, 1
    li   t6, 0x2
    beq  a3, t6, t1244_ok
    j    fail
t1244_ok:
t1245: # binvi 0x0, 13
    li   a0, 1245
    li   a1, 0x0
    binvi a3, a1, 13
    li   t6, 0x2000
    beq  a3, t6, t1245_ok
    j    fail
t1245_ok:
t1246: # binvi 0x0, 32
    li   a0, 1246
    li   a1, 0x0
    binvi a3, a1, 32
    li   t6, 0x100000000
    beq  a3, t6, t1246_ok
    j    fail
t1246_ok:
t1247: # binvi 0x0, 63
    li   a0, 1247
    li   a1, 0x0
    binvi a3, a1, 63
    li   t6, 0x8000000000000000
    beq  a3, t6, t1247_ok
    j    fail
t1247_ok:
t1248: # binvi 0x7, 0
    li   a0, 1248
    li   a1, 0x7
    binvi a3, a1, 0
    li   t6, 0x6
    beq  a3, t6, t1248_ok
    j    fail
t1248_ok:
t1249: # binvi 0x7, 1
    li   a0, 1249
    li   a1, 0x7
    binvi a3, a1, 1
    li   t6, 0x5
    beq  a3, t6, t1249_ok
    j    fail
t1249_ok:
t1250: # binvi 0x7, 13
    li   a0, 1250
    li   a1, 0x7
    binvi a3, a1, 13
    li   t6, 0x2007
    beq  a3, t6, t1250_ok
    j    fail
t1250_ok:
t1251: # binvi 0x7, 32
    li   a0, 1251
    li   a1, 0x7
    binvi a3, a1, 32
    li   t6, 0x100000007
    beq  a3, t6, t1251_ok
    j    fail
t1251_ok:
t1252: # binvi 0x7, 63
    li   a0, 1252
    li   a1, 0x7
    binvi a3, a1, 63
    li   t6, 0x8000000000000007
    beq  a3, t6, t1252_ok
    j    fail
t1252_ok:
t1253: # binvi 0x7fffffffffffffff, 0
    li   a0, 1253
    li   a1, 0x7fffffffffffffff
    binvi a3, a1, 0
    li   t6, 0x7ffffffffffffffe
    beq  a3, t6, t1253_ok
    j    fail
t1253_ok:
t1254: # binvi 0x7fffffffffffffff, 1
    li   a0, 1254
    li   a1, 0x7fffffffffffffff
    binvi a3, a1, 1
    li   t6, 0x7ffffffffffffffd
    beq  a3, t6, t1254_ok
    j    fail
t1254_ok:
t1255: # binvi 0x7fffffffffffffff, 13
    li   a0, 1255
    li   a1, 0x7fffffffffffffff
    binvi a3, a1, 13
    li   t6, 0x7fffffffffffdfff
    beq  a3, t6, t1255_ok
    j    fail
t1255_ok:
t1256: # binvi 0x7fffffffffffffff, 32
    li   a0, 1256
    li   a1, 0x7fffffffffffffff
    binvi a3, a1, 32
    li   t6, 0x7ffffffeffffffff
    beq  a3, t6, t1256_ok
    j    fail
t1256_ok:
t1257: # binvi 0x7fffffffffffffff, 63
    li   a0, 1257
    li   a1, 0x7fffffffffffffff
    binvi a3, a1, 63
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1257_ok
    j    fail
t1257_ok:
t1258: # binvi 0xffffffff80000000, 0
    li   a0, 1258
    li   a1, 0xffffffff80000000
    binvi a3, a1, 0
    li   t6, 0xffffffff80000001
    beq  a3, t6, t1258_ok
    j    fail
t1258_ok:
t1259: # binvi 0xffffffff80000000, 1
    li   a0, 1259
    li   a1, 0xffffffff80000000
    binvi a3, a1, 1
    li   t6, 0xffffffff80000002
    beq  a3, t6, t1259_ok
    j    fail
t1259_ok:
t1260: # binvi 0xffffffff80000000, 13
    li   a0, 1260
    li   a1, 0xffffffff80000000
    binvi a3, a1, 13
    li   t6, 0xffffffff80002000
    beq  a3, t6, t1260_ok
    j    fail
t1260_ok:
t1261: # binvi 0xffffffff80000000, 32
    li   a0, 1261
    li   a1, 0xffffffff80000000
    binvi a3, a1, 32
    li   t6, 0xfffffffe80000000
    beq  a3, t6, t1261_ok
    j    fail
t1261_ok:
t1262: # binvi 0xffffffff80000000, 63
    li   a0, 1262
    li   a1, 0xffffffff80000000
    binvi a3, a1, 63
    li   t6, 0x7fffffff80000000
    beq  a3, t6, t1262_ok
    j    fail
t1262_ok:
t1263: # binvi 0x3f, 0
    li   a0, 1263
    li   a1, 0x3f
    binvi a3, a1, 0
    li   t6, 0x3e
    beq  a3, t6, t1263_ok
    j    fail
t1263_ok:
t1264: # binvi 0x3f, 1
    li   a0, 1264
    li   a1, 0x3f
    binvi a3, a1, 1
    li   t6, 0x3d
    beq  a3, t6, t1264_ok
    j    fail
t1264_ok:
t1265: # binvi 0x3f, 13
    li   a0, 1265
    li   a1, 0x3f
    binvi a3, a1, 13
    li   t6, 0x203f
    beq  a3, t6, t1265_ok
    j    fail
t1265_ok:
t1266: # binvi 0x3f, 32
    li   a0, 1266
    li   a1, 0x3f
    binvi a3, a1, 32
    li   t6, 0x10000003f
    beq  a3, t6, t1266_ok
    j    fail
t1266_ok:
t1267: # binvi 0x3f, 63
    li   a0, 1267
    li   a1, 0x3f
    binvi a3, a1, 63
    li   t6, 0x800000000000003f
    beq  a3, t6, t1267_ok
    j    fail
t1267_ok:
t1268: # bexti 0x0, 0
    li   a0, 1268
    li   a1, 0x0
    bexti a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t1268_ok
    j    fail
t1268_ok:
t1269: # bexti 0x0, 1
    li   a0, 1269
    li   a1, 0x0
    bexti a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t1269_ok
    j    fail
t1269_ok:
t1270: # bexti 0x0, 13
    li   a0, 1270
    li   a1, 0x0
    bexti a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1270_ok
    j    fail
t1270_ok:
t1271: # bexti 0x0, 32
    li   a0, 1271
    li   a1, 0x0
    bexti a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t1271_ok
    j    fail
t1271_ok:
t1272: # bexti 0x0, 63
    li   a0, 1272
    li   a1, 0x0
    bexti a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1272_ok
    j    fail
t1272_ok:
t1273: # bexti 0x7, 0
    li   a0, 1273
    li   a1, 0x7
    bexti a3, a1, 0
    li   t6, 0x1
    beq  a3, t6, t1273_ok
    j    fail
t1273_ok:
t1274: # bexti 0x7, 1
    li   a0, 1274
    li   a1, 0x7
    bexti a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t1274_ok
    j    fail
t1274_ok:
t1275: # bexti 0x7, 13
    li   a0, 1275
    li   a1, 0x7
    bexti a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1275_ok
    j    fail
t1275_ok:
t1276: # bexti 0x7, 32
    li   a0, 1276
    li   a1, 0x7
    bexti a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t1276_ok
    j    fail
t1276_ok:
t1277: # bexti 0x7, 63
    li   a0, 1277
    li   a1, 0x7
    bexti a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1277_ok
    j    fail
t1277_ok:
t1278: # bexti 0x7fffffffffffffff, 0
    li   a0, 1278
    li   a1, 0x7fffffffffffffff
    bexti a3, a1, 0
    li   t6, 0x1
    beq  a3, t6, t1278_ok
    j    fail
t1278_ok:
t1279: # bexti 0x7fffffffffffffff, 1
    li   a0, 1279
    li   a1, 0x7fffffffffffffff
    bexti a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t1279_ok
    j    fail
t1279_ok:
t1280: # bexti 0x7fffffffffffffff, 13
    li   a0, 1280
    li   a1, 0x7fffffffffffffff
    bexti a3, a1, 13
    li   t6, 0x1
    beq  a3, t6, t1280_ok
    j    fail
t1280_ok:
t1281: # bexti 0x7fffffffffffffff, 32
    li   a0, 1281
    li   a1, 0x7fffffffffffffff
    bexti a3, a1, 32
    li   t6, 0x1
    beq  a3, t6, t1281_ok
    j    fail
t1281_ok:
t1282: # bexti 0x7fffffffffffffff, 63
    li   a0, 1282
    li   a1, 0x7fffffffffffffff
    bexti a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1282_ok
    j    fail
t1282_ok:
t1283: # bexti 0xffffffff80000000, 0
    li   a0, 1283
    li   a1, 0xffffffff80000000
    bexti a3, a1, 0
    li   t6, 0x0
    beq  a3, t6, t1283_ok
    j    fail
t1283_ok:
t1284: # bexti 0xffffffff80000000, 1
    li   a0, 1284
    li   a1, 0xffffffff80000000
    bexti a3, a1, 1
    li   t6, 0x0
    beq  a3, t6, t1284_ok
    j    fail
t1284_ok:
t1285: # bexti 0xffffffff80000000, 13
    li   a0, 1285
    li   a1, 0xffffffff80000000
    bexti a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1285_ok
    j    fail
t1285_ok:
t1286: # bexti 0xffffffff80000000, 32
    li   a0, 1286
    li   a1, 0xffffffff80000000
    bexti a3, a1, 32
    li   t6, 0x1
    beq  a3, t6, t1286_ok
    j    fail
t1286_ok:
t1287: # bexti 0xffffffff80000000, 63
    li   a0, 1287
    li   a1, 0xffffffff80000000
    bexti a3, a1, 63
    li   t6, 0x1
    beq  a3, t6, t1287_ok
    j    fail
t1287_ok:
t1288: # bexti 0x3f, 0
    li   a0, 1288
    li   a1, 0x3f
    bexti a3, a1, 0
    li   t6, 0x1
    beq  a3, t6, t1288_ok
    j    fail
t1288_ok:
t1289: # bexti 0x3f, 1
    li   a0, 1289
    li   a1, 0x3f
    bexti a3, a1, 1
    li   t6, 0x1
    beq  a3, t6, t1289_ok
    j    fail
t1289_ok:
t1290: # bexti 0x3f, 13
    li   a0, 1290
    li   a1, 0x3f
    bexti a3, a1, 13
    li   t6, 0x0
    beq  a3, t6, t1290_ok
    j    fail
t1290_ok:
t1291: # bexti 0x3f, 32
    li   a0, 1291
    li   a1, 0x3f
    bexti a3, a1, 32
    li   t6, 0x0
    beq  a3, t6, t1291_ok
    j    fail
t1291_ok:
t1292: # bexti 0x3f, 63
    li   a0, 1292
    li   a1, 0x3f
    bexti a3, a1, 63
    li   t6, 0x0
    beq  a3, t6, t1292_ok
    j    fail
t1292_ok:
t1293: # clz 0x0
    li   a0, 1293
    li   a1, 0x0
    clz a3, a1
    li   t6, 0x40
    beq  a3, t6, t1293_ok
    j    fail
t1293_ok:
t1294: # clz 0x1
    li   a0, 1294
    li   a1, 0x1
    clz a3, a1
    li   t6, 0x3f
    beq  a3, t6, t1294_ok
    j    fail
t1294_ok:
t1295: # clz 0xffffffffffffffff
    li   a0, 1295
    li   a1, 0xffffffffffffffff
    clz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1295_ok
    j    fail
t1295_ok:
t1296: # clz 0x7
    li   a0, 1296
    li   a1, 0x7
    clz a3, a1
    li   t6, 0x3d
    beq  a3, t6, t1296_ok
    j    fail
t1296_ok:
t1297: # clz 0xfffffffffffffff9
    li   a0, 1297
    li   a1, 0xfffffffffffffff9
    clz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1297_ok
    j    fail
t1297_ok:
t1298: # clz 0x8000000000000000
    li   a0, 1298
    li   a1, 0x8000000000000000
    clz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1298_ok
    j    fail
t1298_ok:
t1299: # clz 0x7fffffffffffffff
    li   a0, 1299
    li   a1, 0x7fffffffffffffff
    clz a3, a1
    li   t6, 0x1
    beq  a3, t6, t1299_ok
    j    fail
t1299_ok:
t1300: # clz 0x80000000
    li   a0, 1300
    li   a1, 0x80000000
    clz a3, a1
    li   t6, 0x20
    beq  a3, t6, t1300_ok
    j    fail
t1300_ok:
t1301: # clz 0x7fffffff
    li   a0, 1301
    li   a1, 0x7fffffff
    clz a3, a1
    li   t6, 0x21
    beq  a3, t6, t1301_ok
    j    fail
t1301_ok:
t1302: # clz 0xffffffff80000000
    li   a0, 1302
    li   a1, 0xffffffff80000000
    clz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1302_ok
    j    fail
t1302_ok:
t1303: # clz 0x123456789abcdef0
    li   a0, 1303
    li   a1, 0x123456789abcdef0
    clz a3, a1
    li   t6, 0x3
    beq  a3, t6, t1303_ok
    j    fail
t1303_ok:
t1304: # clz 0xfedcba9876543210
    li   a0, 1304
    li   a1, 0xfedcba9876543210
    clz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1304_ok
    j    fail
t1304_ok:
t1305: # clz 0x3f
    li   a0, 1305
    li   a1, 0x3f
    clz a3, a1
    li   t6, 0x3a
    beq  a3, t6, t1305_ok
    j    fail
t1305_ok:
t1306: # clz 0x40
    li   a0, 1306
    li   a1, 0x40
    clz a3, a1
    li   t6, 0x39
    beq  a3, t6, t1306_ok
    j    fail
t1306_ok:
t1307: # clz 0x21
    li   a0, 1307
    li   a1, 0x21
    clz a3, a1
    li   t6, 0x3a
    beq  a3, t6, t1307_ok
    j    fail
t1307_ok:
t1308: # clz 0xff00ff00ff00ff
    li   a0, 1308
    li   a1, 0xff00ff00ff00ff
    clz a3, a1
    li   t6, 0x8
    beq  a3, t6, t1308_ok
    j    fail
t1308_ok:
t1309: # clz 0x100000000
    li   a0, 1309
    li   a1, 0x100000000
    clz a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1309_ok
    j    fail
t1309_ok:
t1310: # clz 0x8000000000000001
    li   a0, 1310
    li   a1, 0x8000000000000001
    clz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1310_ok
    j    fail
t1310_ok:
t1311: # clz 0xffff8000
    li   a0, 1311
    li   a1, 0xffff8000
    clz a3, a1
    li   t6, 0x20
    beq  a3, t6, t1311_ok
    j    fail
t1311_ok:
t1312: # clz 0x102030400000080
    li   a0, 1312
    li   a1, 0x102030400000080
    clz a3, a1
    li   t6, 0x7
    beq  a3, t6, t1312_ok
    j    fail
t1312_ok:
t1313: # ctz 0x0
    li   a0, 1313
    li   a1, 0x0
    ctz a3, a1
    li   t6, 0x40
    beq  a3, t6, t1313_ok
    j    fail
t1313_ok:
t1314: # ctz 0x1
    li   a0, 1314
    li   a1, 0x1
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1314_ok
    j    fail
t1314_ok:
t1315: # ctz 0xffffffffffffffff
    li   a0, 1315
    li   a1, 0xffffffffffffffff
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1315_ok
    j    fail
t1315_ok:
t1316: # ctz 0x7
    li   a0, 1316
    li   a1, 0x7
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1316_ok
    j    fail
t1316_ok:
t1317: # ctz 0xfffffffffffffff9
    li   a0, 1317
    li   a1, 0xfffffffffffffff9
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1317_ok
    j    fail
t1317_ok:
t1318: # ctz 0x8000000000000000
    li   a0, 1318
    li   a1, 0x8000000000000000
    ctz a3, a1
    li   t6, 0x3f
    beq  a3, t6, t1318_ok
    j    fail
t1318_ok:
t1319: # ctz 0x7fffffffffffffff
    li   a0, 1319
    li   a1, 0x7fffffffffffffff
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1319_ok
    j    fail
t1319_ok:
t1320: # ctz 0x80000000
    li   a0, 1320
    li   a1, 0x80000000
    ctz a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1320_ok
    j    fail
t1320_ok:
t1321: # ctz 0x7fffffff
    li   a0, 1321
    li   a1, 0x7fffffff
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1321_ok
    j    fail
t1321_ok:
t1322: # ctz 0xffffffff80000000
    li   a0, 1322
    li   a1, 0xffffffff80000000
    ctz a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1322_ok
    j    fail
t1322_ok:
t1323: # ctz 0x123456789abcdef0
    li   a0, 1323
    li   a1, 0x123456789abcdef0
    ctz a3, a1
    li   t6, 0x4
    beq  a3, t6, t1323_ok
    j    fail
t1323_ok:
t1324: # ctz 0xfedcba9876543210
    li   a0, 1324
    li   a1, 0xfedcba9876543210
    ctz a3, a1
    li   t6, 0x4
    beq  a3, t6, t1324_ok
    j    fail
t1324_ok:
t1325: # ctz 0x3f
    li   a0, 1325
    li   a1, 0x3f
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1325_ok
    j    fail
t1325_ok:
t1326: # ctz 0x40
    li   a0, 1326
    li   a1, 0x40
    ctz a3, a1
    li   t6, 0x6
    beq  a3, t6, t1326_ok
    j    fail
t1326_ok:
t1327: # ctz 0x21
    li   a0, 1327
    li   a1, 0x21
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1327_ok
    j    fail
t1327_ok:
t1328: # ctz 0xff00ff00ff00ff
    li   a0, 1328
    li   a1, 0xff00ff00ff00ff
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1328_ok
    j    fail
t1328_ok:
t1329: # ctz 0x100000000
    li   a0, 1329
    li   a1, 0x100000000
    ctz a3, a1
    li   t6, 0x20
    beq  a3, t6, t1329_ok
    j    fail
t1329_ok:
t1330: # ctz 0x8000000000000001
    li   a0, 1330
    li   a1, 0x8000000000000001
    ctz a3, a1
    li   t6, 0x0
    beq  a3, t6, t1330_ok
    j    fail
t1330_ok:
t1331: # ctz 0xffff8000
    li   a0, 1331
    li   a1, 0xffff8000
    ctz a3, a1
    li   t6, 0xf
    beq  a3, t6, t1331_ok
    j    fail
t1331_ok:
t1332: # ctz 0x102030400000080
    li   a0, 1332
    li   a1, 0x102030400000080
    ctz a3, a1
    li   t6, 0x7
    beq  a3, t6, t1332_ok
    j    fail
t1332_ok:
t1333: # cpop 0x0
    li   a0, 1333
    li   a1, 0x0
    cpop a3, a1
    li   t6, 0x0
    beq  a3, t6, t1333_ok
    j    fail
t1333_ok:
t1334: # cpop 0x1
    li   a0, 1334
    li   a1, 0x1
    cpop a3, a1
    li   t6, 0x1
    beq  a3, t6, t1334_ok
    j    fail
t1334_ok:
t1335: # cpop 0xffffffffffffffff
    li   a0, 1335
    li   a1, 0xffffffffffffffff
    cpop a3, a1
    li   t6, 0x40
    beq  a3, t6, t1335_ok
    j    fail
t1335_ok:
t1336: # cpop 0x7
    li   a0, 1336
    li   a1, 0x7
    cpop a3, a1
    li   t6, 0x3
    beq  a3, t6, t1336_ok
    j    fail
t1336_ok:
t1337: # cpop 0xfffffffffffffff9
    li   a0, 1337
    li   a1, 0xfffffffffffffff9
    cpop a3, a1
    li   t6, 0x3e
    beq  a3, t6, t1337_ok
    j    fail
t1337_ok:
t1338: # cpop 0x8000000000000000
    li   a0, 1338
    li   a1, 0x8000000000000000
    cpop a3, a1
    li   t6, 0x1
    beq  a3, t6, t1338_ok
    j    fail
t1338_ok:
t1339: # cpop 0x7fffffffffffffff
    li   a0, 1339
    li   a1, 0x7fffffffffffffff
    cpop a3, a1
    li   t6, 0x3f
    beq  a3, t6, t1339_ok
    j    fail
t1339_ok:
t1340: # cpop 0x80000000
    li   a0, 1340
    li   a1, 0x80000000
    cpop a3, a1
    li   t6, 0x1
    beq  a3, t6, t1340_ok
    j    fail
t1340_ok:
t1341: # cpop 0x7fffffff
    li   a0, 1341
    li   a1, 0x7fffffff
    cpop a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1341_ok
    j    fail
t1341_ok:
t1342: # cpop 0xffffffff80000000
    li   a0, 1342
    li   a1, 0xffffffff80000000
    cpop a3, a1
    li   t6, 0x21
    beq  a3, t6, t1342_ok
    j    fail
t1342_ok:
t1343: # cpop 0x123456789abcdef0
    li   a0, 1343
    li   a1, 0x123456789abcdef0
    cpop a3, a1
    li   t6, 0x20
    beq  a3, t6, t1343_ok
    j    fail
t1343_ok:
t1344: # cpop 0xfedcba9876543210
    li   a0, 1344
    li   a1, 0xfedcba9876543210
    cpop a3, a1
    li   t6, 0x20
    beq  a3, t6, t1344_ok
    j    fail
t1344_ok:
t1345: # cpop 0x3f
    li   a0, 1345
    li   a1, 0x3f
    cpop a3, a1
    li   t6, 0x6
    beq  a3, t6, t1345_ok
    j    fail
t1345_ok:
t1346: # cpop 0x40
    li   a0, 1346
    li   a1, 0x40
    cpop a3, a1
    li   t6, 0x1
    beq  a3, t6, t1346_ok
    j    fail
t1346_ok:
t1347: # cpop 0x21
    li   a0, 1347
    li   a1, 0x21
    cpop a3, a1
    li   t6, 0x2
    beq  a3, t6, t1347_ok
    j    fail
t1347_ok:
t1348: # cpop 0xff00ff00ff00ff
    li   a0, 1348
    li   a1, 0xff00ff00ff00ff
    cpop a3, a1
    li   t6, 0x20
    beq  a3, t6, t1348_ok
    j    fail
t1348_ok:
t1349: # cpop 0x100000000
    li   a0, 1349
    li   a1, 0x100000000
    cpop a3, a1
    li   t6, 0x1
    beq  a3, t6, t1349_ok
    j    fail
t1349_ok:
t1350: # cpop 0x8000000000000001
    li   a0, 1350
    li   a1, 0x8000000000000001
    cpop a3, a1
    li   t6, 0x2
    beq  a3, t6, t1350_ok
    j    fail
t1350_ok:
t1351: # cpop 0xffff8000
    li   a0, 1351
    li   a1, 0xffff8000
    cpop a3, a1
    li   t6, 0x11
    beq  a3, t6, t1351_ok
    j    fail
t1351_ok:
t1352: # cpop 0x102030400000080
    li   a0, 1352
    li   a1, 0x102030400000080
    cpop a3, a1
    li   t6, 0x6
    beq  a3, t6, t1352_ok
    j    fail
t1352_ok:
t1353: # clzw 0x0
    li   a0, 1353
    li   a1, 0x0
    clzw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1353_ok
    j    fail
t1353_ok:
t1354: # clzw 0x1
    li   a0, 1354
    li   a1, 0x1
    clzw a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1354_ok
    j    fail
t1354_ok:
t1355: # clzw 0xffffffffffffffff
    li   a0, 1355
    li   a1, 0xffffffffffffffff
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1355_ok
    j    fail
t1355_ok:
t1356: # clzw 0x7
    li   a0, 1356
    li   a1, 0x7
    clzw a3, a1
    li   t6, 0x1d
    beq  a3, t6, t1356_ok
    j    fail
t1356_ok:
t1357: # clzw 0xfffffffffffffff9
    li   a0, 1357
    li   a1, 0xfffffffffffffff9
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1357_ok
    j    fail
t1357_ok:
t1358: # clzw 0x8000000000000000
    li   a0, 1358
    li   a1, 0x8000000000000000
    clzw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1358_ok
    j    fail
t1358_ok:
t1359: # clzw 0x7fffffffffffffff
    li   a0, 1359
    li   a1, 0x7fffffffffffffff
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1359_ok
    j    fail
t1359_ok:
t1360: # clzw 0x80000000
    li   a0, 1360
    li   a1, 0x80000000
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1360_ok
    j    fail
t1360_ok:
t1361: # clzw 0x7fffffff
    li   a0, 1361
    li   a1, 0x7fffffff
    clzw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1361_ok
    j    fail
t1361_ok:
t1362: # clzw 0xffffffff80000000
    li   a0, 1362
    li   a1, 0xffffffff80000000
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1362_ok
    j    fail
t1362_ok:
t1363: # clzw 0x123456789abcdef0
    li   a0, 1363
    li   a1, 0x123456789abcdef0
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1363_ok
    j    fail
t1363_ok:
t1364: # clzw 0xfedcba9876543210
    li   a0, 1364
    li   a1, 0xfedcba9876543210
    clzw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1364_ok
    j    fail
t1364_ok:
t1365: # clzw 0x3f
    li   a0, 1365
    li   a1, 0x3f
    clzw a3, a1
    li   t6, 0x1a
    beq  a3, t6, t1365_ok
    j    fail
t1365_ok:
t1366: # clzw 0x40
    li   a0, 1366
    li   a1, 0x40
    clzw a3, a1
    li   t6, 0x19
    beq  a3, t6, t1366_ok
    j    fail
t1366_ok:
t1367: # clzw 0x21
    li   a0, 1367
    li   a1, 0x21
    clzw a3, a1
    li   t6, 0x1a
    beq  a3, t6, t1367_ok
    j    fail
t1367_ok:
t1368: # clzw 0xff00ff00ff00ff
    li   a0, 1368
    li   a1, 0xff00ff00ff00ff
    clzw a3, a1
    li   t6, 0x8
    beq  a3, t6, t1368_ok
    j    fail
t1368_ok:
t1369: # clzw 0x100000000
    li   a0, 1369
    li   a1, 0x100000000
    clzw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1369_ok
    j    fail
t1369_ok:
t1370: # clzw 0x8000000000000001
    li   a0, 1370
    li   a1, 0x8000000000000001
    clzw a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1370_ok
    j    fail
t1370_ok:
t1371: # clzw 0xffff8000
    li   a0, 1371
    li   a1, 0xffff8000
    clzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1371_ok
    j    fail
t1371_ok:
t1372: # clzw 0x102030400000080
    li   a0, 1372
    li   a1, 0x102030400000080
    clzw a3, a1
    li   t6, 0x18
    beq  a3, t6, t1372_ok
    j    fail
t1372_ok:
t1373: # ctzw 0x0
    li   a0, 1373
    li   a1, 0x0
    ctzw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1373_ok
    j    fail
t1373_ok:
t1374: # ctzw 0x1
    li   a0, 1374
    li   a1, 0x1
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1374_ok
    j    fail
t1374_ok:
t1375: # ctzw 0xffffffffffffffff
    li   a0, 1375
    li   a1, 0xffffffffffffffff
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1375_ok
    j    fail
t1375_ok:
t1376: # ctzw 0x7
    li   a0, 1376
    li   a1, 0x7
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1376_ok
    j    fail
t1376_ok:
t1377: # ctzw 0xfffffffffffffff9
    li   a0, 1377
    li   a1, 0xfffffffffffffff9
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1377_ok
    j    fail
t1377_ok:
t1378: # ctzw 0x8000000000000000
    li   a0, 1378
    li   a1, 0x8000000000000000
    ctzw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1378_ok
    j    fail
t1378_ok:
t1379: # ctzw 0x7fffffffffffffff
    li   a0, 1379
    li   a1, 0x7fffffffffffffff
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1379_ok
    j    fail
t1379_ok:
t1380: # ctzw 0x80000000
    li   a0, 1380
    li   a1, 0x80000000
    ctzw a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1380_ok
    j    fail
t1380_ok:
t1381: # ctzw 0x7fffffff
    li   a0, 1381
    li   a1, 0x7fffffff
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1381_ok
    j    fail
t1381_ok:
t1382: # ctzw 0xffffffff80000000
    li   a0, 1382
    li   a1, 0xffffffff80000000
    ctzw a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1382_ok
    j    fail
t1382_ok:
t1383: # ctzw 0x123456789abcdef0
    li   a0, 1383
    li   a1, 0x123456789abcdef0
    ctzw a3, a1
    li   t6, 0x4
    beq  a3, t6, t1383_ok
    j    fail
t1383_ok:
t1384: # ctzw 0xfedcba9876543210
    li   a0, 1384
    li   a1, 0xfedcba9876543210
    ctzw a3, a1
    li   t6, 0x4
    beq  a3, t6, t1384_ok
    j    fail
t1384_ok:
t1385: # ctzw 0x3f
    li   a0, 1385
    li   a1, 0x3f
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1385_ok
    j    fail
t1385_ok:
t1386: # ctzw 0x40
    li   a0, 1386
    li   a1, 0x40
    ctzw a3, a1
    li   t6, 0x6
    beq  a3, t6, t1386_ok
    j    fail
t1386_ok:
t1387: # ctzw 0x21
    li   a0, 1387
    li   a1, 0x21
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1387_ok
    j    fail
t1387_ok:
t1388: # ctzw 0xff00ff00ff00ff
    li   a0, 1388
    li   a1, 0xff00ff00ff00ff
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1388_ok
    j    fail
t1388_ok:
t1389: # ctzw 0x100000000
    li   a0, 1389
    li   a1, 0x100000000
    ctzw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1389_ok
    j    fail
t1389_ok:
t1390: # ctzw 0x8000000000000001
    li   a0, 1390
    li   a1, 0x8000000000000001
    ctzw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1390_ok
    j    fail
t1390_ok:
t1391: # ctzw 0xffff8000
    li   a0, 1391
    li   a1, 0xffff8000
    ctzw a3, a1
    li   t6, 0xf
    beq  a3, t6, t1391_ok
    j    fail
t1391_ok:
t1392: # ctzw 0x102030400000080
    li   a0, 1392
    li   a1, 0x102030400000080
    ctzw a3, a1
    li   t6, 0x7
    beq  a3, t6, t1392_ok
    j    fail
t1392_ok:
t1393: # cpopw 0x0
    li   a0, 1393
    li   a1, 0x0
    cpopw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1393_ok
    j    fail
t1393_ok:
t1394: # cpopw 0x1
    li   a0, 1394
    li   a1, 0x1
    cpopw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1394_ok
    j    fail
t1394_ok:
t1395: # cpopw 0xffffffffffffffff
    li   a0, 1395
    li   a1, 0xffffffffffffffff
    cpopw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1395_ok
    j    fail
t1395_ok:
t1396: # cpopw 0x7
    li   a0, 1396
    li   a1, 0x7
    cpopw a3, a1
    li   t6, 0x3
    beq  a3, t6, t1396_ok
    j    fail
t1396_ok:
t1397: # cpopw 0xfffffffffffffff9
    li   a0, 1397
    li   a1, 0xfffffffffffffff9
    cpopw a3, a1
    li   t6, 0x1e
    beq  a3, t6, t1397_ok
    j    fail
t1397_ok:
t1398: # cpopw 0x8000000000000000
    li   a0, 1398
    li   a1, 0x8000000000000000
    cpopw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1398_ok
    j    fail
t1398_ok:
t1399: # cpopw 0x7fffffffffffffff
    li   a0, 1399
    li   a1, 0x7fffffffffffffff
    cpopw a3, a1
    li   t6, 0x20
    beq  a3, t6, t1399_ok
    j    fail
t1399_ok:
t1400: # cpopw 0x80000000
    li   a0, 1400
    li   a1, 0x80000000
    cpopw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1400_ok
    j    fail
t1400_ok:
t1401: # cpopw 0x7fffffff
    li   a0, 1401
    li   a1, 0x7fffffff
    cpopw a3, a1
    li   t6, 0x1f
    beq  a3, t6, t1401_ok
    j    fail
t1401_ok:
t1402: # cpopw 0xffffffff80000000
    li   a0, 1402
    li   a1, 0xffffffff80000000
    cpopw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1402_ok
    j    fail
t1402_ok:
t1403: # cpopw 0x123456789abcdef0
    li   a0, 1403
    li   a1, 0x123456789abcdef0
    cpopw a3, a1
    li   t6, 0x13
    beq  a3, t6, t1403_ok
    j    fail
t1403_ok:
t1404: # cpopw 0xfedcba9876543210
    li   a0, 1404
    li   a1, 0xfedcba9876543210
    cpopw a3, a1
    li   t6, 0xc
    beq  a3, t6, t1404_ok
    j    fail
t1404_ok:
t1405: # cpopw 0x3f
    li   a0, 1405
    li   a1, 0x3f
    cpopw a3, a1
    li   t6, 0x6
    beq  a3, t6, t1405_ok
    j    fail
t1405_ok:
t1406: # cpopw 0x40
    li   a0, 1406
    li   a1, 0x40
    cpopw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1406_ok
    j    fail
t1406_ok:
t1407: # cpopw 0x21
    li   a0, 1407
    li   a1, 0x21
    cpopw a3, a1
    li   t6, 0x2
    beq  a3, t6, t1407_ok
    j    fail
t1407_ok:
t1408: # cpopw 0xff00ff00ff00ff
    li   a0, 1408
    li   a1, 0xff00ff00ff00ff
    cpopw a3, a1
    li   t6, 0x10
    beq  a3, t6, t1408_ok
    j    fail
t1408_ok:
t1409: # cpopw 0x100000000
    li   a0, 1409
    li   a1, 0x100000000
    cpopw a3, a1
    li   t6, 0x0
    beq  a3, t6, t1409_ok
    j    fail
t1409_ok:
t1410: # cpopw 0x8000000000000001
    li   a0, 1410
    li   a1, 0x8000000000000001
    cpopw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1410_ok
    j    fail
t1410_ok:
t1411: # cpopw 0xffff8000
    li   a0, 1411
    li   a1, 0xffff8000
    cpopw a3, a1
    li   t6, 0x11
    beq  a3, t6, t1411_ok
    j    fail
t1411_ok:
t1412: # cpopw 0x102030400000080
    li   a0, 1412
    li   a1, 0x102030400000080
    cpopw a3, a1
    li   t6, 0x1
    beq  a3, t6, t1412_ok
    j    fail
t1412_ok:
t1413: # sext.b 0x0
    li   a0, 1413
    li   a1, 0x0
    sext.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1413_ok
    j    fail
t1413_ok:
t1414: # sext.b 0x1
    li   a0, 1414
    li   a1, 0x1
    sext.b a3, a1
    li   t6, 0x1
    beq  a3, t6, t1414_ok
    j    fail
t1414_ok:
t1415: # sext.b 0xffffffffffffffff
    li   a0, 1415
    li   a1, 0xffffffffffffffff
    sext.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1415_ok
    j    fail
t1415_ok:
t1416: # sext.b 0x7
    li   a0, 1416
    li   a1, 0x7
    sext.b a3, a1
    li   t6, 0x7
    beq  a3, t6, t1416_ok
    j    fail
t1416_ok:
t1417: # sext.b 0xfffffffffffffff9
    li   a0, 1417
    li   a1, 0xfffffffffffffff9
    sext.b a3, a1
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t1417_ok
    j    fail
t1417_ok:
t1418: # sext.b 0x8000000000000000
    li   a0, 1418
    li   a1, 0x8000000000000000
    sext.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1418_ok
    j    fail
t1418_ok:
t1419: # sext.b 0x7fffffffffffffff
    li   a0, 1419
    li   a1, 0x7fffffffffffffff
    sext.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1419_ok
    j    fail
t1419_ok:
t1420: # sext.b 0x80000000
    li   a0, 1420
    li   a1, 0x80000000
    sext.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1420_ok
    j    fail
t1420_ok:
t1421: # sext.b 0x7fffffff
    li   a0, 1421
    li   a1, 0x7fffffff
    sext.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1421_ok
    j    fail
t1421_ok:
t1422: # sext.b 0xffffffff80000000
    li   a0, 1422
    li   a1, 0xffffffff80000000
    sext.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1422_ok
    j    fail
t1422_ok:
t1423: # sext.b 0x123456789abcdef0
    li   a0, 1423
    li   a1, 0x123456789abcdef0
    sext.b a3, a1
    li   t6, 0xfffffffffffffff0
    beq  a3, t6, t1423_ok
    j    fail
t1423_ok:
t1424: # sext.b 0xfedcba9876543210
    li   a0, 1424
    li   a1, 0xfedcba9876543210
    sext.b a3, a1
    li   t6, 0x10
    beq  a3, t6, t1424_ok
    j    fail
t1424_ok:
t1425: # sext.b 0x3f
    li   a0, 1425
    li   a1, 0x3f
    sext.b a3, a1
    li   t6, 0x3f
    beq  a3, t6, t1425_ok
    j    fail
t1425_ok:
t1426: # sext.b 0x40
    li   a0, 1426
    li   a1, 0x40
    sext.b a3, a1
    li   t6, 0x40
    beq  a3, t6, t1426_ok
    j    fail
t1426_ok:
t1427: # sext.b 0x21
    li   a0, 1427
    li   a1, 0x21
    sext.b a3, a1
    li   t6, 0x21
    beq  a3, t6, t1427_ok
    j    fail
t1427_ok:
t1428: # sext.b 0xff00ff00ff00ff
    li   a0, 1428
    li   a1, 0xff00ff00ff00ff
    sext.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1428_ok
    j    fail
t1428_ok:
t1429: # sext.b 0x100000000
    li   a0, 1429
    li   a1, 0x100000000
    sext.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1429_ok
    j    fail
t1429_ok:
t1430: # sext.b 0x8000000000000001
    li   a0, 1430
    li   a1, 0x8000000000000001
    sext.b a3, a1
    li   t6, 0x1
    beq  a3, t6, t1430_ok
    j    fail
t1430_ok:
t1431: # sext.b 0xffff8000
    li   a0, 1431
    li   a1, 0xffff8000
    sext.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1431_ok
    j    fail
t1431_ok:
t1432: # sext.b 0x102030400000080
    li   a0, 1432
    li   a1, 0x102030400000080
    sext.b a3, a1
    li   t6, 0xffffffffffffff80
    beq  a3, t6, t1432_ok
    j    fail
t1432_ok:
t1433: # sext.h 0x0
    li   a0, 1433
    li   a1, 0x0
    sext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1433_ok
    j    fail
t1433_ok:
t1434: # sext.h 0x1
    li   a0, 1434
    li   a1, 0x1
    sext.h a3, a1
    li   t6, 0x1
    beq  a3, t6, t1434_ok
    j    fail
t1434_ok:
t1435: # sext.h 0xffffffffffffffff
    li   a0, 1435
    li   a1, 0xffffffffffffffff
    sext.h a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1435_ok
    j    fail
t1435_ok:
t1436: # sext.h 0x7
    li   a0, 1436
    li   a1, 0x7
    sext.h a3, a1
    li   t6, 0x7
    beq  a3, t6, t1436_ok
    j    fail
t1436_ok:
t1437: # sext.h 0xfffffffffffffff9
    li   a0, 1437
    li   a1, 0xfffffffffffffff9
    sext.h a3, a1
    li   t6, 0xfffffffffffffff9
    beq  a3, t6, t1437_ok
    j    fail
t1437_ok:
t1438: # sext.h 0x8000000000000000
    li   a0, 1438
    li   a1, 0x8000000000000000
    sext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1438_ok
    j    fail
t1438_ok:
t1439: # sext.h 0x7fffffffffffffff
    li   a0, 1439
    li   a1, 0x7fffffffffffffff
    sext.h a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1439_ok
    j    fail
t1439_ok:
t1440: # sext.h 0x80000000
    li   a0, 1440
    li   a1, 0x80000000
    sext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1440_ok
    j    fail
t1440_ok:
t1441: # sext.h 0x7fffffff
    li   a0, 1441
    li   a1, 0x7fffffff
    sext.h a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1441_ok
    j    fail
t1441_ok:
t1442: # sext.h 0xffffffff80000000
    li   a0, 1442
    li   a1, 0xffffffff80000000
    sext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1442_ok
    j    fail
t1442_ok:
t1443: # sext.h 0x123456789abcdef0
    li   a0, 1443
    li   a1, 0x123456789abcdef0
    sext.h a3, a1
    li   t6, 0xffffffffffffdef0
    beq  a3, t6, t1443_ok
    j    fail
t1443_ok:
t1444: # sext.h 0xfedcba9876543210
    li   a0, 1444
    li   a1, 0xfedcba9876543210
    sext.h a3, a1
    li   t6, 0x3210
    beq  a3, t6, t1444_ok
    j    fail
t1444_ok:
t1445: # sext.h 0x3f
    li   a0, 1445
    li   a1, 0x3f
    sext.h a3, a1
    li   t6, 0x3f
    beq  a3, t6, t1445_ok
    j    fail
t1445_ok:
t1446: # sext.h 0x40
    li   a0, 1446
    li   a1, 0x40
    sext.h a3, a1
    li   t6, 0x40
    beq  a3, t6, t1446_ok
    j    fail
t1446_ok:
t1447: # sext.h 0x21
    li   a0, 1447
    li   a1, 0x21
    sext.h a3, a1
    li   t6, 0x21
    beq  a3, t6, t1447_ok
    j    fail
t1447_ok:
t1448: # sext.h 0xff00ff00ff00ff
    li   a0, 1448
    li   a1, 0xff00ff00ff00ff
    sext.h a3, a1
    li   t6, 0xff
    beq  a3, t6, t1448_ok
    j    fail
t1448_ok:
t1449: # sext.h 0x100000000
    li   a0, 1449
    li   a1, 0x100000000
    sext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1449_ok
    j    fail
t1449_ok:
t1450: # sext.h 0x8000000000000001
    li   a0, 1450
    li   a1, 0x8000000000000001
    sext.h a3, a1
    li   t6, 0x1
    beq  a3, t6, t1450_ok
    j    fail
t1450_ok:
t1451: # sext.h 0xffff8000
    li   a0, 1451
    li   a1, 0xffff8000
    sext.h a3, a1
    li   t6, 0xffffffffffff8000
    beq  a3, t6, t1451_ok
    j    fail
t1451_ok:
t1452: # sext.h 0x102030400000080
    li   a0, 1452
    li   a1, 0x102030400000080
    sext.h a3, a1
    li   t6, 0x80
    beq  a3, t6, t1452_ok
    j    fail
t1452_ok:
t1453: # zext.h 0x0
    li   a0, 1453
    li   a1, 0x0
    zext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1453_ok
    j    fail
t1453_ok:
t1454: # zext.h 0x1
    li   a0, 1454
    li   a1, 0x1
    zext.h a3, a1
    li   t6, 0x1
    beq  a3, t6, t1454_ok
    j    fail
t1454_ok:
t1455: # zext.h 0xffffffffffffffff
    li   a0, 1455
    li   a1, 0xffffffffffffffff
    zext.h a3, a1
    li   t6, 0xffff
    beq  a3, t6, t1455_ok
    j    fail
t1455_ok:
t1456: # zext.h 0x7
    li   a0, 1456
    li   a1, 0x7
    zext.h a3, a1
    li   t6, 0x7
    beq  a3, t6, t1456_ok
    j    fail
t1456_ok:
t1457: # zext.h 0xfffffffffffffff9
    li   a0, 1457
    li   a1, 0xfffffffffffffff9
    zext.h a3, a1
    li   t6, 0xfff9
    beq  a3, t6, t1457_ok
    j    fail
t1457_ok:
t1458: # zext.h 0x8000000000000000
    li   a0, 1458
    li   a1, 0x8000000000000000
    zext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1458_ok
    j    fail
t1458_ok:
t1459: # zext.h 0x7fffffffffffffff
    li   a0, 1459
    li   a1, 0x7fffffffffffffff
    zext.h a3, a1
    li   t6, 0xffff
    beq  a3, t6, t1459_ok
    j    fail
t1459_ok:
t1460: # zext.h 0x80000000
    li   a0, 1460
    li   a1, 0x80000000
    zext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1460_ok
    j    fail
t1460_ok:
t1461: # zext.h 0x7fffffff
    li   a0, 1461
    li   a1, 0x7fffffff
    zext.h a3, a1
    li   t6, 0xffff
    beq  a3, t6, t1461_ok
    j    fail
t1461_ok:
t1462: # zext.h 0xffffffff80000000
    li   a0, 1462
    li   a1, 0xffffffff80000000
    zext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1462_ok
    j    fail
t1462_ok:
t1463: # zext.h 0x123456789abcdef0
    li   a0, 1463
    li   a1, 0x123456789abcdef0
    zext.h a3, a1
    li   t6, 0xdef0
    beq  a3, t6, t1463_ok
    j    fail
t1463_ok:
t1464: # zext.h 0xfedcba9876543210
    li   a0, 1464
    li   a1, 0xfedcba9876543210
    zext.h a3, a1
    li   t6, 0x3210
    beq  a3, t6, t1464_ok
    j    fail
t1464_ok:
t1465: # zext.h 0x3f
    li   a0, 1465
    li   a1, 0x3f
    zext.h a3, a1
    li   t6, 0x3f
    beq  a3, t6, t1465_ok
    j    fail
t1465_ok:
t1466: # zext.h 0x40
    li   a0, 1466
    li   a1, 0x40
    zext.h a3, a1
    li   t6, 0x40
    beq  a3, t6, t1466_ok
    j    fail
t1466_ok:
t1467: # zext.h 0x21
    li   a0, 1467
    li   a1, 0x21
    zext.h a3, a1
    li   t6, 0x21
    beq  a3, t6, t1467_ok
    j    fail
t1467_ok:
t1468: # zext.h 0xff00ff00ff00ff
    li   a0, 1468
    li   a1, 0xff00ff00ff00ff
    zext.h a3, a1
    li   t6, 0xff
    beq  a3, t6, t1468_ok
    j    fail
t1468_ok:
t1469: # zext.h 0x100000000
    li   a0, 1469
    li   a1, 0x100000000
    zext.h a3, a1
    li   t6, 0x0
    beq  a3, t6, t1469_ok
    j    fail
t1469_ok:
t1470: # zext.h 0x8000000000000001
    li   a0, 1470
    li   a1, 0x8000000000000001
    zext.h a3, a1
    li   t6, 0x1
    beq  a3, t6, t1470_ok
    j    fail
t1470_ok:
t1471: # zext.h 0xffff8000
    li   a0, 1471
    li   a1, 0xffff8000
    zext.h a3, a1
    li   t6, 0x8000
    beq  a3, t6, t1471_ok
    j    fail
t1471_ok:
t1472: # zext.h 0x102030400000080
    li   a0, 1472
    li   a1, 0x102030400000080
    zext.h a3, a1
    li   t6, 0x80
    beq  a3, t6, t1472_ok
    j    fail
t1472_ok:
t1473: # rev8 0x0
    li   a0, 1473
    li   a1, 0x0
    rev8 a3, a1
    li   t6, 0x0
    beq  a3, t6, t1473_ok
    j    fail
t1473_ok:
t1474: # rev8 0x1
    li   a0, 1474
    li   a1, 0x1
    rev8 a3, a1
    li   t6, 0x100000000000000
    beq  a3, t6, t1474_ok
    j    fail
t1474_ok:
t1475: # rev8 0xffffffffffffffff
    li   a0, 1475
    li   a1, 0xffffffffffffffff
    rev8 a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1475_ok
    j    fail
t1475_ok:
t1476: # rev8 0x7
    li   a0, 1476
    li   a1, 0x7
    rev8 a3, a1
    li   t6, 0x700000000000000
    beq  a3, t6, t1476_ok
    j    fail
t1476_ok:
t1477: # rev8 0xfffffffffffffff9
    li   a0, 1477
    li   a1, 0xfffffffffffffff9
    rev8 a3, a1
    li   t6, 0xf9ffffffffffffff
    beq  a3, t6, t1477_ok
    j    fail
t1477_ok:
t1478: # rev8 0x8000000000000000
    li   a0, 1478
    li   a1, 0x8000000000000000
    rev8 a3, a1
    li   t6, 0x80
    beq  a3, t6, t1478_ok
    j    fail
t1478_ok:
t1479: # rev8 0x7fffffffffffffff
    li   a0, 1479
    li   a1, 0x7fffffffffffffff
    rev8 a3, a1
    li   t6, 0xffffffffffffff7f
    beq  a3, t6, t1479_ok
    j    fail
t1479_ok:
t1480: # rev8 0x80000000
    li   a0, 1480
    li   a1, 0x80000000
    rev8 a3, a1
    li   t6, 0x8000000000
    beq  a3, t6, t1480_ok
    j    fail
t1480_ok:
t1481: # rev8 0x7fffffff
    li   a0, 1481
    li   a1, 0x7fffffff
    rev8 a3, a1
    li   t6, 0xffffff7f00000000
    beq  a3, t6, t1481_ok
    j    fail
t1481_ok:
t1482: # rev8 0xffffffff80000000
    li   a0, 1482
    li   a1, 0xffffffff80000000
    rev8 a3, a1
    li   t6, 0x80ffffffff
    beq  a3, t6, t1482_ok
    j    fail
t1482_ok:
t1483: # rev8 0x123456789abcdef0
    li   a0, 1483
    li   a1, 0x123456789abcdef0
    rev8 a3, a1
    li   t6, 0xf0debc9a78563412
    beq  a3, t6, t1483_ok
    j    fail
t1483_ok:
t1484: # rev8 0xfedcba9876543210
    li   a0, 1484
    li   a1, 0xfedcba9876543210
    rev8 a3, a1
    li   t6, 0x1032547698badcfe
    beq  a3, t6, t1484_ok
    j    fail
t1484_ok:
t1485: # rev8 0x3f
    li   a0, 1485
    li   a1, 0x3f
    rev8 a3, a1
    li   t6, 0x3f00000000000000
    beq  a3, t6, t1485_ok
    j    fail
t1485_ok:
t1486: # rev8 0x40
    li   a0, 1486
    li   a1, 0x40
    rev8 a3, a1
    li   t6, 0x4000000000000000
    beq  a3, t6, t1486_ok
    j    fail
t1486_ok:
t1487: # rev8 0x21
    li   a0, 1487
    li   a1, 0x21
    rev8 a3, a1
    li   t6, 0x2100000000000000
    beq  a3, t6, t1487_ok
    j    fail
t1487_ok:
t1488: # rev8 0xff00ff00ff00ff
    li   a0, 1488
    li   a1, 0xff00ff00ff00ff
    rev8 a3, a1
    li   t6, 0xff00ff00ff00ff00
    beq  a3, t6, t1488_ok
    j    fail
t1488_ok:
t1489: # rev8 0x100000000
    li   a0, 1489
    li   a1, 0x100000000
    rev8 a3, a1
    li   t6, 0x1000000
    beq  a3, t6, t1489_ok
    j    fail
t1489_ok:
t1490: # rev8 0x8000000000000001
    li   a0, 1490
    li   a1, 0x8000000000000001
    rev8 a3, a1
    li   t6, 0x100000000000080
    beq  a3, t6, t1490_ok
    j    fail
t1490_ok:
t1491: # rev8 0xffff8000
    li   a0, 1491
    li   a1, 0xffff8000
    rev8 a3, a1
    li   t6, 0x80ffff00000000
    beq  a3, t6, t1491_ok
    j    fail
t1491_ok:
t1492: # rev8 0x102030400000080
    li   a0, 1492
    li   a1, 0x102030400000080
    rev8 a3, a1
    li   t6, 0x8000000004030201
    beq  a3, t6, t1492_ok
    j    fail
t1492_ok:
t1493: # orc.b 0x0
    li   a0, 1493
    li   a1, 0x0
    orc.b a3, a1
    li   t6, 0x0
    beq  a3, t6, t1493_ok
    j    fail
t1493_ok:
t1494: # orc.b 0x1
    li   a0, 1494
    li   a1, 0x1
    orc.b a3, a1
    li   t6, 0xff
    beq  a3, t6, t1494_ok
    j    fail
t1494_ok:
t1495: # orc.b 0xffffffffffffffff
    li   a0, 1495
    li   a1, 0xffffffffffffffff
    orc.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1495_ok
    j    fail
t1495_ok:
t1496: # orc.b 0x7
    li   a0, 1496
    li   a1, 0x7
    orc.b a3, a1
    li   t6, 0xff
    beq  a3, t6, t1496_ok
    j    fail
t1496_ok:
t1497: # orc.b 0xfffffffffffffff9
    li   a0, 1497
    li   a1, 0xfffffffffffffff9
    orc.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1497_ok
    j    fail
t1497_ok:
t1498: # orc.b 0x8000000000000000
    li   a0, 1498
    li   a1, 0x8000000000000000
    orc.b a3, a1
    li   t6, 0xff00000000000000
    beq  a3, t6, t1498_ok
    j    fail
t1498_ok:
t1499: # orc.b 0x7fffffffffffffff
    li   a0, 1499
    li   a1, 0x7fffffffffffffff
    orc.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1499_ok
    j    fail
t1499_ok:
t1500: # orc.b 0x80000000
    li   a0, 1500
    li   a1, 0x80000000
    orc.b a3, a1
    li   t6, 0xff000000
    beq  a3, t6, t1500_ok
    j    fail
t1500_ok:
t1501: # orc.b 0x7fffffff
    li   a0, 1501
    li   a1, 0x7fffffff
    orc.b a3, a1
    li   t6, 0xffffffff
    beq  a3, t6, t1501_ok
    j    fail
t1501_ok:
t1502: # orc.b 0xffffffff80000000
    li   a0, 1502
    li   a1, 0xffffffff80000000
    orc.b a3, a1
    li   t6, 0xffffffffff000000
    beq  a3, t6, t1502_ok
    j    fail
t1502_ok:
t1503: # orc.b 0x123456789abcdef0
    li   a0, 1503
    li   a1, 0x123456789abcdef0
    orc.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1503_ok
    j    fail
t1503_ok:
t1504: # orc.b 0xfedcba9876543210
    li   a0, 1504
    li   a1, 0xfedcba9876543210
    orc.b a3, a1
    li   t6, 0xffffffffffffffff
    beq  a3, t6, t1504_ok
    j    fail
t1504_ok:
t1505: # orc.b 0x3f
    li   a0, 1505
    li   a1, 0x3f
    orc.b a3, a1
    li   t6, 0xff
    beq  a3, t6, t1505_ok
    j    fail
t1505_ok:
t1506: # orc.b 0x40
    li   a0, 1506
    li   a1, 0x40
    orc.b a3, a1
    li   t6, 0xff
    beq  a3, t6, t1506_ok
    j    fail
t1506_ok:
t1507: # orc.b 0x21
    li   a0, 1507
    li   a1, 0x21
    orc.b a3, a1
    li   t6, 0xff
    beq  a3, t6, t1507_ok
    j    fail
t1507_ok:
t1508: # orc.b 0xff00ff00ff00ff
    li   a0, 1508
    li   a1, 0xff00ff00ff00ff
    orc.b a3, a1
    li   t6, 0xff00ff00ff00ff
    beq  a3, t6, t1508_ok
    j    fail
t1508_ok:
t1509: # orc.b 0x100000000
    li   a0, 1509
    li   a1, 0x100000000
    orc.b a3, a1
    li   t6, 0xff00000000
    beq  a3, t6, t1509_ok
    j    fail
t1509_ok:
t1510: # orc.b 0x8000000000000001
    li   a0, 1510
    li   a1, 0x8000000000000001
    orc.b a3, a1
    li   t6, 0xff000000000000ff
    beq  a3, t6, t1510_ok
    j    fail
t1510_ok:
t1511: # orc.b 0xffff8000
    li   a0, 1511
    li   a1, 0xffff8000
    orc.b a3, a1
    li   t6, 0xffffff00
    beq  a3, t6, t1511_ok
    j    fail
t1511_ok:
t1512: # orc.b 0x102030400000080
    li   a0, 1512
    li   a1, 0x102030400000080
    orc.b a3, a1
    li   t6, 0xffffffff000000ff
    beq  a3, t6, t1512_ok
    j    fail
t1512_ok:
t1513: # sh3add indexes an array of doublewords (forwarded both ways)
    li   a0, 1513
    la   s0, scratch
    li   t0, 3
    li   t1, 0x77
    sd   t1, 24(s0)
    sh3add t2, t0, s0
    ld   a3, 0(t2)
    li   t6, 0x77
    beq  a3, t6, t1513_ok
    j    fail
t1513_ok:
t1514: # max result used right away (2-cycle latency: one stall, then forwarded from MEMORY)
    li   a0, 1514
    li   t0, -5
    li   t1, 7
    max  t2, t0, t1
    sub  a3, t2, t1
    li   t6, 0x0
    beq  a3, t6, t1514_ok
    j    fail
t1514_ok:
t1515: # performance counters are readable and count forward
    li   a0, 1515
    csrr t0, hpmcounter4
    nop
    csrr t1, hpmcounter4
    sltu a3, t1, t0
    li   t6, 0x0
    beq  a3, t6, t1515_ok
    j    fail
t1515_ok:
t1516: # cpop result forwarded to the next instruction
    li   a0, 1516
    li   t0, 0xff
    cpop t1, t0
    addi a3, t1, 1
    li   t6, 0x9
    beq  a3, t6, t1516_ok
    j    fail
t1516_ok:
t1517: # beq 0x0, 0x0
    li   a0, 1517
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    beq a1, a2, t1517_taken
    j    t1517_chk
t1517_taken:
    li   a3, 1
t1517_chk:
    li   t6, 0x1
    beq  a3, t6, t1517_ok
    j    fail
t1517_ok:
t1518: # beq 0xffffffffffffffff, 0x1
    li   a0, 1518
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t1518_taken
    j    t1518_chk
t1518_taken:
    li   a3, 1
t1518_chk:
    li   t6, 0x0
    beq  a3, t6, t1518_ok
    j    fail
t1518_ok:
t1519: # beq 0xfffffffffffffff9, 0x1
    li   a0, 1519
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t1519_taken
    j    t1519_chk
t1519_taken:
    li   a3, 1
t1519_chk:
    li   t6, 0x0
    beq  a3, t6, t1519_ok
    j    fail
t1519_ok:
t1520: # beq 0x8000000000000000, 0x21
    li   a0, 1520
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    beq a1, a2, t1520_taken
    j    t1520_chk
t1520_taken:
    li   a3, 1
t1520_chk:
    li   t6, 0x0
    beq  a3, t6, t1520_ok
    j    fail
t1520_ok:
t1521: # beq 0x80000000, 0x80000000
    li   a0, 1521
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    beq a1, a2, t1521_taken
    j    t1521_chk
t1521_taken:
    li   a3, 1
t1521_chk:
    li   t6, 0x1
    beq  a3, t6, t1521_ok
    j    fail
t1521_ok:
t1522: # beq 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1522
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    beq a1, a2, t1522_taken
    j    t1522_chk
t1522_taken:
    li   a3, 1
t1522_chk:
    li   t6, 0x0
    beq  a3, t6, t1522_ok
    j    fail
t1522_ok:
t1523: # beq 0xfedcba9876543210, 0x1
    li   a0, 1523
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t1523_taken
    j    t1523_chk
t1523_taken:
    li   a3, 1
t1523_chk:
    li   t6, 0x0
    beq  a3, t6, t1523_ok
    j    fail
t1523_ok:
t1524: # beq 0x40, 0x1
    li   a0, 1524
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t1524_taken
    j    t1524_chk
t1524_taken:
    li   a3, 1
t1524_chk:
    li   t6, 0x0
    beq  a3, t6, t1524_ok
    j    fail
t1524_ok:
t1525: # bne 0x0, 0x0
    li   a0, 1525
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bne a1, a2, t1525_taken
    j    t1525_chk
t1525_taken:
    li   a3, 1
t1525_chk:
    li   t6, 0x0
    beq  a3, t6, t1525_ok
    j    fail
t1525_ok:
t1526: # bne 0xffffffffffffffff, 0x1
    li   a0, 1526
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t1526_taken
    j    t1526_chk
t1526_taken:
    li   a3, 1
t1526_chk:
    li   t6, 0x1
    beq  a3, t6, t1526_ok
    j    fail
t1526_ok:
t1527: # bne 0xfffffffffffffff9, 0x1
    li   a0, 1527
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t1527_taken
    j    t1527_chk
t1527_taken:
    li   a3, 1
t1527_chk:
    li   t6, 0x1
    beq  a3, t6, t1527_ok
    j    fail
t1527_ok:
t1528: # bne 0x8000000000000000, 0x21
    li   a0, 1528
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bne a1, a2, t1528_taken
    j    t1528_chk
t1528_taken:
    li   a3, 1
t1528_chk:
    li   t6, 0x1
    beq  a3, t6, t1528_ok
    j    fail
t1528_ok:
t1529: # bne 0x80000000, 0x80000000
    li   a0, 1529
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bne a1, a2, t1529_taken
    j    t1529_chk
t1529_taken:
    li   a3, 1
t1529_chk:
    li   t6, 0x0
    beq  a3, t6, t1529_ok
    j    fail
t1529_ok:
t1530: # bne 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1530
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bne a1, a2, t1530_taken
    j    t1530_chk
t1530_taken:
    li   a3, 1
t1530_chk:
    li   t6, 0x1
    beq  a3, t6, t1530_ok
    j    fail
t1530_ok:
t1531: # bne 0xfedcba9876543210, 0x1
    li   a0, 1531
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t1531_taken
    j    t1531_chk
t1531_taken:
    li   a3, 1
t1531_chk:
    li   t6, 0x1
    beq  a3, t6, t1531_ok
    j    fail
t1531_ok:
t1532: # bne 0x40, 0x1
    li   a0, 1532
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t1532_taken
    j    t1532_chk
t1532_taken:
    li   a3, 1
t1532_chk:
    li   t6, 0x1
    beq  a3, t6, t1532_ok
    j    fail
t1532_ok:
t1533: # blt 0x0, 0x0
    li   a0, 1533
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    blt a1, a2, t1533_taken
    j    t1533_chk
t1533_taken:
    li   a3, 1
t1533_chk:
    li   t6, 0x0
    beq  a3, t6, t1533_ok
    j    fail
t1533_ok:
t1534: # blt 0xffffffffffffffff, 0x1
    li   a0, 1534
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t1534_taken
    j    t1534_chk
t1534_taken:
    li   a3, 1
t1534_chk:
    li   t6, 0x1
    beq  a3, t6, t1534_ok
    j    fail
t1534_ok:
t1535: # blt 0xfffffffffffffff9, 0x1
    li   a0, 1535
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t1535_taken
    j    t1535_chk
t1535_taken:
    li   a3, 1
t1535_chk:
    li   t6, 0x1
    beq  a3, t6, t1535_ok
    j    fail
t1535_ok:
t1536: # blt 0x8000000000000000, 0x21
    li   a0, 1536
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    blt a1, a2, t1536_taken
    j    t1536_chk
t1536_taken:
    li   a3, 1
t1536_chk:
    li   t6, 0x1
    beq  a3, t6, t1536_ok
    j    fail
t1536_ok:
t1537: # blt 0x80000000, 0x80000000
    li   a0, 1537
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    blt a1, a2, t1537_taken
    j    t1537_chk
t1537_taken:
    li   a3, 1
t1537_chk:
    li   t6, 0x0
    beq  a3, t6, t1537_ok
    j    fail
t1537_ok:
t1538: # blt 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1538
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    blt a1, a2, t1538_taken
    j    t1538_chk
t1538_taken:
    li   a3, 1
t1538_chk:
    li   t6, 0x1
    beq  a3, t6, t1538_ok
    j    fail
t1538_ok:
t1539: # blt 0xfedcba9876543210, 0x1
    li   a0, 1539
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t1539_taken
    j    t1539_chk
t1539_taken:
    li   a3, 1
t1539_chk:
    li   t6, 0x1
    beq  a3, t6, t1539_ok
    j    fail
t1539_ok:
t1540: # blt 0x40, 0x1
    li   a0, 1540
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t1540_taken
    j    t1540_chk
t1540_taken:
    li   a3, 1
t1540_chk:
    li   t6, 0x0
    beq  a3, t6, t1540_ok
    j    fail
t1540_ok:
t1541: # bge 0x0, 0x0
    li   a0, 1541
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bge a1, a2, t1541_taken
    j    t1541_chk
t1541_taken:
    li   a3, 1
t1541_chk:
    li   t6, 0x1
    beq  a3, t6, t1541_ok
    j    fail
t1541_ok:
t1542: # bge 0xffffffffffffffff, 0x1
    li   a0, 1542
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t1542_taken
    j    t1542_chk
t1542_taken:
    li   a3, 1
t1542_chk:
    li   t6, 0x0
    beq  a3, t6, t1542_ok
    j    fail
t1542_ok:
t1543: # bge 0xfffffffffffffff9, 0x1
    li   a0, 1543
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t1543_taken
    j    t1543_chk
t1543_taken:
    li   a3, 1
t1543_chk:
    li   t6, 0x0
    beq  a3, t6, t1543_ok
    j    fail
t1543_ok:
t1544: # bge 0x8000000000000000, 0x21
    li   a0, 1544
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bge a1, a2, t1544_taken
    j    t1544_chk
t1544_taken:
    li   a3, 1
t1544_chk:
    li   t6, 0x0
    beq  a3, t6, t1544_ok
    j    fail
t1544_ok:
t1545: # bge 0x80000000, 0x80000000
    li   a0, 1545
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bge a1, a2, t1545_taken
    j    t1545_chk
t1545_taken:
    li   a3, 1
t1545_chk:
    li   t6, 0x1
    beq  a3, t6, t1545_ok
    j    fail
t1545_ok:
t1546: # bge 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1546
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bge a1, a2, t1546_taken
    j    t1546_chk
t1546_taken:
    li   a3, 1
t1546_chk:
    li   t6, 0x0
    beq  a3, t6, t1546_ok
    j    fail
t1546_ok:
t1547: # bge 0xfedcba9876543210, 0x1
    li   a0, 1547
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t1547_taken
    j    t1547_chk
t1547_taken:
    li   a3, 1
t1547_chk:
    li   t6, 0x0
    beq  a3, t6, t1547_ok
    j    fail
t1547_ok:
t1548: # bge 0x40, 0x1
    li   a0, 1548
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t1548_taken
    j    t1548_chk
t1548_taken:
    li   a3, 1
t1548_chk:
    li   t6, 0x1
    beq  a3, t6, t1548_ok
    j    fail
t1548_ok:
t1549: # bltu 0x0, 0x0
    li   a0, 1549
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bltu a1, a2, t1549_taken
    j    t1549_chk
t1549_taken:
    li   a3, 1
t1549_chk:
    li   t6, 0x0
    beq  a3, t6, t1549_ok
    j    fail
t1549_ok:
t1550: # bltu 0xffffffffffffffff, 0x1
    li   a0, 1550
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t1550_taken
    j    t1550_chk
t1550_taken:
    li   a3, 1
t1550_chk:
    li   t6, 0x0
    beq  a3, t6, t1550_ok
    j    fail
t1550_ok:
t1551: # bltu 0xfffffffffffffff9, 0x1
    li   a0, 1551
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t1551_taken
    j    t1551_chk
t1551_taken:
    li   a3, 1
t1551_chk:
    li   t6, 0x0
    beq  a3, t6, t1551_ok
    j    fail
t1551_ok:
t1552: # bltu 0x8000000000000000, 0x21
    li   a0, 1552
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bltu a1, a2, t1552_taken
    j    t1552_chk
t1552_taken:
    li   a3, 1
t1552_chk:
    li   t6, 0x0
    beq  a3, t6, t1552_ok
    j    fail
t1552_ok:
t1553: # bltu 0x80000000, 0x80000000
    li   a0, 1553
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bltu a1, a2, t1553_taken
    j    t1553_chk
t1553_taken:
    li   a3, 1
t1553_chk:
    li   t6, 0x0
    beq  a3, t6, t1553_ok
    j    fail
t1553_ok:
t1554: # bltu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1554
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bltu a1, a2, t1554_taken
    j    t1554_chk
t1554_taken:
    li   a3, 1
t1554_chk:
    li   t6, 0x1
    beq  a3, t6, t1554_ok
    j    fail
t1554_ok:
t1555: # bltu 0xfedcba9876543210, 0x1
    li   a0, 1555
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t1555_taken
    j    t1555_chk
t1555_taken:
    li   a3, 1
t1555_chk:
    li   t6, 0x0
    beq  a3, t6, t1555_ok
    j    fail
t1555_ok:
t1556: # bltu 0x40, 0x1
    li   a0, 1556
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t1556_taken
    j    t1556_chk
t1556_taken:
    li   a3, 1
t1556_chk:
    li   t6, 0x0
    beq  a3, t6, t1556_ok
    j    fail
t1556_ok:
t1557: # bgeu 0x0, 0x0
    li   a0, 1557
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bgeu a1, a2, t1557_taken
    j    t1557_chk
t1557_taken:
    li   a3, 1
t1557_chk:
    li   t6, 0x1
    beq  a3, t6, t1557_ok
    j    fail
t1557_ok:
t1558: # bgeu 0xffffffffffffffff, 0x1
    li   a0, 1558
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t1558_taken
    j    t1558_chk
t1558_taken:
    li   a3, 1
t1558_chk:
    li   t6, 0x1
    beq  a3, t6, t1558_ok
    j    fail
t1558_ok:
t1559: # bgeu 0xfffffffffffffff9, 0x1
    li   a0, 1559
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t1559_taken
    j    t1559_chk
t1559_taken:
    li   a3, 1
t1559_chk:
    li   t6, 0x1
    beq  a3, t6, t1559_ok
    j    fail
t1559_ok:
t1560: # bgeu 0x8000000000000000, 0x21
    li   a0, 1560
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bgeu a1, a2, t1560_taken
    j    t1560_chk
t1560_taken:
    li   a3, 1
t1560_chk:
    li   t6, 0x1
    beq  a3, t6, t1560_ok
    j    fail
t1560_ok:
t1561: # bgeu 0x80000000, 0x80000000
    li   a0, 1561
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bgeu a1, a2, t1561_taken
    j    t1561_chk
t1561_taken:
    li   a3, 1
t1561_chk:
    li   t6, 0x1
    beq  a3, t6, t1561_ok
    j    fail
t1561_ok:
t1562: # bgeu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 1562
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bgeu a1, a2, t1562_taken
    j    t1562_chk
t1562_taken:
    li   a3, 1
t1562_chk:
    li   t6, 0x0
    beq  a3, t6, t1562_ok
    j    fail
t1562_ok:
t1563: # bgeu 0xfedcba9876543210, 0x1
    li   a0, 1563
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t1563_taken
    j    t1563_chk
t1563_taken:
    li   a3, 1
t1563_chk:
    li   t6, 0x1
    beq  a3, t6, t1563_ok
    j    fail
t1563_ok:
t1564: # bgeu 0x40, 0x1
    li   a0, 1564
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t1564_taken
    j    t1564_chk
t1564_taken:
    li   a3, 1
t1564_chk:
    li   t6, 0x1
    beq  a3, t6, t1564_ok
    j    fail
t1564_ok:
t1565: # lui 0x0
    li   a0, 1565
    lui  a3, 0x0
    li   t6, 0x0
    beq  a3, t6, t1565_ok
    j    fail
t1565_ok:
t1566: # auipc 0x0
    li   a0, 1566
t1566_pc:
    auipc a3, 0x0
    la   t5, t1566_pc
    li   t6, 0x0
    add  t5, t5, t6
    beq  a3, t5, t1566_ok
    j    fail
t1566_ok:
t1567: # lui 0x1
    li   a0, 1567
    lui  a3, 0x1
    li   t6, 0x1000
    beq  a3, t6, t1567_ok
    j    fail
t1567_ok:
t1568: # auipc 0x1
    li   a0, 1568
t1568_pc:
    auipc a3, 0x1
    la   t5, t1568_pc
    li   t6, 0x1000
    add  t5, t5, t6
    beq  a3, t5, t1568_ok
    j    fail
t1568_ok:
t1569: # lui 0x7ffff
    li   a0, 1569
    lui  a3, 0x7ffff
    li   t6, 0x7ffff000
    beq  a3, t6, t1569_ok
    j    fail
t1569_ok:
t1570: # auipc 0x7ffff
    li   a0, 1570
t1570_pc:
    auipc a3, 0x7ffff
    la   t5, t1570_pc
    li   t6, 0x7ffff000
    add  t5, t5, t6
    beq  a3, t5, t1570_ok
    j    fail
t1570_ok:
t1571: # lui 0x80000
    li   a0, 1571
    lui  a3, 0x80000
    li   t6, 0xffffffff80000000
    beq  a3, t6, t1571_ok
    j    fail
t1571_ok:
t1572: # auipc 0x80000
    li   a0, 1572
t1572_pc:
    auipc a3, 0x80000
    la   t5, t1572_pc
    li   t6, 0xffffffff80000000
    add  t5, t5, t6
    beq  a3, t5, t1572_ok
    j    fail
t1572_ok:
t1573: # lui 0xfffff
    li   a0, 1573
    lui  a3, 0xfffff
    li   t6, 0xfffffffffffff000
    beq  a3, t6, t1573_ok
    j    fail
t1573_ok:
t1574: # auipc 0xfffff
    li   a0, 1574
t1574_pc:
    auipc a3, 0xfffff
    la   t5, t1574_pc
    li   t6, 0xfffffffffffff000
    add  t5, t5, t6
    beq  a3, t5, t1574_ok
    j    fail
t1574_ok:
t1575: # lui 0x12345
    li   a0, 1575
    lui  a3, 0x12345
    li   t6, 0x12345000
    beq  a3, t6, t1575_ok
    j    fail
t1575_ok:
t1576: # auipc 0x12345
    li   a0, 1576
t1576_pc:
    auipc a3, 0x12345
    la   t5, t1576_pc
    li   t6, 0x12345000
    add  t5, t5, t6
    beq  a3, t5, t1576_ok
    j    fail
t1576_ok:
t1577: # jal link + target
    li   a0, 1577
    jal  ra, t1577_tgt
t1577_ret:
    j    fail
t1577_tgt:
    la   t6, t1577_ret
    beq  ra, t6, t1577_ok
    j    fail
t1577_ok:
t1578: # jalr clears bit 0 of the target
    li   a0, 1578
    la   t0, t1578_tgt
    jalr ra, 1(t0)
t1578_ret:
    j    fail
t1578_tgt:
    la   t6, t1578_ret
    beq  ra, t6, t1578_ok
    j    fail
t1578_ok:
t1579: # jal x0 (no link) and rd=x0 writes are dropped
    li   a0, 1579
    jal  zero, t1579_tgt
    j    fail
t1579_tgt:
    addi zero, zero, 5
    beqz zero, t1579_ok
    j    fail
t1579_ok:
t1580: # sd then every load width
    li   a0, 1580
    la   s0, scratch
    li   t0, 0x8182838485868788
    sd   t0, 0(s0)
t1581: # lb 0
    li   a0, 1581
    lb   a3, 0(s0)
    li   t6, 0xffffffffffffff88
    beq  a3, t6, t1581_ok
    j    fail
t1581_ok:
t1582: # lb 1
    li   a0, 1582
    lb   a3, 1(s0)
    li   t6, 0xffffffffffffff87
    beq  a3, t6, t1582_ok
    j    fail
t1582_ok:
t1583: # lb 2
    li   a0, 1583
    lb   a3, 2(s0)
    li   t6, 0xffffffffffffff86
    beq  a3, t6, t1583_ok
    j    fail
t1583_ok:
t1584: # lb 4
    li   a0, 1584
    lb   a3, 4(s0)
    li   t6, 0xffffffffffffff84
    beq  a3, t6, t1584_ok
    j    fail
t1584_ok:
t1585: # lbu 0
    li   a0, 1585
    lbu   a3, 0(s0)
    li   t6, 0x88
    beq  a3, t6, t1585_ok
    j    fail
t1585_ok:
t1586: # lbu 1
    li   a0, 1586
    lbu   a3, 1(s0)
    li   t6, 0x87
    beq  a3, t6, t1586_ok
    j    fail
t1586_ok:
t1587: # lbu 2
    li   a0, 1587
    lbu   a3, 2(s0)
    li   t6, 0x86
    beq  a3, t6, t1587_ok
    j    fail
t1587_ok:
t1588: # lbu 4
    li   a0, 1588
    lbu   a3, 4(s0)
    li   t6, 0x84
    beq  a3, t6, t1588_ok
    j    fail
t1588_ok:
t1589: # lh 0
    li   a0, 1589
    lh   a3, 0(s0)
    li   t6, 0xffffffffffff8788
    beq  a3, t6, t1589_ok
    j    fail
t1589_ok:
t1590: # lh 2
    li   a0, 1590
    lh   a3, 2(s0)
    li   t6, 0xffffffffffff8586
    beq  a3, t6, t1590_ok
    j    fail
t1590_ok:
t1591: # lh 4
    li   a0, 1591
    lh   a3, 4(s0)
    li   t6, 0xffffffffffff8384
    beq  a3, t6, t1591_ok
    j    fail
t1591_ok:
t1592: # lhu 0
    li   a0, 1592
    lhu   a3, 0(s0)
    li   t6, 0x8788
    beq  a3, t6, t1592_ok
    j    fail
t1592_ok:
t1593: # lhu 2
    li   a0, 1593
    lhu   a3, 2(s0)
    li   t6, 0x8586
    beq  a3, t6, t1593_ok
    j    fail
t1593_ok:
t1594: # lhu 4
    li   a0, 1594
    lhu   a3, 4(s0)
    li   t6, 0x8384
    beq  a3, t6, t1594_ok
    j    fail
t1594_ok:
t1595: # lw 0
    li   a0, 1595
    lw   a3, 0(s0)
    li   t6, 0xffffffff85868788
    beq  a3, t6, t1595_ok
    j    fail
t1595_ok:
t1596: # lw 4
    li   a0, 1596
    lw   a3, 4(s0)
    li   t6, 0xffffffff81828384
    beq  a3, t6, t1596_ok
    j    fail
t1596_ok:
t1597: # lwu 0
    li   a0, 1597
    lwu   a3, 0(s0)
    li   t6, 0x85868788
    beq  a3, t6, t1597_ok
    j    fail
t1597_ok:
t1598: # lwu 4
    li   a0, 1598
    lwu   a3, 4(s0)
    li   t6, 0x81828384
    beq  a3, t6, t1598_ok
    j    fail
t1598_ok:
t1599: # ld 0
    li   a0, 1599
    ld   a3, 0(s0)
    li   t6, 0x8182838485868788
    beq  a3, t6, t1599_ok
    j    fail
t1599_ok:
t1600: # sb then ld
    li   a0, 1600
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x102030405061619
    sb   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x8182838485868719
    beq  a3, t6, t1600_ok
    j    fail
t1600_ok:
t1601: # sh then ld
    li   a0, 1601
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x10203040506252a
    sh   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x818283848586252a
    beq  a3, t6, t1601_ok
    j    fail
t1601_ok:
t1602: # sw then ld
    li   a0, 1602
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x10203040506434c
    sw   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x818283840506434c
    beq  a3, t6, t1602_ok
    j    fail
t1602_ok:
t1603: # sd then ld
    li   a0, 1603
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x102030405068f80
    sd   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x102030405068f80
    beq  a3, t6, t1603_ok
    j    fail
t1603_ok:
t1604: # negative offset
    li   a0, 1604
    addi s1, s0, 16
    ld   a3, -16(s1)
    li   t6, 0x8182838485868788
    beq  a3, t6, t1604_ok
    j    fail
t1604_ok:
t1605: # fence is a no-op
    li   a0, 1605
    li   a3, 9
    fence
    addi a3, a3, 1
    li   t6, 0xa
    beq  a3, t6, t1605_ok
    j    fail
t1605_ok:
t1606: # csrrw returns old value
    li   a0, 1606
    li   t0, 0x5a
    csrw status, t0
    li   t1, 0x33
    csrrw a3, status, t1
    li   t6, 0x5a
    beq  a3, t6, t1606_ok
    j    fail
t1606_ok:
t1607: # csrrw wrote new value
    li   a0, 1607
    csrr a3, status
    li   t6, 0x33
    beq  a3, t6, t1607_ok
    j    fail
t1607_ok:
t1608: # csrrs sets bits
    li   a0, 1608
    li   t0, 0x0c
    csrrs a3, status, t0
    csrr a3, status
    li   t6, 0x3f
    beq  a3, t6, t1608_ok
    j    fail
t1608_ok:
t1609: # csrrc clears bits
    li   a0, 1609
    li   t0, 0x0f
    csrrc a3, status, t0
    csrr a3, status
    li   t6, 0x30
    beq  a3, t6, t1609_ok
    j    fail
t1609_ok:
t1610: # csrrs with x0 does not write
    li   a0, 1610
    csrrs a3, status, x0
    csrr a4, status
    sub  a3, a3, a4
    li   t6, 0x0
    beq  a3, t6, t1610_ok
    j    fail
t1610_ok:
t1611: # csrrwi
    li   a0, 1611
    csrrwi a3, status, 17
    csrr a3, status
    li   t6, 0x11
    beq  a3, t6, t1611_ok
    j    fail
t1611_ok:
t1612: # csrrsi
    li   a0, 1612
    csrrsi a3, status, 8
    csrr a3, status
    li   t6, 0x19
    beq  a3, t6, t1612_ok
    j    fail
t1612_ok:
t1613: # csrrci
    li   a0, 1613
    csrrci a3, status, 1
    csrr a3, status
    li   t6, 0x18
    beq  a3, t6, t1613_ok
    j    fail
t1613_ok:
t1614: # csr read then forward to next instruction
    li   a0, 1614
    csrwi status, 5
    csrr t0, status
    addi a3, t0, 1
    li   t6, 0x6
    beq  a3, t6, t1614_ok
    j    fail
t1614_ok:
t1615: # hartid reads 0
    li   a0, 1615
    csrr a3, hartid
    li   t6, 0x0
    beq  a3, t6, t1615_ok
    j    fail
t1615_ok:
t1616: # mhartid reads 0
    li   a0, 1616
    csrr a3, mhartid
    li   t6, 0x0
    beq  a3, t6, t1616_ok
    j    fail
t1616_ok:
t1617: # ecall traps to mtvec and mret returns (the handler counts in a5)
    li   a0, 1617
    la   t0, trap_handler
    csrw mtvec, t0
    li   a5, 0
    ecall
    ecall
    mv   a3, a5
    li   t6, 0x2
    beq  a3, t6, t1617_ok
    j    fail
t1617_ok:
t1618: # mcause = 11 after ecall
    li   a0, 1618
    ecall
    csrr a3, mcause
    li   t6, 0xb
    beq  a3, t6, t1618_ok
    j    fail
t1618_ok:
t1619: # mcause = 3 after ebreak
    li   a0, 1619
    ebreak
    csrr a3, mcause
    li   t6, 0x3
    beq  a3, t6, t1619_ok
    j    fail
t1619_ok:
t1620: # mepc = address of the ecall (the handler added 4)
    li   a0, 1620
trap_site:
    ecall
    csrr a3, mepc
    la   t1, trap_site
    sub  a3, a3, t1
    li   t6, 0x4
    beq  a3, t6, t1620_ok
    j    fail
t1620_ok:
t1621: # mret restores MIE from MPIE
    li   a0, 1621
    csrsi mstatus, 8
    ecall
    csrr a3, mstatus
    andi a3, a3, 0x88
    li   t6, 0x88
    beq  a3, t6, t1621_ok
    j    fail
t1621_ok:
t1622: # cycle counter moves forward
    li   a0, 1622
    rdcycle t0
    nop
    nop
    rdcycle t1
    sltu a3, t0, t1
    li   t6, 0x1
    beq  a3, t6, t1622_ok
    j    fail
t1622_ok:
t1623: # instret counts 3 retired instructions between reads (second pass: warm instruction cache; 3 nops first so no earlier bubble is still draining)
    li   a0, 1623
    li   t2, 2
t1623_pass:
    nop
    nop
    nop
    rdinstret t0
    nop
    nop
    rdinstret t1
    addi t2, t2, -1
    bnez t2, t1623_pass
    sub  a3, t1, t0
    li   t6, 0x3
    beq  a3, t6, t1623_ok
    j    fail
t1623_ok:
t1624: # cycle counter is read-only
    li   a0, 1624
    rdcycle t0
    csrw cycle, zero
    rdcycle t1
    sltu a3, t0, t1
    li   t6, 0x1
    beq  a3, t6, t1624_ok
    j    fail
t1624_ok:
pass:
    li   a0, 0
    halt               # tohost = 1: PASS
fail:
    slli t0, a0, 1     # a0 holds the failing test number
    ori  t0, t0, 1
    csrw tohost, t0    # tohost = (n << 1) | 1: FAIL in test n
    j    .

trap_handler:          # counts traps in a5 and returns to the instruction after the ecall/ebreak
    addi a5, a5, 1
    csrr t5, mepc
    addi t5, t5, 4
    csrw mepc, t5
    mret

    .align 3
scratch:
    .zero 32
