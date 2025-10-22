local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ✅ Wait for the player's character to be ready
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
    player.CharacterAdded:Wait()
end

local character = player.Character
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- 🔍 Search for Dreamer Fountain anywhere in workspace
local function findDreamerFountain()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if string.find(descendant.Name:lower(), "dreaming fountain") then
            return descendant
        end
    end
    return nil
end

local fountain = findDreamerFountain()

if fountain then
    local fountainPart = fountain.PrimaryPart or fountain:FindFirstChildWhichIsA("BasePart")
    if fountainPart then
        humanoidRootPart.CFrame = fountainPart.CFrame + Vector3.new(0, 4, 0)
        print("✅ Teleported to:", fountain:GetFullName())
    else
        warn("❌ Found Dreamer Fountain but no teleportable part inside.")
    end
else
    warn("❌ Could not find any object named Dreamer Fountain.")
end
