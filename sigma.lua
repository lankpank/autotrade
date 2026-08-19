-- ============================================================
-- 1RZ LITE - CUSTOM FUNCTIONS
-- ============================================================

-- Check if game is loaded
if not game:IsLoaded() then game.Loaded:Wait() end

-- Get services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Remote references
local RemoteFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")
local remote = RemoteFolder:WaitForChild("RemoteEvent")
local remotefunction = RemoteFolder:WaitForChild("RemoteFunction")

-- Load modules
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local PetsData = require(ReplicatedStorage.Shared.Data.Pets)

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    -- Shrines
    shrineLevel = 1,
    shrinePotion = "Lucky",
    shrineAmount = 100,
    DreamerShrineAmount = 1,
    
    -- Spam
    autoSpamR = true,
    
    -- Webhook
    webhookEnabled = true,
    webhookURL = "https://discord.com/api/webhooks/1520793322233401526/DDES_4Ps5Vp42p5ZD5kG5-zl-kBXZv7Eq9JihzNLttLKf7Kdnfs3JHC4yPfRUBOqWaqv",
    webhookHidePlayerName = false,
}

-- ============================================================
-- 0. ANTI-IDLE (Disable AFK kick)
-- ============================================================
local function disableAFK()
    for _, x in pairs(getconnections(game.Players.LocalPlayer.Idled)) do 
        x:Disable() 
    end
    print("[Anti-AFK] Disabled all idle connections")
end

-- Call immediately
disableAFK()

-- Also re-apply if player respawns or idle connections reappear
task.spawn(function()
    while true do
        task.wait(30) -- Check every 30 seconds
        pcall(disableAFK)
    end
end)

-- ============================================================
-- 1. DONATE TO BUBBLE SHRINE
-- ============================================================
local function donateToBubbleShrine(level, potion, amount)
    pcall(function()
        remotefunction:InvokeServer("DonateToShrine", {
            Level = level or Config.shrineLevel,
            Type = "Potion",
            Name = potion or Config.shrinePotion,
            Amount = amount or Config.shrineAmount,
        })
    end)
end

-- ============================================================
-- 2. DONATE TO DREAMER SHRINE
-- ============================================================
local function donateToDreamerShrine(amount)
    pcall(function()
        remotefunction:InvokeServer("DonateToDreamerShrine", amount or Config.DreamerShrineAmount)
    end)
end

-- ============================================================
-- 3. SPAM R KEY (removed E)
-- ============================================================
local function startSpamR()
    task.spawn(function()
        while true do
            task.wait(0)
            if not Config.autoSpamR then 
                task.wait(0.5)
                continue 
            end
            -- Only send R key
            VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
    end)
end

-- ============================================================
-- 4. REMOVE EGG ANIMATION
-- ============================================================
local function removeHatchAnimation()
    local HatchModule
    pcall(function()
        HatchModule = require(ReplicatedStorage.Client.Effects.HatchEgg)
    end)
    if not HatchModule then 
        warn("HatchModule not found")
        return 
    end
    
    HatchModule.Play = function(self, result)
        if result and result.Pets then
            local gui = player:FindFirstChild("PlayerGui")
            if gui then
                local screenGui = gui:FindFirstChild("ScreenGui")
                if screenGui then
                    local hatching = screenGui:FindFirstChild("Hatching")
                    if hatching then hatching.Visible = false end
                    local hud = screenGui:FindFirstChild("HUD")
                    if hud then hud.Visible = true end
                end
            end
            self._hatching = false
        end
    end
end

-- ============================================================
-- 5. WEBHOOK NOTIFY (Secret & Infinity only)
-- ============================================================
local function sendDiscordWebhook(url, payload)
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if type(req) ~= "function" then return false end
    
    local ok, res = pcall(function()
        return req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
    end)
    
    if ok and res then
        local sc = res.StatusCode
        if sc == nil or sc == 200 or sc == 204 then return true end
    end
    return false
end

local function sendWebhook(title, color, fields, imageUrl)
    if not Config.webhookEnabled or Config.webhookURL == "" then return end
    
    local hide = Config.webhookHidePlayerName == true
    local useTitle = hide and "Pet Hatched" or title
    
    sendDiscordWebhook(Config.webhookURL, {
        embeds = { {
            title = useTitle,
            color = color,
            fields = fields,
            thumbnail = imageUrl and { url = imageUrl } or nil,
            footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
        } },
    })
end

