"""
Builds the 3D vending machine mesh that client looks.lua dresses every machine in.

Every machine shares this one mesh; only the texture changes. The shape follows the cabinet
layout of the shop art: the header, the recessed window and the pickup tray sit exactly where
the art paints them. UVs follow the wrap layout in vending_layout.py, which
make_wrap_textures.py fills, and each surface is projected straight on, so it can be painted
as one flat picture.

Run headless from the repo root:
    "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
        --python Tools/blender/make_vending_mesh.py

Writes:
    Contents/mods/PhunMart2/common/media/models_X/PhunMart/Vending.fbx  (shipped)
    Tools/blender/vending.blend                                         (for editing by hand)

Units: 1 Blender metre = 1 PZ tile. Origin sits on the floor at the tile centre, matching
vanilla's appliances_laundry_P1_00.fbx. The front faces -Y in Blender.
"""

import os
import sys
import bpy
import bmesh
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vending_layout as L  # noqa: E402

# Box size in tiles, measured off the 2D sprites (Tiles/2x/phunmart_01.png): the faces span
# 59 and 40 px at 64 px per tile, and the front edge is ~147 px tall. The engine draws a storey
# (192 px at 2x) as 2.449 model units, so 147 px is ~1.88 units. The front art ends up
# stretched taller than its 537 x 731 source, the same way the 2D sprite stretches it.
WIDTH = 0.92
DEPTH = 0.62
HEIGHT = 1.88

# Features of the front, in pixels of the texture's FRONT region (y down from the top). Kept
# in vending_layout.py so the mesh, the textures and the glow mask agree.
ART_W, ART_H = L.FRONT[2] - L.FRONT[0], L.FRONT[3] - L.FRONT[1]
BANNER_BOTTOM_PX = L.BANNER[3]  # header box
GLASS_PX = L.GLASS  # x0, y0, x1, y1: recessed window
TRAY_PX = L.TRAY  # recessed pickup tray

HEADER_PROTRUDE = 0.025  # header sticks out past the body front
GLASS_DEPTH = 0.03
TRAY_DEPTH = 0.06
PLINTH_HEIGHT = 0.04
PLINTH_INSET = 0.03  # kick plate set back from the body on every side
BEVEL = 0.012  # chamfer on the vertical corners and the header's top edges

PREVIEW_TEXTURE = os.path.join("phunmart", "good-phoods.png")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
MEDIA = os.path.join(ROOT, "Contents", "mods", "PhunMart2", "common", "media")
FBX_OUT = os.path.join(MEDIA, "models_X", "PhunMart", "Vending.fbx")
BLEND_OUT = os.path.join(HERE, "vending.blend")


W2, D2 = WIDTH / 2, DEPTH / 2
Z_BANNER = HEIGHT * (1 - BANNER_BOTTOM_PX / ART_H)


def px_x(px):
    return -W2 + px / ART_W * WIDTH


def px_z(py):
    return HEIGHT - py / ART_H * HEIGHT


class Block:
    """One welded piece of the mesh. Verts are shared by position so bevels see clean edges."""

    def __init__(self, bm):
        self.bm = bm
        self.verts = {}
        self.faces = []

    def vert(self, p):
        key = tuple(round(c, 6) for c in p)
        if key not in self.verts:
            self.verts[key] = self.bm.verts.new(key)
        return self.verts[key]

    def quad(self, pts, normal):
        """Adds a face from corner points, wound so it faces along `normal`."""
        a, b, c = (Vector(p) for p in pts[:3])
        if (b - a).cross(c - a).dot(Vector(normal)) < 0:
            pts = list(reversed(pts))
        f = self.bm.faces.new([self.vert(p) for p in pts])
        self.faces.append(f)
        return f

    def bevel(self, edge_test):
        edges = [e for f in self.faces for e in f.edges if edge_test(e)]
        edges = list(set(edges))
        bmesh.ops.bevel(self.bm, geom=edges, offset=BEVEL, segments=1, affect="EDGES", profile=0.5,
                        clamp_overlap=True)


