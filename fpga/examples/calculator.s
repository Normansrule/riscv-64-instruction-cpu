# =============================================================================
# fpga/examples/calculator.s: a calculator and a light painter, on the board's
# switches, buttons, LEDs and seven-segment display
#
# Made for the Digilent Basys 3 (16 switches, 5 buttons, 16 LEDs, 4 digits);
# it runs on every Sixfold board and in the console on the site.
#
# CALCULATOR (at start)
#   switches 15..8 = A, switches 7..0 = B (binary, 0..255 each)
#   the display shows A and B in hexadecimal ("0C.05"), the LEDs copy the switches
#   up = A + B   down = A - B   left = A x B   right = A / B (and the remainder)
#   The answer appears on the display in decimal (in hexadecimal with all four
#   decimal points lit if it needs five digits), on the 16 LEDs in binary, and
#   on the serial port as a sentence. Move a switch to see A and B again.
#   centre = switch to the light painter
# LIGHT PAINTER
#   left / right move the cursor (the blinking LED), up flips the LED under it
#   (one binv instruction), down turns all of them off, centre goes back
#   The display shows "L" and the cursor position.
# From the PC: the keys u d l r c do what the buttons do; q quits.
#
# Every number here is the CPU's own work: the sums, the products, the
# divisions, and the decimal digits (one divide by 10 per digit), and the
# segment patterns (a table lookup per digit). The board only lights what it is told.
# Buttons bounce: a press is accepted after it has been steady for 10 ms.
#
# FPGA-STEPS: sw=0x0C05 wait=20 press=U press=D press=L press=R
# FPGA-STEPS: sw=0xFFFF wait=20 press=L sw=0x0700 wait=20 press=R
# FPGA-STEPS: press=C press=L press=L press=U press=R press=U key=q
# FPGA-EXPECT-OUTPUT: 12 + 5 = 17
# FPGA-EXPECT-OUTPUT: 12 - 5 = 7
# FPGA-EXPECT-OUTPUT: 12 x 5 = 60
# FPGA-EXPECT-OUTPUT: 12 / 5 = 2 remainder 2
# FPGA-EXPECT-OUTPUT: 255 x 255 = 65025
# FPGA-EXPECT-OUTPUT: 7 / 0: no answer
# FPGA-EXPECT-OUTPUT: lights: cursor 1 LEDs 0x0006
# FPGA-EXPECT-LEDS: 0x0006
# FPGA-EXPECT-DISPLAY: 0x38003F06
# =============================================================================
    .equ DEVICES,  0x10000000
    .equ PUTCHAR,  0x00
    .equ LEDS,     0x08
    .equ BUTTONS,  0x10
    .equ UART,     0x18
    .equ CLOCK,    0x28
    .equ MTIME,    0x58
    .equ SWITCHES, 0x68
    .equ DISPLAY,  0x70
    .equ CENTRE,   1              # BUTTONS bits
    .equ UP,       4
    .equ DOWN,     8
    .equ LEFT,     16
    .equ RIGHT,    32

    li   sp, 0xFFF0
    li   s0, DEVICES
    ld   s1, CLOCK(s0)            # cycles per second
    li   t0, 1000
    divu s1, s1, t0               # s1 = cycles per millisecond
    bnez s1, have_clock
    li   s1, 1                    # (the clock rate reads 0 in plain simulation)
have_clock:
    li   s2, 0                    # the buttons as last seen (debounced)
    li   s3, 0                    # mode: 0 calculator, 1 light painter
    li   s4, -1                   # the switches the display last showed (-1: show them now)
    li   s5, 0                    # painter: cursor (0..15)
    li   s6, 0                    # painter: the LED pattern
    la   a0, help
    call puts

# ---------------------------------------------------------------- the main loop: poll, act, repeat
loop:
    call read_input               # a0 = buttons newly pressed (or a key from the PC), 0 = none
    li   t0, -1
    beq  a0, t0, quit
    bnez s3, painter

