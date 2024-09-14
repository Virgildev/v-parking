local QBCore = exports['qb-core']:GetCoreObject()

local function handleTicketing(vehicle)
    local playerJob = QBCore.Functions.GetPlayerData().job.name
    if not table.contains(Config.ParkingJobs, playerJob) then
        lib.notify({
            title = Lang.Lang.permission_denied,
            description = Lang.Lang.no_permission,
            type = 'error'
        })
        return
    end

    local playerData = QBCore.Functions.GetPlayerData()
    local officerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname

    local licensePlate = GetVehicleNumberPlateText(vehicle)

    local input = lib.inputDialog(Lang.Lang.ticket_menu_title, {
        {type = 'number', label = Lang.Lang.amount_label, placeholder = Lang.Lang.amount_label, min = 1, max = Config.MaxTicketPrice, required = true},
        {type = 'input', label = Lang.Lang.reason_label, placeholder = Lang.Lang.reason_label, required = true},
        {type = 'textarea', label = Lang.Lang.notes_label, placeholder = Lang.Lang.notes_label}
    })

    if not input then return end

    local amount = tonumber(input[1])
    local reason = input[2]
    local notes = input[3] or ""

    if not amount or not reason then
        lib.notify({
            title = Lang.Lang.invalid_input,
            description = Lang.Lang.invalid_ticket_id,
            type = 'error'
        })
        return
    end

    local ticketID = math.random(100000, 999999)
    TriggerServerEvent('ticketing:giveTicket', VehToNet(vehicle), amount, reason, notes, officerName, licensePlate, ticketID)
end

function table.contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

RegisterNetEvent('ticketing:placeTicket')
AddEventHandler('ticketing:placeTicket', function(vehicleNetId, amount, reason, notes, officerName, licensePlate, ticketID)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    
    if DoesEntityExist(vehicle) then
        local propName = Config.propName
        local propHash = GetHashKey(propName)
        
        RequestModel(propHash)
        while not HasModelLoaded(propHash) do
            Wait(500)
        end

        local vehiclePos = GetEntityCoords(vehicle)

        local prop = CreateObject(propHash, vehiclePos.x, vehiclePos.y, vehiclePos.z + 1.0, true, true, true)
        SetEntityAsMissionEntity(prop, true, true)
        FreezeEntityPosition(prop, true)

        local boneIndex = GetEntityBoneIndexByName(vehicle, 'windscreen') 
        if boneIndex ~= -1 then
            local offsetX, offsetY, offsetZ = -0.6, 0.33, -0.2 
            local rotationX, rotationY, rotationZ = -49.45, 0.00, 0.0  

            AttachEntityToEntity(prop, vehicle, boneIndex, offsetX, offsetY, offsetZ, rotationX, rotationY, rotationZ, false, false, false, false, 2, true)
        else
            print("Windshield bone not found!")
        end

        SetEntityCollision(prop, false, false)
        SetEntityAlpha(prop, 255, false)
        SetEntityVisible(prop, true)

        SetEntityAsMissionEntity(prop, true, true)

        exports.ox_target:addEntity(vehicleNetId, {
            {
                name = "manage_ticket_" .. vehicleNetId,
                icon = "fas fa-ticket-alt",
                label = Lang.Lang.manage_ticket,
                onSelect = function()
                    TriggerEvent('ticketing:showTicketMenu', {
                        vehicle = vehicleNetId,
                        reason = reason,
                        notes = notes,
                        amount = amount,
                        officerName = officerName,
                        licensePlate = licensePlate,
                        prop = prop, 
                        ticketID = ticketID
                    })
                end
            }
        })
    else
        lib.notify({
            title = Lang.Lang.vehicle_not_found,
            description = Lang.Lang.vehicle_not_found,
            type = 'error'
        })
    end
end)

exports.ox_target:addGlobalVehicle({
    label = Lang.Lang.open_vehicle_menu,
    icon = 'fa-solid fa-ticket',
    groups = Config.ParkingJobs,
    distance = 3.0, 
    onSelect = function(data)
        local vehicle = data.entity
        handleTicketing(vehicle)
    end
})

