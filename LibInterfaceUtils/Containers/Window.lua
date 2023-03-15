local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Window", 1
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
    OnUpdate = true,
}

local templates = {
    default = {
        content = {
            bgEnabled = false,
            bordersEnabled = false,
        },
        frame = {
            bgColor = private.assets.colors.elvBackdrop,
        },
        scrollBars = {
            vertical = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = {
                    enabled = true,
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.darker,
                },
            },
            horizontal = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = {
                    enabled = true,
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.darker,
                },
            },
        },
        title = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
        },
        titleBar = {
            bgColor = private.assets.colors.elvTransparent,
            padding = 4,
        },
    },
    transparent = {
        content = {
            bgEnabled = false,
            bordersEnabled = false,
        },
        frame = {
            bgColor = private.assets.colors.elvTransparent,
        },
        scrollBars = {
            vertical = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = {
                    enabled = false,
                },
            },
            horizontal = {
                track = {
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = {
                    enabled = false,
                },
            },
        },
        title = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
        },
        titleBar = {
            bgColor = private.assets.colors.elvTransparent,
            padding = 4,
        },
    },
}

local templatesMetatable = {
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
        self:SetFrameStrata("HIGH")
        self:ApplyTemplate("default")
        self:SetTitle()
    end,

    OnRelease = function(self)
        self.content:ReleaseChildren()
    end,

    AddChild = function(self, ...)
        return self.content:AddChild(...)
    end,

    ApplyTemplate = function(self, templateName, mixin)
        templateName = type(templateName) == "string" and templateName:lower() or templateName
        local template
        if type(templateName) == "table" then
            template = templateName
            local info = setmetatable(template, templatesMetatable)
        else
            template = templates[templateName or "default"] or templates.default
        end

        private:SetBackdrop(self, template.frame)
        private:SetBackdrop(self.titleBar, template.titleBar)
        private:SetFont(self.titleBar.title, template.title)
        private:SetBackdrop(self.content, template.content)
        self.content:SetScrollBars(template.scrollBars)

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
            self.resizer:Show()
        else
            self.resizer:Hide()
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
    end,

    SetDraggable = function(self, isDraggable, ...)
        self:EnableMouse(isDraggable or false)
        self:SetMovable(isDraggable or false)
        self:RegisterForDrag(...)
    end,

    SetLayout = function(self, ...)
        self.content:SetLayout(...)
    end,

    SetPadding = function(self, ...)
        self.content:SetPadding(...)
    end,

    SetSpacing = function(self, ...)
        self.content:SetSpacing(...)
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

    frame.resizer = CreateFrame("Button", nil, frame)
    frame.resizer:SetNormalTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-DOWN]])
    frame.resizer:SetHighlightTexture([[INTERFACE\CHATFRAME\UI-CHATIM-SIZEGRABBER-HIGHLIGHT]])
    frame.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.resizer:SetSize(16, 16)
    frame.resizer:EnableMouse(true)
    frame.resizer:SetScript("OnMouseDown", childScripts.resizer.OnMouseDown)
    frame.resizer:SetScript("OnMouseUp", childScripts.resizer.OnMouseUp)

    frame.content = lib:New("ScrollFrame")
    frame.content:SetParent(frame)
    frame.content:SetPoint("TOPLEFT", frame.titleBar, "BOTTOMLEFT", 5, 0)
    frame.content:SetPoint("BOTTOMRIGHT", -5, 5)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        forbidden = forbidden,
        registry = registry,
    }

    frame.titleBar.close.widget = widget
    frame.resizer.widget = widget

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
