
MaskedNoiseModule = {}
setmetatable(MaskedNoiseModule, { __index = Module })


function MaskedNoiseModule:new(multiplier, mask_min_threshold, mask_max_threshold, smooth)
	local instance = Module:new()
	
	instance.noise = nil
	instance.noise_mask = nil
	instance.map = nil
	instance.map_mask = nil
	
	instance.param_mask_max_threshold = mask_max_threshold
	instance.param_mask_min_threshold = mask_min_threshold
	instance.param_multiplier = multiplier
	instance.param_smooth = smooth
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function MaskedNoiseModule:init(noise_manager)
	error("MaskedNoiseModule:init(noise_manager) needs to be implemented!")
end

function MaskedNoiseModule:init_map(x, z, support)
	self.map = self.noise:get2dMap({ x = x, y = z })
	self.map = arrayutil.swapped_reindex2d(self.map, x, z)
	self.map_mask = self.noise_mask:get2dMap({ x = x, y = z })
	self.map_mask = arrayutil.swapped_reindex2d(self.map_mask, x, z)
end

function MaskedNoiseModule:get(x, z, value, info)
	local mask_val = mathutil.clamp(self.map_mask[x][z], -1, 1)

	if mask_val >= self.param_mask_min_threshold and mask_val <= self.param_mask_max_threshold then
		local val = self.map[x][z]
		
		val = transform.linear(val)
		
		if self.param_smooth then
			val = val * transform.linear(mask_val, self.param_mask_min_threshold, self.param_mask_max_threshold)
		end
		
		val = val * self.param_multiplier
		
		return value + val, info
	end
	
	return value, info
end

