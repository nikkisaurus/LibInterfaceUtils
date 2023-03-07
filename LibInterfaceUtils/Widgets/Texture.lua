local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Texture", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local maps = {
    methods = {
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
    },
    scripts = {
        OnEnter = true,
        OnHide = true,
        OnLeave = true,
        OnMouseDown = true,
        OnMouseUp = true,
        OnShow = true,
    },
}

local methods = {
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

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    private:Map(frame, texture, maps)

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
