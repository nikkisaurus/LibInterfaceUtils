local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Frame", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local frame
local handlers, methods, protected, protectedScripts, scripts, templates

handlers = {
    OnAcquire = function(self, ...)
        -- Defaults
        self:ApplyTemplate("default")
        self:SetTitle()
        self:SetStatus()

        self:SetClampedToScreen(true)
        self:EnableMovable(true, "LeftButton")
        local w, h = GetPhysicalScreenSize()
        self:EnableResize(true, 300, 300, w * 0.8, h * 0.8)

        self:SetSize(300, 300)
        self:SetAnchors()
    end,

    OnRelease = function(self, ...)
        print("Released", ...)
    end,

    ApplyTemplate = function(self, templateName)
        local template = templates[templateName]
        assert(template, "Invalid argument for Frame:ApplyTemplate(template): template")

        -- Set frame background and borders
        protected.bg:SetColorTexture(template.bgColor:GetRGBA())
        private:DrawBorders(protected.borders, template.borderSize, template.borderColor)

        -- Set titleBar background and borders
        protected.titleBar.bg:SetColorTexture(template.titleBar.bgColor:GetRGBA())
        private:DrawBorders(protected.titleBar.borders, template.titleBar.borderSize, template.titleBar.borderColor)

        -- Set statusBar background and borders
        protected.statusBar.bg:SetColorTexture(template.statusBar.bgColor:GetRGBA())
        private:DrawBorders(protected.statusBar.borders, template.statusBar.borderSize, template.statusBar.borderColor)
        protected.statusBar.text:SetPoint("TOPLEFT", template.statusBar.padding, -template.statusBar.padding)
        protected.statusBar.text:SetPoint("RIGHT", protected.statusBar.resizer, "LEFT", -template.statusBar.padding, 0)
        protected.statusBar.text:SetPoint("BOTTOM", -template.statusBar.padding, template.statusBar.padding)

        self:SetUserData("template", template)
    end,

    EnableMovable = function(self, enabled, ...)
        self:EnableMouse(enabled or false)
        self:SetMovable(enabled or false)
        self:RegisterForDrag(...)
    end,

    EnableResize = function(self, enabled, minWidth, minHeight, maxWidth, maxHeight)
        self:SetResizable(enabled or false)
        if enabled then
            assert(type(minWidth) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): minWidth")
            assert(type(minHeight) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): minHeight")
            assert(type(maxWidth) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): maxWidth")
            assert(type(maxHeight) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): maxHeight")

            self:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
            protected.resizer:Show()
        else
            protected.resizer:Hide()
        end
    end,

    MarkDirty = function(self, usedWidth, height)
        if usedWidth and height then
            protected.content:SetSize(usedWidth, height)
            protected.horizontalBox:SetHeight(protected.content:GetHeight())
        end

        self:SetAnchors()
    end,

    ParentChild = function(self, child)
        child:SetParent(protected.content)
    end,

    SetAnchors = function(self)
        local horizontalBar = protected.horizontalBar
        local verticalBar = protected.verticalBar
        local verticalBox = protected.verticalBox

        protected.horizontalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
        verticalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

        if horizontalBar:HasScrollableExtent() then
            horizontalBar:Show()
            verticalBox:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 5)
            verticalBar:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 2)
        else
            horizontalBar:Hide()
            verticalBox:SetPoint("BOTTOM", protected.statusBar, "TOP", 0, 5)
            verticalBar:SetPoint("BOTTOM", protected.statusBar, "TOP", 0, 2)
        end

        if verticalBar:HasScrollableExtent() then
            verticalBar:Show()
            verticalBox:SetPoint("RIGHT", verticalBar, "LEFT", -5, 0)
        else
            verticalBar:Hide()
            verticalBox:SetPoint("RIGHT", -5, 0)
        end
    end,

    SetFullAnchor = function(self, child, height)
        child:SetPoint("TOPRIGHT", protected.verticalBox, "TOPRIGHT", 0, -height)
    end,

    SetStatus = function(self, text)
        protected.statusBar.text:SetText(text or "")
    end,

    SetTitle = function(self, text)
        local template = self:GetUserData("template")

        protected.titleBar.title:SetText(text or "")
        protected.titleBar:SetHeight(max(protected.titleBar.title:GetStringHeight() + (template.titleBar.padding * 2), 20))

        -- Set titleBar element points
        local size = protected.titleBar:GetHeight() - template.titleBar.padding
        protected.titleBar.close:SetSize(size, size)
        protected.titleBar.close:SetPoint("RIGHT", -template.titleBar.padding, 0)

        protected.titleBar.title:SetPoint("TOPLEFT", template.titleBar.padding, -template.titleBar.padding)
        protected.titleBar.title:SetPoint("RIGHT", protected.titleBar.close, "LEFT", -template.titleBar.padding, 0)
        protected.titleBar.title:SetPoint("BOTTOM", 0, template.titleBar.padding)
    end,
}

