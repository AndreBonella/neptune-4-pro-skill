# Calibration on the Neptune 4 Pro

Do these in order. Later steps depend on earlier ones. The tests below work in any slicer:
OrcaSlicer has most of them built in (Calibration menu), and ElegooSlicer (an Orca fork) has the same menu.
In other slicers, download an equivalent test model or do the manual version described here.
**Record every result in `filament-profiles/`** (see "Per-filament test log" at the end).

## A. Machine calibration (once, and after hardware changes)

1. **Mechanical check.** Check the eccentric nuts on the X carriage and bed wheels: no wobble, but they still roll freely. Tighten the belts evenly. Make sure the gantry is square (both Z sides at the same height).
2. **PID tuning** (from cold, one at a time):
   - OpenNept4une: `PID_TUNE_EXTRUDER`, `PID_TUNE_INNER_BED`, `PID_TUNE_OUTER_BED`
   - Plain Klipper: `PID_CALIBRATE HEATER=extruder TARGET=240`, then `PID_CALIBRATE HEATER=heater_bed TARGET=65` (check `printer.cfg` for the exact heater names on stock firmware, including the outer bed zone)
   - Then `SAVE_CONFIG`.
3. **Bed tramming (screws).** `BED_LEVEL_SCREWS_TUNE` (OpenNept4une) or `SCREWS_TILT_CALCULATE` if configured. Repeat until all corners are within ~0.05 mm. Do it with the bed hot (~60 °C).
4. **Z offset.** Run `CALIBRATE_PROBE_Z_OFFSET` (OpenNept4une) or `PROBE_CALIBRATE` with the paper test → `ACCEPT` → `SAVE_CONFIG`. Fine-tune live during a first-layer print with babystepping (`SET_GCODE_OFFSET Z_ADJUST=±0.01 MOVE=1`). On stock firmware you can also use the touchscreen Z-offset adjust.
5. **Bed mesh.** `BED_MESH_CALIBRATE` with the bed at printing temperature, then save. KAMP (OpenNept4une) probes only the print area before each print, which is faster and usually more accurate.
6. **Axis twist compensation** (if the first layer is uneven left to right despite a good mesh): `AXIS_TWIST_COMPENSATION_CALIBRATE` / `Axis_Twist_Comp_Tune`.
7. **Input shaping.**
   - With an ADXL345 (OpenNept4une includes SPI and Fly USB ADXL configs): `SHAPER_CALIBRATE`, then `SAVE_CONFIG`. Use the recommended `max_accel`.
   - Without an accelerometer: print a ringing tower (Klipper docs "Resonance compensation", manual method) or use a slicer's input shaping test, then set `SET_INPUT_SHAPER SHAPER_FREQ_X=... SHAPER_FREQ_Y=...`.
8. **E-steps / rotation distance.** Usually correct from the factory. Only check if flow calibration lands far from 1.0 (outside ~0.9–1.1). Mark 120 mm, extrude 100 mm slowly at temp, measure, and adjust `rotation_distance` in `[extruder]`.

## B. Per-filament calibration

Redo for every new filament **brand or type**, and after a nozzle change. Colors of the same brand are often
similar but not always, so a quick temperature and flow check is worth it.

**Before testing:**
- **Dry the filament.** Wet filament makes every test lie, especially retraction and temperature.
- Calibrate first (section A). Start from the filament's generic preset (e.g. "Generic PETG") or the brand preset if one exists.
- Run every test in a **throw-away project** and don't save its settings. Write the results into the filament profile in a fresh project, so test-specific overrides don't leak into your real profile.
- Inspect test prints under **raking light** (a lamp from the side or top) to see line defects.

Recommended minimum for a new filament: temperature, flow ratio, pressure advance. Retraction and max flow
are next in value. The rest is optional.

### 1. Temperature tower
- Print a tower that steps the nozzle temperature by 5 °C per segment across the spool's range.
- Judge each segment on: wall surface, stringing, small details/cones, bridges, overhangs. These pull in opposite directions: cooler gives better bridges and less stringing, hotter gives better overhangs and layer adhesion.
- Pick the best overall compromise. **If several temperatures are acceptable, take the higher one.** It gives stronger layer bonding and more flow headroom for speed. For fast printing, go ~5–10 °C above the "prettiest" segment.
- Lazy fallback: the middle of the range on the spool label.

### 2. Flow ratio (flow rate / extrusion multiplier)
- Print a set of top-surface patches with stepped flow ratios: OrcaSlicer "Flow rate" Pass 1 → Pass 2, or the "YOLO" variant. Other slicers: print several 30×30 mm squares with flow overrides.
- Pick the patch with the **smoothest top surface and no gaps between lines**. Over-extrusion shows as ridges and rough, raised lines; under-extrusion shows as gaps. Values between two patches are fine (e.g. −0.025).
- If the best patch is the most extreme one, shift the base flow by ±0.05 and run it again.
- **Don't use caliper wall-thickness flow tests** (measuring a single-wall cube). They also measure layer wobble and caliper error, and give misleading values.
- Save in the **filament** profile, not the process.

