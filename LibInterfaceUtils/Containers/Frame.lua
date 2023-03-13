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

    content = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StartMoving()
            end
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StopMovingOrSizing()
            end
        end,
    },

    horizontalBox = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StartMoving()
            end
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StopMovingOrSizing()
            end
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

    verticalBox = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StartMoving()
            end
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
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

    OnUpdate = function(self)
        -- Using OnUpdate instead of OnSizeChanged to throttle the DoLayout calls and provide a more responsive experience
        local w, h = self:GetSize()
        w = private:round(w)
        h = private:round(h)
        local width = self:GetUserData("width")
        local height = self:GetUserData("height")
        if not width or not height or w ~= width or h ~= height or self:GetUserData("scrollUpdate") then
            self:SetUserData("width", w)
            self:SetUserData("height", h)
            self:DoLayout()
            -- scrollUpdate needs to be here for after scrollbars change in order to update the layout, since widths and heights will change
            -- very important that this is set to false AFTER DoLayout, or it'll continue to run every frame
            self:SetUserData("scrollUpdate", false)
        end
    end,
}

local methods = {
    OnAcquire = function(self, ...)
        self:SetClampedToScreen(true)
        self:SetDraggable(true, "LeftButton")
        local w, h = GetPhysicalScreenSize()
        self:EnableResize(true, 300, 300, w * 0.8, h * 0.8)
        self:SetFrameStrata("DIALOG")

        self:SetSize(300, 300)
        self:ApplyTemplate("transparent")
        self:SetTitle()
        self:SetStatus()
    end,

    OnLayoutFinished = function(self)
        self:SetScrollAnchors()
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

        self.verticalBar.Track.Thumb.Main:SetTexture(template.scrollBars.vertical.track.texture)
        self.verticalBar.Track.Thumb.Main:SetVertexColor(template.scrollBars.vertical.track.color:GetRGBA())
        self.verticalBar.Back.Texture:SetVertexColor(template.scrollBars.vertical.track.color:GetRGBA())
        self.verticalBar.Forward.Texture:SetVertexColor(template.scrollBars.vertical.track.color:GetRGBA())
        if template.scrollBars.vertical.background.enabled then
            self.verticalBar.Background.Main:SetTexture(template.scrollBars.vertical.background.texture)
            self.verticalBar.Background.Main:SetVertexColor(template.scrollBars.vertical.background.color:GetRGBA())
            self.verticalBar.Background.Main:Show()
        else
            self.verticalBar.Background.Main:Hide()
        end

        self.horizontalBar.Track.Thumb.Main:SetTexture(template.scrollBars.horizontal.track.texture)
        self.horizontalBar.Track.Thumb.Main:SetVertexColor(template.scrollBars.horizontal.track.color:GetRGBA())
        self.horizontalBar.Back.Texture:SetVertexColor(template.scrollBars.horizontal.track.color:GetRGBA())
        self.horizontalBar.Forward.Texture:SetVertexColor(template.scrollBars.horizontal.track.color:GetRGBA())
        if template.scrollBars.horizontal.background.enabled then
            self.horizontalBar.Background.Main:SetTexture(template.scrollBars.horizontal.background.texture)
            self.horizontalBar.Background.Main:SetVertexColor(template.scrollBars.horizontal.background.color:GetRGBA())
            self.horizontalBar.Background.Main:Show()
        else
            self.horizontalBar.Background.Main:Hide()
        end

        self:SetUserData("template", template)
        self:SetAnchors()
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

    Fill = function(self, child)
        local xOffset = child:GetUserData("xOffset")
        local yOffset = child:GetUserData("yOffset")
        local xFill = child:GetUserData("xFill")
        local yFill = child:GetUserData("yFill")

        child:SetParent(self.verticalBox)
        child:SetPoint("TOPLEFT", xOffset, yOffset)
        child:SetPoint("BOTTOMRIGHT", xFill, yFill)
    end,

    FillX = function(self, child)
        local x = child:GetUserData("xFill") or 0
        child:SetPoint("RIGHT", self.verticalBox, "RIGHT", x, 0)
        return self.verticalBox:GetWidth() + x
    end,

    FillY = function(self, child)
        local y = child:GetUserData("yFill") or 0
        child:SetPoint("BOTTOM", self.verticalBox, "BOTTOM", 0, y)
    end,

    GetAnchorX = function(self)
        return self.verticalBox
    end,

    GetAnchorY = function(self)
        return self.verticalBox
    end,

    GetAvailableHeight = function(self)
        return private:round(self.verticalBox:GetHeight())
    end,

    GetAvailableWidth = function(self)
        return private:round(self.verticalBox:GetWidth())
    end,

    MarkDirty = function(self, usedWidth, usedHeight)
        self.content:SetSize(usedWidth, usedHeight)
        self.horizontalBox:SetSize(usedWidth, usedHeight)
    end,

    ParentChild = function(self, child, parent)
        child:SetParent(self.content)
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

    SetScrollAnchors = function(self)
        local content = self.content
        local horizontalBar = self.horizontalBar
        local verticalBar = self.verticalBar
        local verticalBox = self.verticalBox
        local statusBar = self.statusBar

        self.horizontalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
        verticalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

        if private:round(content:GetWidth()) > private:round(verticalBox:GetWidth()) then
            horizontalBar:Show()
            verticalBox:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 5)
            verticalBar:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 2)
        else
            horizontalBar:Hide()
            verticalBox:SetPoint("BOTTOM", statusBar, "TOP", 0, 5)
            verticalBar:SetPoint("BOTTOM", statusBar, "TOP", 0, 2)
        end

        if private:round(content:GetHeight()) > private:round(verticalBox:GetHeight()) then
            verticalBar:Show()
            verticalBox:SetPoint("RIGHT", verticalBar, "LEFT", -5, 0)
        else
            verticalBar:Hide()
            verticalBox:SetPoint("RIGHT", -5, 0)
        end

        self:SetUserData("scrollUpdate", true)
    end,

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
    frame.titleBar = CreateFrame("Frame", nil, frame)
    frame.titleBar:SetPoint("TOPLEFT")
    frame.titleBar:SetPoint("TOPRIGHT")
    frame.titleBar.frame = frame

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

    frame.horizontalBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsHorizontalScrollBar")
    frame.horizontalBar:SetPoint("BOTTOMLEFT", frame.statusBar, "TOPLEFT", 2, 2)
    frame.horizontalBar:SetPoint("BOTTOMRIGHT", frame.statusBar, "TOPRIGHT", -2, 2)

    frame.horizontalBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    frame.horizontalBox:SetPoint("TOP", frame.titleBar, "BOTTOM", 0, -5)
    frame.horizontalBox:SetPoint("LEFT", 5, 0)
    frame.horizontalBox:SetPoint("RIGHT", verticalBar, "LEFT", -5, 0)
    frame.horizontalBox:SetScript("OnMouseWheel", nil)
    frame.horizontalBox:SetScript("OnMouseDown", childScripts.horizontalBox.OnMouseDown)
    frame.horizontalBox:SetScript("OnMouseUp", childScripts.horizontalBox.OnMouseUp)

    frame.content = CreateFrame("Frame", nil, frame.horizontalBox, "ResizeLayoutFrame")
    frame.content.scrollable = true
    frame.content:SetScript("OnMouseDown", childScripts.content.OnMouseDown)
    frame.content:SetScript("OnMouseUp", childScripts.content.OnMouseUp)

    frame.horizontalView = CreateScrollBoxLinearView()
    frame.horizontalView:SetPanExtent(50)
    frame.horizontalView:SetHorizontal(true)

    frame.verticalBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsVerticalScrollBar")
    frame.verticalBar:SetPoint("TOP", frame.titleBar, "BOTTOM", 0, -2)
    frame.verticalBar:SetPoint("RIGHT", -2, 0)
    frame.verticalBar:SetPoint("BOTTOM", frame.horizontalBar, "TOP", 0, 2)

    frame.verticalBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    frame.verticalBox:SetPoint("TOP", frame.titleBar, "BOTTOM", 0, -5)
    frame.verticalBox:SetPoint("LEFT", 5, 0)
    frame.verticalBox:SetPoint("RIGHT", frame.verticalBar, "LEFT", -5, 0)
    frame.verticalBox:SetPoint("BOTTOM", frame.horizontalBar, "TOP", 0, 5)
    frame.verticalBox:SetScript("OnMouseDown", childScripts.verticalBox.OnMouseDown)
    frame.verticalBox:SetScript("OnMouseUp", childScripts.verticalBox.OnMouseUp)

    frame.horizontalBox:SetParent(frame.verticalBox)
    frame.horizontalBox:SetAllPoints(frame.verticalBox)
    frame.horizontalBox.scrollable = true

    frame.verticalView = CreateScrollBoxLinearView()
    frame.verticalView:SetPanExtent(50)

    ScrollUtil.InitScrollBoxWithScrollBar(frame.horizontalBox, frame.horizontalBar, frame.horizontalView)
    ScrollUtil.InitScrollBoxWithScrollBar(frame.verticalBox, frame.verticalBar, frame.verticalView)

    frame = private:CreateTextures(frame)
    frame.titleBar = private:CreateTextures(frame.titleBar)
    frame.statusBar = private:CreateTextures(frame.statusBar)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        forbidden = forbidden,
        registry = registry,
    }

    frame.titleBar.close.widget = widget
    frame.content.widget = widget
    frame.horizontalBox.widget = widget
    frame.statusBar.resizer.widget = widget
    frame.verticalBox.widget = widget

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
