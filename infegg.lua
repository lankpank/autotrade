if type(getgenv) == "function" then
    local g = getgenv()
    if rawget(g, "_1rzHubUltimate_Loaded") then return end
    g._1rzHubUltimate_Loaded = true
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- ============================================================
-- Auto rejoin on disconnect
-- ============================================================
task.spawn(function()
    repeat task.wait() until CoreGui:FindFirstChild("RobloxPromptGui")
    local pg = CoreGui:FindFirstChild("RobloxPromptGui")
    local po = pg and pg:FindFirstChild("promptOverlay") or pg and pg:WaitForChild("promptOverlay", 30)
    if not po then return end
    po.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            task.spawn(function()
                while true do
                    pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
                    task.wait(2)
                end
            end)
        end
    end)
end)

-- ============================================================
-- Services & Modules
-- ============================================================
local RemoteFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")
local remote = RemoteFolder:WaitForChild("RemoteEvent")
local remotefunction = RemoteFolder:WaitForChild("RemoteFunction")

local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local TimeUtil = require(ReplicatedStorage.Shared.Framework.Utilities.Math.Time)

-- ============================================================
-- DISABLE 3D RENDERING + SET RENDER DISTANCE TO 1
-- ============================================================
pcall(function() RunService:Set3dRenderingEnabled(false) end)

-- Force Chunker Render Distance to 1
local function setChunkerDistance()
    local mod
    pcall(function() mod = require(ReplicatedStorage.Shared.Utils.Chunker) end)
    if not mod or type(mod) ~= "table" then
        pcall(function() mod = require(ReplicatedStorage.Shared.Framework.Classes.Chunker) end)
    end
    if mod and type(mod) == "table" then
        if rawget(mod, "_BGSI_ULTIMATE_ORIG") == nil then
            mod._BGSI_ULTIMATE_ORIG = mod.Update
        end
        mod.Update = function(self, pos, ...)
            if type(self) == "table" then
                self.RenderDistance = 1
            end
            return mod._BGSI_ULTIMATE_ORIG(self, pos, ...)
        end
        print("[Ultimate] Chunker Render Distance set to 1")
    end
end

task.defer(function()
    for _ = 1, 40 do
        if setChunkerDistance() then return end
        task.wait(0.5)
    end
end)

-- ============================================================
-- NO HATCH ANIMATION
-- ============================================================
local HatchModule
pcall(function()
    HatchModule = require(ReplicatedStorage.Client.Effects.HatchEgg)
    if HatchModule and HatchModule.Play then
        local originalPlay = HatchModule.Play
        HatchModule.Play = function(self, result)
            if result and result.Pets then
                local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
                if gui:FindFirstChild("Hatching") then
                    gui.Hatching.Visible = false
                end
                if gui:FindFirstChild("HUD") then
                    gui.HUD.Visible = true
                end
                self._hatching = false
            end
        end
        print("[Ultimate] No Hatch Animation ENABLED")
    end
end)

-- ============================================================
-- Helper Functions
-- ============================================================
local function setHRPCFrame(cf)
    if typeof(cf) ~= "CFrame" or not player then return false end
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return false end
    hrp.CFrame = cf
    return true
end

local cachedMaxHatch, lastMaxHatchAt = nil, 0
local function getMaxHatchAmount()
    if cachedMaxHatch and tick() - lastMaxHatchAt < 5 then return cachedMaxHatch end
    local m
    pcall(function()
        if LocalData:IsReady() then
            local d = LocalData:Get()
            m = d and (d.MaxHatch or d.HatchLimit or d.HatchAmount or (d.Upgrades and d.Upgrades.HatchAmount) or (d.Stats and d.Stats.MaxHatch))
        end
    end)
    if type(m) ~= "number" or m < 1 then m = 80 end
    cachedMaxHatch, lastMaxHatchAt = m, tick()
    return m
end

