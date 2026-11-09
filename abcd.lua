local pets = {
    "The King of the Dark Crop",
    "Sinister P",
    "Gothic Shard",
    "Phantom Robot",
    "Vampire Slime",
    "Vampire Lord",
    "Witchdeeri",
    "Hallowed Lord",
    "Skull Cauldron",
    "Blizzeria Pumpkin",
    "Doomsekkar",
    "Harvest Koi",
    "Harvest Rigby",
    "Fall Gryphon",
    "Angelic Pumpkin",
    "Dark Swan",
    "Dark Mariposa",
    "Guild Star",
    "Dark Robot",
    "Dowodle Elemental",
    "DOWODLE FACE GOD",
    "Cloudy Koi",
    "Rainbow Elemental",
    "Rainbow Shard",
    "Rift Seeker",
    "Elite Champion",
    "Radiant Dragon",
    "Radiant Seeing Eye",
    "Darkburst",
    "Elite Dragon",
    "Shadow Radiance",
    "Shadowshard",
    "Jester Seal",
    "Patriotic Koi",
    "Patriotic Basilisk",
    "Patriotic Gem",
    "Patriotic Rigby",
    "Jester Elephant Plushie",
    "Pandamni",
    "Dark Matter Raven",
    "Hacker Pyramidimum",
    "Dominus Overlord",
    "Big Hyperwave Bunny",
    "H y p e r w a v e",
    "Hyperwave Shard",
    "Royal Tamer",
    "Aquarium",
    "FLOWER FACE GOD",
    "Sea Dragon",
    "Sunflower Shard",
    "Summer Rigby",
    "Solar Phoenix",
    "Lemon Shark",
    "Golden Seal",
}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local HttpRequest = (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request) or (krnl and request)

local webhook = "https://discord.com/api/webhooks/1443518513934237706/SYlpNc5bZqXECZAYf98HD5yjrIZqmsKhSyzTArormuUv_V5HAZWB7nv2yQxufw0ix4v7"

if not webhook:lower():match("^https://") then
    error("Invalid webhook URL. Must start with https://")
end

local function sendToWebhook(text)
    HttpRequest({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({content = text})
    })
end

-- ✅ All 4 variants, always scanned for every pet
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

local function runScan()
    sendToWebhook("⏳ Starting fetch of **selected secret pet variants**...")

    local existsLines = {}
    local totalPets = #pets
    local scanned = 0

    for _, petName in ipairs(pets) do
        for _, prefix in ipairs(variants) do
            local variantName = prefix .. petName
            local count = 0

            local ok, res = pcall(function()
                return Remote:InvokeServer("GetExisting", variantName)
            end)

            if ok and res ~= nil then
                count = tonumber(res) or 0
            end

            -- ✅ Format: "Name 0 -> COUNT exist"
            local line = string.format("%s 0 -> %d exist", variantName, count)
            table.insert(existsLines, line)
        end

        scanned += 1

        if scanned % 5 == 0 or scanned == totalPets then
            sendToWebhook(("🔄 Progress: %d/%d pets scanned..."):format(scanned, totalPets))
        end
    end

    local output = table.concat(existsLines, "\n")

    local boundary = "------------------------" .. tostring(math.random(1000000000000000, 9999999999999999))
    local body = ""
    body ..= "--" .. boundary .. "\r\n"
    body ..= 'Content-Disposition: form-data; name="file"; filename="exists.txt"\r\n'
    body ..= "Content-Type: text/plain\r\n\r\n"
    body ..= output .. "\r\n"
    body ..= "--" .. boundary .. "--\r\n"

    HttpRequest({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
        Body = body
    })

    sendToWebhook("✅ Done! `.txt` file with updated format has been sent.")
end

-- 🔂 Execute once
runScan()
sendToWebhook("🕒 Scan complete. Script will not loop again.")
