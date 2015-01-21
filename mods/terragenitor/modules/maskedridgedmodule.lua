
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

function MaskedRidgedModule:init_map(x, z)
	self.map = self.noise:get2dMap({ x = x, y = z })
	self.map = tableutil.swapped_reindex2d(self.map, x, z)
	self.map_mask = self.noise_mask:get2dMap({ x = x, y = z })
	self.map_mask = tableutil.swapped_reindex2d(self.map_mask, x, z)
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