local function fireHatch(egg)
    if type(egg) ~= "string" or egg == "" then return end
    pcall(function() remote:FireServer("HatchEgg", egg, getMaxHatchAmount()) end)
end

local function teleportToEggByName(name)
    if type(name) ~= "string" or name == "" then return false end
    
    -- Try saved locations first
    local saved = Config and Config.savedLocations and Config.savedLocations[name]
    if saved then
        local x = saved.X or saved.x
        local y = saved.Y or saved.y
        local z = saved.Z or saved.z
        if x and y and z then
            return setHRPCFrame(CFrame.new(x, y + 3, z))
        end
    end
    
    -- Try default Infinity Egg location
    if name == "Infinity Egg" then
        return setHRPCFrame(CFrame.new(-99, 9 + 3, -26))
    end
    
    -- Try live chunker model
    local rendered = workspace:FindFirstChild("Rendered")
    if rendered then
        local low = string.lower(name)
        for _, d in ipairs(rendered:GetDescendants()) do
            if d.Name == "Chunker" then
                for _, inst in ipairs(d:GetDescendants()) do
                    if inst:IsA("Model") and string.lower(inst.Name) == low then
                        local okCf, cf = pcall(function() return inst:GetPivot() end)
                        if okCf and typeof(cf) == "CFrame" then
                            return setHRPCFrame(cf + Vector3.new(0, 5, 0))
                        end
                    end
                end
            end
        end
    end
    
    return false
end

-- ============================================================
-- Cooldown Functions (for Obby)
-- ============================================================
local function getCooldownNow()
    if TimeUtil and type(TimeUtil.now) == "function" then
        local ok, t = pcall(function() return TimeUtil.now() end)
        if ok and type(t) == "number" then return t end
    end
    if workspace and type(workspace.GetServerTimeNow) == "function" then
        local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
        if ok and type(t) == "number" then return t end
    end
    return os.time()
end

local function getCooldownEndAt(cooldowns, name)
    if type(cooldowns) ~= "table" or type(name) ~= "string" then return nil end
    local direct = cooldowns[name]
    if type(direct) == "number" then return direct end
    local want = string.lower(name)
    for k, v in pairs(cooldowns) do
        if type(k) == "string" and type(v) == "number" and string.lower(k) == want then
            return v
        end
    end
    return nil
end

local function isOnCooldown(cooldowns, name)
    local endAt = getCooldownEndAt(cooldowns, name)
    if not endAt then return false end
    return getCooldownNow() < endAt
end

-- ============================================================
-- Medium Obby Configuration
-- ============================================================
local MEDIUM_OBBY = {
    Name = "Medium",
    PreStartCFrame = CFrame.new(-41529, 10, -20402),
    IslandCFrame = CFrame.new(-1124.33, 5919.76, 22570.72),
}

-- ============================================================
-- GLOBAL FLAGS
-- ============================================================
_G.Ultimate_ObbyActive = false
_G.Ultimate_LuckEggActive = false

-- ============================================================
-- Spam E Function
-- ============================================================
local spamERunning = false
local spamThread = nil

local function startSpamE()
    if spamERunning then return end
    spamERunning = true
    spamThread = task.spawn(function()
        while spamERunning do
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.01)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.01)
            VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait(0.01)
            VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            task.wait(0.01)
        end
    end)
end

local function stopSpamE()
    spamERunning = false
    if spamThread then
        spamThread = nil
    end
end

-- ============================================================
-- AUTO HATCH INFINITY EGG
-- ============================================================
task.spawn(function()
    local lastTp = 0
    while true do
        task.wait(0)
        
        if _G.Ultimate_ObbyActive or _G.Ultimate_LuckEggActive then
            lastTp = 0
            if _G.Ultimate_LuckEggActive then
                task.wait(0.1)
            else
                task.wait(0.5)
            end
            continue
        end
        
        local char = player and player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.2)
            continue
        end
        
        if tick() - lastTp >= 10 then
            pcall(function() teleportToEggByName("Infinity Egg") end)
            lastTp = tick()
        end
        
        fireHatch("Infinity Egg")
    end
