# PhunMart -- Customisation Guide

PhunMart is fully data-driven. Everything about what shops sell, what things cost, what
conditions gate a purchase, and how tokens are earned is defined in plain JSON config files
that you can override without touching the mod itself.

> **Upgrading from before B42.20.4?** These files used to be Lua tables in `.txt` files. That
> build removed `loadstring`, so the game can no longer read them, and the config files are
> now `.json`. See [Converting your old config files](#converting-your-old-config-files).

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

Each concept is a named, reusable definition stored in its own override file. Reading
top-down shows how to design a shop; bottom-up shows how data flows at compile time.

```
SHOP  (PhunMart_Shops.json)
  Machine sprite, pool sets, default pricing & roll count
  │
  └─► POOL SET  (defined inline on the shop)
        Roll count, default price for this shelf
        │
        └─► POOL  (PhunMart_Pools.json)
              Which groups to draw from; zone gating
              │
              └─► GROUP  (PhunMart_Groups.json)
                    Which game items or specials to include; default price & weight
                    │
                    ├─► game item catalogue  (via `categories` or explicit `items`)
                    ├─► SPECIAL  (via `specialCategories` or explicit `specials`)
                    │
                    └─► ITEM / OFFER  (PhunMart_Items.json)
                          Per-offer overrides: price, weight, stock, conditions
                          │
                          ├─► PRICE  (PhunMart_Prices.json)
                          └─► CONDITIONS  (PhunMart_Conditions.json)
```

| Layer          | Override file             | Controls                                            |
| -------------- | ------------------------- | --------------------------------------------------- |
| **Shop**       | `PhunMart_Shops.json`      | Sprite, pool sets, pricing, roll count, spawn rules |
| **Pool**       | `PhunMart_Pools.json`      | Which groups to draw from; zone gating              |
| **Group**      | `PhunMart_Groups.json`     | Which items or specials are eligible; default price |
| **Special**    | `PhunMart_Specials.json`   | What the player receives (trait, XP, vehicle, etc.) |
| **Item/Offer** | `PhunMart_Items.json`      | Per-offer weight, stock, price, conditions          |
| **Price**      | `PhunMart_Prices.json`     | Cost in change, tokens, or inventory items          |
| **Condition**  | `PhunMart_Conditions.json` | Who can buy it and how many times                   |

---

## 2. Common admin tasks

Most server admins want to tweak existing shops rather than build new ones. Each recipe
below is a standalone override file you drop into `Zomboid/Lua/`. See
[How overrides work](#3-how-overrides-work) for merge rules.

### Change a price

Make all food shops cheaper. `currency_low` is the default price used by GoodPhoods --
override just the `amount` field.

`PhunMart_Prices.json`

```json
{
  "currency_low": { "amount": 15 }
}
```

The shipped value is 25, which is $0.25, so that drops it to $0.15.

### Blacklist items from all shops

Prevent specific items from appearing in any shop. No recompile needed -- takes effect on
next restock.

`PhunMart_Items.json`

```json
{
  "Base.Katana": { "blacklisted": true },
  "Base.Crowbar": { "blacklisted": true }
}
```

You can also do this in-game: open any shop as admin → Admin Tools → Pool Viewer →
right-click an item → **Add to blacklist**.

### Add items to an existing group

Add specific items to an existing group so they appear in that group's pools. This merges
with the built-in list.

`PhunMart_Groups.json`

```json
{
  "tools_general": {
    "items": ["Base.Sledgehammer", "Base.Crowbar"]
  }
}
```

### Gate an offer behind a condition

Require Carpentry 3+ to buy a specific item, and limit it to one purchase per player.

`PhunMart_Conditions.json`

```json
{
  "carpentryMid": {
    "test": "perkLevelBetween",
    "args": { "perk": "Carpentry", "min": 3 }
  }
}
```

`PhunMart_Items.json`

```json
{
  "Base.Sledgehammer": {
    "conditions": ["carpentryMid", "onceOnly"]
  }
}
```

`onceOnly` is built in, so only `carpentryMid` needs defining.

### Add vehicles from another mod

See the dedicated guide: [Adding a Modded Vehicle](GUIDE_ADDING_MODDED_VEHICLE.md). The quick-start
covers it in two steps using the in-game admin UI -- no Lua editing required.

### Adjust restock timing for a shop

Make WrentAWreck restock weekly instead of using the server default.

`PhunMart_Shops.json`

```json
{
  "WrentAWreck": { "restockFrequency": 168 }
}
```

`restockFrequency` is in hours, so 168 is seven days.

### Switch all prices to a physical item

See the dedicated guide: [Using an Item as Currency](GUIDE_ITEM_CURRENCY.md). One change
to `currency_base` flips the entire price tree from wallet deductions to inventory barter.

---

## 3. How overrides work

Each config layer has a built-in default file baked into the mod. Placing an override file in
your server's `Zomboid/Lua/` folder patches on top of those defaults using a deep merge:

| Override file                | Patches                 |
| ---------------------------- | ----------------------- |
| `PhunMart_Prices.json`        | Prices                  |
| `PhunMart_Specials.json`      | Specials                |
| `PhunMart_Conditions.json`    | Conditions              |
| `PhunMart_Items.json`         | Offer items             |
| `PhunMart_XP_Items.json`      | XP offer items          |
| `PhunMart_XP_Conditions.json` | XP conditions           |
| `PhunMart_Groups.json`        | Item groups             |
| `PhunMart_Pools.json`         | Pools                   |
| `PhunMart_Shops.json`         | Shops                   |
| `PhunMart_TokenRewards.json`  | Token reward milestones |

**Deep merge rules:**

- Tables are merged key-by-key recursively.
- Arrays are replaced entirely (not merged element-by-element).
- Setting a key to a new value in your override replaces it.
- You only need to include the keys you want to change -- everything else stays as-is.
- `PhunMart_TokenRewards.json` is loaded in full (not merged) -- copy the whole file before editing.

Each override file is a single JSON object holding your changes.

### Converting your old config files

Before B42.20.4 these files were Lua tables in `.txt` files, and the mod read them with
`loadstring`. That build removed `loadstring`, `load` and `loadfile`, so there is no longer any
way for the game to read Lua source at runtime. The config files are JSON instead, and an old
`.txt` cannot be read at all.

Your old files are left exactly where they are. Nothing deletes or rewrites them, and they stay
readable as a backup for as long as you want to keep them. What the mod does is notice them: if
`PhunMart_Pools.txt` is present and `PhunMart_Pools.json` is not, the server log says so at
startup and points at the converter, and the settings in that file are not applied until you
convert it.

This applies to the player data files too, not just the overrides:
`PhunMart_Wallet.txt`, `PhunMart_Purchases.txt`, `PhunMart_KillTracking.txt` and
`PhunMart_PlaytimeTracking.txt`. Wallet balances also live in the save, so those survive
regardless, but purchase history and reward progress come back only once their files are
converted. Convert them before players return, and nothing is lost.

To convert:

1. Back up your existing `.txt` files.
2. Open the [Phun configuration converter](https://phunzoider.github.io/PhunZones/converter/).
   It runs entirely in your browser and does not upload anything.
3. Drag each old `PhunMart_*.txt` file onto the page, or paste its contents.
4. Download the `.json` file it produces.
5. Put it in the same folder as the old file, with the same name and a `.json` extension:
   `PhunMart_Pools.txt` becomes `PhunMart_Pools.json`.
6. Restart the server and check the log for any file it is still complaining about.
7. Keep the `.txt` files until you have confirmed everything came across.

Where the files live:

| Setup            | Folder                                            |
| ---------------- | ------------------------------------------------- |
| Single-player    | `%UserProfile%\Zomboid\Lua\`                      |
| Dedicated server | `%UserProfile%\Zomboid\Server\<server-name>\Lua\` |

On a multiplayer server these files exist only on the server. Clients have no copy and need no
conversion.

The converter accepts data tables only. It rejects functions, calls and expressions, so a
config file with real Lua logic in it has to be rewritten by hand: there is no version of the
new runtime that can execute it. If you never hand-edited these files, everything the mod
itself wrote will convert cleanly.

---

## 4. Prices

File: `PhunMart_Prices.json`

Named price definitions. Referenced by pool sets (as `price`) on shops, by groups (as `defaults.price`), and by individual offers (as `price`).

```json
{
  "free": { "kind": "free" },

  "currency_25": {
    "kind": "currency",
    "pool": "change",
    "amount": 25
  },

  "currency_low": {
    "kind": "currency",
    "pool": "change",
    "amount": { "min": 250, "max": 600 }
  },

  "token_1": {
    "kind": "currency",
    "pool": "tokens",
    "amount": 1
  },

  "nails_10": {
    "kind": "items",
    "items": [{ "item": "Base.Nails", "amount": 10 }]
  },

  "recipe_bundle": {
    "kind": "items",
    "items": [
      { "item": "Base.Nails", "amount": 5 },
      { "item": "Base.Plank", "amount": 3 }
    ]
  },

  "denim_barter": {
    "kind": "items",
    "items": [{
      "item": "Base.CraftedDenimShirt",
      "substitutes": ["Base.CraftedDenimShirt_White", "Base.CraftedDenimShirt_Random"],
      "amount": 3
    }]
  },

  "self_with_subs": {
    "kind": "self",
    "amount": 3,
    "substitutes": ["Base.CraftedDenimShirt_White", "Base.CraftedDenimShirt_Random"]
  }
}
```

Taking those in turn:

- `free` costs nothing.
- `currency_25` and `currency_low` are deducted from the player's wallet. `pool` picks which
  balance: `change` is the loose coin balance and is stored in cents, so `25` is $0.25 and the
  `250` to `600` range is $2.50 to $6.00. `tokens`, as in `token_1`, is an integer count of
  bound tokens.
- `amount` is either a fixed number or a `min`/`max` range, which is rolled once per restock.
- `nails_10` and `recipe_bundle` are barter: the items are consumed from the player's
  inventory, and a price can name more than one.
- `substitutes` on an item lists colour or style variants that count as equivalent payment.
  The primary item is consumed first and the substitutes fill the remainder.
- `self_with_subs` is a self-pay price, used by collector and pawn offers where the item on
  display *is* the cost. Substitutes work here too, but sit at the top level rather than
  inside `items`.

### Using a physical item as currency

If you'd rather price shops in a lootable item like `Base.Money` instead of the built-in
change wallet, you can switch `currency_base` to `kind = "items"` and use the `factor`
property to scale the entire price tree in one step. See the dedicated guide:
[Using an Item as Currency](GUIDE_ITEM_CURRENCY.md).

---

## 5. Specials

File: `PhunMart_Specials.json`

Named special definitions -- non-item actions the player receives (traits, XP, boosts, vehicles).
Supports inheritance via `inherit` to avoid repetition. Templates (`template = true`) are base
definitions not used as offers directly.

### Template and inheritance

```json
{
  "trait_add_base": {
    "template": true,
    "kind": "trait",
    "category": "trait_add",
    "display": { "texture": "media/textures/icons/trait_add.png" }
  },

  "add_brave": {
    "inherit": "trait_add_base",
    "display": { "text": "Gain: Brave" },
    "actions": [{ "type": "addTrait", "trait": "base:brave" }]
  }
}
```

`trait_add_base` is the template every trait-add special shares; `add_brave` is a concrete
special inheriting from it.

The `inherit` key copies all fields from the named entry, then the local fields override them.
Only one level of inheritance is supported.

### Special kinds

| `kind`      | What it does                                                          |
| ----------- | --------------------------------------------------------------------- |
| `item`      | Spawns an inventory item. Uses `actions[].type = "giveItem"`.         |
| `trait`     | Adds or removes a character trait. Uses `addTrait` / `removeTrait`.   |
| `skill`     | Grants XP to a perk. Uses `type = "giveXP"`.                          |
| `boost`     | Applies a temporary XP multiplier. Uses `type = "applyBoost"`.        |
| `vehicle`   | Spawns a vehicle nearby. Uses `type = "spawnVehicle"`.                |
| `collector` | Grants bound tokens. Uses `type = "grantBoundTokens"`.                |
| `pawn`      | Credits change to the player's wallet. Uses `type = "adjustBalance"`. |

See [Reference: special kinds](#14-reference-special-kinds) for full action schemas.

### Display overrides

The `display` block controls what the shop UI shows for a special:

```json
"display": {
  "text": "Gain: Brave",
  "texture": "Item_Notebook"
}
```

`text` is the label in the shop grid and the details panel. `texture` is the icon, given as
either a game texture name or a path relative to the mod.

If `display.texture` is omitted for an item special, the game icon for that item is used.

---

## 6. Conditions

File: `PhunMart_Conditions.json`

Named condition definitions. Referenced in offer `conditions` arrays and pool `defaults.conditions`.
A condition is a named test applied server-side at purchase time and client-side for UI feedback.

```json
{
  "minHours": {
    "test": "worldAgeHoursBetween",
    "args": { "min": 10 }
  },

  "lowCarpentry": {
    "test": "perkLevelBetween",
    "args": { "perk": "Woodwork", "min": 1, "max": 3 }
  },

  "onceOnly": {
    "test": "purchaseCountMax",
    "args": { "max": 1, "scope": "player_item_shop" }
  },

  "onlyCarpenters": {
    "test": "professionIn",
    "args": { "professions": ["carpenter"] }
  },

  "requiresNails": {
    "test": "hasItems",
    "args": { "items": [{ "item": "Base.Nails", "amount": 10 }] }
  }
}
```

In order: available only after 10 in-game hours; Woodwork between levels 1 and 3; one purchase
per player per shop per item across all sessions; a profession drawn from the list; and the
named items present in the player's inventory.

See [Reference: condition tests](#13-reference-condition-tests) for all available tests.

---

## 7. Items (Offers)

File: `PhunMart_Items.json`

Named offer definitions. These are the individual purchasable slots in a pool. Each offer
links a `price`, a `reward` (special key), and optional `conditions` and `offer` behaviour.

```json
{
  "offer:my_pistol": {
    "price": "currency_high",
    "reward": "reward_pistol",
    "offer": {
      "weight": 1.0
    }
  },

  "vehicle:SmallCar": {
    "price": "vehicle_common",
    "reward": "vehicle_smallcar",
    "offer": {
      "weight": 1.0,
      "stock": {
        "min": 0,
        "max": 1,
        "restockHours": 168
      }
    }
  },

  "offer:rare_sword": {
    "price": "currency_high",
    "reward": "reward_katana",
    "conditions": ["minHours", "onceOnly"],
    "offer": { "weight": 0.3 }
  }
}
```

`price` is a key from Prices and `reward` a key from Specials. `offer.weight` is the relative
probability during selection. The `restockHours` of 168 above is one in-game week. Every key
listed in `conditions` must pass.

**Key naming convention:** Items that belong to a logical type use a namespace prefix
(`offer:`, `vehicle:`, etc.) as a readability aid.

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

Pool sets on shops supply a default `price` that applies to all offers rolled from that set -- see [Shops](#10-shops). Groups can also set `defaults.price` for their items.

---

## 8. Groups

File: `PhunMart_Groups.json`

Groups define which game items or specials are eligible for a pool. For item-type shops the
preferred approach is to source by **category** rather than listing items individually. A
single category line like `"categories": ["Clothing"]` automatically covers every clothing
item in the game -- hundreds of items in one declaration. It's also mod-compatible: any mod
that adds items in that category gets included for free, with no config changes required.

Explicit `items` lists are for cases where you need precise control -- curated selections
that don't map cleanly to a single category, or vehicle script names which have no category
at all. Use categories as the default; fall back to explicit lists when you need to
hand-pick.

For non-item shops (traits, XP, boosts, vehicles), groups use `specialCategories` to pull
specials by their `category` field, or `specials` to include specific special keys directly.
For adding vehicles from another mod to WrentAWreck, see
[Adding a Modded Vehicle](GUIDE_ADDING_MODDED_VEHICLE.md).

```json
{
  "tools_general": {
    "defaults": {
      "price": "currency_mid",
      "offer": { "weight": 1.0 }
    },
    "categories": ["Tool", "ToolWeapon"]
  },

  "crafts_sewing": {
    "defaults": {
      "price": "currency_low",
      "offer": { "weight": 0.8 }
    },
    "items": ["Base.Scissors", "Base.Thread"]
  },

  "food_fresh": {
    "defaults": {
      "price": "currency_xlow",
      "offer": { "weight": 1.0 }
    },
    "categories": ["Food"],
    "blacklist": ["Base.Crisps", "Base.BeerBottle"],
    "blacklistCategories": ["Alcohol"]
  },

  "vehicles_small": {
    "label": "Small Cars",
    "fallbackTexture": "Item_CarKey",
    "defaults": {
      "price": "vehicle_common",
      "offer": { "weight": 1.0 }
    },
    "items": ["SmallCar", "SmallCar02", "CarTaxi"]
  },

  "traits_add": {
    "label": "Positive Traits",
    "fallbackTexture": "media/textures/icons/trait_add.png",
    "fallbackCategory": "Positive Traits",
    "specialCategories": ["trait_add"]
  }
}
```

`tools_general` is category-based and so covers every tool in the game, mods included.
`crafts_sewing` names its items explicitly. `food_fresh` takes a broad category and then
removes what it does not want: `blacklist` excludes individual item IDs and
`blacklistCategories` excludes whole sub-categories. `vehicles_small` overrides the icon and
category label shown in the shop UI. `traits_add` is a special-category group, wrapping
specials by their `category` field rather than listing game items.

### Group fields

| Field                   | Description                                                                  |
| ----------------------- | ---------------------------------------------------------------------------- |
| `defaults.price`        | Default price key applied to every item in this group                        |
| `defaults.offer.weight` | Default weight for items from this group                                     |
| `categories`            | Game display categories to include (item-type groups)                        |
| `items`                 | Explicit item full names to include (item-type groups)                       |
| `specialCategories`     | Special `category` values to include (non-item groups: traits, XP, vehicles) |
| `specials`              | Explicit special keys to include (non-item groups)                           |
| `blacklist`             | Item or special keys to exclude after inclusion                              |
| `blacklistCategories`   | Category names to exclude after inclusion                                    |
| `label`                 | Optional display label for this group in the UI                              |
| `fallbackTexture`       | Texture name used when an item has no icon                                   |
| `fallbackCategory`      | Category label shown in the shop details panel                               |

---

## 9. Pools

File: `PhunMart_Pools.json`

Pools control which groups contribute to a shop shelf. They don't set pricing or roll counts
-- those live on the pool set or shop (see [Shops](#10-shops)).

```json
{
  "pool_goodphoods": {
    "sources": {
      "groups": ["food_fresh", "food_cooking_utensils"]
    }
  },

  "pool_finalamendment_guns": {
    "zones": { "difficulty": [3, 4] },
    "sources": {
      "groups": ["weapons_firearms", "weapons_parts"]
    }
  }
}
```

`pool_finalamendment_guns` is zone-gated, appearing only in difficulty 3 and 4 zones, which
requires PhunZones.

| Field              | Description                                                                                                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sources.groups`   | Array of Group keys to pull items/specials from                                                                                                                   |
| `zones.difficulty` | Optional zone difficulty filter (0-5). Requires [PhunZones](https://github.com/PhunZoider/PhunZones). Checked at placement and restock. Omit for always-eligible. |

---

## 10. Shops

File: `PhunMart_Shops.json`

Shops bind a machine sprite to one or more pools via **pool sets**. Each pool set merges its
pools into one candidate list, then rolls a random subset.

```json
{
  "PittyTheTool": {
    "category": "Tool",
    "background": "machine-pity-the-tool.png",
    "sprites": ["phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27"],
    "unpoweredSprites": ["phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31"],
    "roll": { "mode": "weighted", "count": { "min": 5, "max": 8 } },
    "poolSets": [
      {
        "price": "currency_mid",
        "keys": [{ "key": "pool_pittythetool", "weight": 1.0 }]
      }
    ]
  },

  "BudgetXPerience": {
    "category": "XP",
    "defaultView": "list",
    "background": "machine-budget-xp.png",
    "sprites": ["phunmart_02_40", "phunmart_02_41", "phunmart_02_42", "phunmart_02_43"],
    "unpoweredSprites": ["phunmart_02_44", "phunmart_02_45", "phunmart_02_46", "phunmart_02_47"],
    "roll": { "mode": "weighted", "count": { "min": 4, "max": 8 } },
    "poolSets": [{
      "keys": [
        { "key": "pool_xp_budget", "weight": 1.0 },
        { "key": "pool_boost_budget", "weight": 0.5 },
        { "key": "pool_xp_gifted", "weight": 1.0 },
        { "key": "pool_boost_gifted", "weight": 0.5 }
      ]
    }]
  }
}
```

`PittyTheTool` is the simple case: one pool set, with the roll and price set at shop level.
`BudgetXPerience` is blended, putting several pools in *one* set so they merge into a single
menu. The weight on each key scales that pool's offer weights, which is why the boost pools at
`0.5` appear about half as often as the XP pools beside them.

### Shop fields

| Field              | Description                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------- |
| `category`         | Display category shown in admin tools                                                          |
| `background`       | PNG file name from `media/textures/` (no path prefix)                                          |
| `sprites`          | 4-element array of tile sprite names (E/S/W/N facing)                                          |
| `unpoweredSprites` | Sprite names shown when machine is unpowered                                                   |
| `defaultView`      | `"grid"` (default) or `"list"` -- layout mode for the shop UI                                  |
| `roll`             | Default roll: `{ mode = "weighted", count = { min = N, max = M } }`. Overridable per pool set. |
| `poolSets`         | Array of pool sets (see below)                                                                 |
| `probability`      | Placement weight (default `1`). Set to `0` to disable auto-placement.                          |
| `minDistance`      | Minimum tile gap from same shop type (overrides `DefaultDistance` sandbox setting)             |
| `restockFrequency` | In-game hours between restocks (overrides server default)                                      |

### Pool sets

Each pool set is an object with:

- `keys` -- array of `{ key, weight }` pool references
- `price` (optional) -- default price for all offers in this set
- `roll` (optional) -- override roll count for this set

**Price precedence:** `item price` > `group defaults.price` > `poolSet.price`.

**Roll fallback:** `poolSet.roll` > `shop.roll` > global default `{min=5, max=8}`.

**Multiple pool sets** = independent shelves (e.g. FinalAmendment has separate melee, ammo,
guns, explosives shelves with different roll counts). **Multiple keys in one set** = blended
menu (e.g. BudgetXPerience merges XP and boost pools into one selection).

---

## 11. Token Rewards

File: `PhunMart_TokenRewards.json`

Controls when players automatically receive currency. This file is loaded in full -- copy the
entire example file and edit it. It is not merged with defaults; your file replaces them.

```json
{
  "playtime": [
    { "atMinutes": 10, "rewards": [{ "item": "PhunMart.Token", "amount": 1 }] },
    { "atMinutes": 60, "rewards": [{ "item": "PhunMart.Token", "amount": 1 }] },
    { "atMinutes": 300, "rewards": [{ "item": "PhunMart.Token", "amount": 2 }] }
  ],

  "zombieKills": [
    { "kills": 100, "rewards": [{ "item": "PhunMart.Token", "amount": 1 }] },
    { "kills": 500, "rewards": [{ "item": "PhunMart.Token", "amount": 2 }] },
    { "kills": 1000, "rewards": [{ "item": "PhunMart.Token", "amount": 5 }] }
  ],

  "sprinterKills": [
    { "kills": 50, "rewards": [{ "item": "PhunMart.Token", "amount": 1 }] },
    { "kills": 200, "rewards": [{ "item": "PhunMart.Token", "amount": 3 }] }
  ]
}
```

Every milestone is one-time. `atMinutes` counts cumulative real-world minutes online, and the
kill milestones reset per wipe.

A milestone can hand over more than one thing, since `rewards` is an array:

```json
{ "atMinutes": 600, "rewards": [
  { "item": "PhunMart.Token", "amount": 5 },
  { "item": "Base.Katana", "amount": 1 }
]}
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

Exclude items from all shops via override file or in-game UI. See
[Blacklist items from all shops](#blacklist-items-from-all-shops) in Common admin tasks for
the override approach. In-game: open any shop as admin → Admin Tools → Pool Viewer →
right-click an item → **Add to blacklist**. Persists across restarts; set `blacklisted = false`
to re-enable.

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

```json
"actions": [{ "type": "giveItem", "item": "Base.BaseballBat", "amount": 1 }]
```

### `kind = "trait"` -- add or remove a trait

Add a positive trait:

```json
"actions": [{ "type": "addTrait", "trait": "base:brave" }]
```

Remove a negative one:

```json
"actions": [{ "type": "removeTrait", "trait": "base:slowlearner" }]
```

Trait keys follow the `base:<name>` format. Use `/dumppz traits` to list all trait keys.

### `kind = "skill"` -- grant XP to a perk

```json
"actions": [{ "type": "giveXP", "perk": "Cooking", "amount": 150 }]
```

### `kind = "boost"` -- apply a temporary XP multiplier

```json
"actions": [{ "type": "applyBoost", "perk": "Cooking", "multiplier": 2.0, "durationHours": 4 }]
```

### `kind = "vehicle"` -- spawn a vehicle

```json
"actions": [{
  "type": "spawnVehicle",
  "scripts": ["SmallCar", "SmallCar02"],
  "args": {
    "condition": { "min": 40, "max": 80 },
    "fuel": { "min": 0.2, "max": 0.6 }
  }
}]
```

One of the `scripts` is chosen at random. `condition` is a vehicle condition percentage and
`fuel` is a fuel level from 0 to 1.

Use `scripts` (array) to pick randomly from multiple variants, or `script` (string) for a single type.
Vehicle script names come from the game's vehicle script database -- use `/dumppz vehicles` to list them.

For a step-by-step walkthrough of adding vehicles from another mod, see
[Adding a Modded Vehicle](GUIDE_ADDING_MODDED_VEHICLE.md).

### `kind = "collector"` -- grant bound tokens

```json
"actions": [{ "type": "grantBoundTokens", "amount": 2 }]
```

Used by the Collectors machine. The displayed item IS the price (the player hands over
game items); the reward is bound tokens credited to both the current and death-restored
wallet pools. Collector offers use `kind = "self"` prices so the item icon shown in the
shop grid is the item the player must bring.

### `kind = "pawn"` -- credit change to the wallet

```json
"actions": [{ "type": "adjustBalance", "pool": "change", "amount": 500 }]
```

Used by the PrawnStars machine. Same flow as collectors -- the player hands over items
and receives currency in return. The `pool` field defaults to `"change"` but can be set
to `"tokens"` if needed. The `amount` is in cents (500 = $5.00). Like collectors, pawn
offers use `kind = "self"` prices.

---

## 15. Advanced: building a new shop from scratch

This walkthrough builds a small "Bob's Hardware" tool shop from nothing -- a new machine,
its own pool, a curated item group, prices, and one gated special offer. You'll touch all
seven override files.

### Step 1 -- Define prices

`PhunMart_Prices.json`

```json
{
  "tools_cheap": { "kind": "currency", "pool": "change", "amount": 50 },
  "tools_normal": { "kind": "currency", "pool": "change", "amount": 150 },
  "tools_pricey": { "kind": "currency", "pool": "change", "amount": 500 }
}
```

Amounts are in cents, so those are $0.50, $1.50 and $5.00.

### Step 2 -- Define a special (optional)

Only needed for non-item actions (trait grants, XP boosts, vehicle spawns). Regular items
sourced from a group don't need a special entry.

`PhunMart_Specials.json`

```json
{
  "reward_sledgehammer": {
    "kind": "item",
    "actions": [{ "type": "giveItem", "item": "Base.Sledgehammer", "amount": 1 }],
    "display": { "text": "Sledgehammer" }
  }
}
```

### Step 3 -- Define conditions (optional)

`PhunMart_Conditions.json`

```json
{
  "carpentryMid": {
    "test": "perkLevelBetween",
    "args": { "perk": "Carpentry", "min": 3 }
  }
}
```

### Step 4 -- Register the special as an offer

`PhunMart_Items.json`

```json
{
  "offer:sledgehammer_special": {
    "price": "tools_pricey",
    "reward": "reward_sledgehammer",
    "conditions": ["carpentryMid", "onceOnly"],
    "offer": { "weight": 0.5 }
  }
}
```

### Step 5 -- Define the item group

`PhunMart_Groups.json`

```json
{
  "bobs_tools": {
    "defaults": {
      "price": "tools_normal",
      "offer": { "weight": 1.0 }
    },
    "categories": ["Tool", "ToolWeapon"],
    "blacklistCategories": ["WeaponCrafted", "JunkWeapon", "InstrumentWeapon"]
  }
}
```

### Step 6 -- Define the pool

`PhunMart_Pools.json`

```json
{
  "pool_bobshardware": {
    "sources": {
      "groups": ["bobs_tools"]
    }
  }
}
```

### Step 7 -- Define the shop

`PhunMart_Shops.json`

```json
{
  "BobsHardware": {
    "category": "Tool",
    "background": "machine-hard-wear.png",
    "sprites": ["phunmart_01_24", "phunmart_01_25", "phunmart_01_26", "phunmart_01_27"],
    "unpoweredSprites": ["phunmart_01_28", "phunmart_01_29", "phunmart_01_30", "phunmart_01_31"],
    "roll": { "mode": "weighted", "count": { "min": 5, "max": 8 } },
    "poolSets": [
      {
        "price": "tools_normal",
        "keys": [{ "key": "pool_bobshardware", "weight": 1.0 }]
      }
    ]
  }
}
```

On server start the compiler reads all seven files, resolves references, and the shop is
live. Place a `BobsHardware` machine via the admin menu.
