# Neptune 4 Pro — Claude Code skill

A [Claude Code](https://claude.com/claude-code) skill (also usable by other agents that support `SKILL.md`)
that gives printer-specific help for the **Elegoo Neptune 4 Pro** (Klipper):

- **Filament settings and tips** for PLA, high-speed PLA, PLA+, silk, matte, wood, PLA-CF, PETG, PETG-CF, TPU, ABS, ASA, nylon, PA-CF and PC blends, plus drying and storage
- **Calibration:**
  - Machine: PID, Z offset, bed mesh, axis twist, input shaping.
  - Per filament, in any slicer: temperature, flow ratio, pressure advance, retraction, max volumetric flow.
- **Per-filament test log** (`filament-profiles/`). Calibrated values are saved and reused instead of generic ranges.
- **Firmware:** stock Elegoo vs [OpenNept4une](https://github.com/OpenNeptune3D/OpenNept4une), macros, start G-code, Moonraker API
- **Troubleshooting** table (stringing, warping, clogs, layer shifts, first-layer issues)
- **General tricks:** orientation, supports, brim, infill, modifiers, long-print checklist, tools

## Install

**Personal (all projects):**
```bash
git clone https://github.com/AndreBonella/neptune-4-pro-skill.git
mkdir -p ~/.claude/skills
cp -r neptune-4-pro-skill/.claude/skills/neptune-4-pro ~/.claude/skills/
```

**Per project:** copy `.claude/skills/neptune-4-pro` into your project's `.claude/skills/`, or just open Claude Code inside this cloned repo.

Then ask Claude things like *"PETG settings for my Neptune 4 Pro"*, *"calibrate Polymaker PLA white"*, or *"my prints are stringing"*.

## Layout
```
.claude/skills/neptune-4-pro/
├── SKILL.md                    printer facts, hard limits, workflow
├── references/
│   ├── filaments.md            per-filament settings, tips, drying
│   ├── calibration.md          machine + per-filament calibration tests
│   ├── klipper.md              firmware, macros, G-code, Moonraker API
│   ├── troubleshooting.md      symptom → cause → fix
│   └── tips-and-tricks.md      slicing/workflow tips, tools
└── filament-profiles/
    ├── README.md               index of calibrated filaments
    └── _TEMPLATE.md            record template per filament
```

## Disclaimer
Settings are **starting points** compiled from community guides, retailer specs and videos (sources are listed in
`SKILL.md` and `references/tips-and-tricks.md`). Always calibrate your own spool. Respect the printer's limits
(300 °C nozzle, 110 °C bed). Follow OpenNept4une's own instructions when flashing firmware: a wrong stepper current
setting can damage the motors.
