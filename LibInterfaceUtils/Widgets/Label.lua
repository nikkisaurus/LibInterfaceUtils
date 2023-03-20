local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Label", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    frame = {
        bgEnabled = false,
        bordersEnabled = false,
    },
    label = {
        justifyH = "LEFT",
        disabledColor = private.assets.colors.dimmedWhite,
    },
}

local maps = {
    methods = {
        EnableMouse = true,
        GetText = true,
        SetJustifyH = true,
        SetJustifyV = true,
        SetWordWrap = true,
    },
}

local childScripts = {
    icon = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsDisabled() then
                return
            end

            frame:Fire("OnMouseDown")
        end,
    },
}

local scripts = {
    OnSizeChanged = function(self)
        self:SetAnchors()
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 20)
        self:SetAutoWidth(true)
        self:ApplyTemplate()
        self:SetIcon()
        self:SetText()
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        local frame = CreateFromMixins(defaults.frame, template and template.frame or {})
        local label = CreateFromMixins(defaults.label, template and template.label or {})

        private:SetBackdrop(self, frame)
        private:SetFont(self.label, label)

        self:SetUserData("label", label)
    end,

    IsDisabled = function(self)
        return self:GetUserData("isDisabled")
    end,

    IsTruncated = function(self)
        -- TODO need to calculate icon width when possible to see if it's being cut off
        return (self.label:GetStringWidth()) > self:GetWidth()
    end,

    SetAnchors = function(self)
        self.icon:ClearAllPoints()
        self.label:ClearAllPoints()

        local iconPoint = self:GetUserData("iconPoint")
        local hasIcon = self:GetUserData("icon")
        local canWrap = self.label:CanWordWrap()

        if hasIcon then
            self.icon:SetPoint(iconPoint)
            self.label:SetPoint(iconPoint, self.icon, private.points[iconPoint][1], private.points[iconPoint][2] * 5, private.points[iconPoint][3] * 5)
            self.label:SetPoint(private.points[iconPoint][1])

            if private.points[iconPoint][3] ~= 0 then
                self.label:SetPoint("LEFT")
                self.label:SetPoint("RIGHT")
                self.label:SetWidth(self:GetWidth())
                if canWrap then
                    self:SetHeight(self.icon:GetHeight() + self.label:GetStringHeight() + 5)
                else
                    self:SetHeight(self.icon:GetHeight() + self.label:GetHeight() + 5)
                end
            else
                self.label:SetWidth(self:GetWidth() - self.icon:GetWidth() - 5)
                if canWrap then
                    self:SetHeight(max(self.icon:GetHeight(), self.label:GetStringHeight() + 5))
                else
                    self:SetHeight(self.icon:GetHeight())
                end
            end
        else
            self.icon:SetSize(0, 0)
            self.label:SetPoint("TOPLEFT")
            self.label:SetPoint("TOPRIGHT")
            self.label:SetWidth(self:GetWidth()) -- need to set to make sure height is properly calculated
            if canWrap then
                self:SetHeight(self.label:GetStringHeight())
            end
        end

        if self:GetUserData("autoWidth") then
            self:SetWidth(self.label:GetStringWidth() + 20)
        end
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:SetUserData("autoWidth", isAutoWidth)
        self:SetAnchors()
    end,

    SetDisabled = function(self, isDisabled)
        self:SetUserData("isDisabled", isDisabled)
        self:SetInteractible(not isDisabled)
        local label = self:GetUserData("label")
        if isDisabled then
            private:SetFont(self.label, CreateFromMixins(label, { color = label.disabledColor }))
        else
            private:SetFont(self.label, label)
        end
    end,

    SetIcon = function(self, icon, width, height, point)
        self:SetUserData("icon", icon)
        self.icon:SetTexture(icon)
        self.icon:SetWidth(width or 20)
        self.icon:SetHeight(height or 20)
        self:SetUserData("iconPoint", point or "TOPLEFT")

        self:SetAnchors()
    end,

    SetInteractible = function(self, isInteractible)
        self:EnableMouse(isInteractible or false)
        self.label:EnableMouse(isInteractible or false)
        self.icon:EnableMouse(isInteractible or false)
    end,

    SetText = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    ShowTruncatedText = function(self, show)
        self:SetUserData("showTruncatedText", show)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame = private:CreateTextures(frame)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetScript("OnMouseDown", childScripts.icon.OnMouseDown)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    frame.icon.widget = widget

    private:Map(frame, frame.icon)
    private:Map(frame, frame.label, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
