# =============================================================================
# tests/isa_selfcheck.s: AUTO-GENERATED self-checking test of every RV64IM +
# Zicsr instruction (859 test cases, expected values computed by an independent
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
t757: # beq 0x0, 0x0
    li   a0, 757
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    beq a1, a2, t757_taken
    j    t757_chk
t757_taken:
    li   a3, 1
t757_chk:
    li   t6, 0x1
    beq  a3, t6, t757_ok
    j    fail
t757_ok:
t758: # beq 0xffffffffffffffff, 0x1
    li   a0, 758
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t758_taken
    j    t758_chk
t758_taken:
    li   a3, 1
t758_chk:
    li   t6, 0x0
    beq  a3, t6, t758_ok
    j    fail
t758_ok:
t759: # beq 0xfffffffffffffff9, 0x1
    li   a0, 759
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t759_taken
    j    t759_chk
t759_taken:
    li   a3, 1
t759_chk:
    li   t6, 0x0
    beq  a3, t6, t759_ok
    j    fail
t759_ok:
t760: # beq 0x8000000000000000, 0x21
    li   a0, 760
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    beq a1, a2, t760_taken
    j    t760_chk
t760_taken:
    li   a3, 1
t760_chk:
    li   t6, 0x0
    beq  a3, t6, t760_ok
    j    fail
t760_ok:
t761: # beq 0x80000000, 0x80000000
    li   a0, 761
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    beq a1, a2, t761_taken
    j    t761_chk
t761_taken:
    li   a3, 1
t761_chk:
    li   t6, 0x1
    beq  a3, t6, t761_ok
    j    fail
t761_ok:
t762: # beq 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 762
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    beq a1, a2, t762_taken
    j    t762_chk
t762_taken:
    li   a3, 1
t762_chk:
    li   t6, 0x0
    beq  a3, t6, t762_ok
    j    fail
t762_ok:
t763: # beq 0xfedcba9876543210, 0x1
    li   a0, 763
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t763_taken
    j    t763_chk
t763_taken:
    li   a3, 1
t763_chk:
    li   t6, 0x0
    beq  a3, t6, t763_ok
    j    fail
t763_ok:
t764: # beq 0x40, 0x1
    li   a0, 764
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    beq a1, a2, t764_taken
    j    t764_chk
t764_taken:
    li   a3, 1
t764_chk:
    li   t6, 0x0
    beq  a3, t6, t764_ok
    j    fail
t764_ok:
t765: # bne 0x0, 0x0
    li   a0, 765
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bne a1, a2, t765_taken
    j    t765_chk
t765_taken:
    li   a3, 1
t765_chk:
    li   t6, 0x0
    beq  a3, t6, t765_ok
    j    fail
t765_ok:
t766: # bne 0xffffffffffffffff, 0x1
    li   a0, 766
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t766_taken
    j    t766_chk
t766_taken:
    li   a3, 1
t766_chk:
    li   t6, 0x1
    beq  a3, t6, t766_ok
    j    fail
t766_ok:
t767: # bne 0xfffffffffffffff9, 0x1
    li   a0, 767
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t767_taken
    j    t767_chk
t767_taken:
    li   a3, 1
t767_chk:
    li   t6, 0x1
    beq  a3, t6, t767_ok
    j    fail
t767_ok:
t768: # bne 0x8000000000000000, 0x21
    li   a0, 768
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bne a1, a2, t768_taken
    j    t768_chk
t768_taken:
    li   a3, 1
t768_chk:
    li   t6, 0x1
    beq  a3, t6, t768_ok
    j    fail
t768_ok:
t769: # bne 0x80000000, 0x80000000
    li   a0, 769
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bne a1, a2, t769_taken
    j    t769_chk
t769_taken:
    li   a3, 1
t769_chk:
    li   t6, 0x0
    beq  a3, t6, t769_ok
    j    fail
t769_ok:
t770: # bne 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 770
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bne a1, a2, t770_taken
    j    t770_chk
t770_taken:
    li   a3, 1
t770_chk:
    li   t6, 0x1
    beq  a3, t6, t770_ok
    j    fail
t770_ok:
t771: # bne 0xfedcba9876543210, 0x1
    li   a0, 771
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t771_taken
    j    t771_chk
t771_taken:
    li   a3, 1
t771_chk:
    li   t6, 0x1
    beq  a3, t6, t771_ok
    j    fail
