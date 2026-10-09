"""
Renders PhunMart's 2D tile sheets from the 3D machine, so the tiles match the textures.

Every machine is the same mesh (vending.blend, built by make_vending_mesh.py) wearing its
shop's wrap texture, so a sheet cell is just that mesh, turned to face one way, seen from the
game's isometric camera. The sheets keep the layout TileZed already knows: 8 x 8 cells of
128 x 256 (2x tiles), one machine per row, E S W N then the four unpowered cells. Nothing reads
the unpowered cells any more, but placed machines in old saves may still stand on them, so
they get a copy of the powered face rather than being left empty.

Run headless from the repo root:
    "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
        --python Tools/blender/render_sprites.py [-- phunmart_01 ...]

Writes Tools/blender/sprites/phunmart_0N.png. To ship them: copy into the TileZed 2x folder
(d:/pz-dev/Tiles/Tiles/2x), repack phunmart.pack, and copy the .pack and .tiles into the mod.

Another mod's sheet: pass --custom, the output path, then one texture path per row:
    ... --python Tools/blender/render_sprites.py -- --custom out/phleamarket_01.png 
        ../PhleaMarket/Contents/mods/PhleaMarket/common/media/textures/phunmart/phleamarket.png

Camera: the game draws a tile's floor as a 128 x 64 diamond at 2x and a storey (2.449 model
units) as 192 px. That is a true orthographic view at 30 degrees down and 45 degrees round,
at 90.5 px per unit (64 px across per unit of x, 0.866 * 90.5 = 78.4 px per unit of height).
The tile's floor centre sits 32 px above the cell's bottom edge.
"""

import math
import os
import shutil
import sys
import tempfile

import bpy
import numpy as np
from mathutils import Vector

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
MEDIA = os.path.join(ROOT, "Contents", "mods", "PhunMart2", "common", "media")
TEXTURES = os.path.join(MEDIA, "textures", "phunmart")
BLEND = os.path.join(HERE, "vending.blend")
OUT = os.path.join(HERE, "sprites")

# One texture per row, top to bottom. Must match the tiles each shop names in
# defaults/shops.lua and the tables in Docs/MACHINE_ART.md.
ROWS = 8  # sheets are always 8 x 8, whatever number of rows hold machines
SHEETS = {
    "phunmart_01": ["none", "good-phoods", "phat-phoods", "pity-the-tool",
                    "final-amendment", "wrent-a-wreck", "michelles", "car-a-part"],
    "phunmart_02": ["traiter-joes", "csv", "electronics", "phish4u",
                    "hoes", "budget-xp", "gifted-xp", "luxury-xp"],
    "phunmart_03": ["hard-wear", "collectors", "travellers", "sheds-and-commoners",
                    "prawn-stars", "zetsy", "lootgoblin", "necromart"],
}

CELL_W, CELL_H = 128, 256
COLS = 8
PX_PER_UNIT = 64 / math.cos(math.radians(45))  # 90.51
FLOOR_FROM_BOTTOM = 32  # px from the cell's bottom edge to the tile's floor centre

# The mesh's front faces -Y. The camera sits at +X -Y, so -Y is the lower-left face (south)
# and +X the lower-right face (east). Column order is E S W N.
FACINGS = [("E", 90), ("S", 0), ("W", -90), ("N", 180)]

GLOW = 0.6  # emission strength where the mask is white: the powered look


def args():
    argv = sys.argv
    return argv[argv.index("--") + 1:] if "--" in argv else []


def load_machine():
    with bpy.data.libraries.load(BLEND, link=False) as (src, dst):
        dst.objects = [n for n in src.objects if n == "Vending"]
    obj = dst.objects[0]
    bpy.context.scene.collection.objects.link(obj)
    obj.location = (0, 0, 0)
    return obj


