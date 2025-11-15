local HttpService = game:GetService("HttpService")

-- 🧩 Your Discord webhook URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1439362633932345626/GEgEz-DMscb8xFJ1rY4uQrWzlPVqZACR0XtKkpiFUMEQBDUQ0zh5JGS6_x8vEhSwz5x-"

-- 🧩 Your Discord User ID (to ping you)
local DISCORD_USER_ID = "619522585964576795" -- replace this with yours

local function sendDiscordMessage(content)
    local data = {
        ["content"] = content
    }

    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("❌ Failed to send Discord message:", err)
    end
end


local function onEggHatched(hatchInfo)
    if not (hatchInfo and hatchInfo.Pets and myself) then return end

    for _, petData in ipairs(hatchInfo.Pets) do
        local pet = petData.Pet
        if not (pet and pet.Name) then continue end

        local petInfo = petDatabase[pet.Name]
        if not petInfo then continue end

        local rarity = petInfo.Rarity
        local shiny = pet.Shiny
        local mythic = pet.Mythic

        -- 🏷️ Build prefix (Shiny, Mythic, etc.)
        local prefix = ""
        if shiny and mythic then
            prefix = "Shiny Mythic "
        elseif mythic then
            prefix = "Mythic "
        elseif shiny then
            prefix = "Shiny "
        end

        local fullPetName = prefix .. pet.Name
        local message
        local ping = ""

        -- 🧩 Logic for sending and pinging
        if rarity == "Legendary" then
            if mythic or (shiny and mythic) then
                message = string.format("🎉 **%s** hatched a %s**%s** 🟣", myself.Name, prefix, pet.Name)
            end
        elseif rarity == "Secret" or rarity == "Infinity" then
            ping = string.format("<@%s>", DISCORD_USER_ID)
            message = string.format("💎 %s just hatched a **%s%s**! %s", myself.Name, prefix, pet.Name, ping)
        end

        -- 🚀 Send the webhook
        if message then
            sendDiscordMessage(message)
        end
    end
end
