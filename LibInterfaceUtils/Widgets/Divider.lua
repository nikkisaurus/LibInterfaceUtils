local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
local objectType, version = "Divider", 1

local divider
local maps, methods, protected

maps = {
    SetTexture = true,
    SetVertexColor = true,
}

methods = {
    OnAcquire = function(self)
        self:SetSize(300, 1)
        self:SetTexture()
    end,

    SetColorTexture = function(self, ...)
        self:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
        self:SetVertexColor(...)
    end,
}

protected = {}

local function creationFunc()
    divider = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    divider.overrideForbidden = true

    local texture = divider:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(divider)

    protected.texture = texture

    local widget = {
        object = divider,
        type = objectType,
        version = version,
        forbidden = {},
        callbackRegistry = {},
    }

    private:MapMethods(divider, texture, maps)

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
