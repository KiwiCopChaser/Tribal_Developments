-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- Command to set bail
RegisterCommand("setbail", function(source, args)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    local duration = tonumber(args[3])
    
    if not targetId or not amount or not duration then
        QBCore.Functions.Notify("Usage: /setbail [playerID] [amount] [duration in hours]", "error")
        return
    end
    
    QBCore.Functions.TriggerCallback('qb-bailbond:server:setBail', function(success, message)
        QBCore.Functions.Notify(message, success and "success" or "error")
    end, targetId, amount, duration)
end)

-- Command to pay bail
RegisterCommand("paybail", function()
    QBCore.Functions.TriggerCallback('qb-bailbond:server:payBail', function(success, message)
        QBCore.Functions.Notify(message, success and "success" or "error")
    end)
end)

-- Command to revoke bail
RegisterCommand("revokebail", function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        QBCore.Functions.Notify("Usage: /revokebail [playerID]", "error")
        return
    end
    
    QBCore.Functions.TriggerCallback('qb-bailbond:server:revokeBail', function(success, message)
        QBCore.Functions.Notify(message, success and "success" or "error")
    end, targetId)
end)

-- Periodically check bail status
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        QBCore.Functions.TriggerCallback('qb-bailbond:server:checkBailStatus', function(bail)
            if bail then
                local timeLeft = math.floor((bail.expiry - os.time()) / 60) -- minutes left
                QBCore.Functions.Notify("Your bail of $" .. bail.amount .. " is still active. " .. timeLeft .. " minutes remaining.", "primary")
            end
        end)
    end
end)