RegisterNetEvent('ticketing:showTicketMenu')
AddEventHandler('ticketing:showTicketMenu', function(data)
    if data and data.vehicle then
        lib.registerContext({
            id = 'ticket_menu',
            title = Lang.Lang.ticket_menu_title,
            options = {
                {
                    title = Lang.Lang.pick_up_ticket,
                    description = Lang.Lang.pick_up_ticket_description,
                    icon = 'check',
                    onSelect = function(menuData)
                        TriggerEvent('ticketing:pickupTicket', {
                            vehicle = data.vehicle,  
                            reason = data.reason,
                            notes = data.notes,   
                            amount = data.amount,   
                            officerName = data.officerName, 
                            licensePlate = data.licensePlate, 
                            prop = data.prop,  
                            ticketID = data.ticketID
                        })

                        exports.ox_target:removeEntity(data.vehicle)
                        DeleteEntity(data.prop)

                        lib.notify({
                            title = Lang.Lang.ticket_picked_up,
                            description = Lang.Lang.ticket_picked_up,
                            type = 'success'
                        })
                        
                        TriggerEvent('ticketing:removeTicket', data.vehicle, data.prop)
                    end
                }
            }
        })
        lib.showContext('ticket_menu', data)
    else
        print('No data available to show the ticket menu')
    end
end)

RegisterNetEvent('ticketing:pickupTicket')
AddEventHandler('ticketing:pickupTicket', function(ticketData)
    TriggerServerEvent('ticketing:giveTicketItem', ticketData)
end)

RegisterNetEvent('ticketing:removeTicket')
AddEventHandler('ticketing:removeTicket', function(vehicleNetId, prop)
    exports.ox_target:removeEntity(vehicleNetId)
    DeleteEntity(prop)
end)

RegisterNetEvent('ticketing:showTicketDetailsMenu')
AddEventHandler('ticketing:showTicketDetailsMenu', function(ticket)
    print("Ticket received:", json.encode(ticket))
    if ticket and ticket.metadata then
        lib.registerContext({
            id = 'ticket_details_menu',
            title = Lang.Lang['ticket_details'] or "Ticket Details",
            options = {
                {
                    title = Lang.Lang['ticket_id'] or "Ticket ID",
                    description = tostring(ticket.metadata.ticketID),
                    icon = 'car'
                },
                {
                    title = Lang.Lang['vehicle_plate'] or "Vehicle Plate",
                    description = tostring(ticket.metadata.licensePlate) or "N/A",
                    icon = 'car'
                },
                {
                    title = Lang.Lang['amount_label_Title'] or "Amount",
                    description = Lang.Lang['currency'] .. tostring(ticket.metadata.amount),
                    icon = 'money-bill'
                },
                {
                    title = Lang.Lang['reason'] or "Reason",
                    description = tostring(ticket.metadata.reason) or "N/A",
                    icon = 'exclamation-circle'
                },
                {
                    title = Lang.Lang['notes'] or "Notes",
                    description = tostring(ticket.metadata.notes) or "N/A",
                    icon = 'sticky-note'
                },
                {
                    title = Lang.Lang['date_issued_label'] or "Date Issued",
                    description = tostring(ticket.metadata.dateIssued) or "N/A",
                    icon = 'calendar-alt'
                },
                {
                    title = Lang.Lang['officer_label'] or "Issued By",
                    description = tostring(ticket.metadata.officerName) or "N/A",
                    icon = 'user'
                }
            }
        })
        lib.showContext('ticket_details_menu')
    else
        print(Lang.Lang['no_valid_ticket_metadata'] or "No valid ticket metadata")
    end
end)


