Flora = {}


function Flora.get_template_plant()
	return {
		biome_name = nil,
		distance = 0,
		distance_max = nil,
		distance_min = nil,
		max_elevation = 31000,
		max_humidity = 31000,
		max_temperature = 31000,
		max_vegetation = 31000,
		min_elevation = -31000,
		min_humidity = -31000,
		min_temperature = -31000,
		min_vegetation = -31000,
		name = "Template Plant",
		probability = 1
	}
end

function Flora.test_biome(plant, biome)
	if plant.biome_name ~= nil then
		if type(plant.biome_name) == "table" then
			for idx, name in pairs(plant.biome_name) do
				if biome.name == name then
					return true
				end
			end
			
			return false
		else
			return biome.name == plant.biome_name
		end
	end
	
	return true
end

function Flora.test_probability(plant, random)
	if plant.probability < 1 then
		local probability = transform.linear(random:next(0, 32767), 0, 32767, 0, 1)
				
		return plant.probability >= probability
	end
	
	return true
end

function Flora.test_fits(plant, elevation, humidity, temperature, vegetation)
	return elevation >= plant.min_elevation and elevation < plant.max_elevation
		and humidity >= plant.min_humidity and humidity < plant.max_humidity
		and temperature >= plant.min_temperature and temperature < plant.max_temperature
		and vegetation >= plant.min_vegetation and vegetation < plant.max_vegetation
end

function Flora.test_surroundings(plant, map, x, z, random)
	local distance = plant.distance
	
	if plant.distance_min ~= nil and plant.distance_max ~= nil then
		distance = transform.linear(random:next(0, 32767), 0, 32767, plant.distance_min, plant.distance_max)
		distance = mathutil.round(distance)
	end
	
	if distance > 0 then
		for idxx = x - distance, x + distance, 1 do
			for idxz = z - distance, z + distance, 1 do
				if map[idxx] ~= nil and map[idxx][idxz] == plant then
					return false
				end
			end
		end
	end
	
	return true
end


function Flora:new()
	local instance = {
		default_plant = nil,
		plants = List:new(),
		vegetation = TerraGenitor:new(),
		vegetation_cache = BlockedCache:new()
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function Flora:get_plant_map(x, z, seed, biome_map, elevation_map, humidity_map, temperature_map)
	if self.vegetation_cache:is_cached(x, z) then
		return self.vegetation_cache:get(x, z)
	end
	
	local vegetation_map = self.vegetation:get_map(x, z, { 
		biome_map = biome_map,
		elevation_map = elevation_map,
		humidity_map = humidity_map,
		temperature_map = temperature_map
	})
	
	local random_distance = PseudoRandom(seed)
	local random_probability = PseudoRandom(seed)
	local random_fisher_yates = PseudoRandom(seed)
	local map = {}
	
	local index_map = {}
	local index = 0
	for idxx = x, x + constants.block_size - 1, 1 do
		for idxz = z, z + constants.block_size - 1, 1 do
			index_map[index] = { x = idxx, z = idxz }
			index = index + 1
		end
	end
	
	fisheryates.run(index_map, 0, index - 1, random_fisher_yates, function(item)
		local biome = biome_map[item.x][item.z]
		local elevation = elevation_map[item.x][item.z].value
		local humidity = humidity_map[item.x][item.z].value
		local temperature = temperature_map[item.x][item.z].value
		local vegetation = vegetation_map[item.x][item.z].value
		
		local current_plant = self.default_plant
		
		self.plants:foreach(function(plant)
			if Flora.test_fits(plant, elevation, humidity, temperature, vegetation)
				and Flora.test_biome(plant, biome)
				and Flora.test_probability(plant, random_probability)
				and Flora.test_surroundings(plant, map, item.x, item.z, random_distance) then
				
				current_plant = plant
			end
		end)
		
		if map[item.x] == nil then
			map[item.x] = {}
		end
		
		map[item.x][item.z] = current_plant
	end)
	
	return map
end

function Flora:init(noise_manager)
	self.vegetation:init(noise_manager)
end

function Flora:register_plant(plant)
	self.plants:add(plant)
end

function Flora:register_vegetation_module(module)
	self.vegetation:register(module)
end

function Flora:set_default_plant(plant)
	self.default_plant = plant
end

