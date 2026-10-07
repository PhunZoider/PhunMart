"""
Repaints the bottom band of a machine front (below the tray, FRONT rows KICK_TOP..bottom) as a
clean kick panel with a vent grille, in place.

Run headless from the repo root, naming the images to fix:
    "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
        --python Tools/blender/paint_kick_panel.py -- <image.png> [<image.png> ...]

Works on a full wrap texture (1024 x 1024, FRONT at the top left) or on front_base.png
(512 x 1024, the FRONT alone): either way the front is the image's left 512 columns.
The panel colour is taken from the band being replaced, so it matches the cabinet around it.
"""

import os
import sys

import bpy
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import vending_layout as L  # noqa: E402

KICK_TOP = 881  # first row below the tray frame, in FRONT pixels
FRONT_W = L.FRONT[2] - L.FRONT[0]
FRONT_H = L.FRONT[3] - L.FRONT[1]

BORDER = 10  # recessed panel edge, in from the band's sides
VENT_MARGIN_X = 70  # grille, in from the front's sides
VENT_TOP, VENT_BOTTOM = 908, 982  # grille rows (the plinth starts at 1002)
SLOT_H, SLOT_PITCH = 4, 9


def load(path):
    img = bpy.data.images.load(path)
    w, h = img.size
    px = np.empty(w * h * 4, np.float32)
    img.pixels.foreach_get(px)
    bpy.data.images.remove(img)
    return np.flipud(px.reshape(h, w, 4)).copy()


def save(arr, path):
    h, w = arr.shape[:2]
    img = bpy.data.images.new("out", w, h, alpha=True)
    img.pixels.foreach_set(np.flipud(arr).ravel())
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def paint(arr):
    band = arr[KICK_TOP:FRONT_H, 0:FRONT_W]
    base = np.median(band[..., :3].reshape(-1, 3), axis=0)
    rows = FRONT_H - KICK_TOP

    # A plain panel, a touch lighter at the top and darker towards the floor.
    shade = np.linspace(1.08, 0.88, rows)[:, None, None]
    band[..., :3] = np.clip(base * shade, 0, 1)
    band[..., 3] = 1

    # Recessed panel edge: dark along the top and left, light along the bottom and right.
    dark, light = base * 0.55, np.clip(base * 1.6, 0, 1)
    top, bottom = BORDER, rows - BORDER - 22  # stop above the plinth rows
    left, right = BORDER, FRONT_W - BORDER
    band[top, left:right, :3] = dark
    band[top:bottom, left, :3] = dark
    band[bottom, left:right + 1, :3] = light
    band[top:bottom + 1, right, :3] = light

    # Vent grille: horizontal slots, each with a highlight on its lower lip.
    slot = base * 0.25
    for y in range(VENT_TOP, VENT_BOTTOM - SLOT_H + 1, SLOT_PITCH):
        r = y - KICK_TOP
        band[r:r + SLOT_H, VENT_MARGIN_X:FRONT_W - VENT_MARGIN_X, :3] = slot
        band[r + SLOT_H, VENT_MARGIN_X:FRONT_W - VENT_MARGIN_X, :3] = light * 0.85


def main():
    paths = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    for path in paths:
        arr = load(path)
        paint(arr)
        save(arr, path)
        print("painted", path)


main()
