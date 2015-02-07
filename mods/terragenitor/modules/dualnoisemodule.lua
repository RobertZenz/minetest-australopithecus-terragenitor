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


--- A module that returns the combination of two noises and a mask.
DualNoiseModule = {}
setmetatable(DualNoiseModule, { __index = Module })


function DualNoiseModule:new(multiplier)
	local instance = Module:new()
	
	instance.noise_a = nil
	instance.noise_b = nil
	instance.noise_mask = nil
	instance.map_a = nil
	instance.map_b = nil
	instance.map_mask = nil
	
	instance.param_multiplier = multiplier
	
	setmetatable(instance, self)
	self.__index = self
		
	return instance
end


function DualNoiseModule:init(noise_manager)
	error("DualNoiseModule:init(noise_manager) needs to be implemented!")
end

function DualNoiseModule:init_map(x, z, support)
	self.map_a = self.noise_a:get2dMap({ x = x, y = z })
	self.map_a = tableutil.swapped_reindex2d(self.map_a, x, z)
	self.map_b = self.noise_b:get2dMap({ x = x, y = z })
	self.map_b = tableutil.swapped_reindex2d(self.map_b, x, z)
	self.map_mask = self.noise_mask:get2dMap({ x = x, y = z })
	self.map_mask = tableutil.swapped_reindex2d(self.map_mask, x, z)
end

function DualNoiseModule:get(x, z, value, info)
	local a = self.map_a[x][z]
	local b = self.map_b[x][z]
	local mask = self.map_mask[x][z]
	mask = transform.small_linear(mask)
	
	local val = interpolate.linear(mask, a, b)  * self.param_multiplier
	
	return value + val, info
end

