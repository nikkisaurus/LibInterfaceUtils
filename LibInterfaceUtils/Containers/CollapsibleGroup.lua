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

local childScripts = {
    header = {
        OnClick = function(self)
            local frame = self.widget.object
            frame:Collapse(not frame:GetUserData("collapsed"))
        end,
    },
}

local scripts = {
    -- OnSizeChanged = function(self)
    --     self:DoLayout()
    -- end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(500, 300)
        self:EnableHeaderBackdrop(true)
        self:SetBackdrop()
        self:SetLabel()
        self:SetLabelFont(GameFontNormal)
        self:Collapse()
        self:SetPadding()
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
            local newParent = parent:GetUserData("parent")
            if newParent then
                parent = newParent
            else
                break
            end
        end

        if parent then
            parent:DoLayout()
        end
    end,

    EnableBackdrop = function(self, isEnabled, backdrop)
        defaults.backdrop.bgEnabled = isEnabled or false
        defaults.backdrop.bordersEnabled = isEnabled or false
        self:SetBackdrop(backdrop)
    end,

    EnableHeaderBackdrop = function(self, isEnabled, backdrop)
        defaults.headerBackdrop.bgEnabled = isEnabled or false
        defaults.headerBackdrop.bordersEnabled = isEnabled or false
        self:SetHeaderBackdrop(backdrop)
    end,

    GetAnchorX = function(self)
        return self.content
    end,

    GetAvailableHeight = function(self)
        return private:round(self.content:GetHeight())
    end,

    GetAvailableWidth = function(self)
        return private:round(self.content:GetWidth())
    end,

    MarkDirty = function(self, _, height)
        self:SetHeight(height + self.header:GetHeight() + (self:GetUserData("collapsed") and 0 or 9))
    end,

    ParentChild = function(self, child, parent)
        child:SetParent(self.content)
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self.container, CreateFromMixins(defaults.backdrop, backdrop or {}))
    end,

    SetHeaderBackdrop = function(self, backdrop)
        private:SetBackdrop(self.header, CreateFromMixins(defaults.headerBackdrop, backdrop or {}))
    end,

    SetLabel = function(self, text)
        self.header:SetText(text or "")
    end,

    SetLabelFont = function(self, fontObject, color)
        self.header:SetNormalFontObject(fontObject)
        self.header:GetFontString():SetTextColor((color or private.assets.colors.flair):GetRGBA())
        self.header:SetHeight(self.header:GetTextHeight() + 20)
    end,

    SetPadding = function(self, left, right, top, bottom)
        self.content:SetPoint("TOPLEFT", left or 5, -(top or 5))
        self.content:SetPoint("BOTTOMRIGHT", -(right or 5), -(bottom or 5))
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

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
