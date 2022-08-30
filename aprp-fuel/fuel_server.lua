-- Fuel system
local stations = {}
local vehicles_fuel = {}
local timers = {}
local colisions = {}

addEvent('_ServerPlayerEngineStart', true)
addEvent('_ServerPlayerEngineStop_', true)

addEvent('_ServerStopFuel_', true)

-- Fuel rate {moving_rate, idle_rate}
-- 
-- Big Bikes		0.004,	0.001
-- Strong Bikes 	0.003, 0.0007
-- Medium Bikes 	0.0025, 0.0005
-- Economic Bikes	0.0010, 0.00020
vehicles_fuel['NRG-500'] 		= {0.003, 	0.0007} 
vehicles_fuel['FCR-900'] 		= {0.003, 	0.0007}
vehicles_fuel['HPV1000'] 		= {0.003, 	0.0007}
vehicles_fuel['BF-400'] 			= {0.0025, 	0.0005}
vehicles_fuel['Wayfarer'] 		= {0.004,	0.0010}
vehicles_fuel['Freeway'] 		= {0.004,	0.0010}
vehicles_fuel['Sanchez'] 		= {0.0025, 	0.0005}
vehicles_fuel['PCJ-600'] 		= {0.0025, 	0.0005}
vehicles_fuel['Faggio'] 			= {0.0010, 	0.00020}
-- 2-Door Compact Cars
-- Heavy Vehicles_fuel 	0.005,	0.001
-- Strong Vehicles_fuel  0.004,	0.0009
-- Medium Vehicles_fuel  0.0035, 0.0005
-- Economic Vehicle 0.0020,	0.0003
-- Super Economic	0.0010, 0.00008
vehicles_fuel['Alpha'] 			= {0.0035, 	0.0005}
vehicles_fuel['Blista Compact'] 	= {0.0020,	0.0003}
vehicles_fuel['Bravura'] 		= {0.0035, 	0.0005}
vehicles_fuel['Buccaneer'] 		= {0.004,	0.0009}
vehicles_fuel['Cadrona'] 		= {0.0035, 	0.0005}
vehicles_fuel['Club'] 			= {0.0035, 	0.0005}
vehicles_fuel['Esperanto'] 		= {0.004,	0.0009}
vehicles_fuel['Euros'] 			= {0.004,	0.0009}
vehicles_fuel['Feltzer'] 		= {0.0035, 	0.0005}
vehicles_fuel['Fortune'] 		= {0.0035, 	0.0005}
vehicles_fuel['Hermes'] 			= {0.005,	0.0010}
vehicles_fuel['Hustler'] 		= {0.005,	0.0010}
vehicles_fuel['Majestic'] 		= {0.0035, 	0.00050}
vehicles_fuel['Manana'] 			= {0.0010, 	0.00008}
vehicles_fuel['Picador'] 		= {0.0035, 	0.0005}
vehicles_fuel['Previon'] 		= {0.0020,	0.0003}
vehicles_fuel['Stallion'] 		= {0.0020,	0.0003}
vehicles_fuel['Tampa'] 			= {0.0035, 	0.0005}
vehicles_fuel['Virgo'] 			= {0.0035, 	0.0005}
-- 4-Door & Luxury
-- Super Heavy		0.006,	0.0020
-- Heavy Vehicles_fuel 	0.005,	0.001
-- Strong Vehicles_fuel  0.004,	0.0009
-- Medium Vehicles_fuel  0.0035, 0.0005
-- Economic Vehicle 0.0020,	0.0003
-- Super Economic	0.0010, 0.00008
vehicles_fuel['Admiral'] 		= {0.0035, 	0.0005}
vehicles_fuel['Damaged Glendale']= {0.005,	0.0010}
vehicles_fuel['Elegant'] 		= {0.004,	0.0009}
vehicles_fuel['Emperor'] 		= {0.0035, 	0.0005}
vehicles_fuel['Glendale'] 		= {0.0035, 	0.0005}
vehicles_fuel['Greenwood'] 		= {0.0035, 	0.0005}
vehicles_fuel['Intruder'] 		= {0.0035, 	0.0005}
vehicles_fuel['Merit'] 			= {0.0035, 	0.0005}
vehicles_fuel['Nebula'] 			= {0.0035, 	0.0005}
vehicles_fuel['Oceanic'] 		= {0.004,	0.0009}
vehicles_fuel['Premier'] 		= {0.0035, 	0.0005}
vehicles_fuel['Primo'] 			= {0.0035, 	0.0005}
vehicles_fuel['Stafford'] 		= {0.005,	0.0010}
vehicles_fuel['Stretch'] 		= {0.006,	0.0020}
vehicles_fuel['Sunrise'] 		= {0.0035, 	0.0005}
vehicles_fuel['Tahoma'] 			= {0.0035, 	0.0005}
vehicles_fuel['Vincent'] 		= {0.0020,	0.0003}
vehicles_fuel['Washington'] 		= {0.004,	0.0009}
vehicles_fuel['Willard'] 		= {0.0020,	0.0003}
-- Utilitaries
-- Heavy Duty		0.0080,	0.00400
-- Super Heavy		0.0060,	0.00200
-- Heavy			0.0050,	0.00100
-- Medium 			0.0035, 0.00030
-- Super Economic	0.0010, 0.00008
vehicles_fuel['Baggage'] 		= {0.0010, 	0.00008}
vehicles_fuel['Bus'] 			= {0.0080,	0.00400}
vehicles_fuel['Cabbie'] 			= {0.0035, 	0.00030}
vehicles_fuel['Coach'] 			= {0.0080,	0.00400}
vehicles_fuel['Sweeper'] 		= {0.0010, 	0.00008}
vehicles_fuel['Taxi'] 			= {0.0035, 	0.00030}
vehicles_fuel['Towtruck'] 		= {0.0050,	0.00100}
vehicles_fuel['Trashmaster'] 	= {0.0050,	0.00100}
vehicles_fuel['Utility Van'] 	= {0.0050,	0.00100}
-- Government Vehicles_fuel
-- Heavy Duty		0.0080,	0.00400
-- Super Heavy		0.0060,	0.00200
-- Heavy			0.0050,	0.00100
-- Medium 			0.0035, 0.00030
-- Super Economic	0.0010, 0.00008
vehicles_fuel['Ambulance'] 		= {0.0035, 	0.00030}
vehicles_fuel['Barracks'] 		= {0.0060,	0.00200}
vehicles_fuel['Enforcer'] 		= {0.0060,	0.00200}
vehicles_fuel['FBI Rancher'] 	= {0.0035, 	0.00030}
vehicles_fuel['FBI Truck'] 		= {0.0035, 	0.00030}
vehicles_fuel['Fire Truck'] 		= {0.0050,	0.00100}
vehicles_fuel['Police LS'] 		= {0.0035, 	0.00030}
vehicles_fuel['Police LV'] 		= {0.0035, 	0.00030}
vehicles_fuel['Police Ranger'] 	= {0.0035, 	0.00030}
vehicles_fuel['Police SF'] 		= {0.0035, 	0.00030}
vehicles_fuel['S.W.A.T.'] 		= {0.0060,	0.00200}
vehicles_fuel['Securicar'] 		= {0.0035, 	0.00030}
-- Heavy & Utility
-- Construction		0.0090,	0.00500
-- Heavy Duty		0.0080,	0.00400
-- Super Heavy		0.0060,	0.00200
-- Heavy			0.0050,	0.00100
-- Medium 			0.0035, 0.00030
-- Super Economic	0.0010, 0.00008
vehicles_fuel['Benson'] 				= {0.0035, 	0.00030}
vehicles_fuel['Boxville Mission'] 	= {0.0050,	0.00100}
vehicles_fuel['Boxville'] 			= {0.0050,	0.00100}
vehicles_fuel['Cement Truck'] 		= {0.0060,	0.00200}
vehicles_fuel['Combine Harvester'] 	= {0.0050,	0.00100}
vehicles_fuel['DFT-30'] 				= {0.0050,	0.00100}
vehicles_fuel['Dozer'] 				= {0.0050,	0.00100}
vehicles_fuel['Dumper'] 				= {0.0090,	0.00500}
vehicles_fuel['Dune'] 				= {0.0035, 	0.00030}
vehicles_fuel['Flatbed'] 			= {0.0080,	0.00400}
vehicles_fuel['Hotdog'] 				= {0.0035, 	0.00030}
vehicles_fuel['Linerunner'] 			= {0.0080,	0.00400}
vehicles_fuel['Mr. Whoopee'] 		= {0.0035, 	0.00030}
vehicles_fuel['Mule'] 				= {0.0035, 	0.00030}
vehicles_fuel['Packer'] 				= {0.0080,	0.00400}
vehicles_fuel['Roadtrain'] 			= {0.0080,	0.00400}
vehicles_fuel['Tanker'] 				= {0.0080,	0.00400}
vehicles_fuel['Tractor'] 			= {0.0050,	0.00100}
vehicles_fuel['Yankee'] 				= {0.0035, 	0.00030}
-- Light Trucks & Vans
-- Strong Vehicles_fuel  0.0040,	0.00090
-- Medium Vehicles_fuel  0.0035, 0.00050
-- Economic Vehicle 0.0020,	0.00030
vehicles_fuel["Berkley's RC Van"] 	= {0.0035, 	0.00030}
vehicles_fuel['Bobcat'] 				= {0.0035, 	0.00030}
vehicles_fuel['Burrito'] 			= {0.0035, 	0.00030}
vehicles_fuel['Damaged Sadler'] 		= {0.0040,	0.00090}
vehicles_fuel['Forklift'] 			= {0.0010, 	0.00008}
vehicles_fuel['Moonbeam'] 			= {0.0035, 	0.00030}
vehicles_fuel['Mower'] 				= {0.0020,	0.00030}
vehicles_fuel['News Van'] 			= {0.0035, 	0.00030}
vehicles_fuel['Pony'] 				= {0.0035, 	0.00030}
vehicles_fuel['Rumpo'] 				= {0.0035, 	0.00030}
vehicles_fuel['Sadler'] 				= {0.0035, 	0.00030}
vehicles_fuel['Tug'] 				= {0.0010, 	0.00008}
vehicles_fuel['Walton'] 				= {0.0035, 	0.00030}
vehicles_fuel['Yosemite'] 			= {0.0035, 	0.00030}
-- Lowriders
-- Medium Vehicles_fuel  0.0035, 0.00050
-- Economic Vehicle 0.0020,	0.00030
vehicles_fuel['Blade'] 				= {0.0035, 	0.00030}
vehicles_fuel['Broadway'] 			= {0.0040,	0.00090}
vehicles_fuel['Remington'] 			= {0.0040,	0.00090}
vehicles_fuel['Savanna'] 			= {0.0035, 	0.00030}
vehicles_fuel['Slamvan'] 			= {0.0040,	0.00090}
vehicles_fuel['Tornado'] 			= {0.0040,	0.00090}
vehicles_fuel['Voodoo'] 				= {0.0035, 	0.00030}
-- Muscle Cars
vehicles_fuel['Buffalo'] 			= {0.0040,	0.00090}
vehicles_fuel['Clover'] 				= {0.0035, 	0.00030}
vehicles_fuel['Phoenix'] 			= {0.0040,	0.00090}
vehicles_fuel['Sabre'] 				= {0.0040,	0.00090}
-- Street Racer
-- Muscle	    0.0050,	0.00100
-- SuperSport	0.0040,	0.00090
-- Sport   		0.0035,	0.00080
-- Economic Sport 0.0030, 0.00050
vehicles_fuel['Banshee'] 			= {0.0035,	0.00080}
vehicles_fuel['Bullet'] 				= {0.0050,	0.00100}
vehicles_fuel['Cheetah'] 			= {0.0035,	0.00080}
vehicles_fuel['Comet'] 				= {0.0035,	0.00080}
vehicles_fuel['Elegy'] 				= {0.0040,	0.00090}
vehicles_fuel['Flash'] 				= {0.0030, 	0.00050}
vehicles_fuel['Hotknife'] 			= {0.0050,	0.00100}
vehicles_fuel['Hotring Racer'] 		= {0.0050,	0.00100}
vehicles_fuel['Hotring Racer 2'] 	= {0.0050,	0.00100}
vehicles_fuel['Hotring Racer 3'] 	= {0.0050,	0.00100}
vehicles_fuel['Infernus'] 			= {0.0040,	0.00090}
vehicles_fuel['Jester'] 				= {0.0035,	0.00080}
vehicles_fuel['Stratum'] 			= {0.0035,	0.00080}
vehicles_fuel['Sultan'] 				= {0.0035,	0.00080}
vehicles_fuel['Super GT'] 			= {0.0035,	0.00080}
vehicles_fuel['Turismo'] 			= {0.0040,	0.00090}
vehicles_fuel['Uranus'] 				= {0.0030, 	0.00050}
vehicles_fuel['Windsor'] 			= {0.0030, 0.00050}
vehicles_fuel['ZR-350'] 				= {0.0040,	0.00090}

