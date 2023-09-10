ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local isInInventory        = false
local poid		           = 0

local currentBagCoords     = nil
local realCurrentBagCoords = nil
local bagWeight            = 0

local inventory, money, weapons

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		SetNuiFocus(false,false)
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)

	if guiEnabled then
		EnableGui(false, uiType)
	end
end)

function EnableGui(state, ui)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = ui,
		enable = state
	})

    if state == false then
        currentBagCoords = nil
        isInInventory    = false
    end

    setPlayerInInventory(state)

end

function isGuiEnabled()
	return guiEnabled
end

RegisterNUICallback('closeNUI', function()
	EnableGui(false, uiType)
end)

function closeBagUI()
    if isInInventory then
        EnableGui(false, uiType)
    end
end


function closeBagUIOnRemoval(entityCoords)

    if isInInventory and entityCoords == currentBagCoords then
        EnableGui(false, uiType)
    end
end

RegisterNetEvent('tp-advancedbags:openBagInventory')
AddEventHandler('tp-advancedbags:openBagInventory', function(_data, coords, entityCoordsTable)

	if not isDead then

        currentBagCoords     = coords
        realCurrentBagCoords = entityCoordsTable
        
        uiType = "enable_loading"

        EnableGui(true, uiType)
    
        loadPlayerInventory()
        loadOtherInventory(_data)

        DisableControlAction(0, 57)
    
        isInInventory = true
    
        Wait(250)

        uiType = "enable_inventory_otherInventory"
        
        EnableGui(true, uiType)
			 
	end
end)


RegisterNUICallback("nodrag",function(data, cb)  
    SendNUIMessage({action = "nodrag"})
end)

function loadPlayerInventory(targetSource)

    local isOtherSource = false

    if targetSource == nil then
        targetSource = GetPlayerServerId(PlayerId())
    else
        isOtherSource = true
    end

    ESX.TriggerServerCallback("tp-advancedbags:getPlayerInventory",function(data)
            items = {}
            inventory = data.inventory
            money = data.money
            black_money = data.black_money
            weapons = data.weapons
            DisableControlAction(0, 57)
            
            if money ~= nil and money > 0 then
                moneyData = {
                    label = "Cash",
                    name = "cash",
                    type = "item_money",
                    count = money,
                    usable = false,
                    rare = false,
                    limit = -1,
                    canRemove = true
                }

                table.insert(items, moneyData)
            end

            if black_money > 0 then
                blackMoneyData = {
                    label = "Black Money",
                    name = "black_money",
                    type = "item_black_money",
                    count = black_money,
                    usable = false,
                    rare = false,
                    limit = -1,
                    canRemove = true
                }

                table.insert(items, blackMoneyData)
            end


            if inventory ~= nil then
                for key, value in pairs(inventory) do
                    if inventory[key].count <= 0 then
                        inventory[key] = nil
                    else
                        inventory[key].type = "item_standard"
                        table.insert(items, inventory[key])
                    end
                end
            end

            if weapons ~= nil then
                for key, value in pairs(weapons) do
                    local weaponHash = GetHashKey(weapons[key].name)
                    local playerPed = PlayerPedId()
                    -- if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= "WEAPON_UNARMED" then
                    if weapons[key].name ~= "WEAPON_UNARMED" then

                        local weaponLabel = weapons[key].label

                        if Config.WeaponLabelNames[weapons[key].name] then
                            weaponLabel = Config.WeaponLabelNames[weapons[key].name]
                        end

                        table.insert(
                            items,
                            {
                                label = weaponLabel,
                                count = 1,
                                limit = -1,
                                type = "item_weapon",
                                name = weapons[key].name,
                                usable = false,
                                rare = false,
                                canRemove = true
                            }
                        )
                    end
                end
            end

            SendNUIMessage(
                {
                    action = "setItems",
                    itemList = items,
                    isTarget = isOtherSource
                }
            )
        end,
        targetSource
    )
end

