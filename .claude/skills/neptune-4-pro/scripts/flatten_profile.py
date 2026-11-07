"""Flatten an OrcaSlicer system profile (resolve the `inherits` chain) into one JSON for the CLI.
usage: flatten_profile.py <profiles_dir> <kind: machine|process|filament> <profile name> <out.json> [key=value ...]"""
import json
import os
import sys

root, kind, name, out = sys.argv[1:5]
overrides = sys.argv[5:]

index = {}
for vendor in os.listdir(root):
    vdir = os.path.join(root, vendor, kind)
    if not os.path.isdir(vdir):
        continue
    for dp, _, files in os.walk(vdir):
        for f in files:
            if f.endswith(".json"):
                p = os.path.join(dp, f)
                try:
                    d = json.load(open(p, encoding="utf-8"))
                except Exception:
                    continue
                if "name" in d:
                    index.setdefault(d["name"], p)

chain = []
cur = name
while cur:
    if cur not in index:
        sys.exit(f"profile not found: {cur}")
    d = json.load(open(index[cur], encoding="utf-8"))
    chain.append(d)
    cur = d.get("inherits")

merged = {}
for d in reversed(chain):
    merged.update(d)
merged.pop("inherits", None)
merged["name"] = name + " (flattened)"
merged["from"] = "User"
merged["is_custom_defined"] = "1"
for kv in overrides:
    k, v = kv.split("=", 1)
    merged[k] = json.loads(v)
json.dump(merged, open(out, "w"), indent=1)
print(kind, "chain:", " <- ".join(c["name"] for c in chain))
