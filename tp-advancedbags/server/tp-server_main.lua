
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local objectData      = {}

-- Generating bags on resource start.
AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

	Wait(5000)
	local spawnedBags                    = 0

	local bagResults                     = MySQL.Sync.fetchAll('SELECT * FROM bag_inventories')
	local itemResult, weaponResult       = MySQL.Sync.fetchAll('SELECT * FROM items'), ESX.GetWeaponList()

	for i=1, #bagResults, 1 do

		local itemElements, weaponElements   = {}, {}
		local bag                            = bagResults[i]

		for i=1, #itemResult, 1 do
			local _weight = Config.localWeight[itemResult[i].name]
	
			if _weight == nil then
				_weight = Config.DefaultWeight
			end
	
			table.insert(itemElements, {
				name = itemResult[i].name, 
				label = itemResult[i].label, 
				weight = _weight, 
				count = 0
			})
		end
	
		for i=1, #weaponResult, 1 do
			local _weight = Config.localWeight[weaponResult[i].name]
	
			if _weight == nil then
				_weight = Config.DefaultWeaponWeight
			end
	
			table.insert(weaponElements, {
				name = weaponResult[i].name, 
				label = "NOT_AVAILABLE", 
				realLabel = weaponResult[i].label, 
				weight = _weight, 
				count = 1
			})
		end
		
		-- Loading all items & weapons from bag inventory after loading all items & weapons by the system.
		local inventory, weapons = json.decode(bag.inventory), json.decode(bag.weapons)

		for i=1, #itemElements, 1 do
			for key, value in pairs(inventory) do

				if itemElements[i].name == value.name then
					itemElements[i].count = value.count
				end
			end
		end

		for i=1, #weaponElements, 1 do
			for key, value in pairs(weapons) do
				if weaponElements[i].name == value.name then
					weaponElements[i].count = value.count
					weaponElements[i].label = weaponElements[i].realLabel
				end
			end
		end

		-- Spawn bag after loading all the items & weapons data.
		bag.x, bag.y, bag.z = tonumber(bag.x), tonumber(bag.y), tonumber(bag.z)
      
		local object = CreateObjectNoOffset(GetHashKey("xm_prop_x17_bag_01a"), bag.x, bag.y, bag.z, true, false)
		FreezeEntityPosition(object, true)

		local data = {id = bag.id, identifier = bag.identifier, targetIdentifier = nil, entity = object, inventory = itemElements, weapons = weaponElements, money = bag.money, black_money = bag.black_money, locked = bag.locked, lock_password = bag.lock_password}

		objectData[round(bag.x, 1) .. round(bag.y, 1)] = data

		local newCoords = vector3(bag.x, bag.y, bag.z)
		TriggerClientEvent('tp-advancedbags:onNewBagObjectInfo', -1, newCoords, data)

		spawnedBags = spawnedBags + 1

    end

	Citizen.Wait(5000)
	print("Successfully loaded: " .. spawnedBags .. " bags.")

end)

RegisterServerEvent("tp-advancedbags:onBagSuccessfullPlacement")
AddEventHandler("tp-advancedbags:onBagSuccessfullPlacement", function(entityCoords)
	local _source  = source
    local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('bag', 1)

    local newCoords = vector3(entityCoords.x, entityCoords.y, entityCoords.z - 1.0)

    local object = CreateObjectNoOffset(GetHashKey("xm_prop_x17_bag_01a"), newCoords.x, newCoords.y, newCoords.z, true, false)
    FreezeEntityPosition(object, true)

	-- Inserting to SQL the Bag ID & all symbols from the generator.
	local bagID = tostring(math.random(1000, 9999) .. math.random(1, 99) .. newCoords.x)
	bagID = bagID:gsub("%W", "")

	local bagPassword = tostring(math.random(10000, 99999))

	-- Inserting to SQL all the bag information.
	MySQL.Async.execute('INSERT INTO bag_inventories (id, identifier, name, x, y, z, lock_password) VALUES (@id, @identifier, @name, @x, @y, @z, @lock_password)',
	{
		['@id']            = bagID,
		['@identifier']    = xPlayer.identifier,
		['@name']          = GetPlayerName(source),
		['@x']             = tostring(newCoords.x),
		['@y']             = tostring(newCoords.y),
		['@z']             = tostring(newCoords.z),
		['@lock_password'] = bagPassword,
	})

    local itemResult, weaponResult       = MySQL.Sync.fetchAll('SELECT * FROM items'), ESX.GetWeaponList()
	local itemElements, weaponElements   = {}, {}

    for i=1, #itemResult, 1 do
		local _weight = Config.localWeight[itemResult[i].name]

		if _weight == nil then
			_weight = Config.DefaultWeight
		end

        table.insert(itemElements, {
			name = itemResult[i].name, 
			label = itemResult[i].label, 
			weight = _weight, 
			count = 0
		})
    end

	for i=1, #weaponResult, 1 do
		local _weight = Config.localWeight[weaponResult[i].name]

		if _weight == nil then
			_weight = Config.DefaultWeaponWeight
		end

		table.insert(weaponElements, {
			name = weaponResult[i].name, 
			label = "NOT_AVAILABLE", 
			realLabel = weaponResult[i].label, 
			weight = _weight, 
			count = 1
		})
	end

    local data = {id = bagID, identifier = xPlayer.identifier, targetIdentifier = nil, entity = object, inventory = itemElements, weapons = weaponElements, money = 0, black_money = 0, locked = 0, lock_password = bagPassword}

    objectData[round(entityCoords.x, 1) .. round(entityCoords.y, 1)] = data

    TriggerClientEvent('tp-advancedbags:onNewBagObjectInfo', -1, newCoords, data)

	if Config.Debug then
		print(GetPlayerName(_source) .. " placed up a bag with the ID: " .. bagID .. " and Lock Password: " .. bagPassword)
	end

end)

