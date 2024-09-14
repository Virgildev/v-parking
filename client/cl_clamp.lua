local wheelClampProp = 'rottenberger_prop_wheel_clamp'
local clampedVehicles = {}

function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

function GetClosestVehicleTire(vehicle)
    local tireBones = {
        "wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1",
        "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3",
        "wheel_lr", "wheel_rr"
    }
    local tireIndex = {
        ["wheel_lf"] = 0, ["wheel_rf"] = 1,
        ["wheel_lm1"] = 2, ["wheel_rm1"] = 3,
        ["wheel_lm2"] = 45, ["wheel_rm2"] = 47,
        ["wheel_lm3"] = 46, ["wheel_rm3"] = 48,
        ["wheel_lr"] = 4, ["wheel_rr"] = 5
    }

    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed, false)
    local minDistance = 1.0
    local closestTire = nil

    for _, boneName in ipairs(tireBones) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIndex ~= -1 then
            local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            local distance = #(plyPos - bonePos)

            if closestTire == nil or distance < closestTire.boneDist then
                closestTire = {
                    bone = boneName,
                    boneDist = distance,
                    bonePos = bonePos,
                    tireIndex = tireIndex[boneName]
                }
            end
        end
    end

    return closestTire
end

function placeWheelClamp(vehicle)
    local playerPed = PlayerPedId()
    local vehicleCoords = GetEntityCoords(vehicle)

    local closestTire = GetClosestVehicleTire(vehicle)
    if not closestTire then
        lib.notify({
            title = Lang.Lang['wheel_clamp'],
            description = Lang.Lang['no_suitable_wheel'],
            type = 'error',
            position = 'top-right'
        })
        return
    end

    -- Define offsets for each wheel with Y and Z rotations
    local offsets = {
        wheel_lf = { x = -0.1, y = 0.0, z = -0.15, rotY = 0.0, rotZ = 270.0 },   -- Left front
        wheel_rf = { x = -0.1, y = 0.0, z = 0.15, rotY = 180.0, rotZ = 270.0 }, -- Right front
        wheel_lr = { x = -0.1, y = 0.0, z = -0.15, rotY = 0.0, rotZ = 270.0 },   -- Left rear
        wheel_rr = { x = -0.1, y = 0.0, z = 0.15, rotY = 180.0, rotZ = 270.0 }, -- Right rear
    }

    local clampOffset = offsets[closestTire.bone]
    if not clampOffset then
        clampOffset = { x = 0.05, y = 0.0, z = 0.02, rotY = 0.0, rotZ = 0.0 }
    end

    if lib.progressCircle({
        duration = Config.ClampProgress,
        position = 'bottom',
        anim = {
            dict = 'mp_car_bomb',
            clip = 'car_bomb_mechanic'
        },
        disable = {
            move = true,
            car = true,
        }
    }) then
        local bonePos = closestTire.bonePos
        loadModel(wheelClampProp)

        local clampObject = CreateObject(GetHashKey(wheelClampProp), bonePos.x, bonePos.y, bonePos.z, true, true, true)
        AttachEntityToEntity(clampObject, vehicle, GetEntityBoneIndexByName(vehicle, closestTire.bone), 
            clampOffset.x, clampOffset.y, clampOffset.z, 
            0.0, clampOffset.rotY, clampOffset.rotZ, true, true, false, false, 2, true
        )

        if not clampedVehicles[vehicle] then
            clampedVehicles[vehicle] = {}
        end
        table.insert(clampedVehicles[vehicle], clampObject)

        SetVehicleEngineOn(vehicle, false, true, true)
        SetVehicleUndriveable(vehicle, true)
        FreezeEntityPosition(vehicle, true)

        TriggerServerEvent('wheel_clamp:place', vehicle) 

        lib.notify({
            title = Lang.Lang['wheel_clamp'],
            description = Lang.Lang['clamp_placed'],
            type = 'success',
            position = 'top-right'
        })
    else
        lib.notify({
            title = Lang.Lang['wheel_clamp'],
            description = Lang.Lang['clamp_placement_canceled'],
            type = 'error',
            position = 'top-right'
        })
    end
end

function removeWheelClamp(vehicle)
    if clampedVehicles[vehicle] then
        if lib.progressCircle({
            duration = Config.ClampProgress,
            position = 'bottom',
            anim = {
                dict = 'mp_car_bomb',
                clip = 'car_bomb_mechanic'
            },
            disable = {
                move = true,
                car = true,
            }
        }) then
            for _, clampObject in ipairs(clampedVehicles[vehicle]) do
                DeleteObject(clampObject)
            end
            clampedVehicles[vehicle] = nil

            FreezeEntityPosition(vehicle, false)
            SetVehicleUndriveable(vehicle, false)
            SetEntityCanBeDamaged(vehicle, true)

            TriggerServerEvent('wheel_clamp:remove', vehicle) 

            lib.notify({
                title = Lang.Lang['wheel_clamp'],
                description = Lang.Lang['clamp_removed'],
                type = 'success',
                position = 'top-right'
            })
        else
            lib.notify({
                title = Lang.Lang['wheel_clamp'],
                description = Lang.Lang['clamp_removal_canceled'],
                type = 'error',
                position = 'top-right'
            })
        end
    else
        lib.notify({
            title = Lang.Lang['wheel_clamp'],
            description = Lang.Lang['clamp_not_found'],
            type = 'error',
            position = 'top-right'
        })
    end
end

local tireBones = {
    "wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1",
    "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3",
    "wheel_lr", "wheel_rr"
}

exports.ox_target:addGlobalVehicle({
    {
        label = Lang.Lang['clamp_wheel_target'], 
        icon = 'fa-solid fa-lock',
        distance = 3.0, 
        groups = Config.ParkingJobs,
        items = Config.ClampItem,
        bones = tireBones,
        canInteract = function(entity, distance, coords, name, bone)
            return not clampedVehicles[entity]
        end,
        onSelect = function(data)
            local vehicle = data.entity
            local boneName = data.bone 
            placeWheelClamp(vehicle, boneName)
        end
    }
})

exports.ox_target:addGlobalVehicle({
    {
        label = Lang.Lang['unclamp_wheel_target'], 
        icon = 'fa-solid fa-unlock',
        distance = 3.0, 
        groups = Config.ParkingJobs,
        bones = tireBones, 
        canInteract = function(entity, distance, coords, name, bone)
            return clampedVehicles[entity]
        end,
        onSelect = function(data)
            local vehicle = data.entity
            local boneName = data.bone 
            removeWheelClamp(vehicle, boneName)
        end
    }
})
