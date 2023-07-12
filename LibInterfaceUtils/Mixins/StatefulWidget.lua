local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local StatefulWidget = { _stateHandlers = {} }

function StatefulWidget._stateHandlers:OnEnter()
	self._state.highlight = true
	self:UpdateState()
end

function StatefulWidget._stateHandlers:OnLeave()
	self._state.highlight = false
	self:UpdateState()
end

function StatefulWidget._stateHandlers:OnMouseDown()
	self._state.pushed = true
	self:UpdateState()
end

function StatefulWidget._stateHandlers:OnMouseUp()
	self._state.pushed = false
	self:UpdateState()
end

function StatefulWidget:GetState()
	local state = self._state
	return (not self:IsEnabled()) and "Disabled" or (state.pushed and "Pushed") or (state.highlight and "Highlight") or "Normal"
end

function StatefulWidget:UpdateState()
	self:__updater()
end

function lib:RegisterStateHandlers(widget, frame, updater)
	widget = Mixin(widget, StatefulWidget)
	for event, _ in pairs(widget._stateHandlers) do
		addon.RegisterEvent(widget._frame, event)
	end

	widget.__frame = frame -- prefix with double underscores to differentiate between the normal _frame
	widget.__updater = updater -- and for consistency with state values
	widget:UpdateState()
end

function lib:UnregisterStateHandlers(widget)
	for event, _ in pairs(widget._stateHandlers) do
		widget._stateHandlers[event] = nil
		addon.RegisterEvent(widget._frame, event)
	end

	widget.__frame = nil
	widget.__updater = nil

	widget._stateHandlers = nil
	widget.GetState = nil
	widget.UpdateState = nil
end
