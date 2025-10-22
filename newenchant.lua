local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 🔌 Services / Modules
local RemoteFunction = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteFunction")

local RemoteEvent = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteEvent")

local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local PetsModule = require(
    ReplicatedStorage:WaitForChild("Shared")
        :WaitForChild("Data")
        :WaitForChild("Pets")
)

-- 🎯 Target enchant
local TARGET_ENCHANT = "secret-hunter" 
local SCAN_INTERVAL = 1000 -- 1 hour 
local petsToHandle = {}

-- 🧠 Utility functions
local function hasDeterminationEnchant(pet)
    for _, enchant in pairs(pet.Enchants or {}) do
        if enchant.Id == TARGET_ENCHANT then
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

-- 🧾 Scan inventory for Secret or Infinity pets missing Determination
local function scanPets()
    local data = LocalData:Get()
    if not data or not data.Pets then
        warn("⚠️ No pets found in LocalData.")
        return
    end

    local found = 0
    for _, pet in pairs(data.Pets) do
        local petInfo = PetsModule[pet.Name]
        if petInfo and (petInfo.Rarity == "Secret" or petInfo.Rarity == "Infinity") then
            found += 1
            if not hasDeterminationEnchant(pet) and not isQueued(pet.Id) then
                print("📥 Queuing pet:", pet.Name, "| Rarity:", petInfo.Rarity, "| ID:", pet.Id)
                table.insert(petsToHandle, pet.Id)
            end
        end
    end

    print("🔍 Scan complete. Found", found, "Secret/Infinity pets.")
end

-- 🔁 Process queued pets with UseShadowCrystal
task.spawn(function()
    while true do
        if #petsToHandle > 0 then
            local petId = table.remove(petsToHandle, 1)
            local pet = getPetById(petId)
            if not pet then
                warn("❌ Pet not found:", petId)
            else
                print("🔁 Using Shadow Crystal on:", pet.Name, "| ID:", pet.Id)
                while true do
                    local currentPet = getPetById(petId)
                    if not currentPet then
                        warn("❌ Pet removed during process:", petId)
                        break
                    end

                    if hasDeterminationEnchant(currentPet) then
                        print("✅", currentPet.Name, "now has Determination enchant!")
                        break
                    end

                    -- 🧿 Use Shadow Crystal on the pet
                    RemoteEvent:FireServer("UseShadowCrystal", currentPet.Id)
                    task.wait(0.25)
                end
            end
        else
            task.wait(1) -- wait a bit before checking again
        end
    end
end)

-- 🕐 Re-scan every hour
task.spawn(function()
    while true do
        scanPets()
        task.wait(SCAN_INTERVAL)
    end
end)

-- Initial scan
scanPets()
