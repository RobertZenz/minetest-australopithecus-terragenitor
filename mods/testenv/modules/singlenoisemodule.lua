
SingleNoiseModule = {}


function SingleNoiseModule:new()
	local instance = Module:new()
	
	instance.noise = nil
	instance.map = nil
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function SingleNoiseModule:init(noise_manager)
	self.noise = noise_manager:get_noise_map(3, 0.5, 1, 35)
end

function SingleNoiseModule:init_map(x, z)
	self.map = self.noise:get2dMap({ x = x, y = z })
	self.map = tableutil.swapped_reindex2d(self.map, x, z)
end

function SingleNoiseModule:get(x, z, value, info)
	return value + self.map[x][z] * 5, info
end

