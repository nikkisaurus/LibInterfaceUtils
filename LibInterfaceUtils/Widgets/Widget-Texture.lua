local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Texture", 1, false
local Widget = { _events = {} }

function Widget._events:OnAcquire()
	self:SetSize(100, 100)
	self:SetTexture()
	self:SetTexCoord(0, 1, 0, 1)
	self:SetBlendMode("BLEND")
	self:SetVertexColor(1, 1, 1, 1)
	self:SetDesaturated()
	self:SetHorizTile()
	self:SetVertTile()
	self:SetRotation(0)
	self:SetInteractive()
	self:Show()
end

function Widget:SetAtlas(...)
	self._frame:SetAtlas(...)
end

function Widget:SetBlendMode(...)
	self._frame:SetBlendMode(...)
end

function Widget:SetColorTexture(...)
	self._frame:SetColorTexture(...)
end

function Widget:SetDesaturated(...)
	self._frame:SetDesaturated(...)
end

function Widget:SetGradient(...)
	self._frame:SetGradient(...)
end

function Widget:SetHorizTile(...)
	self._frame:SetHorizTile(...)
end

function Widget:SetInteractive(isInteractive)
	self._frame:EnableMouse(isInteractive)
end

function Widget:SetRotation(...)
	self._frame:SetRotation(...)
end

function Widget:SetTexCoord(...)
	self._frame:SetTexCoord(...)
end

function Widget:SetTexture(...)
	self._frame:SetTexture(...)
end

function Widget:SetVertexColor(...)
	self._frame:SetVertexColor(...)
end

function Widget:SetVertTile(...)
	self._frame:SetVertTile(...)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = UIParent:CreateTexture(nil, "OVERLAY"),
	}, Widget)

	return widget
end)
