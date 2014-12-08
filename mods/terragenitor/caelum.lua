--[[
Copyright (c) 2014, Robert 'Bobby' Zenz
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


--- Caelum is a module based system for managing humidity, temperature and
-- biomes.
--
-- It is very similar to TerraGenitor.
Caelum = {}


--- Creates a new instance of Caelum.
--
-- @param humidity_base_value Optional. The abse value for humidity, defaults
--                            to zero.
-- @param temperature_base_value Optional. The abse value for temperature,
--                               defaults to zero.
function Caelum:new(humidity_base_value, temperature_base_value)
	local instance = {
		biomes = {},
		biomes_cache = {},
		biomes_counter = 0,
		default_biome = nil,
		humidity = TerraGenitor:new(humidity_base_value),
		temperature = TerraGenitor:new(temperature_base_value)
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Clears the complete map cache.
function Caelum:clear_cache()
	self.biomes_cache = {}
	self.humidity:clear_cache()
	self.temperature:clear_cache()
end
                                                                                                      
function Caelum:get_biome(x, z, elevation, humidity, temperature)
	local biome = self.default_biome
	
	for idx = 0, self.biomes_counter - 1, 1 do
		if self.biomes[idx]:fits(x, z, elevation, humidity, temperature) then
			biome = self.biomes[idx]
		end
	end
	
	return biome
end

function Caelum:get_biome_map(x, z, elevation_map)
	if self:is_cached(x, z) then
		return self.biomes_cache[x][z]
	end
	
	local humidity_map = self.humidity:get_map(x, z, elevation_map)
	local temperature_map = self.temperature:get_map(x, z, elevation_map)
	
	local map = {}
	
	for idxx = x, x + constants.block_size - 1, 1 do
		map[idxx] = {}
		
		for idxz = z, z + constants.block_size - 1, 1 do
			local elevation = elevation_map[idxx][idxz]
			local humidity = humidity_map[idxx][idxz]
			local temperature = temperature_map[idxx][idxz]
			
			map[idxx][idxz] = self:get_biome(idxx, idxz, elevation, humidity, temperature)
		end
	end
	
	return map
end

function Caelum:get_humidity_map(x, z, elevation_map)
	return self.humidity:get_map(x, z)
end

function Caelum:get_temperature_map(x, z, elevation_map)
	return self.temperature:get_map(x, z, elevation_map)
end

function Caelum:init(noise_manager)
	self.humidity:init(noise_manager)
	self.temperature:init(noise_manager)
end

function Caelum:is_cached(x, z)
	return self.biomes_cache[x] ~= nil and self.biomes_cache[x][z] ~= nil
end

function Caelum:register_biome(biome)
	self.biomes[self.biomes_counter] = biome
	self.biomes_counter = self.biomes_counter + 1
end

function Caelum:register_humidity_module(module)
	self.humidity:register(module)
end

function Caelum:register_temperature_module(module)
	self.temperature:register(module)
end

function Caelum:set_default_biome(biome)
	self.default_biome = biome
end

