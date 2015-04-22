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


--- A module that does return a ridged noise together with a mask.
MaskedRidgedModule = {}
setmetatable(MaskedRidgedModule, { __index = Module })


function MaskedRidgedModule:new(mask_threshold, multiplier, threshold_min, threshold_max)
	local instance = Module:new()
	
	instance.map = nil
	instance.map_mask = nil
	instance.noise = nil
	instance.noise_mask = nil
	
	instance.param_mask_threshold = mask_threshold
	instance.param_multiplier = multiplier
	instance.param_threshold_max = threshold_max
	instance.param_threshold_min = threshold_min
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function MaskedRidgedModule:init(noise_manager)
	error("MaskedRidgedModule:init(noise_manager) needs to be implemented!")
end

function MaskedRidgedModule:init_map(x, z, support)
	self.map = self.noise:get2dMap({ x = x, y = z })
	self.map = arrayutil.swapped_reindex2d(self.map, x, z)
	self.map_mask = self.noise_mask:get2dMap({ x = x, y = z })
	self.map_mask = arrayutil.swapped_reindex2d(self.map_mask, x, z)
end

function MaskedRidgedModule:get(x, z, value, info)
	local mask_val = self.map_mask[x][z]
	
	if mask_val >= self.param_mask_threshold then
		local val = self.map[x][z]
	
		if val >= self.param_threshold_min and val <= self.param_threshold_max then
			val = transform.centered_linear(val, self.param_threshold_min, self.param_threshold_max)
			val = interpolate.cosine(val)
			val = interpolate.cosine(val)
			val = val * self.param_multiplier
		
			-- Fade out
			val = val * math.min(transform.linear(mask_val, self.param_mask_threshold, self.param_mask_threshold + 0.05), 1)
			
			return value + val, info
		end
	end
	
	return value, info
end

