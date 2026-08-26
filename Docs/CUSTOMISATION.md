# PhunMart: Customisation Guide

PhunMart is fully data-driven. Everything about what shops sell, what things cost, what
conditions gate a purchase, and how tokens are earned is defined in plain Lua config files
that you can override without touching the mod itself.

Every one of those files has an editor behind it in game. Open the Admin Panel and click
`** PhunMart **`, or use the Debug Menu, and you get **PhunMart Setup**: one window with a
tab per config layer, plus a **Tools** tab for the actions that are not edits. Saving in
there writes the same override files this guide describes, so the two routes are
interchangeable and you can mix them freely.

---

## Table of Contents

1. [How the pieces fit together](#1-how-the-pieces-fit-together)
2. [Common admin tasks](#2-common-admin-tasks)
3. [How overrides work](#3-how-overrides-work)
4. [Prices](#4-prices)
5. [Specials](#5-specials)
6. [Conditions](#6-conditions)
7. [Items (Offers)](#7-items-offers)
8. [Groups](#8-groups)
9. [Pools](#9-pools)
10. [Shops](#10-shops)
11. [Token Rewards](#11-token-rewards)
12. [Item Blacklist](#12-item-blacklist)
13. [Reference: condition tests](#13-reference-condition-tests)
14. [Reference: special kinds](#14-reference-special-kinds)
15. [Advanced: building a new shop from scratch](#15-advanced-building-a-new-shop-from-scratch)

---

## 1. How the pieces fit together

Each concept is a named, reusable definition stored in its own override file. Read top-down to
see how to design a shop, bottom-up to see how the data flows at compile time. The tabs in
PhunMart Setup are in this same order for the same reason.

```
SHOP  (PhunMart_Shops.txt)
  Machine sprite, pool sets, default pricing and roll count
  │
  └─► POOL SET  (defined inline on the shop)
        One shelf: which pools feed it, its roll count and fallback price
        │
        └─► POOL  (PhunMart_Pools.txt)
              Which groups to draw from, zone gating, always-available flag
              │
              └─► GROUP  (PhunMart_Groups.txt)
                    Which game items or specials are eligible, and their defaults
                    │
                    ├─► game item catalogue  (via `categories` or explicit `items`)
                    ├─► SPECIAL  (via `specialCategories`, `specials`, or `defaults.reward`)
                    │
                    └─► ITEM / OFFER  (PhunMart_Items.txt)
                          Per-offer overrides: price, weight, stock, conditions
                          │
                          ├─► PRICE  (PhunMart_Prices.txt)
                          └─► CONDITIONS  (PhunMart_Conditions.txt)
```

A shop can carry several pool sets, and each one is an independent shelf with its own roll.
FinalAmendment uses four, so melee, ammo, guns and explosives each get guaranteed space rather
than competing in one draw. Several pools inside a single set do the opposite: they merge into
one candidate list, and the weight on each key scales that pool's offers within it.

| Layer          | Override file             | Controls                                              |
| -------------- | ------------------------- | ----------------------------------------------------- |
| **Shop**       | `PhunMart_Shops.txt`      | Sprite, pool sets, pricing, roll count, spawn rules   |
| **Pool**       | `PhunMart_Pools.txt`      | Which groups to draw from, zone gating                |
| **Group**      | `PhunMart_Groups.txt`     | Which items or specials are eligible, and defaults    |
| **Special**    | `PhunMart_Specials.txt`   | What the player receives: trait, XP, vehicle, animal  |
| **Item/Offer** | `PhunMart_Items.txt`      | Per-offer weight, stock, price, conditions            |
| **Price**      | `PhunMart_Prices.txt`     | Cost in change, tokens, or inventory items            |
| **Condition**  | `PhunMart_Conditions.txt` | Who can buy it, and how many times                    |
| **Blacklist**  | `PhunMart_Blacklist.txt`  | Items no shop may ever stock                          |

---

## 2. Common admin tasks

Most server admins want to tweak existing shops rather than build new ones. Each recipe
below is a standalone override file you drop into `Zomboid/Lua/`. See
[How overrides work](#3-how-overrides-work) for merge rules.

### Change a price

Make all food shops cheaper. `currency_low` is the default price used by GoodPhoods, so
overriding just its `amount` moves every food price at once.

`PhunMart_Prices.txt`

```lua
return {
    currency_low = { amount = { min = 150, max = 300 } },   -- was 250 to 600 ($2.50-$6.00)
}
```

To scale the whole economy at once rather than one price at a time, put a `factor` on
`currency_base`. See [The factor property](GUIDE_ITEM_CURRENCY.md#the-factor-property).

### Blacklist items from all shops

Prevent specific items from appearing in any shop. No recompile needed, and it takes effect
on the next restock.

`PhunMart_Blacklist.txt`

```lua
return {
    items = {
        exclude = {
            ["Base.Katana"]  = true,
            ["Base.Crowbar"] = true,
        }
    }
}
```

This file is union-merged with the built-in list rather than replacing it, so setting a key to
`false` is how you let something back in.

In game, the **Blacklist** tab of PhunMart Setup lists everything currently excluded and lets
you add or remove entries. You can also blacklist from the shelf you are looking at: the
**Pools** tab has a **View** button that opens the pool viewer, where right-clicking an item
offers **Add to blacklist**. Selecting several rows first blacklists them together.

### Add items to an existing group

Add specific items to an existing group so they appear in that group's pools. This merges
with the built-in list.

`PhunMart_Groups.txt`

```lua
return {
    tools_general = {
        items = { "Base.Sledgehammer", "Base.Crowbar" }
    },
}
```

### Gate an offer behind a condition

Require Carpentry 3+ to buy a specific item, and limit it to one purchase per player.

`PhunMart_Conditions.txt`

```lua
return {
    carpentryMid = {
        test = "perkLevelBetween",
        args = { perk = "Carpentry", min = 3 }
    },
}
```

`PhunMart_Items.txt`

```lua
return {
    ["Base.Sledgehammer"] = {
        conditions = { "carpentryMid", "oneTimePurchase" },   -- oneTimePurchase ships with the mod
    },
}
```

### Add vehicles from another mod

See the dedicated guide: [Adding a Modded Vehicle](GUIDE_ADDING_MODDED_VEHICLE.md). The quick-start
covers it in a couple of clicks in the admin UI, with no Lua editing required.

### Adjust restock timing for a shop

Make WrentAWreck restock weekly instead of using the server default.

`PhunMart_Shops.txt`

```lua
return {
    WrentAWreck = { restockFrequency = 168 },   -- 168 hours = 7 days
}
```

### Switch all prices to a physical item

See the dedicated guide: [Using an Item as Currency](GUIDE_ITEM_CURRENCY.md). One change
to `currency_base` flips the entire price tree from wallet deductions to inventory barter.

---

## 3. How overrides work

Each config layer has a built-in default file baked into the mod. Placing an override file in
your server's `Zomboid/Lua/` folder patches on top of those defaults using a deep merge:

| Override file                | Patches                                          |
| ---------------------------- | ------------------------------------------------ |
| `PhunMart_Prices.txt`        | Prices                                           |
| `PhunMart_Specials.txt`      | Specials, including trait, vehicle and livestock |
| `PhunMart_XP_Rewards.txt`    | XP and boost specials                            |
| `PhunMart_Conditions.txt`    | Conditions                                       |
| `PhunMart_XP_Conditions.txt` | XP conditions                                    |
| `PhunMart_Items.txt`         | Offer items                                      |
| `PhunMart_XP_Items.txt`      | XP offer items                                   |
| `PhunMart_Groups.txt`        | Item groups                                      |
| `PhunMart_Pools.txt`         | Pools                                            |
| `PhunMart_Shops.txt`         | Shops                                            |
| `PhunMart_Blacklist.txt`     | The global item blacklist                        |
| `PhunMart_TokenRewards.txt`  | Token reward milestones                          |

**Deep merge rules:**

- Tables are merged key-by-key recursively.
- Arrays are replaced entirely, never merged element-by-element.
- Setting a key to a new value in your override replaces it.
- You only need to include the keys you want to change. Everything else stays as it was.
- `PhunMart_TokenRewards.txt` is loaded in full rather than merged, so copy the whole file
  before editing it.

Each override file must `return {}` with your changes as a Lua table.

**Removing a key rather than changing it.** Because an override can only add or replace,
there needs to be a way to say "unset this". The in-game editors write the string
`__phunmart_removed__` as the value, which the loader strips out along with whatever was
underneath. If you open a file the editor has written and find one, that is what it means,
and you can write them by hand for the same effect.

**Nothing is ever edited in place.** The defaults shipped with the mod are never touched, so
deleting your override file restores stock behaviour completely. In the editors this is the
difference between a shipped definition, which you can only mask, and one you created, which
you can delete outright.

---

## 4. Prices

File: `PhunMart_Prices.txt`

Named price definitions. Referenced by pool sets (as `price`) on shops, by groups (as `defaults.price`), and by individual offers (as `price`).

```lua
return {

    -- Free -- no cost
    free = { kind = "free" },

    -- Currency -- deducted from the player's wallet
    -- pool = "change"  (loose coin balance, stored in cents: 25 = $0.25)
    -- pool = "tokens"  (bound tokens, integer count)
    currency_25 = {
        kind   = "currency",
        pool   = "change",
        amount = 25          -- $0.25
    },

    -- Amount can be a fixed number or a random range rolled per restock
    currency_low = {
        kind   = "currency",
        pool   = "change",
        amount = { min = 250, max = 600 }   -- $2.50 to $6.00
    },

    token_1 = {
        kind   = "currency",
        pool   = "tokens",
        amount = 1
    },

    -- Physical items -- items consumed from the player's inventory (barter)
    nails_10 = {
        kind  = "items",
        items = { { item = "Base.Nails", amount = 10 } }
    },

    -- Multiple item costs
    recipe_bundle = {
        kind  = "items",
        items = {
            { item = "Base.Nails",  amount = 5 },
            { item = "Base.Plank",  amount = 3 },
        }
    },

    -- Substitutes -- colour/style variants that count as equivalent payment.
    -- Primary item is consumed first; substitutes fill the remainder.
    denim_barter = {
        kind  = "items",
        items = {{
            item        = "Base.CraftedDenimShirt",
            substitutes = { "Base.CraftedDenimShirt_White", "Base.CraftedDenimShirt_Random" },
            amount      = 3
        }}
    },

    -- Self-pay -- collector/pawn offers where the displayed item IS the cost.
    -- Substitutes work here too (add at top level instead of per-item).
    self_with_subs = {
        kind        = "self",
        amount      = 3,
        substitutes = { "Base.CraftedDenimShirt_White", "Base.CraftedDenimShirt_Random" }
    },
}
```

### Price kinds

| `kind`     | What the player pays                                                            |
| ---------- | --------------------------------------------------------------------------------- |
| `free`     | Nothing                                                                         |
| `currency` | A wallet balance, named by `pool`: `change` (cents) or `tokens` (whole tokens)   |
| `items`    | Items taken from inventory, listed in `items`                                    |
| `self`     | Copies of the displayed item itself. Used by the Collectors and PrawnStars shops |

`amount` may be a fixed number or a `{ min, max }` range rolled fresh at each restock.
`factor` scales every amount in the entry after inheritance resolves, as
`ceil(amount * factor)` with a floor of 1.

### Substitutes

Colour and style variants of the same garment are equivalent as far as a barter price is
concerned, but they are separate item types to the game. A `substitutes` list says so. The
primary item is consumed first and substitutes fill whatever is left over.

On an `items` price, `substitutes` belongs to the individual item line, since each line may
have its own variants. On a `self` price there is only one item in play, so it goes at the
top level instead. Both forms appear in the example above.

### Using a physical item as currency

If you would rather price shops in a lootable item like `Base.Money` than in the built-in
change wallet, `currency_base` is the single place to change it, and `factor` rescales the
whole tree to suit. The **Change the currency** tool on the Tools tab does this with a live
preview of every affected price. See the dedicated guide:
[Using an Item as Currency](GUIDE_ITEM_CURRENCY.md).

---

## 5. Specials

File: `PhunMart_Specials.txt`

Named special definitions: the non-item things a player receives, such as traits, XP, boosts,
vehicles and livestock. `inherit` avoids repetition, and entries marked `template = true` are
base definitions that never appear as offers themselves.

### Template and inheritance

```lua
return {

    -- Base template: all trait-add specials share these defaults
    trait_add_base = {
        template = true,
        kind     = "trait",
        category = "trait_add",
        display  = { texture = "media/textures/icons/trait_add.png" }
    },

    -- Concrete special inheriting the template
    add_brave = {
        inherit  = "trait_add_base",
        display  = { text = "Gain: Brave" },
        actions  = { { type = "addTrait", trait = "base:brave" } }
    },
}
```

The `inherit` key copies all fields from the named entry, then the local fields override them.
Only one level of inheritance is supported.

### Special kinds

| `kind`      | What it does                                                              |
| ----------- | --------------------------------------------------------------------------- |
| `item`      | Spawns an inventory item. Uses `actions[].type = "giveItem"`.             |
| `trait`     | Adds or removes a character trait. Uses `addTrait` / `removeTrait`.       |
| `skill`     | Grants XP to a skill. Uses `type = "giveXP"`.                             |
| `boost`     | Raises the XP boost level for a skill. Uses `type = "applyBoost"`.        |
| `vehicle`   | Hands over a claim key for a vehicle. Uses `type = "spawnVehicle"`.       |
| `animal`    | Hands over a claim token for livestock. Uses `type = "spawnAnimal"`.      |
| `collector` | Grants bound tokens. Uses `type = "grantBoundTokens"`.                    |
| `pawn`      | Credits change to the player's wallet. Uses `type = "adjustBalance"`.     |

See [Reference: special kinds](#14-reference-special-kinds) for full action schemas.

### Display overrides

The `display` block controls what the shop UI shows for a special:

```lua
display = {
    text    = "Gain: Brave",          -- label in shop grid and details panel
    texture = "Item_Notebook",        -- icon (game texture name or mod-relative path)
}
```

If `display.texture` is omitted for an item special, the game icon for that item is used.

---

## 6. Conditions

File: `PhunMart_Conditions.txt`

Named condition definitions. Referenced in offer `conditions` arrays and pool `defaults.conditions`.
A condition is a named test applied server-side at purchase time and client-side for UI feedback.

```lua
return {

    -- Only available between 10 and 40 in-game hours
    earlyWindow = {
        test = "worldAgeHoursBetween",
        args = { min = 10, max = 40 }
    },

    -- Player must have Woodwork skill between levels 1 and 3
    midWoodwork = {
        test = "perkLevelBetween",
        args = { perk = "Woodwork", min = 1, max = 3 }
    },

    -- One purchase of this offer per account, ever
    buyOnce = {
        test  = "purchaseCountMax",
        args  = { max = 1 }
    },

    -- Player must have a profession from the list
    buildersOnly = {
        test = "professionIn",
        args = { professions = { "carpenter" } }
    },

    -- Player must have these items in their inventory
    requiresNails = {
        test = "hasItems",
        args = { items = { { item = "Base.Nails", amount = 10 } } }
    },
}
```

**Watch out for key collisions.** These files merge onto the defaults by key, so reusing a
built-in name patches that entry rather than creating your own. Writing
`minHours = { test = "worldAgeHoursBetween", args = { min = 10 } }` looks like a fresh
condition but is really an edit to the shipped `minHours`, whose `args.max` of 20 survives
the merge and keeps capping it. The example above uses names of its own for that reason.

These are the conditions that ship, and are safe to reference from an offer:

| Key                 | Meaning                                    |
| ------------------- | ------------------------------------------ |
| `minHours`          | World age between 10 and 20 in-game hours  |
| `lowCarpentry`      | Woodwork level 1 to 3                      |
| `highBoost`         | Woodwork XP boost level 2 to 3             |
| `onlyCarpenters`    | Carpenter profession                       |
| `requiresItems`     | 10 nails in inventory                      |
| `oneTimePurchase`   | One purchase of the offer                  |
| `max10Purchases`    | Ten purchases of the offer                 |

The XP shop adds a `perk_<Skill>_lt3` / `_mid` / `_high` condition for each of the 25 skills,
used to gate XP grants by current level.

See [Reference: condition tests](#13-reference-condition-tests) for all available tests.

---

## 7. Items (Offers)

File: `PhunMart_Items.txt`

Named offer definitions. These are the individual purchasable slots in a pool. Each offer
links a `price`, a `reward` (special key), and optional `conditions` and `offer` behaviour.

```lua
return {

    -- Simple item offer
    ["offer:my_pistol"] = {
        price  = "currency_high",     -- key from Prices
        reward = "reward_pistol",     -- key from Specials
        offer  = {
            weight = 1.0              -- relative probability during selection
        }
    },

    -- Offer with limited stock and restock timer
    ["vehicle:SmallCar"] = {
        price  = "vehicle_common",
        reward = "vehicle_smallcar",
        offer  = {
            weight = 1.0,
            stock  = {
                min          = 0,
                max          = 1,
                restockHours = 168    -- 1 week in-game
            }
        }
    },

    -- Offer gated by conditions
    ["offer:rare_sword"] = {
        price      = "currency_high",
        reward     = "reward_katana",
        conditions = { "minHours", "oneTimePurchase" },   -- all must pass
        offer      = { weight = 0.3 }
    },
}
```

**Key naming convention:** Items that belong to a logical type use a namespace prefix
(`offer:`, `vehicle:`, etc.) as a readability aid. The colon syntax requires bracket notation.

### Offer fields

| Field                      | Type     | Description                                               |
| -------------------------- | -------- | --------------------------------------------------------- |
| `price`                    | string   | Price key from Prices config                              |
| `reward`                   | string   | Special key from Specials config                          |
| `conditions`               | string[] | Array of condition keys; all must pass                    |
| `offer.weight`             | number   | Probability weight during restock selection (default 1.0) |
| `offer.stock.min`          | int      | Minimum stock on restock (default 1)                      |
| `offer.stock.max`          | int      | Maximum stock on restock (default 1)                      |
| `offer.stock.restockHours` | number   | In-game hours between restocks                            |

Pool sets on shops supply a default `price` for every offer rolled from that set, described
under [Shops](#10-shops). Groups and pools can also set a `defaults.price` of their own.

---

## 8. Groups

File: `PhunMart_Groups.txt`

Groups define which game items or specials are eligible for a pool. For item-type shops the
preferred approach is to source by **category** rather than listing items individually. A
single category line like `categories = { "Clothing" }` automatically covers every clothing
item in the game, hundreds of them in one declaration. It is also mod-compatible: any mod that
adds items in that category is included for free, with no config changes required.

Explicit `items` lists are for when you need precise control, such as a curated selection that
does not map cleanly onto one category, or vehicle script names, which have no category at all.
Use categories by default and fall back to explicit lists when you need to hand-pick.

For non-item shops (traits, XP, boosts, vehicles), groups use `specialCategories` to pull
specials by their `category` field, or `specials` to include specific special keys directly.
For adding vehicles from another mod to WrentAWreck, see
[Adding a Modded Vehicle](GUIDE_ADDING_MODDED_VEHICLE.md).

```lua
return {

    -- Category-based: covers every tool in the game, including from mods
    tools_general = {
        defaults = {
            price = "currency_mid",
            offer = { weight = 1.0 }
        },
        categories = { "Tool", "ToolWeapon" }
    },

    -- Include specific items only
    crafts_sewing = {
        defaults = {
            price = "currency_low",
            offer = { weight = 0.8 }
        },
        items = { "Base.Scissors", "Base.Thread" }
    },

    -- Broad category with unwanted items removed
    food_fresh = {
        defaults = {
            price = "currency_xlow",
            offer = { weight = 1.0 }
        },
        categories = { "Food" },
        blacklist = {
            "Base.Crisps", "Base.BeerBottle",   -- individual IDs to exclude
        },
        blacklistCategories = { "Alcohol" }      -- whole sub-categories to exclude
    },

    -- Override the icon and category label shown in the shop UI for this group
    vehicles_small = {
        label          = "Small Cars",
        fallbackTexture = "Item_CarKey",
        defaults = {
            price = "vehicle_common",
            offer = { weight = 1.0 }
        },
        items = { "SmallCar", "SmallCar02", "CarTaxi" }
    },

    -- Special-category group: wraps specials by their category field
    traits_add = {
        label           = "Positive Traits",
        fallbackTexture = "media/textures/icons/trait_add.png",
        fallbackCategory = "Positive Traits",
        specialCategories = { "trait_add" }
    },
}
```

### Group fields

| Field                   | Description                                                                  |
| ----------------------- | ---------------------------------------------------------------------------- |
| `defaults.price`        | Default price key applied to every item in this group                        |
| `defaults.reward`       | Special key applied to every item in this group. See below                   |
| `defaults.offer.weight` | Default weight for items from this group                                     |
| `categories`            | Game display categories to include (item-type groups)                        |
| `items`                 | Explicit item full names, or vehicle script names, to include                |
| `specialCategories`     | Special `category` values to include (non-item groups: traits, XP, vehicles) |
| `specials`              | Explicit special keys to include (non-item groups)                           |
| `blacklist`             | Item or special keys to exclude after inclusion                              |
| `blacklistCategories`   | Category names to exclude after inclusion                                    |
| `label`                 | Optional display label for this group in the UI                              |
| `fallbackTexture`       | Texture name used when an item has no icon                                   |
| `fallbackCategory`      | Category label shown in the shop details panel                               |
| `title`                 | Name for this group in the admin lists. Cosmetic; falls back to the key      |
| `enabled`               | Set `false` to drop the group from every pool that names it                  |

### defaults.reward: one special, many rows

An item listed in `items` normally becomes an offer that hands over that item. `defaults.reward`
replaces that with a named special, while each item still gets **its own row** in the shop.
The row's item is passed to the special when the purchase resolves, so one special can serve
a whole list.

This is how the vehicle groups work. `vehicles_luxury` lists six car script names and sets
`defaults.reward = "vehicle_luxury"`; the player sees six separate cars to choose between and
buying any of them runs the same `spawnVehicle` action against the one they picked. Adding a
seventh car is one entry in `items`, with no new special needed.

Contrast `specials`, where each entry is a whole special and produces exactly one row. Use
`items` plus `defaults.reward` when the entries differ only in which thing they hand over,
and `specials` when they genuinely differ.

---

## 9. Pools

File: `PhunMart_Pools.txt`

A pool is a shelf: it gathers groups into one candidate list. Roll counts live on the shop or
pool set rather than here (see [Shops](#10-shops)), though a pool can supply a fallback price.

```lua
return {
    pool_goodphoods = {
        sources = {
            groups = { "food_fresh", "food_cooking_utensils" }
        }
    },

    -- Zone-gated: only appears in difficulty 3 and 4 zones (requires PhunZones)
    pool_finalamendment_guns = {
        zones = { difficulty = { 3, 4 } },
        sources = {
            groups = { "weapons_firearms", "weapons_parts" }
        }
    },

    -- Always available: every offer appears, no roll
    pool_prawnstars_core = {
        sticky = true,
        defaults = { price = "self_1", reward = "change_payout_budget" },
        sources = { groups = { "pawn_budget" } }
    },
}
```

| Field              | Description                                                                                                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sources.groups`   | Array of Group keys to pull items and specials from                                                                                                               |
| `zones.difficulty` | Optional zone difficulty filter (0 to 5). Requires [PhunZones](https://github.com/PhunZoider/PhunZones). Checked at placement and restock. Omit for always-eligible. |
| `sticky`           | Every offer in this pool appears on every restock, bypassing the roll. See below.                                                                                 |
| `defaults.price`   | Price used by offers in this pool that name none of their own                                                                                                     |
| `defaults.offer.stock` | `{ min, max }` stock for offers in this pool that set none. Omit `max` for a fixed amount.                                                                     |
| `blacklist`        | Item keys this pool will not draw, on top of the global blacklist                                                                                                 |
| `fallbackTexture`  | Icon of last resort, used only when the group supplies none                                                                                                       |
| `fallbackCategory` | Category label of last resort, same rule                                                                                                                          |
| `title`            | Name for this pool in the admin lists. Cosmetic; falls back to the key                                                                                            |
| `enabled`          | Set `false` to drop the pool from every shop that names it                                                                                                        |

**Sticky pools** are how a machine keeps a fixed menu. Their offers are added before the roll
happens and are never subject to it, so a sticky pool of eight offers means those eight always
appear and the roll fills any remaining slots from the other pools in the set. They also win
ties: an item in both a sticky and a non-sticky pool is taken from the sticky one. Keep them
small, since every offer is permanent shelf space. The compiler warns past `MaxStickyItems`
(10 by default).

**Price precedence**, most specific first: the offer's own `price`, then the `price` on the
special it rewards, then group `defaults.price`, then pool `defaults.price`, then the pool
set's `price`. Conditions do not follow this rule: every layer's conditions are combined, and
all of them must pass.

---

## 10. Shops

File: `PhunMart_Shops.txt`

Shops bind a machine sprite to one or more pools via **pool sets**. Each pool set merges its
pools into one candidate list, then rolls a random subset.

```lua
return {

    -- Simple: one pool set, shop-level roll and price
    PittyTheTool = {
        category         = "Tool",
        background       = "machine-pity-the-tool.png",
        sprites          = { "phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27" },
        unpoweredSprites = { "phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31" },
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {
            { price = "currency_mid",
              keys = {{ key = "pool_pittythetool", weight = 1.0 }} },
        }
    },

    -- Blended: multiple pools in ONE set merge into a single menu.
    -- The weight on each key scales that pool's offer weights.
    BudgetXPerience = {
        category    = "XP",
        defaultView = "list",
        background  = "machine-budget-xp.png",
        sprites     = { "phunmart_02_40", "phunmart_02_41", "phunmart_02_42", "phunmart_02_43" },
        unpoweredSprites = { "phunmart_02_44", "phunmart_02_45", "phunmart_02_46", "phunmart_02_47" },
        roll = { mode = "weighted", count = { min = 4, max = 8 } },
        poolSets = {{
            keys = {
                { key = "pool_xp_budget",    weight = 1.0 },
                { key = "pool_boost_budget", weight = 0.5 },   -- boosts appear ~half as often
                { key = "pool_xp_gifted",    weight = 1.0 },
                { key = "pool_boost_gifted", weight = 0.5 },
            }
        }}
    },
}
```

### Shop fields

| Field              | Description                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------- |
| `category`         | Groups related shops. Shown in the admin lists, and shared by the spacing rule below.           |
| `background`       | PNG file name from `media/textures/` (no path prefix)                                          |
| `sprites`          | 4-element array of tile sprite names (E/S/W/N facing)                                          |
| `unpoweredSprites` | Sprite names shown when machine is unpowered                                                   |
| `defaultView`      | `"grid"` (default) or `"list"`, the layout the shop UI opens in                                |
| `roll`             | Default roll: `{ mode = "weighted", count = { min = N, max = M } }`. Overridable per pool set. |
| `poolSets`         | Array of pool sets (see below)                                                                 |
| `probability`      | Placement weight (default `1`). Set to `0` to disable auto-placement.                          |
| `minDistance`      | Minimum tile gap from any machine of the same type or category. Overrides `DefaultDistance`.   |
| `restockFrequency` | In-game hours between restocks (overrides server default)                                      |
| `rerollFrequency`  | In-game hours before a machine of this type becomes a different shop. See below.               |
| `enabled`          | Set `false` to disable the shop entirely. Existing machines stop working.                      |

**`category` is not just a label.** Spacing is enforced against the nearest machine of the same
type *and* the nearest of anything sharing its category, whichever is closer. Giving two shops
the same category makes them compete for space, which is what keeps, say, two different rare
weapon machines from landing on the same street. A shop with no category is spaced against its
own type alone.

### Machines that change shop

Off by default. Set `DefaultNumOfHoursToReRoll` above 0 and machines periodically stop being
one shop and become another, drawn from whatever is eligible where they stand, using the same
probability, spacing and zone rules that placed them in the first place. The machine changes
its sprite and rebuilds its stock to match, and its restock clock starts fresh.

A machine holds off while any player is within 30 tiles, so it never changes in front of the
person about to use it, and it never happens while someone has its shop window open. It changes
on the next check after they leave.

`rerollFrequency` on a shop overrides the server setting for machines of that type. Three
states, and the difference matters:

| Value        | Meaning                                                        |
| ------------ | -------------------------------------------------------------- |
| absent       | Follow `DefaultNumOfHoursToReRoll`                             |
| `0`          | Never change, even when the server default says otherwise      |
| any number   | Hours between changes for this shop, ignoring the server default |

Use `0` for a shop meant to be a landmark, so players can rely on finding it where they left
it. Machines that existed before this setting was switched on count from when they were
created rather than from hour zero, so enabling it does not turn the whole map over at once.

### Pool sets

Each pool set is an object with:

- `keys`: array of `{ key, weight }` pool references
- `price` (optional): default price for all offers in this set
- `roll` (optional): roll count for this set, overriding the shop's

**Price precedence,** most specific first: offer `price`, the special's `price`, group
`defaults.price`, pool `defaults.price`, then `poolSet.price`.

**Roll fallback:** `poolSet.roll`, then `shop.roll`, then a built-in `{min=5, max=8}`.

**Multiple pool sets** = independent shelves (e.g. FinalAmendment has separate melee, ammo,
guns, explosives shelves with different roll counts). **Multiple keys in one set** = blended
menu (e.g. BudgetXPerience merges XP and boost pools into one selection).

---

## 11. Token Rewards

File: `PhunMart_TokenRewards.txt`

Controls when players automatically receive currency. Unlike every other override file, this
one is loaded in full rather than merged, so your copy replaces the defaults outright. Copy the
whole file before editing it.

```lua
return {

    -- Playtime milestones -- one-time each, atMinutes = cumulative real-world minutes online
    playtime = {
        { atMinutes = 10,  rewards = { { item = "PhunMart.Token", amount = 1 } } },
        { atMinutes = 60,  rewards = { { item = "PhunMart.Token", amount = 1 } } },
        { atMinutes = 300, rewards = { { item = "PhunMart.Token", amount = 2 } } },
        -- Mix in other items at a milestone:
        -- { atMinutes = 600, rewards = {
        --     { item = "PhunMart.Token", amount = 5 },
        --     { item = "Base.Katana",    amount = 1 },
        -- }},
    },

    -- Normal zombie kill milestones -- one-time each per wipe
    zombieKills = {
        { kills = 100,  rewards = { { item = "PhunMart.Token", amount = 1 } } },
        { kills = 500,  rewards = { { item = "PhunMart.Token", amount = 2 } } },
        { kills = 1000, rewards = { { item = "PhunMart.Token", amount = 5 } } },
    },

    -- Sprinter kill milestones
    sprinterKills = {
        { kills = 50,  rewards = { { item = "PhunMart.Token", amount = 1 } } },
        { kills = 200, rewards = { { item = "PhunMart.Token", amount = 3 } } },
    },
}
```

### Reward items

| Item                     | Effect                                |
| ------------------------ | ------------------------------------- |
| `PhunMart.Nickel`        | Adds 5c to the player's change wallet |
| `PhunMart.Dime`          | Adds 10c to the change wallet         |
| `PhunMart.Quarter`       | Adds 25c to the change wallet         |
| `PhunMart.Token`         | Adds 1 bound token (account wallet)   |
| Any other item full name | Spawned directly into inventory       |

---

## 12. Item Blacklist

There are two blacklists, and they work at different levels.

The **global blacklist** removes an item from every shop in the game. It lives in
`PhunMart_Blacklist.txt` under `items.exclude`, and you can edit it from the **Blacklist** tab,
from the pool viewer's right-click menu, or by hand as shown in
[Blacklist items from all shops](#blacklist-items-from-all-shops). It persists across restarts.
To let an item back in, remove it on the Blacklist tab or set its key to `false`.

A **pool blacklist** is narrower: it stops one pool drawing an item that its groups would
otherwise supply, leaving other pools alone. That one lives in the `blacklist` field of the pool
itself, and there is a picker for it on the Pools editor.

Either way, an item already sitting on a shelf stays there until that machine restocks.

---

## 13. Reference: condition tests

| `test`                 | Args                                       | Description                                                                                                    |
| ---------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| `worldAgeHoursBetween` | `min`, `max` (both optional)               | World age in in-game hours                                                                                     |
| `perkLevelBetween`     | `perk`, `min`, `max` (both optional)       | Player's current level in a skill                                                                              |
| `perkBoostBetween`     | `perk`, `min`, `max`                       | Active XP boost level for a skill                                                                              |
| `professionIn`         | `professions` (array of strings)           | Player's starting profession key                                                                               |
| `hasItems`             | `items` (array of `{item, amount}`)        | Player must have these items in inventory                                                                      |
| `purchaseCountMax`     | `max`, and optionally `scope`, `key`       | Limits repeat purchases. See below.                                                                            |
| `boundTokensBelowMax`  | `max`                                      | Passes only while the player's bound token balance is under `max`. Gates token-granting offers so nobody earns tokens they cannot hold. |

### purchaseCountMax

Counts how many times this player has bought **this offer**, and fails once the count reaches
`max`. An offer here means one pool plus one item, so the same item in two different pools is
counted separately, while two machines of the same shop type share a count.

`scope` decides whose purchases count:

| `scope`             | Counts                                                             |
| ------------------- | ------------------------------------------------------------------- |
| `"character"`       | Only the current character. Dying resets it.                       |
| anything else, or omitted | Every character on the account. Dying does not reset it.     |

Set `key` to count against a name you choose instead of the offer. Several offers sharing one
`key` share a single allowance, which is how you build "pick one of these three, once".

History lives in the save, so a wipe clears it. The **Reset player data** tool on the Tools tab
clears it on demand.

### Conditions the compiler adds for you

Trait offers get extra checks injected automatically, so you do not write these yourself and
will not find them in any config file. `canGrantTrait` blocks an offer when the player already
has the trait, when they hold one that conflicts with it, or when the trait is disabled in
multiplayer. `canRemoveTrait` blocks a removal when the player does not have the trait. Both
produce ordinary condition failures with their own messages in the shop UI.

### Perk names

Perk names are the PascalCase strings returned by the game engine, for example:
`Cooking`, `Fitness`, `Strength`, `Woodwork`, `Mechanics`, `Carpentry`, `Farming`, `Fishing`,
`Foraging`, `Doctor`, `Tailoring`, `Electricity`, `MetalWelding`, `Aiming`, `Reloading`, etc.

Use `/dumppz perks` (admin command) to get the full list for your server.

---

## 14. Reference: special kinds

### `kind = "item"`: spawn an item

```lua
actions = { { type = "giveItem", item = "Base.BaseballBat", amount = 1 } }
```

`amount` is per purchase and is multiplied by the quantity bought, so one action can hand over
a stack without repeating the entry.

### `kind = "trait"`: add or remove a trait

```lua
-- Add a positive trait
actions = { { type = "addTrait",    trait = "base:brave" } }

-- Remove a negative trait
actions = { { type = "removeTrait", trait = "base:slowlearner" } }
```

Trait keys follow the `base:<name>` format. Use `/dumppz traits` to list all trait keys.

### `kind = "skill"`: grant XP to a skill

```lua
actions = { { type = "giveXP", skill = "Cooking", amount = 150 } }
```

The field is `skill`, not `perk`. Conditions use `perk` for the same idea, which is an
inconsistency worth knowing about: an action naming `perk` grants nothing and fails quietly.
`amount` is multiplied by the purchase quantity.

### `kind = "boost"`: raise the XP boost level for a skill

```lua
actions = { { type = "applyBoost", skill = "Cooking", multiplier = 2 } }
```

Despite the name, `multiplier` is the game's XP boost **level**, clamped to 1, 2 or 3. It is
not a rate, so 2.0 and 2 mean the same thing and 0.5 means 1. The boost lasts as long as the
game decides; PhunMart cannot set a duration, and a `durationHours` field is ignored if you
add one.

### `kind = "vehicle"`: hand over a vehicle claim key

```lua
actions = { {
    type    = "spawnVehicle",
    scripts = { "SmallCar", "SmallCar02" },   -- one chosen at random
    args    = {
        condition = { min = 40, max = 80 },   -- vehicle condition %
        fuel      = { min = 0.2, max = 0.6 }, -- fuel level, 0 to 1
    }
} }
```

Use `scripts` (array) to pick randomly from several variants, or `script` (string) for a single
type. Either way the purchase hands the player a **Vehicle Claim Key** rather than spawning
anything immediately; they right-click the key outdoors to summon the car.

If the offer's own item is a valid vehicle script, that is what spawns and the list is only a
fallback. That is what lets a group of car names share one special and still let the player
choose. Names are case-sensitive, and scripts that no longer resolve are dropped at compile
time. Use `/dumppz vehicles` to list them, or the vehicle picker in the Specials editor.

For a step-by-step walkthrough of adding vehicles from another mod, see
[Adding a Modded Vehicle](GUIDE_ADDING_MODDED_VEHICLE.md).

### `kind = "animal"`: hand over a livestock claim token

```lua
actions = { {
    type   = "spawnAnimal",
    animal = "hen",
    breed  = "rhodeisland",
    size   = "small",          -- small, medium or large; sets the token's weight
} }
```

Used by HoesNMoes. As with vehicles, the purchase yields a claim token that the player
right-clicks outdoors to release the animal. `size` only decides how heavy the token is to
carry, so a cow is a real commitment to haul home.

A list of `animals` may be given instead of a single `animal` and `breed`, in which case one is
chosen at random. An offer whose item reads `type:breed` picks that one specifically. Types and
breeds are validated at compile time and again at purchase, so an entry naming an animal the
game does not have is dropped rather than failing later.

### `kind = "collector"`: grant bound tokens

```lua
actions = { { type = "grantBoundTokens", amount = 2 } }
```

Used by the Collectors machine. Here the displayed item is the price: the player hands over
game items and receives bound tokens, credited to both the spendable balance and the floor
restored on death. Collector offers use `kind = "self"` prices, which is what makes the icon
in the shop grid the item the player must bring.

### `kind = "pawn"`: credit change to the wallet

```lua
actions = { { type = "adjustBalance", pool = "change", amount = 500 } }
```

Used by the PrawnStars machine, and the same flow as collectors: the player hands over items
and receives currency. `pool` defaults to `"change"` but accepts `"tokens"`. `amount` is in
cents, so 500 is $5.00. Like collectors, pawn offers use `kind = "self"` prices.

---

## 15. Advanced: building a new shop from scratch

> If you just want a working shop, the **Create a shop** wizard on the Tools tab walks you
> through appearance, spawn rules and stock, and writes all of this for you. This section is
> for understanding what it wrote, or for building one outside the game.

This walkthrough builds a small "Bob's Hardware" tool shop from nothing: a new machine, its own
pool, a curated item group, prices, and one gated special offer. It touches all seven override
files.

### Step 1: Define prices

`PhunMart_Prices.txt`

```lua
return {
    tools_cheap  = { kind = "currency", pool = "change", amount = 50  },  -- $0.50
    tools_normal = { kind = "currency", pool = "change", amount = 150 },  -- $1.50
    tools_pricey = { kind = "currency", pool = "change", amount = 500 },  -- $5.00
}
```

### Step 2: Define a special (optional)

Only needed for non-item actions (trait grants, XP boosts, vehicle spawns). Regular items
sourced from a group don't need a special entry.

`PhunMart_Specials.txt`

```lua
return {
    reward_sledgehammer = {
        kind    = "item",
        actions = { { type = "giveItem", item = "Base.Sledgehammer", amount = 1 } },
        display = { text = "Sledgehammer" }
    },
}
```

### Step 3: Define conditions (optional)

`PhunMart_Conditions.txt`

```lua
return {
    carpentryMid = {
        test = "perkLevelBetween",
        args = { perk = "Carpentry", min = 3 }
    },
}
```

### Step 4: Register the special as an offer

`PhunMart_Items.txt`

```lua
return {
    ["offer:sledgehammer_special"] = {
        price      = "tools_pricey",
        reward     = "reward_sledgehammer",
        conditions = { "carpentryMid", "oneTimePurchase" },
        offer      = { weight = 0.5 }
    },
}
```

### Step 5: Define the item group

`PhunMart_Groups.txt`

```lua
return {
    bobs_tools = {
        defaults = {
            price = "tools_normal",
            offer = { weight = 1.0 }
        },
        categories = { "Tool", "ToolWeapon" },
        blacklistCategories = { "WeaponCrafted", "JunkWeapon", "InstrumentWeapon" }
    },
}
```

### Step 6: Define the pool

`PhunMart_Pools.txt`

```lua
return {
    pool_bobshardware = {
        sources = {
            groups = { "bobs_tools" }
        }
    },
}
```

### Step 7: Define the shop

`PhunMart_Shops.txt`

```lua
return {
    BobsHardware = {
        category         = "Tool",
        background       = "machine-hard-wear.png",
        sprites          = { "phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27" },
        unpoweredSprites = { "phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31" },
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {
            { price = "tools_normal",
              keys = {{ key = "pool_bobshardware", weight = 1.0 }} },
        }
    },
}
```

Note the missing `probability`. It defaults to 1, so the shop can still be placed
automatically but will lose almost every roll against the shipped shops, which weight 15. Give
it a comparable number if you want it to appear on its own, or leave it at 1 and place machines
by hand.

On server start the compiler reads all seven files and resolves the references between them,
and the shop is live. **Reload definitions** on the Tools tab does the same thing without a
restart, which is what you want while iterating on files you are editing by hand. Then place a
`BobsHardware` machine from the in-game Items List, or wait for one to convert.

If a reference does not resolve, the offer is dropped rather than the compile failing, and the
reason is written to the server log. That is worth checking first when something you defined
does not show up.
