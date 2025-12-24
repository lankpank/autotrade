

--Paste Script Config Here
getgenv().bgsiSettings={
    HATCHING_SETTINGS={
        OPEN_EGGS = true,
        EGG = "Festive Egg",
        WEBHOOK_SETTINGS={
            WEBHOOK="https://discord.com/api/webhooks/1436639336169996359/cYq8ckGmy2arH1QdIWjD50mleVtkz9vCVqXiBuAjgUOVutlsjpv9uHWTan5EfE8-WvNL",
            DISCORD_ID="619522585964576795",
            ODDS="10b",
            IGNORE_ODDS_IF_SHINY_OR_MYTHIC = false,
            HIDE_USERNAME = false
        },
        RIFT_SETTINGS={
            LOOK_FOR_RIFTS = true,
            MINIMUM_LUCK = 5,
            SUMMONED_RIFTS = true,
            TARGETS = {"Giftbox Egg", "Festive Egg"}
        },
    }

loadstring(game:HttpGet("https://raw.githubusercontent.com/IdiotHub/Scripts/main/Loader"))()

