local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Frame", 1
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
        statusbar = {
            enabled = true,
            texture = private.assets.blankTexture,
            texCoord = { 0, 1, 0, 1 },
            color = private.assets.colors.elvTransparent,
            padding = 4,
        },
        statusborder = {
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
        self:SetStatus()
        self:SetPadding(5, 5, 5, 5)

        -- local usedWidth = 0
        -- local usedHeight = 0
        -- for i = 1, 50 do
        --     local frame = CreateFrame("Frame")
        --     frame:SetSize(20, 20)
        --     -- private:ApplyBackdrop(frame)
        --     tinsert(self.frames, frame)

        --     local test = frame:CreateTexture(nil, "BACKGROUND")
        --     test:SetAllPoints(frame)
        --     test:SetColorTexture(CreateColor(fastrandom(), fastrandom(), fastrandom(), 1):GetRGBA())

        --     local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        --     label:SetText(i .. " In irure cupidatat laborum occaecat reprehenderit qui duis do officia voluptate excepteur.")
        --     label:SetAllPoints(frame)
        --     -- usedWidth = max(usedWidth, label:GetWidth())
        --     -- usedHeight = usedHeight + label:GetHeight()
        -- end

        -- print(self.content.Layout, self.content.frames)
        -- local extent = self.verticalView:Layout()
        -- print(extent)

        -- -- self.content:SetHeight(extent)
        -- self.horizontalBox:SetHeight(extent)
        -- self.verticalBox:Layout()

        -- local layoutFunction = function(index, frame, offset)
        --     local indent = self:GetElementIndent(frame)
        --     local setPoint = self:IsHorizontal() and ScrollBoxViewUtil.SetHorizontalPoint or ScrollBoxViewUtil.SetVerticalPoint
        --     return setPoint(frame, offset, indent, scrollTarget)
        -- end

        -- local frames = self.frames
        -- local frameCount = frames and #frames or 0
        -- if frameCount == 0 then
        --     return 0
        -- end

        -- local spacing = 0 -- self:GetSpacing()
        -- -- local scrollTarget = self:GetScrollTarget()
        -- -- local frameLevelCounter = CreateFrameLevelCounter(self:GetFrameLevelPolicy(), scrollTarget:GetFrameLevel(), frameCount)

        -- local total = 0
        -- local offset = 0
        -- for index, frame in ipairs(frames) do
        --     local extent = layoutFunction(index, frame, offset, scrollTarget)
        --     offset = offset + extent + spacing
        --     total = total + extent

        --     -- if frameLevelCounter then
        --     --     frame:SetFrameLevel(frameLevelCounter())
        --     -- end
        -- end

        -- local spacingTotal = math.max(0, frameCount - 1) * spacing
        -- local extentTotal = total + spacingTotal
        -- -- return extentTotal;
        -- self:MarkDirty(usedWidth, usedHeight)
    end,

    ApplyTemplate = function(self, template, mixin)
        local t = self:Set("template", type(template) == "table" and CreateFromMixins(mixin or templates.default) or templates[tostring(template):lower()] or templates.default)

        private:ApplyBackdrop(self, t.frame)
        self:SkinTitlebar()
        self:SkinStatusbar()
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

    MarkDirty = function(self, ...)
        self.content:SetSize(...)
        self.horizontalBox:SetSize(...)
    end,

    SetAnchors = function(self)
        local t = self:Get("template")

        self.titlebar:SetHeight(max(self.title:GetStringHeight() + (t.titlebar.padding * 2), 20))
        self.statusbar:SetHeight(max(self.status:GetStringHeight() + (t.statusbar.padding * 2), 20))

        local closeSize = self.titlebar:GetHeight() - (t.titlebar.padding / 2)
        self.close:SetSize(closeSize, closeSize)
        self.close:SetPoint("RIGHT", self.titlebar, "RIGHT", -t.titlebar.padding, 0)

        self.title:SetPoint("TOPLEFT", self.titlebar, "TOPLEFT", t.titlebar.padding, -t.titlebar.padding)
        self.title:SetPoint("RIGHT", self.close, "LEFT", -t.titlebar.padding, 0)
        self.title:SetPoint("BOTTOM", self.titlebar, "BOTTOM", 0, t.titlebar.padding)

        self.status:SetPoint("TOPLEFT", self.statusbar, "TOPLEFT", t.statusbar.padding, -t.statusbar.padding)
        self.status:SetPoint("RIGHT", self.resizer, "LEFT", -t.statusbar.padding, 0)
        self.status:SetPoint("BOTTOM", self.statusbar, "BOTTOM", -t.statusbar.padding, t.statusbar.padding)
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

    SetStatus = function(self, text)
        self.status:SetText(text or "")
        self:SetAnchors()
    end,

    SetTitle = function(self, text)
        self.title:SetText(text or "")
        self:SetAnchors()
    end,

    SkinStatusbar = function(self)
        local t = self:Get("template")

        self.statusbar:SetTexture()
        self.statusbar:SetTexCoord(0, 1, 0, 1)
        self.statusbar:SetVertexColor(1, 1, 1, 1)

        if t.statusbar.enabled then
            self.statusbar:SetTexture(t.statusbar.texture)
            self.statusbar:SetTexCoord(unpack(t.statusbar.texCoord))
            self.statusbar:SetVertexColor(t.statusbar.color:GetRGBA())
        end

        self.statusborder:SetTexture()
        self.statusborder:SetVertexColor(1, 1, 1, 1)
        self.statusborder:SetHeight(0)
        self.statusborder:ClearAllPoints()
        self.statusborder:Hide()

        if t.statusborder.enabled then
            self.statusborder:SetTexture(t.statusborder.texture)
            self.statusborder:SetVertexColor(t.statusborder.color:GetRGBA())
            self.statusborder:SetHeight(PixelUtil.GetNearestPixelSize(t.statusborder.edgeSize, private.UIParent:GetEffectiveScale(), 1))
            self.statusborder:SetPoint("TOPLEFT", self.statusbar, "TOPLEFT", 0, t.statusborder.inset)
            self.statusborder:SetPoint("TOPRIGHT", self.statusbar, "TOPRIGHT", 0, t.statusborder.inset)
            self.statusborder:Show()
        end
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
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), private.UIParent, "BackdropTemplate")
    private:Mixin(frame, "Container", "UserData")
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

    frame.statusbar = frame:CreateTexture(nil, "BACKGROUND")
    frame.statusbar:SetPoint("BOTTOMLEFT")
    frame.statusbar:SetPoint("BOTTOMRIGHT")
    frame.statusbar:SetHeight(20)

    frame.statusborder = frame:CreateTexture(nil, "BORDER")

    frame.resizer = CreateFrame("Button", nil, frame)
    frame.resizer:SetNormalTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-DOWN]])
    frame.resizer:SetHighlightTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-HIGHLIGHT]])
    frame.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.resizer:SetSize(16, 16)
    frame.resizer:EnableMouse(true)
    frame.resizer:SetScript("OnMouseDown", childScripts.resizer.OnMouseDown)
    frame.resizer:SetScript("OnMouseUp", childScripts.resizer.OnMouseUp)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.status:SetJustifyH("LEFT")

    frame.content = private:CreateScrollFrame(frame)
    frame.scrollable = true

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
