-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLEGLOBAL
-----------------------------------------------------------------------------------------------------------------------------------------
local vehglobal = {}

RegisterNetEvent("Reborn_Base:setVehicleGlobal")
AddEventHandler("Reborn_Base:setVehicleGlobal", function(data)
    vehglobal = data
end)

function getVehicleInfo(vehicle)
	for i in ipairs(vehglobal) do
		if vehicle == vehglobal[i].hash or vehicle == vehglobal[i].name then
            return vehglobal[i]
        end
    end
    return false
end

function vehicleGlobal()
	return vehglobal
end

function vehicleExist(vname)
	local veh = getVehicleInfo(vname)
	if veh then
		return true
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLENAME
-----------------------------------------------------------------------------------------------------------------------------------------
function vehicleName(vname)
	local veh = getVehicleInfo(vname)
	if veh then
		return veh.name
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLECHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vehicleChest(vname)
	local veh = getVehicleInfo(vname)
	if veh then
		return veh.capacidade or 40
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLEPRICE
-----------------------------------------------------------------------------------------------------------------------------------------
function vehiclePrice(vname)
	local veh = getVehicleInfo(vname)
	if veh then
		return veh.price
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLETYPE
-----------------------------------------------------------------------------------------------------------------------------------------
function vehicleType(vname)
	local veh = getVehicleInfo(vname)
	if veh then
		return veh.tipo
	end
end
