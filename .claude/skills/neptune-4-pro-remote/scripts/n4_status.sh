#!/usr/bin/env bash
# One-shot, read-only printer summary from Moonraker.
#   n4_status.sh <printer-ip-or-host>[:port]      (port defaults to 7125)
set -euo pipefail
H=${1:?usage: $0 <printer-ip>[:port]}; [[ $H == *:* ]] || H=$H:7125
q='print_stats&virtual_sdcard&webhooks&extruder&heater_bed&heater_generic%20heater_bed_outer&toolhead&gcode_move&mcu'
read -r -d '' PY <<'PYEOF' || true
import json, sys
s = json.load(sys.stdin)["result"]["status"]
def g(obj, key, default=None):
    return (s.get(obj) or {}).get(key, default)
ps = s.get("print_stats", {})
msg = (g("webhooks", "state_message") or "").splitlines()
print(f"klippy   {g('webhooks', 'state')}  {msg[0][:90] if msg else ''}")
print(f"job      {ps.get('state')}  {ps.get('filename') or '-'}")
if ps.get("state") in ("printing", "paused"):
    info = ps.get("info") or {}
    layer = f"{info.get('current_layer')}/{info.get('total_layer')}" if info.get("total_layer") else "n/a (no SET_PRINT_STATS_INFO)"
    z = (g("gcode_move", "gcode_position") or [0, 0, 0])[2]
    print(f"progress {g('virtual_sdcard', 'progress', 0) * 100:.1f}%  printed {ps.get('print_duration', 0) / 60:.0f} min  layer {layer}  Z {z:.2f}")
for name, obj in (("nozzle", "extruder"), ("bed", "heater_bed"), ("outer", "heater_generic heater_bed_outer")):
    if obj in s:
        print(f"{name:8} {g(obj, 'temperature', 0):.1f} / {g(obj, 'target', 0):.0f} C")
print(f"homed    {g('toolhead', 'homed_axes') or 'none'}")
st = g("mcu", "last_stats") or {}
print(f"mcu link {st.get('bytes_retransmit')} bytes retransmitted, {st.get('bytes_invalid')} invalid since the last restart (a jump of hundreds = link trouble)")
PYEOF
curl -fsS -m 10 "http://$H/printer/objects/query?$q" | python3 -c "$PY"