stations[1] = {1941.99609375, -1773.13671875, 12.56141719818, 8, 100}
stations[2] = {-2244.37109375, -2560.84375, 31.121875, 8, 75}
stations[3] = {-1605.34375, -2714.3818359375, 48.033473968506, 13, 120}
stations[4] = {-734.6171875, 2746.017578125, 46.3265625, 8, 50}
stations[5] = {660.138671875, -565.5283203125, 15.8359375, 13, 90}
stations[6] = {655.0078125,-471.802734375,15.5359375, 3, 80}

function loadGasStations()
	-- Loads the colision sphere of the gas station
	--
	if #stations == 0 then
		return
	end

	for i, k in pairs(stations) do
		local colision = createColTube(k[1], k[2], k[3], k[4], 5)
		colision:setData('gasstation:price', k[5])
		-- adding the colision to the colisions table
		table.insert(colisions, colision)
		addEventHandler('onColShapeHit', colision, enteredGasStation)
		addEventHandler('onColShapeLeave', colision, leftGasStation)
	end
end
addEventHandler('onResourceStart', root, loadGasStations)

function enteredGasStation(element)
	-- handles when a player enters the gas station colision shpere
	--
	local element_type = getElementType(element)
	if element_type ~= 'vehicle' then
		return
	end
	
	if exports['aprp-helpers']:isMessageSent('fuel_entered_message', element) then
		return
	end

	exports['aprp-helpers']:addSentMessage('fuel_entered_message', element, 10000)

	local driver 		= getVehicleController(element)
	if not driver then 
		return
	end

	local price	 		= tonumber(source:getData('gasstation:price'))
	local vehicle_fuel 	= math.floor(tonumber(element:getData('vehicle:fuel') + 0.5))
	local fuel_amount	= 100 - vehicle_fuel
	local math			= fuel_amount * price
	local zoneName		= getZoneName(getElementPosition(element))

	element:setData('vehicle:gasstationprice', price)

	outputChatBox(zoneName .. ' Gas Station! Type /refuel to fill the tank', driver, 50, 168, 68)
	outputChatBox('Price per liter: $' .. tostring(price), driver, 50, 168, 68)
	outputChatBox('Refuel price: $' .. math .. ' (' .. fuel_amount .. 'L)', driver, 50, 168, 68)
