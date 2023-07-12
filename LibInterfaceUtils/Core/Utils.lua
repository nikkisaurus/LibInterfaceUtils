local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function addon.isValidString(str)
	return type(str) == "string" and str ~= "" and str
end

function addon.isTable(tbl)
	return type(tbl) == "table"
end

function addon.safecall(func, ...)
	if type(func) == "function" then
		return func(...)
	end
end

function addon.setNestedMetatables(target, source)
	setmetatable(target, { __index = source })
	for key, value in pairs(target) do
		if addon.isTable(value) and addon.isTable(source[key]) then
			addon.setNestedMetatables(value, source[key])
		end
	end
end

function addon.unpack(...)
	if addon.isTable(...) then
		return unpack(...)
	else
		return ...
	end
end