### 3. Pressure advance (PA)
- Use a PA Line or PA Pattern test (more reliable than the PA tower for direct drive). Pattern is less sensitive to bed flatness than Line.
- **Run the test at the speed and acceleration you actually print outer walls with**, because PA is only correct for one flow and acceleration. If your filament's max flow can't reach that outer-wall speed, test at the speed it can reach. Check this in the slicer preview: color by speed on a large object and read the real outer-wall speed.
- Pick the line or corner that's **sharp with no gap or bulge**. Values between test lines are fine.
- Typical direct-drive ranges: PLA ~0.02–0.06, PETG ~0.04–0.08, TPU ~0.0–0.2 (often lower is better; TPU tests can run up to ~0.5).
- Apply it in the filament profile (Orca: "Enable pressure advance"), or per print with `SET_PRESSURE_ADVANCE ADVANCE=0.04`.
- **Keep it consistent.** Set most speeds and accelerations close to the calibrated values, except top surfaces, so the PA value stays valid. Small parts and overhangs slow down and drift from the calibrated value.
- **Advanced, Klipper only (fits the N4P):** OrcaSlicer's *adaptive pressure advance* takes several PA values measured at different flow and acceleration combinations and adjusts PA per feature.
  - Run the PA test at a low speed, your highest speed, and at least one in between. Repeat each at top-surface and outer-wall acceleration.
  - Record `PA, flow, accel` for each run.
  - Optional: use half of your lowest PA value for bridges.
  - Only worth it after basic PA works well. Verify with a test cube against the single-value result.

### 4. Retraction
- Print a retraction test that increases retraction length step by step (direct drive: ~0.2 → 1.5 mm in 0.1 mm steps). Use a dry spool.
- Pick the **lowest step with no strings or oozing blobs**, and check the seam side too. Shorter is better. Too much retraction can cause small holes in outer walls that look like wet-filament defects, and can jam the extruder.
- Read the length at the chosen height from the G-code preview, or compute `start + step × (height in mm ÷ step height)`.
- On direct drive, more than 2 mm is almost never right. Exception: **TPU** stays at 0–0.5 mm (see `filaments.md`).

### 5. Max volumetric speed (max flow)
- Print a max-flow test: a spiral or vase object whose flow (mm³/s) increases with height. Start with the default range; use a lower range for TPU. Don't push high-flow tests too far in one go, because extreme values can clog. Two runs are safer.
- Find the **first defect height** (surface breaks up, missing lines, a change in sheen, or extruder clicks). Check the rounded corners too. For flexible filaments, judge mainly by the corners. Measure that height with a caliper.
- In the slicer preview, color by flow and read the flow at that height.
- Set the filament's max volumetric speed **10–20% below** that value. This caps your real-world speed:
  `speed (mm/s) = flow (mm³/s) / (line width × layer height)`. Example: 15 mm³/s ÷ (0.45 × 0.2) ≈ 167 mm/s.
- If the new max flow is much lower than the speed you used for the PA test, redo PA at the reachable speed (step 3).

### 6. Optional tests
- **VFA test:** finds speeds with resonance artifacts (vertical fine artifacts). Avoid those speeds for outer walls.
- **Tolerance test:** for functional and fitted parts. Print a tolerance or hole test and tune "X-Y hole compensation" / "X-Y contour compensation", or Orca's "precise wall".
- **Cooling check:** discoloration or a dull, streaky surface on walls, especially TPU and PETG, can mean the fan is too high. Lower it for that filament.

### 7. Verify
Print a calibration cube (e.g. Orca cube) with the old and the new profile using the same process settings.
Compare layer lines, corners and top surface. Record the result.

## C. Re-calibration triggers
- New nozzle (especially hardened steel): flow, PA, and temperature (+5–10 °C).
- New filament brand or color: at least temperature, flow, PA. Colors of the same brand can differ.
- Moved the printer or changed the bed sheet: Z offset and mesh.
- Belts adjusted or new parts on the toolhead: input shaping.
- Before a very long print: see the pre-flight checklist in `tips-and-tricks.md`.

## D. Per-filament test log
Every calibrated filament gets a record in `filament-profiles/` (in the skill folder), copied from
`filament-profiles/_TEMPLATE.md`. Before recommending settings for a filament, check for an existing record
and use its measured values in place of the generic ranges. After the user reports a test result, update
the record and the index in `filament-profiles/README.md`.
