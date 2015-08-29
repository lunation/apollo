local hook_registry = {}

hook = {}

function hook.add(event_name, id, f)
	if not isstring(event_name) or not isstring(id) or not isfunction(f) then error("Bad call to hook.add.") end

	if not hook_registry[event_name] then
		hook_registry[event_name]= {}
	end

	hook_registry[event_name][id]= f
end

function hook.call(event_name,...)
	local t = hook_registry[event_name]

	if t then
		for k,v in pairs(t) do
			local a,b,c,d,e,f = v(...)

			if a~=nil then
				return a,b,c,d,e,f
			end
		end
	end
end