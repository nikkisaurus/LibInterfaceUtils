local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "EditBox", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    button = {
        disabled = {
            bgEnabled = false,
            bordersEnabled = false,
        },
        highlight = {
            bgEnabled = false,
            bordersEnabled = false,
        },
        normal = {
            bgEnabled = false,
            bordersEnabled = false,
            font = "GameFontHighlight",
            color = private.assets.colors.white,
        },
    },
    editbox = {
        bgColor = private.assets.colors.normal,
        font = "GameFontHighlight",
        color = private.assets.colors.white,
        justifyH = "LEFT",
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
            self.widget.object.button:Hide()
        end,
        OnEscapePressed = function(self)
            self:ClearFocus()
        end,
        OnSpacePressed = true,
        OnTabPressed = true,
        OnTextChanged = function(self, userInput)
            local frame = self.widget.object
            if userInput and frame:GetUserData("enableButton") then
                frame.button:Show()
            elseif not frame:GetUserData("enableButton") then
                frame.button:Hide()
            end
        end,
        OnTextSet = function(self)
            self.widget.object.button:Hide()
        end,
    },
}

local childScripts = {
    button = {
        OnClick = function(self)
            self.widget.object:Fire("OnEnterPressed")
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
        self:EnableButton(true)
        self:SetAutoFocus(false)
        self:SetTextInsets()
        self:SetText("")
        self:SetLabel()
    end,

    ApplyTemplate = function(self, template)
        local label = CreateFromMixins(defaults.label, template and template.label or {})
        local editbox = CreateFromMixins(defaults.editbox, template and template.editbox or {})
        local button = CreateFromMixins(defaults.button, template and template.button or {})

        private:SetFont(self.label, label)
        private:SetFont(self.editbox, editbox)
        private:SetBackdrop(self.editbox, editbox)
        self.button:ApplyTemplate(button)
    end,

    EnableButton = function(self, isEnabled)
        self:SetUserData("enableButton", isEnabled)
        self.button:Hide()
        self.button:SetPushedTextOffsets(0, 0)
        self:SetTextInsets()
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
        self.button:SetParent(self.editbox)
        self.button:SetPoint("TOPRIGHT")
        self:SetEditHeight(self.editbox:GetHeight())
    end,

    SetEditHeight = function(self, height)
        self.editbox:SetHeight(height)
        self.button:SetSize(height * 2, height)
        self:SetHeight(height + (self:HasLabel() and (self.label:GetHeight() + 5) or 0))
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
        self.editbox:SetTextInsets(left or 6, (right or 6) + (self:GetUserData("enableButton") and self.button:GetWidth() or 0), top or 6, bottom or 6)
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

    frame.button = lib:New("Button")
    frame.button:SetText(OKAY)
    frame.button:SetScript("OnClick", childScripts.button.OnClick)

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
