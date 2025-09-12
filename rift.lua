wait(3)

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local localUsername = player.Name

local ACCOUNT_LABEL = "HopyHopHop"
local MAX_PLAYER_COUNT = 9
local RIFT_NAME = "brainrot-egg"
local RIFT_PATH = workspace.Rendered.Rifts
local MAIN_LOOP_DELAY = 10
local HOP_COOLDOWN = 10

-- Webhooks
local w_main = "https://discord.com/api/webhooks/1415718364055077025/_cblNWmsQS35E-1xCz-CQWYMbiKm4aFncF_0ngpDsavEPFPbfL5QUE1nP7kmk2xWzy1V"
local w_notify = "https://discord.com/api/webhooks/1415341588015612045/ve6HgH8seupCcDkmyBXjqIPoW0kywwS8knvpDDfTgbwMl8KZoEZGZIPBs3Jptu8Cvyby"

local isHopping = false

-- Sends a payload to a Discord webhook
local function sendWebhook(targetUrl, payload)
    local requestBody = HttpService:JSONEncode(payload)
    local requestOptions = {
        Url = targetUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = requestBody
    }
    pcall(function()
        if syn and syn.request then
            return syn.request(requestOptions)
        elseif request then
            return request(requestOptions)
        elseif http and http.request then
            return http.request(requestOptions)
        else
            warn("No known client-side HTTP function found.")
        end
    end)
end

-- Checks if the rift exists and has a Display part
local function isRiftValid(riftName)
    local rift = RIFT_PATH:FindFirstChild(riftName)
    if rift and rift:FindFirstChild("Display") and rift.Display:IsA("BasePart") then
        return rift
    end
    return nil
end

-- Finds a non-full server and teleports
local function hopServers()
    if isHopping then
        print("Hop already in progress. Waiting...")
        return
    end
    isHopping = true
    print("Finding a random, non-full server...")

    local potentialServers = {}
    local success, body = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
        ))
    end)

    if success and body and body.data then
        for _, serverInfo in ipairs(body.data) do
            local playerCount = tonumber(serverInfo.playing)
            if playerCount and serverInfo.id ~= game.JobId and playerCount < MAX_PLAYER_COUNT then
                table.insert(potentialServers, serverInfo)
            end
        end

        if #potentialServers > 0 then
            local targetServer = potentialServers[math.random(1, #potentialServers)]
            local message = string.format(
                "%s V7.4 | User **%s** is hopping randomly.\n> **From:** %s\n> **To:** %s\n> **Players:** %d/%d",
                ACCOUNT_LABEL, localUsername, game.JobId, targetServer.id, targetServer.playing, targetServer.maxPlayers
            )
            sendWebhook(w_notify, {content = message})
            wait(1)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, Players.LocalPlayer)
            end)
        else
            print("No new servers found. Falling back.")
            pcall(function() TeleportService:Teleport(game.PlaceId, Players.LocalPlayer) end)
        end
    else
        warn("API hop failed. falling back.")
        pcall(function() TeleportService:Teleport(game.PlaceId, Players.LocalPlayer) end)
    end

    task.delay(HOP_COOLDOWN, function()
        print("Hop cooldown finished. ready for next hop!!!")
        isHopping = false
    end)
end

-- Checks for the rift and sends Discord webhook
local function checkAndReportRift()
    local riftInstance = isRiftValid(RIFT_NAME)
    if not riftInstance then return nil end

    print("'Display' part found. reporting.")

    local discordTimestampValue = ""
    local luckValue = ""

    local surfaceGui = riftInstance.Display:FindFirstChild("SurfaceGui")
    local timerGui = surfaceGui and surfaceGui:FindFirstChild("Timer")
    if timerGui and timerGui:IsA("TextLabel") then
        local timerText = timerGui.Text
        local minutes = tonumber(string.match(timerText, "(%d+) ?m")) or 0
        local seconds = tonumber(string.match(timerText, "(%d+) ?s")) or 0
        if (minutes + seconds) > 0 then
            discordTimestampValue = string.format("<t:%d:R>", os.time() + (minutes * 60) + seconds)
        end
    end

    local iconPart = riftInstance.Display:FindFirstChild("Icon")
    local luckLabel = iconPart and iconPart:FindFirstChild("Luck")
    if luckLabel and luckLabel:IsA("TextLabel") then
        luckValue = luckLabel.Text
    end

    local height, gameId, jobId = math.floor(riftInstance.Display.Position.Y), game.PlaceId, game.JobId
    local joinLink = "roblox://experiences/start?placeId=" .. gameId .. "&gameInstanceId=" .. jobId
    local teleportScript = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', gameId, jobId)
    local playerCount = #Players:GetPlayers()

    local embedFields = {
        { ["name"] = "Found By", ["value"] = localUsername .. " (" .. ACCOUNT_LABEL .. ")", ["inline"] = false },
        { ["name"] = "Rift Height", ["value"] = tostring(height) .. " meters", ["inline"] = false },
        { ["name"] = "Players", ["value"] = string.format("%d/12", playerCount), ["inline"] = false }
    }

    if luckValue and luckValue ~= "" then
        table.insert(embedFields, {["name"] = "Luck", ["value"] = luckValue, ["inline"] = false})
    end
    if discordTimestampValue and discordTimestampValue ~= "" then
        table.insert(embedFields, {["name"] = "Ends", ["value"] = discordTimestampValue, ["inline"] = false})
    end
    table.insert(embedFields, { ["name"] = "Direct Server Link", ["value"] = "```\n" .. joinLink .. "\n```", ["inline"] = false })
    table.insert(embedFields, { ["name"] = "Teleport Script", ["value"] = "```lua\n" .. teleportScript .. "\n```", ["inline"] = false })

    local payload = {
        ["embeds"] = {{
            ["title"] = RIFT_NAME .. " Found!",
            ["description"] = "A rift has been located.",
            ["color"] = 65280,
            ["fields"] = embedFields,
            ["footer"] = { ["text"] = "Webhook v7.4" }
        }}
    }

    sendWebhook(w_main, payload)
    wait(0.5)
    sendWebhook(w_main, {content = joinLink})

    return riftInstance
end

-- Main loop
print("script started.")
while wait(MAIN_LOOP_DELAY) do
    local riftInstance = checkAndReportRift()
    
    if riftInstance then
        print("Rift found. Reporting, but still hopping...")
    else
        print("Rift not found. Hopping...")
    end
    
    hopServers()
end
