# Smart Print PLA Meta Black

| Field | Value |
|---|---|
| Brand / product | Smart Print PLA Meta (sold under the Imagine filament line by some retailers; confirm on the label) |
| Type | PLA Meta (low-temperature, higher-flow PLA) |
| Color | Black |
| Spool label range | — (to confirm from the spool label; one retailer lists nozzle 185–215 °C, bed 25–60 °C) |
| Bought / opened | — |
| Nozzle used | 0.4 mm brass (stock) |
| Firmware | Stock Elegoo (Klipper v0.10.0-530) |
| Slicer + base preset | OrcaSlicer 2.4.2 CLI, "Elegoo PLA @EN4 Series" + "0.20mm Standard @Elegoo N4Pro 0.4 nozzle" |
| Dried before testing | — |

## Test results

| # | Test | Date | Result | Notes |
|---|---|---|---|---|
| 1 | Temperature tower (225 → 185 °C, step 5 °C) | 2026-11-07 | **205 °C** | stringing 205, overhangs 200, bridge 210, fine detail 205, walls 205 |
| 2 | Flow ratio (YOLO, base 1.00 at 205 °C) | — | **—** | best patch offset: — |
| 3 | Pressure advance | — | **—** | tested at — mm/s, — mm/s² accel |
| 4 | Retraction length / speed | — | **— mm @ — mm/s** | |
| 5 | Max volumetric speed | — | measured — → **set — mm³/s** | defect height — mm |
| 6 | Fan (part cooling) | — | — % (overhang/bridge — %) | |
| 7 | Bed temp + surface prep | — | — °C, — | |
| 8 | Enclosure needed | — | no (lid/door open) | PLA |
| opt | Adaptive PA sets (PA, flow, accel) | — | — | Klipper only |
| opt | VFA speeds to avoid | — | — | |
| opt | Tolerance / XY compensation | — | — | |
| ✔ | Verification cube | — | — | |

## Final settings (copy into the slicer filament profile)
- Nozzle: 205 °C (first layer 205–210 °C)
- Bed: — °C (first layer — °C)
- Flow ratio: —
- Pressure advance: —
- Max volumetric speed: — mm³/s
- Retraction: — mm @ — mm/s, Z-hop — mm
- Fan: min — % / max — %, overhangs — %

## Observations and history
- 2026-11-07: Record created; calibration started.
- 2026-11-07: Test 1 temperature tower printing (225→185 °C, 9 blocks, bed 60 °C, fan 100%, 5 mm brim, ~57 min). File `TempTower_SmartPrint_PLAMeta_225-185.gcode` started via Moonraker.
- 2026-11-07: Tower finished (~59 min; stock firmware logged the job as "cancelled" at 93 % although it completed). Per-feature picks: stringing 205, overhangs 200, bridge 210, fine detail 205, walls 205 → **205 °C** (3 of 5 criteria, the others bracket it).
