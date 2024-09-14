local QBCore = exports['qb-core']:GetCoreObject()

local function tableContains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

RegisterServerEvent('ticketing:giveTicket')
AddEventHandler('ticketing:giveTicket', function(vehicleNetId, amount, reason, notes, officerName, licensePlate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name

    if not tableContains(Config.ParkingJobs, job) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = Lang.Lang['permission_denied'],
            description = Lang.Lang['no_permission'],
            type = "error"
        })
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not DoesEntityExist(vehicle) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = Lang.Lang['error'],
            description = Lang.Lang['vehicle_not_found'],
            type = "error"
        })
        return
    end

    MySQL.Async.insert('INSERT INTO active_tickets (vehicle_net_id, amount, reason, notes, officer_name, license_plate) VALUES (@vehicleNetId, @amount, @reason, @notes, @officerName, @licensePlate)', {
        ['@vehicleNetId'] = vehicleNetId,
        ['@amount'] = amount,
        ['@reason'] = reason,
        ['@notes'] = notes,
        ['@officerName'] = officerName,
        ['@licensePlate'] = licensePlate
    }, function(ticketId)
        if ticketId then
            TriggerClientEvent('ticketing:placeTicket', -1, vehicleNetId, amount, reason, notes, officerName, licensePlate, ticketId)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = Lang.Lang['ticket_issue_failed'],
                description = Lang.Lang['ticket_issue_failed'],
                type = "error"
            })
        end
    end)
end)

RegisterServerEvent('ticketing:payTicket')
AddEventHandler('ticketing:payTicket', function(ticketId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.Async.fetchAll('SELECT * FROM active_tickets WHERE id = @ticketId', {['@ticketId'] = ticketId}, function(ticketData)
        if #ticketData > 0 then
            local ticket = ticketData[1]
            local amount = ticket.amount
            local playerBank = Player.PlayerData.money["bank"]

            if ticket.is_paid then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = Lang.Lang['ticket_already_paid'],
                    description = Lang.Lang['ticket_already_paid'],
                    type = "error"
                })
                return
            end

            if playerBank >= amount then
                MySQL.Async.execute('UPDATE active_tickets SET is_paid = TRUE WHERE id = @ticketId', {['@ticketId'] = ticketId}, function(affectedRows)
                    if affectedRows > 0 then
                        local success, response = exports.ox_inventory:RemoveItem(src, 'ticket', 1)

                        if success then
                            Player.Functions.RemoveMoney('bank', amount, 'paid-ticket')

                            TriggerClientEvent('ox_lib:notify', src, {
                                title = Lang.Lang['payment_successful'],
                                description = Lang.Lang['payment_successful'],
                                type = "success"
                            })
                        else
                            TriggerClientEvent('ox_lib:notify', src, {
                                title = Lang.Lang['inventory_issue'],
                                description = Lang.Lang['inventory_issue'] .. response,
                                type = "error"
                            })
                        end
                    else
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = Lang.Lang['update_failed'],
                            description = Lang.Lang['update_failed'],
                            type = "error"
                        })
                    end
                end)
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = Lang.Lang['insufficient_funds'],
                    description = Lang.Lang['insufficient_funds'],
                    type = "error"
                })
            end
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = Lang.Lang['ticket_not_found'],
                description = Lang.Lang['ticket_not_found'],
                type = "error"
            })
        end
    end)
end)

RegisterServerEvent('ticketing:giveTicketItem')
AddEventHandler('ticketing:giveTicketItem', function(ticketData)
    print("ticketData received:", json.encode(ticketData))
    local src = source

    local dateIssued = os.date('%m/%d/%Y') 
    local metadata = {
        vehicle = ticketData.vehicle,
        reason = ticketData.reason,    
        notes = 'Notes: ' .. ticketData.notes,      
        amount = ticketData.amount,   
        officerName = ticketData.officerName,  
        licensePlate = ticketData.licensePlate, 
        dateIssued = dateIssued,
        ticketID = ticketData.ticketID
    }

    local success, response = exports.ox_inventory:AddItem(src, 'ticket', 1, metadata)

    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = Lang.Lang['success'],
            description = Lang.Lang['ticket_added'],
            type = "success"
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = Lang.Lang['error'],
            description = Lang.Lang['add_ticket_failed'] .. tostring(response),
            type = "error"
        })
    end
end)

exports('useTicket', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local ticket = exports.ox_inventory:GetSlot(inventory.id, slot)
        if ticket and ticket.metadata then
            TriggerClientEvent('ticketing:showTicketDetailsMenu', inventory.id, ticket)
        else
            TriggerClientEvent('ox_lib:notify', inventory.id, {
                title = Lang.Lang['error'],
                description = Lang.Lang['no_ticket_data'],
                type = "error"
            })
        end
    end
end)

RegisterServerEvent('ticketing:getActiveTickets')
AddEventHandler('ticketing:getActiveTickets', function()
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM active_tickets', {}, function(tickets)
        if tickets and #tickets > 0 then
            TriggerClientEvent('ticketing:showActiveTickets', src, tickets)
            print("tickets received:", json.encode(tickets))
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = Lang.Lang['no_active_tickets'],
                description = Lang.Lang['no_active_tickets'],
                type = "info"
            })
            print("tickets received:", json.encode(tickets))
        end
    end)
end)

RegisterServerEvent('ticketing:getTicketDetails')
AddEventHandler('ticketing:getTicketDetails', function(ticketId)
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM active_tickets WHERE id = @ticketId', {
        ['@ticketId'] = ticketId
    }, function(tickets)
        if tickets and #tickets > 0 then
            TriggerClientEvent('ticketing:showTicketDetail', src, tickets[1])
            print("tickets received:", json.encode(tickets))
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = Lang.Lang['ticket_not_found'],
                description = Lang.Lang['ticket_details_not_found'],
                type = "error"
            })
            print("tickets received:", json.encode(tickets))
        end
    end)
end)

RegisterServerEvent('ticketing:markAsPaid')
AddEventHandler('ticketing:markAsPaid', function(ticketId)
    local src = source

    MySQL.Async.execute('UPDATE active_tickets SET is_paid = @is_paid WHERE id = @ticketId', {
        ['@is_paid'] = true,
        ['@ticketId'] = ticketId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                title = Lang.Lang['ticket_updated'],
                description = Lang.Lang['ticket_updated'],
                type = "success"
            })
            TriggerClientEvent('ticketing:getActiveTickets', src)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = Lang.Lang['update_failed'],
                description = Lang.Lang['update_failed'],
                type = "error"
            })
        end
    end)
end)
