local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
local objectType, version = "Button", 1

local handlers, methods, protected, protectedScripts, scripts

handlers = {
    OnAcquire = function(self)
        self:SetSize(100, 20)
    end,
}

methods = {
    -- SetPoint = true,
}

protected = {}

protectedScripts = {}

scripts = {
    OnClick = function(self)
        print("Clicked")
    end,
}

local function creationFunc()
    local button = CreateFrame("Button", private:GetObjectName(objectType), UIParent, "UIPanelButtonTemplate")
    button.overrideForbidden = true

    return private:RegisterObject(button, objectType, version, handlers, methods, scripts)
end

private:RegisterObjectPool(objectType, creationFunc)
