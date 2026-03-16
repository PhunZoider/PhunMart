# PhunMart - Using an Item as Currency

By default PhunMart uses its own currency called **change** to price items.
If you'd rather price everything in a physical inventory item like `Base.Money`, `Base.Nails`, `Base.Jewels`
or anything else players can loot — you can do that with a single edit to the base price.

---

## Step-by-step example: Use Base.Money as main currency

1. Open the shop admin window by clicking the `PhunMart` button on the Admin Panel or Debug Panel. There you can click **Admin Tools** (bottom-left).
2. Click **Prices** to open the price definitions list.
3. Find and select **`currency_base`**, then click **Edit** (or double-click the row).
4. In the edit modal, change the following fields:

   | Field      | Set to                                                                 |
   | ---------- | ---------------------------------------------------------------------- |
   | **Kind**   | `items`                                                                |
   | **Amount** | `1` (or whatever base quantity you want)                               |
   | **Items**  | Click **Pick...** and select the item (e.g. `Base.Money`)              |
   | **Factor** | A scaling multiplier (e.g. `0.04`) — see [below](#the-factor-property) |

   Leave **Inherit** blank.

   ![Edit currency_base](https://github.com/PhunZoider/PhunMart/blob/main/Docs/images/ChangeToBaseMoney.png)

5. Click **Apply**.

That's it. Every price that inherits from `currency_base` now costs N of your chosen item
instead of N cents from the wallet. The factor scales the inherited `amount` values down to
reasonable item counts — `currency_50` with `amount = 50` and `factor = 0.04` resolves to
`ceil(50 * 0.04) = 2` of `Base.Money`.

> Note: Changes will only come into effect when the shop restocks. Click Restock All option from the admin window

---

## How it all works

Most of the built-in prices inherit from `currency_base`. That key ships as:

```lua
currency_base = { kind = "currency", pool = "change", amount = 1, factor = 1 }
```

Child prices like `currency_25`, `currency_50`, `currency_150` etc. inherit the `kind`,
`pool`, and `factor` from `currency_base` and override only the `amount`. Changing
`currency_base` to `kind = "items"` flips the entire inheritance tree in one step — every
child price becomes an item-barter cost instead of a wallet deduction.

---

## Override file

If you prefer to set this up outside the game, create or edit `PhunMart_Prices.lua` in your
server's `Zomboid/Lua/` folder:

```lua
return {
    currency_base = {
        kind   = "items",
        items  = {{ item = "Base.Money", amount = 1 }},
        factor = 0.04
    },
}
```

Child prices that inherit from `currency_base` will pick up the new `kind` and `factor`
automatically. The child's `amount` (e.g. 25 for `currency_25`) is multiplied by the
inherited factor to produce the final item count.

### Overriding individual children

You only need to override a child if you want it to deviate from the factor-scaled result.
For example, if `currency_25` should cost exactly 3 instead of `ceil(25 * 0.04) = 1`:

```lua
return {
    currency_base = {
        kind   = "items",
        items  = {{ item = "Base.Money", amount = 1 }},
        factor = 0.04
    },

    -- Override just this one child
    currency_25 = { inherit = "currency_base", amount = 3, factor = 1 },
}
```

Setting `factor = 1` on the child prevents the parent's 0.04 from scaling the explicit
amount of 3.

---

## The factor property

`factor` is an optional multiplier (default 1) that scales all amounts in a price entry
after inheritance resolves. The compiler applies it as `math.ceil(amount * factor)` with a
minimum of 1.

This is the key to making item-based currency work cleanly. The built-in children have
`amount` values designed for cents (25, 50, 150, 500…). When you switch to items, those raw
amounts would mean "25 of Base.Money" — far too expensive. Instead of overriding every
child, you set a `factor` on `currency_base` that scales the whole tree down to sensible
item quantities:

| Child key      | amount | factor | Result (`ceil(amount * factor)`) |
| -------------- | ------ | ------ | -------------------------------- |
| `currency_05`  | 5      | 0.04   | 1                                |
| `currency_25`  | 25     | 0.04   | 1                                |
| `currency_50`  | 50     | 0.04   | 2                                |
| `currency_100` | 100    | 0.04   | 4                                |
| `currency_250` | 250    | 0.04   | 10                               |
| `currency_500` | 500    | 0.04   | 20                               |

A child can override `factor` on itself to deviate from the base — the child's factor
replaces the parent's (no compounding).

---

## Things to keep in mind

- **Wallet UI:** The player's change wallet balance (shown in the character panel) becomes
  irrelevant when prices use `kind = "items"` — the system checks inventory instead. You
  may want to disable the change pool entirely via the **EnableChangePool** sandbox setting.

- **Token prices are unaffected.** Prices with `pool = "tokens"` use a separate system and
  don't inherit from `currency_base`. Token-priced shops (like the Collectors machine)
  continue to work as before.

- **Any item works.** `Base.Money` is a common choice because players find cash while looting,
  but you could use `Base.Nails`, `Base.Bullets9mm`, or any other stackable item. The item
  picker in the admin editor shows every item registered in the game.

- **Substitutes.** If you want colour or style variants to count as equivalent payment, add a
  `substitutes` array to the item line. See the
  [Substitutes section](CUSTOMISATION.md#substitutes) in the main customisation guide.
