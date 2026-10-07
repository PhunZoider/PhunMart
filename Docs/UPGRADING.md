# PhunMart: Upgrading

This page is for anyone updating PhunMart on a server they have **customised**, or updating a
mod that **extends** PhunMart. If you run PhunMart as it ships, there is nothing to do:
subscribe, restart, done.

Changes are listed newest first. Each one says what changed, what PhunMart does about it for
you, and what, if anything, is left for you to do.

---

## Table of Contents

- [Quick check](#quick-check)
- [How the automatic upgrade works](#how-the-automatic-upgrade-works)
- [For server admins](#for-server-admins)
  - [Machines are 3D](#machines-are-3d)
  - [Playtime rewards count survived time](#playtime-rewards-count-survived-time)
  - [One setting for what death does to a balance](#one-setting-for-what-death-does-to-a-balance)
  - [Vehicles: the group is the class](#vehicles-the-group-is-the-class)
  - [Config files are JSON (B42.20.4)](#config-files-are-json-b42204)
  - [New settings that change nothing until you use them](#new-settings-that-change-nothing-until-you-use-them)
- [For mod authors](#for-mod-authors)
  - [A shop's look is its texture](#a-shops-look-is-its-texture)
  - [Tiles are optional](#tiles-are-optional)
  - [Ask the machine which shop it is](#ask-the-machine-which-shop-it-is)
  - [The shop window was relaid](#the-shop-window-was-relaid)
  - [The vehicle specials are gone](#the-vehicle-specials-are-gone)
- [If something goes wrong](#if-something-goes-wrong)

---

## Quick check

| If you...                                                      | Then                                                           |
| -------------------------------------------------------------- | -------------------------------------------------------------- |
| Have override files from before B42.20.4 (`PhunMart_*.txt`)    | Convert them once. [Details](#config-files-are-json-b42204)     |
| Turned off dropping wallets on death                           | Set it again under its new name. [Details](#one-setting-for-what-death-does-to-a-balance) |
| Have your own `PhunMart_TokenRewards.json`                     | Check its playtime numbers. [Details](#playtime-rewards-count-survived-time) |
| Gave a shop your own window image (`background`)               | Give it a 3D texture. [Details](#machines-are-3d)               |
| Changed the shipped car shops, or made vehicle groups          | Nothing. Converted for you. [Details](#vehicles-the-group-is-the-class) |
| Picked a shipped background in the editor or the wizard        | Nothing. Converted for you. [Details](#machines-are-3d)         |
| Ship a mod that adds a machine                                 | Swap `background` for `texture`. [Details](#for-mod-authors)    |
| Ship a mod that adds a shop window mode                        | Open your machine and look. [Details](#the-shop-window-was-relaid) |

---

## How the automatic upgrade works

Your override files are a thin layer of changes on top of PhunMart's defaults. Most updates to
those defaults need nothing from you: a pool you never touched just picks up the new version.

When an update makes an existing override *wrong* rather than merely old, PhunMart ships a
**migration** for it. On the first server start after updating:

1. PhunMart reads which version last wrote your override files.
2. Before changing anything, it saves every override file as it was into one backup,
   `PhunMart_Backup_v<old version>.json`, in the same folder. If it cannot write the backup, it
   stops and changes nothing.
3. It runs each migration newer than that version, in order, and rewrites only the files a
   migration actually changed.
4. It logs every change it made, one line each, in the server log under `[PhunMart]`.

Only override files are migrated. Player wallets, purchase history and machines in the world
are not touched by any of this.

The override files live here:

| Setup            | Folder                                             |
| ---------------- | -------------------------------------------------- |
| Single-player    | `%UserProfile%\Zomboid\Lua\`                       |
| Dedicated server | `%UserProfile%\Zomboid\Server\<server-name>\Lua\`  |

---

## For server admins

### Machines are 3D

Machines are now drawn as a 3D vending machine wearing each shop's **texture**, which also
supplies the shop window. Previously a shop had 2D tiles and a separate window image named by
`background`. The window was relaid to match the machine's proportions, and the old window
images no longer fit it.

**Done for you.** Any shop in `PhunMart_Shops.json` whose `background` is one of PhunMart's own
`machine-*.png` images is switched to the texture made from that image: `machine-zetsy.png`
becomes `"texture": "zetsy"`, and the `background` line is removed. If the shop already had a
`texture`, that one is kept. The log names every shop it changed.

**Left for you.** A `background` that names an image of your own is left alone, because you
chose it on purpose. That shop will:

- show your image as its window, stretched to the new shape, so the controls may not sit on the
  art;
- have no 3D model, since there is no texture to make one from, and show its 2D tiles instead.

To fix it, open the shop on the **Shops** tab and pick a **3D texture** (there are spare ones),
then clear **Background**. If you want to keep your own art, the
[Machine Art Reference](MACHINE_ART.md#making-a-texture) shows how to turn it into a texture.

**Also new:**

- A shop no longer needs tiles of its own. Leave **2D sprites** empty and it stands on the
  generic machine. See [Machine Art](MACHINE_ART.md#2d-tiles).
- Machines remember which shop they are, so they keep it when picked up and put down.
- To place a shop by hand, use **Spawn Shop** on the **Shops** tab. Shops you made yourself have
  no entry in the Items List, and this works for every shop.
- Players can turn the 3D models off for themselves under **Options > Mods > PhunMart**.

### Playtime rewards count survived time

Playtime milestones count **game** minutes survived, added up across a player's characters in
the save. They always have; the documentation used to say real minutes online, which was wrong.

The shipped schedule changed to match: one token each at about 5 and 30 real minutes, then 2,
5, 12 and 30 real hours, at the default one-hour day. The old schedule (10, 60, 300, 600 and 900
game minutes) handed out most of its tokens inside the first hour of play.

**Done for you.** Nothing needed if you never wrote your own `PhunMart_TokenRewards.json`.

**Left for you.** That file replaces the defaults whole rather than patching them, so if you
have one, you keep whatever schedule is in it, including the old one if you copied it from the
defaults. Read its `atMinutes` values as game minutes (24 per real minute at the default day
length) and adjust if they are not what you meant. The **Rewards** tab edits them in game.
See [Token Rewards](CUSTOMISATION.md#11-token-rewards).

### One setting for what death does to a balance

The sandbox option `DropOnDeath` (true or false) was replaced by `WalletOnDeath`, with three
choices: **Dropped** on the body, **Kept** by the player, or **Lost**.

**Left for you.** The game does not carry a value across a renamed option, so every server
starts on the default, **Dropped**. If you had `DropOnDeath` off, set `WalletOnDeath` to the
choice you meant: **Kept** or **Lost**. `ReturnRate` now applies only to **Dropped**.

### Vehicles: the group is the class

Vehicle groups now carry their own price, weight, stock and spawn condition, and list cars by
script name. The ten `vehicle_*` specials that used to hold those, the per-car vehicle entries
in `PhunMart_Items.json`, and the Vehicles tab are gone.

**Done for you.** A group or item override that named a removed `vehicle_*` special has that
special's price band written onto it, without overwriting any price or weight you set yourself.
An override that only patched one of those specials is dropped, since what it patched no
longer exists. One that carried its own actions is kept and moves to the Specials tab's Other
list.

**Left for you.** Nothing, but if a car shop looks thinner than it did, check the log for what
was ported. Adding a car is now one name in a group's list: see
[Adding Modded Vehicles](GUIDE_ADDING_MODDED_VEHICLE.md).

### Config files are JSON (B42.20.4)

Build 42.20.4 removed the game's ability to read Lua source at runtime, so the override files
moved from Lua tables in `PhunMart_*.txt` to `PhunMart_*.json`.

**Left for you.** This is the one change PhunMart cannot make for you. Your `.txt` files are
left exactly where they are, and the server log names each one that has no `.json` yet. Convert
them once with the [Phun configuration converter](https://phunzoider.github.io/PhunZones/converter/),
which runs in your browser and uploads nothing. Step by step:
[Converting your old config files](CUSTOMISATION.md#converting-your-old-config-files).

### New settings that change nothing until you use them

These arrived recently and default to how things already worked:

| Setting                       | Where              | What it does                                                    |
| ----------------------------- | ------------------ | --------------------------------------------------------------- |
| `ShopsMoveable`               | Sandbox            | Let players pick machines up and move them. Off by default.      |
| `ShopsDestructible`           | Sandbox            | Let players sledgehammer machines. Off by default.               |
| Players Can Move / Destroy    | Shop editor, Basics | The same, per shop, overriding the sandbox option.             |
| `ChangeDropMode`              | Sandbox            | Pay zombie change as loose coins (default), one Change item, or straight into the wallet. |
| Price ranges                  | Prices tab         | The editor now takes a min/max range for any price, items included, not just currency. The top of a range can now actually roll. |
| Currency name                 | Tools, Change the currency | Name an item currency for the shop window.              |

---

## For mod authors

If your mod adds a machine, a shop window mode or an admin tab, the
[extension guide](GUIDE_EXTENDING.md) describes how things work now. This section lists what
moved underneath existing mods. [Phlea Market](https://github.com/PhunZoider/PhleaMarket) has
been updated and is a working example of all of it.

### A shop's look is its texture

The shop field that decides how a machine looks is now `texture`, a 1024 x 1024 wrap texture in
`media/textures/phunmart/`. Its front is also the shop window.

```lua
-- Before
background = "machine-yourshop.png",

-- After
texture = "yourshop",   -- media/textures/phunmart/yourshop.png
```

Until you ship a texture, a shop naming `background = "machine-yourshop.png"` looks for
`phunmart/yourshop.png`, finds nothing, and falls back to its 2D tiles with the old image
stretched over the new window. The migration in
[Machines are 3D](#machines-are-3d) only rewrites admin override files, never a mod's defaults.

To make the texture from your existing window art:

```
blender -b --factory-startup --python Tools/blender/make_wrap_textures.py -- --convert machine-yourshop.png yourshop.png
```

`background` still exists, but now means an override image for the window, drawn over the
whole of it at 1 : 2. See [Machine Art](MACHINE_ART.md#the-shop-window).

If you ship textures that no shop of yours wears, register them so admins can pick them:

```lua
PhunMart.registerMachineTexture("yourshop-alt")
```

### Tiles are optional

`sprites` and `unpoweredSprites` are now only the 2D view, shown when a player turns 3D models
off, and are optional. Leave them out and your shop stands on PhunMart's generic machine.

If you drop your own tiles, you can also drop your tile pack, along with the `pack=` and
`tiledef=` lines in `mod.info`. Keep them if you would rather the 2D view still looked like
your machine.

### Ask the machine which shop it is

Machines now carry their shop on the object, and several shops can share the generic tiles,
so a machine's sprite no longer reliably says which shop it is. If your code looked
`Core.spriteToShop` up by sprite name, or read the tile's `CustomName`, call this instead:

```lua
local shopKey = PhunMart.shopKeyForObject(isoObject)
```

It reads what the machine carries, and falls back to the sprite for machines placed before
they carried it.

Shops sharing the generic tiles have no entry in `Core.spriteToShop` at all: a sprite is only
indexed when exactly one shop uses it.

To give a player a machine for a shop with no scripted item, build it on the server with
`PhunMart.newMachineItem("YourShop")` and add it to their inventory there.

### The shop window was relaid

The window is now the machine's front, at 1 : 2. The registration API did not change, and a
mode's filter strip still receives its `x, y, w, h` from `createFilter`, so a mode that
positions its widgets from those is unaffected. A mode that drew at fixed coordinates of its
own should be opened and checked: the glass, keypad and mode strip have all moved.

### The vehicle specials are gone

The ten `vehicle_*` specials were removed in the vehicle rework. A mod's `groups` or `items`
defaults that named one as a reward will lose those offers, and the compile log says so. Put
the price, weight and spawn settings on the group's `defaults` instead and list the cars by
script name. See [Vehicle groups](CUSTOMISATION.md#vehicle-groups).

---

## If something goes wrong

Every migration run leaves `PhunMart_Backup_v<old version>.json` beside your override files. It
holds every override file exactly as it was, keyed by file name. To undo a change, copy the
entry you want from the backup back into its file, then press **Reload definitions** on the
Tools tab or restart. The migration will not run again: it is recorded as done.

If a shop, pool or offer you defined is missing after an update, check the server log first.
When a reference does not resolve, PhunMart drops that one offer rather than failing, and says
why under `[PhunMart]`.

Still stuck? [Open an issue](https://github.com/PhunZoider/PhunMart/issues) or ask on
[Discord](https://discord.gg/v2USyAtP6q), with the `[PhunMart]` lines from your server log.
