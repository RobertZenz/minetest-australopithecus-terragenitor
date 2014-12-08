--[[
Copyright (c) 2014, Robert 'Bobby' Zenz
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


Biome = {}


function Biome:new(name, parameters)
	parameters = parameters or {}
	
	local instance = {
		name = name,
		
		is_ocean = parameters.needs_ocean or nil,
		max_elevation = parameters.max_elevation or 31000,
		max_humidity = parameters.max_humidity or 31000,
		max_temperature = parameters.max_temperature or 31000,
		min_elevation = parameters.min_elevation or -31000,
		min_humidity = parameters.min_humidity or -31000,
		min_temperature = parameters.min_temperature or -31000
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function Biome:fits(x, z, elevation, humidity, temperature)
	return elevation.value >= self.min_elevation and elevation.value < self.max_elevation
		and humidity.value >= self.min_humidity and humidity.value < self.max_humidity
		and temperature.value >= self.min_temperature and temperature.value < self.max_temperature
		and (self.is_ocean ~= nil or self.is_ocean == elevation.info.ocean)
end

