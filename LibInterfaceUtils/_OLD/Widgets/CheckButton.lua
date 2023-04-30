local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "CheckButton", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    disabled = {
        justifyH = "LEFT",
        color = private.assets.colors.dimmedWhite,
    },
    highlight = {
        justifyH = "LEFT",
        color = private.assets.colors.flair,
    },
    normal = {
        justifyH = "LEFT",
    },
}

local maps = {
    methods = {
        GetText = true,
        SetJustifyH = true,
        SetJustifyV = true,
        SetWordWrap = true,
        SetFontObject = true,
        SetFont = true,
        SetTextColor = true,
    },
}

local scripts = {
    OnClick = function(self)
        self:SetChecked(not self:Get("checked"))
    end,

    OnSizeChanged = function(self)
        self:SetAnchors()
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 20)
        self:ApplyTemplate()
        self:SetPadding()
        self:SetCheckAlignment("TOPLEFT")
        self:SetAutoWidth(true)
        self:SetStyle()
        self:SetText()
        self:SetChecked()
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        self:Set("template", type(template) == "table" and CreateFromMixins(defaults, template) or defaults)
        self:SetState(self:IsDisabled() and "disabled" or "normal")
    end,

    GetChecked = function(self)
        return self:Get("checked")
    end,

    SetAnchors = function(self)
        self.checkBox:ClearAllPoints()
        self.label:ClearAllPoints()

        local checkPoint = self:Get("checkPoint")
        local padding = self:Get("padding")
        local canWrap = self.label:CanWordWrap()

        self.checkBox:SetPoint(checkPoint)
        self.label:SetPoint(checkPoint, self.checkBox, private.points[checkPoint][1], private.points[checkPoint][2] * padding, private.points[checkPoint][3] * padding)
        self.label:SetPoint(private.points[checkPoint][1], -(private.points[checkPoint][2] * padding), -(private.points[checkPoint][3] * padding))

        if private.points[checkPoint][3] ~= 0 then
            self.label:SetPoint("LEFT")
            self.label:SetPoint("RIGHT")
            self.label:SetWidth(self:GetWidth())
            if canWrap then
                self:SetHeight(self.checkBox:GetHeight() + self.label:GetStringHeight() + (padding * 2))
            else
                self:SetHeight(self.checkBox:GetHeight() + self.label:GetHeight() + (padding * 2))
            end
        else
            self.label:SetWidth(self:GetWidth() - self.checkBox:GetWidth() - (padding * 2))
            if canWrap then
                self:SetHeight(max(self.checkBox:GetHeight(), self.label:GetStringHeight()))
            else
                self:SetHeight(self.checkBox:GetHeight())
            end
        end

        if self:Get("autoWidth") then
            self:SetWidth(self.checkBox:GetWidth() + self.label:GetStringWidth() + (padding * 3))
        end

        if not private:strcheck(self.label:GetText()) then
            self:SetSize(self.checkBox:GetSize())
        end
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:Set("autoWidth", isAutoWidth)
        self:SetAnchors()
    end,

    SetCheckAlignment = function(self, point)
        self:Set("checkPoint", point or "TOPLEFT")
        self:SetAnchors()
    end,

    SetChecked = function(self, isChecked)
        self:Set("checked", isChecked)
        if isChecked then
            self.checked:Show()
        else
            self.checked:Hide()
        end
    end,

    SetDisabled = function(self, isDisabled)
        self:Set("isDisabled", isDisabled)
        self:SetState(isDisabled and "disabled" or "normal")
        self.checked:SetDesaturated(isDisabled)
        if isDisabled then
            self:Disable()
        else
            self:Enable()
        end
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    SetPadding = function(self, padding)
        self:Set("padding", padding or 5)
    end,

    SetState = function(self, state)
        self:Set("state", state)
        private:SetFont(self, self:Get("template")[state])
    end,

    SetStyle = function(self, style)
        if style == "radio" then
            self.checkBox:SetAtlas("perks-radio-background")
            self.checked:SetAtlas("perks-radio-dot")
            self.checked:ClearAllPoints()
            self.checked:SetSize(12, 12)
            self.checked:SetPoint("CENTER", self.checkBox, "CENTER", 0, -PixelUtil.GetNearestPixelSize(1, private.UIParent:GetEffectiveScale(), 1))
        else
            self.checkBox:SetAtlas("perks-checkbox")
            self.checked:SetAtlas("perks-icon-checkmark")
            self.checked:ClearAllPoints()
            self.checked:SetAllPoints(self.checkBox)
        end
    end,
}

local function creationFunc()
    local button = private:Mixin(CreateFrame("CheckButton", private:GetObjectName(objectType), private.UIParent), "UserData")

    button.checkBox = button:CreateTexture(nil, "ARTWORK")
    button.checkBox:SetSize(12, 12)

    button.checked = button:CreateTexture(nil, "OVERLAY")
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