def build_body(bm):
    """Cabinet between plinth and header: front with the window and tray cut in as recesses."""
    blk = Block(bm)
    z0, z1 = PLINTH_HEIGHT, Z_BANNER
    py0, py1 = BANNER_BOTTOM_PX, ART_H * (1 - PLINTH_HEIGHT / HEIGHT)
    holes = [(GLASS_PX, GLASS_DEPTH), (TRAY_PX, TRAY_DEPTH)]

    # Front as a grid split at every hole edge, skipping the cells inside a hole.
    xs = sorted({0, ART_W} | {h[0][0] for h in holes} | {h[0][2] for h in holes})
    ys = sorted({py0, py1} | {h[0][1] for h in holes} | {h[0][3] for h in holes})
    for x0, x1 in zip(xs, xs[1:]):
        for y0, y1 in zip(ys, ys[1:]):
            if any(r[0] <= x0 and x1 <= r[2] and r[1] <= y0 and y1 <= r[3] for r, _ in holes):
                continue
            blk.quad([(px_x(x0), -D2, px_z(y1)), (px_x(x1), -D2, px_z(y1)),
                      (px_x(x1), -D2, px_z(y0)), (px_x(x0), -D2, px_z(y0))], (0, -1, 0))

    # Each hole: four walls facing into it and a back face set in by its depth.
    for (hx0, hy0, hx1, hy1), depth in holes:
        xa, xb, za, zb = px_x(hx0), px_x(hx1), px_z(hy1), px_z(hy0)
        yb = -D2 + depth
        blk.quad([(xa, -D2, za), (xa, yb, za), (xa, yb, zb), (xa, -D2, zb)], (1, 0, 0))
        blk.quad([(xb, -D2, za), (xb, yb, za), (xb, yb, zb), (xb, -D2, zb)], (-1, 0, 0))
        blk.quad([(xa, -D2, zb), (xb, -D2, zb), (xb, yb, zb), (xa, yb, zb)], (0, 0, -1))
        blk.quad([(xa, -D2, za), (xb, -D2, za), (xb, yb, za), (xa, yb, za)], (0, 0, 1))
        blk.quad([(xa, yb, za), (xb, yb, za), (xb, yb, zb), (xa, yb, zb)], (0, -1, 0))

    # Sides and back split at the same heights as the front, so the corner edges weld.
    zs = sorted({px_z(y) for y in ys})
    for za, zb in zip(zs, zs[1:]):
        blk.quad([(-W2, -D2, za), (-W2, D2, za), (-W2, D2, zb), (-W2, -D2, zb)], (-1, 0, 0))
        blk.quad([(W2, -D2, za), (W2, D2, za), (W2, D2, zb), (W2, -D2, zb)], (1, 0, 0))
        blk.quad([(-W2, D2, za), (W2, D2, za), (W2, D2, zb), (-W2, D2, zb)], (0, 1, 0))

    blk.bevel(lambda e: all(abs(abs(v.co.x) - W2) < 1e-5 and abs(abs(v.co.y) - D2) < 1e-5 for v in e.verts))


def build_header(bm):
    """Banner header: full depth, sticking out past the body front, top edges chamfered."""
    blk = Block(bm)
    za, zb = Z_BANNER, HEIGHT
    yf = -D2 - HEADER_PROTRUDE
    blk.quad([(-W2, yf, za), (W2, yf, za), (W2, yf, zb), (-W2, yf, zb)], (0, -1, 0))
    blk.quad([(-W2, D2, za), (W2, D2, za), (W2, D2, zb), (-W2, D2, zb)], (0, 1, 0))
    # Top split where the overhang meets the body, so its rim welds to the split sides.
    blk.quad([(-W2, yf, zb), (W2, yf, zb), (W2, -D2, zb), (-W2, -D2, zb)], (0, 0, 1))
    blk.quad([(-W2, -D2, zb), (W2, -D2, zb), (W2, D2, zb), (-W2, D2, zb)], (0, 0, 1))
    # The underside only shows where it overhangs the body.
    blk.quad([(-W2, yf, za), (W2, yf, za), (W2, -D2, za), (-W2, -D2, za)], (0, 0, -1))
    for x, n in ((-W2, -1), (W2, 1)):
        # Split where the overhang meets the body, so the underside welds to the sides.
        blk.quad([(x, yf, za), (x, -D2, za), (x, -D2, zb), (x, yf, zb)], (n, 0, 0))
        blk.quad([(x, -D2, za), (x, D2, za), (x, D2, zb), (x, -D2, zb)], (n, 0, 0))

    def outer(e):
        a, b = e.verts
        vertical = abs(a.co.x - b.co.x) < 1e-5 and abs(a.co.y - b.co.y) < 1e-5
        if vertical:
            return abs(abs(a.co.x) - W2) < 1e-5 and (abs(a.co.y - yf) < 1e-5 or abs(a.co.y - D2) < 1e-5)
        top = abs(a.co.z - HEIGHT) < 1e-5 and abs(b.co.z - HEIGHT) < 1e-5
        on_rim = lambda v: abs(abs(v.co.x) - W2) < 1e-5 or abs(v.co.y - yf) < 1e-5 or abs(v.co.y - D2) < 1e-5
        return top and on_rim(a) and on_rim(b) and not (abs(a.co.y - (-D2)) < 1e-5 and abs(b.co.y - (-D2)) < 1e-5)

    blk.bevel(outer)