calculator:
    ld   t0, SWITCHES(s0)
    andi t1, a0, CENTRE
    bnez t1, to_painter
    bnez a0, calculate
    beq  t0, s4, loop             # nothing new
    mv   s4, t0                   # the switches moved: show A and B again
    sh   t0, LEDS(s0)             # the 16 LEDs copy the switches
    srli a0, t0, 8
    call hex_pair                 # A: two hex digits
    slli s7, a0, 16
    li   t1, 0x800000             # the decimal point between A and B
    or   s7, s7, t1
    andi a0, s4, 0xff
    call hex_pair                 # B
    or   a0, a0, s7
    sw   a0, DISPLAY(s0)
    j    loop

calculate:                        # a0 = the pressed button(s): s7 = A, s8 = B
    ld   t0, SWITCHES(s0)
    mv   s4, t0
    srli s7, t0, 8
    andi s7, s7, 0xff
    andi s8, t0, 0xff
    mv   s9, a0
    mv   a0, s7
    call put_decimal
    andi t1, s9, UP
    bnez t1, add_them
    andi t1, s9, DOWN
    bnez t1, subtract_them
    andi t1, s9, LEFT
    bnez t1, multiply_them
    # RIGHT: divide
    li   a0, '/'
    call put_operator
    mv   a0, s8
    call put_decimal
    beqz s8, no_answer
    divu s10, s7, s8              # quotient
    remu s11, s7, s8              # remainder
    la   a0, equals
    call puts
    mv   a0, s10
    call put_decimal
    la   a0, remainder_text
    call puts
    mv   a0, s11
    call put_decimal
    call newline
    mv   a0, s10
    j    show_answer
no_answer:
    la   a0, no_answer_text
    call puts
    li   t0, 0x00795050           # " Err"
    sw   t0, DISPLAY(s0)
    sh   zero, LEDS(s0)
    j    loop
add_them:
    li   a0, '+'
    add  s10, s7, s8
    j    two_operands
subtract_them:
    li   a0, '-'
    sub  s10, s7, s8
    j    two_operands
multiply_them:
    li   a0, 'x'
    mul  s10, s7, s8
two_operands:
    call put_operator
    mv   a0, s8
    call put_decimal
    la   a0, equals
    call puts
    mv   a0, s10
    call put_decimal
    call newline
    mv   a0, s10
show_answer:                      # a0 = the answer: LEDs in binary, display in decimal
    sh   a0, LEDS(s0)
    call number_segments
    sw   a0, DISPLAY(s0)
    j    loop

to_painter:
    li   s3, 1
    la   a0, painter_help
    call puts
    j    show_cursor

# ---------------------------------------------------------------- the light painter
painter:
    andi t1, a0, CENTRE
    bnez t1, to_calculator
    andi t1, a0, LEFT
    beqz t1, local_1
    addi s5, s5, 1                # left: towards LED 15
    andi s5, s5, 15
local_1:  andi t1, a0, RIGHT
    beqz t1, local_2
    addi s5, s5, -1               # right: towards LED 0
    andi s5, s5, 15
local_2:  andi t1, a0, UP
    beqz t1, local_3
    binv s6, s6, s5               # flip the LED under the cursor: one instruction (Zbs)
local_3:  andi t1, a0, DOWN
    beqz t1, local_4
    li   s6, 0
local_4:  beqz a0, blink
    call report_lights
show_cursor:                      # "L 07": L, a blank, the cursor in decimal
    li   t0, 10
    divu a0, s5, t0
    call digit_segments
    slli s7, a0, 8
    remu a0, s5, t0
    call digit_segments
    or   a0, a0, s7
    li   t0, 0x38 << 24           # "L"
    or   a0, a0, t0
    sw   a0, DISPLAY(s0)
