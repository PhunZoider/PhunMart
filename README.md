# PhunMart

PhunMart transforms Zomboid vending machines into fully customizable shops. With PhunMart, you can sell items, perks, boosts, or even fast travel (with the [PhunMartPortKey](https://github.com/PhunZoider/PhunMartPortKey) addon). PhunMart is designed to be highly customizable yet easy to use, making it perfect for creating unique experiences for your community.

## Installation

1. **Subscribe via Steam Workshop:**

   - Subscribe to [PhunTools](https://steamcommunity.com/sharedfiles/filedetails/?id=3270421989).
   - Subscribe to [PhunMart](https://steamcommunity.com/sharedfiles/filedetails/?id=3270428943).

2. **Add to Your Config:**

   - Include PhunMart in your server configuration:
     - Mods=PhunTools,PhunMart
   - Include the WorkshopIds in your server configuration:
     - WorkshopItems=3270421989;3270428943

3. **Upload Custom Files:**
   - Upload the files from this repos [ServerFiles\Lua](ServerFiles/Lua) folder to your own servers `Lua` folder. These files allow full customization of shops and items.

## Customizing

There are 2 main areas for customizing: Items and Shops. Both are loaded into the system from files residing in the servers Lua folder in the following order:

1. **Item Definitions:**

   - Load `PhunMart_ItemDefs.ini` to determine which files to load.
   - Load each file listed (excluding commented files that start with a #) and transform contents into purchasable items.
   - Validate items (note any limitations).

2. **Shop Definitions:**
   - Load `PhunMart_ShopDefs.ini` to determine which files contain shop information.
   - Load each shop file (excluding commented files that start with a #) and transform each entry into a shop.

## Inheritance

To make managing hundreds (or thousands of items) easier, we use a simple type of "inheritance" for both items and shops. This means that an item (or shop) doesn't have to specify each of its own properties, it can simply "copy" another item and change whatever it needs to. This makes scaling out items and updating them much easier.

```
-- Define the base item
{
    abstract = true, -- this is only ever used to copy from
    key = "base-food:ing", -- a made up unique key
    inventory = {
        min = 2, -- we want between 2 and 5 items in stock
        max = 5
    },
    tab = "Misc", -- In the Misc tab
    tags = "food", -- for shop filtering
    price = {
        currency = { -- default to shop currency
            min = 1, -- between 1 currency
            max = 5 -- and 5
        }
    }
}, {
    name = "Base.Flour",
    inherits = "base-food:ing" -- copy base item
}, {
    name = "Base.Ramen",
    inherits = "base-food:ing" -- copy base item
}, {
    name = "Base.WildEggs",
    inherits = "base-food:ing", -- copy base item, but...
    tab = "Fresh" -- overwrite the "Misc" tab
}

```

## Item Customization

PhunMart supports a variety of item types. Each item type has specific properties that govern its display and purchase behavior.

## Types

A common property you will see in items is `type`. This governs how an item may be displayed to how it is purchased. The core system supports the following types:

| Key     | Description                                                          |
| ------- | -------------------------------------------------------------------- |
| ITEM    | An actual item. e.g., `Base.Sledgehammer` or `Base.Pencil`           |
| PERK    | XP for a skill, e.g., `Cooking` or `Fitness`                         |
| BOOST   | XP Boosts akin to reading books                                      |
| TRAIT   | Positive or Negative traits, e.g., `Smoker` or `All Thumbs`          |
| VEHICLE | A key that spawns a car when purchased                               |
| PORT    | Allows player to purchase fast travel (requires PhunMartPortKey mod) |

## Item Properties

Although most of the following properties are optional or have shortcuts to make management easier, here they are in their full glory

| Key           | Type                                    | Desc                                                                                                                                                                                                                               | Example                                                    |
| ------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `key`         | string                                  | If not set, PhunMart will try to generate one based on other values                                                                                                                                                                | `key="TRAIT:Pretty"`                                       |
| `abstract`    | bool                                    | If set, this is not a real item, it only serves as a template to create other items                                                                                                                                                | `abstract=true`                                            |
| `inherits`    | string                                  | Specifies the key of another item you want to use as a base. Allows for simplifying your configurations                                                                                                                            | `inherits="TRAIT:PrettyBase"`                              |
| `display`     | object                                  | See table below. Governs how the item is displayed to players browsing the shop                                                                                                                                                    | `display={label="Base.Pencil", type="ITEM"}`               |
| `tab`         | string                                  | Speficies the tab name that the item should appear under                                                                                                                                                                           | `tab="Drinks"`                                             |
| `probability` | number                                  | A number of 0-100 that determines the odds of this item being stocked. If omitted, the shops default probability is used.                                                                                                          | `probability=14`                                           |
| `mod`         | string                                  | A modId that is required to be active in order for this item to be added to the selection pool.                                                                                                                                    | `mod="TheyKnew"`                                           |
| `inventory`   | number \| table<min=number, max=number> | The amount made available during restocking. If min/max are given, it will randomly choose the amount using those two numbers                                                                                                      | `inventory={min=1, max=4}`                                 |
| `receive`     | object                                  | See Receive section below. What the player receives on successful purchase                                                                                                                                                         | `receive={{label="Base.Pencil", type="ITEM", quantity=1}}` |
| `conditions`  | object                                  | See Condition section below. The conditions that must pass in order for the player to be eligible to purchase the item                                                                                                             | `conditions={{price={["Base.Pencil"]=4}}}`                 |
| `enabled`     | bool                                    | If set to false, the item will not appear in the selection pool                                                                                                                                                                    | `enabled=true`                                             |
| `tags`        | string                                  | a CSV string of text to categorise the item. This can be used by shops to make list management much easier. eg tags=food,junk would enable a store to select the item regardless of if they wanted junk food or just general food. | `tags="food,junk"`                                         |
| `level`       | number                                  | Similar to tags, this field optionally provides a way for shops to differntiate items in a list. eg A shop in Louisville may only want to display T4 boosts, so it can filter its selection to Perks with level 4.                 | `level=4`                                                  |

### display

The display table expresses how we want to display the item in the shop. Most of the time, this will be the item we are selling
For example:

```
    display = {
        type = "TRAIT",
        overlay = "token-overlay",
        label = "AllThumbs"
    },
```

| Key           | Type                                                                                                                                                     | Desc                                                                                                                                                                                             | Example                    |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------- |
| `label`       | string                                                                                                                                                   | Depending on the type of item, the will be the way we source the tranlation for the player. In the case of an item, it may be Base.Sledgehammer. In the case of a trait, it could be Agoraphobic | `label="Base.Sledgehammer` |
| `labelExt`    | string                                                                                                                                                   | Used to differntiate between Sprinting I and Springing II                                                                                                                                        | `labelExt="II"`            |
| `type`        | string                                                                                                                                                   | How we want to display the item to the shopper                                                                                                                                                   | `type="ITEM"`              |
| `texture`     | string. Optional. The name of the texture to display                                                                                                     |
| `textureType` | string. Optional. Direct how we source the texture. eg. ITEM, PERK, TRAIT, etc..                                                                         |
| `overlay`     | string. Optional. The name of the texture in the textures folder to overlay the displayed image. This is used for the chevrons or plus images over perks |

### Receive

The `receive` property is an array of items/actions the player receives when a successful purchase has been made
For example:

```
    receive = {{
        type = "trait",
        name = "AllThumbs"
    }, {
        type = "item",
        name = "PhunMart.TraiterToken",
        quantity = 4
    }}

```

Would give the player the `AllThumbs` trait and 4 `PhunMart.TraiterTokens` when purchased. This allows the player to purcahse a crappy trait in exchange for more tokens they can use to buy good traits!

| Key        | Type   | Desc                                                                                                                                                                                             | Example               |
| ---------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------- | ----- | ------- | ----- | ------------------------------- | -------------- |
| `type`     | (item  | trait                                                                                                                                                                                            | perk                  | boost | vehicle | port) | Type of thing they will receive | `type="TRAIT"` |
| `label`    | string | Depending on the type of item, the will be the way we source the tranlation for the player. In the case of an item, it may be Base.Sledgehammer. In the case of a trait, it could be Agoraphobic | `label="AllThumbs"`   |
| `quantity` | number | Defaults to 1. This is the number of items they will get (which will be ignored by some types, like trait)                                                                                       | `quantity=4`          |
| `tag`      | string | For use with extending functionality                                                                                                                                                             | `tag="PORT"`          |
| `value`    | any    | Optional. For extending functionality                                                                                                                                                            | `value={x=1,y=2,z=0}` |

### Condition

A condition is a set of tests that must pass for the player to be able to make a purchase.
For example:

```
conditions={
    {
        skills={
            Strength=4,
            price={
                ["Base.Pencil] = 4
            }
        }
    }
}

```

| Key            | Type                                                     | Desc                                                                                                                                                                                                                                             | Example                              |
| -------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| `skills`       | table<string, number \| <table<min:number, max:number>>> | each key is a skill name and the level the player needs to be to qualify                                                                                                                                                                         | `skills={ Strength={min=4, max=6} }` |
| `boosts`       | table<string, bool>                                      | a key value pair of boosts that must be present (if true) or not present (if false). eg Strength=false would mean the player would fail the condition if they had a Strength boost active                                                        | `boosts={ Strength=true }`           |
| `traits`       | table<string, bool>                                      | a key value pair of traits that must be present (if true) or not present (if false). eg AllThumbs=false would mean the player would fail the condition if they had the AllThumbs trait                                                           | `traits={ Brave=false }`             |
| `professions`  | table<string, bool>                                      | a key value pair of professions that the player must be (if true) or not (if false). eg mechanics=false would mean the player would fail the condition if they were a mechanic, mechanics=true would require the player to be a mechanic to pass | `professions = { mechanics=true } }` |
| `maxLimit`     | number                                                   | The maximum time the player can purchase this item across all characters                                                                                                                                                                         | `maxLimit=3`                         |
| `maxCharLimit` | number                                                   | The maximum time the player can purchase this item per characters                                                                                                                                                                                | `maxCharLimit=3`                     |
| `minTime`      | number                                                   | The number of hours the player must have played for (across all characters) before being eligible to purchase                                                                                                                                    | `minTime=24`                         |
| `minCharTime`  | number                                                   | The number of hours the player must have played for on their current character before being eligible to purchase                                                                                                                                 | `minCharTime=24`                     |
| `price`        | table<string, number>                                    | A key value pair of the itemType=quantity. eg Base.Pencil=4 would require the player to have 4 pencils in their inventory to be eligible to purchase.                                                                                            | `price={ ["Base.Pencil]=4 }`         |

## Shop Properties

Although most of the following properties are optional or have shortcuts, here they all are in all their glory!

| Key               | Type                                    | Desc                                                                                                                                                             | Example                                 |
| ----------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| `key`             | string                                  | If not set, PhunMart will try to generate one based on other values                                                                                              | `key="SHOP:PHOOD"`                      |
| `abstract`        | bool                                    | If set, this is not a real item, it only serves as a template to create other items                                                                              | `abstract=true`                         |
| `inherits`        | string                                  | Specifies the key of another item you want to use as a base. Allows for simplifying your configurations                                                          | `inherits="SHOP:PHOODBase"`             |
| `probability`     | number                                  | A number of 0-100 that determines the odds of this shop being chosen. If omitted, default probability from settings is used.                                     | `probability=14`                        |
| `restock`         | number                                  | The number of game hours between restocking                                                                                                                      | `restock=24`                            |
| `fills`           | number \| table<min=number, max=number> | The number of items to be stocked during restocking process                                                                                                      | `fills={min=5, max=10}`                 |
| `backgroundImage` | string                                  | the name of a png in the textures folder that contains the backdrop for this shop                                                                                | `backgroundImage="machine-good-phoods"` |
| `layout`          | string                                  | the name of a layout to use for the shop. This isn't used yet                                                                                                    | `layout="DEFAULT"`                      |
| `pools`           | object                                  | see below                                                                                                                                                        |                                         |
| `methods`         | string                                  | method for calculating pool (not yet implemented)                                                                                                                |                                         |
| `zones`           | object                                  | see below                                                                                                                                                        |                                         |
| `currency`        | string                                  | The default currency for shop. Any item whose price uses the currency key will be overwritten with the shops currency.                                           | `currency=Base.Money`                   |
| `reservations`    | table<string>                           | an array of XYZ coords as a string in this format: X_Y_Z will reserve that location for that specific shop. Its a way of guranteeing that shop will be there!    | `reservations={"10021_12344_0"}`        |
| `enabled`         | bool                                    | If false, the shop won't be eligible to appear                                                                                                                   | `enabled=true`                          |
| `requiresPower`   | bool                                    | If true, the shop will require power to operate (depending on your settings)                                                                                     | `requiresPower=true`                    |
| `minDistance`     | number                                  | defaults to 100. The minimum distance the same shop can spawn. eg 100 means you must travel at least 100 squares before the shop will be eligible to spawn again | `minDistance=100`                       |

### pools

A pool is one or more tables of items. Currently, PhunMart will randomly pick one of the pools when restocking, however future plans are to make this more configurable (eg make a pool only appear during December and its full of christmas stuff). All shops will have at least one pool.
An example pools property:

```
    pools = {
        items = {{
            rolls = 7, -- we want 7 items
            filters = {
                tags = "food,fruit,drink", -- of one of these types
                files = "PhunMart_FoodItems.lua" -- that came from this file
            }
        }, {
            rolls = 6, -- we want 6 items
            filters = {
                tags = "veg,cooking,readytoeat", -- of one of these types
                files = "PhunMart_FoodItems.lua" -- from this file
            }
        }}
    }
```

The above would randomly choose between a selection of Food, Fruits and drinks or Veggies, Cooking items or Ready To Eat items. This helps give more of a "theme" when restocking.

pools.items

| Key       | Type                                    | Desc                                                                                                      | Example                             |
| --------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `keys`    | table<string>                           | an array of admin specified items OR filters that will be used to populate the pool of all possible items | `keys={"ITEM.hammer", "ITEM.nail"}` |
| `filters` | object                                  | see below                                                                                                 |                                     |
| `rolls`   | number \| table<min=number, max=number> | Number of items to roll (overrides top level fills). TODO: This should be changed to fills                | `rolls=4`                           |

### filters

A filter is a way of being able to dynamically select items for a pool without micro-managing it.

| Key     | Type   | Desc                                                                                                                                                                                                      | Example                         |
| ------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `tags`  | string | a CSV of tags to match with items. eg an item that has a tags property of "food,junk" will be eligible for this pool if its value is "drink,junk"                                                         | `tags="drink,junk"`             |
| `files` | string | a CSV of file names to draw items from. eg if the files value was "PhunMart_FoodItems.lua" then any item coming from that file will be eligible (as long as it matched the tags property should it exist) | `files="PhunMart_FoodItems.lua" |

### zones

The zones property limits selection of the shop based on where the shop is at. This requires the PhunZones mod to be active. This property ensures that we can have entry level items and boosts in Rosewood, but high level ones in say, Louisville.

| Key          | Type          | Desc                                                                                   | Example                            |
| ------------ | ------------- | -------------------------------------------------------------------------------------- | ---------------------------------- |
| `difficulty` | number        | If set, this shop will only be eligible to appear in a zone with a matching difficulty | `difficulty=3`                     |
| `keys`       | table<string> | a list of keys where this shop is eligible to appear (under development)               | `keys={"MarchRidge", "Riverwood"}` |
