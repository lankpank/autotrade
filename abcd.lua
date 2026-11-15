
local pets = {
    "67 GOD",
    "Angelic Essence",
    "Angelus",
    "Avernus",
    "BGSI Trophy",
    "Blossom Chime",
    "Diamond Trophy",
    "Fabergé",
    "Guiding Light",
    "Harvest Deeri",
    "Inferno Gem",
    "Infinity Star",
    "Mystic Prophet",
    "Nekomata",
    "Neon Dragon",
    "Neon Overlord",
    "Neon Pyramidium",
    "Neon Seeker",
    "Nightseeker",
    "OG Angelic Spirit",
    "OG Easter Robot",
    "OG Giant Chocolate Chicken",
    "OG King Doggy",
    "OG King Kitty",
    "OG Patriotic Robot",
    "Patriotic Koi",
    "Pisces Twins",
    "Pot O' Gems",
    "Queen Butterfly",
    "Queen Wasp",
    "Radiancy",
    "Radiant Champion",
    "Radiant Seeing Eye",
    "Rainbow Dogcat",
    "Rainbow Shard",
    "Rainshine",
    "Resurrection",
    "Revelation",
    "Rift Seeker",
    "Ruby Crystal Dragon",
    "Ruby Trophy",
    "S E A L",
    "Sakura Koi",
    "Sapphire Crystal Dragon",
    "Shade Demon",
    "Shadow Overlord",
    "Shadow Radiance",
    "Shadow Soul",
    "Shadowstone",
    "Shining Radiance",
    "Skyward Harp",
    "Solar Phoenix",
    "Soul Jam",
    "Sparkle Sundae Champion",
    "Spirit Jam",
    "STAR OF LEGEND",
    "Stargazer",
    "Sunflower Shard",
    "Super Ancient One",
    "Super Leviathan",
    "Supreme Clover",
    "Taffy Dragon",
    "Techarium",
    "The Celestial Dragon",
    "The Dahlia",
    "The Death",
    "The Devil",
    "The Doodlementor",
    "The Dormouse",
    "The Duality",
    "The Duallord",
    "The Fallen Guardian",
    "The First Sentinel",
    "The Hermit",
    "The Lovers",
    "Trifolium Spirit",
    "Unicorn Plushie",
    "Vaporwave Elemental",
    "Vaporwave Soul",
    "VOID GUARDIAN",
    "VOID HEART",
    "VOID RADIANCE",
    "VOID SHADOW LEVIATHAN",
    "VOID SKULL",
    "VOID TYRANT",
    "VOIDIUM",
    "Watcher of Radiance",
    "The Elder",
}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local HttpRequest =
    (http and http.request)
    or (syn and syn.request)
    or (fluxus and fluxus.request)
    or (krnl and request)

-- EDIT YOUR WEBHOOK HERE
local webhook = ""

if not HttpRequest then
    error("HTTP request function not found.")
end

if webhook == "" or not webhook:lower():match("^https://") then
    error("Invalid webhook URL. Please enter your Discord webhook.")
end

local function sendToWebhook(message)
    HttpRequest({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            content = message
        })
    })
end

-- All 8 variants
local variants = {
    "",
    "Shiny ",
    "Mythic ",
    "Shiny Mythic ",
    "XL ",
    "XL Shiny ",
    "XL Mythic ",
    "XL Shiny Mythic "
}

-- Main scanning function
local function runScan()
    sendToWebhook(
        "⏳ Starting fetch of **selected pet variants**..."
    )

    local existsLines = {}
    local totalPets = #pets
    local scanned = 0

    for _, petName in ipairs(pets) do
        for _, prefix in ipairs(variants) do
            local variantName = prefix .. petName
            local count = "nil"

            local ok, res = pcall(function()
                return Remote:InvokeServer(
                    "GetExisting",
                    variantName
                )
            end)

            if ok and res ~= nil then
                count = tostring(res)
            end

            -- Full pet name + existing count
            table.insert(
                existsLines,
                string.format("%s %s", variantName, count)
            )
        end

        scanned += 1

        -- Progress notification every 5 pets
        if scanned % 5 == 0 or scanned == totalPets then
            sendToWebhook(
                ("🔄 Progress: %d/%d pets scanned..."):format(
                    scanned,
                    totalPets
                )
            )
        end
    end

    -- Convert results into TXT content
    local output = table.concat(existsLines, "\n")

    -- Generate multipart upload
    local boundary = "------------------------"
        .. tostring(
            math.random(1000000000000000, 9999999999999999)
        )

    local body = ""
    body ..= "--" .. boundary .. "\r\n"
    body ..= 'Content-Disposition: form-data; name="file"; filename="exists.txt"\r\n'
    body ..= "Content-Type: text/plain\r\n\r\n"
    body ..= output .. "\r\n"
    body ..= "--" .. boundary .. "--\r\n"

    -- Upload TXT file to Discord
    HttpRequest({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] =
                "multipart/form-data; boundary=" .. boundary
        },
        Body = body
    })

    sendToWebhook(
        "✅ Scan complete! Updated `exists.txt` uploaded."
    )
end

-- Execute ONCE only
local ok, err = pcall(runScan)

if not ok then
    warn("Pet scan failed: " .. tostring(err))
    pcall(
        sendToWebhook,
        "❌ Scan failed: " .. tostring(err)
    )
else
    sendToWebhook(
        "✅ Scan complete. Script will not run again."
    )
end
