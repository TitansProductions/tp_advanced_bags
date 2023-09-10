ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local arrayWeight = Config.localWeight

-- Return the sum of all item in pPlayer inventory
function getInventoryWeight(pPlayer)
    local weight = 0
	local itemWeight = 0
  
	if #pPlayer.inventory > 0 then
		for i=1, #pPlayer.inventory, 1 do
		  if pPlayer.inventory[i] ~= nil then
			itemWeight = Config.DefaultWeight
			if arrayWeight[pPlayer.inventory[i].name] ~= nil then
			  itemWeight = arrayWeight[pPlayer.inventory[i].name]
			end
			weight = weight + (itemWeight * pPlayer.inventory[i].count)
		  end
		end
	end
  
	return weight
end

RegisterServerEvent('tp-advancedbags:FUpdate')
AddEventHandler('tp-advancedbags:FUpdate', function(xPlayer)
    local source_ = source
    local weight = getInventoryWeight(xPlayer)
    TriggerClientEvent('tp-advancedbags:change',source_,weight)
end)
  
  
RegisterServerEvent('tp-advancedbags:Update')
AddEventHandler('tp-advancedbags:Update', function(source)
    local source_ = source
    local xPlayer = ESX.GetPlayerFromId(source_)
    local weight = getInventoryWeight(xPlayer)
    TriggerClientEvent('tp-advancedbags:change',source_,weight)
end)


ESX.RegisterServerCallback("tp-advancedbags:getPlayerInventory", function(source, cb, target)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then

    cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), black_money = targetXPlayer.getAccount('black_money').money, weapons = targetXPlayer.loadout})

	else
		cb(nil)
	end
end)
