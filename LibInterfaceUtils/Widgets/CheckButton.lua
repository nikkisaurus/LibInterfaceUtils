local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "CheckButton", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    label = {
        justifyH = "LEFT",
        disabledColor = private.assets.colors.dimmedWhite,
    },
}

local maps = {
    methods = {
        SetJustifyH = true,
        SetJustifyV = true,
        SetWordWrap = true,
    },
}

local scripts = {
    OnClick = function(self)
        self:SetChecked(not self:GetUserData("checked"))
    end,
    OnSizeChanged = function(self)
        self:SetAnchors()
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 20)
        self:ApplyTemplate()
        self:SetCheckAlignment("TOPLEFT")
        self:SetStyle()
        self:SetAutoWidth(true)
        self:SetText()
        self:SetChecked()
    end,

    ApplyTemplate = function(self, template)
        local label = CreateFromMixins(defaults.label, template or {})
        private:SetFont(self.label, label)
        self:SetUserData("label", label)
    end,

    GetChecked = function(self)
        return self:GetUserData("checked")
    end,

    SetAnchors = function(self)
        self.checkBox:ClearAllPoints()
        self.label:ClearAllPoints()

        local checkPoint = self:GetUserData("checkPoint")
        local canWrap = self.label:CanWordWrap()

        self.checkBox:SetPoint(checkPoint)
        self.label:SetPoint(checkPoint, self.checkBox, private.points[checkPoint][1], private.points[checkPoint][2] * 5, private.points[checkPoint][3] * 5)
        self.label:SetPoint(private.points[checkPoint][1], -(private.points[checkPoint][2] * 5), -(private.points[checkPoint][3] * 5))

        if private.points[checkPoint][3] ~= 0 then
            self.label:SetPoint("LEFT")
            self.label:SetPoint("RIGHT")
            self.label:SetWidth(self:GetWidth())
            if canWrap then
                self:SetHeight(self.checkBox:GetHeight() + self.label:GetStringHeight() + 10)
            else
                self:SetHeight(self.checkBox:GetHeight() + self.label:GetHeight() + 10)
            end
        else
            self.label:SetWidth(self:GetWidth() - self.checkBox:GetWidth() - 10)
            if canWrap then
                self:SetHeight(max(self.checkBox:GetHeight(), self.label:GetStringHeight()))
            else
                self:SetHeight(self.checkBox:GetHeight())
            end
        end

        if self:GetUserData("autoWidth") then
            self:SetWidth(self.label:GetStringWidth() + 30)
        end

        if not private:strcheck(self.label:GetText()) then
            self:SetSize(self.checkBox:GetSize())
        end
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:SetUserData("autoWidth", isAutoWidth)
        self:SetAnchors()
    end,

    SetCheckAlignment = function(self, point)
        self:SetUserData("checkPoint", point or "TOPLEFT")
        self:SetAnchors()
    end,

    SetChecked = function(self, isChecked)
        self:SetUserData("checked", isChecked)
        if isChecked then
            self.checked:Show()
        else
            self.checked:Hide()
        end
    end,

    SetDisabled = function(self, isDisabled)
        local label = self:GetUserData("label")
        if isDisabled then
            private:SetFont(self.label, CreateFromMixins(label, { color = label.disabledColor }))
            self.checked:SetAtlas("checkmark-minimal-disabled")
            self:Disable()
        else
            private:SetFont(self.label, label)
            self.checked:SetAtlas("checkmark-minimal")
            self:Enable()
        end
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    SetStyle = function(self, style)
        if style == "radio" then
            self.checkBox:SetAtlas("perks-radio-background")
            self.checked:SetAtlas("perks-radio-dot")
            self.checked:ClearAllPoints()
            self.checked:SetSize(12, 12)
            self.checked:SetPoint("CENTER", self.checkBox, "CENTER", 0, -1)
        else
            self.checkBox:SetAtlas("perks-checkbox")
            self.checked:SetAtlas("perks-icon-checkmark")
        end
    end,
}

local function creationFunc()
    local button = CreateFrame("CheckButton", private:GetObjectName(objectType), UIParent)

    button.checkBox = button:CreateTexture(nil, "ARTWORK")
    button.checkBox:SetSize(12, 12)

    button.checked = button:CreateTexture(nil, "ARTWORK")
    button.checked:SetAllPoints(button.checkBox)

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    local widget = {
        object = button,
        type = objectType,
        version = version,
    }

    private:Map(button, button.label, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
