# PhunMart: Extending It From Another Mod

PhunMart can be extended by a separate mod, without editing PhunMart and without a fork. A
mod that does this declares `require=phunmart2` in its `mod.info`, loads after PhunMart, and
registers what it wants through the tables and functions below.

This is how [Phlea Market](https://github.com/PhunZoider/PhleaMarket) is built: its own
repository, its own Workshop item, its own tile pack, and roughly forty lines of contact
with PhunMart in total.

> Everything here is registered at **load time**, from your mod's `shared` folder. That is
> the window it has to happen in: the first two are read when definitions compile, and the
> rest when a shop window or the admin shell first opens. A mod's shared files load well
> before any of that.

---

## Table of Contents

- [A machine of your own](#a-machine-of-your-own)
- [Keeping your own flags](#keeping-your-own-flags)
- [A machine that stocks nothing](#a-machine-that-stocks-nothing)
- [Modes: giving the shop window another job](#modes-giving-the-shop-window-another-job)
- [A tab in the admin window](#a-tab-in-the-admin-window)
- [Register once](#register-once)

---

## A machine of your own

`Core.defaultPaths` maps each kind of definition to the modules it is built from.
`compileWith` reads it at compile time, which is long after every mod has loaded, so
appending to it is enough to have your shop compiled and placed alongside the sixteen
PhunMart ships.

```lua
table.insert(PhunMart.defaultPaths.shops, "YourMod/defaults/shops")
```

Your file returns a table keyed by shop name, in the same shape as
`PhunMart/defaults/shops`:

```lua
return {
    YourShop = {
        probability = 5,
        minDistance = 500,
        category = "YourShop",
        powered = true,
        background = "machine-yourshop.png",
        sprites          = {"yourshop_01_0", "yourshop_01_1", "yourshop_01_2", "yourshop_01_3"},
        unpoweredSprites = {"yourshop_01_4", "yourshop_01_5", "yourshop_01_6", "yourshop_01_7"},
        poolSets = { ... }
    }
}
```

The same works for `pools`, `groups`, `items`, `prices`, `specials` and `conditionsDefs`.

Sprites come from your own tile pack, declared in your `mod.info` with `pack=` and
`tiledef=`. Pick a tiledef index that collides with nothing else installed. Sprite names are
global once a pack loads, so you *can* reference PhunMart's, but then your machine's art
ships from a repository you do not own and the two have to be versioned together to change
a sprite.

The background is an ordinary texture and needs no pack: `shopDef.background` resolves
against `media/textures/`, which merges across mods.

---

## Keeping your own flags

The compiler does not copy a shop definition into the runtime. It builds a new table from an
explicit list of field names, which is what keeps a compiled shop small and stops an admin
override smuggling arbitrary keys into it.

That means **a flag your mod invents is dropped** between the definition that declared it
and anything that reads it, silently, leaving no evidence beyond a condition that never
fires.

```lua
table.insert(PhunMart.shopDefPassthrough, "yourFlag")
```

Named there, `yourFlag` survives compilation and travels on to the client in the shop
payload, which is the only route the shop window has to a definition. Passthrough copies
never overwrite a field the compiler names itself.

---

## A machine that stocks nothing

Placement asks whether a shop has at least one pool that passes the zone filter where it is
about to stand. A shop with no `poolSets` correctly answers no, and that test applies even
when an admin forces placement, so such a machine can never be placed at all.

If your machine fills its shelves from somewhere other than a pool, say so:

```lua
YourShop = {
    stocksNothing = true,
    poolSets = {},
    ...
}
```

That also removes the base **Buy** mode from the window, since there is nothing of the
shop's own to buy. Register a mode that knows how to show what is really in it.

> Do not use `enabled = false` to keep a machine out of the world conditionally. A disabled
> definition is dropped from the runtime entirely, and machines already standing do not go
> with it: they stay exactly where they are with nothing behind them, losing their
> background, their modes and their stock. Use `probability = 0` instead, which keeps a
> machine out of new placement while leaving the placed ones intact.

---

## Modes: giving the shop window another job

Every machine PhunMart ships has one job, so the window never had to say which one it was
doing. A machine that also takes goods in has more than one, and the player has to be able
to choose. Modes are that choice, drawn as a strip along the bottom of the machine's banner.

The strip appears only when two or more modes apply, so a machine with one mode looks
exactly as it always has.

```lua
PhunMart.registerShopMode({
    key = "sell",
    label = "IGUI_YourMod_Sell",
    order = 20,
    flag = "yourFlag",

    onEnter = function(ui) end,
    onExit = function(ui) end,

    getGridData = function(ui) return yourPayload end,
    actionLabel = function(ui, offer) return getText("IGUI_YourMod_List") end,
    canAction = function(ui, offer, id) return id ~= nil end,
    onAction = function(ui) end,

    createFilter = function(ui, x, y, w, h) return {someWidget} end,
    onActivate = function(ui, id, offer, entry) end,
    detailLines = function(ui, offer) return {{text = "..."}} end
})
```

### Scoping

`flag` names a field on the shop payload that must be truthy for the mode to appear, which
is the usual way to scope a mode to your machine. It has to be one you named in
`shopDefPassthrough`, or it will not be there to test. `applies(data)` is available for
anything a flag cannot express. Declaring neither puts your mode on **every machine in the
game**, which is what the base Buy mode wants and almost certainly not what yours does.

`order` places it in the strip. Buy is at 10.

### Drawing

`getGridData(ui)` returns whatever the item grid should render: a table with an `offers` map
keyed by id, each entry carrying `item`, `price` and `offer.stockQty`. Projecting your own
data into that shape gets you icons, categories, tooltips, scrolling and the two view modes
for free.

`detailLines(ui, offer)` adds lines to the details pane, drawn among the price and the
stock. Useful when the figures above are true but incomplete, such as a tile standing for
several listings where the price shown is the lowest rather than the price.

### Acting

`actionLabel`, `canAction` and `onAction` own the big button at the bottom right.

`onActivate` answers a double click on a tile. There is no default behaviour: a double click
that buys would turn a slip of the hand into a purchase, so a mode that has somewhere to go
has to say so. Selection always fires first, so activation acts on the tile under the
cursor.

### The filter strip

`createFilter(ui, x, y, w, h)` claims a strip along the top of the glass, above the item
grid, and the grid gives up that height. Return a list of already initialised UI elements
and the window will place them and own their lifetime, rebuilding them whenever the mode
changes.

This is where controls that narrow hundreds of rows belong. Filter on the client against
data you already hold: a search that goes back to the server on every keystroke is unusable
at any latency.

---

## A tab in the admin window

`admin_shell.lua` holds eleven tabs of its own, and yours slots in among them.

```lua
PhunMart.registerAdminTab({
    key = "yourmod_things",
    module = "yourmod_things",
    label = "IGUI_YourMod_Tab",
    order = 95
})
```

`module` is a key on `PhunMart.ui`, not the panel itself. The shell resolves it when the
window opens rather than when the list is built, so your panel can register itself later:

```lua
PhunMart.ui.yourmod_things = ListPanel:derive("YourModThings")
```

Your panel derives from `PhunMart_Client/ui/base/list_panel`, which brings sorting,
filtering, the button bar and row drawing. It needs a `createTab(player)` returning the
instance, and usually `requestData`, `setData`, `refreshList` and `getFilterText`.

Two things about that base worth knowing, because both are opt in:

- **Sorting is per column.** A column only sorts if its definition carries `sort`. Pass
  `sort = true` to sort on the displayed field, or `sort = function(data) ... end` to sort on
  something else. Columns showing formatted text (money, counts, relative times) need the
  function form, or `9` sorts after `10` and `$1.00` after `$0.05`.
- **The filter box searches `getFilterText(itemData)`.** Without an override it falls back to
  the row's display text, which is effectively the first column alone.

Shipped tabs are spaced ten apart so you can sit between any two without renumbering. Tools
sits far out at 1000 so it stays last.

---

## Register once

The game loads a mod's shared files itself, and other files in your mod may also `require`
the same file. Those are two different caches, so one file can execute twice in a session.
Harmless for a function definition, not harmless for a list you append to:

```lua
local function registerOnce(list, value)
    for _, existing in ipairs(list) do
        if existing == value then return end
    end
    table.insert(list, value)
end

registerOnce(PhunMart.defaultPaths.shops, "YourMod/defaults/shops")
registerOnce(PhunMart.shopDefPassthrough, "yourFlag")
```

`registerShopMode` and `registerAdminTab` replace by key, so they are already safe to call
more than once. Re-registering a shipped key is also how you would replace one of PhunMart's
own screens or modes, which is deliberate: it has to be said explicitly rather than
happening by accident.

---

## Sandbox settings

Your options go in your own `sandbox-options.txt`, on your own page. They are read by name,
so nothing stops you reading them with your own one line helper:

```lua
function YourMod.getOption(name, default)
    local options = getSandboxOptions()
    local option = options and options:getOptionByName("YourMod." .. name)
    local value = option and option:getValue()
    if value == nil then return default end
    return value
end
```

Do not declare options under PhunMart's prefix or on its page. An admin looking for your
mod's settings should find them under your mod's name.

Sandbox enums hand back the ordinal rather than the label, so a read is a bare `1` or `2`.
Name them once rather than comparing to numbers throughout.
