return {{
    abstract = true,
    key = "base-collectors",
    tab = "Items",
    tags = "collectables",
    inventory = {
        min = 1,
        max = 2
    }
}, {
    key = "base-collectors-scrap-gold",
    tab = "Scraps",
    tags = "scrap-gold",
    inventory = false,
    price = {
        ["Base.GoldScraps"] = 20
    },
    mod = "PhunStuff",
    recieve = {{
        label = "PhunMart.CheeseToken"
    }}
}, {
    key = "base-collectors-scrap-silver",
    tab = "Scraps",
    tags = "scrap-silver",
    inventory = false,
    price = {
        ["Base.SilverScraps"] = 10
    },
    mod = "PhunStuff",
    recieve = {{
        label = "PhunMart.SilverDollar"
    }}
}, {
    key = "base-collectors-scrap-gems",
    tab = "Scraps",
    tags = "scrap-gems",
    inventory = false,
    price = {
        ["Base.GemScrap"] = 50
    },
    mod = "PhunStuff",
    recieve = {{
        label = "PhunMart.TraiterToken"
    }}
}}
