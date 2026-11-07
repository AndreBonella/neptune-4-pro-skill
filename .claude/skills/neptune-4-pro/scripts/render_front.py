"""Render a depth image of the mesh as seen from the front (-Y) and the back (+Y) to a PNG."""
import sys
import numpy as np
import trimesh
from PIL import Image

mesh = trimesh.load(sys.argv[1], force="mesh")
out = sys.argv[2]
res = 0.25
(x0, y0, z0), (x1, y1, z1) = mesh.bounds
xs = np.arange(x0, x1, res)
zs = np.arange(z0, z1, res)
X, Z = np.meshgrid(xs, zs)
imgs = []
for y_start, d in ((y0 - 5, 1.0), (y1 + 5, -1.0)):
    origins = np.column_stack([X.ravel(), np.full(X.size, y_start), Z.ravel()])
    dirs = np.tile([0, d, 0], (X.size, 1))
    locs, idx, _ = mesh.ray.intersects_location(origins, dirs, multiple_hits=False)
    depth = np.full(X.size, np.nan)
    depth[idx] = np.abs(locs[:, 1] - y_start)
    img = depth.reshape(X.shape)[::-1]
    finite = img[np.isfinite(img)]
    lo, hi = np.percentile(finite, 1), np.percentile(finite, 99)
    norm = np.clip((img - lo) / max(hi - lo, 1e-6), 0, 1)
    norm = np.where(np.isfinite(img), 1 - norm, 0)
    if d < 0:
        norm = norm[:, ::-1]  # mirror back view so text reads correctly
    imgs.append((norm * 255).astype(np.uint8))
pad = np.zeros((imgs[0].shape[0], 20), np.uint8)
Image.fromarray(np.hstack([imgs[0], pad, imgs[1]])).resize(
    (int((imgs[0].shape[1] * 2 + 20) * 2), imgs[0].shape[0] * 2)).save(out)
print("saved", out)
