local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local url = "https://raw.githubusercontent.com/lankpank/mmm/main/servers.json"
local placeId = game.PlaceId
local currentServerId = game.JobId
local webhookUrl = "https://discord.com/api/webhooks/1415341588015612045/ve6HgH8seupCcDkmyBXjqIPoW0kywwS8knvpDDfTgbwMl8KZoEZGZIPBs3Jptu8Cvyby"

-- Send message to Discord
local function sendWebhook(msg)
    pcall(function()
        HttpService:PostAsync(
            webhookUrl,
            HttpService:JSONEncode({content = msg}),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

-- Fetch servers.json from GitHub
local function getServers()
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        return HttpService:JSONDecode(result)
    else
        warn("❌ Failed to fetch servers:", result)
        sendWebhook("❌ Failed to fetch servers.json")
        return {}
    end
end

-- Pick a random valid server (not current, not full)
local function pickServer(servers)
    local candidates = {}
    for _, server in ipairs(servers) do
        if server.id ~= currentServerId and server.playing < server.maxPlayers then
            table.insert(candidates, server)
        end
    end
    if #candidates > 0 then
        return candidates[math.random(1, #candidates)]
    end
end

-- Keep trying until teleport works
local function loopTeleport()
    task.wait(20) -- ⏳ wait 20 seconds before starting
    while true do
        local servers = getServers()
        local target = pickServer(servers)

        if target then
            sendWebhook("🌍 Attempting to TP from **" .. currentServerId .. "** → **" .. target.id .. "**")
            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
            end)

            if success then
                sendWebhook("✅ Teleport started: **" .. currentServerId .. "** → **" .. target.id .. "**")
                break -- stop loop once teleport fires
            else
                warn("⚠️ Teleport failed:", err)
                sendWebhook("⚠️ Teleport failed: " .. tostring(err) .. " | Retrying in 5s...")
            end
        else
            warn("⚠️ No suitable servers found.")
            sendWebhook("⚠️ No suitable servers found. Retrying in 5s...")
        end

        task.wait(5) -- retry after 5s
    end
end

-- Run it
loopTeleport()