local function spawnTicketPaymentPed()
    local pedModel = GetHashKey(Config.TicketPaymentLocation.ped.model)

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(500)
    end

    local pedCoords = Config.TicketPaymentLocation.ped.coords
    local pedHeading = Config.TicketPaymentLocation.ped.heading

    local ped = CreatePed(4, pedModel, pedCoords, pedHeading, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    FreezeEntityPosition(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedConfigFlag(ped, 32, true) 
    SetPedConfigFlag(ped, 34, true) 

    local boxZoneParams = {
        coords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 1.0), 
        size = vector3(2.0, 2.0, 2.0), 
        rotation = pedHeading, 
        options = Config.TicketPaymentLocation.interaction.target
    }
    exports.ox_target:addBoxZone(boxZoneParams)
end

RegisterNetEvent('ticketing:payTicket')
AddEventHandler('ticketing:payTicket', function()
    local input = lib.inputDialog(Lang.Lang['pay_ticket'], {
        {type = 'number', label = Lang.Lang['ticket_id'], placeholder = Lang.Lang['ticket_id_placeholder'], required = true}
    })

    if not input then return end

    local ticketId = tonumber(input[1])

    if not ticketId then
        lib.notify({
            title = Lang.Lang['invalid_ticket_id'],
            description = Lang.Lang['invalid_ticket_id'],
            type = 'error'
        })
        return
    end

    TriggerServerEvent('ticketing:payTicket', ticketId)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        spawnTicketPaymentPed()
    end
end)

local parkingHutModels = Config.HutModels

for _, model in ipairs(parkingHutModels) do
    local options = {
        {
            label = Lang.Lang['manage_ticket'],
            icon = 'fas fa-ticket-alt',
            onSelect = function(data)
                TriggerEvent('ticketing:viewActiveTickets', {
                    entity = data.entity,
                    label = data.label
                })
            end,
            canInteract = function(_, distance)
                return distance <= 3.0
            end
        }
    }
    
    exports.ox_target:addModel(model, options)
end

RegisterNetEvent('ticketing:viewActiveTickets')
AddEventHandler('ticketing:viewActiveTickets', function()
    TriggerServerEvent('ticketing:getActiveTickets')
end)

RegisterNetEvent('ticketing:showActiveTickets')
AddEventHandler('ticketing:showActiveTickets', function(tickets)
    print('Received tickets:', json.encode(tickets))

    local ticketOptions = {}

    for _, ticket in ipairs(tickets) do
        table.insert(ticketOptions, {
            title = string.format(Lang.Lang['ticket_id_label'], ticket.id) .. ' - ' .. string.format(Lang.Lang['vehicle_plate_label'], ticket.license_plate),
            onSelect = function()
                TriggerEvent('ticketing:showTicketDetails', ticket.id)
            end
        })
    end

    if #ticketOptions > 0 then
        lib.registerContext({
            id = 'active_tickets_menu',
            title = Lang.Lang['active_tickets'],
            options = ticketOptions
        })

        lib.showContext('active_tickets_menu')
    else
        print(Lang.Lang['no_active_tickets']) 
        exports.ox_lib:notify({
            title = Lang.Lang['no_active_tickets'],
            description = Lang.Lang['no_active_tickets'],
            type = "info"
        })
    end
end)

RegisterNetEvent('ticketing:showTicketDetails')
AddEventHandler('ticketing:showTicketDetails', function(ticketId)
    TriggerServerEvent('ticketing:getTicketDetails', ticketId)
end)

RegisterNetEvent('ticketing:showTicketDetail')
AddEventHandler('ticketing:showTicketDetail', function(ticket)
    local paidStatus = (ticket.is_paid and Lang.Lang['success']) or Lang.Lang['error']
    lib.registerContext({
        id = 'ticket_details_menu',
        title = Lang.Lang['ticket_details'] or "Ticket Details",
        options = {
            {
                title = string.format(Lang.Lang['ticket_id_label'] or "Ticket ID: %s", ticket.id or "N/A"),
                description = string.format(Lang.Lang['vehicle_plate_label'] or "Vehicle Plate: %s", ticket.license_plate or "N/A")
            },
            {
                title = Lang.Lang['amount_label_Title'] or "Amount",
                description = Lang.Lang['currency'] .. tostring(ticket.amount),
            },
            {
                title = Lang.Lang['reason'] or "Reason",
                description = tostring(ticket.reason) or "N/A",
            },
            {
                title = Lang.Lang['notes_label'] or "Notes",
                description = ticket.notes or "N/A"
            },
            {
                title = Lang.Lang['officer_label'] or "Officer",
                description = ticket.officer_name or "N/A"
            },
            {
                title = Lang.Lang['status_label'] or "Paid Status",
                description = tostring(ticket.is_paid)
            },
            {
                title = Lang.Lang['mark_as_paid'] or "Mark as Paid",
                description = Lang.Lang['mark_as_paid_description'] or "Click to mark this ticket as paid.",
                onSelect = function()
                    TriggerServerEvent('ticketing:markAsPaid', ticket.id)
                end
            }
        }
    })

    lib.showContext('ticket_details_menu')
end)
