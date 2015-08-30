function print(...)
	window:console_print(...)
end

print[[
/=====================================================================\
[         ###    ########   #######  ##       ##        #######       ]
[        ## ##   ##     ## ##     ## ##       ##       ##     ##      ]
[       ##   ##  ##     ## ##     ## ##       ##       ##     ##      ]
[      ##     ## ########  ##     ## ##       ##       ##     ##      ]
[      ######### ##        ##     ## ##       ##       ##     ##      ]
[      ##     ## ##        ##     ## ##       ##       ##     ##      ]
[      ##     ## ##         #######  ######## ########  #######       ]
[                                                                     ]
[    Apollo is an HTML5 Game Engine written in Lua for some reason.   ]
[                                                                     ]
[        Version: 0.0.0                                               ]
[        Author: Adam Coggeshall                                      ]
[        Website: https://github.com/lunation/apollo                  ]
[                                                                     ]
[  “Doubt has killed more scripts than errors ever will.” - John Lua  ]
\=====================================================================/
]]

-- Rename loadstring.
compile = loadstring
loadstring= nil

-- Get rid of all the rest of the load/run shit.
load = nil
loadfile = nil
dofile = nil

-- Lua's package system is dumb anyway. Not that I came up with a better way to do things :/
require = nil
module = nil
package = nil

-- Fuck these, they're probably broken anyway.
io = nil
os = nil

-- I will fucking sodoku if using this becomes necessary
debug= nil

-- They don't fucking need control of the GC. Wasn't this deprecated anyway?
collectgarbage = nil

-- Stop wasting my time. If I need these I'll convert them to luajit's naming scheme.
bit32 = nil

-- Jank OO.

function Class(t)
	if t.__index then error("Classes don't support custom __index.") end
	t.__index=t
	return function(...)
		local o = {}
		setmetatable(o,t)
		o:__ctor(...)
		return o
	end
end

-- Gmod-style typechecking funcs. Shitty naming adopted as well.

function isbool(v)
	return type(v)=="boolean"
end

function isnumber(v)
	return type(v)=="number"
end

function isstring(v)
	return type(v)=="string"
end

function istable(v)
	return type(v)=="table"
end

function isfunction(v)
	return type(v)=="function"
end

-- File lib here. We need it to bootstrap everything else.

file = {}

function file.list(path)
	local files = {}
	local dirs = {}

	local base = window.file_table;

	for s in path:gmatch("[^/]+") do
		base = base[s]
		if not base then
			error("Invalid path.")
		end
	end

	for k,v in pairs(base) do
		if isstring(v) then
			table.insert(files,k)
		else
			table.insert(dirs,k)
		end
	end

	return files,dirs
end

file.read = function(name,callback) window:fetch_file(name,function(_,data) callback(data) end) end --god this is terrible

-- Our LUA loading system. Goddamn I hate it so much.

print("Loading engine libraries...")

local engine_libs = file.list("engine")

local libs_completed = 0

for _,name in pairs(engine_libs) do
	file.read("engine/"..name,function(data)
		compile(data,name)()
		print("> "..name)
		libs_completed=libs_completed+1
		if libs_completed==#engine_libs then
			--Load the game or some shit
			print("\nEngine loaded. Time to load the game or something.")
		end
	end)
end

-- What does our lib look like right now?
--[[
for k,v in pairs(_G) do
	print(k,v)
end
]]
