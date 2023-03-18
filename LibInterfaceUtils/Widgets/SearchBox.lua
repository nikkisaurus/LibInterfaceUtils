local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "SearchBox", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    button = {
        color = private.assets.colors.white,
        highlightColor = private.assets.colors.flair,
    },
    editbox = {
        bgColor = private.assets.colors.normal,
        font = "GameFontHighlight",
        color = private.assets.colors.white,
        justifyH = "LEFT",
    },
    icon = {
        color = private.assets.colors.lightWhite,
    },
    label = {
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        justifyH = "LEFT",
    },
}

local forbidden = {
    SetMultiLine = true,
}

local maps = {
    methods = {
        AddHistoryLine = true,
        ClearFocus = true,
        GetText = true,
        GetNumber = true,
        HighlightText = true,
        Insert = true,
        SetAltArrowKeyMode = true,
        SetAutoFocus = true,
        SetBlinkSpeed = true,
        SetFocus = true,
        SetFontObject = true,
        SetHistoryLines = true,
        SetMaxByes = true,
        SetMaxLetters = true,
        SetNumber = true,
        SetNumeric = true,
        SetPassword = true,
        SetSpacing = true,
        SetText = true,
    },
    scripts = {
        OnEditFocusGained = true,
        OnEditFocusLost = true,
        OnEnterPressed = function(self)
            self:ClearFocus()
        end,
        OnEscapePressed = function(self)
            self:ClearFocus()
        end,
        OnSpacePressed = true,
        OnTabPressed = true,
        OnTextChanged = function(self, userInput)
            local frame = self.widget.object
            if private:strcheck(self:GetText()) then
                frame.button:Show()
            else
                frame.button:Hide()
            end
        end,
        OnTextSet = function(self)
            local frame = self.widget.object
            if private:strcheck(self:GetText()) then
                frame.button:Show()
            else
                frame.button:Hide()
            end
        end,
    },
}

local childScripts = {
    button = {
        OnClick = function(self)
            local widget = self.widget
            widget.object.editbox:SetText("")
            self:Hide()

            if widget.callbacks.OnEditCleared then
                widget.callbacks.OnEditCleared(widget.object)
            end
        end,

        OnEnter = function(self)
            local frame = self.widget.object
            local button = frame:GetUserData("button")
            if button then
                self:GetNormalTexture():SetVertexColor(button.highlightColor:GetRGBA())
            end
        end,

        OnLeave = function(self)
            local frame = self.widget.object
            local button = frame:GetUserData("button")
            if button then
                self:GetNormalTexture():SetVertexColor(button.color:GetRGBA())
            end
        end,
    },
}

local scripts = {
    OnSizeChanged = function(self)
        local height = self.editbox:GetHeight() + (self:HasLabel() and (self.label:GetStringHeight() + 5) or 0)
        if self:GetHeight() ~= height then
            self:SetHeight(height)
        end
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 25)
        self:ApplyTemplate()
        self.button:Hide()
        self:SetAutoFocus(false)
        self:SetTextInsets()
        self:SetText("")
        self:SetLabel()
    end,

    ApplyTemplate = function(self, template)
        local label = CreateFromMixins(defaults.label, template and template.label or {})
        local icon = CreateFromMixins(defaults.icon, template and template.icon or {})
        local editbox = CreateFromMixins(defaults.editbox, template and template.editbox or {})
        local button = CreateFromMixins(defaults.button, template and template.button or {})

        private:SetFont(self.label, label)
        self.icon:SetVertexColor(icon.color:GetRGBA())
        private:SetFont(self.editbox, editbox)
        private:SetBackdrop(self.editbox, editbox)
        self.button:GetNormalTexture():SetVertexColor(button.color:GetRGBA())
        self:SetUserData("button", button)
    end,

    HasLabel = function(self)
        return private:strcheck(self.label:GetText())
    end,

    SetAnchors = function(self)
        local text = self.label:GetText()
        if private:strcheck(text) then
            self.label:Show()
            self.editbox:SetPoint("TOP", self.label, "BOTTOM", 0, -5)
        else
            self.label:Hide()
            self.editbox:SetPoint("TOP")
        end

        self.editbox:SetPoint("RIGHT")
        self.icon:SetPoint("LEFT", 4, 0)
        self.button:SetPoint("RIGHT", -4, 0)
        self:SetEditHeight(self.editbox:GetHeight())
    end,

    SetEditHeight = function(self, height)
        self.editbox:SetHeight(height)
        self.icon:SetSize(height / 2, height / 2)
        self.button:SetSize(height / 2, height / 2)
        self:SetHeight(height + (self:HasLabel() and (self.label:GetStringHeight() + 5) or 0))
        self:SetTextInsets()
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    SetSize = function(self, width, height)
        self:SetWidth(width)
        self:SetEditHeight(height)
    end,

    SetTextInsets = function(self, left, right, top, bottom)
        self.editbox:SetTextInsets((left or 6) + self.icon:GetWidth() + 4, (right or 6) + self.button:GetWidth() + 4, top or 6, bottom or 6)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetPoint("TOPLEFT")
    frame.label:SetPoint("TOPRIGHT")
    frame.label:SetJustifyH("LEFT")

    frame.editbox = CreateFrame("EditBox", nil, frame)
    frame.editbox = private:CreateTextures(frame.editbox)

    frame.icon = frame.editbox:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAtlas("common-search-magnifyingglass")

    frame.button = CreateFrame("Button", nil, frame.editbox)
    frame.button:SetNormalAtlas("common-search-clearbutton")
    frame.button:SetScript("OnClick", childScripts.button.OnClick)
    frame.button:SetScript("OnEnter", childScripts.button.OnEnter)
    frame.button:SetScript("OnLeave", childScripts.button.OnLeave)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        forbidden = forbidden,
    }

    frame.editbox.widget = widget
    frame.button.widget = widget

    private:Map(frame, frame.editbox, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
