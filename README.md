# PhunMart

A Project Zomboid (B42) mod that converts vanilla vending machines into 16 themed automated
shops — dispensing food, gear, weapons, vehicles, skill books, traits, XP boosts, and more.
Stock rotates on a timer. Coins come from scavenging. Tokens come from surviving.

Shops source from the game's item catalogue by category, so **modded items show up
automatically** — no config needed. Right-click a machine, browse the shop UI, and buy with
**change** (coins found as loot) or **tokens** (earned through milestones and trade-ins).
Admins can place machines manually and override every aspect of the system through Lua files.

> **Requires:** Project Zomboid Build 42.15+ (singleplayer or multiplayer)
> **Optional:** [PhunZones](https://github.com/PhunZoider/PhunZones) — zone-difficulty filtering on shop pools

![Shop in the apocolypse](Docs/images/shopping.png)

---

## The Shops

| Shop                  | Category      | Rarity | What's inside                                                                                       |
| --------------------- | ------------- | ------ | --------------------------------------------------------------------------------------------------- |
| **GoodPhoods**        | Food          | Common | Fresh produce, packaged food, and cooking gear. Cheap, cheerful, and always stocked.                |
| **PittyTheTool**      | Tools         | Common | Hand tools, utility gear, and the odd weapon-adjacent implement.                                    |
| **MichellesCrafts**   | Crafts        | Common | Sewing kits, thread, needles, and assorted craft supplies for the fashion-conscious survivor.       |
| **CarAParts**         | Vehicle Parts | Common | Mechanical spares, fluids, and components to keep your ride alive.                                  |
| **CSVPharmacy**       | Medical       | Common | Bandages and basics up front; antibiotics and rare pharmaceuticals at the back.                     |
| **RadioHacks**        | Electronics   | Common | Walkie-talkies, batteries, circuitry — if it runs on volts, it's probably here.                     |
| **Phish4U**           | Fishing       | Common | Rods, tackle, lures, and bait. Someone kept this thing restocked.                                   |
| **HoesNMoes**         | Gardening     | Common | Seeds, fertiliser, farming tools. Plan for next season.                                             |
| **HardWear**          | Clothing      | Common | Civilian clothing at standard weight; military and protective gear at lower odds.                   |
| **ShedsAndCommoners** | Literature    | Common | All 125 skill books across 25 B42 skills, sorted by volume tier.                                    |
| **FinalAmendment**    | Weapons       | Rare   | Firearms, ammunition, and explosives. Rare, spread out, and worth hunting down.                     |
| **WrentAWreck**       | Vehicles      | Rare   | Order a car. It spawns nearby. Budget, standard, and premium tiers. Restocks weekly.                |
| **TraiterJoes**       | Traits        | Rare   | Spend tokens to gain positive traits or remove negative ones. The rarest machine in the world.      |
| **BudgetXPerience**   | XP / Boosts   | Rare   | Direct skill XP grants and temporary XP multipliers, tiered by power.                               |
| **Collectors**        | Trade-in      | Rare   | Bring your mementos and collectibles. Trade them in for bound tokens. The more obscure, the better. |
| **PrawnStars**        | Pawn          | Rare   | Sell jewellery and valuables for change. Five payout tiers from budget ($1) to jackpot ($50).       |

**Common** shops have a 15-in-15 base probability weight and no minimum spacing.
**Rare** shops have lower probability weights (5–8) and a minimum tile distance (300–500 tiles)
from other machines of the same type.

---

## Currency

PhunMart uses two separate wallets:

### Change (loose coin)

- Found as loot throughout the world — **Nickel** (5¢), **Dime** (10¢), **Quarter** (25¢)
- Stored as a cents balance (integer). Cap: **$99.99** by default (configurable)
- Used for everyday purchases: food, tools, medical, clothing, books
- On death, the player drops a wallet containing their coins that only they can pick up
  (configurable return rate via sandbox settings)

### Tokens (bound)

- **Not found as loot** — earned only through milestones and the Collectors machine
- Bound to the account — survive character death
- Cap: **60 tokens** by default (configurable)
- Used for high-value purchases, specifically traits

The wallet balance is shown in the shop UI so players always know what they can afford.
Machines that require tokens display the current balance alongside the requirement.

---

## Earning Tokens

Tokens are earned two ways:

### One-time milestones

Awarded automatically when thresholds are crossed — no player action required.

| Milestone                    | Reward              |
| ---------------------------- | ------------------- |
| Playtime: first hour online  | Tokens              |
| Playtime: 5 hours, 10 hours  | Tokens (increasing) |
| Zombie kills: 100, 500, 1000 | Tokens (increasing) |
| Sprinter kills: 50, 200      | Tokens              |

Exact amounts are configurable — see [Customisation Guide](Docs/CUSTOMISATION.md#11-token-rewards) (player rewards).

### Collectors machine (repeatable)

Bring collectible items (toys, antiques, mementos) to a Collectors machine and trade them in
for bound tokens. Rarer items pay more — from 1 token per 3 common items up to 3 tokens for
a legendary find. The selection rotates each restock.

---

## Server Setup

### Installation

1. Subscribe on Steam Workshop (or install manually into `mods/`)
2. Enable **PhunMart2** in your server mod list
3. Start the server — machines will convert automatically on first load

### Sandbox Options

Key settings available in `sandbox-options.txt` or the server sandbox editor:

| Option                  | Default        | Description                                                                                      |
| ----------------------- | -------------- | ------------------------------------------------------------------------------------------------ |
| `ChanceToConvert`       | 80%            | Global % chance to convert a vanilla vending machine                                             |
| `DefaultDistance`       | 200 tiles      | Default minimum tile gap between any two machines                                                |
| `ChangeCapCents`        | 9999 (=$99.99) | Maximum change balance per player                                                                |
| `TokenCap`              | 60             | Maximum token balance per player                                                                 |
| `DropOnDeath`           | true           | Whether the player drops a wallet item on death                                                  |
| `OnlyPickupOwn`         | true           | Whether only the owner can pick up their dropped wallet                                          |
| `ReturnRate`            | 100            | % of change returned in the dropped wallet (100 = full, 0 = nothing)                             |
| `DefaultHoursToRestock` | 72             | Default in-game hours between shop restocks (3 days); per-shop `restockFrequency` overrides this |

### Admin Commands

- `/dumppz all` — dumps perks, traits, items, vehicles to a Lua file for reference
- `/dumppz perks` / `traits` / `items` / `vehicles` — individual dumps

Admins can also place machines manually via the in-game Items List.

### Optional: PhunZones integration

If [PhunZones](https://github.com/PhunZoider/PhunZones) is installed, shop pools can be
filtered by zone difficulty (1–5). For example, the WrentAWreck budget pool appears only in
difficulty 1–2 zones, and the premium pool only in 4–5. Shops in unzoned areas remain
permissive and show all pools.

---

## Customisation

Everything is data-driven and overridable without touching the mod. Drop override files into
your server's `Zomboid/Lua/` folder to patch prices, pools, shops, conditions, and token
rewards on top of the built-in defaults.

Full reference: **[Docs/CUSTOMISATION.md](Docs/CUSTOMISATION.md)** — common admin recipes,
deep-merge rules, condition tests, special kinds, and a complete shop-from-scratch walkthrough.

---

## Compatibility

Build 42 only. Works in singleplayer and multiplayer. Mod-compatible by design — item shops
source by category, so modded items appear automatically. No known conflicts; please
[report issues on GitHub](https://github.com/PhunZoider/PhunMart/issues).

---

## Links

- [GitHub Repository](https://github.com/PhunZoider/PhunMart)
- [Customisation Guide](Docs/CUSTOMISATION.md)
- [Issue Tracker](https://github.com/PhunZoider/PhunMart/issues)
