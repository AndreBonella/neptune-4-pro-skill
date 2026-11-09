# Klipper, firmware and printer control for the Neptune 4 Pro

## Stock firmware vs OpenNept4une

**Stock Elegoo firmware:** Klipper + Moonraker + Fluidd with Elegoo's touchscreen UI. Easy, and the touchscreen works.
Elegoo's Klipper is customized. Updating Klipper or Moonraker from the Fluidd update manager can break it, so update only via Elegoo releases unless you know what you're doing.

### Stock firmware facts (verified on the user's N4 Pro, 2026-11-07)
| Item | Value |
|---|---|
| Printer address | **Changes over time (DHCP).** Hostname `mkspi`. See "Finding the printer" below |
| API access | Moonraker through the Fluidd nginx proxy on **port 80** (`http://$IP/server/info`). Port 7125 is **not** open |
| Klipper | `v0.10.0-530-g3387a9c2-dirty` (Elegoo fork) |
| Heater objects | `extruder`, `heater_bed` (inner), **`heater_generic heater_bed1`** (outer zone) |
| Filament sensor | `filament_switch_sensor fila` |
| Limits | `max_velocity` 500, `max_accel` 5000 (Elegoo's pre-print sets 270 mm/s / 4000 mm/s²) |
| G-code storage | `/home/mks/gcode_files` (Moonraker root `gcodes`) |

**Starting a print via the API on stock firmware:**
- `POST /printer/print/start?filename=...` returns an **empty body**, but the print does start.
- Elegoo's Moonraker then runs its own pre-print sequence: metadata, `G28`, `G1 Z100`, `SDCARD_PRINT_FILE`, `BED_MESH_CLEAR`, `BED_MESH_PROFILE load=6`, `SET_VELOCITY_LIMIT velocity=270 accel=4000`, `PRINT_START`, and only then the file.
- **Don't retry the start.** A second call fails with `!! SD busy`. Check `print_stats.state` (`printing`) and `virtual_sdcard.is_active` instead.
- **Finished prints show as "cancelled".** The stock end sequence turns off both beds and then runs `CANCEL_PRINT` + `SDCARD_RESET_FILE`, so `print_stats` drops from `printing` (around 93 % display progress) straight to `standby`, and `/server/history` records `cancelled`. Ask the user whether it finished; don't report a failure from this alone.
- Use Orca's stock **Elegoo Neptune 4 Pro** printer profile with stock firmware. Its start G-code heats and purges by itself, and its before-layer-change G-code turns the outer zone off (`M141 S0`) for small, centred, low-temperature prints.

**OpenNept4une** (community, https://github.com/OpenNeptune3D/OpenNept4une, forks e.g. mowtox/OpenNept4une) replaces the Elegoo software with stock open-source Klipper/Moonraker/Fluidd/Mainsail, Crowsnest and KAMP on an Armbian image.
- Install: flash the eMMC with the release image (needs an MKS EMMC-ADAPTER V2 USB reader or eMMC→microSD adapter; **back up the original eMMC first**), then run `~/OpenNept4une/OpenNept4une.sh` and pick "Install latest OpenNept4une Printer.cfg".
- The installer asks for **stepper current (0.8 A or 1.2 A)** and **PCB version (V1.0 / V1.1)**. **The wrong current can permanently damage the steppers.** Identify it from the motor label (`BJ42D15-26V77` = 0.8 A, `BJ42D22-53V04` = 1.2 A), from the stock `printer.cfg` `run_current` under stepper_x/stepper_y, or from the build date (N4 Pro before June 2023 = 0.8 A, after = 1.2 A).
- On V1.1 boards, swap the LED section in `printer.cfg` (delete "LED Control v1.0", uncomment v1.1).
- The **touchscreen stops working**. Use the web UI or the Mobileraker app.
- SSH: `ssh mks@<printer-ip>` (default password `makerbase`; change it). Wi-Fi: `sudo nmtui`. Timezone: `sudo armbian-config`.
- Includes: KAMP adaptive meshing, PID macros, bed-level macros, axis twist compensation, working segmented bed, ADXL345 configs, firmware retraction, Crowsnest webcam.
- **Reboot from the UI (Host → Reboot), don't just cut power.** That way changes are written to eMMC.

### OpenNept4une macros
Verified against `printer-confs/base.cfg` and `printer-confs/n4pro/` in the upstream repo (commit 33f6055, 2026-03-10).
Klipper macro names are case-insensitive.

| Macro | Purpose |
|---|---|
| `PRINT_START` | Slicer start hook. Params: `BED_TEMP` (default 60), `EXTRUDER_TEMP` (default 200), `AREA_START`/`AREA_END` (first-layer bounds, drive the outer-bed logic), `BED_HEAT_SOAK_MINUTES` (default 0), `BED_MESH` = `adaptive` (default, KAMP) / `full` / `none` / *saved profile name*. Sequence: heat bed → optional soak → home → mesh → Smart_Park → heat nozzle → KAMP `LINE_PURGE` |
| `PRINT_END` | Turns heaters off, retracts/wipes, presents the print at `X0 Y230`, end jingle |
| `PAUSE` / `RESUME` / `CANCEL_PRINT` | Pause parks at the rear-left, drops the nozzle to 175 °C and lifts Z 30 mm (param `Z=`). Resume reheats, purges 80 mm, then returns |
| `M600` | Filament change → calls `PAUSE` |
| `LOAD_FILAMENT` / `UNLOAD_FILAMENT` | Load/unload using the previous print temperature |
| `Bed_Level_Screws_Tune` | Heats the bed (current target or 60 °C), homes, runs `SCREWS_TILT_CALCULATE` (M4 screws, CW). Repeat until within tolerance |
| `Calibrate_Probe_Z_Offset` | Homes + `PROBE_CALIBRATE` (paper test) → `ACCEPT` → `SAVE_CONFIG` |
| `Auto_Full_Bed_Level` | Heats the bed to 60 °C, full 11×11 `BED_MESH_CALIBRATE` |
| `PID_Tune_EXTRUDER` | `PID_CALIBRATE` extruder, default 210 °C (param `TEMPERATURE=`), fan 100%, saves |
| `PID_Tune_BED` | Inner bed (`heater_bed`), default 60 °C, saves |
| `PID_Tune_Outer_BED` | Outer bed (`heater_bed_outer`) while also heating the inner zone, default 60 °C, saves (N4 Pro only) |
| `Axis_Twist_Comp_Tune` | Homes + `AXIS_TWIST_COMPENSATION_CALIBRATE` (X 30→210 at Y 117.5) |
| `SET_BED_TEMPERATURE TARGET=` / `BED_TEMPERATURE_WAIT MINIMUM= MAXIMUM=` | Set/wait on the bed, including the outer zone when it's active (see Segmented bed) |
| `Frame_Light_ON/OFF`, `Part_Light_ON/OFF`, `M300 S<freq> P<ms>` | Lights and beeper |

Put your own macros and overrides (e.g. `SET_RETRACTION` defaults) in `user_settings.cfg`, which `printer.cfg` includes.
Regenerating `printer.cfg` with the installer won't overwrite it.

### OpenNept4une `printer.cfg` defaults (N4 Pro)
| Setting | Value |
|---|---|
| `max_velocity` / `max_accel` | **250 mm/s / 3000 mm/s²** (far below the marketed 500 mm/s; raise only after input shaping and testing) |
| `square_corner_velocity` | 5.0 |
| Extruder | `rotation_distance: 28.888`, `gear_ratio: 52:10`, `pressure_advance: 0.02725`, `max_temp: 330` (keep the 300 °C hardware limit anyway) |
| Input shaper defaults | `mzv` X 111.6 Hz, Y 32.4 Hz (re-tune for your machine) |
| Probe | Inductive/switch probe on PA11, offsets X −24.25 Y +20.45, 3 samples median |
| Bed mesh | 11×11, bicubic, `mesh_min 10,21`, `mesh_max 210,211`, fade 1–10 mm |
| Stepper current | X/Y 0.8 or 1.2 A (by motor type), Z 0.8 A, E 0.9 A |
| Filament runout sensor | `filament_sensor` on PA12. Pauses and unloads on runout; enabled only while printing |
| Web UIs | Fluidd on port 80, **Mainsail on port 81** |

### OrcaSlicer start G-code for OpenNept4une (single line)
```
PRINT_START BED_TEMP=[hot_plate_temp_initial_layer] EXTRUDER_TEMP=[nozzle_temperature_initial_layer] AREA_START={first_layer_print_min[0]},{first_layer_print_min[1]} AREA_END={first_layer_print_max[0]},{first_layer_print_max[1]}
;Nozzle diameter = [nozzle_diameter]
;Filament type = [filament_type]
;Filament name = [filament_vendor]
;Filament weight = [filament_density]
```
End G-code: `PRINT_END`.
Optional extras on the `PRINT_START` line: `BED_HEAT_SOAK_MINUTES=10` (ABS/ASA, large PETG) and `BED_MESH=full` or `BED_MESH=none`.

**Firmware retraction gotcha:** the bundled OpenNept4une Orca printer profile sets `use_firmware_retraction = 1`.
Orca then emits `G10`/`G11` and **ignores the slicer's retraction length**. But `[firmware_retraction]` in `base.cfg`
has no values, and Klipper's default `retract_length` is 0, so retraction may be effectively off. Fix it one of two ways:
- Add `SET_RETRACTION RETRACT_LENGTH=<calibrated> RETRACT_SPEED=<calibrated>` to the filament's start G-code in the slicer (per filament, best), or set defaults in a `[firmware_retraction]` override in `user_settings.cfg`. Or:
- Turn off "Use firmware retraction" in the printer profile and use the slicer's retraction values.

Check the current values with `GET_RETRACTION`.

The bundled filament presets (Generic PLA/PETG) have pressure advance 0 and PETG retraction 2.5 mm. Treat them as placeholders
and calibrate your own (`calibration.md` section B).
Thumbnails: Printer settings → Advanced → G-code thumbnail format `ColPic`. The first size must be `160x160`.
The repo ships ready OrcaSlicer profiles in `orca-profiles/` (import via File → Import → Import Configs…).

## Slicer options
- **OrcaSlicer** (recommended): has a built-in Elegoo Neptune 4 Pro profile, the best calibration tools, and can upload to the printer as an "Octo/Klipper" host (Moonraker URL `http://<printer-ip>` or `http://<printer-ip>:7125`).
- **ElegooSlicer**: Elegoo's OrcaSlicer fork with N4P profiles preconfigured for stock firmware.
- **Cura / Elegoo Cura**: works, but has no built-in calibration tools.
- With **stock firmware**, keep the slicer's stock N4P start G-code. It handles the segmented bed and Elegoo's own macros.

## Segmented bed (N4 Pro only)
The bed has an inner zone and an outer zone. The outer zone only needs to heat for large parts. For **ABS/ASA/PC
and large prints, heat both zones** so the whole bed is even, which reduces warping at the edges.
Stock firmware/slicer profiles switch the outer zone based on model size.

**On OpenNept4une** (verified in `printer-confs/n4pro/section_extra_heating.cfg` and `section_start_bed_setup.cfg`):
- Heater objects: inner = `heater_bed`, outer = `heater_generic heater_bed_outer` (max 120 °C in config, PWM cycle 0.3 s).
- `PRINT_START` sets `small_print = True` when the first layer lies entirely within **X/Y 62.5–172.5 mm** (the centre zone). Only then does the outer zone stay off.
- The outer zone is **forced on whenever `BED_TEMP` ≥ 80 °C** (`variable_outer_bed_force_activation_temp`), so PETG at 80 °C and above, ABS, ASA and PC always heat the full bed.
- `M140`/`M190` are redefined to call `SET_BED_TEMPERATURE` / `BED_TEMPERATURE_WAIT`, which drive both zones under the rules above.
- `M141 S<t>` / `M191 S<t>` set (and wait for) **only the outer zone**.
- To always heat both zones, set `variable_force_outer_bed_heater: True` in `PRINT_START`, or lower the activation temperature.
- Moonraker objects to query: `heater_bed` and `heater_generic heater_bed_outer`.

On stock Elegoo firmware the names can differ. Read `printer.cfg` or query Moonraker (`/printer/objects/list`) before naming heaters.

## Useful Klipper commands
| Command | Use |
|---|---|
| `SET_PRESSURE_ADVANCE ADVANCE=0.04` | Set PA live |
| `SET_GCODE_OFFSET Z_ADJUST=0.01 MOVE=1` | Babystep Z during the first layer |
| `SET_RETRACTION RETRACT_LENGTH=0.8 RETRACT_SPEED=35` | Firmware retraction (if `[firmware_retraction]` is enabled) |
| `SET_VELOCITY_LIMIT ACCEL=5000` | Change acceleration live |
| `M221 S98` / `M220 S80` | Flow % / speed % overrides |
| `PID_CALIBRATE HEATER=extruder TARGET=240` | PID tune |
| `BED_MESH_CALIBRATE` / `BED_MESH_PROFILE LOAD=default` | Bed mesh |
| `SHAPER_CALIBRATE` | Input shaper tuning (needs ADXL) |
| `SAVE_CONFIG` | Persist calibration results (restarts Klipper) |
| `FIRMWARE_RESTART` | Restart after a config change |

## Finding the printer
The printer's IP changes from time to time, so never assume an address. Find and confirm it before any API call. It has moved from 192.168.68.3 to 192.168.68.4 (seen 2026-11-09); these are hints only.

1. Try the last address seen, and confirm it is the printer (a read-only request):
   ```bash
   IP=192.168.68.4; curl -s -m 3 "http://$IP/printer/info" | grep -q '"hostname": *"mkspi"' && echo "printer at $IP"
   ```
2. If that fails, search the local network with the same read-only check:
   ```bash
   SUBNET=$(ip -4 route | awk '/proto kernel/ && !/linkdown/ {print $1; exit}')
   python3 -c 'import ipaddress,sys; print(*ipaddress.ip_network(sys.argv[1]).hosts(), sep="\n")' "$SUBNET" |
     xargs -P 64 -I{} sh -c 'curl -s -m 2 "http://{}/printer/info" | grep -q "\"hostname\": *\"mkspi\"" && echo {}'
   ```
3. If the search finds nothing or a permission check blocks it, don't work around the block. Ask the user for the IP, which is on the touchscreen's network settings or the router's device list.

A failed connection to an old address doesn't mean the printer is off or disconnected. After moving to OpenNept4une, the hostname may differ, so match on `/server/info` containing `klippy_state` and also try port 7125.

## Moonraker API (for Claude to query or control the printer)
Base URL: `http://<printer-ip>:7125`, or port 80 through the web UI proxy. On the user's stock printer, use `http://$IP` (port 80 only), with `$IP` from "Finding the printer" above.
```bash
# Status (read-only, safe)
curl -s "http://$IP:7125/printer/objects/query?extruder&heater_bed&print_stats&toolhead"
# Outer bed zone (OpenNept4une; the space in the object name is URL-encoded)
curl -s "http://$IP:7125/printer/objects/query?heater_generic%20heater_bed_outer"
# List G-code files
curl -s "http://$IP:7125/server/files/list?root=gcodes"
# Upload a file (ask the user first)
curl -s -F "file=@part.gcode" "http://$IP:7125/server/files/upload"
# Start a print (ask the user first)
curl -s -X POST "http://$IP:7125/printer/print/start?filename=part.gcode"
# Send G-code (ask the user first if it heats, moves or saves)
curl -s -X POST "http://$IP:7125/printer/gcode/script" --data-urlencode "script=SET_PRESSURE_ADVANCE ADVANCE=0.04"
# Pause / resume / cancel
curl -s -X POST "http://$IP:7125/printer/print/pause"   # resume / cancel likewise
```
Always confirm with the user before any heating, movement, print start/cancel, `SAVE_CONFIG`, or config edit.
