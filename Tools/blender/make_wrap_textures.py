"""
Builds the 3D machines' wrap textures (layout: vending_layout.py) from the shop UI backgrounds.

Run headless from the repo root:
    "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
        --python Tools/blender/make_wrap_textures.py

For every media/textures/machine-<name>.png it writes media/textures/phunmart/<name>.png:
    FRONT        the cabinet in front_base.png (painted for the 3D machine's proportions), with
                 the shop's banner from its art pasted into the header
    LEFT/RIGHT   plain cabinet, with a side panel filled from the banner's outer decoration
    BACK         cabinet with a condenser panel: coil and vent slats, after the 2D sprites
    TOP          plain cabinet
    TRIM         the dark window frame
    glow mask    banner and side panels fully lit, glass half lit (half size, bottom-right)
These are starting points: repaint any region by hand and the mesh picks it up unchanged. A
texture listed in HAND_PAINTED is never written: once someone has painted one, it is theirs.

To refresh only the glow mask of named textures (e.g. hand-painted ones, after the layout's
glow areas move), leaving their colour art alone:
    ... --python Tools/blender/make_wrap_textures.py -- --mask-only budget-xp [name ...]

To convert one shop image from anywhere (another mod's, say) to a texture anywhere:
    ... --python Tools/blender/make_wrap_textures.py -- --convert <machine-art.png> <out.png>
A mod's textures belong in its own media/textures/phunmart/, where shops find them by name.

Also writes Tools/blender/vending_template.png: every region in its own colour with the starter
glow areas outlined, for painting a new machine from scratch.

And Tools/blender/vending_overlay.png: a finished machine with the banner and side panels cut
out to transparency, to lay over a shop's own art in an image editor. Only that one:
    ... --python Tools/blender/make_wrap_textures.py -- --overlay
"""

import glob
import os
import sys

import bpy
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import vending_layout as L  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
TEXTURES = os.path.join(ROOT, "Contents", "mods", "PhunMart2", "common", "media", "textures")
OUT_DIR = os.path.join(TEXTURES, "phunmart")
TEMPLATE = os.path.join(HERE, "vending_template.png")
FRONT_BASE = os.path.join(HERE, "front_base.png")
OVERLAY = os.path.join(HERE, "vending_overlay.png")
# The art the overlay's cabinet and frames come from; its banner and side panels are cut away.
OVERLAY_SOURCE = os.path.join(TEXTURES, "machine-hard-wear.png")

# Textures painted by hand, by name. Skipped entirely.
HAND_PAINTED = {"budget-xp"}

# Patches of the 537 x 731 art (x0, y0, x1, y1; y down).
CABINET_PX = (395, 150, 425, 240)  # plain grey: right panel above the keypad
FRAME_PX = (30, 300, 44, 500)  # dark window frame
BANNER_PX = (30, 8, 508, 112)  # banner art inside its frame
DECOR_W = 100  # outer decoration at each end of the banner, either side of the logo

GLASS_GLOW = 0.5

# The front art's plain panel (125, 124, 117) is much lighter than the 2D sprites' cabinet
# (generic machine side ~71, 68, 69), and reads lighter still once lit in game. Scaled to match.
CABINET_TONE = 0.56
# Back panel colours, after the 2D sprites' condenser (~44, 42, 42).
BACK_PANEL = (0.17, 0.165, 0.165, 1)
COIL = (0.05, 0.05, 0.05, 1)
COIL_EDGE = (0.30, 0.30, 0.30, 1)
SLAT = (0.09, 0.09, 0.09, 1)


# Images as numpy arrays: (height, width, 4) floats, row 0 at the top.

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


def resize(arr, w, h):
    img = bpy.data.images.new("tmp", arr.shape[1], arr.shape[0], alpha=True)
    img.pixels.foreach_set(np.flipud(arr).ravel())
    img.scale(w, h)
    px = np.empty(w * h * 4, np.float32)
    img.pixels.foreach_get(px)
    bpy.data.images.remove(img)
    return np.flipud(px.reshape(h, w, 4)).copy()


def crop(arr, rect):
    x0, y0, x1, y1 = rect
    return arr[y0:y1, x0:x1]


