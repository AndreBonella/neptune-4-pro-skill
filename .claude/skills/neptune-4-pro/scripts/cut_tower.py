"""Cut Orca's 350->5 C temperature tower (10 mm per block, 350 C at the bottom)
to a start..end range, the same way OrcaSlicer's Calibration > Temperature does."""
import sys
import numpy as np
import trimesh

src, dst, t_start, t_end = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
EPS = 1e-4
mesh = trimesh.load(src, force="mesh")
# Orca 2.4.2 model: 70 blocks, label 500 C at z=0..10 down to 155 C at z=690..700 (verified by rendering)
TOP_LABEL = 500
lower = (TOP_LABEL - t_start) / 5 * 10.0 + EPS          # drop blocks hotter than start
upper = ((TOP_LABEL - t_end) / 5 + 1) * 10.0 + EPS      # keep up to and including end block

mesh = mesh.slice_plane([0, 0, upper], [0, 0, -1], cap=True)
mesh = mesh.slice_plane([0, 0, lower], [0, 0, 1], cap=True)
b = mesh.bounds
mesh.apply_translation([-(b[0][0] + b[1][0]) / 2, -(b[0][1] + b[1][1]) / 2, -b[0][2]])
mesh.export(dst)
print("blocks:", round((upper - lower) / 10), "size:", np.round(mesh.extents, 2), "watertight:", mesh.is_watertight)
