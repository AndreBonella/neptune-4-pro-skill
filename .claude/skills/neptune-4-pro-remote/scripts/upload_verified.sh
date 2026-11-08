#!/usr/bin/env bash
# Upload a G-code file to Moonraker, then download it again and compare checksums.
# Use it whenever the network is flaky: a silently truncated or corrupted upload prints garbage.
#   upload_verified.sh <printer-ip>[:port] FILE.gcode [NAME_ON_PRINTER]
# Does NOT start the print.
set -euo pipefail
H=${1:?usage: $0 <printer-ip>[:port] FILE [NAME]}; F=${2:?file}; N=${3:-$(basename "$F")}
[[ $H == *:* ]] || H=$H:7125
want=$(sha256sum "$F" | cut -d' ' -f1)
enc=$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$N")
for try in 1 2 3; do
  if curl -fsS -m 600 -F "root=gcodes" -F "file=@$F;filename=$N" "http://$H/server/files/upload" >/dev/null; then
    got=$(curl -fsS -m 600 "http://$H/server/files/gcodes/$enc" | sha256sum | cut -d' ' -f1 || true)
    if [[ $got == "$want" ]]; then echo "uploaded and verified: $N ($want)"; exit 0; fi
    echo "attempt $try: read-back checksum differs, retrying" >&2
  else
    echo "attempt $try: upload failed, retrying" >&2
  fi
  sleep 3
done
echo "upload could not be verified after 3 attempts; do not print this file" >&2
exit 1
