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


--- A simple module that is only returning the value from one noise source.
SingleNoiseModule = {}
setmetatable(SingleNoiseModule, { __index = Module })


--- Creates a new instance of SingleNoiseModule.
--
-- @param The multiplier that is applied to the value.
-- @return A new instance.
function SingleNoiseModule:new(multiplier)
	local instance = Module:new()
	
	instance.noise = nil
	instance.map = nil
	
	instance.param_multiplier = multiplier
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function SingleNoiseModule:init(noise_manager)
	error("SingelNoiseModule:init(noise_manager) needs to be implemented!")
end

function SingleNoiseModule:init_map(x, z)
	self.map = self.noise:get2dMap({ x = x, y = z })
	self.map = tableutil.swapped_reindex2d(self.map, x, z)
end

function SingleNoiseModule:get(x, z, value, info)
	local val = self.map[x][z] * self.param_multiplier
	
	return value + val, info
end

