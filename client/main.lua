
local QBCore = exports['qb-core']:GetCoreObject()

local bag_obj = nil
local bag_model = "prop_big_bag_01"

-- ################################ FUNCTIONS ################################

local RotationToDirection = function(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local RayCastGamePlayCamera = function(distance)
    -- Checks to see if the Gameplay Cam is Rendering or another is rendering (no clip functionality)
    local currentRenderingCam = false
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end

    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
	local direction = RotationToDirection(cameraRotation)
	local destination =	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local _, b, _, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, e
end

function DropBag(item) 

	-- TO DO
	-- CHECK IF IN CAR
	-- 

	-- Drop bag on ground
	local dropAnimDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
	local dropAnim = "machinic_loop_mechandplayer"
	local ped = PlayerPedId()
	x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 0.8, 0.0))
	local heading = GetEntityHeading(GetPlayerPed(-1))

	RequestModel(bag_model)
	while not HasModelLoaded(bag_model) do
	   Wait(1)
	end

	exports['progressbar']:ProgressWithStartEvent({
		name = "drop_police_bag",
		duration = 5000,
		label = "Dropping Bag...",
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = dropAnimDict,
			anim = dropAnim,
			flags = 1,
		},
		prop = {},
		propTwo = {}
	 }, function()

			--TaskPlayAnim(ped, dropAnimDict, dropAnim, 8.0, 8.0, -1, 1, 0, false, false, false)
			bag_obj = CreateObject(bag_model, x, y, z, true, true, true)
			SetEntityHeading(bag_obj, heading)
			PlaceObjectOnGroundProperly(bag_obj)
			FreezeEntityPosition(bag_obj, true)

			exports['qb-target']:AddTargetModel(bag_model, {
				options = {
					{
						type = "client",
						event = "pb:client:OpenBag",
						icon = "fas fa-toolbox",
						label = "Open Bag",
						job = "police",
					},
					{
						type = "client",
						event = "pb:client:PickupBag",
						icon = "fas fa-hand-peace",
						label = "Take Bag",
						job = "police",
					},
				},
				distance = 2.0
			})

			-- Remove bag
			QBCore.Functions.TriggerCallback("pb:server:RemoveBag", function(removed)
				if not removed then
					DeleteObject(bag_obj)
				end
			end, item)

		end,
		function(cancelled)
			ClearPedTasks(ped)
        	StopAnimTask(ped, dropAnimDict, dropAnim, 1.0)
			if cancelled then
				print("Canceled")
				if bag_obj ~= nil then
					DeleteObject(bag_obj)
					TriggerServerEvent('pb:server:AddBag')
				end
			else
				print("Finished..")
			end
		end)

end

-- ################################ NET EVENTS ################################

RegisterNetEvent('pb:client:UseBag', function(item)
	local PlayerData = QBCore.Functions.GetPlayerData()

	if PlayerData.job.name == "police" then
		print("Bag Used")
		DropBag(item)
	else
		QBCore.Functions.Notify("You cannot use this!", "error")
	end
end)

RegisterNetEvent('pb:client:OpenBag', function()

	TriggerServerEvent("inventory:server:OpenInventory", "stash", "policebag_"..QBCore.Functions.GetPlayerData().citizenid, {
        maxweight = 100000,
        slots = 5,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "policebag_"..QBCore.Functions.GetPlayerData().citizenid)

end)

RegisterNetEvent('pb:client:PickupBag', function()

	-- Check if space to add item

	print("Trying to pickup bag ... ")

	local hit, entity = RayCastGamePlayCamera(10.0)

	if hit and IsEntityAnObject(entity) and GetHashKey(bag_model) == GetEntityModel(entity) then

		QBCore.Functions.TriggerCallback("pb:server:AddBag", function(added)

			if added then
				
				local NetID = NetworkGetNetworkIdFromEntity(entity)

				SetEntityAsMissionEntity(entity, true, true)
				DeleteEntity(entity)

				QBCore.Functions.Notify("Bag picked Up!", "success")

			else
				QBCore.Functions.Notify("Could not pick up bag!", "error")
			end

		end)

	end

end)

