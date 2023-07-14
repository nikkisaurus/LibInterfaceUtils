local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Texture", 1, false
local Widget = { _events = {} }

function Widget._events:OnAcquire()
    self:SetSize(100, 100)
    self:SetTexture(134400)    
    self:Show()
end

function Widget:SetAtlas(...)
    self._frame:SetAtlas(...)
end

function Widget:SetTexture(...)
    self._frame:SetTexture(...)
end

function Widget:SetVertexColor(...)
    self._frame:SetVertexColor(...)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
    local widget = CreateFromMixins({
        _frame = UIParent:CreateTexture(nil, "OVERLAY")
    }, Widget)

    return widget
end)