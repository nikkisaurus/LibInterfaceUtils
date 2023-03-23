local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Texture", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local methods = {
    OnAcquire = function(self)
        self:SetSize(100, 100)
        self:SetInteractible()
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
    private:Mixin(texture, "UserData")

    local widget = {
        object = texture,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
