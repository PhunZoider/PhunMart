# PhunMart: Using an Item as Currency

By default PhunMart prices things in its own currency, **change**, held in a wallet. If you
would rather charge in something players loot, like `Base.Money`, `Base.Nails` or
`Base.Jewels`, that is one change to one price definition and the whole shop system follows.

---

## The easy way: the Currency tool

1. Open the Admin Panel and click `** PhunMart **`, then go to the **Tools** tab.
2. Select **Change the currency** and click **Open**.
3. Set **Pay with** to `An item players carry`.
4. Click **Pick...** next to **Item** and choose your item, for example `Base.Money`.
5. Adjust **Scale by** until the preview reads sensibly.
6. **Apply**.

![Edit currency_base](https://github.com/PhunZoider/PhunMart/blob/main/Docs/images/ChangeToBaseMoney.png)

The dialog lists every price the change will touch, with what it costs now beside what it will
cost after, updating as you type. That table is the point of the tool: picking a scale factor
used to mean working it out on paper.

The tool also grows a **Reset to default** button once you have changed anything, which removes
your override and restores the shipped currency exactly.

> Prices update when a machine restocks, not immediately. The Tools tab will list the affected
> machines under **Pending restocks**, and **Restock every machine** applies the change
> everywhere at once.

---

## How it works

Most built-in prices inherit from `currency_base`, which ships as:

```json
"currency_base": { "kind": "currency", "pool": "change", "amount": 1, "factor": 1 }
```

Children like `currency_25` and `currency_150` take their `kind`, `pool` and `factor` from it
and override only `amount`. Changing `currency_base` to `"kind": "items"` therefore flips the
entire tree in one step: every child becomes an item cost rather than a wallet deduction.

### The factor property

`factor` is an optional multiplier, default 1, applied to every amount in a price entry after
inheritance resolves. The compiler works it out as `ceil(amount * factor)`, never less than 1.

This is what makes item currency usable. The child amounts were written as cents: 25, 50, 250,
500. Taken literally as item counts, a mid-range tool would cost 500 of something. Rather than
overriding every child, set one factor on the base and scale the whole ladder:

| Child key      | amount | factor | Result (`ceil(amount * factor)`) |
| -------------- | ------ | ------ | -------------------------------- |
| `currency_05`  | 5      | 0.04   | 1                                |
| `currency_25`  | 25     | 0.04   | 1                                |
| `currency_50`  | 50     | 0.04   | 2                                |
| `currency_100` | 100    | 0.04   | 4                                |
| `currency_250` | 250    | 0.04   | 10                               |
| `currency_500` | 500    | 0.04   | 20                               |

A child may set its own `factor`, which replaces the parent's rather than compounding with it.

---

## Doing it in a file instead

Create or edit `PhunMart_Prices.json` in your server's `Zomboid/Lua/` folder:

```json
{
  "currency_base": {
    "kind": "items",
    "items": [{ "item": "Base.Money", "amount": 1 }],
    "factor": 0.04
  }
}
```

Every child that inherits from it picks up the new `kind` and `factor` automatically.

### Overriding individual children

Only needed when a child should deviate from the factor-scaled result. To make `currency_25`
cost exactly 3 rather than `ceil(25 * 0.04) = 1`:

```json
{
  "currency_base": {
    "kind": "items",
    "items": [{ "item": "Base.Money", "amount": 1 }],
    "factor": 0.04
  },

  "currency_25": { "inherit": "currency_base", "amount": 3, "factor": 1 }
}
```

The `currency_25` entry overrides just that one child.

`factor = 1` on the child stops the parent's 0.04 scaling the explicit 3 down to 1.

---

## Things to keep in mind

- **The change wallet becomes decorative.** With `kind = "items"` the system checks inventory
  instead of the wallet, so the balance in the character panel no longer buys anything. Turn
  the pool off entirely with the **EnableChangePool** sandbox setting.

- **Token prices are unaffected.** Prices using `pool = "tokens"` inherit from `token_base`,
  not `currency_base`, so token-priced shops such as TraiterJoes carry on as before. Switch
  those separately by editing `token_base` if you want to.

- **Self-pay prices are unaffected too.** The Collectors and PrawnStars machines price offers
  as `kind = "self"`, meaning the displayed item is what the player hands over. Those never
  touch `currency_base`.

- **Milestone rewards are separate.** The playtime and kill rewards under the Rewards tab
  hand out whatever item they name, and they do not follow `currency_base`. The shipped
  entries pay `PhunMart.Token`, which is credited to the token wallet rather than spawned.
  To pay milestones in your new currency, edit each entry to name that item: any item that
  is not one of PhunMart's own coins or tokens is spawned into the player's bag.

- **Phlea Market keeps its own prices.** Player-to-player listings are priced in change by
  the seller at listing time, not from the `prices` table, so switching `currency_base` does
  not reach them. Running both means running two currencies side by side. If you are moving
  the server to an item currency, turn Phlea Market off.

- **Any stackable item works.** `Base.Money` is the usual pick because players find it while
  looting, but nails, ammunition or anything else will do. The item picker lists everything
  registered in the game, mods included.

- **Substitutes.** To let colour or style variants count as equivalent payment, add a
  `substitutes` array to the item line. See
  [Substitutes](CUSTOMISATION.md#substitutes) in the customisation guide.
