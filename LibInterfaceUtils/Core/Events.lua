local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function addon.Fire(widget, event, ...)
	local callback = widget._events[event]
	addon.safecall(callback, widget, ...)
	widget:Fire(event, ...)
end

function addon.RegisterEvent(frame, event, callback)
	local widget = frame.widget
	local stateHandler = widget._stateHandlers and widget._stateHandlers[event]
	local handler = widget._events[event]
	local userCallback = widget._callbacks[event]

	if frame:HasScript(event) then
		if not handler and not userCallback and not callback and not stateHandler then
			-- Unregister event
			frame:SetScript(event, nil)
			return
		end

		frame:SetScript(event, function(...)
			addon.safecall(stateHandler, widget, ...)
			addon.safecall(handler, widget, ...)
			addon.safecall(userCallback, widget, ...)
			addon.safecall(callback, widget, ...)
		end)
	end
end
