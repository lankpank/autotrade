local HttpService = game:GetService("HttpService")

-- 🔗 Your webhook URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1437859696227913940/BjXtAao0TReaQAyRvkvGmBmHOuQnSncMlszz0TyY5pCEK71t5wdJ02H1_ydsSfK2K53t"

-- Pick any available request function
local requestFunc =
    (syn and syn.request)
    or (http and http.request)
    or (http_request)
    or (fluxus and fluxus.request)
    or nil

if not requestFunc then
    warn("⚠️ No supported HTTP request function found (syn/http/fluxus).")
end

-- Secret bounty logic
local function SecretBounty(daysAhead)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RiftsData, EggsData

    local success = pcall(function()
        RiftsData = require(ReplicatedStorage.Shared.Data.Rifts)
        EggsData = require(ReplicatedStorage.Shared.Data.Eggs)
    end)

    if not success then
        return nil
    end

    local secretBounties = {
        { Name = "King Leviathan", Chance = 2e-8 },
        { Name = "Harmonic Harp", Chance = 2e-7 },
        { Name = "Axolotl Army", Chance = 1e-7 },
    }

    local possibleEggs = { "Common Egg" }
    for _, riftInfo in pairs(RiftsData) do
        if riftInfo.Type == "Egg" then
            local eggData = EggsData[riftInfo.Egg]
            if eggData and eggData.World and eggData.Island then
                table.insert(possibleEggs, riftInfo.Egg)
            end
        end
    end

    local secondsInDay = 86400
    local todaySeed = math.floor(os.time() / secondsInDay) - 1
    local targetSeed = todaySeed + (daysAhead or 0)

    local rng_prev = Random.new(targetSeed - 1)
    local rng_today = Random.new(targetSeed)

    local prev_bountyIndex = rng_prev:NextInteger(1, #secretBounties)
    local bountyIndex = rng_today:NextInteger(1, #secretBounties)
    if bountyIndex == prev_bountyIndex then
        bountyIndex = bountyIndex % #secretBounties + 1
    end

    local prev_eggIndex = rng_prev:NextInteger(1, #possibleEggs)
    local eggIndex = rng_today:NextInteger(1, #possibleEggs)
    if eggIndex == prev_eggIndex then
        eggIndex = eggIndex % #possibleEggs + 1
    end

    local currentBounty = secretBounties[bountyIndex]
    local currentEgg = possibleEggs[eggIndex]

    return {
        Name = currentBounty.Name,
        Egg = currentEgg,
        Chance = currentBounty.Chance,
        DayOffset = daysAhead or 0
    }
end

-- 🧮 Helper for formatted date (e.g., "Nov 12th")
local function getFormattedDate(offset)
    local time = os.time() + (offset * 86400)
    local day = tonumber(os.date("!%d", time))
    local suffix = "th"
    if day % 10 == 1 and day ~= 11 then suffix = "st"
    elseif day % 10 == 2 and day ~= 12 then suffix = "nd"
    elseif day % 10 == 3 and day ~= 13 then suffix = "rd" end
    return os.date("!%b ", time) .. day .. suffix
end

-- 📨 Send to webhook (using exploit-supported request)
local function sendToWebhook(bountyTable)
    local content = "**🎯 Secret Bounty Forecast (Next 21 Days)**\n```"
    for _, bounty in ipairs(bountyTable) do
        local dayLabel = (bounty.DayOffset == 0) and "Today" or ("Day +" .. bounty.DayOffset)
        local dateLabel = getFormattedDate(bounty.DayOffset)
        content ..= string.format("[%s | %s] %s — Egg: %s — Chance: %.2e\n",
            dayLabel, dateLabel, bounty.Name, bounty.Egg, bounty.Chance)
    end
    content ..= "```\n"

    local payload = HttpService:JSONEncode({
        content = content
    })

    if requestFunc then
        local response = requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })

        if response and (response.StatusCode == 204 or response.Success) then
            print("[✅] Sent bounty forecast to Discord!")
        else
            warn("[❌] Webhook request failed!", response and response.StatusMessage or "No response")
        end
    else
        warn("⚠️ No valid HTTP request function found!")
    end
end

-- 🧭 Generate & send forecast
local allBounties = {}
for day = 0, 20 do
    local bounty = SecretBounty(day)
    if bounty then
        table.insert(allBounties, bounty)
    end
end

sendToWebhook(allBounties)
