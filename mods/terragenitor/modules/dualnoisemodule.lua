
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

function DualNoiseModule:init_map(x, z)
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

