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

local childScripts = {
    content = {
        OnSizeChanged = function(self)
            local frame = self.widget.object
            frame:DoLayout()
        end,
    },
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(500, 300)
        self:EnableBackdrop()
        self:SetLabel()
        self:SetLabelFont(GameFontNormal)
    end,

    EnableBackdrop = function(self, isEnabled, backdrop)
        defaults.backdrop.bgEnabled = isEnabled or false
        defaults.backdrop.bordersEnabled = isEnabled or false
        self:SetBackdrop(backdrop)
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
        self:SetHeight(height + self.label:GetHeight() + 15)
    end,

    ParentChild = function(self, child, parent)
        child:SetParent(self.content)
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self.container, CreateFromMixins(defaults.backdrop, backdrop or {}))
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

    SetLabelFont = function(self, fontObject, color)
        self.label:SetFontObject(fontObject)
        self.label:SetTextColor((color or private.assets.colors.flair):GetRGBA())
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

    frame.content = CreateFrame("Frame", nil, frame.container)
    frame.content:SetPoint("TOPLEFT", 5, -5)
    frame.content:SetPoint("BOTTOMRIGHT", -5, -5)
    frame.content:SetScript("OnSizeChanged", childScripts.content.OnSizeChanged)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        registry = registry,
    }

    frame.content.widget = widget

    return private:RegisterContainer(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
