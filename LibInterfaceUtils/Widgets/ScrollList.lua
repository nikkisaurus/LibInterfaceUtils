local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "ScrollList", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    bordered = {
        frame = {
            bgEnabled = true,
            bordersEnabled = true,
        },
    },
    default = {
        frame = {
            bgEnabled = false,
            bordersEnabled = false,
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
    OnSizeChanged = function(self)
        self.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(500, 300)
        self:ApplyTemplate("default")
        self:SetResizable(false)
    end,

    OnRelease = function(self)
        self.scrollBox:Flush()
        self:Reset()
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
        private:SetScrollBarBackdrop(self.scrollBar, template.scrollBars and template.scrollBars.vertical)

        self:SetUserData("template", template)
    end,

    GetVerticalScroll = function(self)
        return self.scrollBar:GetScrollPercentage()
    end,

    Initialize = function(self, extent, initializer, template)
        if type(extent) == "function" then
            self.scrollView:SetElementExtentCalculator(extent)
        else
            self.scrollView:SetElementExtent(extent or 20)
        end

        self.scrollView:SetElementInitializer(template or "Frame", initializer)
    end,

    Reset = function(self)
        self.scrollView:SetElementExtent(20)
        self.scrollView:SetElementInitializer("Frame", nil)
        self.scrollBox:SetView(self.scrollView)
    end,

    SetDataProvider = function(self, callback)
        local DataProvider = CreateDataProvider()
        callback(DataProvider)
        self.scrollBox:SetDataProvider(DataProvider)

        return DataProvider
    end,

    SetScrollBars = function(self, template)
        self.scrollBar.Track.Thumb.Main:SetTexture(template.vertical.track.texture)
        self.scrollBar.Track.Thumb.Main:SetVertexColor(template.vertical.track.color:GetRGBA())
        self.scrollBar.Back.Texture:SetVertexColor(template.vertical.track.color:GetRGBA())
        self.scrollBar.Forward.Texture:SetVertexColor(template.vertical.track.color:GetRGBA())
        if template.vertical.background.enabled then
            self.scrollBar.Background.Main:SetTexture(template.vertical.background.texture)
            self.scrollBar.Background.Main:SetVertexColor(template.vertical.background.color:GetRGBA())
            self.scrollBar.Background.Main:Show()
        else
            self.scrollBar.Background.Main:Hide()
        end
    end,

    SetVerticalScroll = function(self, percentage)
        self.scrollBar:SetScrollPercentage(percentage)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame = private:CreateTextures(frame)

    frame.scrollBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsVerticalScrollBar")
    frame.scrollBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, 0)
    frame.scrollBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)

    frame.scrollBox = CreateFrame("Frame", nil, frame, "WoWScrollBoxList")

    frame.scrollView = CreateScrollBoxListLinearView()

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", frame, "TOPLEFT", 5, -5),
        CreateAnchor("BOTTOMRIGHT", frame.scrollBar, "BOTTOMLEFT", -5, 5),
    }

    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", frame, "TOPLEFT", 5, -5),
        CreateAnchor("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5),
    }

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(frame.scrollBox, frame.scrollBar, anchorsWithBar, anchorsWithoutBar)
    ScrollUtil.InitScrollBoxListWithScrollBar(frame.scrollBox, frame.scrollBar, frame.scrollView)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
