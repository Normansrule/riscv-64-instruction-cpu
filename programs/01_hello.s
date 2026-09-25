# =============================================================================
# 01_hello.s: print a string through memory-mapped I/O
#
# Storing a byte to address 0x1000_0000 prints it (src/Scratchpad_Memory.sv). The
# loop loads one character with LBU, stores it to the I/O address with SB,
# and stops at the terminating zero byte.
#
#   What to look for: every LBU is followed by a BEQZ that needs the loaded
#                     byte -> a LOAD_STALL each iteration; every "j loop"
#                     is a JAL, redirected in FETCH2 for 1 bubble.
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
    halt

message:
    .string "Hello, RISC-V!\n"
