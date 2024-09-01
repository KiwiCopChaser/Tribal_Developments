-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()
local activeBailBonds = {}

-- Initialize bail bonds from database on resource start
Citizen.CreateThread(function()
    MySQL.Async.fetchAll('SELECT * FROM bail_bonds', {}, function(results)
        for _, bail in ipairs(results) do
            activeBailBonds[bail.citizen_id] = {
                amount = bail.amount,
                expiry = bail.expiry,
                paid = bail.paid == 1
            }
        end
        print('Bail bonds loaded from database')
    end)
end)

-- Set bail for a player
QBCore.Functions.CreateCallback('qb-bailbond:server:setBail', function(source, cb, targetId, amount, duration)
    local player = QBCore.Functions.GetPlayer(source)
    local target = QBCore.Functions.GetPlayer(targetId)
    
    if not IsAuthorized(player) then
        cb(false, Config.Locales['not_authorized'])
        return
    end
    
    if not target then
        cb(false, Config.Locales['target_not_found'])
        return
    end
    
    local expiry = os.time() + (duration * 60 * 60) -- Convert hours to seconds
    local citizenId = target.PlayerData.citizenid
    
    MySQL.Async.insert('INSERT INTO bail_bonds (citizen_id, amount, expiry, paid) VALUES (?, ?, ?, ?)', 
        {citizenId, amount, expiry, 0},
        function(id)
            if id then
                activeBailBonds[citizenId] = {
                    amount = amount,
                    expiry = expiry,
                    paid = false
                }
                cb(true, "Bail set successfully.")
                TriggerClientEvent('QBCore:Notify', targetId, string.format(Config.Locales['bail_set'], amount, duration))
            else
                cb(false, Config.Locales['db_error'])
            end
        end
    )
end)

-- Pay bail
QBCore.Functions.CreateCallback('qb-bailbond:server:payBail', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local citizenId = player.PlayerData.citizenid
    local bail = activeBailBonds[citizenId]
    
    if not bail then
        cb(false, Config.Locales['no_active_bail'])
        return
    end
    
    if bail.paid then
        cb(false, Config.Locales['bail_already_paid'])
        return
    end
    
    if player.PlayerData.money.cash < bail.amount then
        cb(false, Config.Locales['not_enough_cash'])
        return
    end
    
    player.Functions.RemoveMoney('cash', bail.amount, "bail-payment")
    bail.paid = true
    
    MySQL.Async.execute('UPDATE bail_bonds SET paid = 1 WHERE citizen_id = ?', {citizenId})
    
    -- Release player from jail
    TriggerEvent('qb-policejob:server:SetHandcuffStatus', source, false)
    TriggerEvent('qb-policejob:server:SetJailStatus', source, 0)
    
    cb(true, Config.Locales['bail_paid'])
end)

-- Check bail status
QBCore.Functions.CreateCallback('qb-bailbond:server:checkBailStatus', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local citizenId = player.PlayerData.citizenid
    local bail = activeBailBonds[citizenId]
    
    if not bail then
        cb(nil)
        return
    end
    
    if os.time() > bail.expiry then
        activeBailBonds[citizenId] = nil
        MySQL.Async.execute('DELETE FROM bail_bonds WHERE citizen_id = ?', {citizenId})
        cb(nil)
        TriggerClientEvent('QBCore:Notify', source, Config.Locales['bail_expired'], "error")
        return
    end
    
    cb(bail)
end)

-- Revoke bail
QBCore.Functions.CreateCallback('qb-bailbond:server:revokeBail', function(source, cb, targetId)
    local player = QBCore.Functions.GetPlayer(source)
    local target = QBCore.Functions.GetPlayer(targetId)
    
    if not IsAuthorized(player) then
        cb(false, Config.Locales['not_authorized'])
        return
    end
    
    if not target then
        cb(false, Config.Locales['target_not_found'])
        return
    end
    
    local citizenId = target.PlayerData.citizenid
    
    if not activeBailBonds[citizenId] then
        cb(false, Config.Locales['no_bail_to_revoke'])
        return
    end
    
    activeBailBonds[citizenId] = nil
    MySQL.Async.execute('DELETE FROM bail_bonds WHERE citizen_id = ?', {citizenId})
    
    cb(true, "Bail revoked successfully.")
    TriggerClientEvent('QBCore:Notify', targetId, Config.Locales['bail_revoked'])
end)

-- Helper function to check if a player is authorized
function IsAuthorized(player)
    return Config.AuthorizedJobs[player.PlayerData.job.name] ~= nil
end
