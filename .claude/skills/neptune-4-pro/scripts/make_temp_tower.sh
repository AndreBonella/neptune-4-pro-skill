#!/usr/bin/env bash
# Build a ready-to-print OrcaSlicer-style temperature tower G-code for the Neptune 4 Pro (stock firmware profile).
# usage: make_temp_tower.sh <start_temp> <end_temp> <bed_temp> <out_dir> [orca_dir] [filament_profile]
#   e.g. make_temp_tower.sh 225 185 60 /tmp/tt
# Needs: draco_decoder, python3, and a venv with trimesh scipy shapely mapbox-earcut manifold3d (VENV env var,
# default <out_dir>/venv; created if missing). OrcaSlicer extracted AppImage dir (default ~/Applications/OrcaSlicer-2.4.2).
set -euo pipefail
START=$1; END=$2; BED=$3; OUT=$4
ORCA=${5:-$HOME/Applications/OrcaSlicer-2.4.2}
FIL=${6:-Elegoo PLA @EN4 Series}
HERE=$(cd "$(dirname "$0")" && pwd)
VENV=${VENV:-$OUT/venv}
PROFILES=$ORCA/resources/profiles
mkdir -p "$OUT/out"

if [ ! -x "$VENV/bin/python" ]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install -q trimesh numpy scipy shapely mapbox-earcut manifold3d networkx pillow rtree
fi

draco_decoder -i "$ORCA/resources/calib/temperature_tower/temperature_tower.drc" -o "$OUT/tower.obj" >/dev/null
"$VENV/bin/python" -I "$HERE/cut_tower.py" "$OUT/tower.obj" "$OUT/tower_cut.stl" "$START" "$END"
"$VENV/bin/python" -I "$HERE/render_front.py" "$OUT/tower_cut.stl" "$OUT/tower_preview.png"   # check labels

# Profiles must be flattened and marked "system", or the Orca CLI rejects printer/process compatibility (-17).
python3 -I "$HERE/flatten_profile.py" "$PROFILES" machine "Elegoo Neptune 4 Pro 0.4 nozzle" "$OUT/machine.json" \
  'name="Elegoo Neptune 4 Pro 0.4 nozzle"' 'from="system"'
python3 -I "$HERE/flatten_profile.py" "$PROFILES" process "0.20mm Standard @Elegoo N4Pro 0.4 nozzle" "$OUT/process.json" \
  'name="0.20mm Standard @Elegoo N4Pro 0.4 nozzle"' 'from="system"' 'brim_type="outer_only"' 'brim_width="5"'
B="[\"$BED\"]"
python3 -I "$HERE/flatten_profile.py" "$PROFILES" filament "$FIL" "$OUT/filament.json" \
  "name=\"$FIL\"" 'from="system"' "nozzle_temperature=[\"$START\"]" "nozzle_temperature_initial_layer=[\"$START\"]" \
  "cool_plate_temp=$B" "cool_plate_temp_initial_layer=$B" "eng_plate_temp=$B" "eng_plate_temp_initial_layer=$B" \
  "hot_plate_temp=$B" "hot_plate_temp_initial_layer=$B" "textured_plate_temp=$B" "textured_plate_temp_initial_layer=$B"

(cd "$OUT" && "$ORCA/AppRun" --load-settings "machine.json;process.json" --load-filaments filament.json \
  --arrange 1 --slice 0 --outputdir out tower_cut.stl >/dev/null 2>&1) || true
grep -q '"Success."' "$OUT/out/result.json" || { cat "$OUT/out/result.json"; exit 1; }

STEP=5
python3 -I "$HERE/add_temp_steps.py" "$OUT/out/plate_1.gcode" "$OUT/TempTower_${START}-${END}.gcode" "$START" "$STEP"
grep -m3 -E '^M190|^M109' "$OUT/TempTower_${START}-${END}.gcode"
grep 'estimated printing time' "$OUT/TempTower_${START}-${END}.gcode"
echo "G-code: $OUT/TempTower_${START}-${END}.gcode"
