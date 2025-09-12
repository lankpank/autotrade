local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Services/Modules
local Network = ReplicatedStorage:WaitForChild("Shared")
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

-- Function to delete all non-Secret/Infinity pets
local function deleteNonTargetPets()
    local data = LocalData:Get()
    if not data or not data.Pets then
        warn("❌ No pets in inventory.")
        return
    end

    for _, pet in pairs(data.Pets) do
        local petInfo = PetsModule[pet.Name]

        -- Only delete pets that are not Secret/Infinity
        if petInfo and petInfo.Rarity ~= "Secret" and petInfo.Rarity ~= "Infinity" then
            local args = {
                "DeletePet",
                pet.Id, -- unique pet ID
                1,      -- amount (usually 1 for unique pets)
                false   -- delete single, not mass-delete
            }

            Network:FireServer(unpack(args))
            print("🗑️ Deleted pet:", pet.Name, "| ID:", pet.Id, "| Rarity:", petInfo.Rarity)
        end
    end
end

-- Run it once
deleteNonTargetPets()
