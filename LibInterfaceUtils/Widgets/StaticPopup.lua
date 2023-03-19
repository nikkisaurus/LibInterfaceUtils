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
    OnHide = function(self)
        local onEscape = self:GetUserData("onEscape")
        if not self:GetUserData("userReleased") and onEscape then
            onEscape(self)
        end
        self:Release()
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

        self:SetUserData("button", button)
        private:SetBackdrop(self, frame)
        private:SetFont(self.label, label)

        if frame.hideOnEscape then
            tinsert(UISpecialFrames, self:GetName())
        else
            tDeleteItem(UISpecialFrames, self:GetName())
        end
    end,

    InitializeButtons = function(self, buttons, onEscape)
        self.buttons:ReleaseChildren()

        self:SetUserData("onEscape", onEscape)

        if type(buttons) ~= "table" then
            local button = self.buttons:New("Button")
            button:SetText(CLOSE)
            button:ApplyTemplate(template)
            button:SetCallback("OnClick", function()
                self:Release()
            end)
        else
            local template = self:GetUserData("button")

            for i = 2, 1, -1 do
                local buttonInfo = buttons[i]
                local button = self.buttons:New("Button")
                button:SetText(buttonInfo.text or (i == 1 and ACCEPT or CANCEL))
                button:ApplyTemplate(template)
                button:SetCallback("OnClick", function()
                    if buttonInfo.OnClick then
                        buttonInfo.OnClick(self)
                    end
                    self:SetUserData("userReleased", true)
                    self:Release()
                end)
            end
        end

        self:SetAnchors()
    end,

    SetAnchors = function(self)
        self.buttons:ClearAllPoints()
        self.label:ClearAllPoints()

        local left = self:GetUserData("left")
        local right = self:GetUserData("right")
        local top = self:GetUserData("top")
        local bottom = self:GetUserData("bottom")

        local spacingH = self:GetUserData("spacingH")
        local spacingV = self:GetUserData("spacingV")

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
        self:SetUserData("left", left or 20)
        self:SetUserData("right", right or 20)
        self:SetUserData("top", top or 20)
        self:SetUserData("bottom", bottom or 20)
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:SetUserData("spacingH", spacingH or 5)
        self:SetUserData("spacingV", spacingV or 20)
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