t771_ok:
t772: # bne 0x40, 0x1
    li   a0, 772
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bne a1, a2, t772_taken
    j    t772_chk
t772_taken:
    li   a3, 1
t772_chk:
    li   t6, 0x1
    beq  a3, t6, t772_ok
    j    fail
t772_ok:
t773: # blt 0x0, 0x0
    li   a0, 773
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    blt a1, a2, t773_taken
    j    t773_chk
t773_taken:
    li   a3, 1
t773_chk:
    li   t6, 0x0
    beq  a3, t6, t773_ok
    j    fail
t773_ok:
t774: # blt 0xffffffffffffffff, 0x1
    li   a0, 774
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t774_taken
    j    t774_chk
t774_taken:
    li   a3, 1
t774_chk:
    li   t6, 0x1
    beq  a3, t6, t774_ok
    j    fail
t774_ok:
t775: # blt 0xfffffffffffffff9, 0x1
    li   a0, 775
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t775_taken
    j    t775_chk
t775_taken:
    li   a3, 1
t775_chk:
    li   t6, 0x1
    beq  a3, t6, t775_ok
    j    fail
t775_ok:
t776: # blt 0x8000000000000000, 0x21
    li   a0, 776
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    blt a1, a2, t776_taken
    j    t776_chk
t776_taken:
    li   a3, 1
t776_chk:
    li   t6, 0x1
    beq  a3, t6, t776_ok
    j    fail
t776_ok:
t777: # blt 0x80000000, 0x80000000
    li   a0, 777
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    blt a1, a2, t777_taken
    j    t777_chk
t777_taken:
    li   a3, 1
t777_chk:
    li   t6, 0x0
    beq  a3, t6, t777_ok
    j    fail
t777_ok:
t778: # blt 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 778
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    blt a1, a2, t778_taken
    j    t778_chk
t778_taken:
    li   a3, 1
t778_chk:
    li   t6, 0x1
    beq  a3, t6, t778_ok
    j    fail
t778_ok:
t779: # blt 0xfedcba9876543210, 0x1
    li   a0, 779
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t779_taken
    j    t779_chk
t779_taken:
    li   a3, 1
t779_chk:
    li   t6, 0x1
    beq  a3, t6, t779_ok
    j    fail
t779_ok:
t780: # blt 0x40, 0x1
    li   a0, 780
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    blt a1, a2, t780_taken
    j    t780_chk
t780_taken:
    li   a3, 1
t780_chk:
    li   t6, 0x0
    beq  a3, t6, t780_ok
    j    fail
t780_ok:
t781: # bge 0x0, 0x0
    li   a0, 781
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bge a1, a2, t781_taken
    j    t781_chk
t781_taken:
    li   a3, 1
t781_chk:
    li   t6, 0x1
    beq  a3, t6, t781_ok
    j    fail
t781_ok:
t782: # bge 0xffffffffffffffff, 0x1
    li   a0, 782
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t782_taken
    j    t782_chk
t782_taken:
    li   a3, 1
t782_chk:
    li   t6, 0x0
    beq  a3, t6, t782_ok
    j    fail
t782_ok:
t783: # bge 0xfffffffffffffff9, 0x1
    li   a0, 783
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t783_taken
    j    t783_chk
t783_taken:
    li   a3, 1
t783_chk:
    li   t6, 0x0
    beq  a3, t6, t783_ok
    j    fail
t783_ok:
t784: # bge 0x8000000000000000, 0x21
    li   a0, 784
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bge a1, a2, t784_taken
    j    t784_chk
t784_taken:
    li   a3, 1
t784_chk:
    li   t6, 0x0
    beq  a3, t6, t784_ok
    j    fail
t784_ok:
t785: # bge 0x80000000, 0x80000000
    li   a0, 785
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bge a1, a2, t785_taken
    j    t785_chk
t785_taken:
    li   a3, 1
t785_chk:
    li   t6, 0x1
    beq  a3, t6, t785_ok
    j    fail
t785_ok:
t786: # bge 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 786
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bge a1, a2, t786_taken
    j    t786_chk
t786_taken:
    li   a3, 1
t786_chk:
    li   t6, 0x0
    beq  a3, t6, t786_ok
    j    fail
t786_ok:
t787: # bge 0xfedcba9876543210, 0x1
    li   a0, 787
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t787_taken
    j    t787_chk
t787_taken:
    li   a3, 1
