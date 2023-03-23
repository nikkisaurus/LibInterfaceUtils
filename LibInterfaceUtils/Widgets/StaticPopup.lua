local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "StaticPopup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    button = {},
    frame = {
        hideOnEscape = true,
    },
    label = {
        justifyH = "LEFT",
        justifyV = "TOP",
    },
}

local popups = {}

local scripts = {
    OnDragStart = function(self)
        self:StartMoving()
    end,
    OnDragStop = function(self)
        self:StopMovingOrSizing()
    end,
    OnKeyDown = function(self, key)
        if not self:Get("frame").hideOnEscape or key ~= "ESCAPE" then
            self:SetPropagateKeyboardInput(true)
        else
            self:SetPropagateKeyboardInput(false)
            local onEscape = self:Get("onEscape")
            if onEscape then
                onEscape(self)
            end
            self:Release()
        end
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 100)
        self:ApplyTemplate()
        self:SetSpacing()
        self:SetPadding()
        self:InitializeButtons()
        self:SetAnchors()
        self:SetFrameStrata("TOOLTIP")
        private:HidePopups(self)
    end,

    ApplyTemplate = function(self, template)
        local button = CreateFromMixins(defaults.button, template and template.button or {})
        local frame = CreateFromMixins(defaults.frame, template and template.frame or {})
        local label = CreateFromMixins(defaults.label, template and template.label or {})

        self:Set("button", button)
        private:SetBackdrop(self, frame)
        private:SetFont(self.label, label)

        self:Set("frame", frame)
    end,

    InitializeButtons = function(self, buttons, onEscape)
        self.buttons:ReleaseChildren()

        self:Set("onEscape", onEscape)

        if type(buttons) ~= "table" then
            local button = self.buttons:New("Button")
            button:SetText(CLOSE)
            button:ApplyTemplate(t)
            button:SetCallback("OnClick", function()
                self:Release()
            end)
        else
            local template = self:Get("button")

            for i = 2, 1, -1 do
                local buttonInfo = buttons[i]
                local button = self.buttons:New("Button")
                button:SetText(buttonInfo.text or (i == 1 and ACCEPT or CANCEL))
                button:ApplyTemplate(template)
                button:SetCallback("OnClick", function()
                    if buttonInfo.OnClick then
                        buttonInfo.OnClick(self)
                    end
                    self:Release()
                end)
            end
        end

        self:SetAnchors()
    end,

    SetAnchors = function(self)
        self.buttons:ClearAllPoints()
        self.label:ClearAllPoints()

        local left = self:Get("left")
        local right = self:Get("right")
        local top = self:Get("top")
        local bottom = self:Get("bottom")

        local spacingH = self:Get("spacingH")
        local spacingV = self:Get("spacingV")

        self.buttons:SetPoint("BOTTOMLEFT", left, bottom)
        self.buttons:SetPoint("BOTTOMRIGHT", -right, bottom)
        self.buttons:SetSpacing(spacingH, 0)

        self.label:SetPoint("TOP", 0, -top)
        self.label:SetPoint("LEFT", left, 0)
        self.label:SetPoint("RIGHT", -right, 0)
        self.label:SetPoint("BOTTOM", self.buttons, "TOP", 0, spacingV)

        self:SetHeight(self.buttons.children[1]:GetHeight() + self.label:GetStringHeight() + top + bottom + spacingV)
    end,

    SetLabel = function(self, text)
        self.label:SetText(text)
        self:SetAnchors()
    end,

    SetPadding = function(self, left, right, top, bottom)
        self:Set("left", left or 20)
        self:Set("right", right or 20)
        self:Set("top", top or 20)
        self:Set("bottom", bottom or 20)
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:Set("spacingH", spacingH or 5)
        self:Set("spacingV", spacingV or 20)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    private:CreateTextures(frame)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    tinsert(popups, frame)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    frame.buttons = lib:New("Group")
    frame.buttons:SetParent(frame)
    frame.buttons:SetPadding(0, 0, 0, 0)
    frame.buttons:SetLayoutPoint("BOTTOMRIGHT")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)

function private:HidePopups(ignoredPopup)
    for _, popup in ipairs(popups) do
        if popup ~= ignoredPopup then
            popup:Release()
        end
    end
end
