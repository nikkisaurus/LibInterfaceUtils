local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "CheckButton", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local maps = {
    methods = {
        SetJustifyH = true,
        SetJustifyV = true,
        SetWordWrap = true,
    },
}

local registry = {
    OnClick = true,
    OnDoubleClick = true,
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnShow = true,
    PostClick = true,
    PreClick = true,
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
        self:SetLabelFont(GameFontHighlight)
        self:SetJustifyH("LEFT")
        self:SetJustifyV("MIDDLE")
        self:SetWordWrap(true)
        self:SetAutoWidth(true)
        self:SetCheckAlignment("TOPLEFT")
        self:SetText()
        self:SetChecked()
    end,

    SetAnchors = function(self)
        self.checkBox:ClearAllPoints()
        self.label:ClearAllPoints()

        local iconPoint = self:GetUserData("iconPoint")
        local canWrap = self.label:CanWordWrap()

        self.checkBox:SetPoint(iconPoint)
        self.label:SetPoint(iconPoint, self.checkBox, private.points[iconPoint][1], private.points[iconPoint][2] * 5, private.points[iconPoint][3] * 5)
        self.label:SetPoint(private.points[iconPoint][1], -(private.points[iconPoint][2] * 5), -(private.points[iconPoint][3] * 5))

        if private.points[iconPoint][3] ~= 0 then
            self.label:SetPoint("LEFT")
            self.label:SetPoint("RIGHT")
            self.label:SetWidth(self:GetWidth())
            if canWrap then
                self:SetHeight(self.checkBox:GetHeight() + self.label:GetStringHeight() + 10)
            else
                self:SetHeight(self.checkBox:GetHeight() + self.label:GetHeight() + 10)
            end
        else
            self.label:SetWidth(self:GetWidth() - self.checkBox:GetWidth() - 5)
            if canWrap then
                self:SetHeight(max(self.checkBox:GetHeight(), self.label:GetStringHeight()))
            else
                self:SetHeight(self.checkBox:GetHeight())
            end
        end

        if self:GetUserData("autoWidth") then
            self:SetWidth(self.label:GetStringWidth() + 30)
        end
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:SetUserData("autoWidth", isAutoWidth)
    end,

    SetCheckAlignment = function(self, point)
        self:SetUserData("iconPoint", point or "TOPLEFT")
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
        if isDisabled then
            self.checked:SetAtlas("checkmark-minimal-disabled")
            self:Disable()
        else
            self.checked:SetAtlas("checkmark-minimal")
            self:Enable()
        end
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    SetLabelFont = function(self, fontObject, color)
        self.label:SetFontObject(fontObject)
        self.label:SetTextColor((color or private.assets.colors.white):GetRGBA())
    end,
}

local function creationFunc()
    local button = CreateFrame("CheckButton", private:GetObjectName(objectType), UIParent)

    button.checkBox = button:CreateTexture(nil, "ARTWORK")
    button.checkBox:SetAtlas("checkbox-minimal")
    button.checkBox:SetSize(16, 16)

    button.checked = button:CreateTexture(nil, "ARTWORK")
    button.checked:SetAtlas("checkmark-minimal")
    button.checked:SetAllPoints(button.checkBox)

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    local widget = {
        object = button,
        type = objectType,
        version = version,
        registry = registry,
    }

    private:Map(button, button.label, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
