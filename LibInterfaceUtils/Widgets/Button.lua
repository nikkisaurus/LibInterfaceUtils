local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
local objectType, version = "Button", 1

local button
local callbackRegistry, methods, protected

callbackRegistry = {
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

methods = {
    OnAcquire = function(self)
        self:SetSize(100, 20)
        self:SetBackdrop()
        self:SetDraggable()
        self:SetPushedTextOffset(1, -1)
        self:EnableMouse(true) -- this gets disabeld during SetDraggable
    end,

    SetFont = function(self, ...)
        private:SetFont(protected.text, ...)
    end,

    SetBackdrop = function(self, ...)
        private:SetBackdrop(protected.bg, protected.borders, protected.highlight, ...)
    end,

    SetPushedTextOffset = function(self, ...)
        self:SetUserData("pushedOffset", x and y and { x, y })
    end,
}

protected = {}

local function creationFunc()
    button = CreateFrame("Button", private:GetObjectName(objectType), UIParent)
    button.overrideForbidden = true

    local bg, borders, highlight = private:CreateTexture(button)
    bg:SetAllPoints(button)

    button:SetNormalFontObject(GameFontHighlight)
    button:SetText("")

    protected.bg = bg
    protected.borders = borders
    protected.highlight = highlight

    local widget = {
        object = button,
        type = objectType,
        version = version,
        forbidden = {},
        callbackRegistry = callbackRegistry,
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
