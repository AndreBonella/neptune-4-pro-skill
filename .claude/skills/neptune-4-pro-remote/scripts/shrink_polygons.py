#!/usr/bin/env python3
"""Shrink EXCLUDE_OBJECT_DEFINE outlines in a G-code file to bounding boxes.

Slicers write each object's real outline (often ~1000 points for a detailed model). KAMP's
Smart_Park / LINE_PURGE walk every point of every object in Jinja, and on a full plate that can
block Klipper long enough for "MCU 'mcu' shutdown: Timer too close" right at the purge line.
A 4-point box keeps KAMP's area (it only uses min/max) and the exclude-object buttons working.

    shrink_polygons.py IN.gcode [OUT.gcode]      (OUT defaults to IN with _fixed before .gcode)
    shrink_polygons.py --check IN.gcode          report only, exit 1 if anything would change

Standard library only. The input file is never modified.
"""
import re
import sys

POLY = re.compile(r"POLYGON=(\[\[.*?\]\])")
PAIR = re.compile(r"\[\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\]")
MAX_POINTS = 16  # outlines at or below this size are left alone


def fmt(v):
    s = f"{v:.4f}".rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


def shrink(line):
    """Returns (new_line, points_before) or None when the line is fine as it is."""
    if not line.startswith("EXCLUDE_OBJECT_DEFINE"):
        return None
    m = POLY.search(line)
    if not m:
        return None
    pts = [(float(x), float(y)) for x, y in PAIR.findall(m.group(1))]
    if len(pts) <= MAX_POINTS:
        return None
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    x0, x1, y0, y1 = fmt(min(xs)), fmt(max(xs)), fmt(min(ys)), fmt(max(ys))
    box = f"[[{x0},{y0}],[{x1},{y0}],[{x1},{y1}],[{x0},{y1}]]"
    return line[: m.start(1)] + box + line[m.end(1):], len(pts)


def main(argv):
    check = "--check" in argv
    args = [a for a in argv if a != "--check"]
    if not args:
        sys.exit(__doc__)
    src = args[0]
    dst = args[1] if len(args) > 1 else re.sub(r"(\.gcode)?$", "_fixed.gcode", src, count=1)
    out, changed, before = [], 0, 0
    with open(src, encoding="utf-8", errors="surrogateescape", newline="") as f:
        for line in f:
            r = shrink(line)
            if r:
                line, n = r
                changed += 1
                before += n
            out.append(line)
    if not changed:
        print(f"{src}: no large outlines, nothing to do")
        return 0
    print(f"{src}: {changed} object outline(s), {before} points -> {4 * changed}")
    if check:
        return 1
    with open(dst, "w", encoding="utf-8", errors="surrogateescape", newline="") as f:
        f.writelines(out)
    print(f"wrote {dst}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
