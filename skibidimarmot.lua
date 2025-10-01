setfpscap(3)  -- number = fps

getgenv().bgsInfConfig = {
    ADD_FRIEND = true,
    AUTO_UPDATE_RESTART = true,
    FOCUS_DICE = false,
    SUPER_TICKET_MINIGAME = "",
    GIVE_BUBBLE_SHRINE = {"Coins", "Tickets"},
    MIN_GIVE_BUBBLE_SHRINE = 1000,
    MASTERY_BUFFS_LEVEL = 20, 
    ENCHANT_HIGH_ROLLER = false,

    PURCHASE_ALIENSHOP = true,
    PURCHASE_BLACKMARKET = true,
    PURCHASE_DICE_MERCHANT = true,
    PURCHASE_TRAVELING_MERCHANT = true,
    PURCHASE_STARSHOP_SLOT = 14,
    RESTOCK_SHOP = "Festival Shop",

    USE_ROYAL_KEY = true,
    USE_DICE_KEY = true,
    USE_SUPER_KEY = true,
    USE_MYSTERY_BOX = true,

    RARITY_TO_DELETE = {"Common", "Unique", "Rare", "Epic", "Legendary"},
    RARITY_TO_SHINY = {"Common", "Unique", "Rare", "Epic", "Legendary"},
    MAX_LEGENDARY_TIER_TO_DELETE = 2,  -- (DO NOT Delete Tier 3+ shiny & mythic, use PETS_TO_DELETE instead)
    DELETE_LEGENDARY_SHINY = true,
    DELETE_LEGENDARY_MYTHIC = true,

    ENCHANT_TEAMUP = false,
    ENCHANT_TEAMUP_TIER = 3,

    AUTO_BOUNTY_RIFT = true,
    MIN_RIFT_MULTIPLIER = 1,
    RIFT_EGGS = {"Brainrot Egg", "Bee Egg"},
    HATCH_1X_EGG = {"Classic Egg"},
    ALWAYS_INFINITY_ELIXIR = true,
    ALWAYS_EGG_ELIXIR = true,
    ALWAYS_SECRET_ELIXIR = true,

    IGNORE_SEASON_CHALLENGES = true,
    IGNORE_EQUIP_BEST_PET = true,

    WEBHOOK_URL = "https://discord.com/api/webhooks/1217192873611628616/_idFM4Mk1Si7McZI_Z_B-Sn_6JIuBDRDsA7a2e4Q895U4IxyDBIoc9yGwA6ot5S21NIb",
    DISCORD_ID = "324553736053719040",
    WEBHOOK_NOTE = "skibidi",
    WEBHOOK_ODDS = "1m",
    SHOW_PET_WEBHOOK_USERNAME = true,
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/e1f274825da00b92599872de596f1fc0.lua"))()
