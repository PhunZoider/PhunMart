# PhunMart -- Customisation Guide

PhunMart is fully data-driven. Everything about what shops sell, what things cost, what
conditions gate a purchase, and how tokens are earned is defined in plain Lua config files
that you can override without touching the mod itself.

---

## Table of Contents

1. [How the pieces fit together](#1-how-the-pieces-fit-together)
2. [Quick start: a new shop from scratch](#2-quick-start-a-new-shop-from-scratch)
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

---

## 1. How the pieces fit together

A machine sells **offers** -- each offer is a thing a player can buy. An offer has a cost
(coins, tokens, or inventory items) and an action (a game item, a trait, some XP, a vehicle
key). It can also be gated: maybe only carpenters can buy it, maybe it's limited to one
purchase per player, maybe it only appears once it's back in stock.

Offers are grouped into **pools** by theme -- food, XP boosts, vehicles. A pool curates
_what's on the menu_: which items are eligible, zone gating, fallback icons. Pools don't
decide how many items appear -- that's the job of the layer above.

A **shop** is a machine with a sprite and a visual identity. It references pools through
**pool sets**. Each pool set merges all of its eligible pools into one candidate list and
then rolls a random subset from that merged set. The number of items to roll is controlled
by a `roll` field that can live on the pool set or on the shop (as a default for all its
pool sets). Separate pool sets produce independent shelves; multiple pools in the same set
blend together into a single menu.
That's the full chain: machine -> pool set -> pool -> offers -> special / cost / conditions.

The config files exist because each of those concepts is reusable. Prices are named so the
same `currency_25` applies to a hundred offers without repeating it. Conditions are named so
`onceOnly` can be shared across pools. Specials are named so the same "Gain: Brave" definition
isn't duplicated for every shop that sells traits. The layering is indirection in service of
reuse.

---

Reading bottom-up shows how data flows; top-down shows how to design a new shop.

```
SHOP  (PhunMart_Shops.lua)
  Which machine sprite, which pool sets to blend
  │
  └─► POOL  (PhunMart_Pools.lua)
        What's eligible; where to get items from
        │
        ├─► GROUP  (PhunMart_Groups.lua)
        │     Which game items to include; default price & weight
        │     │
        │     └─► game item catalogue  (auto-populated from PZ item scripts)
        │
        └─► SPECIALS  (used by trait/XP/vehicle pools)
              Pulls all specials whose category field matches
              │
              └─► SPECIAL  (PhunMart_Specials.lua)
                    What the player receives on purchase
              │
              └─► ITEM / OFFER  (PhunMart_Items.lua)
                    Per-offer overrides: price, weight, stock, conditions
                    │
                    ├─► PRICE  (PhunMart_Prices.lua)
                    │     How much it costs (change / tokens / barter items)
                    │
                    └─► CONDITIONS  (PhunMart_Conditions.lua)
                          Rules that must pass before a player can buy
```

### What each layer controls

| Layer          | Controls                                       | Lives in                  |
| -------------- | ---------------------------------------------- | ------------------------- |
| **Shop**       | Machine sprite, pool sets, default roll count  | `PhunMart_Shops.lua`      |
| **Pool**       | Item sourcing strategy; zone gating            | `PhunMart_Pools.lua`      |
| **Group**      | Which game items are eligible; default price   | `PhunMart_Groups.lua`     |
| **Special**    | What the player actually receives              | `PhunMart_Specials.lua`   |
| **Item/Offer** | Per-offer weight, stock, price, conditions     | `PhunMart_Items.lua`      |
| **Price**      | Cost in change, tokens, or inventory items     | `PhunMart_Prices.lua`     |
| **Condition**  | Who can buy it and how many times              | `PhunMart_Conditions.lua` |

Layers in the middle (Pool, Group) are primarily used for **item-type shops** -- things that
come from the PZ item catalogue. Trait, vehicle, XP, and other non-item shops skip Groups
entirely and source directly from named Specials via category.

---

## 2. Quick start: a new shop from scratch

This walkthrough builds a small "Bob's Hardware" tool shop from nothing -- a new machine,
its own pool, a curated item group, prices, and one gated special offer.

### Step 1 -- Define a price (if you need one that doesn't exist yet)

`PhunMart_Prices.lua`

```lua
return {
    tools_cheap  = { kind = "currency", pool = "change", amount = 50  },  -- $0.50
    tools_normal = { kind = "currency", pool = "change", amount = 150 },  -- $1.50
    tools_pricey = { kind = "currency", pool = "change", amount = 500 },  -- $5.00
}
```

### Step 2 -- Define a special for the offer

Specials (non-item actions like trait grants, XP boosts, vehicle spawns) go in Specials.
Regular items sourced from a group don't need a special entry -- the game item itself is the reward.

`PhunMart_Specials.lua`

```lua
return {
    reward_sledgehammer = {
        kind    = "item",
        actions = { { type = "giveItem", item = "Base.Sledgehammer", amount = 1 } },
        display = { text = "Sledgehammer" }
    },
}
```

### Step 3 -- Define a condition for the special offer

`PhunMart_Conditions.lua`

```lua
return {
    -- Must have level 3+ Carpentry skill
    carpentryMid = {
        test = "perkLevelBetween",
        args = { perk = "Carpentry", min = 3 }
    },

    -- Can only buy this once per character, ever
    onceOnly = {
        test  = "purchaseCountMax",
        args  = { max = 1, scope = "player_item" }
    },
}
```

### Step 4 -- Register the special offer as an Item entry

`PhunMart_Items.lua`

```lua
return {
    ["offer:sledgehammer_special"] = {
        price      = "tools_pricey",
        reward     = "reward_sledgehammer",
        conditions = { "carpentryMid", "onceOnly" },
        offer      = { weight = 0.5 }   -- appears less often than regular tools
    },
}
```

### Step 5 -- Define the item group

Groups describe which game items to pull in from the PZ catalogue.

`PhunMart_Groups.lua`

```lua
return {
    bobs_tools = {
        defaults = {
            price = "tools_normal",
            offer = { weight = 1.0 }
        },
        include = {
            categories = { "Tool", "ToolWeapon" }
        },
        -- Exclude anything too combat-focused for a hardware shop
        blacklistCategories = { "WeaponCrafted", "JunkWeapon", "InstrumentWeapon" }
    },
}
```

### Step 6 -- Define the pool

The pool draws from `bobs_tools` (which expands to all matching game items) and also includes
the special offer key directly via `sources.items`. The sledgehammer's lower weight (0.5)
means it appears roughly half as often as a weight-1 item when the pool set rolls its
selection. How many items appear is controlled by `roll` on the shop or pool set -- not here.

`PhunMart_Pools.lua`

```lua
return {
    pool_bobshardware = {
        sources = {
            groups = { "bobs_tools" },
            items  = { "offer:sledgehammer_special" }  -- joins the same candidate set
        }
    },
}
```

### Step 7 -- Define the shop

`PhunMart_Shops.lua`

```lua
return {
    BobsHardware = {
        category         = "Tool",
        background       = "machine-hard-wear.png",   -- reuse an existing background, or add your own
        sprites          = { "phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27" },
        unpoweredSprites = { "phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31" },
        roll = { mode = "weighted", count = { min = 5, max = 8 } },  -- 5-8 items per restock
        poolSets = {
            { keys = {{ key = "pool_bobshardware", weight = 1.0 }} },
        }
    },
}
```

That's the complete chain. On server start the compiler reads all seven files, resolves
the references, and the shop is live. An admin can then place a `BobsHardware` machine
via the admin menu.

---

## 3. How overrides work

Each config layer has a built-in default file baked into the mod. Placing an override file in
your server's `Zomboid/Lua/` folder patches on top of those defaults using a deep merge:

| Override file                | Patches                 |
| ---------------------------- | ----------------------- |
| `PhunMart_Prices.lua`        | Prices                  |
| `PhunMart_Specials.lua`      | Specials                |
| `PhunMart_Conditions.lua`    | Conditions              |
| `PhunMart_Items.lua`         | Offer items             |
| `PhunMart_XP_Items.lua`      | XP offer items          |
| `PhunMart_XP_Conditions.lua` | XP conditions           |
| `PhunMart_Groups.lua`        | Item groups             |
| `PhunMart_Pools.lua`         | Pools                   |
| `PhunMart_Shops.lua`         | Shops                   |
| `PhunMart_TokenRewards.lua`  | Token reward milestones |

**Deep merge rules:**

- Tables are merged key-by-key recursively.
- Arrays are replaced entirely (not merged element-by-element).
- Setting a key to a new value in your override replaces it.
- You only need to include the keys you want to change -- everything else stays as-is.
- `PhunMart_TokenRewards.lua` is loaded in full (not merged) -- copy the whole file before editing.

Each override file must `return {}` with your changes as a Lua table.

---

## 4. Prices

File: `PhunMart_Prices.lua`

Named price definitions. Referenced by pools (as `defaults.price`) and individual offers (as `price`).

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
        amount = { min = 250, max = 600 }   -- $2.50–$6.00
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

    -- Item substitutes -- accept variant items as equivalent payment.
    -- Many PZ items have colour or style variants with different keys but
    -- identical gameplay value (e.g. denim shirts). Adding `substitutes`
    -- lets the system count any listed variant toward the required amount.
    -- The primary item is consumed first; substitutes fill the remainder.
    denim_barter = {
        kind  = "items",
        items = {{
            item        = "Base.CraftedDenimShirt",
            substitutes = { "Base.CraftedDenimShirt_White", "Base.CraftedDenimShirt_Random" },
            amount      = 3
        }}
    },

    -- Self-pay with substitutes -- collector offers where players hand over
    -- N of the displayed item. Substitutes let colour variants count too.
    self_with_subs = {
        kind        = "self",
        amount      = 3,
        substitutes = { "Base.CraftedDenimShirt_White", "Base.CraftedDenimShirt_Random" }
    },
}
```

### Substitutes

The `substitutes` field is an optional array of item keys that count as equivalent payment
alongside the primary `item`. This is useful when PZ has multiple variants of the same item
(colour variants, crafted vs looted, etc.) that players would reasonably expect to be
interchangeable.

- On `kind = "items"` prices: add `substitutes` to any item line in the `items` array.
- On `kind = "self"` prices: add `substitutes` at the top level of the price entry.

When checking affordability, the system sums the player's inventory count of the primary item
plus all substitutes. When deducting, it removes from the primary item first, then from each
substitute in order until the required amount is met.

---

## 5. Specials

File: `PhunMart_Specials.lua`

Named special definitions -- non-item actions the player receives (traits, XP, boosts, vehicles).
Supports inheritance via `inherit` to avoid repetition. Templates (`template = true`) are base
definitions not used as offers directly.

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

| `kind`    | What it does                                                        |
| --------- | ------------------------------------------------------------------- |
| `item`    | Spawns an inventory item. Uses `actions[].type = "giveItem"`.       |
| `trait`   | Adds or removes a character trait. Uses `addTrait` / `removeTrait`. |
| `skill`   | Grants XP to a perk. Uses `type = "giveXP"`.                        |
| `boost`   | Applies a temporary XP multiplier. Uses `type = "applyBoost"`.      |
| `vehicle` | Spawns a vehicle nearby. Uses `type = "spawnVehicle"`.              |

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

File: `PhunMart_Conditions.lua`

Named condition definitions. Referenced in offer `conditions` arrays and pool `defaults.conditions`.
A condition is a named test applied server-side at purchase time and client-side for UI feedback.

```lua
return {

    -- Only available after 10 in-game hours
    minHours = {
        test = "worldAgeHoursBetween",
        args = { min = 10 }
    },

    -- Player must have Woodwork skill between levels 1 and 3
    lowCarpentry = {
        test = "perkLevelBetween",
        args = { perk = "Woodwork", min = 1, max = 3 }
    },

    -- Limit purchases to 1 per player per shop per item (across all sessions)
    onceOnly = {
        test  = "purchaseCountMax",
        args  = { max = 1, scope = "player_item_shop" }
    },

    -- Player must have a profession from the list
    onlyCarpenters = {
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

See [Reference: condition tests](#13-reference-condition-tests) for all available tests.

---

## 7. Items (Offers)

File: `PhunMart_Items.lua`

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
        conditions = { "minHours", "onceOnly" },   -- all must pass
        offer      = { weight = 0.3 }
    },
}
```

**Key naming convention:** Items that belong to a logical type use a namespace prefix
(`offer:`, `vehicle:`, etc.) as a readability aid. The colon syntax requires bracket notation.

### Offer fields

| Field                      | Type     | Description                                       |
| -------------------------- | -------- | ------------------------------------------------- |
| `price`                    | string   | Price key from Prices config                      |
| `reward`                   | string   | Special key from Specials config                  |
| `conditions`               | string[] | Array of condition keys; all must pass            |
| `offer.weight`             | number   | Probability weight during restock selection (default 1.0) |
| `offer.stock.min`          | int      | Minimum stock on restock (default 1)              |
| `offer.stock.max`          | int      | Maximum stock on restock (default 1)              |
| `offer.stock.restockHours` | number   | In-game hours between restocks                    |

Pools can also supply `defaults` that apply to all items sourced from a group -- see [Pools](#9-pools).

---

## 8. Groups

File: `PhunMart_Groups.lua`

Groups define which game items are eligible for a pool. The preferred approach is to source
by **category** rather than listing items individually. A single category line like
`categories = { "Clothing" }` automatically covers every clothing item in the game -- hundreds
of items in one declaration. It's also mod-compatible: any mod that adds items in that
category gets included for free, with no config changes required.

Explicit `include.items` lists are for cases where you need precise control -- curated
selections that don't map cleanly to a single category, or vehicle script names which have no
category at all. Use categories as the default; fall back to explicit lists when you need
to hand-pick.

```lua
return {

    -- Category-based: covers every tool in the game, including from mods
    tools_general = {
        defaults = {
            price = "currency_mid",
            offer = { weight = 1.0 }
        },
        include = {
            categories = { "Tool", "ToolWeapon" }
        }
    },

    -- Include specific items only
    crafts_sewing = {
        defaults = {
            price = "currency_low",
            offer = { weight = 0.8 }
        },
        include = {
            items = { "Base.Scissors", "Base.Thread" }
        }
    },

    -- Broad category with unwanted items removed
    food_fresh = {
        defaults = {
            price = "currency_xlow",
            offer = { weight = 1.0 }
        },
        include = {
            categories = { "Food" }
        },
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
        include = {
            items = { "SmallCar", "SmallCar02", "CarTaxi" }
        }
    },
}
```

### Group fields

| Field                   | Description                                           |
| ----------------------- | ----------------------------------------------------- |
| `defaults.price`        | Default price key applied to every item in this group |
| `defaults.offer.weight` | Default weight for items from this group              |
| `include.categories`    | Game display categories to include                    |
| `include.items`         | Explicit item full names to include                   |
| `blacklist`             | Item full names to exclude after category inclusion   |
| `blacklistCategories`   | Category names to exclude after inclusion             |
| `label`                 | Optional display label for this group in the UI       |
| `fallbackTexture`       | Texture name used when an item has no icon            |

---

## 9. Pools

File: `PhunMart_Pools.lua`

Pools define _what's on the menu_ -- a set of eligible offers drawn from groups or special
categories. Pools are pure curation: they control which items can appear, not how many.
The number of items shown per restock is controlled by `roll` on the pool set or shop level
(see [Shops](#10-shops)).

```lua
return {

    pool_goodphoods = {
        defaults = {
            price = "currency_05"  -- overrides group defaults for items in this pool
        },
        sources = {
            groups = { "food_fresh", "food_cooking_utensils" }  -- pull from Groups
        }
    },

    -- Pool sourcing from specials (used for trait/XP/vehicle shops)
    -- sources.specials pulls all specials whose `category` field matches
    pool_traiter_good = {
        fallbackTexture  = "Item_Notebook",
        fallbackCategory = "Positive Traits",
        sources = {
            specials = { "trait_add" }
        }
    },
}
```

### Pool fields

| Field              | Description                                                                                                                                                                                                    |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `defaults.price`   | Price key applied to every item drawn from this pool                                                                                                                                                           |
| `sources.groups`   | Array of Group keys to pull items from                                                                                                                                                                         |
| `sources.specials` | Array of special category strings -- pulls all items whose special has a matching `category` field                                                                                                              |
| `fallbackTexture`  | Icon to use when an offer has no icon                                                                                                                                                                          |
| `fallbackCategory` | Category label shown in the shop details panel                                                                                                                                                                 |
| `zones.difficulty` | Optional array of allowed zone difficulty values (0-5). Requires [PhunZones](https://github.com/PhunZoider/PhunZones). If omitted the pool is always eligible. Machines in unzoned areas also pass the filter. |

#### Zone difficulty filtering

If PhunZones is installed, you can restrict a pool to specific difficulty tiers:

```lua
pool_weapons_advanced = {
    zones = {
        difficulty = { 3, 4, 5 }   -- only eligible in mid-to-hard zones
    },
    sources = { ... }
}
```

The filter applies at two points:

1. **Placement time** -- a shop will only be placed at a location if at least one of its pools passes the zone filter for that position.
2. **Restock time** -- only pools that pass the zone filter for the machine's position are included in that restock's merged candidate set.

Pools without a `zones` field, machines in unzoned areas, and servers without PhunZones installed all behave permissively -- every pool is eligible.

---

## 10. Shops

File: `PhunMart_Shops.lua`

Shops bind a machine sprite to one or more pools. Each shop key is a unique machine type.

```lua
return {

    -- Simple shop: one pool set, shop-level roll applies to all sets
    PittyTheTool = {
        category         = "Tool",
        background       = "machine-pity-the-tool.png",
        sprites          = { "phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27" },
        unpoweredSprites = { "phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31" },
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {
            { keys = {{ key = "pool_pittythetool", weight = 1.0 }} },
        }
    },

    -- Multiple pool sets with per-set roll overrides.
    -- Each set is an independent shelf; all shelves contribute to the shop.
    -- Per-set roll overrides the shop-level roll for that shelf.
    FinalAmendment = {
        category   = "Weapon",
        background = "machine-final-amendment.png",
        sprites    = { "phunmart_01_32", "phunmart_01_33", "phunmart_01_34", "phunmart_01_35" },
        unpoweredSprites = { "phunmart_01_36", "phunmart_01_37", "phunmart_01_38", "phunmart_01_39" },
        poolSets = {
            { roll = { mode = "weighted", count = { min = 2, max = 3 } },
              keys = {{ key = "pool_finalamendment_melee", weight = 1.0 }} },
            { roll = { mode = "weighted", count = { min = 4, max = 7 } },
              keys = {{ key = "pool_finalamendment_ammo",  weight = 1.0 }} },
            { roll = { mode = "weighted", count = { min = 3, max = 5 } },
              keys = {{ key = "pool_finalamendment_guns",  weight = 1.0 }} },
            { roll = { mode = "weighted", count = { min = 1, max = 3 } },
              keys = {{ key = "pool_finalamendment_explosives", weight = 1.0 }} },
        }
    },

    -- Blended pools: multiple pools in ONE set merge into a single candidate
    -- list. The weight on each key scales that pool's offer weights (rarity
    -- multiplier). Here boost pools have weight 0.5 so boost items appear
    -- roughly half as often as XP items in the merged selection.
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
                { key = "pool_boost_budget", weight = 0.5 },
                { key = "pool_xp_gifted",    weight = 1.0 },
                { key = "pool_boost_gifted", weight = 0.5 },
                { key = "pool_xp_luxury",    weight = 1.0 },
                { key = "pool_boost_luxury", weight = 0.5 },
            }
        }}
    },

    -- Zone-gated pools: each pool has a zones.difficulty filter. At restock,
    -- only pools matching the machine's zone are merged into the candidate set.
    WrentAWreck = {
        category    = "Vehicle",
        defaultView = "list",
        background  = "machine-wrent-a-wreck.png",
        sprites     = { "phunmart_01_40", "phunmart_01_41", "phunmart_01_42", "phunmart_01_43" },
        unpoweredSprites = { "phunmart_01_44", "phunmart_01_45", "phunmart_01_46", "phunmart_01_47" },
        roll = { mode = "weighted", count = { min = 5, max = 8 } },
        poolSets = {
            { keys = {{ key = "pool_vehicles_budget",   weight = 1.0 }} },
            { keys = {{ key = "pool_vehicles_standard", weight = 1.0 }} },
            { keys = {{ key = "pool_vehicles_premium",  weight = 1.0 }} },
        }
    },
}
```

### Shop fields

| Field              | Description                                                                                                                                                            |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `category`         | Display category shown in admin tools                                                                                                                                  |
| `background`       | PNG file name from `media/textures/` (no path prefix)                                                                                                                  |
| `sprites`          | 4-element array of tile sprite names (E/S/W/N facing)                                                                                                                  |
| `unpoweredSprites` | 4-element array of sprite names shown when machine is unpowered                                                                                                        |
| `defaultView`      | `"grid"` (default) or `"list"` -- layout mode for the shop UI                                                                                                           |
| `roll`             | Default roll for all pool sets: `{ mode = "weighted", count = { min = N, max = M } }`. Can be overridden per pool set.                                                 |
| `poolSets`         | Array of pool sets. Each set has a `keys` array and an optional `roll` override                                                                                        |
| `probability`      | Relative weight in the placement lottery (default `1`). Set to `0` to disable automatic placement. Higher values make the shop appear more often.                      |
| `minDistance`      | Minimum tile distance from any other machine of the same shop type (overrides `DefaultDistance` sandbox setting). Useful for keeping rare shops spread across the map. |
| `restockFrequency` | In-game hours between automatic restocks (default: server setting). Overrides the global restock timer for this shop type only -- e.g. `168` for weekly.                |

**How pool sets work:**

Each pool set merges **all eligible pools** from its `keys` into one candidate list, then
rolls a random subset using the set's `roll` config. The `weight` on each key entry scales
that pool's offer weights -- it acts as a rarity multiplier, not a selection probability.
If the same item appears in multiple pools within a set, it is deduplicated (first
occurrence wins).

**Roll fallback chain:** `poolSet.roll` > `shop.roll` > global default `{min=5, max=8}`.
You only need to set `roll` on the pool set if it differs from the shop default.

This gives you two levels of control:

- **Multiple pool sets** -- each set is an independent shelf. Use this when a shop should
  always stock from several categories (e.g. FinalAmendment always has melee, ammo, guns,
  and explosives as separate shelves with different roll counts).
- **Multiple keys in one set** -- all pools blend together into a single merged menu. Use
  this when pools share a theme but are zone-gated or have different rarity tiers (e.g.
  BudgetXPerience merges all XP/boost pools; zone filtering decides which tiers contribute).

---

## 11. Token Rewards

File: `PhunMart_TokenRewards.lua`

Controls when players automatically receive currency. This file is loaded in full -- copy the
entire example file and edit it. It is not merged with defaults; your file replaces them.

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

The blacklist lets admins exclude specific items from all shop pools without editing any config
file. Blacklisted items are filtered out at restock time -- they will not appear as offers in
any pool, regardless of which group sourced them.

### Via the in-game UI

Open any shop as an admin. Click the gear icon (admin panel) → **Pool Viewer**. Right-click any
item row → **Add to blacklist**. The row greys out immediately and the exclusion takes effect on
the next restock.

### Via override file

`PhunMart_Items.lua` -- set the item's `blacklisted` field to `true`:

```lua
return {
    -- Prevent katanas from appearing in any shop
    ["Base.Katana"] = {
        blacklisted = true
    },
}
```

The blacklist is stored server-side and persists across restarts. Removing an entry from the
override file (or setting `blacklisted = false`) re-enables the item on next restock.

---

## 13. Reference: condition tests

| `test`                 | Args                                | Description                                                                                                                                               |
| ---------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `worldAgeHoursBetween` | `min`, `max` (optional)             | World age in in-game hours                                                                                                                                |
| `perkLevelBetween`     | `perk`, `min`, `max` (optional)     | Player's current level in a skill                                                                                                                         |
| `perkBoostBetween`     | `perk`, `min`, `max`                | Active XP boost level for a skill                                                                                                                         |
| `professionIn`         | `professions` (array of strings)    | Player's starting profession key                                                                                                                          |
| `purchaseCountMax`     | `max`, `scope`                      | Limits repeat purchases                                                                                                                                   |
| `hasItems`             | `items` (array of `{item, amount}`) | Player must have items in inventory                                                                                                                       |
| `boundTokensBelowMax`  | _(none)_                            | Passes only if the player's bound token balance is below the server cap. Used to gate token-granting offers so players can't earn tokens they can't hold. |

### purchaseCountMax scopes

| Scope               | Meaning                                                       |
| ------------------- | ------------------------------------------------------------- |
| `player_item_shop`  | Per player, per offer, per shop (default)                     |
| `player_item`       | Per player, per offer across all shops                        |
| `player_shop`       | Per player, per shop (all offers combined)                    |
| `player`            | Per player, across all shops and all offers                   |
| `account_item_shop` | Per account (persists across characters), per offer, per shop |
| `account`           | Per account, across everything                                |

### Perk names

Perk names are the PascalCase strings returned by the game engine, for example:
`Cooking`, `Fitness`, `Strength`, `Woodwork`, `Mechanics`, `Carpentry`, `Farming`, `Fishing`,
`Foraging`, `Doctor`, `Tailoring`, `Electricity`, `MetalWelding`, `Aiming`, `Reloading`, etc.

Use `/dumppz perks` (admin command) to get the full list for your server.

---

## 14. Reference: special kinds

### `kind = "item"` -- spawn an item

```lua
actions = { { type = "giveItem", item = "Base.BaseballBat", amount = 1 } }
```

### `kind = "trait"` -- add or remove a trait

```lua
-- Add a positive trait
actions = { { type = "addTrait",    trait = "base:brave" } }

-- Remove a negative trait
actions = { { type = "removeTrait", trait = "base:slowlearner" } }
```

Trait keys follow the `base:<name>` format. Use `/dumppz traits` to list all trait keys.

### `kind = "skill"` -- grant XP to a perk

```lua
actions = { { type = "giveXP", perk = "Cooking", amount = 150 } }
```

### `kind = "boost"` -- apply a temporary XP multiplier

```lua
actions = { { type = "applyBoost", perk = "Cooking", multiplier = 2.0, durationHours = 4 } }
```

### `kind = "vehicle"` -- spawn a vehicle

```lua
actions = { {
    type    = "spawnVehicle",
    scripts = { "SmallCar", "SmallCar02" },   -- one chosen at random
    args    = {
        condition = { min = 40, max = 80 },   -- vehicle condition %
        fuel      = { min = 0.2, max = 0.6 }, -- fuel level 0–1
    }
} }
```

Use `scripts` (array) to pick randomly from multiple variants, or `script` (string) for a single type.
Vehicle script names come from the game's vehicle script database -- use `/dumppz vehicles` to list them.
