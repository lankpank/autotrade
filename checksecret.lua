local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Modules
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local PetsModule = require(
    ReplicatedStorage:WaitForChild("Shared")
        :WaitForChild("Data")
        :WaitForChild("Pets")
)

-- 🧠 Webhook
local WEBHOOK_URL = ""

-- Discord ID to ping (replace with your ID)
local DISCORD_ID = ""

-- Safe request
local requestFunc =
    (syn and syn.request)
    or (http and http.request)
    or (http_request)
    or (fluxus and fluxus.request)
    or (getgenv().request)

-- Player Info
local player = Players.LocalPlayer
local username = player and player.Name or "UnknownUser"
local displayName = player and player.DisplayName or username

-- Pull inventory
local function getAllPets()
    local data = LocalData:Get()
    return (data and data.Pets) or {}
end

-- Variant type
local function getVariantType(pet)
    local shiny = pet.Shiny
    local mythic = pet.Mythic

    if shiny and mythic then
        return "🌈 Shiny Mythic"
    elseif shiny then
        return "🌟 Shiny"
    elseif mythic then
        return "🔥 Mythic"
    else
        return "Normal"
    end
end

-- Rarity
local function getRarity(pet)
    local petInfo = PetsModule[pet.Name]
    if petInfo and petInfo.Rarity then
        return petInfo.Rarity
    else
        return "Unknown"
    end
end

-- Send pets to Discord
local function sendSpecialPets()
    local pets = getAllPets()
    local lines = {}
    local pingLines = {}

    for _, pet in pairs(pets) do
        local rarity = getRarity(pet)
        if rarity == "Secret" or rarity == "Infinity" then
            local variant = getVariantType(pet)
            local info = string.format(
                "%s | %s | %s | ID: %s",
                pet.Name,
                rarity,
                variant,
                pet.Id
            )
            table.insert(lines, info)

            -- Conditional ping logic
            if rarity == "Infinity" or (rarity == "Secret" and (variant == "🌈 Shiny Mythic" or variant == "🔥 Mythic")) then
                table.insert(pingLines, string.format("<@%s> %s", DISCORD_ID, info))
            end
        end
    end

    if #lines == 0 then
        table.insert(lines, "⚠️ No Secret or Infinity pets found.")
    end

    local payload = {
        username = "🐾 Special Pet Exporter",
        embeds = {{
            title = string.format("💎 Secret & Infinity Pets - %s (%s)", displayName, username),
            description = table.concat(lines, "\n"),
            color = 0xFFD700,
            footer = { text = os.date("Exported at %Y-%m-%d %H:%M:%S") }
        }},
        content = #pingLines > 0 and table.concat(pingLines, "\n") or ""
    }

    local success, res = pcall(function()
        return requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if success and res and (res.StatusCode == 204 or res.Success) then
        print("[✅] Sent Secret/Infinity pets to Discord for", username)
    else
        warn("[❌] Failed to send pets:", res and res.StatusMessage or "No response.")
    end
end

-- Loop every hour
while true do
    sendSpecialPets()
    print("[⏳] Waiting 1 hour before next export...")
    task.wait(3600)
end
