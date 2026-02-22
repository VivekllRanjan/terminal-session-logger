#!/usr/bin/env python3
import re, sys

def apply_backspaces(s):
    result = []
    for ch in s:
        if ch == '\b':
            if result: result.pop()
        else:
            result.append(ch)
    return ''.join(result)

def clean(text):
    text = re.sub(r'\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)', '', text)  # OSC
    text = re.sub(r'\x1b\[[0-9;?]*[A-Za-z]', '', text)              # CSI
    text = re.sub(r'\x1b.', '', text)                                # other ESC
    text = text.replace('\x07', '')                                  # BEL
    text = re.sub(r'^Script (started|done).*[\r\n]*', '', text, flags=re.MULTILINE)

    output_lines = []
    last_cmd = None

    for seg in re.split(r'[\r\n]+', text):
        seg = apply_backspaces(seg)
        stripped = seg.strip()
        if not stripped:
            continue
        match = re.search(r'\$\s+(.*)', stripped)
        if match:
            cmd = match.group(1).strip()
            if cmd and cmd != last_cmd:
                output_lines.append('$ ' + cmd)
                last_cmd = cmd
        elif re.search(r'\$\s*$', stripped):
            pass  # bare prompt, skip
        else:
            last_cmd = None
            output_lines.append(seg.rstrip())

    return '\n'.join(line for line in output_lines if line.strip())

if len(sys.argv) != 3:
    print("Usage: cleanlog <input.log> <output.log>")
    sys.exit(1)

with open(sys.argv[1], 'r', errors='replace') as f:
    raw = f.read()
with open(sys.argv[2], 'w') as f:
    f.write(clean(raw))
