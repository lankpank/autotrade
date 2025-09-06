setfpscap(3)  -- number = fps

getgenv().bgsInfConfig = {
    ADD_FRIEND = true,
    AUTO_UPDATE_RESTART = true,
    FOCUS_DICE = false,
    SUPER_TICKET_MINIGAME = "",
    GIVE_BUBBLE_SHRINE = {"Coins", "Tickets"},
    MIN_GIVE_BUBBLE_SHRINE = 1000,
    MASTERY_BUFFS_LEVEL = 20, 
    ENCHANT_HIGH_ROLLER = true,

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
    MIN_RIFT_MULTIPLIER = 10,
    HATCH_1X_EGG = {"Nightmare Egg"},
    ALWAYS_INFINITY_ELIXIR = true,
    ALWAYS_EGG_ELIXIR = false,
    ALWAYS_SECRET_ELIXIR = false,

    IGNORE_SEASON_CHALLENGES = false,
    IGNORE_EQUIP_BEST_PET = false,

    WEBHOOK_URL = "https://discord.com/api/webhooks/1409541809662857347/PDZx8xT5PoT00LY2EMFtPVxf4JBjtEu4PnoUN5cBMfnpjNipHym67vw3DoyPAbJXVt7j",
    DISCORD_ID = "324553736053719040",
    WEBHOOK_NOTE = "skibidi",
    WEBHOOK_ODDS = "10k",
    SHOW_PET_WEBHOOK_USERNAME = true,
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/e1f274825da00b92599872de596f1fc0.lua"))()
