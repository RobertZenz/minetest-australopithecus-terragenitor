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


-- Get the base path.
local base_path = minetest.get_modpath(minetest.get_current_modname())

-- Load the necessary files.
dofile(base_path .. "/biome.lua")
dofile(base_path .. "/caelum.lua")
dofile(base_path .. "/chisel.lua")
dofile(base_path .. "/flora.lua")
dofile(base_path .. "/module.lua")
dofile(base_path .. "/sculptor.lua")
dofile(base_path .. "/terragenitor.lua")


local modules_path = base_path .. "/modules"

dofile(modules_path .. "/dualnoisemodule.lua")
dofile(modules_path .. "/maskednoisemodule.lua")
dofile(modules_path .. "/maskedridgedmodule.lua")
dofile(modules_path .. "/roundingmodule.lua")
dofile(modules_path .. "/singlenoisemodule.lua")

