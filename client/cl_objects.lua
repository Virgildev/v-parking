local QBCore = exports['qb-core']:GetCoreObject()

local ObjectList = {}
local isInVehicle = false
local rotationSpeed = 1.0 

local RotationToDirection = function(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local RayCastCamera = function()
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * 10.0)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit, surfaceNormal
end

RegisterNetEvent("QBCore:Client:EnteredVehicle", function()
    isInVehicle = true
end)

RegisterNetEvent("QBCore:Client:LeftVehicle", function()
    isInVehicle = false
end)

RegisterNetEvent('parking:deleteObject', function(id)
    if lib.progressBar({
        duration = Config.ObjectPlacerProgress,
        label = Lang.Lang['removing_object'],
        canCancel = true,
        position = 'bottom',
        disable = {
            car = true,
            combat = true,
        },
        anim = {
            dict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
            clip = "plant_floor"
        }
    }) then
        TriggerServerEvent("parking:deleteObject", id)
    else
        lib.notify({
            title = Lang.Lang['operation_cancelled'],
            type = 'error'
        })
    end
end)

RegisterNetEvent('parking:removeObject', function(objectId)
    NetworkRequestControlOfEntity(ObjectList[objectId].object)
    DeleteObject(ObjectList[objectId].object)
    ObjectList[objectId] = nil
end)

RegisterNetEvent('parking:spawnObject', function(objectId, type, loc, heading)
    local x, y, z = table.unpack(loc)
    local spawnedObj = CreateObject(Config.Objects[type].model, x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(spawnedObj)
    SetEntityHeading(spawnedObj, heading)
    FreezeEntityPosition(spawnedObj, Config.Objects[type].freeze)
    ObjectList[objectId] = {
        id = objectId,
        object = spawnedObj,
        coords = vector3(x, y, z - 0.3),
    }
    
    exports.ox_target:addLocalEntity({spawnedObj}, {
        {
            icon = 'fas fa-trash',
            label = Lang.Lang['remove_object'],
            canInteract = function()
                local playerData = QBCore.Functions.GetPlayerData()
                return table.contains(Config.ParkingJobs, playerData.job.name)
            end,
            onSelect = function()
                TriggerEvent('parking:deleteObject', objectId)
            end,
        }
    })
end)

function table.contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function RegisterObjectMenu()
    local menuOptions = {}

    for objectKey, objectData in pairs(Config.Objects) do
        table.insert(menuOptions, {
            title = Lang.Lang['spawn_object']:format(objectKey),
            icon = 'caret-right',
            event = 'parking:placeProp',
            args = {object = objectKey},
        })
    end

    table.insert(menuOptions, {
        title = Lang.Lang['close'],
        icon = 'xmark',
        canClose = true,
    })

    lib.registerContext({
        id = 'object_menu',
        title = Lang.Lang['object_placement_menu_title'],
        canClose = true,
        options = menuOptions,
    })
end

RegisterNetEvent('parking:OpenObjectMenu', function()
    RegisterObjectMenu()  
    lib.showContext('object_menu')
end)

RegisterNetEvent('parking:placeProp', function(data)
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then return end
    
    local ModelHash = Config.Objects[data.object].model
    RequestModel(ModelHash)
    while not HasModelLoaded(ModelHash) do 
        Wait(0) 
    end

    lib.showTextUI(Lang.Lang['place_object_instruction'], {position = 'top-center'})
    local hit, dest, _, _ = RayCastCamera()
    local obj = CreateObject(ModelHash, dest.x, dest.y, dest.z, false, false, false)
    SetEntityCollision(obj, false, false)
    SetEntityAlpha(obj, 150, true)
    
    local placed = false
    while not placed do
        Wait(0)
        hit, dest, _, _ = RayCastCamera()
        if hit == 1 then
            SetEntityCoords(obj, dest.x, dest.y, dest.z)
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                
                if lib.progressCircle({
                    duration = Config.ObjectPlacerProgress,
                    label = Lang.Lang['placing_object'],
                    canCancel = true,
                    position = 'bottom',
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = 'anim@narcotics@trash',
                        clip = 'drop_front'
                    },
                }) then
                    local heading = GetEntityHeading(obj)
                    DeleteObject(obj)
                    
                    local ped = PlayerPedId()
                    RequestAnimDict('anim@narcotics@trash')
                    while not HasAnimDictLoaded('anim@narcotics@trash') do 
                        Wait(0) 
                    end
                    TaskPlayAnim(ped, 'anim@narcotics@trash', 'drop_front', 8.0, 8.0, -1, 16, 0, false, false, false)
                    Citizen.Wait(1000)
                    TriggerServerEvent("parking:spawnObject", data.object, dest, heading)
                    StopAnimTask(ped, "anim@narcotics@trash", "drop_front", 1.0)
                    ClearPedTasks(ped)
                    RemoveAnimDict("anim@narcotics@trash")
                    TriggerEvent('parking:OpenObjectMenu')
                else
                    lib.notify({
                        title = Lang.Lang['operation_cancelled'],
                        type = 'error'
                    })
                    DeleteObject(obj)
                end
                
                placed = true
            end

            if IsControlPressed(0, 175) then
                local currentHeading = GetEntityHeading(obj)
                local newHeading = currentHeading + rotationSpeed
                SetEntityHeading(obj, newHeading)
                print('Rotating Right: ' .. newHeading)
            end
            if IsControlPressed(0, 174) then 
                local currentHeading = GetEntityHeading(obj)
                local newHeading = currentHeading - rotationSpeed
                SetEntityHeading(obj, newHeading)
                print('Rotating Left: ' .. newHeading)
            end
            
            if IsControlJustPressed(0, 47) then 
                lib.hideTextUI()
                placed = false
                DeleteObject(obj)
                return
            end
        end
    end
end)
