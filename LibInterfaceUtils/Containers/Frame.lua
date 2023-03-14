local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Frame", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local forbidden = {
    CreateFontString = true,
    RegisterAllEvents = true,
    RegisterEvent = true,
    SetBackdrop = true,
    SetBackdropBorderColor = true,
    SetBackdropColor = true,
    SetScale = true,
    SetScript = true,
    UnregisterAllEvents = true,
    UnregisterEvent = true,
}

local registry = {
    OnDragStart = true,
    OnDragStop = true,
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
        frame = {
            bgColor = private.assets.colors.elvBackdrop,
        },
        statusBar = {
            bgColor = private.assets.colors.elvTransparent,
            padding = 4,
        },
        titleBar = {
            bgColor = private.assets.colors.elvTransparent,
            padding = 4,
        },
        scrollBars = {
            vertical = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.lightWhite,
                },
                background = {
                    texture = false,
                    color = private.assets.colors.lightWhite,
                },
            },
            horizontal = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedBlack,
                },
                background = {
                    texture = false,
                    color = private.assets.colors.dimmedBlack,
                },
            },
        },
    },
    transparent = {
        frame = {
            bgColor = private.assets.colors.elvTransparent,
        },
        statusBar = {
            bgColor = private.assets.colors.elvTransparent,
            padding = 4,
        },
        titleBar = {
            bgColor = private.assets.colors.elvTransparent,
            padding = 4,
        },
        scrollBars = {
            vertical = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.bright,
                },
                background = {
                    enabled = false,
                },
            },
            horizontal = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.bright,
                },
                background = {
                    enabled = false,
                },
            },
        },
    },
}

local templateMetaTable = {
    __index = templates.default,
}

local childScripts = {
    close = {
        OnClick = function(self)
            local frame = self.widget.object
            frame:Release()
        end,
    },

    resizer = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsResizable() then
                frame:StartSizing()
            end
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            if frame:IsResizable() then
                frame:StopMovingOrSizing()
            end
        end,
    },
}

local scripts = {
    OnDragStart = function(self)
        self:StartMoving()
    end,

    OnDragStop = function(self)
        self:StopMovingOrSizing()
    end,
}

