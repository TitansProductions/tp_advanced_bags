ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local insideBlacklistedZone = false
local isBusy                = false

function isInsideBlackListedZone(cb)
	insideBlacklistedZone = cb
end

RegisterNetEvent("tp-advancedbags:onBagPlacement")
AddEventHandler("tp-advancedbags:onBagPlacement", function()

	if not insideBlacklistedZone then

		if not isBusy then
			isBusy                    = true
			local playerPed           = PlayerPedId()
			local pos                 = GetEntityCoords(playerPed)
		
			local x,y,z               = table.unpack(pos)
			local prop                = CreateObject(GetHashKey("xm_prop_x17_bag_01a"), x, y, z + 0.2, true, true, true)
			local boneIndex           = GetPedBoneIndex(playerPed, 57005)
		
			local animDict, animation = 'random@domestic', 'pickup_low'
		
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.42, 0.0, 0.0, 0.0, 280.0, 53.0, true, true, false, true, 1, true)
		
			ESX.Streaming.RequestAnimDict(animDict, function()
				TaskPlayAnim(playerPed, animDict, animation, 8.0, -8, 1500, 2, 0, 0, 0, 0)
		
				Wait(1000)
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
				TriggerServerEvent("tp-advancedbags:onBagSuccessfullPlacement", pos)
	
				Wait(1000)
				isBusy = false
			end)
		end
	else
		ESX.ShowNotification(_U("black_listed_zone"), true)
	end

end)

RegisterNetEvent("tp-advancedbags:onBagPickup")
AddEventHandler("tp-advancedbags:onBagPickup", function(data, newCoords)

	if not isBusy then
		isBusy                    = true

		local playerPed           = PlayerPedId()
		local pos                 = GetEntityCoords(playerPed)
	
		local animDict, animation = 'random@domestic', 'pickup_low'
		
		ESX.Streaming.RequestAnimDict(animDict, function()
			TaskPlayAnim(playerPed, animDict, animation, 8.0, -8, 1500, 2, 0, 0, 0, 0)
	
			Wait(1000)
			ClearPedSecondaryTask(playerPed)
	
			-- Checking if bag contains any kind of money.
			if data.money > 0 or data.black_money > 0 then
				ESX.ShowNotification(_U("cannot_pickup"), true)
				isBusy = false
				return
			end
	
			-- Checking if bag contains any items.
			for i=1, #data.inventory, 1 do
	
				if data.inventory[i].count >= 1 then
					ESX.ShowNotification(_U("cannot_pickup"), true)
					isBusy = false
					return
				end
			end
			
			-- Checking if bag contains any weapons.
			for i=1, #data.weapons, 1 do
		
				if data.weapons[i].label ~= "NOT_AVAILABLE" then
					ESX.ShowNotification(_U("cannot_pickup"), true)
					isBusy = false
					return
				end
			end
	
			-- If bag is empty, we are now able to pickup the bag.
			TriggerServerEvent("tp-advancedbags:onBagPickupDataRemove", data, newCoords)
	
			Wait(1000)
			isBusy = false
		end)
	end

end)

RegisterNetEvent("tp-advancedbags:onBagLuggageLock")
AddEventHandler("tp-advancedbags:onBagLuggageLock", function(newCoords, status)
	if not isBusy then
		isBusy = true

		ESX.TriggerServerCallback("tp-advancedbags:hasSpecifiedItem",function(hasItem)

			local playerPed           = PlayerPedId()
			local pos                 = GetEntityCoords(playerPed)
		
			local animDict, animation = 'random@domestic', 'pickup_low'
			
			ESX.Streaming.RequestAnimDict(animDict, function()
				TaskPlayAnim(playerPed, animDict, animation, 8.0, -8, 1500, 2, 0, 0, 0, 0)
		
				Wait(1000)
				ClearPedSecondaryTask(playerPed)

				if status == 1 then
					if hasItem then
						TriggerServerEvent("tp-advancedbags:onBagLuggageLockStatus", newCoords, 1)
					else
						ESX.ShowNotification(_U("no_luggage_lock"), true)
					end
				else
					TriggerServerEvent("tp-advancedbags:onBagLuggageLockStatus", newCoords, 0)
				end
			end)

			Wait(1000)
			isBusy = false
			
		end, "luggage_lock")
	end

end)