blink:                            # the cursor blinks: on for a quarter second, off for a quarter
    ld   t0, MTIME(s0)
    li   t1, 250
    mul  t1, t1, s1               # cycles in 250 ms
    divu t0, t0, t1
    andi t0, t0, 1
    sll  t0, t0, s5
    xor  t0, t0, s6
    sh   t0, LEDS(s0)
    j    loop

to_calculator:
    li   s3, 0
    li   s4, -1                   # show A and B again
    la   a0, help
    call puts
    j    loop

report_lights:                    # "lights: cursor 7 LEDs 0x0080"
    addi sp, sp, -16
    sd   ra, 0(sp)
    la   a0, lights_text
    call puts
    mv   a0, s5
    call put_decimal
    la   a0, leds_text
    call puts
    li   t2, 12
local_5:  srl  t0, s6, t2               # four hex digits, highest first
    andi t0, t0, 15
    la   t1, hex_digits
    add  t1, t1, t0
    lbu  t0, 0(t1)
    sb   t0, PUTCHAR(s0)
    addi t2, t2, -4
    bgez t2, local_5
    call newline
    ld   ra, 0(sp)
    addi sp, sp, 16
    ret

quit:
    beqz s3, local_6
    sh   s6, LEDS(s0)             # leave the pattern without the blinking cursor
local_6:  la   a0, bye
    call puts
    halt

# ---------------------------------------------------------------- input: debounced buttons, or a key
# Returns a0 = the buttons that went from released to pressed, the button of a key typed on the PC
# (u d l r c), -1 for q, or 0.
read_input:
    addi sp, sp, -16
    sd   ra, 0(sp)
    ld   t0, UART(s0)
    andi t1, t0, 1
    beqz t1, buttons
    sd   zero, UART(s0)           # take the byte
    srli t0, t0, 8
    andi t0, t0, 0xff
    li   a0, -1
    li   t1, 'q'
    beq  t0, t1, input_done
    la   t1, keys                 # "udlrc" -> UP DOWN LEFT RIGHT CENTRE
    li   t2, 0
local_7:  add  t3, t1, t2
    lbu  t3, 0(t3)
    beqz t3, buttons              # some other key: ignore it
    beq  t3, t0, local_8
    addi t2, t2, 1
    j    local_7
local_8:  la   t1, key_buttons
    add  t1, t1, t2
    lbu  a0, 0(t1)
    j    input_done
buttons:
    li   a0, 0
    ld   t0, BUTTONS(s0)
    andi t0, t0, 0x3f
    beq  t0, s2, input_done       # no change
    li   a0, 10
    call wait_ms                  # wait until the contacts stop bouncing
    ld   t0, BUTTONS(s0)
    andi t0, t0, 0x3f
    not  t1, s2
    and  a0, t0, t1               # pressed now, not before
    mv   s2, t0
input_done:
    ld   ra, 0(sp)
    addi sp, sp, 16
    ret

wait_ms:                          # a0 milliseconds, timed with MTIME
    mul  t0, a0, s1
    ld   t1, MTIME(s0)
    add  t0, t0, t1
local_9:  ld   t1, MTIME(s0)
    bltu t1, t0, local_9
    ret

# ---------------------------------------------------------------- the display: numbers into segments
digit_segments:                   # a0 = 0..15 -> its seven-segment pattern
    la   t1, segment_table
    add  t1, t1, a0
    lbu  a0, 0(t1)
    ret

hex_pair:                         # a0 = 0..255 -> two hex digits (the high one in bits 15..8)
    addi sp, sp, -16
    sd   ra, 0(sp)
    sd   s9, 8(sp)
    andi s9, a0, 15
    srli a0, a0, 4
    andi a0, a0, 15
    call digit_segments
    slli t2, a0, 8
    mv   a0, s9
    mv   s9, t2
    call digit_segments
    or   a0, a0, s9
    ld   s9, 8(sp)
    ld   ra, 0(sp)
    addi sp, sp, 16
    ret