end

function leftGasStation(element)
	local element_type = getElementType(element)
	if element_type ~= 'vehicle' then
		return
	end

	element:removeData('vehicle:gasstationprice')
end

function refuel(player, command)
	if not isPedInVehicle(player) then
		outputChatBox('You must be inside a vehicle and at a gas station to refuel', player, 255, 0, 0)
		return
	end

	local vehicle 			= getPedOccupiedVehicle(player)
	local vehicle_seat		= getPedOccupiedVehicleSeat(player)
	local price				= vehicle:getData('vehicle:gasstationprice')
	local vehicle_fuel		= math.floor(tonumber(vehicle:getData('vehicle:fuel') + 0.5))
	local vehicle_engine	= vehicle:getData('vehicle:engine')

	if vehicle_engine then
		outputChatBox('You must turn your engine off first!', player, 255, 0, 0)
		return
	end

	local math = (100 - vehicle_fuel) * price

	local transaction = exports['aprp-accounts']:moneyTransaction(tonumber(player:getData('charid')), math, player)
	
	if not transaction[1] then
		outputChatBox('Not enough money to buy this!', player, 255, 0, 0)
		return
	end

	vehicle:setData('vehicle:fuel', 100)

	outputChatBox('Vehicle tank is now full!', player, 0, 255, 0)
