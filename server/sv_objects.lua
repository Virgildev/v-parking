local QBCore = exports['qb-core']:GetCoreObject()

local Objects = {}

local function CreateObjectId()
    local objectId = math.random(10000, 99999)
    while Objects[objectId] do
        objectId = math.random(10000, 99999)
    end
    return objectId
end

QBCore.Commands.Add(Config.ObjectMenuCommand, Lang.Lang['object_menu_command'], {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local jobName = Player.PlayerData.job.name
    
    if table.contains(Config.ParkingJobs, jobName) and Player.PlayerData.job.onduty then
        TriggerClientEvent('parking:OpenObjectMenu', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = Lang.Lang['access_denied_title'],
            description = Lang.Lang['access_denied_description'],
            type = 'error'
        })
    end
end)

function table.contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

RegisterNetEvent('parking:spawnObject', function(object, loc, heading)
    print('Server spawnObject triggered with:', object, loc, heading)
    local objectId = CreateObjectId()
    local type = object
    Objects[objectId] = type
    TriggerClientEvent("parking:spawnObject", -1, objectId, type, loc, heading)
    TriggerClientEvent('ox_lib:notify', -1, {
        title = Lang.Lang['success'],
        description = Lang.Lang['object_spawn'],
        type = 'success'
    })
end)

RegisterNetEvent('parking:deleteObject', function(objectId)
    TriggerClientEvent('parking:removeObject', -1, objectId)
    TriggerClientEvent('ox_lib:notify', -1, {
        title = Lang.Lang['success'],
        description = Lang.Lang['object_deleted'],
        type = 'success'
    })
end)
