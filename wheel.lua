local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CHECK_INTERVAL = 0.1
local SPIN_DELAY = 0.1

local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local ItemUtil = require(ReplicatedStorage.Shared.Utils.Stats.ItemUtil)
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local TICKET_ITEM = { Type = "Powerup", Name = "Valentine's Spin Ticket", Amount = 1 }

task.spawn(function()
    task.wait(7)
    while task.wait(CHECK_INTERVAL) do
        pcall(function()
            local playerData = LocalData:Get()
            if not playerData or ItemUtil:GetOwnedAmount(playerData, TICKET_ITEM) == 0 then
                return
            end

            local spinResult = Remote:InvokeServer("ValentinesWheelSpin")

            if spinResult then
                task.wait(SPIN_DELAY)
                Remote:FireServer("ClaimValentinesWheelSpinQueue")
            end
        end)
    end
end)
