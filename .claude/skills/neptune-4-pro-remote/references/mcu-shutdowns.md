# MCU shutdowns on the Neptune 4 Pro (OpenNept4une)

The mainboard MCU (STM32) talks to the host (Rockchip RK3328, Armbian) over a UART, `/dev/ttyS0`.
Klipper's host process schedules every step and heater change ahead of time. If the host falls behind, or the
UART stops moving bytes, the MCU shuts down to protect the hardware. The message says which side failed.

## Reading klippy.log

Get it with `scripts/shutdown_report.sh <ip>`, or `GET /server/files/klippy.log` (rotated copies:
`/server/files/list?root=logs`). Around the shutdown, look for:

| Line | Meaning |
|---|---|
| `MCU 'mcu' shutdown: Timer too close` | The host sent a command too late. Usually the **host stalled**. |
| `MCU 'mcu' shutdown: Missed scheduling of next digital out event` | A heater/pin update arrived late. Usually **communication**. |
| `Lost communication with MCU 'mcu'` / `Timeout with MCU 'mcu'` | Nothing came back over the UART. **Communication**. |
| `Reactor <t> busy for <s> with: - '<handler>'` | Klipper's main loop was blocked for `<s>` seconds by that handler, just before the shutdown. Anything over ~0.1 s at print time is enough. |
| `Dumping serial stats: ... bytes_retransmit=N` | `N` is the retransmitted bytes since the last restart. Tens is normal. Hundreds or more in a short time = the link is in trouble. |
| `Stats <t>: ... bytes_retransmit=N` | Printed every second. Watch `N` jump to time when the trouble started. |

The live counter is also in Moonraker: `printer/objects/query?mcu` → `last_stats.bytes_retransmit`.
`scripts/n4_status.sh` prints it. It's worth a glance a few minutes into every print.

## Cause 1: KAMP stalls on large object outlines ("Timer too close" at the purge line)

**Signature:** the shutdown comes right after `KAMP purge starting at ...`, with `Reactor ... busy for 0.2+ with:
VirtualSD.work_handler`. `bytes_retransmit` stays low.

**Why:** OrcaSlicer (and others) write each object's real outline into `EXCLUDE_OBJECT_DEFINE ... POLYGON=[...]`. For a
detailed model that's ~900 points per object, or ~16 KB per line. KAMP's `Smart_Park` and `LINE_PURGE` collect every point
of every object in Jinja (`printer.exclude_object.objects | map(attribute='polygon') | sum(start=[])`), then take min/max.
With 9 detailed objects (8154 points), this blocked the reactor for 0.226 s while the purge moves were already queued.

**Fix:** shrink the outlines before uploading: `scripts/shrink_polygons.py file.gcode`. The same file with only the
outlines reduced to bounding boxes went through the purge and kept printing. KAMP only uses the min/max, so
the purge and park positions don't change.
A config-side fix is to pass `AREA_START`/`AREA_END` from `PRINT_START` to the macros, so no polygon walk is needed. This was
reported upstream: OpenNeptune3D/OpenNept4une#455.

## Cause 2: serial IRQ thread priority drops after FIRMWARE_RESTART ("Missed scheduling" / "Timeout with MCU")

**Applies if** the printer runs the `affinity.service` that came with OpenNept4une v0.1.7 / display_connector
(`/usr/local/sbin/affinity-setup.sh` or `~/display_connector/affinity-setup.sh`). It pins services to cores, runs Klippy at
SCHED_FIFO 60 and raises the ttyS0 interrupt thread to FIFO 70. Check with:
```bash
systemctl is-active affinity.service
ps -eLo pid,cls,rtprio,psr,comm | grep -E 'ttyS0|klippy|python' | grep -v grep
```

**Signature:** the shutdown comes minutes or hours into a print that started after a `FIRMWARE_RESTART`. `bytes_retransmit`
jumps from tens to hundreds (seen: 18 → 908) just before.

**Why** (documented in OpenNeptune3D/OpenNept4une#445): the service raises `irq/<n>-ttyS0` above Klippy **when it runs**.
A `FIRMWARE_RESTART` closes and reopens ttyS0, and the kernel recreates the IRQ thread at its default FIFO 50, now
**below** Klippy at 60 on the same CPU. Under load, Klippy starves the UART interrupt that feeds it.

**Fixes, best first:**
- **Remove the affinity service.** display_connector's `dev` branch retired it (commit 3272efe, "remove affinity
  service and setup"). Its `affinity-setup.sh` became a one-time cleanup that disables the unit and deletes the files,
  and its scheduling changes clear on the next reboot. Updating display_connector, or running that cleanup, is the
  upstream path.
- **Until then, after every `FIRMWARE_RESTART`**, put the priority back (needs sudo; show the user the command):
  ```bash
  sudo chrt -f -p 70 $(ps -eo pid,comm | awk '/irq\/[0-9]+-ttyS0/{print $1}')
  ```
  Then confirm with the `ps` line above.

## Cause 3: UART TX DMA kernel bug (random "Lost communication" after hours)

Reported in OpenNeptune3D/OpenNept4une#444: on the RT kernel, `serial8250_tx_dma_flush()` can leave the TX DMA stuck,
so the kernel's TX counter for ttyS0 stops moving and Klipper times out. That issue's workaround is to remove
`dmas`/`dma-names` from `serial@ff110000` in the device tree, making the UART interrupt-driven. The reporter then ran 138 h of printing
without a disconnect after that. It is a DTB edit, so follow the issue's instructions exactly, and note that a
`linux-dtb` package upgrade reverts it.

## Not an MCU shutdown: the printer turns itself off

If SSH and the web UI vanish and the board is off, **check the power-loss monitor first**. OpenNept4une can run one that
watches the PSU's power-good/power-loss GPIO lines and calls `poweroff` (supercap-backed). After the next boot:
```bash
journalctl -b -1 --no-pager | grep -i -E 'power|poweroff|shutdown' | tail -30
```
A drop of the power-good line alone, while the power-loss line stays normal, was seen when a stepper enabled (TMC
`GSTAT` reset in klippy.log just before). That is a voltage sag, not a cut. A monitor that powers off on it gives
false shutdowns. OpenNept4une#442 covers the power monitor service.

## After any shutdown

1. Read the cause (above) before restarting anything.
2. `FIRMWARE_RESTART`, then fix the IRQ priority if cause 2 applies.
3. Don't resume. Cancel, clear the plate, fix the cause (e.g. shrink outlines), re-upload, print again.
