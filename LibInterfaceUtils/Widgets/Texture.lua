local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
local objectType, version = "Texture", 1

local texture
local mapMethods, methods, mapScripts, protected

mapMethods = {
    EnableMouse = true,
    SetAtlas = true,
    SetBlendMode = true,
    SetDrawLayer = true,
    SetDesaturated = true,
    SetDesaturation = true,
    SetGradient = true,
    SetHorizTile = true,
    SetMask = true,
    SetRotation = true,
    SetTexCoord = true,
    SetTexture = true,
    SetVertexColor = true,
}

mapScripts = {
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnShow = true,
}

methods = {
    OnAcquire = function(self)
        self:SetSize(100, 100)
        self:SetTexture()
        self:EnableMouse()
    end,

    SetColorTexture = function(self, ...)
        self:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
        self:SetVertexColor(...)
    end,
}

protected = {}

local function creationFunc()
    texture = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    texture.overrideForbidden = true

    local tex = texture:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(texture)

    protected.texture = tex

    local widget = {
        object = texture,
        type = objectType,
        version = version,
        forbidden = {},
        callbackRegistry = {},
    }

    private:MapMethods(texture, tex, mapMethods)
    private:MapScripts(texture, tex, mapScripts)

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
