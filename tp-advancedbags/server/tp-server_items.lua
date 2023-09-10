ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-------------------------------------------------------------------
-- Bag Placement.
-------------------------------------------------------------------
ESX.RegisterUsableItem('bag', function(source) 
	local _source = source
    
    TriggerClientEvent("tp-advancedbags:onBagPlacement", xPlayer.source)
end) 

ESX.RegisterServerCallback("tp-advancedbags:hasSpecifiedItem", function(source, cb, item)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
		local targetItem = xPlayer.getInventoryItem(item)

        if targetItem and targetItem.count >= 1 then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)
