---
name: neptune-4-pro
description: Expert help for the Elegoo Neptune 4 Pro (Klipper-based FDM printer) — slicer settings for any filament (PLA, PLA+, silk, matte, wood, CF-filled, PETG, TPU, ABS, ASA, nylon, PC), calibration (PID, Z offset, bed mesh, flow, pressure advance, retraction, input shaping), OrcaSlicer/ElegooSlicer profiles, OpenNept4une firmware, Klipper/Moonraker commands, and troubleshooting print defects (stringing, warping, clogs, layer shifts, first-layer issues). Use whenever the user mentions the Neptune 4 Pro / N4P / Neptune 4, asks how to print a filament on it, wants slicer settings, or is diagnosing a print problem on it.
---

# Elegoo Neptune 4 Pro

Use this skill to give concrete, printer-specific answers for the Elegoo Neptune 4 Pro (N4P).
Always treat numbers here as **starting points** — tell the user to verify with the calibration prints in
`references/calibration.md` for their specific spool.

## Printer facts (use these, don't guess)

| Item | Value |
|---|---|
| Firmware | Klipper (stock Elegoo build, or community **OpenNept4une**) with Moonraker + Fluidd web UI |
| Build volume | 225 × 225 × 265 mm |
| Hotend | All-metal, **max 300 °C**, ships with 0.4 mm **brass** nozzle |
| Extruder | Direct drive, dual-gear → keep retraction short (≈0.5–1.2 mm) |
| Bed | Max 110 °C, **two heating zones** (inner ~150 W + outer ~100 W); PEI spring-steel sheet |
| Speed | Marketed 500 mm/s; realistic quality range 150–300 mm/s, limited by hotend flow (run a max volumetric flow test). OpenNept4une's config caps at 250 mm/s / 3000 mm/s² by default |
| Bed zones (OpenNept4une) | `heater_bed` (inner) + `heater_generic heater_bed_outer`. Outer turns on automatically for prints outside X/Y 62.5–172.5 mm or bed ≥ 80 °C |
| User's printer | **Stock Elegoo firmware**, stock 0.4 mm brass nozzle, at **192.168.68.3** (Moonraker via port 80; 7125 closed). Outer bed = `heater_generic heater_bed1`. Details in `references/klipper.md` |
| Filament runout sensor | Yes (`filament_sensor`). `M600` = `PAUSE` for filament changes |
| Klipper features | Pressure advance, input shaping (needs an ADXL345 accelerometer for automatic tuning), bed mesh, KAMP (OpenNept4une) |
| Upgrades | Elegoo hardened steel nozzle kit (0.4/0.6/0.8) for abrasive filaments; enclosure for ABS/ASA/nylon/PC |

Hard limits to enforce in every recommendation:
- Never recommend nozzle temps above **300 °C** or bed above **110 °C**.
- Abrasive filaments (anything **-CF, -GF**, glow-in-the-dark, some metal/marble fills) **require a hardened nozzle** — brass wears out in a few hundred grams.
- ABS/ASA/PC/nylon: recommend an enclosure and ventilation (fumes: styrene/VOCs).

## Workflow

1. **Identify the setup** if it matters to the answer: stock Elegoo firmware vs OpenNept4une; slicer (OrcaSlicer, ElegooSlicer, Cura, PrusaSlicer); nozzle size/material; enclosure or not.
2. **Identify the filament** (type + brand if known). **First check `filament-profiles/`** for a calibrated record of that filament. Measured values there override generic ranges. Otherwise use its section in `references/filaments.md`, and prefer the manufacturer's printed range on the spool label when the user has it.
3. **Give settings** as a compact table: nozzle temp, bed temp, fan, speed / max volumetric flow, retraction, bed prep, drying, special notes.
4. **For a new (uncalibrated) filament, or "calibrate <filament>"**, run the guided procedure in `references/calibration-procedure.md`: one labeled test print at a time (temperature → flow ratio → pressure advance → retraction → max flow → verify). The user picks the best sample, and Claude converts it to the setting. Create a record from `filament-profiles/_TEMPLATE.md`.
5. **When the user reports test results**, write them into that filament's record and update the index in `filament-profiles/README.md`. Fill in only what was measured; never invent results.
6. **For defects**, use `references/troubleshooting.md`. Ask for or infer the symptom, and check wet filament first for stringing, popping or rough surfaces.
7. **For firmware/macros/printer control**, use `references/klipper.md`.
8. **For general slicing/workflow advice** (orientation, supports, brim, infill, modifiers, long-print checklist, tools), use `references/tips-and-tricks.md`.

## Reference files

- `references/filaments.md` — per-filament settings and tips/tricks (PLA family, PETG, TPU, ABS, ASA, nylon, PC, CF/GF, specialty), plus drying and storage table.
- `references/calibration.md` — machine calibration (Klipper commands) and slicer-independent per-filament tests.
- `references/calibration-procedure.md` — guided "print labeled samples → user picks the best" session, with a card per test and conversion formulas.
- `references/tips-and-tricks.md` — orientation, supports, brim, infill, modifiers, pre-flight checklist, tools, post-processing.
- `filament-profiles/` — the user's calibrated per-filament records (`README.md` index + `_TEMPLATE.md`).
- `references/klipper.md` — stock vs OpenNept4une, macros, start/end G-code, Moonraker API, segmented bed.
- `references/troubleshooting.md` — symptom → cause → fix table for common N4P defects.

## Controlling the printer

If the user asks Claude to talk to the printer directly (Moonraker HTTP API, see `references/klipper.md`):
- Read-only queries (status, temperatures, file list) are fine.
- **Ask for confirmation before** heating, homing/moving, starting/cancelling prints, `SAVE_CONFIG`, firmware restarts, or editing `printer.cfg`. Someone may not be next to the printer.
- Back up `printer.cfg` before editing it.

## Sources (compiled Nov 2026)
OpenNept4une README (github.com/mowtox/OpenNept4une) and source (github.com/OpenNeptune3D/OpenNept4une, commit 33f6055), All3DP N4 Pro profile guide, Siraya Tech N4 filament guide,
P3D Neptune tuning guides, 3DJake/retailer spec sheets, Tom's Hardware N4 Pro review, Elegoo wiki filament
drying guide, Flashforge drying table, Klipper documentation. Values that differed between sources are given as ranges.
Videos: Factorian Designs "Filament Calibration Masterclass" (gVU5If1VsAM), InitMakes "3D Printing Tricks You SHOULD
KNOW!" (mV9irIrbsTk). Where the videos conflicted with the researched guidance, the researched guidance was kept.
