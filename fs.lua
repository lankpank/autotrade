local ENABLED = true
local DIFFICULTIES_TO_CYCLE = { "Easy", "Medium", "Hard" }
local TELEPORT_DELAY = 2.5

if not ENABLED then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local RemoteEvent = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent
local ObbysFolder = Workspace.Obbys
local ObbyTeleports = Workspace.Worlds["Seven Seas"].Areas["Classic Island"].Obbys

local function teleportTo(target)
    local character = LocalPlayer.Character
    if not character or not target then return end
    local targetCFrame
    if typeof(target) == "CFrame" then
        targetCFrame = target
    elseif target:IsA("BasePart") then
        targetCFrame = target.CFrame
    elseif target:IsA("Model") then
        targetCFrame = target:GetPivot()
    end
    if targetCFrame then
        character:PivotTo(targetCFrame * CFrame.new(0, 3, 0))
    end
end

local function runObbyCycle(difficulty)
    print("Starting obby: " .. difficulty)
    local teleportPart = ObbyTeleports:FindFirstChild(difficulty) 
        and ObbyTeleports[difficulty]:FindFirstChild("Portal") 
        and ObbyTeleports[difficulty].Portal:FindFirstChild("Part")
    local completePart = ObbysFolder:FindFirstChild(difficulty) and ObbysFolder[difficulty]:FindFirstChild("Complete")
    if not teleportPart or not completePart then
        return
    end
    teleportTo(teleportPart)
    task.wait(0.5)
    RemoteEvent:FireServer("StartObby", difficulty)
    task.wait(TELEPORT_DELAY)
    teleportTo(completePart)
    task.wait(0.5)
    RemoteEvent:FireServer("CompleteObby")
    task.wait(0.5)
    RemoteEvent:FireServer("ClaimObbyChest")
    task.wait(2)
end

task.spawn(function()
    while task.wait(1) do
        local character = LocalPlayer.Character
        local playerData = LocalData:Get()
        if not character or not character.PrimaryPart or not playerData or not playerData.ObbyCooldowns then
            continue
        end
        local initialPosition = character.PrimaryPart.CFrame
        local completedAnObbyInCycle = false
        for _, difficulty in ipairs(DIFFICULTIES_TO_CYCLE) do
            local cooldownEndTime = playerData.ObbyCooldowns[difficulty] or 0
            if os.time() >= cooldownEndTime then
                runObbyCycle(difficulty)
                completedAnObbyInCycle = true
                task.wait(3)
                playerData = LocalData:Get()
                if not playerData or not playerData.ObbyCooldowns then break end
            end
        end
        if completedAnObbyInCycle then
            teleportTo(initialPosition)
        end
        playerData = LocalData:Get()
        if not playerData or not playerData.ObbyCooldowns then continue end
        local nextAvailableTime = math.huge
        for _, difficulty in ipairs(DIFFICULTIES_TO_CYCLE) do
            local cooldownEndTime = playerData.ObbyCooldowns[difficulty] or 0
            if cooldownEndTime > os.time() and cooldownEndTime < nextAvailableTime then
                nextAvailableTime = cooldownEndTime
            end
        end
        if nextAvailableTime ~= math.huge then
            local timeToWait = nextAvailableTime - os.time()
            if timeToWait > 0 then
                print("All obbies are on cooldown. Next check in " .. timeToWait .. " seconds.")
                task.wait(timeToWait)
            end
        end
    end
end)
