
-- Load the test file.
dofile("./mods/utils/test.lua")

-- Now load the file for testing.
dofile("./mods/terragenitor/terragenitor.lua")

dofile("./mods/terragenitor/module.lua")
dofile("./mods/utils/blockedcache.lua")
dofile("./mods/utils/constants.lua")
dofile("./mods/utils/list.lua")
dofile("./mods/utils/noisemanager.lua")


test.start("Terragenitor")

test.run("basic", function()
	local terragenitor = TerraGenitor:new()
	terragenitor:init()
	
	test.equals(true, terragenitor:is_initialized())
	
	terragenitor:get_map(0, 0)
end)

test.run("default_value", function()
	local terragenitor = TerraGenitor:new("default")
	terragenitor:init()
	
	test.equals(true, terragenitor:is_initialized())
	
	local map = terragenitor:get_map(0, 0)
	
	test.equals("default", map[0][0].value)
	test.equals("default", map[15][15].value)
end)

test.run("function_module", function()
	local terragenitor = TerraGenitor:new("default")
	
	terragenitor:register(function(self, x, z, value, info, support)
		info.changed = true
		return "changed", info
	end)
	
	terragenitor:init()
	
	test.equals(true, terragenitor:is_initialized())
	
	local map = terragenitor:get_map(0, 0)
	
	test.equals("changed", map[0][0].value)
	test.equals(true, map[0][0].info.changed)
	test.equals("changed", map[15][15].value)
	test.equals(true, map[15][15].info.changed)
end)

test.run("function_modules", function()
	local terragenitor = TerraGenitor:new("default")
	
	terragenitor:register(function(self, x, z, value, info, support)
		info.a = true
		return "a", info
	end)
	terragenitor:register(function(self, x, z, value, info, support)
		info.b = true
		return value .. "b", info
	end)
	terragenitor:register(function(self, x, z, value, info, support)
		info.c = true
		return value, info
	end)
	
	terragenitor:init()
	
	test.equals(true, terragenitor:is_initialized())
	
	local map = terragenitor:get_map(0, 0)
	
	test.equals("ab", map[0][0].value)
	test.equals(true, map[0][0].info.a)
	test.equals(true, map[0][0].info.b)
	test.equals(true, map[0][0].info.c)
	test.equals("ab", map[15][15].value)
	test.equals(true, map[15][15].info.a)
	test.equals(true, map[15][15].info.b)
	test.equals(true, map[15][15].info.c)
end)

