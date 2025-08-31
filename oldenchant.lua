local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteFunction")
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)

-- 🐾 All pet.Id strings to keep enchanted
local targetPetIds = {
    "80a61311-56bf-457b-bf6d-6b5fb6a79463", -- Chronos
    "97da736f-c201-4f68-bd30-6e19103369cf", -- The Overlord
    "df752002-74f6-40b4-91b3-a2dfad99844a", -- Fallen Angel
    "604a118f-088b-40b3-af63-9925bb883329", -- Eternal Star
    "58ca81fe-3cca-414e-8779-14324ddd1862", -- Fallen Angel
    "652d7241-baf8-4bcd-82fd-f5be7464107f", -- Sea Champion
    "031f5e7a-a027-4531-9478-f69a7a40972b", -- Earth Champion
    "4610fec1-28bd-4ccf-bfbc-1f59d922340e", -- Earth Champion
    "d6c6c839-05e8-4199-95a4-ac0d223f2ad8", -- Sea Champion
    "968fb742-c157-4fbe-9ee7-844e4cb58d96", -- Fallen Angel
    "8c03fb94-6b27-4e6a-abc0-a7f762d32021"  -- Diamond Overlord
}

local targetEnchant = "secret-hunter"
local targetLevel = 1

-- 🔄 State
local petsToHandle = {} -- queue of pet.Id values
local checkingDelay = 2 -- seconds between checks (faster than 5)

local function hasDesiredEnchant(pet)
    for _, enchant in pairs(pet.Enchants or {}) do
        if enchant.Id == targetEnchant and enchant.Level == targetLevel then
            return true
        end
    end
    return false
end

local function getPetById(petId)
    local data = LocalData:Get()
    if not data or not data.Pets then return nil end

    for _, pet in pairs(data.Pets) do
        if pet.Id == petId then
            return pet
        end
    end

    return nil
end

local function isQueued(petId)
    for _, id in ipairs(petsToHandle) do
        if id == petId then
            return true
        end
    end
    return false
end

-- 👀 Check every few seconds for missing enchants
task.spawn(function()
    while true do
        local data = LocalData:Get()
        if data and data.Pets then
            for _, pet in pairs(data.Pets) do
                if table.find(targetPetIds, pet.Id) and not hasDesiredEnchant(pet) and not isQueued(pet.Id) then
                    print("📥 Queuing pet for reroll:", pet.Id)
                    table.insert(petsToHandle, pet.Id)
                end
            end
        end
        task.wait(checkingDelay) -- now 2s
    end
end)

-- 🔁 Process reroll queue one by one
while true do
    if #petsToHandle > 0 then
        local petId = table.remove(petsToHandle, 1)
        print("🔁 Rerolling pet:", petId)

        while true do
            local pet = getPetById(petId)
            if not pet then
                warn("❌ Pet not found:", petId)
                break
            end

            if hasDesiredEnchant(pet) then
                print("✅ Pet", petId, "has desired enchant, done.")
                break
            end

            RemoteFunction:InvokeServer("RerollEnchants", petId, "Gems")
            task.wait(0.2) -- shorter delay
        end
    else
        task.wait(0.1) -- idle wait shortened
    end
end
