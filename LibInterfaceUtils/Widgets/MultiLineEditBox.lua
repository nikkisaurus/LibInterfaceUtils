local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "MultiLineEditBox", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local anchors = {
    with = function(frame)
        return {
            CreateAnchor("TOPLEFT", frame.container, "TOPLEFT"),
            CreateAnchor("RIGHT", frame.scrollBar, "LEFT", -3, 0),
            CreateAnchor("BOTTOM", frame.container, "BOTTOM"),
        }
    end,
    without = function(frame)
        return {
            CreateAnchor("TOPLEFT", frame.container, "TOPLEFT"),
            CreateAnchor("BOTTOMRIGHT", frame.container, "BOTTOMRIGHT"),
        }
    end,
}

local defaults = {
    button = {},
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
        OnEscapePressed = function(self)
            self:ClearFocus()
        end,
        OnSpacePressed = true,
        OnTabPressed = true,
        OnTextChanged = function(self, userInput)
            local frame = self.widget.object
            if userInput then
                frame.button:SetDisabled()
            end
        end,
        OnTextSet = function(self)
            self.widget.object.button:SetDisabled(true)
        end,
    },
}

local childScripts = {
    button = {
        OnClick = function(self)
            local widget = self.widget
            self:SetDisabled(true)

            if widget.callbacks.OnEnterPressed then
                widget.callbacks.OnEnterPressed(widget.object)
            end
        end,
    },
}

local scripts = {
    OnSizeChanged = function(self)
        local height = self.container:GetHeight() + (self:HasLabel() and (self.label:GetStringHeight() + 5) or 0) + self.button:GetHeight() + 5
        if self:GetHeight() ~= height then
            self:SetHeight(height)
        end
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 150)
        self:ApplyTemplate()
        self.button:SetDisabled(true)
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
        private:SetBackdrop(self.container, editbox)
        private:SetScrollBarBackdrop(self.scrollBar, template and template.scrollBar)
        self.button:ApplyTemplate(button)
    end,

    HasLabel = function(self)
        return private:strcheck(self.label:GetText())
    end,

    SetAnchors = function(self)
        local text = self.label:GetText()
        if private:strcheck(text) then
            self.label:Show()
            self.container:SetPoint("TOPLEFT", self.label, "BOTTOMLEFT", 0, -5)
        else
            self.label:Hide()
            self.container:SetPoint("TOPLEFT")
        end

        self.container:SetPoint("RIGHT")
        self:SetEditHeight(self.container:GetHeight())
        self.button:SetPoint("TOPLEFT", self.container, "BOTTOMLEFT", 0, -5)
    end,

    SetEditHeight = function(self, height)
        self.container:SetHeight(height)
        self:SetHeight(height + (self:HasLabel() and (self.label:GetStringHeight() + 5) or 0) + self.button:GetHeight() + 5)
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
        self.editbox:SetTextInsets(left or 6, right or 6, top or 6, bottom or 6)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetPoint("TOPLEFT")
    frame.label:SetPoint("TOPRIGHT")
    frame.label:SetJustifyH("LEFT")

    frame.container = CreateFrame("Frame", nil, frame, "ScrollingEditBoxTemplate")
    frame.container = private:CreateTextures(frame.container)
    frame.editbox = frame.container.ScrollBox.EditBox

    frame.scrollBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsVerticalScrollBar")
    frame.scrollBar:SetPoint("TOPRIGHT", frame.container, "TOPRIGHT")
    frame.scrollBar:SetPoint("BOTTOMRIGHT", frame.container, "BOTTOMRIGHT")

    ScrollUtil.RegisterScrollBoxWithScrollBar(frame.container.ScrollBox, frame.scrollBar)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(frame.container.ScrollBox, frame.scrollBar, anchors.with(frame), anchors.without(frame))

    frame.button = lib:New("Button")
    frame.button:SetParent(frame)
    frame.button:SetText(ACCEPT)
    frame.button:SetAutoWidth(true)
    frame.button:SetScript("OnClick", childScripts.button.OnClick)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        forbidden = forbidden,
    }

    frame.container.widget = widget
    frame.button.widget = widget

    private:Map(frame, frame.editbox, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
