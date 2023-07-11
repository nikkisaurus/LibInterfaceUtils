local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function addon.GenerateWidgetName(widgetType)
	local pool = lib.pools[widgetType]
	local count = 1

	for _, _ in pool:EnumerateActive() do
		count = count + 1
	end

	for _, _ in pool:EnumerateInactive() do
		count = count + 1
	end

	return ("Liu%s%d"):format(widgetType, count)
end
