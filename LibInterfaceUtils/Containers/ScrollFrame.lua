local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "ScrollFrame", 1
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
        self:SetSize(500, 300)
        self:EnableBackdrop()
    end,

    OnLayoutFinished = function(self)
        self:SetScrollAnchors()
    end,

    EnableBackdrop = function(self, isEnabled, backdrop)
        defaults.backdrop.bgEnabled = isEnabled or false
        defaults.backdrop.bordersEnabled = isEnabled or false
        self:SetBackdrop(backdrop)
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

    ParentChild = function(self, child, parent)
        child:SetParent(self.content)
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self, CreateFromMixins(defaults.backdrop, backdrop or {}))
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
    frame.content:SetScript("OnMouseDown", childScripts.content.OnMouseDown)
    frame.content:SetScript("OnMouseUp", childScripts.content.OnMouseUp)

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

    frame.content.widget = widget
    frame.horizontalBox.widget = widget
    frame.verticalBox.widget = widget

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