t787_chk:
    li   t6, 0x0
    beq  a3, t6, t787_ok
    j    fail
t787_ok:
t788: # bge 0x40, 0x1
    li   a0, 788
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bge a1, a2, t788_taken
    j    t788_chk
t788_taken:
    li   a3, 1
t788_chk:
    li   t6, 0x1
    beq  a3, t6, t788_ok
    j    fail
t788_ok:
t789: # bltu 0x0, 0x0
    li   a0, 789
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bltu a1, a2, t789_taken
    j    t789_chk
t789_taken:
    li   a3, 1
t789_chk:
    li   t6, 0x0
    beq  a3, t6, t789_ok
    j    fail
t789_ok:
t790: # bltu 0xffffffffffffffff, 0x1
    li   a0, 790
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t790_taken
    j    t790_chk
t790_taken:
    li   a3, 1
t790_chk:
    li   t6, 0x0
    beq  a3, t6, t790_ok
    j    fail
t790_ok:
t791: # bltu 0xfffffffffffffff9, 0x1
    li   a0, 791
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t791_taken
    j    t791_chk
t791_taken:
    li   a3, 1
t791_chk:
    li   t6, 0x0
    beq  a3, t6, t791_ok
    j    fail
t791_ok:
t792: # bltu 0x8000000000000000, 0x21
    li   a0, 792
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bltu a1, a2, t792_taken
    j    t792_chk
t792_taken:
    li   a3, 1
t792_chk:
    li   t6, 0x0
    beq  a3, t6, t792_ok
    j    fail
t792_ok:
t793: # bltu 0x80000000, 0x80000000
    li   a0, 793
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bltu a1, a2, t793_taken
    j    t793_chk
t793_taken:
    li   a3, 1
t793_chk:
    li   t6, 0x0
    beq  a3, t6, t793_ok
    j    fail
t793_ok:
t794: # bltu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 794
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bltu a1, a2, t794_taken
    j    t794_chk
t794_taken:
    li   a3, 1
t794_chk:
    li   t6, 0x1
    beq  a3, t6, t794_ok
    j    fail
t794_ok:
t795: # bltu 0xfedcba9876543210, 0x1
    li   a0, 795
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t795_taken
    j    t795_chk
t795_taken:
    li   a3, 1
t795_chk:
    li   t6, 0x0
    beq  a3, t6, t795_ok
    j    fail
t795_ok:
t796: # bltu 0x40, 0x1
    li   a0, 796
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bltu a1, a2, t796_taken
    j    t796_chk
t796_taken:
    li   a3, 1
t796_chk:
    li   t6, 0x0
    beq  a3, t6, t796_ok
    j    fail
t796_ok:
t797: # bgeu 0x0, 0x0
    li   a0, 797
    li   a1, 0x0
    li   a2, 0x0
    li   a3, 0
    bgeu a1, a2, t797_taken
    j    t797_chk
t797_taken:
    li   a3, 1
t797_chk:
    li   t6, 0x1
    beq  a3, t6, t797_ok
    j    fail
t797_ok:
t798: # bgeu 0xffffffffffffffff, 0x1
    li   a0, 798
    li   a1, 0xffffffffffffffff
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t798_taken
    j    t798_chk
t798_taken:
    li   a3, 1
t798_chk:
    li   t6, 0x1
    beq  a3, t6, t798_ok
    j    fail
t798_ok:
t799: # bgeu 0xfffffffffffffff9, 0x1
    li   a0, 799
    li   a1, 0xfffffffffffffff9
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t799_taken
    j    t799_chk
t799_taken:
    li   a3, 1
t799_chk:
    li   t6, 0x1
    beq  a3, t6, t799_ok
    j    fail
t799_ok:
t800: # bgeu 0x8000000000000000, 0x21
    li   a0, 800
    li   a1, 0x8000000000000000
    li   a2, 0x21
    li   a3, 0
    bgeu a1, a2, t800_taken
    j    t800_chk
t800_taken:
    li   a3, 1
t800_chk:
    li   t6, 0x1
    beq  a3, t6, t800_ok
    j    fail
t800_ok:
t801: # bgeu 0x80000000, 0x80000000
    li   a0, 801
    li   a1, 0x80000000
    li   a2, 0x80000000
    li   a3, 0
    bgeu a1, a2, t801_taken
    j    t801_chk
t801_taken:
    li   a3, 1
t801_chk:
    li   t6, 0x1
    beq  a3, t6, t801_ok
    j    fail
