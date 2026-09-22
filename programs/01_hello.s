# =============================================================================
# 01_hello.s — print a string through memory-mapped I/O
#
# Storing a byte to address 0x1000_0000 prints it (see rtl/memory.v). The
# loop loads one character with LBU, stores it to the I/O address with SB,
# and stops at the terminating zero byte.
#
#   What to look for: every LBU is followed by a BEQZ that needs the loaded
#                     byte -> a LOAD-USE stall each iteration; every taken
#                     "j loop" flushes 3 instructions.
# EXPECT-OUTPUT: Hello, RISC-V!\n
# EXPECT: a0 = 15
# =============================================================================
    la   t0, message         # t0 = pointer to the string
    li   t1, 0x10000000      # t1 = address of the "putchar" register
    li   a0, 0               # a0 = characters printed
loop:
    lbu  t2, 0(t0)           # load one character (zero-extended)
    beqz t2, done            # zero byte = end of string
    sb   t2, 0(t1)           # print it
    addi t0, t0, 1
    addi a0, a0, 1
    j    loop
done:
    ecall

message:
    .string "Hello, RISC-V!\n"
