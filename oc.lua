script_key="XYdAkPyUuYSNwQNrrcSgjvXWpixJRWje";

getgenv().bgsiSettings={
HATCHING_SETTINGS={
  NEW_ACCOUNT=false, --unlock w1,w2,w3 & grinds mastery Warning. I dont recommend using on accounts with progress. It might work but isnt intended 
  NEW_ACCOUNT_SKIP_W3=true, --skips W3. only needs W1, W2 and masteries to be considered not "new"
  OPEN_EGGS=true,
  EGG="Hellish Egg", --to find & Hatch
  AUTO_EGG_HUNTING="", --Bounty, XL
WEBHOOK_SETTINGS={
  WEBHOOK="https://discord.com/api/webhooks/1455368735564234894/tMJuYLx3R4refYBL8dO-uO9IlefDYsrIq71H26LLQkj173y8PzGo5Q-bRIiTSY35tQrl", --Discord Webhook URL to see your own Hatches
  DISCORD_ID="619522585964576795", --User ID To mention when you hatch something (Public & User)
  ROLE_ID="", --Discord ID is skipped if set (Only user webhook)
  ODDS="1b",
  IGNORE_ODDS_IF_SHINY_OR_MYTHIC=true,
  ALLOW_EASY_SECRETS=false, 
  HIDE_USERNAME=true, --Hide player in user webhook
  PET_BLACKLIST={},
  },
RIFT_SETTINGS={
  LOOK_FOR_RIFTS=true,
  AUTO_RIFT_EGG_HUNTING="", --Bounty, XL
  MINIMUM_LUCK=25, -- Min Luck multi go for
  SUMMONED_RIFTS=true, --Admin Abuse
  SERVERHOP_TILL_AA_PORTAL=false,
  TARGETS={"Retro Egg"},
  AUTO_SUMMON_RIFT=true, --Rift Summoning (W1 Bubble Shrine)
  TO_SUMMON="", --Egg/Chest name (overriden if AUTO_RIFT_EGG_HUNTING is set)
  },
},
QUEST_SETTINGS={
  AUTO_QUEST=true, --toggles Completion of Quests
  CLAIM_SEASON_PASS=true,
  GENIE_IGNORE_W3_EGGS=true,
  DO_GEM_GENIE=false,
  DO_SEASON_PASS_HOURLY=true,
  DO_SEASON_PASS_DAILY=true,
  DO_MILESTONE_MINIGAMES=false,
  DO_MILESTONE_POTIONS=false,
  DO_GLOBALINCENTIVE=false,
  GEM_GENIE_REWARDS={"Secret Elixir","Infinity Elixir","Egg Elixir","Shadow Crystal","Reroll Orb"},
  },
POTION_SETTINGS={
  USE_POTIONS=true,
  CLAIM_BLESSING=true, --Gets W1, W3 Blessing
  POTIONS_TO_USE={"Lucky","Speed","Mythic","Egg Elixir","Infinity Elixir"},
  BLESSING_POTIONS={"Lucky","Speed","Mythic","Tickets","Coins" }, --Potions for W1 Blessing
  BULK_POTION_USAGE=true, --Gets 1 Day of potions
  },
PET_SETTINGS={
  GAME_AUTO_DELETE=false,
  AUTO_DELETE=false, --script's Auto Delete 
  AUTO_DELETE_TIER=2, --Deletes Legendary Up to this Tier
  MANUAL_AUTO_DELETE={},
  EQUIP_SECRETS=false,
  EQUIP_SUPER=false,
  EQUIP_BEST=false,
  ALLOWED_SECRETS={}
  },
REBIRTH_MACHINE_SETTINGS={ 
  USE_REBIRTH_MACHINE=false,
  SECRETS_TO_FUSE={},
  FUSE_RARITY="Normal", --Normal, Shiny, Mythic, Shiny Mythic
  },
MINIGAME_SETTINGS={ 
  PLAY_MINIGAMES=false,
  USE_SUPER_TICKET=false,
  SUPER_TICKET_MINIGAME="Robot Claw",
  SUPER_TICKET_AMOUNT=20,
  SUPER_TICKET_COOLDOWN=45, --min
  FOCUS_DICE=false,
  USE_GOLDEN_DICEN=false,
  GOLDEN_DICE_AMOUNT=2,
  },
ENCHANT_SETTINGS={
  ENCHANT_PETS=false,
  ENCHANT_SECRETS=false,
  ENCHANT_LEGENDARY=false,
  USE_SHADOW_CRYSTAL=true,
  SECRET_PET_ENCHANTMENTS={
    ["Secret Hunter"]={Tier=1,HigherTiers=true,Prio=true},
    ["Ultra Roller"]={Tier=1,HigherTiers=true},
    },
  LEGENDARY_PET_ENCHANTMENTS={
    ["Looter"]={Tier=5,HigherTiers=true},
    ["Team Up"]={Tier=5,HigherTiers=true,Prio=true},
    },
  },
MISC_SETTINGS={
  SKIP_PREMIUM_PASS=true,
  IGNORE_W3=true,
  GRIND_PEARLS=false,
  GRIND_PEARLS_DURATION=2, --min
  AUTO_FISH=false,
  AUTO_FISH_DURATION=2, --min
  AUTO_CHEST_RIFT = false,
  RIFT_CHESTS_TO_FIND={"royal-chest","super-chest","dice-rift"},
  AUTO_CHEST=false,
  AUTO_MERCHANT=false,
  MERCHANT_REROLL="circus-shop",
  AUTO_MERCHANT_BLACKLIST={},
  OPEN_POWERUP_EGGS=false,
  OPEN_MYSTERY_BOXES=false,
  MYSTERY_TILL_GEM_CAP=false,
  AUTO_SPIN=true,
  CLAIM_PLAYTIME=true,
  CLAIM_CODES=true,
  DO_DOGGY_JUMP=true,
  CLAIM_INDEX_REWARDS=true,
  AUTO_MASTERY=false,
  UPGRADE_BUBBLES=true,
  BLOW_BUBBLES=false,
  PICKUP_ITEMS_WHILE_HATCHING=false,
  },
HEAVEN_AND_HELL_ISLAND_SETTINGS = {
  ISLAND = "Hell", --island to use (Hell, Heaven)
  USE_ISLAND_ELIXIR = true, --Uses Elixir based on ISLAND Setting
  CLAIM_ISLAND_BLESSING = true, --Claims Shrine based on ISLAND Setting
  --Script looks for lowest tier and highest amount first to claim for blessing
},
DEBUG={
  FPS_LIMIT=15,
  FPS_COUNTER=true,
  BEST_HATCH=true,
  DISABLE_HATCH_ANIM=true,
  DISABLE_UI=false,
  },
}
--Script Config on channel #⚙script-config
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/a1b4af844e9ed9a7b2a2cc2ee90fe37d.lua"))()
