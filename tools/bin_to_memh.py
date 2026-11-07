#!/usr/bin/env python3
import sys
from pathlib import Path

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} INPUT.bin OUTPUT.hex")
    sys.exit(1)

input_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
data = input_path.read_bytes()

with output_path.open("w") as output_file:
    for offset in range(0, len(data), 4):
        word_bytes = data[offset:offset + 4].ljust(4, b"\x00")
        word = int.from_bytes(word_bytes, byteorder="little")
        output_file.write(f"{word:08x}\n")