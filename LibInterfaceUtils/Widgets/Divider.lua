local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Divider", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local maps = {
    methods = {
        SetTexture = true,
        SetVertexColor = true,
    },
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 1)
        self:SetTexture()
    end,

    SetColorTexture = function(self, ...)
        self:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
        self:SetVertexColor(...)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    local texture = frame:CreateTexture(nil, "ARTWORK")
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
