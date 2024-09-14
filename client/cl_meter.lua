QBCore = exports['qb-core']:GetCoreObject()

function GetMeterId(entity)
    local coords = GetEntityCoords(entity)
    return math.floor(coords.x * 1000) + math.floor(coords.y * 1000)
end

local function showParkingMeterOptions(meterId, remainingTime)
    local remainingPercent = math.min(remainingTime / Config.MaxTime, 1) * 100

    lib.registerContext({
        id = 'parking_meter_menu_' .. meterId,
        title = Lang.Lang['parking_meter_options_title'],
        canClose = true,
        options = {
            {
                title = string.format(Lang.Lang['remaining_time'], remainingTime),
                progress = remainingPercent,  
                colorScheme = 'blue',
                readOnly = true
            },
            {
                title = Lang.Lang['add_time'],
                icon = 'money-bill-wave',
                onSelect = function()
                    TriggerEvent('parking:openAddTimeInput', meterId)
                end
            }
        }
    })
    lib.showContext('parking_meter_menu_' .. meterId)
end

for _, model in ipairs(Config.Models) do
    local options = {
        {
            label = Lang.Lang['add_time'],
            icon = 'fa-solid fa-money-bill-wave', 
            onSelect = function(data)
                local meterId = GetMeterId(data.entity)

                TriggerServerEvent('parking:requestTime', meterId)
            end,
            canInteract = function(_, distance)
                return distance <= 2.5
            end
        }
    }
    
    exports.ox_target:addModel(model, options)
end

RegisterNetEvent('parking:openAddTimeInput', function(meterId)
    local input = lib.inputDialog(Lang.Lang['add_time_title'], {
        { type = 'number', label = Lang.Lang['add_time_label'], min = 1, max = 60, step = 1, default = 1 }
    }, {
        allowCancel = true
    })

    if input and input[1] then
        local timeToAdd = tonumber(input[1])
        if timeToAdd then
            TriggerServerEvent('parking:addTime', meterId, timeToAdd)
        else
            lib.notify({
                title = Lang.Lang['invalid_time_input'],
                description = Lang.Lang['invalid_time_input'],
                type = 'error'
            })
        end
    end
end)

RegisterNetEvent('parking:showMenuWithTime', function(meterId, remainingTime)
    showParkingMeterOptions(meterId, remainingTime)
end)

RegisterNetEvent('parking:timeAdded', function(time)
    lib.notify({
        title = Lang.Lang['time_added_title'],
        description = string.format(Lang.Lang['time_added_description'], time),
        type = 'success'
    })
end)