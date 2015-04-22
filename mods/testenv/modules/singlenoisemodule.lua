
SingleNoiseModule = {}
setmetatable(SingleNoiseModule, { __index = Module })


function SingleNoiseModule:new()
	local instance = Module:new()
	
	instance.noise_a = nil
	instance.noise_b = nil
	instance.noise_c = nil
	instance.map_a = nil
	instance.map_b = nil
	instance.map_c = nil
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function SingleNoiseModule:init(noise_manager)
	self.noise_a = noise_manager:get_noise_map(2, 0.3, 1, 120)
	self.noise_b = noise_manager:get_noise_map(4, 0.3, 1, 120)
	self.noise_c = noise_manager:get_noise_map(6, 0.3, 1, 120)
	self.noise_c = noise_manager:get_noise_map(8, 0.3, 1, 120)
end

function SingleNoiseModule:init_map(x, z)
	self.map_a = self.noise_a:get2dMap({ x = x, y = z })
	self.map_a = arrayutil.swapped_reindex2d(self.map_a, x, z)
	self.map_b = self.noise_b:get2dMap({ x = x, y = z })
	self.map_b = arrayutil.swapped_reindex2d(self.map_b, x, z)
	self.map_c = self.noise_c:get2dMap({ x = x, y = z })
	self.map_c = arrayutil.swapped_reindex2d(self.map_c, x, z)
end

function SingleNoiseModule:get(x, z, value, info, support)
	local val = 0
	val = val + self.map_a[x][z]
	val = val + self.map_b[x][z]
	val = val + self.map_c[x][z]
	val = val / 3
	
	return value + mathutil.round(val * 12), info
end

