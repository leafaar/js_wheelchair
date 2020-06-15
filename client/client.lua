local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

RegisterNetEvent('js_wheelchair:Spawn')
AddEventHandler('js_wheelchair:Spawn', function()
    spawnProp()
end)

RegisterNetEvent('js_wheelchair:Remove')
AddEventHandler('js_wheelchair:Remove', function()
    removeProp()
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 500

        local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("prop_wheelchair_01"), false)

        if DoesEntityExist(closestObject) then
            sleep = 5

            local wheelChairCoords = GetEntityCoords(closestObject)
			local wheelChairForward = GetEntityForwardVector(closestObject)
			
			local sitCoords = (wheelChairCoords + wheelChairForward * - 0.5)
			local pickupCoords = (wheelChairCoords + wheelChairForward * 0.3)
            
            if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 1.0 then
                DrawText3Ds(sitCoords, "[~r~E~w~] Sentar", 0.4)

                if IsControlJustPressed(0, 38) then
                    Sit(closestObject)
                end
            end

            if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 1.0 then
                DrawText3Ds(pickupCoords, "[~r~E~w~] Pegar", 0.4)

                if IsControlJustPressed(0, 38) then
                    PickUp(closestObject)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

function spawnProp()
    LoadModel('prop_wheelchair_01')
    local modelHash = GetHashKey('prop_wheelchair_01')
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))

    local wheelchair = CreateObject(modelHash, x + 1, y , z - 1, true)
end

function removeProp()
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local modelHash = GetHashKey('prop_wheelchair_01')
    local wheelchair = GetClosestObjectOfType(x, y, z, 10.0, modelHash, true, true, true)

    if DoesEntityExist(wheelchair) then 
        DeleteEntity(wheelchair)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
end

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function DrawText3Ds(coords, text, scale)
	local x,y,z = coords.x, coords.y, coords.z
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 215)

	AddTextComponentString(text)
	DrawText(_x, _y)

	local factor = (string.len(text)) / 370

	DrawRect(_x, _y + 0.0150, 0.030 + factor, 0.025, 41, 11, 41, 100)
end

function Sit(wheelchairObject)
    local closestPlayer, closestPlayerDist = GetClosestPlayer()

    if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
            TriggerEvent('Notify', 'aviso', 'Alguém já está sentado nesta cadeira.')
            return
        end
    end
    LoadAnim("missfinale_c2leadinoutfin_c_int")

    AttachEntityToEntity(PlayerPedId(), wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)

    local heading = GetEntityHeading(wheelchairObject)
    
    while IsEntityAttachedToEntity(PlayerPedId(), wheelchairObject) do
        Citizen.Wait(5)

		if IsPedDeadOrDying(PlayerPedId()) then
			DetachEntity(PlayerPedId(), true, true)
		end

		if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			TaskPlayAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 69, 1, false, false, false)
        end
        
        if IsControlJustPressed(0, 167) then
			DetachEntity(PlayerPedId(), true, true)
			local x, y, z = table.unpack(GetEntityCoords(wheelchairObject) + GetEntityForwardVector(wheelchairObject) * - 0.7)
			SetEntityCoords(PlayerPedId(), x + 1,y,z)
		end
    end
end

function PickUp(wheelchairObject)
	local closestPlayer, closestPlayerDist = GetClosestPlayer()

	if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'anim@heists@box_carry@', 'idle', 3) then
			TriggerEvent('Notify', 'aviso', 'Alguém já está usando esta cadeira.')
			return
		end
	end

	NetworkRequestControlOfEntity(wheelchairObject)

	LoadAnim("anim@heists@box_carry@")

	AttachEntityToEntity(wheelchairObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

	while IsEntityAttachedToEntity(wheelchairObject, PlayerPedId()) do
		Citizen.Wait(5)

		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
		end

		if IsPedDeadOrDying(PlayerPedId()) then
			DetachEntity(wheelchairObject, true, true)
		end

		if IsControlJustPressed(0, 167) then
            DetachEntity(wheelchairObject, true, true)
            vRP._stopAnim(true)
		end
	end
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = GetPlayerPed(-1)
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end