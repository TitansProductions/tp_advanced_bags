ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(30)
    end
end)

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local objectData            = {}
local isPlayerDead          = false
local isBusy                = false
local inZone                = false
local inInventory           = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData, isNew) 
	ESX.PlayerLoaded = true
	ESX.PlayerData = playerData

    Wait(2000)
    ESX.TriggerServerCallback('tp-advancedbags:fetchObjectsData', function(data)
        objectData = data
    end)

end)

AddEventHandler('esx:onPlayerDeath', function(data)
    isPlayerDead = true
    isBusy = false
end)

AddEventHandler('playerSpawned', function()
    isPlayerDead = false
    isBusy = false
end)

-- Supporting Disc-Death Script for player revive.
AddEventHandler('disc-death:onPlayerRevive', function(data)
    isPlayerDead = false
    isBusy = false
end)

-- Entering a blacklisted zone.
AddEventHandler('tp-advancedbags:hasEnteredZone', function(zone)
    inZone = true

    isInsideBlackListedZone(true)

    if Config.BlackListedZonesDebug then
        print("You are inside of a blacklisted zone.")
    end
end)

-- Leaving a blacklisted zone.
AddEventHandler('tp-advancedbags:hasExitedZone', function(zone)
    inZone = false

    isInsideBlackListedZone(false)

    if Config.BlackListedZonesDebug then
        print("You are not inside of a blacklisted zone.")
    end
end)

-- Enter / Exit zone events
if Config.BlackListedZones then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1250)

            local coords      = GetEntityCoords(PlayerPedId())
            local isInZone  = false
            local currentZone = nil
    
            for k,v in pairs(Config.Zones) do
                if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
                    isInZone  = true
                    currentZone = k
                end
            end
    
            if isInZone then
                HasAlreadyEnteredMarker = true
                LastZone                = currentZone
                TriggerEvent('tp-advancedbags:hasEnteredZone', currentZone)
            end
    
            if not isInZone then
                HasAlreadyEnteredMarker = false
                TriggerEvent('tp-advancedbags:hasExitedZone', LastZone)
            end
        end
    end)
end

RegisterNetEvent("tp-advancedbags:onNewBagObjectInfo")
AddEventHandler("tp-advancedbags:onNewBagObjectInfo", function(entityCoords, data)

    local newCoords = round(entityCoords.x, 1) .. round(entityCoords.y, 1)
    
    objectData[newCoords] = data
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local pedCoords = GetEntityCoords(PlayerPedId())
        local objectId = GetClosestObjectOfType(pedCoords, 1.0, GetHashKey("xm_prop_x17_bag_01a"), false)

        local canDoAction                    = false

		local entityCoords = GetEntityCoords(objectId)
        local newCoords = round(entityCoords.x, 1) .. round(entityCoords.y, 1)
		local sleep = true

        if not isPlayerDead and not isBusy and not inInventory then
            
            if DoesEntityExist(objectId) and objectData[newCoords] then
            
                sleep = false
                
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 2.0 then
                    canDoAction = true
                end

                if objectData[newCoords].locked == 0 then
                    ESX.ShowHelpNotification(_U("near_to_bag"))
                else
                    ESX.ShowHelpNotification(_U("near_to_bag2"))
                end

                -- on Bag opening.
                if IsControlJustReleased(0, Keys['E']) then

                    isBusy = true

                    if canDoAction then

                        ESX.TriggerServerCallback("tp-advancedbags:getOtherInventory",function(_data)

                            if _data.locked == 1 then
    
                                local _title = _U('luggage_lock_menu_title')

                                if _data.identifier == _data.targetIdentifier then
                                    _title = _U('luggage_lock_menu_title') .. " | Password: " .. _data.lock_password
                                end

                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
    
                                    title = _title
                                  }, function(data, menu)
                                    local amount = tonumber(data.value)
                                
                                    if amount == nil or amount < 0 then
                                      ESX.ShowNotification(_U('invalid_amount'), true)
                                    else
            
                                        if tonumber(_data.lock_password) ~= amount then
                                            ESX.ShowNotification(_U('password_incorrect'), true)
                                        else
                                            menu.close()
                                            Wait(100)
                                            TriggerEvent('tp-advancedbags:openBagInventory', _data, newCoords, entityCoords)
                                        end
    
                                    end
                                  end, function(data, menu)
                                    menu.close()
                                end)
                            else
                                TriggerEvent('tp-advancedbags:openBagInventory', _data, newCoords, entityCoords)
                            end

                            isBusy = false

                        end, newCoords)

                    else
                        ESX.ShowNotification(_U('another_player_near'))
                        isBusy = false
                    end
                end

                -- on Bag Pickup.
                if IsControlJustReleased(0, Keys['G']) then
                    
                    isBusy = true

                    if canDoAction then
                        TriggerEvent("tp-advancedbags:onBagPickup", objectData[newCoords], newCoords)

                        Wait(2000)
                    else
                        ESX.ShowNotification(_U('another_player_near'))
                    end

                    isBusy = false 
                end

                -- on Bag Luggage Placement / Removal.
                if IsControlJustReleased(0, Keys['H']) then
                    isBusy = true

                    if canDoAction then
                        if objectData[newCoords].locked == 1 then
                            TriggerEvent("tp-advancedbags:onBagLuggageLock", entityCoords, 0)
                        else
                            TriggerEvent("tp-advancedbags:onBagLuggageLock", entityCoords, 1)
                        end
                    else
                        ESX.ShowNotification(_U('another_player_near'))
                    end

                    isBusy = false

                end
            end
        end

		if sleep then
			Citizen.Wait(1500)
		end
    end
end)

if Config.EnableBlackListedZoneRadiusBlips then
    Citizen.CreateThread(function()
        for _, info in pairs(Config.Zones) do

            info.blip = AddBlipForRadius(info.Pos.x, info.Pos.y, info.Pos.z, info.Size.x)
        
            SetBlipHighDetail(info.blip, true)
            SetBlipDisplay(info.blip, 4)
            SetBlipColour(info.blip, 1)
            SetBlipAlpha (info.blip, 128)
        
        
            info.blip = AddBlipForCoord(info.Pos.x, info.Pos.y, info.Pos.z)
            SetBlipSprite(info.blip, 163)
            SetBlipDisplay(info.blip, 3)
            SetBlipScale(info.blip, 1.0)
            SetBlipColour(info.blip, 1)
            SetBlipAsShortRange(info.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(_)
            EndTextCommandSetBlipName(info.blip)
    
        end
    end)
end


function setPlayerInInventory(cb)
    inInventory = cb
end

function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end