methods = {
    CreateFontString = true,
    -- CreateTexture = true,
    -- DisableDrawLayer = true,
    -- EnableDrawLayer = true,
    -- EnableKeyboard = true,
    -- EnableMouse = true,
    -- EnableMouseWheel = true,
    -- GetAttribute = true,
    -- GetBackdrop = true,
    -- GetBackdropBorderColor = true,
    -- GetBackdropColor = true,
    -- GetChildren = true,
    -- GetClampRectInsets = true,
    -- GetDepth = true,
    -- GetEffectiveAlpha = true,
    -- GetEffectiveDepth = true,
    -- GetEffectiveScale = true,
    -- GetFrameLevel = true,
    -- GetFrameStrata = true,
    -- GetFrameType = true,
    -- GetHitRectInsets = true,
    -- GetID = true,
    -- GetMaxResize = true,
    -- GetMinResize = true,
    -- GetNumChildren = true,
    -- GetNumRegions = true,
    -- GetRegions = true,
    -- GetScale = true,
    -- GetScript = true,
    -- GetTitleRegion = true,
    -- HasScript = true,
    -- HookScript = true,
    -- IgnoreDepth = true,
    -- IsClampedToScreen = true,
    -- IsEventRegistered = true,
    -- IsFrameType = true,
    -- IsIgnoringDepth = true,
    -- IsKeyboardEnabled = true,
    -- IsMouseEnabled = true,
    -- IsMouseWheelEnabled = true,
    -- IsMovable = true,
    -- IsResizable = true,
    -- IsToplevel = true,
    -- IsUserPlaced = true,
    -- Lower = true,
    -- Raise = true,
    -- RegisterAllEvents = true,
    -- RegisterEvent = true,
    -- RegisterForDrag = true,
    -- SetBackdrop = true,
    -- SetBackdropBorderColor = true,
    -- SetBackdropColor = true,
    -- SetClampedToScreen = true,
    -- SetClampRectInsets = true,
    -- SetDepth = true,
    -- SetFrameLevel = true,
    -- SetFrameStrata = true,
    -- SetHitRectInsets = true,
    -- SetID = true,
    -- SetMaxResize = true,
    -- SetMinResize = true,
    -- SetMovable = true,
    -- SetResizable = true,
    SetScale = true,
    -- SetScript = true,
    -- SetSize = false,
    -- SetToplevel = true,
    -- SetUserPlaced = true,
    -- StartMoving = true,
    -- StartSizing = false,
    -- StopMovingOrSizing = false,
    -- UnregisterAllEvents = true,
    -- UnregisterEvent = true,
}

protected = {}

protectedScripts = {
    close = {
        OnClick = function(self)
            frame:Release()
        end,
    },

    content = {
        OnMouseDown = function(self)
            frame:StartMoving()
        end,

        OnMouseUp = function(self)
            frame:StopMovingOrSizing()
        end,

        OnSizeChanged = function(self)
            protected.horizontalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
            protected.verticalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
        end,
    },

    horizontalBox = {
        OnMouseDown = function(self)
            frame:StartMoving()
        end,

        OnMouseUp = function(self)
            frame:StopMovingOrSizing()
        end,
    },

    resizer = {
        OnMouseDown = function(self)
            frame:StartSizing()
        end,
        OnMouseUp = function(self)
            frame:StopMovingOrSizing()
        end,
    },

    verticalBox = {
        OnMouseDown = function(self)
            frame:StartMoving()
        end,

        OnMouseUp = function(self)
            frame:StopMovingOrSizing()
        end,
    },
}

scripts = {
    OnDragStart = function(self)
        self:StartMoving()
    end,

    OnDragStop = function(self)
        self:StopMovingOrSizing()
    end,

    OnSizeChanged = function(self)
        self:SetAnchors()
    end,
}

templates = {
    default = {
        bgColor = private.assets.colors.backdrop,
        borderColor = private.assets.colors.black,
        borderSize = 1,
        statusBar = {
            bgColor = private.assets.colors.dimmedBackdrop,
            borderColor = private.assets.colors.black,
            borderSize = 1,
            padding = 4,
        },
        titleBar = {
            bgColor = private.assets.colors.dimmedBackdrop,
            borderColor = private.assets.colors.black,
            borderSize = 1,
            padding = 4,
        },
    },
    transparent = {
        bgColor = private.assets.colors.dimmedBackdrop,
        borderColor = private.assets.colors.black,
        borderSize = 1,
        statusBar = {
            bgColor = private.assets.colors.dimmedBackdrop,
            borderColor = private.assets.colors.black,
            borderSize = 1,
            padding = 4,
        },
        titleBar = {
            bgColor = private.assets.colors.dimmedBackdrop,
            borderColor = private.assets.colors.black,
            borderSize = 1,
            padding = 4,
        },
    },
}

