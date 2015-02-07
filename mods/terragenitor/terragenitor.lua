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


--- TerraGenitor is a module based system to create value maps.
--
-- A value map in this case is a simple 2D array/table of values,
-- for example a heightmap for the terrain.
--
-- The value for every x/z coordinate pair is passed through all modules which
-- can change and manipulate the value. An additional info object is passed
-- with it, which allows each module to save further information.
TerraGenitor = {}


--- Creates a new instance of TerraGenitor.
--
-- @param base_value The base/start value.
-- @return A new instance of TerraGenitor.
function TerraGenitor:new(base_value)
	local instance = {
		base_value = base_value or 0,
		cache = BlockedCache:new(),
		initialized = false,
		modules = List:new()
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Gets the map for the given x and z coordinate.
-- The map is a 2D array/table, with the first dimension being x, the second
-- being z starting at the given values. The values contained within is a table
-- with two values, value and info. Both are not defined. The size of the map
-- defaults to constants.block_size, which should be 80.
--
-- Example: value = map[x][z]
--
-- The result of this function is cached, and if invoked multiple times the map
-- from the cache is returned.
--
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @param support Optional. The support object that provides additional
--                additional information for the module. The format of this
--                is not defined.
-- @return A map with all values starting at the given coordinates.
function TerraGenitor:get_map(x, z, support)
	if self.cache:is_cached(x, z) then
		return self.cache:get(x, z)
	end
	
	self.modules:foreach(function(module)
		module:init_map(x, z, support)
	end)
	
	local map = {}
		
	for idxx = x, x + constants.block_size - 1, 1 do
		map[idxx] = {}
		
		for idxz = z, z + constants.block_size - 1, 1 do
			local value = self.base_value
			local info = {}
			
			self.modules:foreach(function(module)
				value, info = module:get(idxx, idxz, value, info, support)
			end)
			
			map[idxx][idxz] = {
				value = value,
				info = info
			}
		end
	end
	
	self.cache:put(x, z, map)
	
	return map
end

--- Inits this instance and all modules.
--
-- Does nothing if this instance is already intialized.
--
-- @param noise_manager Optional. The NoiseManager to use for the init. Defaults
--                      to a new instance if not provided.
function TerraGenitor:init(noise_manager)
	if self.initialized == false then
		noise_manager = noise_manager or NoiseManager:new()
		
		self.modules:foreach(function(module)
			module:init(noise_manager)
		end)
		
		self.initialized = true
	end
end

--- Gets if this instance has been initialized.
--
-- @return true if this instance has been initialized.
function TerraGenitor:is_initialized()
	return self.initialized
end

--- Register the given module.
--
-- Modules should be registered before the init method is called, otherwise
-- the modules will not be initialized by TerraGenitor.
--
-- @param module The module to register. Can also be a function with the same
--               signature as the get function in the module, which is
--               function(self, x, z, value, info, support).
function TerraGenitor:register(module)
	if type(module) == "function" then
		local container = Module:new()
		container.get = module
		self.modules:add(container)
	else
		self.modules:add(module)
	end
end

