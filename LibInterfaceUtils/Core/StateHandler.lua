local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local Handler = {}

function Handler:OnEnter()
	self._state.highlight = true
	self:UpdateState()
end

function Handler:OnLeave()
	self._state.highlight = false
	self:UpdateState()
end

function Handler:OnMouseDown()
	self._state.pushed = true
	self:UpdateState()
end

function Handler:OnMouseUp()
	self._state.pushed = false
	self:UpdateState()
end

function lib:RegisterStateHandlers(widget, updater)
	widget._stateHandlers = CreateFromMixins(Handler)
	for event, _ in pairs(widget._stateHandlers) do
		addon.RegisterEvent(widget._frame, event)
	end

	widget.UpdateState = updater
	widget:UpdateState(widget)
end

function lib:UnregisterStateHandlers(widget)
	for event, _ in pairs(widget._stateHandlers) do
		widget._stateHandlers[event] = nil
		addon.RegisterEvent(widget._frame, event)
	end

	widget._stateHandlers = nil
	widget.UpdateState = nil
end
