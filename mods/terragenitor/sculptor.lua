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


--- Sculptor is a module based system for manipulating blocks/chunks.
--
-- The modules used by Sculptor are called a "Chisel". A chisel is a very thin
-- interface that works very similar to the modules of TerraGenitor.
Sculptor = {}


--- Creates a new instance of Sculptor.
function Sculptor:new()
	local instance = {
		chisels = List:new(),
		initialized = false
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Inits this instance and all chisels.
--
-- Does nothing if this instance is already intialized.
--
-- @param noise_manager Optional. The NoiseManager to use for the init. Defaults
--                      to a new instance if not provided.
function Sculptor:init(noise_manager)
	if self.initialized == false then
		noise_manager = noise_manager or NoiseManager:new()
		
		self.chisels:foreach(function(chisel)
			chisel:init(noise_manager)
		end)
		
		self.initialized = true
	end
end


--- Gets if this instance has been initialized.
--
-- @return true if this instance has been initialized.
function Sculptor:is_initialized()
	return self.initialized
end

--- Register the given chisel.
--
-- Chisels should be registered before the init method is called, otherwise
-- the chisels will not be initialized by Sculptor.
--
-- @param chisel The chisel to register.
function Sculptor:register(chisel)
	self.chisels:add(chisel)
end

--- Sculpts the given data by calling all chisels on it.
--
-- @param x The x coordinate.
-- @param y The y coordinate.
-- @param z The z coordinate.
-- @param data The data which should be changed.
-- @param area The area associated with the given data.
-- @param support Optional. The support object that provides additional
--                information for the chisels. The format is not defined.
-- @return The same data object as given.
function Sculptor:sculpt(x, y, z, data, area, support)
	self.chisels:foreach(function(chisel)
		chisel:init_block(x, y, z)
	end)
	
	for idxx = x, x + constants.block_size - 1, 1 do
		for idxz = z, z + constants.block_size - 1, 1 do
			for idxy = y, y + constants.block_size - 1, 1 do
				local index = area:index(idxx, idxy, idxz)
				
				self.chisels:foreach(function(chisel)
					data[index] = chisel:get(idxx, idxy, idxz, data[index], support)
				end)
			end
		end
	end
	
	return data
end

