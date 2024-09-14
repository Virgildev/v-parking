Config = {}

--[[
     ██╗ ██████╗ ██████╗      ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
     ██║██╔═══██╗██╔══██╗    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
     ██║██║   ██║██████╔╝    ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
██   ██║██║   ██║██╔══██╗    ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
╚█████╔╝╚██████╔╝██████╔╝    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
 ╚════╝  ╚═════╝ ╚═════╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝                                                                            
]]
Config.PedLocations = {
    {
        coords = vector3(442.0, -1021.0, 28.5), -- Location of the ped
        heading = 180.0, -- Rotation/heading of the ped
        pedModel = 's_m_y_cop_01', -- Ped model
        jobs = {'police', 'sheriff'}, -- List of jobs allowed to interact with this ped
        spawnLocations = vector4(442.5027, -1024.2810, 28.6822, 93.9930), -- Location where the vehicle spawns
    },
    -- Additional PedLocations can be added here
}

-- Parking Hut Models that can be targetted to see the ticket management menu
Config.HutModels = {
    'prop_parking_hut_1',
    'prop_parking_hut_2'
}

-- Vehicle Config
Config.Vehicles = {
    { name = 'pwcart', label = 'Parking Maid Pigeon' },
    { name = 'policeb', label = 'Police Bike' },
    -- Add more vehicles here
}

-- Parking Jobs Config
Config.ParkingJobs = { 'police', 'parking' }

--[[
 ██████╗ ██████╗      ██╗███████╗ ██████╗████████╗    ██████╗ ██╗      █████╗  ██████╗███████╗██████╗ 
██╔═══██╗██╔══██╗     ██║██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██║     ██╔══██╗██╔════╝██╔════╝██╔══██╗
██║   ██║██████╔╝     ██║█████╗  ██║        ██║       ██████╔╝██║     ███████║██║     █████╗  ██████╔╝
██║   ██║██╔══██╗██   ██║██╔══╝  ██║        ██║       ██╔═══╝ ██║     ██╔══██║██║     ██╔══╝  ██╔══██╗
╚██████╔╝██████╔╝╚█████╔╝███████╗╚██████╗   ██║       ██║     ███████╗██║  ██║╚██████╗███████╗██║  ██║
 ╚═════╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝       ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝ 
]]

Config.UseObjectPlacer = true --true or false

Config.ObjectPlacerProgress = 5000 --progress bar duration for placing and removing props

Config.Objects = {
    ["cone"] = { model = `prop_phonebox_05a`, freeze = false }, --Label, prop model, frozen or not frozen (can be moved or not)
    ["barrier"] = { model = `prop_barrier_work06a`, freeze = true },
    ["Speed Limit"] = { model = `prop_snow_sign_road_06g`, freeze = true },
    ["Do Not Block"] = { model = `prop_sign_road_03e`, freeze = true },
    ["tent"] = { model = `prop_gazebo_03`, freeze = true },
    ["light"] = { model = `prop_worklight_03b`, freeze = true },
    ["Parking Hut"] = { model = `prop_parking_hut_2`, freeze = true },
    ["Post"] = { model = `prop_bollard_02a`, freeze = true },
    ["Barrier Gate"] = { model = `prop_sec_barier_base_01`, freeze = true },
}

Config.ObjectMenuCommand = 'trafficobjectmenu' -- DO NOT USE 'OBJECTMENU' OR IT WILL CONFLICT WITH QB-POLICEJOB AND QBX-POLICEJOB

--[[
██████╗  █████╗ ██████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗     ███╗   ███╗███████╗████████╗███████╗██████╗ 
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██║████╗  ██║██╔════╝     ████╗ ████║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
██████╔╝███████║██████╔╝█████╔╝ ██║██╔██╗ ██║██║  ███╗    ██╔████╔██║█████╗     ██║   █████╗  ██████╔╝
██╔═══╝ ██╔══██║██╔══██╗██╔═██╗ ██║██║╚██╗██║██║   ██║    ██║╚██╔╝██║██╔══╝     ██║   ██╔══╝  ██╔══██╗
██║     ██║  ██║██║  ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║ ╚═╝ ██║███████╗   ██║   ███████╗██║  ██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝                                                                                                     
]]
Config.CostPerMinute = 1 -- Cost per minute in dollars
Config.MaxTime = 120 -- Maximum parking time in minutes (2 hours)
Config.meterCheckTime = 60000
Config.Models = {
    `prop_parknmeter_01`,
    `prop_parknmeter_02`,
}


--[[
████████╗██╗ ██████╗██╗  ██╗███████╗████████╗    
╚══██╔══╝██║██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝    
   ██║   ██║██║     █████╔╝ █████╗     ██║      
   ██║   ██║██║     ██╔═██╗ ██╔══╝     ██║       
   ██║   ██║╚██████╗██║  ██╗███████╗   ██║       
   ╚═╝   ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝                                                                                                   
]]

Config.TicketPaymentLocation = {
    ped = {
        model = 's_m_m_security_01', -- Change this to the ped model you want
        coords = vector3(444.9550, -984.0654, 29.6896), -- Replace with your location coordinates
        heading = 89.0 -- Adjust the heading as needed
    },
    interaction = {
        radius = 2.0, -- Radius for interaction
        target = {
            name = 'ticket_payment',
            icon = 'fas fa-credit-card',
            label = 'Pay Ticket',
            onSelect = function()
                TriggerEvent('ticketing:payTicket')
            end
        }
    }
}

-- Prop Config
Config.propName = 'prop_amanda_note_01'

-- Max price a player can put on a parking ticket
Config.MaxTicketPrice = 2500

--[[
 ██████╗██╗      █████╗ ███╗   ███╗██████╗ ██╗███╗   ██╗ ██████╗ 
██╔════╝██║     ██╔══██╗████╗ ████║██╔══██╗██║████╗  ██║██╔════╝ 
██║     ██║     ███████║██╔████╔██║██████╔╝██║██╔██╗ ██║██║  ███╗
██║     ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║██║╚██╗██║██║   ██║
╚██████╗███████╗██║  ██║██║ ╚═╝ ██║██║     ██║██║ ╚████║╚██████╔╝
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝                                                                  
]]

--Clamp Item
Config.ClampItem = 'clamp'

--Clamp progress bar, on and off
Config.ClampProgress = 2000

--[[
████████╗██╗██████╗ ███████╗    ███████╗██╗      █████╗ ███████╗██╗  ██╗██╗███╗   ██╗ ██████╗ 
╚══██╔══╝██║██╔══██╗██╔════╝    ██╔════╝██║     ██╔══██╗██╔════╝██║  ██║██║████╗  ██║██╔════╝ 
   ██║   ██║██████╔╝█████╗      ███████╗██║     ███████║███████╗███████║██║██╔██╗ ██║██║  ███╗
   ██║   ██║██╔══██╗██╔══╝      ╚════██║██║     ██╔══██║╚════██║██╔══██║██║██║╚██╗██║██║   ██║
   ██║   ██║██║  ██║███████╗    ███████║███████╗██║  ██║███████║██║  ██║██║██║ ╚████║╚██████╔╝
   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝                                                                                               
]]

Config.UseSlash = true -- true or false, use slashing or not
Config.Knives = {
    `WEAPON_KNIFE`,
    `WEAPON_BOTTLE`,
    `WEAPON_DAGGER`,
    `WEAPON_SWITCHBLADE`,
}
Config.SlashProgress = 5000
Config.SlashSkillCheck = { 'easy', 'medium', 'easy' }
Config.SlashSkillCheckKeys = { 'w', 'a', 's', 'd' }
