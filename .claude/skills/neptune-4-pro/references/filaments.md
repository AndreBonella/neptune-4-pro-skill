# Filament guide for the Neptune 4 Pro

All values assume the stock all-metal hotend, 0.4 mm nozzle, direct drive, PEI sheet.
They are **starting points** compiled from several guides (which disagree by 5–15 °C) — always run a
temperature tower for a new spool and prefer the range printed on the spool label.

## Quick table

| Filament | Nozzle °C | Bed °C | Part fan | Speed (outer / general) | Retraction | Enclosure | Hardened nozzle |
|---|---|---|---|---|---|---|---|
| PLA | 200–220 | 55–60 | 100% | 150 / 200–250 mm/s | 0.6–1.0 mm @ 30–40 mm/s | No (door/lid open) | No |
| High-speed PLA | 215–235 | 55–60 | 100% | 200 / 250–300 mm/s | 0.6–1.0 mm | No | No |
| PLA+ | 210–230 | 60 | 100% | 150 / 200 mm/s | 0.6–1.0 mm | No | No |
| Silk PLA | 215–230 | 60 | 80–100% | 60–100 / 120 mm/s | 0.5–0.8 mm | No | No |
| Matte PLA | 210–225 | 60 | 100% | 150 / 200 mm/s | 0.6–1.0 mm | No | No |
| Wood / marble PLA | 195–220 | 60 | 100% | 80 / 120 mm/s | 0.5–0.8 mm | No | Recommended (0.6 mm) |
| PLA-CF | 210–230 | 60 | 100% | 100 / 150 mm/s | 0.8 mm @ 30 mm/s | No | **Yes** |
| PETG | 230–250 | 70–85 | 30–60% | 80–120 / 150 mm/s | 0.8–1.2 mm @ 30–40 mm/s | No | No |
| PETG-CF | 240–260 | 75–85 | 30–50% | 80 / 120 mm/s | 0.8–1.0 mm | No | **Yes** |
| TPU 95A | 220–235 | 40–60 | 50–100% | 20–40 mm/s | 0–0.5 mm, slow | No | No |
| ABS | 240–260 | 95–110 | 0–20% | 80 / 150 mm/s | 0.6–1.0 mm | **Yes** | No |
| ASA | 245–265 | 95–110 | 0–30% | 80 / 150 mm/s | 0.6–1.0 mm | **Yes** | No |
| Nylon (PA6/PA12) | 250–280 | 70–90 | 0–30% | 50–80 / 100 mm/s | 0.8–1.2 mm | Recommended | No |
| PA-CF / PA-GF | 260–290 | 80–100 | 0–20% | 60 / 100 mm/s | 0.8 mm | Recommended | **Yes** |
| PC / PC blends | 270–300 (at the limit) | 100–110 | 0–20% | 40–60 / 80 mm/s | 0.6–1.0 mm | **Required** | No (PC-CF: yes) |

Fan % for PETG/ABS/ASA: raise it for bridges and overhangs (Orca "overhang fan speed").

---

## PLA family

### Standard PLA
- Easiest material; good for most prints. Fan at 100% after layer 1–3.
- **Max volumetric flow** is what limits speed, not the motion system. Run Orca's *Max flowrate* test. Typical stock N4P hotend: ~12–20 mm³/s for PLA depending on temp. Set the slicer's "max volumetric speed" a little under the measured value.
- Print hotter (≈220–230 °C) when you print fast. Print cooler (≈200–210 °C) for fine detail and overhangs.
- Leave the lid/door of any enclosure **open**, or PLA heat-creeps and clogs the all-metal hotend.
- **Release trick:** let the PEI sheet cool fully, then flex it. Parts pop off.
- Store dry. PLA tolerates humidity better than most, but brittle filament that snaps on the spool is wet or old.

### High-speed PLA (e.g. "HS PLA", "Hyper PLA")
- Formulated for higher flow. It lets you actually use 250–300 mm/s on the N4P.
- Needs higher temps (225–235 °C) at high flow. Check the max flow test again with this spool.

### Silk PLA
- The shine comes from slow, hot, well-cooled outer walls. Lower outer wall speed to 60–100 mm/s.
- Weaker layer adhesion and prone to stringing, so dry it and keep retraction short.
- Swells as it leaves the nozzle (die swell). Lower the flow ratio a few percent (0.95–0.97) if the surface gets blobby.
- Fewer walls and more infill make no difference to shine; only the outer wall matters.

### Matte PLA
- Slightly abrasive mineral fillers in some brands. Brass is usually fine, but check the label.
- Hides layer lines well. Good choice for figures and functional-looking parts.

### Wood / marble / stone-filled PLA
- Particles clog 0.4 mm nozzles. Use **0.6 mm** if you can, and avoid long pauses at temperature.
- **Wood-grain trick:** vary the nozzle temperature by layer (e.g. 195↔225 °C). Hotter layers come out darker.
- Sand and stain wood-filled prints like real wood.

### PLA-CF and other filled PLA (glow-in-the-dark too)
- **Abrasive.** Use a hardened steel nozzle. Brass loses its bore within hundreds of grams, and you'll see under-extrusion that gets worse over time.
- Hardened steel conducts heat worse than brass, so add **+5–10 °C** and recalibrate flow and PA.
- A 0.6 mm hardened nozzle reduces clogs from fibers.

---