def make_material(obj):
    """Texture colour, plus emission through the glow mask in the bottom-right block."""
    mat = bpy.data.materials.new("Sprite")
    mat.use_nodes = True
    nt = mat.node_tree
    nodes, links = nt.nodes, nt.links
    bsdf = nodes.get("Principled BSDF")
    bsdf.inputs["Roughness"].default_value = 0.8
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.2

    uv = nodes.new("ShaderNodeUVMap")
    colour = nodes.new("ShaderNodeTexImage")
    colour.interpolation = "Linear"
    links.new(uv.outputs["UV"], colour.inputs["Vector"])

    # Mask UV = (0.5 + u / 2, v / 2): the whole texture again at half size, bottom right.
    mapping = nodes.new("ShaderNodeMapping")
    mapping.inputs["Location"].default_value = (0.5, 0.0, 0.0)
    mapping.inputs["Scale"].default_value = (0.5, 0.5, 1.0)
    links.new(uv.outputs["UV"], mapping.inputs["Vector"])
    mask = nodes.new("ShaderNodeTexImage")
    mask.interpolation = "Linear"
    links.new(mapping.outputs["Vector"], mask.inputs["Vector"])

    strength = nodes.new("ShaderNodeMath")
    strength.operation = "MULTIPLY"
    strength.inputs[1].default_value = GLOW
    links.new(mask.outputs["Color"], strength.inputs[0])

    links.new(colour.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(colour.outputs["Color"], bsdf.inputs["Emission Color"])
    links.new(strength.outputs["Value"], bsdf.inputs["Emission Strength"])

    obj.data.materials.clear()
    obj.data.materials.append(mat)
    return colour, mask


def setup_scene():
    scene = bpy.context.scene
    engines = {e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    scene.render.engine = "BLENDER_EEVEE" if "BLENDER_EEVEE" in engines else "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = CELL_W
    scene.render.resolution_y = CELL_H
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.filter_size = 1.0
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"

    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (1, 1, 1, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.55
    scene.world = world

    # Key light from the upper left of the screen, so the south face reads lighter than east.
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 2.2
    sun.rotation_euler = (math.radians(50), 0, math.radians(-100))
    scene.collection.objects.link(sun)

    cam_data = bpy.data.cameras.new("Iso")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = CELL_H / PX_PER_UNIT  # the taller side sets the scale
    cam = bpy.data.objects.new("Iso", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam

    # Look down 30 degrees towards -X +Y, from far enough out to clear the machine.
    cam.rotation_euler = (math.radians(60), 0, math.radians(45))
    bpy.context.view_layer.update()
    rot = cam.matrix_world.to_3x3()
    forward = rot @ Vector((0, 0, -1))
    up = rot @ Vector((0, 1, 0))
    # Put the floor centre FLOOR_FROM_BOTTOM px above the bottom edge: the view centre is
    # CELL_H / 2 px up from the bottom, so shift the camera up the screen by the difference.
    shift_px = CELL_H / 2 - FLOOR_FROM_BOTTOM
    cam.location = -forward * 20 + up * (shift_px / PX_PER_UNIT)
    return scene


def render_cell(scene, obj, angle, path):
    obj.rotation_euler = (0, 0, math.radians(angle))
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)


def read_png(path):
    img = bpy.data.images.load(path)
    px = np.array(img.pixels[:], dtype=np.float32).reshape(img.size[1], img.size[0], 4)
    bpy.data.images.remove(img)
    return px  # rows bottom-up, as Blender stores them


def write_png(path, px):
    h, w = px.shape[:2]
    img = bpy.data.images.new("sheet", w, h, alpha=True)
    img.alpha_mode = "STRAIGHT"
    img.pixels[:] = px.ravel()
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def jobs():
    """(output path, [texture paths, one per row]) for each sheet to render."""
    argv = args()
    if argv[:1] == ["--custom"]:
        return [(os.path.abspath(argv[1]), [os.path.abspath(p) for p in argv[2:]])]
    return [(os.path.join(OUT, sheet + ".png"),
             [os.path.join(TEXTURES, name + ".png") for name in SHEETS[sheet]])
            for sheet in (argv or list(SHEETS))]


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = setup_scene()
    obj = load_machine()
    colour_node, mask_node = make_material(obj)
    scratch = tempfile.mkdtemp(prefix="phunmart_cells_")

    for out, rows in jobs():
        px = np.zeros((CELL_H * ROWS, CELL_W * COLS, 4), dtype=np.float32)
        for row, path in enumerate(rows):
            name = os.path.splitext(os.path.basename(path))[0]
            image = bpy.data.images.load(path)
            colour_node.image = image
            mask_node.image = image
            for col, (facing, angle) in enumerate(FACINGS):
                cell_path = os.path.join(scratch, "%s_%s.png" % (name, facing))
                render_cell(scene, obj, angle, cell_path)
                cell = read_png(cell_path)
                # Sheet rows run top-down; Blender's pixel rows run bottom-up.
                y0 = (ROWS - 1 - row) * CELL_H
                for c in (col, col + 4):  # powered, and its copy in the unpowered slot
                    px[y0:y0 + CELL_H, c * CELL_W:(c + 1) * CELL_W] = cell
            bpy.data.images.remove(image)
            print("rendered", row, name)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        write_png(out, px)
        print("wrote", out)
    shutil.rmtree(scratch, ignore_errors=True)


main()