t801_ok:
t802: # bgeu 0xffffffff80000000, 0xffffffffffffffff
    li   a0, 802
    li   a1, 0xffffffff80000000
    li   a2, 0xffffffffffffffff
    li   a3, 0
    bgeu a1, a2, t802_taken
    j    t802_chk
t802_taken:
    li   a3, 1
t802_chk:
    li   t6, 0x0
    beq  a3, t6, t802_ok
    j    fail
t802_ok:
t803: # bgeu 0xfedcba9876543210, 0x1
    li   a0, 803
    li   a1, 0xfedcba9876543210
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t803_taken
    j    t803_chk
t803_taken:
    li   a3, 1
t803_chk:
    li   t6, 0x1
    beq  a3, t6, t803_ok
    j    fail
t803_ok:
t804: # bgeu 0x40, 0x1
    li   a0, 804
    li   a1, 0x40
    li   a2, 0x1
    li   a3, 0
    bgeu a1, a2, t804_taken
    j    t804_chk
t804_taken:
    li   a3, 1
t804_chk:
    li   t6, 0x1
    beq  a3, t6, t804_ok
    j    fail
t804_ok:
t805: # lui 0x0
    li   a0, 805
    lui  a3, 0x0
    li   t6, 0x0
    beq  a3, t6, t805_ok
    j    fail
t805_ok:
t806: # auipc 0x0
    li   a0, 806
t806_pc:
    auipc a3, 0x0
    la   t5, t806_pc
    li   t6, 0x0
    add  t5, t5, t6
    beq  a3, t5, t806_ok
    j    fail
t806_ok:
t807: # lui 0x1
    li   a0, 807
    lui  a3, 0x1
    li   t6, 0x1000
    beq  a3, t6, t807_ok
    j    fail
t807_ok:
t808: # auipc 0x1
    li   a0, 808
t808_pc:
    auipc a3, 0x1
    la   t5, t808_pc
    li   t6, 0x1000
    add  t5, t5, t6
    beq  a3, t5, t808_ok
    j    fail
t808_ok:
t809: # lui 0x7ffff
    li   a0, 809
    lui  a3, 0x7ffff
    li   t6, 0x7ffff000
    beq  a3, t6, t809_ok
    j    fail
t809_ok:
t810: # auipc 0x7ffff
    li   a0, 810
t810_pc:
    auipc a3, 0x7ffff
    la   t5, t810_pc
    li   t6, 0x7ffff000
    add  t5, t5, t6
    beq  a3, t5, t810_ok
    j    fail
t810_ok:
t811: # lui 0x80000
    li   a0, 811
    lui  a3, 0x80000
    li   t6, 0xffffffff80000000
    beq  a3, t6, t811_ok
    j    fail
t811_ok:
t812: # auipc 0x80000
    li   a0, 812
t812_pc:
    auipc a3, 0x80000
    la   t5, t812_pc
    li   t6, 0xffffffff80000000
    add  t5, t5, t6
    beq  a3, t5, t812_ok
    j    fail
t812_ok:
t813: # lui 0xfffff
    li   a0, 813
    lui  a3, 0xfffff
    li   t6, 0xfffffffffffff000
    beq  a3, t6, t813_ok
    j    fail
t813_ok:
t814: # auipc 0xfffff
    li   a0, 814
t814_pc:
    auipc a3, 0xfffff
    la   t5, t814_pc
    li   t6, 0xfffffffffffff000
    add  t5, t5, t6
    beq  a3, t5, t814_ok
    j    fail
t814_ok:
t815: # lui 0x12345
    li   a0, 815
    lui  a3, 0x12345
    li   t6, 0x12345000
    beq  a3, t6, t815_ok
    j    fail
t815_ok:
t816: # auipc 0x12345
    li   a0, 816
t816_pc:
    auipc a3, 0x12345
    la   t5, t816_pc
    li   t6, 0x12345000
    add  t5, t5, t6
    beq  a3, t5, t816_ok
    j    fail
t816_ok:
t817: # jal link + target
    li   a0, 817
    jal  ra, t817_tgt
t817_ret:
    j    fail
t817_tgt:
    la   t6, t817_ret
    beq  ra, t6, t817_ok
    j    fail
t817_ok:
t818: # jalr clears bit 0 of the target
    li   a0, 818
    la   t0, t818_tgt
    jalr ra, 1(t0)
t818_ret:
    j    fail
