--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

--- Flora is a simple system for placing plants and decorations.
Flora = {}


--- Gets the template/empty plant.
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

--- Tests if the given plant does accept the given biome.
--
-- @param plant The plant to test.
-- @param biome The biome to test against.
-- @return true if the plant fits in the given biome.
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

--- Tests if the given plant can appear here.
--
-- @param plant The plant to test.
-- @param random The PseudoRandom object that is used for the probability.
-- @return true if the plant can be placed here.
function Flora.test_probability(plant, random)
	if plant.probability ~= nil and plant.probability < 1 then
		local probability = transform.linear(random:next(0, 32767), 0, 32767, 0, 1)
				
		return plant.probability >= probability
	end
	
	return true
end

--- Tests if the plant does fit into the given environment, checking
-- the elevation, humidity, temperature and vegetation value.
--
-- @param plant The plant to test.
-- @param elevation The elevation value.
-- @param humidity The humidity value.
-- @param temperature The temperature value.
-- @param vegetation The vegetation value.
-- @return true if the plant fits here.
function Flora.test_fits(plant, elevation, humidity, temperature, vegetation)
	return elevation >= plant.min_elevation and elevation < plant.max_elevation
		and humidity >= plant.min_humidity and humidity < plant.max_humidity
		and temperature >= plant.min_temperature and temperature < plant.max_temperature
		and vegetation >= plant.min_vegetation and vegetation < plant.max_vegetation
end

--- Tests if there are any other plants of the same type in the surroundings.
--
-- @param plant The plant to test.
-- @param map The current map which holds all plants.
-- @param x The current x coordinate.
-- @param z The current y coordinate.
-- @param random The PseudoRandom object that is used for determining
--               the distance to check,
-- @return true if there are no other plants in the surroundings.
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


--- Creates a new instance of Flora.
--
-- @return A new instance of Flora.
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


--- Gets the plant map for the given x and z coordinate.
-- The map is a 2D array/table, with the first dimension being x, the second
-- being z starting at the given values.
--
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @param seed The seed of the current block.
-- @param biome_map The biome map.
-- @param elevation_map The elevation map.
-- @param humidity_map The humidity map.
-- @param temperature_map The temperature map.
-- @return The 2D array/map with the plants in it.
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

--- Inits this instance and all modules.
--
-- Does nothing if this instance is already intialized.
--
-- @param noise_manager Optional. The NoiseManager to use for the init. Defaults
--                      to a new instance if not provided.
function Flora:init(noise_manager)
	self.vegetation:init(noise_manager)
end

--- Gets if this instance has been initialized.
--
-- @return true if this instance has been initialized.
function Flora:is_initialized()
	return self.vegetation.initialized
end

--- Registers the gviven plant.
--
-- @param plant The plant to register.
function Flora:register_plant(plant)
	self.plants:add(plant)
end

--- Registers the given vegetation module.
--
-- @param module The module to register for the vegetation value.
function Flora:register_vegetation(module)
	self.vegetation:register(module)
end

--- Sets the default plant.
--
-- @param plant The plant to use as default plant.
function Flora:set_default_plant(plant)
	self.default_plant = plant
end

