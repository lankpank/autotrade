local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalData = require(RS.Client.Framework.Services.LocalData)
local RemoteEvent = RS.Shared.Framework.Network.Remote.RemoteEvent

local target = "secret-hunter"
local done = {}

-- Function to process pets
local function processPets()
    local data = LocalData:Get()
    if not data or not data.Teams or not data.TeamEquipped then
        return
    end
    
    local team = data.Teams[data.TeamEquipped]
    if not team or not team.Pets then
        return
    end
    
    for _, petId in ipairs(team.Pets) do
        if not done[petId] then
            local pet
            for _, p in ipairs(data.Pets or {}) do
                if p.Id == petId then
                    pet = p
                    break
                end
            end
            
            if pet then
                local has = false
                for _, e in ipairs(pet.Enchants or {}) do
                    if e.Id == target then
                        has = true
                        break
                    end
                end
                
                if has then
                    done[petId] = true
                else
                    RemoteEvent:FireServer("UseShadowCrystal", petId)
                end
            end
            task.wait(0.1)
        end
    end
end

-- Main 30-minute loop
task.spawn(function()
    while true do
        local startTime = os.clock()
        local thirtyMinutes = 30 * 60 -- 30 minutes in seconds
        
        -- Run for 30 minutes
        while (os.clock() - startTime) < thirtyMinutes do
            processPets()
            task.wait(1)
        end
        
        -- Reset the done table after 30 minutes
        done = {}
        print("30 minutes elapsed - resetting tracking...")
        
        -- Optional: Wait a bit before restarting the cycle
        task.wait(5)
    end
end)