RegisterServerEvent("tp-advancedbags:requestBagUpdate")
AddEventHandler("tp-advancedbags:requestBagUpdate", function(entityCoords)
    local data = objectData[round(entityCoords.x, 1) .. round(entityCoords.y, 1)]

	local itemResult, weaponResult = {}, {}

	for i=1, #data.inventory, 1 do

		if data.inventory[i].count >= 1 then
			table.insert(itemResult, {
				name = data.inventory[i].name, 
				label = data.inventory[i].label, 
				count = data.inventory[i].count
			})
		end
    end
	
	for i=1, #data.weapons, 1 do

		if data.weapons[i].label ~= "NOT_AVAILABLE" then
			table.insert(weaponResult, {
				name = data.weapons[i].name, 
				label = data.weapons[i].label, 
				realLabel = data.weapons[i].realLabel, 
				count = data.weapons[i].count
			})
		end
    end

	MySQL.Sync.execute('UPDATE bag_inventories SET inventory = @inventory, weapons = @weapons, money = @money, black_money = @black_money WHERE id = @id', {
		["id"]            = data.id,
		["inventory"]     = json.encode(itemResult),
		["weapons"]       = json.encode(weaponResult),
		["money"]         = data.money,
		["black_money"]   = data.black_money,
	}) 

	TriggerClientEvent('tp-advancedbags:onNewBagObjectInfo', -1, entityCoords, data)
end)


RegisterServerEvent("tp-advancedbags:onBagLuggageLockStatus")
AddEventHandler("tp-advancedbags:onBagLuggageLockStatus", function(entityCoords, status)
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(source)

	if xPlayer then
		
		local data = objectData[round(entityCoords.x, 1) .. round(entityCoords.y, 1)]

		if data.identifier == xPlayer.identifier then
			data.locked = status
	
			MySQL.Sync.execute('UPDATE bag_inventories SET locked = @locked WHERE id = @id', {
				["id"]            = data.id,
				["locked"]        = status,
			}) 
		
			TriggerClientEvent('tp-advancedbags:onNewBagObjectInfo', -1, entityCoords, data)
	
			if status == 0 then 
				xPlayer.addInventoryItem("luggage_lock", 1) 

				TriggerClientEvent('esx:showNotification', _source, _U('removed_luggage_lock'))
			else 
				xPlayer.removeInventoryItem("luggage_lock", 1) 

				TriggerClientEvent('esx:showNotification', _source, _U('placed_luggage_lock'))
			end

		else
			TriggerClientEvent('esx:showNotification', _source, _U('bag_does_not_belong'))
		end

	end

end)


RegisterServerEvent("tp-advancedbags:onBagPickupDataRemove")
AddEventHandler("tp-advancedbags:onBagPickupDataRemove", function(data, entityCoords)
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.addInventoryItem("bag", 1)

	DeleteEntity(data.entity)
	MySQL.Sync.execute('DELETE FROM bag_inventories WHERE id = ' .. data.id)

	if Config.Debug then
		print(GetPlayerName(_source) .. " picked up a bag with the ID: " .. data.id)
	end

	Wait(1000)
    objectData[entityCoords] = nil
end)