def build_plinth(bm):
    """Kick plate, set back on every side so the machine does not look glued to the floor."""
    blk = Block(bm)
    w, d = W2 - PLINTH_INSET, D2 - PLINTH_INSET
    blk.quad([(-w, -d, 0), (w, -d, 0), (w, -d, PLINTH_HEIGHT), (-w, -d, PLINTH_HEIGHT)], (0, -1, 0))
    blk.quad([(-w, d, 0), (w, d, 0), (w, d, PLINTH_HEIGHT), (-w, d, PLINTH_HEIGHT)], (0, 1, 0))
    blk.quad([(-w, -d, 0), (-w, d, 0), (-w, d, PLINTH_HEIGHT), (-w, -d, PLINTH_HEIGHT)], (-1, 0, 0))
    blk.quad([(w, -d, 0), (w, d, 0), (w, d, PLINTH_HEIGHT), (w, -d, PLINTH_HEIGHT)], (1, 0, 0))


# Whole-machine extents per axis, so every surface maps by its position on the machine and a
# surface split into strips (to weld the corners) still reads as one continuous picture.
X0, X1 = -W2, W2
Y0, Y1 = -D2 - HEADER_PROTRUDE, D2
DEPTH_ALL = Y1 - Y0


def project(face, uv, region, st):
    for loop in face.loops:
        loop[uv].uv = L.to_uv(region, *st(loop.vert.co))


def in_recess(face):
    c = face.calc_center_median()
    return -D2 + 1e-4 < c.y < -D2 + TRAY_DEPTH + 1e-4 and abs(c.x) < W2 - 0.03 and c.z > PLINTH_HEIGHT


def assign_uvs(bm):
    uv = bm.loops.layers.uv.new("UVMap")
    bm.normal_update()
    down = lambda co: (HEIGHT - co.z) / HEIGHT  # noqa: E731
    for face in bm.faces:
        n = face.normal
        if n.y < -0.9:
            # Anything facing forward is the front picture, recess backs included.
            project(face, uv, L.FRONT, lambda co: ((co.x - X0) / WIDTH, down(co)))
        elif in_recess(face) or n.z < -0.7:
            # Recess walls and the header underside: plain trim, spread by position.
            ax = max(range(3), key=lambda i: abs(n[i]))
            a, b = [i for i in range(3) if i != ax]
            ext = ((X0, X1), (Y0, Y1), (0.0, HEIGHT))
            project(face, uv, L.TRIM, lambda co: ((co[a] - ext[a][0]) / (ext[a][1] - ext[a][0]),
                                                  (co[b] - ext[b][0]) / (ext[b][1] - ext[b][0])))
        elif n.z > 0.7:
            project(face, uv, L.TOP, lambda co: ((co.x - X0) / WIDTH, (Y1 - co.y) / DEPTH_ALL))
        elif abs(n.x) >= abs(n.y):
            if n.x < 0:
                project(face, uv, L.LEFT, lambda co: ((Y1 - co.y) / DEPTH_ALL, down(co)))
            else:
                project(face, uv, L.RIGHT, lambda co: ((co.y - Y0) / DEPTH_ALL, down(co)))
        elif n.y > 0:
            project(face, uv, L.BACK, lambda co: ((X1 - co.x) / WIDTH, down(co)))
        else:
            # Front-corner chamfers lean more forward than sideways: use the front picture.
            project(face, uv, L.FRONT, lambda co: ((co.x - X0) / WIDTH, down(co)))


def build_mesh():
    bm = bmesh.new()
    build_plinth(bm)
    build_body(bm)
    build_header(bm)
    bm.normal_update()
    assign_uvs(bm)

    mesh = bpy.data.meshes.new("Vending")
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new("Vending", mesh)
    bpy.context.scene.collection.objects.link(obj)
    return obj


def add_preview_material(obj):
    mat = bpy.data.materials.new("Vending")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(os.path.join(MEDIA, "textures", PREVIEW_TEXTURE))
    mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    obj.data.materials.append(mat)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    obj = build_mesh()
    add_preview_material(obj)

    os.makedirs(os.path.dirname(FBX_OUT), exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    # Default axes (-Z forward, Y up) match vanilla's laundry FBX. FBX_SCALE_UNITS puts the
    # cm conversion in the file's UnitScaleFactor (100) like vanilla does; the default bakes a
    # x100 scale onto the object node instead, which Blender undoes on import but PZ does not.
    bpy.ops.export_scene.fbx(
        filepath=FBX_OUT,
        use_selection=True,
        object_types={"MESH"},
        apply_scale_options="FBX_SCALE_UNITS",
        # Bake the Z-up to Y-up turn into the vertices so the node carries no rotation.
        bake_space_transform=True,
        path_mode="STRIP",
        bake_anim=False,
    )
    bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
    print("wrote", FBX_OUT)
    print("wrote", BLEND_OUT)


main()
