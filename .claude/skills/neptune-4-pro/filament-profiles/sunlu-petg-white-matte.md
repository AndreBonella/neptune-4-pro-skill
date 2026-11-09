# Sunlu PETG White Matte

| Field | Value |
|---|---|
| Brand / product | Sunlu PETG matte |
| Type | PETG |
| Color | White (matte) |
| Spool label range | Nozzle — °C, Bed — °C |
| Bought / opened | — |
| Nozzle used | 0.4 mm brass (stock) |
| Firmware | Stock Elegoo (Klipper v0.10.0-530) |
| Slicer + base preset | OrcaSlicer 2.4.2, "Elegoo PETG @EN4 Series" (fan 10–40 %, overhangs 90 %, retraction 0.8 mm) |
| Dried before testing | — (temp / hours) |

## Test results

| # | Test | Date | Result | Notes |
|---|---|---|---|---|
| 1 | Temperature tower (260 → 220 °C, step 5 °C) | 2026-11-09 | 240 °C (not adopted) | user's overall pick; the stock 250 °C won the verification |
| 2 | Flow ratio | 2026-11-09 | 0.92 (not adopted) | best patch offset: −0.03 on base 0.95 (YOLO) |
| 3 | Pressure advance | 2026-11-09 | 0.045 (not adopted) | tested at 100 mm/s, 3000 mm/s² accel; 21 chevrons from the CLI |
| 4 | Retraction length / speed | 2026-11-09 | 0.5 mm @ 40 mm/s (not adopted) | first clean ring 6 of 21 (step 0.1 from 0); z-hop 0.2, wipe off |
| 5 | Max volumetric speed | 2026-11-09 | measured 12.5 mm³/s (limit 10.5 not adopted) | defect height 15 mm (5 + 0.5 × 15); vase from the CLI. The stock 11 mm³/s is below the measured 12.5 |
| 6 | Fan (part cooling) | — | — % (overhang/bridge — %) | |
| 7 | Bed temp + surface prep | — | — °C, — (smooth/textured PEI, glue?) | |
| 8 | Enclosure needed | — | yes / no / lid open | |
| opt | Adaptive PA sets (PA, flow, accel) | — | — | Klipper only |
| opt | VFA speeds to avoid | — | — | |
| opt | Tolerance / XY compensation | — | — | |
| ✔ | Verification cube | 2026-11-10 | **stock preset better** | Orca cube: A (stock preset, bed 75) beat B (tests 1–5). No per-feature notes, so which change hurt B is unknown |

## Final settings (copy into the slicer filament profile)
Orca's stock **"Elegoo PETG @EN4 Series"**, which beat the tuned settings in the verification. Only the bed differs from the preset (70 → 75 °C).
- Nozzle: 250 °C (first layer 250 °C)
- Bed: 75 °C (first layer 75 °C), textured PEI
- Flow ratio: 0.95
- Pressure advance: 0.02. The preset leaves PA off, so cube A ran at the printer's default 0.02. **Turn "Enable pressure advance" on at 0.02** so a value left by an earlier print can't change it.
- Max volumetric speed: 11 mm³/s
- Retraction: 0.8 mm @ 60 mm/s (return 30 mm/s), wipe on (1.2 mm), Z-hop 0.4 mm (auto lift)
- Fan: min 10 % / max 40 %, overhangs 90 %, off for the first 3 layers

## Observations and history
- 2026-11-09: Calibration started. Test 1 tower sliced (260 → 220 °C, 9 blocks, bed 75 °C, about 1 h 46 min, 16 g), not yet printed.
- 2026-11-09: User confirmed spool dry and loaded. Tower started via Moonraker as `TempTower_SunluPETG_260-220.gcode`.
- 2026-11-09: Test 1 result: best temp 240 °C.
- 2026-11-09: Test 2 YOLO flow patches sliced from the CLI (240/245 °C, bed 75 °C, base flow 0.95, about 34 min, 13.5 g), each patch's extrusion scaled in the G-code to base + label. Not yet printed.
- 2026-11-09: Test 2 result: best patch −0.03, flow ratio 0.95 − 0.03 = 0.92.
- 2026-11-09: Test 3 chevrons generated from the CLI (21 values, PA 0–0.100 step 0.005, 240/245 °C, bed 75 °C, flow 0.92, walls 100 mm/s, 3000 mm/s², about 24 min, 6.3 g). Not yet printed.
- 2026-11-09: Test 3 result: best PA 0.045 (label 045).
- 2026-11-09: Test 4 retraction tower generated from the CLI (21 rings, 0–2.0 mm, step 0.1, 40 mm/s retract, 30 mm/s deretract, z-hop 0.2, wipe off, about 18 min, 1.15 g). Not yet printed.
- 2026-11-09: Test 4 result: first clean ring 6, retraction (6 − 1) × 0.1 = 0.5 mm.
- 2026-11-09: Test 5 max-flow vase generated from the CLI (Orca SpeedTestStructure cut to 30 mm, flow = 5 + 0.5 × height mm³/s up to 20, speed 76–297 mm/s, 16.9 g). Not yet printed.
- 2026-11-09: Test 5 result: first defect at 15 mm = 12.5 mm³/s; set 10.5 mm³/s (−16 %). PA was measured at ~7.5 mm³/s (100 mm/s walls), below this, so Test 3 stands.
- 2026-11-09: Test 6 cubes sliced (Orca cube 30 mm, same place and process): A stock preset (250 °C, flow 0.95, retraction 0.8 with wipe, no PA set so the printer's 0.02 applies) and B tuned (240/245 °C, flow 0.92, PA 0.045, 10.5 mm³/s, retraction 0.5 @ 40, wipe off, z-hop 0.2). About 40 min and 10 g each. Not yet printed.
- 2026-11-09: Cube A started. The printer still held PA 0.045 from Tests 4–5 (they set it without restoring), so PA was reset to the printer's 0.02 by `SET_PRESSURE_ADVANCE` while the bed heated, before any extrusion. Cube A printed at 0.02 and 250 °C.
- 2026-11-10: Test 6 result: cube A (stock preset) better than cube B (tuned). Final settings set to the stock preset at bed 75 °C, with PA pinned at 0.02. Calibrated.
