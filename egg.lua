local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- 👇 Target egg name
local EGG_NAME = "Sinister Egg"

-- 👇 First teleport position
local firstPosition = Vector3.new(-4922.60, 25.96, -548.99)

-- ✅ Wait until character is ready
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
	player.CharacterAdded:Wait()
end

local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart")

-- 🌀 Step 1: Teleport to first coordinates
humanoidRootPart.CFrame = CFrame.new(firstPosition)
print("Teleported to first position:", firstPosition)

-- ⏳ Step 2: Wait 2 seconds
task.wait(2)

-- ❌ Step 2.5: Disable egg hatching effects
local success, err = pcall(function()
	local hatchModule = require(ReplicatedStorage.Client.Effects.HatchEgg)
	if hatchModule and hatchModule.Play then
		hatchModule.Play = function()
			return
		end
		print("Disabled HatchEgg animation successfully.")
	else
		warn("Could not find HatchEgg module or Play function.")
	end
end)

if not success then
	warn("Error disabling HatchEgg effect:", err)
end

-- 🥚 Step 3: Teleport to the Sinister Egg
local egg = workspace.Rendered.Generic:FindFirstChild(EGG_NAME)

if egg then
	local eggPart = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
	if eggPart then
		humanoidRootPart.CFrame = eggPart.CFrame
		print("Teleported to " .. EGG_NAME)

		-- 🔁 Step 4: Press "E" repeatedly to interact
		while true do
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
			task.wait(0.1)
		end
	else
		warn("Couldn't find egg part.")
	end
else
	warn("Sinister Egg not found.")
end