local methods = {
    OnAcquire = function(self, ...)
        local w, h = GetPhysicalScreenSize()
        self:SetLayout()
        self:SetSize(300, 300)
        self:EnableResize(true, 300, 300, w * 0.8, h * 0.8)
        self:SetDraggable(true, "LeftButton")
        self:SetClampedToScreen(true)
        self:SetFrameStrata("DIALOG")
        self:ApplyTemplate("default")
        self:SetTitle()
        self:SetStatus()
    end,

    OnRelease = function(self)
        self.content:ReleaseChildren()
    end,

    AddChild = function(self, ...)
        return self.content:AddChild(...)
    end,

    ApplyTemplate = function(self, templateName, mixin)
        local template
        if type(templateName) == "table" then
            template = templateName
            local info = setmetatable(template, templateMetaTable)
        else
            template = templates[templateName]
        end

        private:SetBackdrop(self, template.frame)
        private:SetBackdrop(self.statusBar, template.statusBar)
        private:SetBackdrop(self.titleBar, template.titleBar)

        -- TODO redo templates and implement scrollbar customization on scrollFrame container
        -- self.verticalBar.Track.Thumb.Main:SetTexture(template.scrollBars.vertical.track.texture)
        -- self.verticalBar.Track.Thumb.Main:SetVertexColor(template.scrollBars.vertical.track.color:GetRGBA())
        -- self.verticalBar.Back.Texture:SetVertexColor(template.scrollBars.vertical.track.color:GetRGBA())
        -- self.verticalBar.Forward.Texture:SetVertexColor(template.scrollBars.vertical.track.color:GetRGBA())
        -- if template.scrollBars.vertical.background.enabled then
        --     self.verticalBar.Background.Main:SetTexture(template.scrollBars.vertical.background.texture)
        --     self.verticalBar.Background.Main:SetVertexColor(template.scrollBars.vertical.background.color:GetRGBA())
        --     self.verticalBar.Background.Main:Show()
        -- else
        --     self.verticalBar.Background.Main:Hide()
        -- end

        -- self.horizontalBar.Track.Thumb.Main:SetTexture(template.scrollBars.horizontal.track.texture)
        -- self.horizontalBar.Track.Thumb.Main:SetVertexColor(template.scrollBars.horizontal.track.color:GetRGBA())
        -- self.horizontalBar.Back.Texture:SetVertexColor(template.scrollBars.horizontal.track.color:GetRGBA())
        -- self.horizontalBar.Forward.Texture:SetVertexColor(template.scrollBars.horizontal.track.color:GetRGBA())
        -- if template.scrollBars.horizontal.background.enabled then
        --     self.horizontalBar.Background.Main:SetTexture(template.scrollBars.horizontal.background.texture)
        --     self.horizontalBar.Background.Main:SetVertexColor(template.scrollBars.horizontal.background.color:GetRGBA())
        --     self.horizontalBar.Background.Main:Show()
        -- else
        --     self.horizontalBar.Background.Main:Hide()
        -- end

        self:SetUserData("template", template)
        self:SetAnchors()
    end,

    DoLayout = function(self, ...)
        return self.content:DoLayout(...)
    end,

    EnableResize = function(self, enabled, minWidth, minHeight, maxWidth, maxHeight)
        self:SetResizable(enabled or false)

        if enabled then
            assert(type(minWidth) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): minWidth")
            assert(type(minHeight) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): minHeight")
            assert(type(maxWidth) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): maxWidth")
            assert(type(maxHeight) == "number", "Invalid argument for Frame:EnableResize(enabled, minWidth, minHeight, maxWidth, maxHeight): maxHeight")

            self:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
            self.statusBar.resizer:Show()
        else
            self.statusBar.resizer:Hide()
        end
    end,

    GetAnchorX = function(self)
        return self.content:GetAnchorX()
    end,

    GetAvailableHeight = function(self)
        return self.content:GetAvailableHeight()
    end,

    GetAvailableWidth = function(self)
        return self.content:GetAvailableWidth()
    end,

    MarkDirty = function(self, ...)
        self.content:MarkDirty(...)
    end,

    New = function(self, ...)
        return self.content:New(...)
    end,

    ParentChild = function(self, ...)
        self.content:ParentChild(...)
    end,

    ReleaseChildren = function(self)
        self.content:ReleaseChildren()
    end,

    RemoveChild = function(self, ...)
        self.content:RemoveChild(...)
    end,

    SetAnchors = function(self)
        local template = self:GetUserData("template")

        self.titleBar:SetHeight(max(self.titleBar.title:GetStringHeight() + (template.titleBar.padding * 2), 20))

        local closeSize = self.titleBar:GetHeight() - (template.titleBar.padding / 2)
        self.titleBar.close:SetSize(closeSize, closeSize)
        self.titleBar.close:SetPoint("RIGHT", -template.titleBar.padding, 0)

        self.titleBar.title:SetPoint("TOPLEFT", template.titleBar.padding, -template.titleBar.padding)
        self.titleBar.title:SetPoint("RIGHT", self.titleBar.close, "LEFT", -template.titleBar.padding, 0)
        self.titleBar.title:SetPoint("BOTTOM", 0, template.titleBar.padding)

        self.statusBar.text:SetPoint("TOPLEFT", template.statusBar.padding, -template.statusBar.padding)
        self.statusBar.text:SetPoint("RIGHT", self.statusBar.resizer, "LEFT", -template.statusBar.padding, 0)
        self.statusBar.text:SetPoint("BOTTOM", -template.statusBar.padding, template.statusBar.padding)
    end,

    SetDraggable = function(self, isDraggable, ...)
        self:EnableMouse(isDraggable or false)
        self:SetMovable(isDraggable or false)
        self:RegisterForDrag(...)
    end,

    -- !
    -- SetLayout = function(self, ...)
    --     self.content:SetLayout(...)
    -- end,

    -- SetPadding = function(self, ...)
    --     self.content:SetPadding(...)
    -- end,
    -- !

    SetStatus = function(self, text)
        self.statusBar.text:SetText(text or "")
    end,

    SetTitle = function(self, text)
        self.titleBar.title:SetText(text or "")
        self:SetAnchors()
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame = private:CreateTextures(frame)

    frame.titleBar = CreateFrame("Frame", nil, frame)
    frame.titleBar:SetPoint("TOPLEFT")
    frame.titleBar:SetPoint("TOPRIGHT")
    frame.titleBar = private:CreateTextures(frame.titleBar)

    frame.titleBar.title = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.titleBar.title:SetAllPoints(frame.titleBar)

    frame.titleBar.close = CreateFrame("Button", nil, frame.titleBar)
    frame.titleBar.close:SetNormalAtlas("PlayerDeadBlip")
    frame.titleBar.close:SetHighlightAtlas("PlayerDeadBlip", "ADD")
    frame.titleBar.close:SetScript("OnClick", childScripts.close.OnClick)

    frame.statusBar = CreateFrame("Frame", nil, frame)
    frame.statusBar:SetPoint("BOTTOMLEFT")
    frame.statusBar:SetPoint("BOTTOMRIGHT")
    frame.statusBar:SetHeight(20)
    frame.statusBar = private:CreateTextures(frame.statusBar)

    frame.statusBar.resizer = CreateFrame("Button", nil, frame.statusBar)
    frame.statusBar.resizer:SetNormalTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-DOWN]])
    frame.statusBar.resizer:SetHighlightTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-HIGHLIGHT]])
    frame.statusBar.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.statusBar.resizer:SetSize(16, 16)
    frame.statusBar.resizer:EnableMouse(true)
    frame.statusBar.resizer:SetScript("OnMouseDown", childScripts.resizer.OnMouseDown)
    frame.statusBar.resizer:SetScript("OnMouseUp", childScripts.resizer.OnMouseUp)

    frame.statusBar.text = frame.statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.statusBar.text:SetJustifyH("LEFT")

    frame.content = lib:New("ScrollFrame")
    frame.content:SetParent(frame)
    frame.content:SetPoint("TOPLEFT", frame.titleBar, "BOTTOMLEFT", 5, -5)
    frame.content:SetPoint("BOTTOMRIGHT", frame.statusBar, "TOPRIGHT", -5, 5)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        forbidden = forbidden,
        registry = registry,
    }

    frame.titleBar.close.widget = widget
    frame.statusBar.resizer.widget = widget

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
