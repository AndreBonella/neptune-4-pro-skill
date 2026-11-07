---
name: neptune-4-pro-remote
description: Operating an Elegoo Neptune 4 Pro running OpenNept4une (Klipper + Moonraker) directly from Claude Code — checking status, preparing and uploading G-code safely, starting and watching prints, babystepping, editing printer.cfg, and diagnosing MCU shutdowns ("Timer too close", "Missed scheduling of next digital out event", "Timeout with MCU") from klippy.log. Use when the user asks Claude to talk to, watch, start, fix or debug their Neptune 4 Pro over the network or SSH. For slicer settings, filaments and calibration, use the neptune-4-pro skill instead.
---

# Operating a Neptune 4 Pro remotely

Lessons from driving a Neptune 4 Pro (OpenNept4une, Klipper v0.13) from Claude Code over a few weeks: slicing headless,
uploading over a flaky network, and tracking down three different mid-print MCU shutdowns. Pairs with the
`neptune-4-pro` skill, which has the settings, macros and Moonraker basics (`../neptune-4-pro/references/klipper.md`).

## Ground rules

- **Someone may be standing at the printer, or nobody is.** Read-only calls are always fine. Ask before anything that
  heats, moves, homes, starts/cancels a print, restarts Klipper, runs `SAVE_CONFIG` or edits config.
  Never `SAVE_CONFIG` or restart Klipper while a print is running: it ends the print.
- **Check the state first, every time** (`scripts/n4_status.sh <ip>`). Moonraker refuses a new print while one is
  running, but a G-code script will run in the middle of a print.
- **Back up before editing config** (download it, keep the copy, then upload the change).
- **The touchscreen's serial port (`/dev/ttyS1`) belongs to the display service.** Never open it, or run anything that
  does, while `display.service` (display_connector) is running. Two writers corrupt the panel's state.
- **Ask before installing services, systemd units or anything that runs as root.** Show the user the command and let them
  run it.

## Finding the printer

Moonraker listens on port **7125** (the web UI on 80/81 proxies it too). If the IP changed, scan the LAN for 7125:
`for i in $(seq 1 254); do (curl -s -m1 -o /dev/null -w "%{http_code} 192.168.1.$i\n" http://192.168.1.$i:7125/server/info &) ; done | grep ^200`.
SSH is `mks@<ip>`. The password is whatever the owner set; ask, don't guess.

## Workflow for a print

1. **Status:** `scripts/n4_status.sh <ip>`. It shows klippy state, job, temperatures, Z and serial-link retransmits.
2. **Slice.** If slicing headless, see `references/slicing-headless.md`.
3. **Fix the G-code before uploading:**
   - `scripts/shrink_polygons.py file.gcode` (or `--check`). Plates with several detailed objects carry outlines of
     ~1000 points per object, and KAMP's purge macro walking them stalled Klipper into "Timer too close"
     (`references/mcu-shutdowns.md`, cause 1). It writes `file_fixed.gcode`, changing only the `EXCLUDE_OBJECT_DEFINE` lines.
   - If the file has no thumbnail (Orca CLI writes none), add one, or the screen shows no preview.
4. **Upload with a read-back:** `scripts/upload_verified.sh <ip> file_fixed.gcode`. A flaky printer network
   (the N4 Pro's Ethernet can drop several percent of packets) can corrupt an upload silently. The script compares SHA-256
   and retries.
5. **Start** (after the user says go): `curl -X POST "http://<ip>:7125/printer/print/start?filename=<name>"`.
6. **Watch the first layer.** Camera: `GET /server/webcams/list` gives each camera's `snapshot_url`. Fetch a snapshot
   and look at it. Most first-layer failures show in the first 2–3 minutes. The usual fix is a live babystep:
   `SET_GCODE_OFFSET Z_ADJUST=-0.025 MOVE=1` (more squish), which is lost on restart.
7. **Progress:** `print_stats.info.current_layer` is only set if the slicer emits `SET_PRINT_STATS_INFO`. Otherwise
   follow `gcode_move.gcode_position[2]` (Z) and `virtual_sdcard.progress`. Orca's machine G-code can add it:
   start `SET_PRINT_STATS_INFO TOTAL_LAYER=[total_layer_count]`, layer change `SET_PRINT_STATS_INFO CURRENT_LAYER={layer_num + 1}`.

## When it stops with an error

Run `scripts/shutdown_report.sh <ip>` and read `references/mcu-shutdowns.md`. Key points:
- **An MCU shutdown cannot be resumed.** Klipper loses position and heater state. Don't try to restart it at a layer
  height. Cancel, clear the plate, fix the cause, print again.
- Klipper needs `FIRMWARE_RESTART` (`POST /printer/firmware_restart`) after an MCU shutdown. On printers with a realtime
  affinity setup, **check the serial IRQ thread's priority after every FIRMWARE_RESTART** (cause 2). It silently
  drops back and causes the next shutdown.

## Editing printer.cfg over Moonraker

```bash
curl -s "http://$IP:7125/server/files/config/printer.cfg" -o printer.cfg          # download (keep a copy)
cp printer.cfg printer-$(date +%Y%m%d).cfg.bak
# edit; never touch the #*# SAVE_CONFIG block by hand unless you know why
curl -s -F "root=config" -F "file=@printer.cfg" "http://$IP:7125/server/files/upload"
curl -s -X POST "http://$IP:7125/printer/restart"                                 # ask first; not during a print
```
Then check that `webhooks.state` is `ready`. If it says `error`, the message names the bad line. Upload the backup
to roll back.

## Files

- `scripts/n4_status.sh` — read-only status summary.
- `scripts/upload_verified.sh` — upload + SHA-256 read-back + retry. Doesn't start the print.
- `scripts/shrink_polygons.py` — shrink exclude-object outlines to bounding boxes (stdlib Python).
- `scripts/shutdown_report.sh` — fetch klippy.log and show what led to the last MCU shutdown.
- `references/mcu-shutdowns.md` — reading klippy.log and the three causes found so far, with fixes.
- `references/slicing-headless.md` — OrcaSlicer CLI, plates with many copies, first-layer settings that worked.
