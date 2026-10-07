// Generates the three PhunMart vending shaders from vending.frag.tpl.
//
//     node Tools/shaders/make_vending_shaders.js
//
// Each look gets <name>.frag from the template plus vanilla copies of basicEffect.vert and
// basicEffect_static.vert (the engine loads a .vert, a _static.vert and a .frag per shader name).
// Edit the template or the LOOKS below, never the generated files.

const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..", "..");
const OUT = path.join(ROOT, "Contents", "mods", "PhunMart2", "common", "media", "shaders");
const VANILLA = process.env.PZ_SHADERS || "D:/Steam/steamapps/common/ProjectZomboid/media/shaders";

const GLOW_BODY = `\t// Masked areas ignore the scene lighting. Tint still applies so the highlight shows.
\tcol = mix(lit, col * TintColour, mask * GLOW);`;

const LOOKS = [
    {
        name: "phunmartVending",
        look: "powered",
        consts: "// How much of the mask shows unlit.\nconst float GLOW = 1.0;",
        body: GLOW_BODY,
    },
    {
        name: "phunmartVendingSoft",
        look: "no-power-needed",
        consts: "// How much of the mask shows unlit: softer than powered, so the two can be told apart.\nconst float GLOW = 0.45;",
        body: GLOW_BODY,
    },
    {
        name: "phunmartVendingOff",
        look: "unpowered",
        consts: "// Masked areas (the parts that would light up) read as dead even in daylight.\nconst float DIM = 0.45;\nconst float GREY = 0.7;",
        body: "\tfloat lum = dot(lit, vec3(0.299, 0.587, 0.114));\n\tcol = mix(lit, vec3(lum), mask * GREY) * (1.0 - mask * DIM);",
    },
];

const tpl = fs.readFileSync(path.join(__dirname, "vending.frag.tpl"), "utf8").replace(/\r\n/g, "\n");
for (const l of LOOKS) {
    const frag = tpl.replace("__LOOK__", l.look).replace("__LOOK_CONSTS__", l.consts).replace("__LOOK_BODY__", l.body);
    fs.writeFileSync(path.join(OUT, l.name + ".frag"), frag.replace(/\n/g, "\r\n"));
    fs.copyFileSync(path.join(VANILLA, "basicEffect.vert"), path.join(OUT, l.name + ".vert"));
    fs.copyFileSync(path.join(VANILLA, "basicEffect_static.vert"), path.join(OUT, l.name + "_static.vert"));
    console.log("wrote", l.name);
}
