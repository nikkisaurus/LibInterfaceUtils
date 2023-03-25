local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Window", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    default = {
        -- frame = {}, -- Uses defaultBackdrop
        titlebar = {
            enabled = true,
            texture = private.assets.blankTexture,
            texCoord = { 0, 1, 0, 1 },
            color = private.assets.colors.elvTransparent,
            padding = 4,
        },
        titleborder = {
            enabled = true,
            texture = private.assets.blankTexture,
            color = private.assets.colors.black,
            edgeSize = 1,
            inset = -1,
        },
    },
}

local childScripts = {
    close = {
        OnClick = function(self)
            local frame = self:GetParent()
            frame:Release()
        end,
    },

    resizer = {
        OnMouseDown = function(self)
            local frame = self:GetParent()
            if frame:IsResizable() then
                frame:StartSizing()
            end
        end,

        OnMouseUp = function(self)
            local frame = self:GetParent()
            if frame:IsResizable() then
                frame:StopMovingOrSizing()
            end
        end,
    },
}

local scripts = {
    OnDragStart = function(self)
        if not self:IsMovable() then
            return
        end
        self:StartMoving()
    end,

    OnDragStop = function(self)
        if not self:IsMovable() then
            return
        end
        self:StopMovingOrSizing()
    end,

    OnSizeChanged = function(self)
        self:DoLayoutDeferred()
    end,
}

local methods = {
    OnAcquire = function(self, ...)
        self:SetLayout()
        self:SetSpecialFrame()
        self:SetSize(300, 300)
        self:EnableResize(true)
        self:EnableMovable(true, true)
        self:ApplyTemplate()
        self:SetTitle()
        self:SetPadding(5, 5, 5, 5)
    end,

    ApplyTemplate = function(self, template, mixin)
        local t = self:Set("template", type(template) == "table" and CreateFromMixins(mixin or templates.default, template) or templates[tostring(template):lower()] or templates.default)

        private:ApplyBackdrop(self, t.frame)
        self:SkinTitlebar()
    end,

    EnableMovable = function(self, isEnabled, isClamped)
        self:SetMovable(isEnabled or false)
        self:SetClampedToScreen(isClamped or false)
    end,

    EnableResize = function(self, isEnabled, minWidth, minHeight, ...)
        if isEnabled then
            self:SetResizable(true)
            self:SetResizeBounds(minWidth or 300, minHeight or 300, ...)
            self.resizer:Show()
        else
            self:SetResizable(false)
            self.resizer:Hide()
        end
    end,

    GetAvailableHeight = function(self)
        return self.verticalBox:GetHeight()
    end,

    GetAvailableWidth = function(self)
        return self.verticalBox:GetWidth()
    end,

    MarkDirty = function(self, ...)
        self.content:SetSize(...)
        self.horizontalBox:SetSize(...)
    end,

    SetAnchors = function(self)
        local t = self:Get("template")

        self.titlebar:SetHeight(max(self.title:GetStringHeight() + (t.titlebar.padding * 2), 20))

        local closeSize = self.titlebar:GetHeight() - (t.titlebar.padding / 2)
        self.close:SetSize(closeSize, closeSize)
        self.close:SetPoint("RIGHT", self.titlebar, "RIGHT", -t.titlebar.padding, 0)

        self.title:SetPoint("TOPLEFT", self.titlebar, "TOPLEFT", t.titlebar.padding, -t.titlebar.padding)
        self.title:SetPoint("RIGHT", self.close, "LEFT", -t.titlebar.padding, 0)
        self.title:SetPoint("BOTTOM", self.titlebar, "BOTTOM", 0, t.titlebar.padding)
    end,

    SetPadding = function(self, left, right, top, bottom)
        self.padding.left = left or self.padding.left
        self.padding.right = right or self.padding.right
        self.padding.top = top or self.padding.top
        self.padding.bottom = bottom or self.padding.bottom
        self:SetAnchors()
    end,

    SetSpecialFrame = function(self, isSpecial)
        if isSpecial then
            tinsert(UISpecialFrames, self:GetName())
        else
            tDeleteItem(UISpecialFrames, self:GetName())
        end
    end,

    SetTitle = function(self, text)
        self.title:SetText(text or "")
        self:SetAnchors()
    end,

    SkinTitlebar = function(self)
        local t = self:Get("template")

        self.titlebar:SetTexture()
        self.titlebar:SetTexCoord(0, 1, 0, 1)
        self.titlebar:SetVertexColor(1, 1, 1, 1)

        if t.titlebar.enabled then
            self.titlebar:SetTexture(t.titlebar.texture)
            self.titlebar:SetTexCoord(unpack(t.titlebar.texCoord))
            self.titlebar:SetVertexColor(t.titlebar.color:GetRGBA())
        end

        self.titleborder:SetTexture()
        self.titleborder:SetVertexColor(1, 1, 1, 1)
        self.titleborder:SetHeight(0)
        self.titleborder:ClearAllPoints()
        self.titleborder:Hide()

        if t.titleborder.enabled then
            self.titleborder:SetTexture(t.titleborder.texture)
            self.titleborder:SetVertexColor(t.titleborder.color:GetRGBA())
            self.titleborder:SetHeight(PixelUtil.GetNearestPixelSize(t.titleborder.edgeSize, private.UIParent:GetEffectiveScale(), 1))
            self.titleborder:SetPoint("BOTTOMLEFT", self.titlebar, "BOTTOMLEFT", 0, t.titleborder.inset)
            self.titleborder:SetPoint("BOTTOMRIGHT", self.titlebar, "BOTTOMRIGHT", 0, t.titleborder.inset)
            self.titleborder:Show()
        end
    end,
}

local function creationFunc()
    local frame = private:Mixin(CreateFrame("Frame", private:GetObjectName(objectType), private.UIParent, "BackdropTemplate"), "Container", "UserData")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")

    frame.titlebar = frame:CreateTexture(nil, "BACKGROUND")
    frame.titlebar:SetPoint("TOPLEFT")
    frame.titlebar:SetPoint("TOPRIGHT")

    frame.titleborder = frame:CreateTexture(nil, "BORDER")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetAllPoints(frame.titlebar)

    frame.close = CreateFrame("Button", nil, frame)
    frame.close:SetNormalAtlas("PlayerDeadBlip")
    frame.close:SetHighlightAtlas("PlayerDeadBlip", "ADD")
    frame.close:SetScript("OnClick", childScripts.close.OnClick)

    frame.resizer = CreateFrame("Button", nil, frame)
    frame.resizer:SetNormalTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-DOWN]])
    frame.resizer:SetHighlightTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-HIGHLIGHT]])
    frame.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.resizer:SetSize(16, 16)
    frame.resizer:EnableMouse(true)
    frame.resizer:SetScript("OnMouseDown", childScripts.resizer.OnMouseDown)
    frame.resizer:SetScript("OnMouseUp", childScripts.resizer.OnMouseUp)

    frame.content = private:CreateScrollFrame(frame)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        forbidden = forbidden,
        registry = registry,
    }

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
