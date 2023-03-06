local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
local objectType, version = "Button", 1

local button
local callbackRegistry, methods, forbidden, protected, protectedScripts, scripts

callbackRegistry = {
    -- OnChar = true,
    OnClick = true,
    OnDoubleClick = true,
    OnDragStart = true,
    OnDragStop = true,
    OnEnter = true,
    -- OnEvent = true,
    OnHide = true,
    -- OnKeyDown = true,
    -- OnKeyUp = true,
    OnLeave = true,
    -- OnLoad = true,
    OnMouseDown = true,
    OnMouseUp = true,
    -- OnMouseWheel = true,
    OnReceiveDrag = true,
    OnShow = true,
    OnSizeChanged = true,
    -- OnUpdate = true,
    PostClick = true,
    PreClick = true,
}

forbidden = {}

methods = {
    OnAcquire = function(self)
        self:SetSize(100, 20)
        self:SetBackdrop()
        self:SetDraggable()
        self:EnableMouse(true) -- this gets disabeld during SetDraggable
    end,

    SetFont = function(self, ...)
        private:SetFont(protected.text, ...)
    end,

    SetBackdrop = function(self, ...)
        private:SetBackdrop(protected.bg, protected.borders, ...)
    end,

    SetText = function(self, text)
        protected.text:SetText(text)
    end,
}

protected = {}

protectedScripts = {}

scripts = {}

local function creationFunc()
    button = CreateFrame("Button", private:GetObjectName(objectType), UIParent)
    button.overrideForbidden = true

    local bg, borders = private:CreateTexture(button)
    bg:SetAllPoints(button)

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetAllPoints(button)

    protected.bg = bg
    protected.borders = borders
    protected.text = text

    local widget = {
        object = button,
        type = objectType,
        version = version,
        forbidden = forbidden,
        callbackRegistry = callbackRegistry,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