local function creationFunc()
    frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame:SetFrameStrata("DIALOG")
    frame.overrideForbidden = true

    local bg, borders = private:CreateTexture(frame)
    bg:SetAllPoints(frame)

    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT")
    titleBar:SetPoint("TOPRIGHT")

    titleBar.bg, titleBar.borders = private:CreateTexture(titleBar)
    titleBar.bg:SetAllPoints(titleBar)

    titleBar.title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleBar.title:SetAllPoints(titleBar)

    titleBar.close = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")

    local statusBar = CreateFrame("Frame", nil, frame)
    statusBar:SetPoint("BOTTOMLEFT")
    statusBar:SetPoint("BOTTOMRIGHT")
    statusBar:SetHeight(20)

    statusBar.bg, statusBar.borders = private:CreateTexture(statusBar)
    statusBar.bg:SetAllPoints(statusBar)

    statusBar.resizer = CreateFrame("Button", nil, statusBar)
    statusBar.resizer:SetNormalTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-DOWN]])
    statusBar.resizer:SetHighlightTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-HIGHLIGHT]])
    statusBar.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
    statusBar.resizer:SetSize(16, 16)
    statusBar.resizer:EnableMouse(true)

    statusBar.text = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusBar.text:SetJustifyH("LEFT")

    local horizontalBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsHorizontalScrollBar")
    horizontalBar:SetPoint("BOTTOMLEFT", statusBar, "TOPLEFT", 2, 2)
    horizontalBar:SetPoint("BOTTOMRIGHT", statusBar, "TOPRIGHT", -2, 2)
    horizontalBar.Track.Thumb.Middle:SetTexture("Interface/buttons/white8x8")

    local horizontalBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    horizontalBox:SetPoint("TOP", titleBar, "BOTTOM", 0, -5)
    horizontalBox:SetPoint("LEFT", 5, 0)
    horizontalBox:SetPoint("RIGHT", verticalBar, "LEFT", -5, 0)
    horizontalBox:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 5)
    horizontalBox:SetScript("OnMouseWheel", nil)

    local content = CreateFrame("Frame", nil, horizontalBox, "ResizeLayoutFrame")
    content.scrollable = true

    local horizontalView = CreateScrollBoxLinearView()
    horizontalView:SetPanExtent(50)
    horizontalView:SetHorizontal(true)

    local verticalBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsVerticalScrollBar")
    verticalBar:SetPoint("TOP", titleBar, "BOTTOM", 0, -2)
    verticalBar:SetPoint("RIGHT", -2, 0)
    verticalBar:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 2)

    local verticalBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    verticalBox:SetPoint("TOP", titleBar, "BOTTOM", 0, -5)
    verticalBox:SetPoint("LEFT", 5, 0)
    verticalBox:SetPoint("RIGHT", verticalBar, "LEFT", -5, 0)
    verticalBox:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 5)

    horizontalBox:SetParent(verticalBox)
    horizontalBox:SetAllPoints(verticalBox)
    horizontalBox.scrollable = true

    local verticalView = CreateScrollBoxLinearView()
    verticalView:SetPanExtent(50)

    ScrollUtil.InitScrollBoxWithScrollBar(horizontalBox, horizontalBar, horizontalView)
    ScrollUtil.InitScrollBoxWithScrollBar(verticalBox, verticalBar, verticalView)

    protected.bg = bg
    protected.borders = borders
    protected.close = titleBar.close
    protected.content = content
    protected.horizontalBar = horizontalBar
    protected.horizontalBox = horizontalBox
    -- protected.horizontalView = horizontalView
    protected.resizer = statusBar.resizer
    protected.statusBar = statusBar
    protected.titleBar = titleBar
    protected.verticalBar = verticalBar
    protected.verticalBox = verticalBox
    -- protected.verticalView = verticalView

    for protectedObject, scripts in pairs(protectedScripts) do
        local object = protected[protectedObject]
        for script, handler in pairs(scripts) do
            object:SetScript(script, handler)
        end
    end

    return private:RegisterContainer(frame, objectType, version, handlers, methods, scripts)
end

private:RegisterObjectPool(objectType, creationFunc)