t818_tgt:
    la   t6, t818_ret
    beq  ra, t6, t818_ok
    j    fail
t818_ok:
t819: # jal x0 (no link) and rd=x0 writes are dropped
    li   a0, 819
    jal  zero, t819_tgt
    j    fail
t819_tgt:
    addi zero, zero, 5
    beqz zero, t819_ok
    j    fail
t819_ok:
t820: # sd then every load width
    li   a0, 820
    la   s0, scratch
    li   t0, 0x8182838485868788
    sd   t0, 0(s0)
t821: # lb 0
    li   a0, 821
    lb   a3, 0(s0)
    li   t6, 0xffffffffffffff88
    beq  a3, t6, t821_ok
    j    fail
t821_ok:
t822: # lb 1
    li   a0, 822
    lb   a3, 1(s0)
    li   t6, 0xffffffffffffff87
    beq  a3, t6, t822_ok
    j    fail
t822_ok:
t823: # lb 2
    li   a0, 823
    lb   a3, 2(s0)
    li   t6, 0xffffffffffffff86
    beq  a3, t6, t823_ok
    j    fail
t823_ok:
t824: # lb 4
    li   a0, 824
    lb   a3, 4(s0)
    li   t6, 0xffffffffffffff84
    beq  a3, t6, t824_ok
    j    fail
t824_ok:
t825: # lbu 0
    li   a0, 825
    lbu   a3, 0(s0)
    li   t6, 0x88
    beq  a3, t6, t825_ok
    j    fail
t825_ok:
t826: # lbu 1
    li   a0, 826
    lbu   a3, 1(s0)
    li   t6, 0x87
    beq  a3, t6, t826_ok
    j    fail
t826_ok:
t827: # lbu 2
    li   a0, 827
    lbu   a3, 2(s0)
    li   t6, 0x86
    beq  a3, t6, t827_ok
    j    fail
t827_ok:
t828: # lbu 4
    li   a0, 828
    lbu   a3, 4(s0)
    li   t6, 0x84
    beq  a3, t6, t828_ok
    j    fail
t828_ok:
t829: # lh 0
    li   a0, 829
    lh   a3, 0(s0)
    li   t6, 0xffffffffffff8788
    beq  a3, t6, t829_ok
    j    fail
t829_ok:
t830: # lh 2
    li   a0, 830
    lh   a3, 2(s0)
    li   t6, 0xffffffffffff8586
    beq  a3, t6, t830_ok
    j    fail
t830_ok:
t831: # lh 4
    li   a0, 831
    lh   a3, 4(s0)
    li   t6, 0xffffffffffff8384
    beq  a3, t6, t831_ok
    j    fail
t831_ok:
t832: # lhu 0
    li   a0, 832
    lhu   a3, 0(s0)
    li   t6, 0x8788
    beq  a3, t6, t832_ok
    j    fail
t832_ok:
t833: # lhu 2
    li   a0, 833
    lhu   a3, 2(s0)
    li   t6, 0x8586
    beq  a3, t6, t833_ok
    j    fail
t833_ok:
t834: # lhu 4
    li   a0, 834
    lhu   a3, 4(s0)
    li   t6, 0x8384
    beq  a3, t6, t834_ok
    j    fail
t834_ok:
t835: # lw 0
    li   a0, 835
    lw   a3, 0(s0)
    li   t6, 0xffffffff85868788
    beq  a3, t6, t835_ok
    j    fail
t835_ok:
t836: # lw 4
    li   a0, 836
    lw   a3, 4(s0)
    li   t6, 0xffffffff81828384
    beq  a3, t6, t836_ok
    j    fail
t836_ok:
t837: # lwu 0
    li   a0, 837
    lwu   a3, 0(s0)
    li   t6, 0x85868788
    beq  a3, t6, t837_ok
    j    fail
t837_ok:
t838: # lwu 4
    li   a0, 838
    lwu   a3, 4(s0)
    li   t6, 0x81828384
    beq  a3, t6, t838_ok
    j    fail
t838_ok:
t839: # ld 0
    li   a0, 839
    ld   a3, 0(s0)
    li   t6, 0x8182838485868788
    beq  a3, t6, t839_ok
    j    fail
t839_ok:
t840: # sb then ld
    li   a0, 840
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x102030405061619
    sb   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x8182838485868719
    beq  a3, t6, t840_ok
    j    fail
