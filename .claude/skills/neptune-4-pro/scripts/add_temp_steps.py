"""Insert nozzle temperature steps into an Orca G-code file for a temperature tower:
temp = start - int(z / 10.001) * step, applied at each layer change (same rule as OrcaSlicer's calib mode).
usage: add_temp_steps.py in.gcode out.gcode start_temp [step=5]"""
import re
import sys

src, dst, start = sys.argv[1], sys.argv[2], int(sys.argv[3])
step = int(sys.argv[4]) if len(sys.argv) > 4 else 5
out, cur, changes = [], None, []
lines = open(src, encoding="utf-8").read().splitlines()
for i, line in enumerate(lines):
    out.append(line)
    m = re.match(r";Z:([0-9.]+)", line)
    if m and i > 0 and lines[i - 1].startswith(";LAYER_CHANGE"):
        z = float(m.group(1))
        t = start - int(z / 10.001) * step
        if t != cur:
            if cur is not None:  # first layer already uses start temp from the start G-code
                out.append(f"M104 S{t} ; temp tower block z={z}")
                changes.append((z, t))
            cur = t
open(dst, "w", encoding="utf-8").write("\n".join(out) + "\n")
print("temperature changes:", changes)
