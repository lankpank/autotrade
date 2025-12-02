local pets = {
    -- Existing
    "OG Morning Star",
    "Flake Spirit",
    "OG Soulflake",
    "Kuuhenki",
    "Giant DOOF",
    "Rudolph Shock",
    "Cursed King",
    "Santa's Giftbag",
    "OG Holy Bell",
    "King Spitty",
    "Grand Guardian",
    "God Tamer",
    "Guardian Angel",
    "Shadow Raven",
    "OG Lucky Pyramidium",
    "OG Hellshard",
    "OG Overlord Plushie",

    -- ⭐ OG Secrets
    

    -- ⭐ Replaced Basilisks




    -- ⭐ Food Egg
    "Infinity Wisp",


    -- ⭐ Other
    "The Infinity Gem",
    "OG Radiant One",
    "OG Angelic Ghost Spirit",
    "OG Demonic Ghost Spirit",
    "OG Cardinal Bunny",
    "Giant NULLvoid",
    "OG Demoncore"

}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local HttpRequest = (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request) or (krnl and request)

-- ⭐ NEW WEBHOOK
local webhook = "https://discord.com/api/webhooks/1439362633932345626/GEgEz-DMscb8xFJ1rY4uQrWzlPVqZACR0XtKkpiFUMEQBDUQ0zh5JGS6_x8vEhSwz5x-"

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

-- 🧩 Variants with prefixes and proper lookup names
local variants = {
    {"", "", ""},                -- Normal
    {"s ", "s ", "Shiny "},      -- Shiny
    {"m ", "m ", "Mythic "},     -- Mythic
    {"sm ", "sm ", "Shiny Mythic "} -- Shiny Mythic
}

-- 🕒 Main scan function
local function runScan()
    sendToWebhook("⏳ Starting fetch of **selected secret pet variants**, including 0s and nils...")

    local existsLines = {}
    local totalPets = #pets
    local scanned = 0

    for _, petName in ipairs(pets) do
        local simplifiedName = petName:lower():gsub("%s+", " ")

        for _, variant in ipairs(variants) do
            local _, cmdPrefix, searchPrefix = unpack(variant)
            local variantName = searchPrefix .. petName
            local count = "nil"

            local ok, res = pcall(function()
                return Remote:InvokeServer("GetExisting", variantName)
            end)

            if ok then
                count = tostring(res or "nil")
            end

            local line = string.format("!edit exists %s%s %s", cmdPrefix, simplifiedName, count)
            table.insert(existsLines, line)
        end

        table.insert(existsLines, "")
        scanned += 1

        if scanned % 5 == 0 or scanned == totalPets then
            sendToWebhook(("🔄 Progress: %d/%d pets scanned (variants included)..."):format(scanned, totalPets))
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

    sendToWebhook("✅ Done! `.txt` file with **pet command lines** has been sent.")
end

-- 🔁 Auto loop every 1 hour
while true do
    runScan()
    sendToWebhook("🕒 Next scan in 1 hour...")
    task.wait(3600)
end
