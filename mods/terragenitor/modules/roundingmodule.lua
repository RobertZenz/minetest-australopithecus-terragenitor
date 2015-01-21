
RoundingModule = {}
setmetatable(RoundingModule, { __index = Module })


function RoundingModule:new()
	local instance = Module:new()
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function RoundingModule:get(x, z, value, info)
	return mathutil.round(value), info
end