end)

-- ============================================================
-- AUTO 4X LUCK EGG
-- ============================================================
task.spawn(function()
    local lastTp = 0
    while true do
        task.wait(0)
        
        local summoned = workspace:FindFirstChild("SummonedEgg")
        local platform = summoned and summoned:FindFirstChild("EggPlatformSpawn")
        
        if not platform then
            if _G.Ultimate_LuckEggActive then
                _G.Ultimate_LuckEggActive = false
                lastTp = 0
            end
            task.wait(0.5)
            continue
        end
        
        _G.Ultimate_LuckEggActive = true
        
        local char = player and player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(0.2)
            continue
        end
        
        if tick() - lastTp >= 5 then
            local part = platform:IsA("BasePart") and platform or platform:FindFirstChildWhichIsA("BasePart", true)
            if part then
                pcall(function() hrp.CFrame = part.CFrame + Vector3.new(0, 3, -5) end)
                lastTp = tick()
            end
        end
        
        pcall(function()
            remote:FireServer("HatchEgg", "4x Luck Plushie Egg", getMaxHatchAmount())
        end)
    end
end)

-- ============================================================
-- MEDIUM OBBY LOOP
-- ============================================================
local function mediumObbyLoop()
    local lastFireAt = 0
    
    while true do
        if not LocalData or not LocalData.IsReady then
            task.wait(1)
            continue
        end
        
        local ok, data = pcall(function() return LocalData:Get() end)
        if not ok or type(data) ~= "table" then
            task.wait(1)
            continue
        end
        
        local cooldowns = data.ObbyCooldowns
        if type(cooldowns) == "table" and isOnCooldown(cooldowns, "Medium") then
            if not _G.Ultimate_LuckEggActive and not spamERunning then
                startSpamE()
            end
            task.wait(1)
            continue
        end
        
        if spamERunning then
            stopSpamE()
        end
        
        local now = tick()
        if now - lastFireAt < 12 then
            task.wait(1)
            continue
        end
        
        _G.Ultimate_ObbyActive = true
        
        pcall(function()
            setHRPCFrame(MEDIUM_OBBY.PreStartCFrame)
        end)
        task.wait(0.75)
        
        local burstEnd = tick() + 1
        while tick() < burstEnd do
            pcall(function() remote:FireServer("StartObby", MEDIUM_OBBY.Name) end)
            task.wait(0)
        end
        
        task.wait(1)
        pcall(function()
            setHRPCFrame(MEDIUM_OBBY.IslandCFrame)
        end)
        
        task.wait(3)
        
        lastFireAt = tick()
        _G.Ultimate_ObbyActive = false
        
        if not _G.Ultimate_LuckEggActive and not spamERunning then
            startSpamE()
        end
        
        task.wait(2)
    end
end

-- ============================================================
-- DREAMER SHRINE (Donates 1 Dream Shard)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            remotefunction:InvokeServer("DonateToDreamerShrine", 1)
        end)
        task.wait(5)
    end
end)

-- ============================================================
-- BUBBLE SHRINE (Donates 100 Speed Potions Level 2)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            remotefunction:InvokeServer("DonateToShrine", {
                Level = 2,
                Type = "Potion",
                Name = "Speed",
                Amount = 100,
            })
        end)
        task.wait(5)
    end
end)

-- ============================================================
-- Start the script
-- ============================================================
task.spawn(mediumObbyLoop)
task.wait(1)
startSpamE()

print("========================================")
print("[Ultimate] Running!")
print("  - 3D Rendering: DISABLED")
print("  - Render Distance: 1")
print("  - No Hatch Animation: ENABLED")
print("  - Dreamer Shrine: 1 Dream Shard")
print("  - Bubble Shrine: 100 Speed Potions Lv2")
print("========================================")

-- ============================================================
-- Keep the script alive
-- ============================================================
while true do
    task.wait(60)
end
