function getVehicleFuelAmount(vehicle_id)
	-- Gets the vehicle current fuel amount
	-- retuns the fuel amount if vehicle is found
	--
	local select = exports['aprp-database']:quickSelect({'fuel'}, 'vehicles', 'id', tonumber(vehicle_id), true)

	if select.e_size > 0 then
		return select.fuel
	else
		return false
	end
end

function getVehicleFuelAmountClient()
	-- Returns the fuel amount of the player current vehicle
end


