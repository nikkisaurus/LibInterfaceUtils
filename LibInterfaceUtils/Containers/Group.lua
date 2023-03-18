local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Group", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    backdrop = {
        bgEnabled = false,
        bordersEnabled = false,
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
        label = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
            justifyH = "LEFT",
        },
        content = {
            bgEnabled = false,
            bordersEnabled = false,
        },
    },
    bordered = {
        label = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
            justifyH = "LEFT",
        },
        content = {
            bgEnabled = true,
            bordersEnabled = true,
        },
    },
}

local childScripts = {
    container = {
        OnEnter = function(self)
            local frame = self.widget.object
            frame:Fire("OnEnter")
        end,

        OnLeave = function(self)
            local frame = self.widget.object
            frame:Fire("OnLeave")
        end,

        OnMouseDown = function(self)
            local frame = self.widget.object
            frame:Fire("OnMouseDown")
        end,
    },

    content = {
        OnSizeChanged = function(self)
            local frame = self.widget.object
            frame:DoLayoutDeferred()
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
    end,

    ApplyTemplate = function(self, templateName, mixin)
        templateName = type(templateName) == "string" and templateName:lower() or templateName
        local template
        if type(templateName) == "table" then
            template = CreateFromMixins(templates.default, templateName)
        else
            template = templates[templateName or "default"] or templates.default
        end

        private:SetFont(self.label, template.label)
        private:SetBackdrop(self.container, template.content)

        self:SetUserData("template", template)
    end,

    HasLabel = function(self)
        return private:strcheck(self.label:GetText())
    end,

    MarkDirty = function(self, usedWidth, usedHeight)
        self:SetHeight(usedHeight + (self:HasLabel() and (self.label:GetHeight() + 5) or 0) + (self:GetUserData("top")) + (self:GetUserData("bottom")))
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")

        if private:strcheck(text) then
            self.label:Show()
            self.container:SetPoint("TOP", self.label, "BOTTOM", 0, -5)
        else
            self.label:Hide()
            self.container:SetPoint("TOP")
        end
    end,

    SetPadding = function(self, left, right, top, bottom)
        self:SetUserData("left", left or 5)
        self:SetUserData("right", right or 5)
        self:SetUserData("top", top or 5)
        self:SetUserData("bottom", bottom or 5)
        self.content:SetPoint("TOPLEFT", left or 5, -(top or 5))
        self.content:SetPoint("BOTTOMRIGHT", -(right or 5), -(bottom or 5))
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetPoint("TOPLEFT")
    frame.label:SetPoint("TOPRIGHT")
    frame.label:SetJustifyH("LEFT")

    frame.container = CreateFrame("Frame", nil, frame)
    frame.container:SetPoint("LEFT")
    frame.container:SetPoint("BOTTOMRIGHT")
    frame.container = private:CreateTextures(frame.container)
    frame.container:SetScript("OnEnter", childScripts.container.OnEnter)
    frame.container:SetScript("OnLeave", childScripts.container.OnLeave)
    frame.container:SetScript("OnMouseDown", childScripts.container.OnMouseDown)

    frame.content = CreateFrame("Frame", nil, frame.container)
    frame.content:SetScript("OnSizeChanged", childScripts.content.OnSizeChanged)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        registry = registry,
    }

    frame.container.widget = widget
    frame.content.widget = widget

    return private:RegisterContainer(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
