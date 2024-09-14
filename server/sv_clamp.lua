function giveItemToPlayer(playerId, item, count)
    local success, response = exports.ox_inventory:AddItem(playerId, item, count)
    if not success then
        print("Failed to add item: " .. response)
    end
end

function removeItemFromPlayer(playerId, item, count)
    local success, response = exports.ox_inventory:RemoveItem(playerId, item, count)
    if not success then
        print("Failed to remove item: " .. response)
    end
end

RegisterNetEvent('wheel_clamp:place', function(vehicle)
    local playerId = source
    removeItemFromPlayer(playerId, Config.ClampItem, 1) 
end)

RegisterNetEvent('wheel_clamp:remove', function(vehicle)
    local playerId = source
    giveItemToPlayer(playerId, Config.ClampItem, 1)
end)