def cover(arr, w, h):
    """Scales to fill w x h, cropping the overflow evenly (like CSS background-size: cover)."""
    ah, aw = arr.shape[:2]
    if aw / ah > w / h:
        cw = max(1, round(ah * w / h))
        arr = arr[:, (aw - cw) // 2:(aw - cw) // 2 + cw]
    else:
        ch = max(1, round(aw * h / w))
        arr = arr[(ah - ch) // 2:(ah - ch) // 2 + ch]
    return resize(arr, w, h)


def paste(dst, src, rect):
    x0, y0, x1, y1 = rect
    dst[y0:y1, x0:x1] = resize(src, x1 - x0, y1 - y0)


def fill(dst, rect, value):
    x0, y0, x1, y1 = rect
    dst[y0:y1, x0:x1] = value


def outline(dst, rect, colour, t=2):
    x0, y0, x1, y1 = rect
    dst[y0:y0 + t, x0:x1] = colour
    dst[y1 - t:y1, x0:x1] = colour
    dst[y0:y1, x0:x0 + t] = colour
    dst[y0:y1, x1 - t:x1] = colour


def back_panel(tex):
    """The machine's back: an inset condenser panel with a serpentine coil and vent
    slats, drawn into BACK in the cabinet colour already there."""
    x0, y0, x1, y1 = L.BACK
    w, h = x1 - x0, y1 - y0
    # Header band at the top (rows 0..118 of the 731-tall front, as a share of the height)
    # and plinth at the bottom, left as cabinet.
    top = y0 + round(h * 118 / 731) + 6
    bottom = y1 - round(h * 0.04 / 1.88) - 6
    left, right = x0 + 10, x1 - 10
    fill(tex, (left, top, right, bottom), BACK_PANEL)
    outline(tex, (left, top, right, bottom), COIL_EDGE, 1)

    # Vent slats along the bottom fifth.
    slats_top = bottom - (bottom - top) // 5
    for y in range(slats_top, bottom - 3, 5):
        fill(tex, (left + 6, y, right - 6, y + 2), SLAT)

    # Serpentine coil above them: vertical runs joined alternately top and bottom.
    runs = 6
    cy0, cy1 = top + 10, slats_top - 8
    xs = [round(left + 12 + i * (right - left - 24) / (runs - 1)) for i in range(runs)]
    t = 3
    for i, x in enumerate(xs):
        fill(tex, (x - t, cy0, x + t, cy1), COIL_EDGE)
        fill(tex, (x - t + 1, cy0 + 1, x + t - 1, cy1 - 1), COIL)
    for i in range(runs - 1):
        y = cy0 if i % 2 == 0 else cy1 - 2 * t
        fill(tex, (xs[i] - t, y, xs[i + 1] + t, y + 2 * t), COIL_EDGE)
        fill(tex, (xs[i] - t + 1, y + 1, xs[i + 1] + t - 1, y + 2 * t - 1), COIL)


def starter_mask(tex):
    """Black everywhere, then the starter glow areas."""
    fill(tex, L.MASK, (0, 0, 0, 1))
    fill(tex, L.mask_rect(L.BANNER), (1, 1, 1, 1))
    fill(tex, L.mask_rect(L.GLASS), (GLASS_GLOW, GLASS_GLOW, GLASS_GLOW, 1))
    for side in (L.LEFT, L.RIGHT):
        fill(tex, L.mask_rect(L.side_panel(side)), (1, 1, 1, 1))


def convert(src_path, out_path):
    save(build(load(src_path)), out_path)


def build(art):
    tex = np.zeros((L.TEX, L.TEX, 4), np.float32)
    tex[..., 3] = 1

    cabinet = crop(art, CABINET_PX).copy()
    cabinet[..., :3] *= CABINET_TONE
    # The whole texture first, so the gaps between regions are cabinet too and nothing dark
    # bleeds into a region edge when the texture is filtered. The mask goes over its block last.
    paste(tex, cabinet, (0, 0, L.TEX, L.TEX))
    for region in (L.LEFT, L.RIGHT, L.BACK, L.TOP):
        paste(tex, cabinet, region)
    paste(tex, crop(art, FRAME_PX), L.TRIM)
    back_panel(tex)
    # The front: the shared cabinet, then this shop's banner over its header. The art is
    # scaled to the front first so its banner lands in the same rows it always has.
    paste(tex, load(FRONT_BASE), L.FRONT)
    banner_rows = L.BANNER[3]
    front_art = resize(art, L.FRONT[2] - L.FRONT[0], L.FRONT[3] - L.FRONT[1])
    tex[L.FRONT[1]:L.FRONT[1] + banner_rows, L.FRONT[0]:L.FRONT[2]] = front_art[:banner_rows]

    # Side panels: the banner's outer decoration, the left end on the left side and the right
    # end on the right, so each side continues the banner it sits under.
    banner = crop(art, BANNER_PX)
    ends = {L.LEFT: banner[:, :DECOR_W], L.RIGHT: banner[:, -DECOR_W:]}
    for side, decor in ends.items():
        x0, y0, x1, y1 = L.side_panel(side)
        tex[y0:y1, x0:x1] = cover(decor, x1 - x0, y1 - y0)
        outline(tex, (x0, y0, x1, y1), tex[y0 - 4, x0 - 4], 3)

    starter_mask(tex)
    return tex


def overlay():
    """A finished machine with the ad spaces cut out: the banner inside its frame and both side
    panels inside their trim are fully transparent. Put it as the top layer in an image editor,
    paint the shop's own art on a layer beneath, and export the two flattened: that is a
    texture, glow mask and all."""
    tex = build(load(OVERLAY_SOURCE))
    fx, fy = L.FRONT[0], L.FRONT[1]
    x0, y0, x1, y1 = L.BANNER_ART
    holes = [(fx + x0, fy + y0, fx + x1, fy + y1)]
    for side in (L.LEFT, L.RIGHT):
        x0, y0, x1, y1 = L.side_panel(side)
        holes.append((x0 + 3, y0 + 3, x1 - 3, y1 - 3))
    for rect in holes:
        fill(tex, rect, (0, 0, 0, 0))
    save(tex, OVERLAY)
    print("wrote", OVERLAY)
    for rect in holes:
        print("  transparent", rect)


def template():
    tex = np.zeros((L.TEX, L.TEX, 4), np.float32)
    tex[..., 3] = 1
    colours = {
        L.FRONT: (0.80, 0.55, 0.45, 1), L.LEFT: (0.45, 0.70, 0.50, 1), L.RIGHT: (0.45, 0.55, 0.80, 1),
        L.BACK: (0.70, 0.70, 0.45, 1), L.TOP: (0.65, 0.45, 0.70, 1), L.TRIM: (0.30, 0.30, 0.30, 1),
    }
    for region, colour in colours.items():
        fill(tex, region, colour)
        outline(tex, region, (1, 1, 1, 1))
    for rect in (L.BANNER, L.GLASS, L.side_panel(L.LEFT), L.side_panel(L.RIGHT)):
        outline(tex, rect, (1, 1, 0, 1), 3)
    starter_mask(tex)
    for region in colours:
        outline(tex, L.mask_rect(region), (0.35, 0.35, 0.35, 1), 1)
    save(tex, TEMPLATE)


def refresh_masks(names):
    for name in names:
        path = os.path.join(OUT_DIR, name + ".png")
        tex = load(path)
        starter_mask(tex)
        save(tex, path)
        print("mask refreshed", path)


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    if args[:1] == ["--overlay"]:
        overlay()
        return
    if args[:1] == ["--mask-only"]:
        refresh_masks(args[1:])
        return
    if args[:1] == ["--convert"] and len(args) == 3:
        os.makedirs(os.path.dirname(os.path.abspath(args[2])), exist_ok=True)
        convert(os.path.abspath(args[1]), os.path.abspath(args[2]))
        print("wrote", args[2])
        return
    os.makedirs(OUT_DIR, exist_ok=True)
    for src in sorted(glob.glob(os.path.join(TEXTURES, "machine-*.png"))):
        name = os.path.basename(src)[len("machine-"):]
        if name[:-len(".png")] in HAND_PAINTED:
            print("skipped", name, "(hand painted)")
            continue
        out = os.path.join(OUT_DIR, name)
        convert(src, out)
        print("wrote", out)
    template()
    print("wrote", TEMPLATE)
    overlay()


main()
