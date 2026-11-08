# Troubleshooting on the Neptune 4 Pro

**Check wet filament first.** It causes stringing, popping, rough surfaces, weak parts and blobs on every material.
Then check temperature, then calibration (flow → PA → retraction).

| Symptom | Likely causes | Fixes |
|---|---|---|
| Stringing / hairs | Wet filament; too hot; retraction too short; slow travel | Dry the spool; −5 °C; retraction test (0.4–1.5 mm); travel ≥250 mm/s; wipe on retract; PETG: small Z-hop |
| Stringing that retraction changes don't affect | Firmware retraction is on (`G10`/`G11`), so the slicer's retraction length is ignored; Klipper's default length is 0 | `GET_RETRACTION`; set `SET_RETRACTION RETRACT_LENGTH=...` in filament start G-code, or disable firmware retraction in the slicer (see `klipper.md`) |
| Blobs / zits on walls | PA wrong; seam settings; wet filament | Calibrate PA; seam "aligned"/"back"; enable scarf seam (Orca); dry the spool |
| Under-extrusion at speed | Exceeding hotend flow | Run max flow test; set max volumetric speed lower; raise temp 5–10 °C; high-speed filament |
| Gradually worse under-extrusion | Worn brass nozzle (abrasive filament); partial clog | Replace with hardened nozzle; cold pull |
| Extruder clicking / grinding | Clog; flow too high; nozzle too close on layer 1; heat creep | Lower speed/flow; raise Z offset; cold pull; keep enclosure open for PLA |
| Clog with PLA in enclosure | Heat creep in all-metal hotend | Open the lid/door; check the hotend fan; avoid long idle at temp |
| First layer not sticking | Dirty PEI; Z too high; bed not meshed | Wash PEI with dish soap; lower Z offset; re-mesh hot; slower first layer (~30–50 mm/s) |
| First layer rough / ridges | Z too low (over-squish) | Raise Z offset 0.01–0.02 mm at a time |
| Uneven first layer (one side) | Bed tram; gantry not level; axis twist | `Bed_Level_Screws_Tune`; level both Z sides; axis twist compensation |
| Warping / corners lifting | Drafts; no enclosure (ABS/ASA); bed too cool; sharp corners | Enclosure; heat both bed zones; brim/mouse ears; draft shield; glue stick |
| Layer splitting (ABS/ASA/nylon) | Too much cooling; cold ambient | Fan 0–20%; enclosure; +5–10 °C |
| PETG ripped the PEI | PETG over-bonds to smooth PEI | Glue stick/Windex as release; textured PEI; less squish |
| Ringing / ghosting | Input shaper not tuned; loose belts | `SHAPER_CALIBRATE` (ADXL) or ringing tower; tension belts; lower accel |
| Layer shifts | Belts loose; head collision with curled parts; stepper overheating; accel too high | Tension belts; Z-hop on travel; fix warping; lower accel; check stepper current setting (OpenNept4une) |
| Wobbly X carriage / bed wheels | Eccentric nuts loose | Adjust eccentric nuts: no play, still rolls freely |
| Elephant's foot | First layer too squished; bed too hot | Raise Z slightly; Orca "elephant foot compensation" 0.1–0.2 mm |
| Pillowing / holes in top surface | Too few top layers; low fan | 5+ top layers (or ≥0.8 mm); 100% fan for PLA; monotonic top |
| Popping / steam / bubbles | Wet filament | Dry (see `filaments.md` table) |
| TPU jams in extruder | Too fast; retraction too long | ≤3–5 mm³/s; retraction 0–0.5 mm; dry; lower PA |
| Klipper "MCU shutdown" / heater errors | Loose thermistor/heater wires; PID untuned; failing part | Re-run PID; check connectors at hotend and bed; inspect wiring at the strain relief |
| "Timer too close" right at the KAMP purge line | Klipper stalled walking huge exclude-object outlines (full plates of detailed models) | Shrink the outlines before uploading (`neptune-4-pro-remote` skill, `scripts/shrink_polygons.py`) |
| "Missed scheduling of next digital out event" / "Timeout with MCU" mid-print, after a `FIRMWARE_RESTART` | OpenNept4une v0.1.7 `affinity.service` leaves the ttyS0 IRQ thread below Klipper after the restart (OpenNept4une#445) | See `neptune-4-pro-remote` → `references/mcu-shutdowns.md` (remove the affinity service, or re-apply the priority) |
| "Lost communication with MCU" after hours, at random | UART TX DMA kernel bug (OpenNept4une#444) | Device-tree workaround in that issue; see `mcu-shutdowns.md` |
| Printer powers itself off (no web UI, no SSH) | Power-loss monitor reacting to a voltage sag | `journalctl -b -1` after reboot; see `mcu-shutdowns.md` |
| Broke after Fluidd update (stock FW) | Elegoo's custom Klipper overwritten | Restore via Elegoo firmware image, or move to OpenNept4une |

## Cold pull (clearing a partial clog)
1. Heat to the print temp of what's loaded and push some filament through.
2. Cool to ~90–100 °C for PLA (or ~130 °C for PETG/ABS), keeping light pressure.
3. Pull the filament out firmly. The tip should carry a nozzle-shaped plug of debris.
4. Repeat until the tip comes out clean. Nylon filament is ideal for cleaning pulls.
