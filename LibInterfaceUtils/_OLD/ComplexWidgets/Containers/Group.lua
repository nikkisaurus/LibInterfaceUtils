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

local templates = {
    default = {
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        justifyH = "LEFT",
        bg = {
            enabled = false,
        },
        borders = {
            enabled = false,
        },
    },
    bordered = {
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        justifyH = "LEFT",
        borders = {
            insets = {
                top = 0,
                left = 0,
                right = 0,
                bottom = 0,
            },
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

    ApplyTemplate = function(self, template, mixin)
        local t = self:Set("template", type(template) == "table" and CreateFromMixins(mixin or templates.default, template) or templates[tostring(template):lower()] or templates.default)

        private:SetFont(self.label, t)
        private:ApplyBackdrop(self.container, t)
    end,

    HasLabel = function(self)
        return private:strcheck(self.label:GetText())
    end,

    MarkDirty = function(self, usedWidth, usedHeight)
        self:SetHeight(usedHeight + (self:HasLabel() and (self.label:GetHeight() + 2) or 0) + self.padding.top + self.padding.bottom)
    end,

    SetLabel = function(self, text)
        self.label:SetText(text or "")

        if private:strcheck(text) then
            self.label:Show()
            self.container:SetPoint("TOP", self.label, "BOTTOM", 0, -2)
        else
            self.label:Hide()
            self.container:SetPoint("TOP")
        end
    end,

    SetPadding = function(self, left, right, top, bottom)
        self.padding.left = left or self.padding.left
        self.padding.right = right or self.padding.right
        self.padding.top = top or self.padding.top
        self.padding.bottom = bottom or self.padding.bottom

        self.content:SetPoint("TOPLEFT", self.padding.left or 5, -(self.padding.top or 5))
        self.content:SetPoint("BOTTOMRIGHT", -(self.padding.right or 5), -(self.padding.bottom or 5))
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame = private:Mixin(frame, "Container", "UserData")

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.label:SetPoint("TOPLEFT")
    frame.label:SetPoint("TOPRIGHT")
    frame.label:SetJustifyH("LEFT")

    frame.container = CreateFrame("Frame", nil, frame)
    frame.container:SetPoint("LEFT")
    frame.container:SetPoint("BOTTOMRIGHT")
    -- frame.container = private:CreateTextures(frame.container)
    -- frame.container:SetScript("OnEnter", childScripts.container.OnEnter)
    -- frame.container:SetScript("OnLeave", childScripts.container.OnLeave)
    -- frame.container:SetScript("OnMouseDown", childScripts.container.OnMouseDown)

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
