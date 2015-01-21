
SingleNoiseModule = {}
setmetatable(SingleNoiseModule, { __index = Module })


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

