local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Texture", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local registry = {
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnShow = true,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(100, 100)
        self:SetInteractible()
        print("Acquire texture")
    end,

    OnRelease = function(self)
        self:SetTexture()
    end,

    SetColorTexture = function(self, ...)
        self:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
        self:SetVertexColor(...)
    end,

    SetInteractible = function(self, isInteractible)
        self:EnableMouse(isInteractible or false)
    end,
}

local function creationFunc()
    local texture = UIParent:CreateTexture(private:GetObjectName(objectType), "BACKGROUND")

    local widget = {
        object = texture,
        type = objectType,
        version = version,
        registry = registry,
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
-- !FIX ME textures are not resetting
