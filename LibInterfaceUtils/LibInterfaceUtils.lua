local addonName, addon = ...
local lib = LibStub:NewLibrary(addonName .. "-1.0", 1)
if not lib then
	return
end

function lib:New(widgetType)
	local pool = self.pools[widgetType]
	assert(pool, ("Widget type '%s' does not exist."):format(widgetType))

	local widget = pool:Acquire()
	widget.pool = pool
	addon.Fire(widget, "OnAcquire")

	return widget
end

function lib:Release(widget)
	widget:Release()
end
