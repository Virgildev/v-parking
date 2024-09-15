local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    for _, pedData in pairs(Config.PedLocations) do
        local pedModel = GetHashKey(pedData.pedModel)
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(1)
        end

        local ped = CreatePed(4, pedModel, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.heading, false, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)
        SetPedCanRagdollFromPlayerImpact(ped, false)
        SetPedConfigFlag(ped, 32, true)
        SetPedConfigFlag(ped, 34, true) 

        exports.ox_target:addLocalEntity(ped, {
            {
                label = Lang.Lang['open_vehicle_menu'],
                icon = "fa-car",
                onSelect = function()
                    openVehicleMenu(pedData.spawnLocations, pedData)
                end
            }
        })
    end
end)

function openVehicleMenu(spawnLocation, pedData)
        local options = {}

        table.insert(options, {
            title = Lang.Lang['return_vehicle'],
            icon = "fa-solid fa-undo",
            onSelect = function()
                returnVehicle()
            end
        })

        for _, vehicle in pairs(Config.Vehicles) do
            table.insert(options, {
                title = vehicle.label,
                icon = 'fa-solid fa-car',
                onSelect = function()
                    spawnVehicle(vehicle, spawnLocation)
                end
            })
        end

        lib.registerContext({
            id = 'vehicle_menu',
            title = Lang.Lang['vehicle_menu_title'],
            options = options
        })

        lib.showContext('vehicle_menu')
end

function spawnVehicle(vehicle, location)
    DoScreenFadeOut(2500)
    Wait(2500)
    local vehicleHash = GetHashKey(vehicle.name)

    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(1)
    end

    local spawnedVehicle = CreateVehicle(vehicleHash, location.x, location.y, location.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), spawnedVehicle, -1)
    DoScreenFadeIn(2500)

    TriggerEvent(Config.GiveKeyEvent, spawnedVehicle)
end

function returnVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and vehicle ~= 0 then
        TaskLeaveVehicle(playerPed, vehicle, 0)
        Wait(1000)
        DeleteVehicle(vehicle)
    else
        lib.notify({
            description = Lang.Lang['not_in_vehicle'],
            type = 'error',
            showDuration = true 
        })        
    end
end
