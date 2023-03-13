local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Button", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    backdrop = {
        highlightEnabled = true,
    },
}

local registry = {
    OnClick = true,
    OnDoubleClick = true,
    OnDragStart = true,
    OnDragStop = true,
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnReceiveDrag = true,
    OnShow = true,
    OnSizeChanged = true,
    PostClick = true,
    PreClick = true,
}

local methods = {
    OnAcquire = function(self)
        self:SetNormalFontObject(GameFontNormal)
        self:SetHighlightFontObject(GameFontHighlight)
        self:SetDisabledFontObject(GameFontDisable)
        self:SetPushedTextOffset(1, -1)
        self:SetText("")

        self:SetSize(100, 20)
        self:SetDraggable()
        self:EnableMouse(true) -- this gets disabled during SetDraggable

        self:SetBackdrop(defaults.backdrop)
    end,

    IsAutoWidth = function(self)
        return self:GetUserData("autoWidth")
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self, CreateFromMixins(defaults.backdrop, backdrop or {}))
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:SetUserData("autoWidth", isAutoWidth)
        if isAutoWidth then
            self:SetWidth(self:GetTextWidth() + 20)
        end
    end,

    SetText = function(self, text)
        self:_SetText(text or "")
        if self:IsAutoWidth() then
            self:SetWidth(self:GetTextWidth() + 20)
        end
    end,
}

local function creationFunc()
    local button = CreateFrame("Button", private:GetObjectName(objectType), UIParent)
    button._SetText = button.SetText
    button = private:CreateTextures(button)

    local widget = {
        object = button,
        type = objectType,
        version = version,
        registry = registry,
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
