local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteFunction")

local args = { 
    "DonateToShrine",
    {
        Type = "Potion",
        Level = 5, 
        Name = "Speed",
        Amount = 100 
    }
}

-- Repeat forever, once every 3600 seconds (1 hour)
while true do
    RemoteFunction:InvokeServer(unpack(args))
    print("Donated to shrine at " .. os.date("%X"))
    task.wait(3600) -- wait for 1 hour
end 

