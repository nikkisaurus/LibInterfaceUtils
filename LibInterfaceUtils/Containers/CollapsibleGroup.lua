local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "CollapsibleGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local registry = {
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnReceiveDrag = true,
    OnShow = true,
    OnSizeChanged = true,
}

local templates = {
    bordered = {
        content = {
            bgEnabled = true,
            bordersEnabled = true,
        },
        header = {
            bgColor = private.assets.colors.darker,
            highlightEnabled = true,
            highlightColor = private.assets.colors.dimmedFlair,
        },
        label = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
            disabledColor = private.assets.colors.dimmedWhite,
            highlightColor = private.assets.colors.white,
            justifyH = "LEFT",
        },
    },
    default = {
        content = {
            bgEnabled = false,
            bordersEnabled = false,
        },
        header = {
            bgColor = private.assets.colors.darker,
            highlightEnabled = true,
            highlightColor = private.assets.colors.dimmedFlair,
        },
        label = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
            disabledColor = private.assets.colors.dimmedWhite,
            highlightColor = private.assets.colors.white,
            justifyH = "LEFT",
        },
    },
}

local childScripts = {
    header = {
        OnClick = function(self)
            local widget = self.widget
            local frame = widget.object
            frame:Collapse(not frame:GetUserData("collapsed"))

            if widget.callbacks.OnCollapse then
                widget.callbacks.OnCollapse(widget.object)
            end
        end,

        OnEnter = function(self)
            local frame = self.widget.object
            local label = frame:GetUserData("label")
            if label.highlightColor then
                frame.label:SetTextColor(label.highlightColor:GetRGBA())
            end
        end,

        OnLeave = function(self)
            local frame = self.widget.object
            local label = frame:GetUserData("label")
            if label.highlightColor then
                frame.label:SetTextColor(label.color:GetRGBA())
            end
        end,
    },
}

local methods = {
    OnAcquire = function(self)
        self:SetLayout()
        self:SetSize(500, 300)
        self:SetPadding()
        self:ApplyTemplate("default")
        self:SetIcon()
        self:EnableIndicator(true)
        self:SetLabel()
        self:SetDisabled()
        self:Collapse()
    end,

    ApplyTemplate = function(self, template, mixin)
        local templateName = type(template) == "string" and template:lower() or mixin or "default"
        local header = CreateFromMixins(templates[templateName].header, template and template.header or {})
        local label = CreateFromMixins(templates[templateName].label, template and template.label or {})
        local content = CreateFromMixins(templates[templateName].content, template and template.disabled or {})

        private:SetBackdrop(self.header, header)
        private:SetFont(self.label, label)
        private:SetBackdrop(self.container, content)

        self:SetUserData("label", CopyTable(label))
    end,

    Collapse = function(self, collapsed)
        self:SetUserData("collapsed", collapsed)

        if collapsed then
            self.container:Hide()
            self.indicator:SetAtlas("Gamepad_Rev_Plus_32")
        else
            self.indicator:SetAtlas("Gamepad_Rev_Minus_32")
            self.container:Show()
        end

        local parent = self:GetUserData("parent")
        while parent do
            parent:DoLayout()
            parent = parent:GetUserData("parent")
        end
    end,

    EnableIndicator = function(self, isEnabled)
        self:SetUserData("enableIndicator", isEnabled)

        if isEnabled then
            self.indicator:Show()
            self.label:SetPoint("TOPRIGHT", self.indicator, "TOPLEFT", -5, 0)
        else
            self.indicator:Hide()
            self.label:SetPoint("RIGHT", -5, 0)
        end
    end,

    IsDisabled = function(self)
        return self:GetUserData("isDisabled")
    end,

    MarkDirty = function(self, usedWidth, usedHeight)
        if not self:GetUserData("collapsed") then
            usedHeight = usedHeight + self:GetUserData("top") + self:GetUserData("bottom")
        end

        self.container:SetHeight(usedHeight)

        local canWrap = self.label:CanWordWrap()
        if canWrap then
            self.header:SetHeight(self.label:GetStringHeight() + 10)
        else
            self.header:SetHeight(20)
        end

        self:SetHeight(usedHeight + self.header:GetHeight())
    end,

    SetDisabled = function(self, isDisabled)
        self:SetUserData("isDisabled", isDisabled)

        local label = self:GetUserData("label")
        if isDisabled then
            self.label:SetTextColor(label.disabledColor:GetRGBA())
            self.indicator:SetVertexColor(label.disabledColor:GetRGBA())
        else
            self.label:SetTextColor(label.color:GetRGBA())
            self.indicator:SetVertexColor(1, 1, 1, 1)
        end
        self.icon:SetDesaturated(isDisabled)
        self.header:SetEnabled(not isDisabled)
    end,

    SetIcon = function(self, icon, width, height)
        self.icon:SetTexture(icon)
        self.icon:SetWidth(width or 20)
        self.icon:SetHeight(height or 20)
        if icon then
            self.icon:Show()
            self.label:SetPoint("TOPLEFT", self.icon, "TOPRIGHT", 5, 0)
        else
            self.icon:Hide()
            self.label:SetPoint("LEFT", 5, 0)
        end
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")
    end,

    SetPadding = function(self, left, right, top, bottom)
        self:SetUserData("left", left or 5)
        self:SetUserData("right", right or 5)
        self:SetUserData("top", top or 5)
        self:SetUserData("bottom", bottom or 5)
        self.content:SetPoint("TOPLEFT", left or 5, -(top or 5))
        self.content:SetPoint("BOTTOMRIGHT", -(right or 5), (bottom or 5))
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    frame.header = CreateFrame("Button", nil, frame)
    frame.header:SetPoint("TOPLEFT")
    frame.header:SetPoint("TOPRIGHT")
    frame.header:SetHeight(20)
    frame.header = private:CreateTextures(frame.header)
    frame.header:SetScript("OnClick", childScripts.header.OnClick)
    frame.header:SetScript("OnEnter", childScripts.header.OnEnter)
    frame.header:SetScript("OnLeave", childScripts.header.OnLeave)

    frame.icon = frame.header:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(14, 14)
    frame.icon:SetPoint("TOPLEFT", 5, -5)

    frame.indicator = frame.header:CreateTexture(nil, "ARTWORK")
    frame.indicator:SetSize(10, 10)
    frame.indicator:SetPoint("TOPRIGHT", -5, -5)

    frame.label = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetJustifyH("LEFT")
    frame.header:SetFontString(frame.label)

    frame.container = CreateFrame("Frame", nil, frame)
    frame.container:SetPoint("TOP", frame.header, "BOTTOM", 0, 1)
    frame.container:SetPoint("LEFT")
    frame.container:SetPoint("BOTTOMRIGHT")
    frame.container = private:CreateTextures(frame.container)

    frame.content = CreateFrame("Frame", nil, frame.container)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        registry = registry,
    }

    frame.header.widget = widget

    return private:RegisterContainer(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
