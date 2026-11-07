# Guided filament calibration procedure ("print samples → pick the best")

Use this when the user says "calibrate <filament>". Each test prints **one object with several labeled samples**,
each made with a different value. The user only reports **which sample looks best** (a label, a height or a ring
number). Claude converts that into the final setting, writes it to the filament record and prepares the next test.
Method background: `calibration.md` section B.

## How Claude runs a session
1. Create or open the record `filament-profiles/<brand>-<type>-<color>.md` from `_TEMPLATE.md`, and add it to the index.
2. Collect the setup once: spool label range, firmware (stock / OpenNept4une), slicer, nozzle.
3. Give **one test at a time** using the cards below. Fill in the exact numbers for that filament, carrying over the results of earlier tests.
4. When the user replies, convert their answer to a value (formulas below), write it in the record (test table + "Final settings"), confirm it in one line, and give the next card.
5. The user can stop at any point. The record shows where to resume. After test 5, give the verification cube card, then mark the record "calibrated" in the index.

Never fill in a result the user didn't report. If the answer is ambiguous ("between 3 and 4"), take the midpoint, or ask once.

## Automated mode (Claude slices and starts the print)
When the user wants Claude to run the test on the printer (stock firmware at 192.168.68.3, see `klipper.md`):
1. **Temperature tower:** run `scripts/make_temp_tower.sh <start> <end> <bed> <scratch_dir>`. It:
   - takes Orca's own tower model (`resources/calib/temperature_tower/temperature_tower.drc`: 70 blocks × 10 mm, labeled **500 °C at the bottom down to 155 °C**, 5 °C per block), cuts out the requested blocks, and renders `tower_preview.png`. **Read the preview to confirm the labels.**
   - slices with Orca's stock N4 Pro profiles via the CLI (flattened, marked `system`; all plate temperatures set to the bed temperature, because the CLI defaults to the cool-plate temperature).
   - inserts `M104` steps at each block, the same rule Orca's calibration uses.
2. Check the G-code: `M190` = bed temperature, `M109` = start temperature, and the temperature changes listed by the script.
3. Before printing, confirm with the user: spool loaded and dry, PEI clean and empty, someone near the printer. Then upload (`/server/files/upload`) and start (`/printer/print/start`) once. Don't retry; check `print_stats`.
4. Watch the print in the background until it leaves `printing`, then ask the user for the result in the card's answer format.

The other tests (flow, PA, retraction, max flow) need Orca's GUI generators, which have no CLI equivalent. The user
creates them in OrcaSlicer (Calibration menu) and sends them to the printer, or exports the G-code for Claude to upload.

## Setup common to every test (tell the user once)
- Dry the spool first. Clean the PEI. Machine calibration (PID, Z offset, mesh) done.
- Slicer: OrcaSlicer or ElegooSlicer (same Calibration menu). Select the **Neptune 4 Pro printer profile** (G-code flavor Klipper) and the generic preset for the filament type (e.g. Generic PLA), with temperatures set from the spool label.
- Print each test **in a throw-away project, don't save it**. Results go into the filament profile afterwards, in a clean project.
- **OpenNept4une:** if the printer profile has "Use firmware retraction" on, turn it **off** for these tests (the retraction test needs slicer retraction). Retraction is stored with `SET_RETRACTION` later (`klipper.md`).
- Inspect each print with a **lamp low at the side** (raking light). On black or dark filament this is essential.
- Other slicers: use an equivalent downloadable test model. The answers to give are the same.

---

## Card 1: Temperature tower
**Print:** Calibration → *Temperature*. Set the range from the spool label, hottest at the bottom:
- PLA Meta / low-temp PLA: 225 → 185 °C
- Standard PLA: 230 → 190 °C
- PETG: 260 → 220 °C
- ABS/ASA: 270 → 230 °C
- TPU: 240 → 210 °C

Step 5 °C. Bed and fan as for that filament type.

**Samples:** stacked blocks, **each labeled with its temperature**.

**Look at:** stringing between the pillars, overhang quality (side), bridge, small cones/details, wall finish. Cooler segments give better bridges and less stringing; hotter ones give better overhangs and stronger layers.

**User answers:** `best temp: 215` (+ optional notes, e.g. "210 also fine, 225 strings").

**Claude:**
- If two neighbors are both good, pick the **hotter** one (strength and flow headroom).
- Record it as the nozzle temp. First layer = same or +5 °C.
- Use this temperature in all following tests.

## Card 2: Flow ratio
**Print:** Calibration → *Flow rate* → **YOLO (Recommended)**. YOLO (perfectionist) is optional for finer steps. Make sure the filament preset has the Card 1 temperature and the current flow ratio (generic, often 0.98).

**Samples:** 11 square patches **labeled with an offset**: −0.05 … 0 … +0.05 (perfectionist: steps of 0.005).

**Look at:** the top surface. Pick the patch that's **smooth with no gaps between lines and no ridges**. Over-extrusion shows as raised, rough lines; under-extrusion shows as gaps. A faint pattern ring is fine.

**User answers:** `best patch: -0.02`, or "between −0.02 and −0.03".

