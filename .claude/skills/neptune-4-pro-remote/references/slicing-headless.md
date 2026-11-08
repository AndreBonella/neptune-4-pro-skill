# Slicing headless with OrcaSlicer for the Neptune 4 Pro

Useful when Claude prepares a print end to end: STL in, verified G-code on the printer out.

## The command

```bash
orca-slicer --slice 0 --arrange 1 --orient 0 \
  --load-settings "machine.json;process.json" \
  --load-filaments filament.json \
  --outputdir out/ model.stl
```

- Export the three profiles (printer, process, filament) from the OrcaSlicer GUI once, and keep them next to the project.
  Start from the OpenNept4une Orca profiles (`orca-profiles/` in the OpenNept4une repo). The start G-code must be the
  `PRINT_START ... AREA_START=... AREA_END=...` line (see `../../neptune-4-pro/references/klipper.md`).
- On Linux the AppImage extracts to `squashfs-root/`. Run `squashfs-root/bin/orca-slicer` (`--appimage-extract` once).
- `--slice 0` slices every plate. `--orient 0` keeps the model's orientation, so orient it yourself (widest flat face down).
- Read the result: the G-code header has the estimated time and filament weight
  (`grep -E "estimated printing time|filament used \[g\]" out/*.gcode`). Report both to the user before printing.

## Things the CLI does differently from the GUI

- **No thumbnail** in the G-code. Add one with a post-processing script, or the touchscreen shows no preview. Older
  display_connector versions crashed on a file without one (fixed upstream in display_connector#79).
- **`--arrange 1` is conservative** with several copies. For a full plate of identical parts, build a 3MF that already
  places the copies on a grid (one mesh, several build items with translation transforms) and slice it with
  `--arrange 0`. On a 235 mm bed, a 3×3 grid of 60 mm parts at a 72 mm pitch, centred on 117.5, leaves room for brims.
- **Full plates of detailed models** produce huge `EXCLUDE_OBJECT_DEFINE` outlines. Always run
  `../scripts/shrink_polygons.py` on the output (`mcu-shutdowns.md`, cause 1).
- **No layer numbers** reach Klipper unless the machine G-code has `SET_PRINT_STATS_INFO` (see `SKILL.md`, step 7).

## Settings that fixed real failures on this printer

These are from repeated failed and successful prints on one N4 Pro with PLA on the stock PEI sheet. Use them as the first
thing to try, then calibrate (`../../neptune-4-pro/references/calibration.md`).

| Problem | What fixed it |
|---|---|
| Purge line sticks to the nozzle and gets dragged into a spaghetti first layer | Clean the nozzle tip, wash the sheet with dish soap and water, first layer at **20 mm/s walls / 25 mm/s infill**, **220 °C** first layer. The profile's default first layer of 50 mm/s was too fast. |
| First layer round and not sticking even with good flow | Same slow first layer, plus a live `SET_GCODE_OFFSET Z_ADJUST=-0.05 MOVE=1` during layer 1. Once confirmed, make it permanent: add the same amount to the probe `z_offset` in the `SAVE_CONFIG` block (a larger `z_offset` puts the nozzle closer; 1.997 → 2.072 here), then restart Klipper while idle. |
| Large flat PLA part (166 mm ring) warped from layer 9 | Part fan **30–40 %** (off for the first 4 layers) instead of 100 %, 10 mm inner + outer brim, bed 70 °C, and print it flipped with the widest face down. |

A faster bed mesh used on this printer (the OpenNept4une defaults probe 11×11 more slowly): `[bed_mesh] probe_count: 7,7`, `speed: 250`,
`horizontal_move_z: 3`, and `[probe] speed: 10`, `lift_speed: 15`, `samples: 2`, `sample_retract_dist: 2`. The adaptive mesh
(`BED_MESH_CALIBRATE ADAPTIVE=1`, the `PRINT_START` default) then only probes the printed area.

## Estimating before committing

Report time and grams before starting, and offer cheaper variants when a plate is long. Infill, layer height and
top/bottom count move the numbers most. For example, nine 60 mm decorative parts came to about 8 h and 176 g with
0.28 mm layers, 6 % gyroid infill and 3 top/bottom layers. Lightning infill was lighter still, but on that model it
didn't support the top skins.
