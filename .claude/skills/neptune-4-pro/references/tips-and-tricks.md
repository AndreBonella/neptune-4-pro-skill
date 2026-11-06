# General tips and tricks (slicing, workflow, tools)

Printer-agnostic tips that apply well to the Neptune 4 Pro. Filament-specific tips live in `filaments.md`.
Where a tip from a video conflicted with the earlier researched guidance, the researched guidance was kept
(noted inline).

## Orientation and supports
- **Rotate before you add supports.** Flipping or rotating a model often removes the need for supports completely, saving time and filament. Try the slicer's auto-orient, then judge yourself.
- The **face on the bed comes out smoothest**, because it's pressed flat onto the PEI. Put the visible or important face down when you can. The last top layer is usually the roughest surface.
- **Tree supports** for most cases: less filament, faster, easier to remove. Use **normal (grid) supports** when a large flat overhang needs a clean, flat underside.
- Keep **needle-nose pliers** (and flush cutters) for supports in tight spots.

## Bed adhesion and warping
- **Brim 5–7 mm** on boxes, flat parts with sharp corners, and tall or thin parts with a small footprint. It stops corners from curling and keeps narrow parts from tipping. A tiny gap setting between brim and part makes it peel off cleanly.
- **Glue stick:** any cheap school glue stick (PVP/PVA) works as well as branded "3D printer" glue. Apply a thin layer one way, then crosswise. On the N4P's PEI it's mainly a **release agent for PETG and TPU** and an adhesion aid for nylon (see `filaments.md`).
- Bed cleaning: one video argued you don't need to clean the plate or avoid touching it. **The researched guidance is kept:** wipe with IPA between prints, wash with dish soap when adhesion drops, and avoid touching the print area. Finger oils are a common cause of first-layer failures on PEI.

## Infill
- **Gyroid** is a great default. Its lines don't cross on the same layer the way grid does, so the nozzle doesn't scrape over crossings (clicking sounds, knocked-off prints). It's also strong in all directions.
- **Lower infill for decorative parts.** Wall art or figures can often go from 15% to 5–7%. In the video example that cut a print from 9.5 h / 250 g to 6.7 h / 178 g. A lighter part is also easier to mount and cheaper to ship.
- Strength comes more from **walls/perimeters** than infill. Add walls before you add infill for functional parts.

## Modifiers, negative parts and per-region settings
- Slicers (Orca, Bambu Studio, PrusaSlicer, Cura's "per-model settings") let you add a **modifier volume**: a cylinder or box placed in the model with its own settings (higher infill, more walls, ironing, different speed). Use it to reinforce screw bosses or stress points without slowing down the whole print.
- **Negative parts** cut geometry out in the slicer, e.g. a quick screw hole, so you don't need to go back to CAD.

## Pre-flight checklist for long prints
Before an 8+ hour print:
1. Calibration is recent (Z offset, bed mesh/KAMP, the filament has a record in `filament-profiles/`).
2. Belt tension is OK, eccentric nuts have no play, and the rods/rails are clean (lube if the manufacturer says so).
3. Nozzle and hotend are clean, with no buildup on the silicone sock.
4. **Enough filament on the spool** for the whole print (check the weight in the slicer against the spool), and the filament is dry.
5. Nothing near the printer can fall in or block the bed's Y travel (boxes, cables). The N4P's bed moves front to back.
6. A webcam or Mobileraker/Fluidd for monitoring, if available.

## Using leftover filament
- Use partial spools for small prints. Don't throw them away.
- For multi-spool prints, use the **filament runout sensor** (if fitted/enabled in your firmware) to pause automatically. Or insert a pause at a chosen layer in the slicer (Klipper: `PAUSE`, or `M600` if a macro defines it), swap the spool, and `RESUME`. Expect a faint line at the change layer, so do this on parts where looks matter less.
- **Refill spools** (filament without a spool) are cheaper. Print a reusable spool for them, following the spool maker's design.
- Empty spools can be reused: print drawer racks, storage, lamps, or wind cables on them.

## Filament quality
- Very cheap, poor-quality filament can clog or damage nozzles, with inconsistent diameter and contamination. It isn't worth the savings, especially on long prints.

## Post-processing and tools
- **CA glue (superglue) plus activator spray** bonds PLA/PETG parts almost instantly.
- **IPA (isopropyl alcohol) plus a microfiber cloth:** bed cleaning, general printer cleaning, degreasing prints before paint or glue.
- **Painting small details:** thinned acrylic paint, several thin coats. Use a plastic primer if you're painting the whole part. It's cheaper and faster than multi-color printing for small accents.
- **Desiccant:** keep the silica packs that come with filament and reuse them in your storage boxes. Recharge or replace them when saturated. Indicating (color-changing) silica shows when it's spent. Prefer non-toxic indicator types, e.g. orange→green, over cobalt-chloride blue.

## Learn basic CAD
Simple modeling (Tinkercad to start, later Fusion, Onshape, FreeCAD, OpenSCAD/CadQuery) lets you fix and adapt
downloaded models: add holes, hollow parts, cut edges. That's often more useful than designing from scratch.

## Sources
- Factorian Designs, "Filament Calibration Masterclass – 95% do it wrong!" (youtube.com/watch?v=gVU5If1VsAM)
- InitMakes, "3D Printing Tricks You SHOULD KNOW! - Do You?" (youtube.com/watch?v=mV9irIrbsTk)