## PETG
- **Bed adhesion is too good on smooth PEI.** PETG can rip chunks out of the coating. Use a thin layer of **glue stick (or Windex) as a release agent** on smooth PEI. Textured PEI is usually safe without it.
- **Don't squish the first layer** like PLA. Raise Z offset by ~0.02–0.05 mm vs your PLA offset. Too much squish makes PETG pile up on the nozzle and drop blobs.
- **Stringing is the #1 complaint.** Fix it in this order: **dry the filament** (65 °C, 4–6 h) → lower temp 5 °C → tune retraction (0.8–1.2 mm) → enable "wipe on retract" → small Z-hop (0.2 mm). Fast travel speeds (≥250 mm/s) help too.
- Fan 30–60%. Too much cooling hurts layer adhesion. Raise it for bridges and overhangs only.
- Nozzle buildup: wipe the nozzle with a brass brush while hot. A silicone sock helps a lot.
- PETG is slower than PLA at the same temp. Measure max volumetric flow separately (often ~10–15 mm³/s).

## TPU (flexible)
- The direct-drive extruder handles 95A TPU well. 85A and softer works, but needs very slow speeds (15–25 mm/s).
- **Speed is limited by flow.** Set max volumetric speed to ~3–5 mm³/s and let the slicer slow down.
- Retraction 0–0.5 mm at a slow speed. Too much retraction compresses TPU in the extruder and jams it. If using Klipper firmware retraction (OpenNept4une), check `SET_RETRACTION` values aren't overriding your slicer.
- Turn off or lower pressure advance (try 0.0–0.1 for TPU, calibrate it separately).
- TPU **bonds extremely hard to PEI**. Use glue stick as a release layer, especially on smooth PEI.
- **TPU absorbs moisture fastest.** It can go wet in days. Dry it (50–55 °C, 4–8 h) and ideally print it straight from a dryer box.
- Infill and wall count control how flexible the part is: fewer walls and lower gyroid infill make it softer.

## ABS
- **Needs an enclosure** (Elegoo sells one for the N4/N4 Pro, or use a DIY box). Warps and cracks between layers without one.
- **Heat the whole bed.** On the N4 Pro, make sure the **outer bed zone** is on for large ABS parts (see `klipper.md`). Preheat 10–15 min so the enclosure warms up.
- Fan 0–20%. Raise it only for bridges.
- Warping tricks: brim 5–8 mm, mouse ears on corners, a draft shield (Orca: Others → Draft shield), avoid sharp corners, no drafts in the room.
- Adhesion: textured PEI at 100–110 °C works. ABS slurry (ABS dissolved in acetone) or glue stick helps on smooth PEI.
- **Ventilate.** ABS releases styrene and ultrafine particles. Run it in a ventilated room or vent the enclosure outdoors.
- Acetone vapor smoothing gives a glossy finish. Do it outdoors with care; acetone is flammable.

## ASA
- Like ABS but **UV-stable** → best for outdoor parts. Slightly less warping than ABS.
- Same rules: enclosure, both bed zones, low fan, brim, ventilation.
- Dry at 80 °C for 4 h. It's less hygroscopic than nylon, but wet ASA gives a rough, bubbly surface.

## Nylon (PA6, PA12, PA-CF, PA-GF)
- **Extremely hygroscopic.** It goes wet in hours in humid air. Dry it at 70–80 °C for 8–12 h and **print straight from a dryer box**. Wet nylon pops, strings, and loses most of its strength.
- Adhesion: PEI with a glue stick layer, or garolite (G10) sheet. Bare PEI sometimes gives weak adhesion.
- Enclosure strongly recommended to reduce warping and layer splitting.
- Most PA-CF / PA-GF prints well at 260–290 °C, within the N4P's 300 °C limit. **Hardened nozzle mandatory.**
- Nylon parts get tougher after absorbing a little moisture (conditioning). Some users store finished parts in normal air for a few days.

## Polycarbonate (PC) and PC blends
- Pure PC wants 280–310 °C. The N4P tops out at **300 °C**, so choose **PC blends** (PC-ABS, PC-PBT, PC Blend) rated ≤290 °C.
- Enclosure is required. Bed 100–110 °C with both zones on. Fan off.
- Dry at 80 °C for 8 h. PC is very hygroscopic.
- Keep the hotend below its limit. Hold 300 °C only briefly, and never exceed it.

## CF / GF composites in general
- Always use a hardened nozzle. 0.6 mm is ideal for fewer clogs.
- Matte finish and good stiffness, but more brittle than the base polymer.
- Recalibrate flow and PA after swapping to the hardened nozzle.
- The fibers slowly wear the extruder gears too. Inspect them occasionally.

---

## Drying and storage

| Filament | Dry temp | Time | Moisture sensitivity |
|---|---|---|---|
| PLA | 45–50 °C (never above ~55 °C, coils fuse) | 4–6 h | Low–medium (2–4 weeks open) |
| PETG | 65 °C | 4–6 h | Medium (1–2 weeks open) |
| TPU | 50–55 °C (soft grades deform >60 °C) | 4–8 h | **High** (days) |
| ABS | 70–80 °C | 4 h | Medium |
| ASA | 80 °C | 4 h | Medium |
| Nylon / PA-CF | 70–80 °C | 8–12 h | **Very high** (hours) |
| PC | 80 °C | 8 h | High |

- **Signs of wet filament:** popping or hissing at the nozzle, steam, sudden stringing, rough or foamy surfaces, weak and brittle parts.
- Store spools sealed with silica gel (indicating beads are best). Recharge the desiccant when it changes color.
- A filament dryer is the easiest tool. For nylon/PC, check the dryer actually reaches 70–80 °C. Many cheap ones cap out at ~55–65 °C.
- Drying times vary by manufacturer. The spool label wins over this table.

## Bed surface (PEI) care
- Clean with **dish soap + warm water** every so often, and with IPA between prints. Don't touch the print area with your fingers; skin oils kill adhesion.
- Smooth PEI: great PLA adhesion, but needs a release agent for PETG and TPU.
- Textured PEI: hides first-layer marks and releases PETG safely. Fine textures don't show on PLA.
