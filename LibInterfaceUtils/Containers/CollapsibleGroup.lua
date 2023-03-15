local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "CollapsibleGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    backdrop = {
        bgEnabled = false,
    },
    headerBackdrop = {
        highlightEnabled = true,
    },
}

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
    default = {
        header = { -- backdropTable
            bgColor = private.assets.colors.darker,
            highlightEnabled = true,
            highlightColor = private.assets.colors.dimmedFlair,
        },
        label = { -- fontTable
            font = "GameFontNormal",
            color = private.assets.colors.flair,
            highlightColor = private.assets.colors.white,
        },
        content = { -- backdropTable
            bgEnabled = false,
            bordersEnabled = false,
        },
    },
    bordered = {
        header = { -- backdropTable
            bgColor = private.assets.colors.darker,
            highlightEnabled = true,
            highlightColor = private.assets.colors.dimmedFlair,
        },
        label = { -- fontTable
            font = "GameFontNormal",
            color = private.assets.colors.flair,
            highlightColor = private.assets.colors.white,
        },
        content = { -- backdropTable
            bgEnabled = true,
            bordersEnabled = true,
        },
    },
}

local childScripts = {
    header = {
        OnClick = function(self)
            local frame = self.widget.object
            frame:Collapse(not frame:GetUserData("collapsed"))
        end,

        OnEnter = function(self)
            local frame = self.widget.object
            local template = frame:GetUserData("template")
            if template.label.highlightColor then
                frame.label:SetTextColor(template.label.highlightColor:GetRGBA())
            end
        end,

        OnLeave = function(self)
            local frame = self.widget.object
            local template = frame:GetUserData("template")
            if template.label.highlightColor then
                frame.label:SetTextColor(template.label.color:GetRGBA())
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
        self:SetLabel()
        self:Collapse()
    end,

    ApplyTemplate = function(self, templateName, mixin)
        templateName = type(templateName) == "string" and templateName:lower() or templateName
        local template
        if type(templateName) == "table" then
            template = CreateFromMixins(templates.default, templateName)
        else
            template = templates[templateName or "default"] or templates.default
        end

        private:SetBackdrop(self.header, template.header)
        private:SetFont(self.label, template.label)
        private:SetBackdrop(self.container, template.content)

        self:SetUserData("template", template)
    end,

    Collapse = function(self, collapsed)
        self:SetUserData("collapsed", collapsed)

        if collapsed then
            self.container:Hide()
        else
            self.container:Show()
        end

        local parent = self:GetUserData("parent")
        while parent do
            parent:DoLayout()
            parent = parent:GetUserData("parent")
        end
    end,

    MarkDirty = function(self, _, height)
        if not self:GetUserData("collapsed") then
            height = height + self:GetUserData("top") + self:GetUserData("bottom")
        end

        self.container:SetHeight(height)

        local canWrap = self.label:CanWordWrap()
        if canWrap then
            self.header:SetHeight(self.label:GetStringHeight() + 15)
        else
            self.header:SetHeight(20)
        end

        self:SetHeight(height + self.header:GetHeight())
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

    frame.label = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetPoint("LEFT", 5, 0)
    frame.label:SetPoint("RIGHT", -5, 0)
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
