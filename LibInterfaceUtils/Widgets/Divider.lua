local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
local objectType, version = "Divider", 1

local divider
local methods, protected

methods = {
    OnAcquire = function(self)
        self:SetSize(300, 1)
        self:SetTexture()
    end,

    SetColorTexture = function(self, ...)
        self:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
        self:SetVertexColor(...)
    end,

    SetTexture = function(self, texture)
        protected.texture:SetTexture(texture)
    end,

    SetVertexColor = function(self, ...)
        protected.texture:SetVertexColor(...)
    end,
}

protected = {}

local function creationFunc()
    divider = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    divider.overrideForbidden = true

    local texture = divider:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(divider)

    protected.texture = texture

    local widget = {
        object = divider,
        type = objectType,
        version = version,
        forbidden = {},
        callbackRegistry = {},
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