**Claude:**
- New flow ratio = **current flow ratio + offset**. Example: 0.98 + (−0.025) = 0.955.
- If the best patch is the extreme (−0.05 or +0.05), shift the base by that amount and repeat the card.
- (Older two-pass test, if used: Pass 1 labels are % modifiers, so new = current × (100 + modifier) / 100. Pass 2 refines the same way.)

## Card 3: Pressure advance
**Print:** Calibration → *Pressure advance* → extruder type **Direct drive** → **PA Pattern** test. Default range is fine: e.g. 0 → 0.1 step 0.005 for PLA/PETG; TPU end 0.5.
- **Speed:** your outer wall speed, but no faster than the filament can melt. Limit = max volumetric speed ÷ (line width × layer height). With generic 12 mm³/s, 0.45 mm × 0.2 mm, that's ≈ 130 mm/s. If Card 5 is done, use that flow.
- **Acceleration:** your outer wall acceleration (≤ 3000 on OpenNept4une defaults).

**Samples:** nested chevrons/corners, **each line labeled with its PA value**. Speed and acceleration are printed on the plate.

**Look at:** the corner tips. Pick the one that's **sharp with no gap and no bulge**. Values between labels are fine.

**User answers:** `best PA: 0.035` (+ the speed/accel used if changed).

**Claude:**
- Record PA plus the speed and accel it was measured at. Enable PA in the filament profile, or `SET_PRESSURE_ADVANCE ADVANCE=<v>` in filament start G-code.
- Remind the user to keep wall speeds and accelerations near the tested values.
- Optional advanced: adaptive PA. Repeat at low, medium and high speed × top-surface and outer-wall accel. Record `PA, flow, accel` sets (`calibration.md` B3).

## Card 4: Retraction
**Print:** Calibration → *Retraction test*. Direct drive defaults: start 0, end 2 mm, step 0.1. TPU: end 1 mm.
Firmware retraction **off** for this test (OpenNept4une).

**Samples:** a tower of **rings stacked upward**. Each ring is one retraction length, increasing with height.

**Look at:** the **first (lowest) ring with no strings or blobs** between the pillars and a clean seam. Prefer the lowest good ring (higher values can make wall holes), but never 0 except for TPU.

**User answers:** `best ring: 5` (counting from the bottom, first ring = 1), or the **height in mm** of that ring.

**Claude:**
- Length = start + step × (ring − 1). Example: ring 5 → 0 + 0.1 × 4 = 0.4 mm.
- If the user gives a height, tell them to drag the slicer's G-code preview to that height and read the `retract length` value, or compute it from the test's step height. Ask the user to confirm the value once from the preview the first time, because ring spacing depends on the slicer version.
- Retraction speed: keep 30–45 mm/s unless the user saw grinding.
- OpenNept4une with firmware retraction: give `SET_RETRACTION RETRACT_LENGTH=<v> RETRACT_SPEED=<v>` for the filament start G-code. Otherwise, set the filament "retraction length" override.

## Card 5: Max volumetric speed
**Print:** Calibration → *Max flowrate*. Defaults: start 5, end 20, step 0.5 mm³/s. TPU: end ~8. High-speed PLA can try end 25. Two runs are safer than one extreme run.

**Samples:** a tall spiral/vase. Flow increases with height.

**Look at:** the **lowest point where defects start**: gaps, missing lines, rough or matte patches, a change in sheen, or extruder clicking. Check the rounded corners too.

**User answers:** `first defect at 33 mm` (measured from the bed with a caliper or ruler).

**Claude:**
- Flow at that height: read it in the slicer preview (color by **Flow**, slide to that height), or compute **start + height × step** (e.g. 5 + 33 × 0.5 = 21.5 mm³/s). Ask the user to confirm once from the preview.
- Set max volumetric speed = **that value − 10–20 %** (e.g. 21.5 → 17).
- If this is much lower than the flow used in Card 3, redo Card 3 at the reachable speed.

## Card 6: Verify
**Print:** a calibration cube (e.g. Orca cube or Voron cube) **twice, side by side**: once with the generic preset, once with the new filament profile. Same process. Turn off "slow down outer walls" for both, for a fair comparison.

**User answers:** `calibrated better / same / worse` + notes (layer lines, corners, top surface, stringing).

**Claude:** record the result. If it's worse, revisit the step related to the symptom (lines → flow, corners → PA, strings → retraction/temperature). Mark the record calibrated, update the index row, and print the final settings block for the user to save as a named filament profile (e.g. "SmartPrint PLA Meta Black – N4P").

## Optional cards
- **Fan:** if walls look discolored or streaky (common with PETG and TPU), lower the max fan 10–20% and reprint a small cube.
- **VFA:** Calibration → VFA. The user reports speeds with vertical artifacts. Record "avoid X–Y mm/s for outer walls".
- **Tolerance:** print a tolerance/hole test. The user reports which fit is snug, and Claude sets XY hole/contour compensation.

## Reply format for the user (show once at the start)
```
Test 1: best temp 215 — 220 strings a bit
Test 2: best patch -0.02
Test 3: best PA 0.035 (at 130 mm/s, 3000 accel)
Test 4: best ring 5
Test 5: first defect at 33 mm
Test 6: calibrated better, top surface much smoother
```
A photo description or notes are welcome. Claude asks if anything is unclear.
