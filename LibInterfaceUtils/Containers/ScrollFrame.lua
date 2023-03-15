local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "ScrollFrame", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    default = {
        frame = { -- backdropTable
            bgEnabled = false,
            bordersEnabled = false,
        },
        scrollBars = {
            vertical = {
                track = { -- scrollBarTable
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = { -- scrollBarTable
                    enabled = true,
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.darker,
                },
            },
            horizontal = {
                track = { -- scrollBarTable
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = { -- scrollBarTable
                    enabled = true,
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.darker,
                },
            },
        },
    },
    bordered = {
        frame = { -- backdropTable
            bgEnabled = true,
            bordersEnabled = true,
        },
        scrollBars = {
            vertical = {
                track = { -- scrollBarTable
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = { -- scrollBarTable
                    enabled = true,
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.darker,
                },
            },
            horizontal = {
                track = { -- scrollBarTable
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.dimmedWhite,
                },
                background = { -- scrollBarTable
                    enabled = true,
                    texture = private.assets.blankTexture,
                    color = private.assets.colors.darker,
                },
            },
        },
    },
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

local childScripts = {
    horizontalBox = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StartMoving()
            end

            local parent = frame:GetUserData("parent")
            if parent then
                parent:Fire("OnDragStart")
            end
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StopMovingOrSizing()
            end

            local parent = frame:GetUserData("parent")
            if parent then
                parent:Fire("OnDragStop")
            end
        end,
    },

    verticalBox = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StartMoving()
            end

            local parent = frame:GetUserData("parent")
            if parent then
                parent:Fire("OnDragStart")
            end
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            if frame:IsMovable() then
                frame:StopMovingOrSizing()
            end

            local parent = frame:GetUserData("parent")
            if parent then
                parent:Fire("OnDragStop")
            end
        end,
    },
}

local scripts = {
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
    OnAcquire = function(self)
        self:SetLayout()
        self:SetSize(500, 300)
        self:ApplyTemplate("default")
    end,

    ApplyTemplate = function(self, templateName, mixin)
        templateName = type(templateName) == "string" and templateName:lower() or templateName or templateName
        local template
        if type(templateName) == "table" then
            template = CreateFromMixins(templates.default, templateName)
        else
            template = templates[templateName or "default"] or templates.default
        end

        private:SetBackdrop(self, template.frame)
        self:SetScrollBars(template.scrollBars)

        self:SetUserData("template", template)
    end,

    OnLayoutFinished = function(self)
        self:SetScrollAnchors()
    end,

    GetAnchorX = function(self)
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

    SetScrollAnchors = function(self)
        local content = self.content
        local horizontalBar = self.horizontalBar
        local verticalBar = self.verticalBar
        local verticalBox = self.verticalBox

        self.horizontalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
        verticalBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

        if private:round(content:GetWidth()) > private:round(verticalBox:GetWidth()) then
            horizontalBar:Show()
            verticalBox:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 5)
            verticalBar:SetPoint("BOTTOM", horizontalBar, "TOP", 0, 2)
        else
            horizontalBar:Hide()
            verticalBox:SetPoint("BOTTOM", 0, 5)
            verticalBar:SetPoint("BOTTOM", 0, 2)
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

    SetScrollBars = function(self, template)
        self.verticalBar.Track.Thumb.Main:SetTexture(template.vertical.track.texture)
        self.verticalBar.Track.Thumb.Main:SetVertexColor(template.vertical.track.color:GetRGBA())
        self.verticalBar.Back.Texture:SetVertexColor(template.vertical.track.color:GetRGBA())
        self.verticalBar.Forward.Texture:SetVertexColor(template.vertical.track.color:GetRGBA())
        if template.vertical.background.enabled then
            self.verticalBar.Background.Main:SetTexture(template.vertical.background.texture)
            self.verticalBar.Background.Main:SetVertexColor(template.vertical.background.color:GetRGBA())
            self.verticalBar.Background.Main:Show()
        else
            self.verticalBar.Background.Main:Hide()
        end

        self.horizontalBar.Track.Thumb.Main:SetTexture(template.horizontal.track.texture)
        self.horizontalBar.Track.Thumb.Main:SetVertexColor(template.horizontal.track.color:GetRGBA())
        self.horizontalBar.Back.Texture:SetVertexColor(template.horizontal.track.color:GetRGBA())
        self.horizontalBar.Forward.Texture:SetVertexColor(template.horizontal.track.color:GetRGBA())
        if template.horizontal.background.enabled then
            self.horizontalBar.Background.Main:SetTexture(template.horizontal.background.texture)
            self.horizontalBar.Background.Main:SetVertexColor(template.horizontal.background.color:GetRGBA())
            self.horizontalBar.Background.Main:Show()
        else
            self.horizontalBar.Background.Main:Hide()
        end
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame = private:CreateTextures(frame)

    frame.horizontalBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsHorizontalScrollBar")
    frame.horizontalBar:SetPoint("BOTTOMLEFT", 2, 2)
    frame.horizontalBar:SetPoint("BOTTOMRIGHT", -2, 2)

    frame.horizontalBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    frame.horizontalBox:SetPoint("TOP", 0, -5)
    frame.horizontalBox:SetPoint("LEFT", 5, 0)
    frame.horizontalBox:SetPoint("RIGHT", verticalBar, "LEFT", -5, 0)
    frame.horizontalBox:SetScript("OnMouseWheel", nil)
    frame.horizontalBox:SetScript("OnMouseDown", childScripts.horizontalBox.OnMouseDown)
    frame.horizontalBox:SetScript("OnMouseUp", childScripts.horizontalBox.OnMouseUp)

    frame.content = CreateFrame("Frame", nil, frame.horizontalBox, "ResizeLayoutFrame")
    frame.content.scrollable = true

    frame.horizontalView = CreateScrollBoxLinearView()
    frame.horizontalView:SetPanExtent(50)
    frame.horizontalView:SetHorizontal(true)

    frame.verticalBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsVerticalScrollBar")
    frame.verticalBar:SetPoint("TOP", 0, -2)
    frame.verticalBar:SetPoint("RIGHT", -2, 0)
    frame.verticalBar:SetPoint("BOTTOM", frame.horizontalBar, "TOP", 0, 2)

    frame.verticalBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    frame.verticalBox:SetPoint("TOP", 0, -5)
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

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        registry = registry,
    }

    frame.horizontalBox.widget = widget
    frame.verticalBox.widget = widget

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
