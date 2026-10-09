"""
Texture layout shared by make_vending_mesh.py (UVs) and make_wrap_textures.py (images).
client looks.lua (FRONT, for the shop window) and the shaders (MASK_*) repeat a few of these
numbers; change them together.

A machine texture is 1024 x 1024, in two parts:
    colour  everything outside the bottom-right 512 x 512 block, laid out below
    mask    the bottom-right 512 x 512 block: the WHOLE texture again at half size, as the
            glow mask (white = lit when powered, black = not, grey = partly). A texel at (x, y)
            is masked by the mask texel at (MASK_ORIGIN + x * MASK_SCALE, MASK_ORIGIN + y * MASK_SCALE).
Keep it a power of two: the engine pads other sizes and the shaders assume it does not.

Regions are in image pixels, x right and y DOWN from the image top. Each surface is painted as
if looking straight at it from outside, upright:
    FRONT  front of the machine, banner at the top. Also the shop window's background, so it
           gets the resolution: 512 x 1024
    LEFT   left side (seen from the machine's left): back edge on the left, front on the right
    RIGHT  right side: front edge on the left, back on the right
    TOP    seen from above, back edge at the top, front at the bottom
    TRIM   plain dark finish for the recess walls and the header underside
    BACK   back, seen from behind; small, it is nearly always against a wall
"""

TEX = 1024

FRONT = (0, 0, 512, 1024)
LEFT = (512, 0, 688, 512)
RIGHT = (688, 0, 864, 512)
TOP = (864, 0, 1024, 112)
TRIM = (864, 120, 1024, 248)
BACK = (864, 256, 1024, 512)

MASK_ORIGIN = 512
MASK_SCALE = 0.5
MASK = (MASK_ORIGIN, MASK_ORIGIN, TEX, TEX)

# The front's features, in FRONT pixels. They follow the cabinet in front_base.png, painted for
# the 3D machine's proportions (512 x 1024 = 0.49 x 1 of the machine). make_vending_mesh.py
# cuts the recesses here, and the starter glow mask lights BANNER and GLASS.
BANNER = (0, 0, 512, 166)  # header box: the shop's banner
# The banner art inside its silver frame, where shops differ: measured by comparing the shipped
# textures, since the shop art's frame lands a few pixels off any simple scaling of it.
BANNER_ART = (27, 9, 484, 163)
GLASS = (47, 209, 392, 729)  # recessed window
TRAY = (27, 771, 404, 863)  # recessed pickup tray
# Below the tray (rows 881 on) is a kick panel with a vent grille; paint_kick_panel.py draws it.
# Side panels: the full height of the side, from the top of the header down to the plinth (the
# side region's bottom 11 px are the plinth), inset by this margin all round.
SIDE_PANEL_MARGIN = 14
SIDE_PANEL_TOP = SIDE_PANEL_MARGIN
SIDE_PANEL_BOTTOM = 501 - SIDE_PANEL_MARGIN


def side_panel(region):
    x0, y0, x1, y1 = region
    return (x0 + SIDE_PANEL_MARGIN, SIDE_PANEL_TOP, x1 - SIDE_PANEL_MARGIN, SIDE_PANEL_BOTTOM)


def mask_rect(rect):
    """Where a rectangle of the colour layout sits in the mask block."""
    return tuple(round(MASK_ORIGIN + v * MASK_SCALE) for v in rect)


# UVs stop half a texel inside each region. Filtering reads half a texel either side of a
# face's edge, and FRONT's right edge touches the mask block: mapped to the edge itself, the
# banner's white mask would bleed into the machine as a pale line.
INSET = 0.5


def to_uv(region, s, t):
    """Blender UV for a point at (s, t) in 0..1 across a region, t = 0 at the region's top."""
    x0, y0, x1, y1 = region
    x0, y0, x1, y1 = x0 + INSET, y0 + INSET, x1 - INSET, y1 - INSET
    return ((x0 + s * (x1 - x0)) / TEX, 1.0 - (y0 + t * (y1 - y0)) / TEX)
