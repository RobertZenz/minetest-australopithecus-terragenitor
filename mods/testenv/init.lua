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


base_path = minetest.get_modpath(minetest.get_current_modname())
terragenitor = nil


minetest.register_node("testenv:ground", {
	description = "Ground",
	tiles = {
		"grid_blue.png"
	}
})
minetest.register_node("testenv:border", {
	description = "Border",
	tiles = {
		"grid_violet.png"
	}
})

minetest.register_on_mapgen_init(function(mapgen_params)
	minetest.set_mapgen_params({
		mgname = "singlenode",
		water_level = -31000
	})
end)

minetest.register_on_generated(function(minp, maxp, seed)
	if terragenitor == nil then
		terragenitor = TerraGenitor:new()
		dofile(base_path .. "/modules.lua")
		terragenitor:init()
	end
	
	local ground_node = minetest.get_content_id("testenv:ground")
	local border_node = minetest.get_content_id("testenv:border")
	
	local manipulator = MapManipulator:new()
	local area = manipulator:get_area()
	local data = manipulator:get_data()
	
	local elevation_map = terragenitor:get_map(minp.x, minp.z)
	
	for x = minp.x, maxp.x, 1 do
		for z = minp.z, maxp.z, 1 do
			local elevation = elevation_map[x][z].value
			
			for y = minp.y, math.min(elevation, maxp.y), 1 do
				if x == minp.x or z == minp.z
					or x == maxp.x or z == maxp.z
					or y == minp.y or y == maxp.y then
					data[area:index(x, y, z)] = border_node
				else
					data[area:index(x, y, z)] = ground_node
				end
			end
		end
	end

	manipulator:set_data(data)
end)

