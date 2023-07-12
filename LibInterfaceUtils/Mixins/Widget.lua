local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local Widget = {}
addon.Widget = Widget

function Widget:ClearAllPoints()
	self._frame:ClearAllPoints()
end

function Widget:DoParentLayout(deferred)
	local parent = self._state.parent
	while parent do
		parent[deferred and "DoLayoutDeferred" or "DoLayout"](parent)
		parent = parent._state.parent
	end
end

function Widget:Fire(event, ...)
	local userCallback = self._callbacks[event]
	addon.safecall(userCallback, self, ...)
end

function Widget:Get(key)
	return self.data[key]
end

function Widget:GetWidth()
	return self._frame:GetWidth()
end

function Widget:GetHeight()
	return self._frame:GetHeight()
end

function Widget:Hide()
	self._frame:Hide()
end

function Widget:RegisterCallback(event, callback)
	assert(type(callback) == "function", "Invalid callback function supplied to :RegisterCallback()")
	self._callbacks[event] = callback
	addon.RegisterEvent(self._frame, event)
end

function Widget:Release()
	assert(addon.isTable(self), "Invalid widget reference supplied to :Release()")
	assert(self.pool, "Invalid widget reference supplied to :Release()")
	self._frame:SetParent(UIParent)
	self._state.parent = nil
	self.pool:Release(self)
	addon.Fire("OnRelease", self)
end

function Widget:Set(key, value)
	self.data[key] = value
end

function Widget:SetFillWidth(fillWidth)
	self._state.fillWidth = fillWidth
end

function Widget:SetFullHeight(fullHeight)
	self._state.fullHeight = fullHeight
end

function Widget:SetFullWidth(fullWidth)
	self._state.fullWidth = fullWidth
end

function Widget:SetHeight(...)
	self._frame:SetHeight(...)
end

function Widget:SetPoint(...)
	self._frame:SetPoint(...)
end

function Widget:SetSize(...)
	self._frame:SetSize(...)
end

function Widget:SetWidth(...)
	self._frame:SetWidth(...)
end

function Widget:Show()
	self._frame:Show()
end

function Widget:UnregisterCallback(event)
	self._callbacks[event] = nil
	addon.RegisterEvent(self._frame, event)
end