number_segments:                  # a0 = a number -> four digits of segments
    addi sp, sp, -48
    sd   ra, 0(sp)
    sd   s9, 8(sp)
    sd   s10, 16(sp)
    sd   s11, 24(sp)
    mv   s9, a0
    li   s11, 0                   # the minus sign, if any
    bgez s9, local_10
    neg  s9, s9
    li   s11, 0x40                # "-"
    li   t0, 999
    bgt  s9, t0, local_12              # -1000 or less does not fit: hexadecimal
local_10: li   t0, 9999
    bgt  s9, t0, local_12
    # decimal: divide by 10 until nothing is left; blank the leading zeros
    li   s10, 0                   # the segments so far
    li   t2, 0                    # bit position of the next digit
local_11: li   t0, 10
    remu a0, s9, t0
    divu s9, s9, t0
    sd   t2, 32(sp)               # t2 across the call
    call digit_segments
    ld   t2, 32(sp)
    sll  a0, a0, t2
    or   s10, s10, a0
    addi t2, t2, 8
    bnez s9, local_11
    beqz s11, local_13
    sll  t0, s11, t2              # the minus sign left of the digits
    or   s10, s10, t0
    j    local_13
local_12: li   s10, 0x80808080          # hexadecimal, all four decimal points lit
    li   t2, 0
local_14: andi a0, s9, 15
    srli s9, s9, 4
    sd   t2, 32(sp)
    call digit_segments
    ld   t2, 32(sp)
    sll  a0, a0, t2
    or   s10, s10, a0
    addi t2, t2, 8
    li   t0, 32
    blt  t2, t0, local_14
local_13: mv   a0, s10
    ld   ra, 0(sp)
    ld   s9, 8(sp)
    ld   s10, 16(sp)
    ld   s11, 24(sp)
    addi sp, sp, 48
    ret

# ---------------------------------------------------------------- the serial port
puts:                             # a0 = a string
    lbu  t0, 0(a0)
    beqz t0, local_15
    sb   t0, PUTCHAR(s0)
    addi a0, a0, 1
    j    puts
local_15: ret

newline:
    li   t0, 13
    sb   t0, PUTCHAR(s0)
    li   t0, 10
    sb   t0, PUTCHAR(s0)
    ret

put_operator:                     # " x "
    li   t0, ' '
    sb   t0, PUTCHAR(s0)
    sb   a0, PUTCHAR(s0)
    sb   t0, PUTCHAR(s0)
    ret

put_decimal:                      # a0 = a signed number, in decimal
    bgez a0, local_16
    li   t0, '-'
    sb   t0, PUTCHAR(s0)
    neg  a0, a0
local_16: li   t1, 0                    # digits pushed
    li   t2, 10
local_17: remu t0, a0, t2
    divu a0, a0, t2
    addi t0, t0, '0'
    addi sp, sp, -8
    sd   t0, 0(sp)
    addi t1, t1, 1
    bnez a0, local_17
local_18: ld   t0, 0(sp)
    addi sp, sp, 8
    sb   t0, PUTCHAR(s0)
    addi t1, t1, -1
    bnez t1, local_18
    ret

# ---------------------------------------------------------------- data
segment_table:                    # 0 1 2 3 4 5 6 7 8 9 A b C d E F   (bit 0 = segment a ... bit 6 = g)
    .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
hex_digits:
    .ascii "0123456789ABCDEF"
keys:
    .string "udlrc"
key_buttons:
    .byte UP, DOWN, LEFT, RIGHT, CENTRE
help:
    .string "calculator: switches 15-8 = A and 7-0 = B; up +  down -  left x  right /  centre: light painter\r\n"
painter_help:
    .string "light painter: left/right move the cursor  up flips an LED  down clears  centre: calculator\r\n"
equals:
    .string " = "
remainder_text:
    .string " remainder "
no_answer_text:
    .string ": no answer (division by zero)\r\n"
lights_text:
    .string "lights: cursor "
leds_text:
    .string " LEDs 0x"
bye:
    .string "bye\r\n"
