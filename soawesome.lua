--[[
    1rzHub Lite - Standalone Present Rain Collector
    Automatically collects falling gifts (Present Rain event)
]]

-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Get the remote event for sending requests
local RemoteFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")
local remote = RemoteFolder:WaitForChild("RemoteEvent")

-- Track which gifts we've already collected to avoid duplicates
local collectedGiftIds = {}

-- Function to collect a present rain gift
local function collectPresentRain(giftInstance)
    if not giftInstance or typeof(giftInstance) ~= "Instance" then return end
    if not giftInstance:IsA("Folder") then return end
    
    local giftId = giftInstance.Name
    if type(giftId) ~= "string" or giftId == "" then return end
    
    -- Don't collect the same gift twice
    if collectedGiftIds[giftId] then return end
    
    collectedGiftIds[giftId] = true
    pcall(function()
        remote:FireServer("CollectPresentRain", giftId)
        print("[Present Rain] Collected:", giftId)
    end)
end

-- Main watcher function
local function startPresentRainCollector()
    -- Wait for Markers folder
    local markers = Workspace:FindFirstChild("Markers")
    if not markers then
        print("[Present Rain] Waiting for Markers folder...")
        markers = Workspace:WaitForChild("Markers", 600)
    end
    
    if not markers then
        warn("[Present Rain] Could not find Markers folder")
        return
    end
    
    -- Wait for PresentRain folder
    local presentRainFolder = markers:FindFirstChild("PresentRain")
    if not presentRainFolder then
        print("[Present Rain] Waiting for PresentRain folder...")
        presentRainFolder = markers:WaitForChild("PresentRain", 600)
    end
    
    if not presentRainFolder then
        warn("[Present Rain] Could not find PresentRain folder")
        return
    end
    
    print("[Present Rain] Collector activated! Waiting for falling gifts...")
    
    -- Collect any existing gifts
    for _, gift in ipairs(presentRainFolder:GetChildren()) do
        collectPresentRain(gift)
    end
    
    -- Watch for new gifts
    presentRainFolder.ChildAdded:Connect(function(newGift)
        task.defer(function()
            collectPresentRain(newGift)
        end)
    end)
end

-- Start the collector
local success, err = pcall(startPresentRainCollector)
if not success then
    warn("[Present Rain] Error:", err)
else
    print("[Present Rain] Present Rain collector is running")
end

-- Keep the script alive
while task.wait(1) do
    -- Script stays running
end
