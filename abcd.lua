local pets = {
-- Core drops
"Crowned Soul",
"Majesty",

-- Lucky Catcher line
"Royal Gemstone",
"VOID GUARDIAN",
"Patriotic Robot 2.0",
"Firework God",
"Liberty Torch",

-- Shop / special
"Patriotic Star",
"Patriotic Overlord",
"Patriotic Mush",
"Giant Lemonade Master",

-- Season / pass
"Sparkle Sundae Champion",
"Sunken Treasure",
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

-- ✅ Full variant names only (no shortcuts)
local variants = {
    "", 
    "Shiny ",
    "Mythic ",
    "Shiny Mythic "
}

local function runScan()
    sendToWebhook("⏳ Starting fetch of **selected secret pet variants**...")

    local existsLines = {}
    local totalPets = #pets
    local scanned = 0

    for _, petName in ipairs(pets) do
        for _, prefix in ipairs(variants) do
            local variantName = prefix .. petName
            local count = "nil"

            local ok, res = pcall(function()
                return Remote:InvokeServer("GetExisting", variantName)
            end)

            if ok then
                count = tostring(res or "nil")
            end

            -- ✅ New format
            local line = string.format("/updateexists name:%s exists:%s", variantName, count)
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

-- 🔁 Loop every 1 hour
while true do
    runScan()
    sendToWebhook("🕒 Next scan in 1 hour...")
    task.wait(3600)
end