function loadOtherInventory(_data)
    local data      = _data

    bagWeight       = 0

    items           = {}
    money           = data.money
    black_money     = data.black_money
    inventory       = data.inventory
    weapons         = data.weapons

    DisableControlAction(0, 57)

    if money ~= nil and money > 0 then

        local moneyWeight =  (Config.MoneyWeight * money) / 1000
        bagWeight         = bagWeight + moneyWeight

        moneyData = {
            label = "Cash",
            name = "cash",
            type = "item_money",
            count = money,
            usable = false,
            rare = false,
            limit = -1,
            canRemove = true
        }

        table.insert(items, moneyData)
    end

    if black_money > 0 then

        local blackMoneyWeight =  (Config.BlackMoneyWeight * black_money) / 1000
        bagWeight              = bagWeight + blackMoneyWeight

        blackMoneyData = {
            label = "Black Money",
            name = "black_money",
            type = "item_black_money",
            count = black_money,
            usable = false,
            rare = false,
            limit = -1,
            canRemove = true
        }

        table.insert(items, blackMoneyData)
    end

    if inventory ~= nil then
        for key, value in pairs(inventory) do

            if value.count > 0 then

                bagWeight = bagWeight + (value.weight * value.count)
                inventory[key].type = "item_standard"
                table.insert(items, inventory[key])

            end
        end
    end


    if weapons ~= nil then
        for key, value in pairs(weapons) do

            if weapons[key].count > 0 then

                if weapons[key].label ~= "NOT_AVAILABLE" then

                    local playerPed    = PlayerPedId()
                    local weaponHash   = GetHashKey(weapons[key].name)

                    local weaponsCount = weapons[key].count
                    local weaponLabel  = weapons[key].label

                    bagWeight = bagWeight + (value.weight * weapons[key].count)
    
                    if Config.WeaponLabelNames[weapons[key].name] then
                        weaponLabel = Config.WeaponLabelNames[weapons[key].name]
                    end
    
                    table.insert(
                        items,
                        {
                            label = weaponLabel,
                            count = weaponsCount,
                            limit = -1,
                            type = "item_weapon",
                            name = weapons[key].name,
                            usable = false,
                            rare = false,
                            canRemove = true
                        }
                    )
                end
            end
        end
    end

    if round(bagWeight, 4) == 99.9999 then bagWeight = 100 end

    SendNUIMessage({action = "setBagCurrentWeight", weight = round(bagWeight, 2), maxWeight = Config.Limit})

    SendNUIMessage(
        {
            action = "setOtherInventoryItems",
            itemList = items
        }
    )

end

RegisterNUICallback(
    "TakeFromOtherInventory",
    function(data, cb)
        if IsPedSittingInAnyVehicle(playerPed) then
            return
        end

        if type(data.number) == "number" and math.floor(data.number) == data.number then
            local count = tonumber(data.number)

            if data.item and data.item.type == "item_weapon" then
                count = 1
            end

            if data.item then
                TriggerServerEvent("tp-advancedbags:tradeFromOtherInventory", currentBagCoords, data.item.type, data.item.name, count, data.item.count)
            end
        end
    
        Wait(250)
        ESX.TriggerServerCallback("tp-advancedbags:getOtherInventory",function(bag_data)

            loadPlayerInventory()
            loadOtherInventory(bag_data)

            TriggerServerEvent("tp-advancedbags:requestBagUpdate", realCurrentBagCoords)
    
            cb("ok")
    
        end, currentBagCoords)
    end
)

RegisterNUICallback(
    "TakeFromInventory",
    function(data, cb)
        if IsPedSittingInAnyVehicle(playerPed) then
            return
        end

        if type(data.number) == "number" and math.floor(data.number) == data.number then
            local count = tonumber(data.number)

            if data.item and data.item.type == "item_weapon" then
                count = 1
            end

            if data.item then
                TriggerServerEvent("tp-advancedbags:tradeFromInventory", bagWeight, currentBagCoords, data.item.type, data.item.name, count, data.item.count)
            end
        end
    
        Wait(250)
        ESX.TriggerServerCallback("tp-advancedbags:getOtherInventory",function(bag_data)

            loadPlayerInventory()
            loadOtherInventory(bag_data)
    
            TriggerServerEvent("tp-advancedbags:requestBagUpdate", realCurrentBagCoords)

            cb("ok")
    
        end, currentBagCoords)
    end
)
