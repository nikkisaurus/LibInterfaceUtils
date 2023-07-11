local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function addon.isValidString(str)
	return type(str) == "string" and str ~= "" and str
end

function addon.safecall(func, ...)
	if type(func) == "function" then
		return func(...)
	end
end

function addon.setNestedMetatables(target, source)
	setmetatable(target, { __index = source })
	for key, value in pairs(target) do
		if type(value) == "table" and type(source[key]) == "table" then
			addon.setNestedMetatables(value, source[key])
		end
	end
end

function addon.unpack(...)
	if type(...) == "table" then
		return unpack(...)
	else
		return ...
	end
	-- return type(...) == "table" and unpack(...) or ...
end
