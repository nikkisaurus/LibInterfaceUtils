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

local methods = {
    OnAcquire = function(self)
        self:SetSize(500, 300)
        self:EnableHeaderBackdrop(true)
        self:SetBackdrop()
        self:SetLabel()
        self:SetLabelFont(GameFontNormal)
    end,

    Collapse = function(self, collapsed)
        self:SetUserData("collapsed", collapsed)
        if collapsed then
            self.container:Hide()
        else
            self.container:Show()
        end

        self:DoLayout()

        local parent = self:GetUserData("parent")
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

    Fill = function(self, child)
        local xOffset = child:GetUserData("xOffset")
        local yOffset = child:GetUserData("yOffset")
        local xFill = child:GetUserData("xFill")
        local yFill = child:GetUserData("yFill")

        child:SetPoint("TOPLEFT", self.content, "TOPLEFT", xOffset, yOffset)
        self:FillX(child)
        self:FillY(child)
    end,

    FillX = function(self, child)
        local x = child:GetUserData("xFill") or 0
        child:SetPoint("RIGHT", x, 0)
        return self.content:GetWidth() + x
    end,

    FillY = function(self, child)
        local y = child:GetUserData("yFill") or 0
        child:SetPoint("BOTTOM", 0, y)
    end,

    GetAvailableHeight = function(self)
        return self.content:GetHeight()
    end,

    GetAvailableWidth = function(self)
        return self.content:GetWidth()
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
    frame.content:SetPoint("TOPLEFT", 5, -5)
    frame.content:SetPoint("BOTTOMRIGHT", -5, -5)

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