local function setupWebhookNotify()
    remote.OnClientEvent:Connect(function(command, data, ...)
        if not Config.webhookEnabled then return end
        
        local petsList
        if command == "HatchEgg" or command == "HatchPowerupEgg" or command == "ExclusiveHatch" then
            if type(data) == "table" then
                petsList = data.Pets or (data.Name and { data }) or nil
            end
        elseif command == "ItemsReceived" then
            if type(data) == "table" then
                petsList = {}
                for _, item in ipairs(data) do
                    if type(item) == "table" and item.Type == "Pet" then 
                        table.insert(petsList, item) 
                    end
                end
                if #petsList == 0 then petsList = nil end
            end
        end
        
        if not petsList or #petsList == 0 then return end
        
        for i, petInfo in ipairs(petsList) do
            if i > 1 then task.wait(0.1) end
            
            local name = petInfo.Name or (petInfo.Pet and petInfo.Pet.Name) or "Unknown"
            local petData = PetsData and PetsData[name] or {}
            local rarity = petData.Rarity or "Unknown"
            
            -- Only Secret and Infinity
            if rarity ~= "Secret" and rarity ~= "Infinity" then continue end
            
            -- Get variant info
            local shiny = petInfo.Shiny or (petInfo.Pet and petInfo.Pet.Shiny) or false
            local mythic = petInfo.Mythic or (petInfo.Pet and petInfo.Pet.Mythic) or false
            local xl = petInfo.XL or (petInfo.Pet and petInfo.Pet.XL) or false
            
            -- Build variant label
            local variantLabel = ""
            if shiny and mythic then variantLabel = "Shiny Mythic"
            elseif shiny then variantLabel = "Shiny"
            elseif mythic then variantLabel = "Mythic"
            end
            if xl then 
                variantLabel = variantLabel ~= "" and variantLabel .. " XL" or "XL"
            end
            
            -- Color
            local color = 3447003 -- Blue default
            if rarity == "Secret" then
                if shiny and mythic then color = 65280
                elseif mythic then color = 16753920
                elseif shiny then color = 16776960
                else color = 16711680 end
            elseif rarity == "Infinity" then
                if shiny and mythic then color = 65280
                elseif mythic then color = 16753920
                elseif shiny then color = 16776960
                else color = 10181046 end
            end
            
            -- Build fields
            local fields = {
                { 
                    name = "Pet", 
                    value = string.format("%s\nRarity: %s\nVariant: %s", 
                        name, 
                        rarity, 
                        variantLabel ~= "" and variantLabel or "Normal"
                    ), 
                    inline = false 
                },
                { 
                    name = "Player", 
                    value = Config.webhookHidePlayerName and "Hidden" or player.Name, 
                    inline = false 
                },
            }
            
            sendWebhook(
                string.format("%s hatched a %s %s", 
                    Config.webhookHidePlayerName and "Player" or player.Name,
                    rarity,
                    name
                ),
                color,
                fields,
                nil -- imageUrl if you have it
            )
        end
    end)
end

-- ============================================================
-- SHRINE AUTO LOOPS
-- ============================================================

-- Auto Bubble Shrine loop
local function startBubbleShrineLoop()
    task.spawn(function()
        while true do
            donateToBubbleShrine()
            task.wait(5)
        end
    end)
end

-- Auto Dreamer Shrine loop
local function startDreamerShrineLoop()
    task.spawn(function()
        while true do
            donateToDreamerShrine()
            task.wait(5)
        end
    end)
end

-- ============================================================
-- INITIALIZE ALL FUNCTIONS
-- ============================================================

-- Start spam R
startSpamR()

-- Remove hatch animation
removeHatchAnimation()

-- Setup webhook notify
setupWebhookNotify()

-- Start shrine loops
startBubbleShrineLoop()
startDreamerShrineLoop()

-- ============================================================
-- USAGE EXAMPLES (uncomment to use)
-- ============================================================

-- Manual donate functions (you can call these anytime):
-- donateToBubbleShrine(1, "Lucky", 100)  -- Level 1, Lucky potion, 100 donations
-- donateToDreamerShrine(5)               -- Donate 5 to Dreamer shrine

-- Toggle spam R:
-- Config.autoSpamR = false  -- Stop spamming R
-- Config.autoSpamR = true   -- Start spamming R

-- Toggle webhook:
-- Config.webhookEnabled = false
-- Config.webhookURL = "YOUR_NEW_WEBHOOK_URL"

-- Manual anti-AFK (if needed):
-- disableAFK()

print("1RZ Lite Custom Functions Loaded!")
print("- Anti-AFK: Enabled (idle connections disabled)")
print("- Bubble Shrine: Donates every 5s")
print("- Dreamer Shrine: Donates every 5s") 
print("- Spam R: Enabled")
print("- Egg Animation: Removed")
print("- Webhook: Notifies on Secret/Infinity hatches")