end
addCommandHandler('refuel', refuel)


-- Fuel Depletion

function engineStart(vehicle, player)
	-- Check if the vehicle has any fuel in it
	local vehicle_fuel = math.floor(tonumber(vehicle:getData('vehicle:fuel')) + 0.5)

	if vehicle_fuel <= 0 then
		outputChatBox('This vehicle has no fuel in it', player, 255, 0, 0)
		-- Turning the engine off
		vehicle:setData('vehicle:engine', false)
		setVehicleEngineState(vehicle, false)
		return
	end

	-- Getting the vehicle model name
	local vehicle_name = getVehicleNameFromModel(tonumber(vehicle:getData('vehicle:model')))

	-- Check if the vehicle has any fuel parameter
	if not vehicles_fuel[vehicle_name] then
		return
	end

	local timer = setTimer(depleteFuel, 5000, 0, vehicle, player, vehicles_fuel[vehicle_name], vehicle_name) -- Starting the engine depletion
	timers[vehicle] = timer -- Adding the timer to the table
	-- Trigger the client event to display the fuel
	triggerClientEvent('_ServerFuelStart_', root)
end
addEventHandler('_ServerPlayerEngineStart', root, engineStart)

function depleteFuel(vehicle, player, fuel_rate, vehicle_name)
	local vehicle_fuel = tonumber(vehicle:getData('vehicle:fuel'))

	-- Check if the tank is empty
	if vehicle_fuel <= 0 then
		outputChatBox('The vehicle ran out of fuel!', player, 255, 0, 0)
		-- Turning the engine off
		vehicle:setData('vehicle:engine', false)
		setVehicleEngineState(vehicle, false)
		-- Killing the timer
		killTimer(timers[vehicle])
		timers[vehicle] = nil
		return
	end

	local real_rate	   = fuel_rate[2]

	if exports['aprp-helpers']:isElementMoving(vehicle) then
		real_rate = fuel_rate[1]
	end

	local fuel_deplete = 100 * real_rate
	local fuel		   = vehicle_fuel - fuel_deplete

	vehicle:setData('vehicle:fuel', fuel)
end

function stopFuelDepletion(vehicle)
	if not timers[vehicle] then
		return
	end

	if vehicle:getData('vehicle:engine') then
		vehicle:setData('vehicle:engine', false)
		setVehicleEngineState(vehicle, false)
	end

	local data = {}
	data['fuel'] = tonumber(vehicle:getData('vehicle:fuel'))
	exports['aprp-database']:quickUpdate('vehicles', data, 'id', tonumber(vehicle:getData('vehicle:id')))

	killTimer(timers[vehicle])
	timers[vehicle] = nil
end

addEventHandler('_ServerPlayerEngineStop_', root, stopFuelDepletion)