RegisterServerEvent("tp-advancedbags:tradeFromOtherInventory")
AddEventHandler("tp-advancedbags:tradeFromOtherInventory", function(coords, type, itemName, itemCount, clickedItemCount)
	local _source = source

	local targetXPlayer = ESX.GetPlayerFromId(_source)

	if type == "item_standard" then

		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and clickedItemCount >= itemCount then

			targetXPlayer.addInventoryItem(itemName, itemCount)

			local inventory = objectData[coords].inventory

			for key, value in pairs(inventory) do
				if value.name == itemName then
					value.count = value.count - itemCount
				end
			end

		else
			TriggerClientEvent('esx:showNotification', _source, _U('permitted_amount_warning'))
		end

	elseif type == "item_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			targetXPlayer.addMoney(itemCount)

			objectData[coords].money = objectData[coords].money - itemCount
		else
			TriggerClientEvent('esx:showNotification', _source, _U('permitted_amount_warning'))

		end
	elseif type == "item_black_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			targetXPlayer.addAccountMoney("black_money", itemCount)

			objectData[coords].black_money = objectData[coords].black_money - itemCount
		else
			TriggerClientEvent('esx:showNotification', _source, _U('permitted_amount_warning'))
		end
	elseif type == "item_weapon" then
		if not targetXPlayer.hasWeapon(itemName) then

			targetXPlayer.addWeapon(itemName, itemCount)

			local inventory = objectData[coords].weapons

			for key, value in pairs(inventory) do

				if value.name == itemName then

					if (value.count - 1) <= 0 then
						value.count = 1
						value.label = "NOT_AVAILABLE"
					else
						value.count = value.count - 1
					end
					
				end
			end

		else
			TriggerClientEvent('esx:showNotification', _source, _U('already_carrying'))
		end
	end
end)

RegisterServerEvent("tp-advancedbags:tradeFromInventory")
AddEventHandler("tp-advancedbags:tradeFromInventory", function(bagWeight, coords, type, itemName, itemCount, clickedItemCount)
	local _source = source

	if bagWeight >= Config.Limit then
		TriggerClientEvent('esx:showNotification', _source, _U('weight_warning'))
		return
	end

	local targetXPlayer = ESX.GetPlayerFromId(_source)

	if type == "item_standard" then

		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and clickedItemCount >= itemCount then

			local _weight = Config.localWeight[itemName]

			if _weight == nil then
				_weight = Config.DefaultWeight
			end

			if bagWeight + (_weight * itemCount) > Config.Limit then
				TriggerClientEvent('esx:showNotification', _source, _U('weight_warning'))
				return
			end

			targetXPlayer.removeInventoryItem(itemName, itemCount)

			local inventory = objectData[coords].inventory

			for key, value in pairs(inventory) do
				if value.name == itemName then
					value.count = value.count + itemCount
				end
			end

		else
			TriggerClientEvent('esx:showNotification', _source, _U('amount_warning'))
		end

	elseif type == "item_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			local moneyWeight =  (Config.MoneyWeight * itemCount) / 1000

			if (bagWeight + moneyWeight) > Config.Limit then
				TriggerClientEvent('esx:showNotification', _source, _U('weight_warning'))
				return
			end

			targetXPlayer.removeMoney(itemCount)

			objectData[coords].money = objectData[coords].money + itemCount

		else
			TriggerClientEvent('esx:showNotification', _source, _U('amount_warning'))
		end
	elseif type == "item_black_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			local blackMoneyWeight =  (Config.BlackMoneyWeight * itemCount) / 1000

			if (bagWeight + blackMoneyWeight) > Config.Limit then
				TriggerClientEvent('esx:showNotification', _source, _U('weight_warning'))
				return
			end

			targetXPlayer.removeAccountMoney("black_money", itemCount)

			objectData[coords].black_money = objectData[coords].black_money + itemCount
		else
			TriggerClientEvent('esx:showNotification', _source, _U('amount_warning'))
		end

	elseif type == "item_weapon" then

		local inventory = objectData[coords].weapons

		for key, value in pairs(inventory) do

			if value.name == itemName then

				local _weight = Config.localWeight[itemName]

				if _weight == nil then
					_weight = Config.DefaultWeaponWeight
				end
	
				if bagWeight + (_weight * 1) > Config.Limit then
					TriggerClientEvent('esx:showNotification', _source, _U('weight_warning'))
					return
				end

				targetXPlayer.removeWeapon(itemName)

				if value.label == "NOT_AVAILABLE" then
					value.label = value.realLabel
				else
					value.count = value.count + 1
				end
				
			end
		end

	end
end)

ESX.RegisterServerCallback("tp-advancedbags:getOtherInventory", function(source, cb, coords)
	local _source = source

	if objectData[coords] and objectData[coords].entity then

		objectData[coords].targetIdentifier = ESX.GetPlayerFromId(_source).identifier

		cb(objectData[coords])
	else
		cb(nil)
	end

end)


ESX.RegisterServerCallback("tp-advancedbags:fetchObjectsData", function(source, cb, coords)
	cb(objectData)
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

	for k, v in pairs(objectData) do
		if v then
			DeleteEntity(v.entity)
			objectData[k] = nil
		end
		
    end

end)

function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

