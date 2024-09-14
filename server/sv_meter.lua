QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.meterCheckTime) 

        MySQL.Async.fetchAll('SELECT meter_id, remaining_time FROM parking_meters', {}, function(meters)
            for _, meter in ipairs(meters) do
                local newRemainingTime = meter.remaining_time - 60 
                if newRemainingTime < 0 then newRemainingTime = 0 end
                
                local query = [[
                    UPDATE parking_meters 
                    SET remaining_time = @newRemainingTime 
                    WHERE meter_id = @meterId
                ]]
                MySQL.Async.execute(query, {
                    ['@newRemainingTime'] = newRemainingTime,
                    ['@meterId'] = meter.meter_id
                })
            end
        end)
    end
end)

RegisterNetEvent('parking:addTime', function(meterId, time)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local price = time * Config.CostPerMinute

    if xPlayer.Functions.RemoveMoney('cash', price) then
        MySQL.Async.fetchScalar('SELECT COUNT(*) FROM parking_meters WHERE meter_id = @meterId', {
            ['@meterId'] = meterId
        }, function(count)
            if count > 0 then
                local query = [[
                    UPDATE parking_meters 
                    SET remaining_time = GREATEST(0, remaining_time + @time), 
                        paid_amount = paid_amount + @paidAmount
                    WHERE meter_id = @meterId
                ]]
                MySQL.Async.execute(query, {
                    ['@time'] = time * 60, 
                    ['@meterId'] = meterId,
                    ['@paidAmount'] = price
                }, function(affectedRows)
                    if affectedRows > 0 then
                        TriggerClientEvent('parking:timeAdded', src, time)
                    else
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = Lang.Lang['update_failed'],
                            description = Lang.Lang['failed_update_time'],
                            type = 'error'
                        })
                    end
                end)
            else
                local insertQuery = [[
                    INSERT INTO parking_meters (meter_id, remaining_time, paid_amount) 
                    VALUES (@meterId, @time, @paidAmount)
                ]]
                MySQL.Async.execute(insertQuery, {
                    ['@time'] = time * 60, 
                    ['@meterId'] = meterId,
                    ['@paidAmount'] = price
                }, function(affectedRows)
                    if affectedRows > 0 then
                        TriggerClientEvent('parking:timeAdded', src, time)
                    else
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = Lang.Lang['update_failed'],
                            description = Lang.Lang['failed_update_time'],
                            type = 'error'
                        })
                    end
                end)
            end
        end)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = Lang.Lang['insufficient_funds'],
            description = Lang.Lang['insufficient_funds'],
            type = 'error'
        })
    end
end)

RegisterNetEvent('parking:requestTime', function(meterId)
    local src = source

    MySQL.Async.fetchScalar('SELECT remaining_time FROM parking_meters WHERE meter_id = @meterId', {
        ['@meterId'] = meterId
    }, function(remainingTime)
        if remainingTime then
            TriggerClientEvent('parking:showMenuWithTime', src, meterId, remainingTime)
        else
            local insertQuery = [[
                INSERT INTO parking_meters (meter_id, remaining_time, paid_amount) 
                VALUES (@meterId, @time, @paidAmount)
            ]]
            MySQL.Async.execute(insertQuery, {
                ['@meterId'] = meterId,
                ['@time'] = 0, 
                ['@paidAmount'] = 0 
            }, function(affectedRows)
                if affectedRows > 0 then
                    TriggerClientEvent('parking:showMenuWithTime', src, meterId, 0)
                else
                    TriggerClientEvent('ox_lib:notify', src, {
                        title = Lang.Lang['update_failed'],
                        description = Lang.Lang['failed_update_time'],
                        type = 'error'
                    })
                end
            end)
        end
    end)
end)
