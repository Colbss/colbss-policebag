local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("policebag", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	TriggerClientEvent('pb:client:UseBag', source, item)
end)

AddEventHandler('playerDropped', function (reason)
	print('Player ' .. GetPlayerName(source) .. ' dropped (Reason: ' .. reason .. ')')
end)

QBCore.Functions.CreateCallback("pb:server:RemoveBag", function(source, cb, item)
	local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
		return cb(true)
	else
		return cb(false)
	end
end)

QBCore.Functions.CreateCallback("pb:server:AddBag", function(source, cb)
	local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.AddItem("policebag", 1) then
		TriggerClientEvent('inventory:client:ItemBox', source, "policebag", "add")
		return cb(true)
	else
		return cb(false)
	end
end)

