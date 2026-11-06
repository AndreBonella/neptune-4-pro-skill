# Klipper, firmware and printer control for the Neptune 4 Pro

## Stock firmware vs OpenNept4une

**Stock Elegoo firmware:** Klipper + Moonraker + Fluidd with Elegoo's touchscreen UI. Easy, and the touchscreen works.
Elegoo's Klipper is customized. Updating Klipper or Moonraker from the Fluidd update manager can break it, so update only via Elegoo releases unless you know what you're doing.

**OpenNept4une** (community, https://github.com/OpenNeptune3D/OpenNept4une, forks e.g. mowtox/OpenNept4une) replaces the Elegoo software with stock open-source Klipper/Moonraker/Fluidd/Mainsail, Crowsnest and KAMP on an Armbian image.
- Install: flash the eMMC with the release image (needs an MKS EMMC-ADAPTER V2 USB reader or eMMC→microSD adapter; **back up the original eMMC first**), then run `~/OpenNept4une/OpenNept4une.sh` and pick "Install latest OpenNept4une Printer.cfg".
- The installer asks for **stepper current (0.8 A or 1.2 A)** and **PCB version (V1.0 / V1.1)**. **The wrong current can permanently damage the steppers.** Identify it from the motor label (`BJ42D15-26V77` = 0.8 A, `BJ42D22-53V04` = 1.2 A), from the stock `printer.cfg` `run_current` under stepper_x/stepper_y, or from the build date (N4 Pro before June 2023 = 0.8 A, after = 1.2 A).
- On V1.1 boards, swap the LED section in `printer.cfg` (delete "LED Control v1.0", uncomment v1.1).
- The **touchscreen stops working**. Use the web UI or the Mobileraker app.
- SSH: `ssh mks@<printer-ip>` (default password `makerbase`; change it). Wi-Fi: `sudo nmtui`. Timezone: `sudo armbian-config`.
- Includes: KAMP adaptive meshing, PID macros, bed-level macros, axis twist compensation, working segmented bed, ADXL345 configs, firmware retraction, Crowsnest webcam.
- **Reboot from the UI (Host → Reboot), don't just cut power.** That way changes are written to eMMC.

### OpenNept4une macros
| Macro | Purpose |
|---|---|
| `PRINT_START` / `PRINT_END` | Slicer start/end hooks (accept BED_TEMP, EXTRUDER_TEMP, AREA_START, AREA_END) |
| `BED_LEVEL_SCREWS_TUNE` | Corner screw tramming; repeat until within tolerance |
| `CALIBRATE_PROBE_Z_OFFSET` | Paper-test Z offset → Accept → `SAVE_CONFIG` (do while cold) |
| `AUTO_FULL_BED_LEVEL` | Full mesh to inspect bed flatness |
| `PID_TUNE_EXTRUDER`, `PID_TUNE_INNER_BED`, `PID_TUNE_OUTER_BED` | PID tuning; run each separately from cold |
| `Axis_Twist_Comp_Tune` | Axis twist compensation |

### OrcaSlicer start G-code for OpenNept4une (single line)
```
PRINT_START BED_TEMP=[hot_plate_temp_initial_layer] EXTRUDER_TEMP=[nozzle_temperature_initial_layer] AREA_START={first_layer_print_min[0]},{first_layer_print_min[1]} AREA_END={first_layer_print_max[0]},{first_layer_print_max[1]}
;Nozzle diameter = [nozzle_diameter]
;Filament type = [filament_type]
;Filament name = [filament_vendor]
;Filament weight = [filament_density]
```
End G-code: `PRINT_END`.
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
Stock firmware/slicer profiles switch the outer zone based on model size. On OpenNept4une, check the `PRINT_START`
macro or `printer.cfg` for the outer-bed heater name and logic before advising exact commands. Don't guess
heater object names; read `printer.cfg` (`[heater_generic ...]` / `[heater_bed]` sections) or query Moonraker.

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

## Moonraker API (for Claude to query or control the printer)
Base URL: `http://<printer-ip>:7125` (or port 80 through the web UI proxy).
```bash
# Status (read-only, safe)
curl -s "http://$IP:7125/printer/objects/query?extruder&heater_bed&print_stats&toolhead"
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
