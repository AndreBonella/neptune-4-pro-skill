#!/usr/bin/env bash
# Pull klippy.log through Moonraker and show what led up to the most recent MCU shutdown.
#   shutdown_report.sh <printer-ip>[:port]
# Read-only. Look for, in this order:
#   "Reactor ... busy for X with:" just before the shutdown  -> the host stalled (e.g. a macro)
#   "Dumping serial stats: ... bytes_retransmit=N"           -> large N = serial link trouble
#   the last G-code / macro messages before the shutdown     -> what the printer was doing
set -euo pipefail
H=${1:?usage: $0 <printer-ip>[:port]}; [[ $H == *:* ]] || H=$H:7125
log=$(mktemp); trap 'rm -f "$log"' EXIT
curl -fsS -m 120 "http://$H/server/files/klippy.log" -o "$log"
n=$(grep -n "Transition to shutdown state" "$log" | tail -1 | cut -d: -f1 || true)
if [[ -z $n ]]; then echo "no MCU shutdown in the current klippy.log"; exit 0; fi
echo "== last shutdown (klippy.log line $n)"
grep -m1 -A0 "MCU '.*' shutdown:" <(tail -n +"$n" "$log") || true
echo "== what happened just before it (periodic Stats lines and client requests left out)"
head -n "$n" "$log" | grep -v -E "^Stats [0-9.]+:|^Received [0-9.]+: b'" | tail -n 15 | cut -c1-200
echo "== serial stats at the shutdown"
tail -n +"$n" "$log" | grep -m1 "Dumping serial stats" | tr ' ' '\n' | grep -E "bytes_(retransmit|invalid)|srtt|rto" | tr '\n' ' '; echo
echo "== stalls reported in this log (Reactor busy)"
grep -c "busy for" "$log" || true
