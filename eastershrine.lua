-- FIXED: AUTO EASTER SHRINE with proper claim detection
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local EasterShrine = require(ReplicatedStorage.Shared.Shrines.EasterShrine)
local TimeUtil = require(ReplicatedStorage.Shared.Framework.Utilities.Math.Time)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- CONFIGURATION
local WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL_HERE"

-- Universal request function
local function sendWebhook(message)
    if not WEBHOOK_URL or WEBHOOK_URL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then 
        return false 
    end
    
    local requestFunc = (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request) or (request) or (krnl and krnl.request)
    
    if not requestFunc then
        return false
    end
    
    local data = {
        content = message,
        username = LocalPlayer.Name .. " - Auto Shrine",
    }
    
    pcall(function()
        requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    return true
end

print("═══════════════════════════════════")
print("🌸 AUTO EASTER SHRINE - FIXED")
print("═══════════════════════════════════")

local isClaiming = false
local totalBuffsClaimed = 0

-- Get active buff info
local function getBuffInfo()
    local playerData = LocalData:Get()
    if not playerData then return nil end
    
    local shrine = playerData.EasterShrine
    if not shrine then return nil end
    
    local now = TimeUtil.now()
    local buffEndTime = shrine.StartTime + EasterShrine.Duration
    
    if shrine.Buff and buffEndTime > now then
        return {
            buff = shrine.Buff,
            egg = shrine.Egg,
            timeLeft = buffEndTime - now,
            multiplier = EasterShrine.BuffPool and EasterShrine.BuffPool[shrine.Buff] and EasterShrine.BuffPool[shrine.Buff].Multiplier or 1
        }
    end
    
    return nil
end

-- Donate potions
local function donate(amount)
    if amount <= 0 then return true end
    local success = pcall(function()
        return Remote:InvokeServer("DonateToEasterShrine", "Speed", 6, amount)
    end)
    return success
end

-- Claim buff (with cooldown to prevent spam)
local function claim()
    if isClaiming then 
        print("⚠️ Already claiming, waiting...")
        return false 
    end
    
    isClaiming = true
    local success = pcall(function()
        return Remote:FireServer("ClaimEasterShrineBuff")
    end)
    
    task.wait(3) -- Wait for server to process
    isClaiming = false
    return success
end

-- Get current XP
local function getXP()
    local playerData = LocalData:Get()
    if not playerData or not playerData.EasterShrine then return 0 end
    return playerData.EasterShrine.XPOffered or 0
end

-- Main loop
local AUTO_ENABLED = true
local CHECK_INTERVAL = 30
local lastClaimAttempt = 0
local claimCooldown = 60 -- Don't retry claim for 60 seconds if it fails

task.spawn(function()
    print("✅ Auto Easter Shrine Running!")
    sendWebhook("🌸 Auto Easter Shrine started for **" .. LocalPlayer.Name .. "**")
    
    while AUTO_ENABLED do
        local buffInfo = getBuffInfo()
        
        if buffInfo then
            -- BUFF IS ACTIVE - Good! Just wait
            local hours = math.floor(buffInfo.timeLeft / 3600)
            local minutes = math.floor((buffInfo.timeLeft % 3600) / 60)
            print(string.format("✨ Buff active: %s (%dh %dm left) - Applies to: %s", 
                buffInfo.buff, hours, minutes, buffInfo.egg or "Unknown"))
            task.wait(CHECK_INTERVAL)
            
        else
            -- NO BUFF ACTIVE - Check if we need to build XP or claim
            local currentXP = getXP()
            local neededXP = EasterShrine.XPRequired - currentXP
            
            print(string.format("📊 Current XP: %d / %d (Need: %d)", currentXP, EasterShrine.XPRequired, neededXP))
            
            if neededXP <= 0 then
                -- XP is full, but no buff active - try to claim
                local now = os.time()
                if now - lastClaimAttempt >= claimCooldown then
                    print("🎯 XP FULL! Attempting to claim buff...")
                    sendWebhook("🎯 XP FULL! Attempting to claim buff for **" .. LocalPlayer.Name .. "**")
                    
                    local success = claim()
                    if success then
                        print("✅ Claim attempted! Waiting for buff to register...")
                        task.wait(5)
                        
                        -- Check if buff appeared
                        local newBuff = getBuffInfo()
                        if newBuff then
                            totalBuffsClaimed = totalBuffsClaimed + 1
                            print(string.format("🎉 SUCCESS! Got %s buff for %s!", newBuff.buff, newBuff.egg))
                            sendWebhook(string.format("🎉 **%s** claimed **%s** buff for **%s**! (Total: %d)", 
                                LocalPlayer.Name, newBuff.buff, newBuff.egg or "Unknown Egg", totalBuffsClaimed))
                        else
                            print("⚠️ Claimed but buff not detected yet...")
                        end
                        lastClaimAttempt = now
                    else
                        print("❌ Claim failed! Will retry later.")
                        lastClaimAttempt = now
                    end
                else
                    print(string.format("⏳ Waiting %d seconds before retrying claim...", claimCooldown - (now - lastClaimAttempt)))
                end
                task.wait(30)
            else
                -- Need more XP, donate potions
                local potionsNeeded = math.ceil(neededXP / 5000)
                local potionsToDonate = math.min(potionsNeeded, 50)
                
                if potionsToDonate > 0 then
                    print(string.format("📦 Donating %d Speed Lv6 potions (Need %d more XP)", potionsToDonate, neededXP))
                    donate(potionsToDonate)
                else
                    print("⚠️ No potions to donate?")
                end
                task.wait(10)
            end
        end
    end
end)

-- Manual check
local function checkStatus()
    local buffInfo = getBuffInfo()
    local currentXP = getXP()
    local percent = (currentXP / EasterShrine.XPRequired) * 100
    
    print("\n═══════════════════════════════════")
    print("🌸 EASTER SHRINE STATUS")
    print("═══════════════════════════════════")
    
    if buffInfo then
        local hours = math.floor(buffInfo.timeLeft / 3600)
        local minutes = math.floor((buffInfo.timeLeft % 3600) / 60)
        print(string.format("✨ BUFF: %s (+%.2fx luck)", buffInfo.buff, buffInfo.multiplier))
        print(string.format("🥚 Applies to: %s", buffInfo.egg or "Unknown Egg"))
        print(string.format("⏰ Time left: %dh %dm", hours, minutes))
    else
        print("✨ No active buff")
        print(string.format("📊 Progress: %.1f%% (%d / %d XP)", percent, currentXP, EasterShrine.XPRequired))
        local needed = EasterShrine.XPRequired - currentXP
        if needed > 0 then
            print(string.format("📦 Need %d XP (%d Speed Lv6 potions)", needed, math.ceil(needed/5000)))
        else
            print("🎯 XP full - Ready to claim!")
        end
    end
    
    print(string.format("🏆 Total buffs claimed: %d", totalBuffsClaimed))
    print("═══════════════════════════════════")
end

print("\n💡 Commands:")
print("   checkStatus() - Check current status")
print("\n✅ Fixed! Now:")
print("   • Only claims ONCE when XP is full")
print("   • Waits to verify buff is active")
print("   • Won't spam claim attempts")
print("   • Cooldown between claim retries")
print("═══════════════════════════════════")
