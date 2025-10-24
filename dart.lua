local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local remote = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteEvent")

-- ✅ Auto-finish minigame loop
task.spawn(function()
    while true do
        remote:FireServer("FinishMinigame")
        task.wait(0.2)
    end
end)

-- ✅ Auto-start Halloween Darts minigame
local difficulties = {"Medium"}

task.spawn(function()
    while true do
        for _, diff in ipairs(difficulties) do
            remote:FireServer("SkipMinigameCooldown", "Halloween Darts")
            remote:FireServer("StartMinigame", "Halloween Darts", diff)
            remote:FireServer("StartMinigame", "Halloween Darts", diff)
            task.wait(0.5)
        end
    end
end)
