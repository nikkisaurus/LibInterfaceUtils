local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Header", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    label = {
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        justifyH = "LEFT",
    },
}

local scripts = {
    OnSizeChanged = function(self)
        self:SetAnchors()
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 20)
        self:ApplyTemplate()
        self:SetText()
    end,

    ApplyTemplate = function(self, template)
        local label = CreateFromMixins(defaults.label, template or {})
        private:SetFont(self.label, label)

        self.left:SetColorTexture((label.color):GetRGBA())
        self.right:SetColorTexture((label.color):GetRGBA())
        self.bottom:SetColorTexture((label.color):GetRGBA())
    end,

    SetAnchors = function(self)
        local style = self:Get("style") or self.label:ClearAllPoints()
        self.left:ClearAllPoints()
        self.right:ClearAllPoints()
        self.bottom:ClearAllPoints()
        self.label:ClearAllPoints()

        self.label:SetWidth(min(self.label:GetStringWidth(), self:GetWidth() - 60))

        if style and style:lower() == "strikethrough" then
            self.label:SetPoint("CENTER")
            self.label:SetJustifyH("CENTER")
            self.label:SetJustifyV("MIDDLE")
            self.left:SetPoint("LEFT")
            self.left:SetPoint("RIGHT", self.label, "LEFT", -15, 0)
            self.left:SetHeight(PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1))
            self.right:SetPoint("RIGHT")
            self.right:SetPoint("LEFT", self.label, "RIGHT", 15, 0)
            self.right:SetHeight(PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1))
        else
            local pixelSize = PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1)
            self.label:SetPoint("TOPLEFT", 0, -5)
            self.label:SetJustifyH("LEFT")
            self.label:SetJustifyV("TOP")
            self.bottom:SetPoint("TOP", self.label, "BOTTOM", 0, -5)
            self.bottom:SetPoint("LEFT")
            self.bottom:SetPoint("RIGHT")
            self.bottom:SetHeight(pixelSize)
        end
        self:SetHeight(self.label:GetStringHeight() + 15)
    end,

    SetStyle = function(self, style)
        self:Set("style", style)
        self:SetAnchors()
    end,

    SetText = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    frame.left = frame:CreateTexture(nil, "BORDER")
    frame.right = frame:CreateTexture(nil, "BORDER")
    frame.bottom = frame:CreateTexture(nil, "BORDER")
    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
