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


--- The template for a Module to be used with TerraGenitor.
--
-- This is basically only an abstract base, the methods need to be implmented
-- in the implementing object.
Module = {}


--- Creates a new instance of Module.
-- @return a new instance of Module.
function Module:new()
	local instance = {}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- The init method is called when TerraGenitor's init method is called.
-- It is only called once right at the beginning.
--
-- @param noise_manager The NoiseManager that is used.
function Module:init(noise_manager)
end

--- The init_map method is called before values for a certain segment of
-- the map are requested.
--
-- @param x The x coordinate of the block.
-- @param z The z coordiante of the block.
function Module:init_map(x, z)
end

--- Gets the value and info from this Module.
--
-- The info object is an undefined table, which allows each module to save
-- individual information.
--
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @param value The base value.
-- @param info The info object.
-- @return The value and the info object.
function Module:get(x, z, value, info)
	return value, info
end