t840_ok:
t841: # sh then ld
    li   a0, 841
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x10203040506252a
    sh   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x818283848586252a
    beq  a3, t6, t841_ok
    j    fail
t841_ok:
t842: # sw then ld
    li   a0, 842
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x10203040506434c
    sw   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x818283840506434c
    beq  a3, t6, t842_ok
    j    fail
t842_ok:
t843: # sd then ld
    li   a0, 843
    li   t0, 0x8182838485868788
    sd   t0, 8(s0)
    li   t1, 0x102030405068f80
    sd   t1, 8(s0)
    ld   a3, 8(s0)
    li   t6, 0x102030405068f80
    beq  a3, t6, t843_ok
    j    fail
t843_ok:
t844: # negative offset
    li   a0, 844
    addi s1, s0, 16
    ld   a3, -16(s1)
    li   t6, 0x8182838485868788
    beq  a3, t6, t844_ok
    j    fail
t844_ok:
t845: # fence is a no-op
    li   a0, 845
    li   a3, 9
    fence
    addi a3, a3, 1
    li   t6, 0xa
    beq  a3, t6, t845_ok
    j    fail
t845_ok:
t846: # csrrw returns old value
    li   a0, 846
    li   t0, 0x5a
    csrw status, t0
    li   t1, 0x33
    csrrw a3, status, t1
    li   t6, 0x5a
    beq  a3, t6, t846_ok
    j    fail
t846_ok:
t847: # csrrw wrote new value
    li   a0, 847
    csrr a3, status
    li   t6, 0x33
    beq  a3, t6, t847_ok
    j    fail
t847_ok:
t848: # csrrs sets bits
    li   a0, 848
    li   t0, 0x0c
    csrrs a3, status, t0
    csrr a3, status
    li   t6, 0x3f
    beq  a3, t6, t848_ok
    j    fail
t848_ok:
t849: # csrrc clears bits
    li   a0, 849
    li   t0, 0x0f
    csrrc a3, status, t0
    csrr a3, status
    li   t6, 0x30
    beq  a3, t6, t849_ok
    j    fail
t849_ok:
t850: # csrrs with x0 does not write
    li   a0, 850
    csrrs a3, status, x0
    csrr a4, status
    sub  a3, a3, a4
    li   t6, 0x0
    beq  a3, t6, t850_ok
    j    fail
t850_ok:
t851: # csrrwi
    li   a0, 851
    csrrwi a3, status, 17
    csrr a3, status
    li   t6, 0x11
    beq  a3, t6, t851_ok
    j    fail
t851_ok:
t852: # csrrsi
    li   a0, 852
    csrrsi a3, status, 8
    csrr a3, status
    li   t6, 0x19
    beq  a3, t6, t852_ok
    j    fail
t852_ok:
t853: # csrrci
    li   a0, 853
    csrrci a3, status, 1
    csrr a3, status
    li   t6, 0x18
    beq  a3, t6, t853_ok
    j    fail
t853_ok:
t854: # csr read then forward to next instruction
    li   a0, 854
    csrwi status, 5
    csrr t0, status
    addi a3, t0, 1
    li   t6, 0x6
    beq  a3, t6, t854_ok
    j    fail
t854_ok:
t855: # hartid reads 0
    li   a0, 855
    csrr a3, hartid
    li   t6, 0x0
    beq  a3, t6, t855_ok
    j    fail
t855_ok:
t856: # mhartid reads 0
    li   a0, 856
    csrr a3, mhartid
    li   t6, 0x0
    beq  a3, t6, t856_ok
    j    fail
t856_ok:
t857: # cycle counter moves forward
    li   a0, 857
    rdcycle t0
    nop
    nop
    rdcycle t1
    sltu a3, t0, t1
    li   t6, 0x1
    beq  a3, t6, t857_ok
    j    fail
t857_ok:
t858: # instret counts 3 retired instructions between reads (3 nops first so no earlier bubble is still draining)
    li   a0, 858
    nop
    nop
    nop
    rdinstret t0
    nop
    nop
    rdinstret t1
    sub  a3, t1, t0
    li   t6, 0x3
    beq  a3, t6, t858_ok
    j    fail
t858_ok:
t859: # cycle counter is read-only
    li   a0, 859
    rdcycle t0
    csrw cycle, zero
    rdcycle t1
    sltu a3, t0, t1
    li   t6, 0x1
    beq  a3, t6, t859_ok
    j    fail
t859_ok:
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
