#!/usr/bin/env python3
# =============================================================================
# tools/fpga_load.py: send a program to the Sixfold FPGA computer and show what it prints
#
#   python3 tools/fpga_load.py programs/05_fibonacci.s            (assembles it with tools/rv.mjs)
#   python3 tools/fpga_load.py build/05_fibonacci.hex --port /dev/ttyUSB0
#   python3 tools/fpga_load.py programs/01_hello.s --port COM5    (Windows)
#
# The boot firmware (fpga/firmware/bios.s) must be at its "sixfold>" prompt (press the board's reset
# button if a program is still running). Protocol, all numbers little-endian:
#   'l'  address (4 bytes)  length (4 bytes)  the bytes  checksum (4 bytes, sum of the bytes mod 2^32)
#   'r'  run: the firmware restarts the core at 0x2000
# The script then prints everything the board sends until the firmware reports
# "program finished: PASS in N cycles" (or FAIL), and exits with 0 for PASS.
#
# Needs pyserial:  pip install pyserial
# Serial port: Linux /dev/ttyUSB0 (ULX3S, Arty: the second of two ports, often /dev/ttyUSB1),
# macOS /dev/cu.usbserial-*, Windows COMn. WSL: use the Windows COM port through usbipd, or run
# this script with Windows Python.
# =============================================================================
import argparse, os, re, subprocess, sys, time


def read_hex(path):
    """The $readmemh image tools/rv.mjs writes: '@address' lines and one byte per line."""
    memory, address = {}, 0
    for line in open(path):
        line = line.split('//')[0].strip()
        if not line:
            continue
        if line.startswith('@'):
            address = int(line[1:], 16)
        else:
            memory[address] = int(line, 16)
            address += 1
    low, high = min(memory), max(memory) + 1
    return low, bytes(memory.get(a, 0) for a in range(low, high))


def main():
    parser = argparse.ArgumentParser(description='Load and run a program on the Sixfold FPGA computer')
    parser.add_argument('program', help='a .s source (assembled with tools/rv.mjs) or a .hex image')
    parser.add_argument('--port', default='/dev/ttyUSB0')
    parser.add_argument('--baud', type=int, default=115200)
    parser.add_argument('--no-run', action='store_true', help='load only; type r at the prompt later')
    parser.add_argument('--timeout', type=float, default=60.0, help='seconds to wait for the program to finish')
    args = parser.parse_args()

    path = args.program
    if path.endswith('.s'):
        base = os.path.join('build', os.path.splitext(os.path.basename(path))[0])
        subprocess.run(['node', 'tools/rv.mjs', 'asm', path, '-o', base], check=True, stdout=subprocess.DEVNULL)
        path = base + '.hex'
    address, data = read_hex(path)
    if address < 0x2000 or address + len(data) > 0x10000:
        sys.exit(f'the program must lie in 0x2000 .. 0xFFFF (it uses 0x{address:x} .. 0x{address + len(data):x})')

    try:
        import serial
    except ImportError:
        sys.exit('pyserial is missing: pip install pyserial')
    port = serial.Serial(args.port, args.baud, timeout=0.1)
    word = lambda v: (v & 0xFFFFFFFF).to_bytes(4, 'little')
    port.reset_input_buffer()
    port.write(b'\r')                      # a fresh prompt (and proof that the firmware is listening)
    time.sleep(0.2)
    port.read(4096)
    port.write(b'l' + word(address) + word(len(data)) + data + word(sum(data)))
    print(f'[fpga_load] sent {len(data)} bytes at 0x{address:x} to {args.port}', flush=True)
    if not args.no_run:
        time.sleep(0.1)
        port.write(b'r')
    text, deadline = '', time.time() + args.timeout
    while time.time() < deadline:
        chunk = port.read(4096).decode('latin-1')
        if chunk:
            sys.stdout.write(chunk)
            sys.stdout.flush()
            text += chunk
        report = re.search(r'program finished: (PASS|FAIL[^\r\n]*?) in (\d+) cycles', text)
        if args.no_run and 'loaded' in text and 'sixfold> ' in text.split('loaded', 1)[1]:
            return 0
        if report and 'sixfold> ' in text[report.end():]:
            print()
            return 0 if report.group(1) == 'PASS' else 1
    print(f'\n[fpga_load] no report within {args.timeout:.0f} s (a program that never halts? press reset)')
    return 2


if __name__ == '__main__':
    sys.exit(main())
