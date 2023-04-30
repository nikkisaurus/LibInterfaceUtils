local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Frame", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    default = {
        titlebar = {
            enabled = true,
            texture = 1030961,
            texCoord = { 0, 1, 0, 1 },
            color = private.colors.elvTransparent,
            padding = 4,
        },
        titleborder = {
            enabled = true,
            texture = 1030961,
            color = private.colors.black,
            edgeSize = 1,
            inset = -1,
        },
        statusbar = {
            enabled = true,
            texture = 1030961,
            texCoord = { 0, 1, 0, 1 },
            color = private.colors.elvTransparent,
            padding = 4,
        },
        statusborder = {
            enabled = true,
            texture = 1030961,
            color = private.colors.black,
            edgeSize = 1,
            inset = -1,
        },
    },
}

local events = {
    OnAcquire = function(widget)
        widget:ApplyTemplate()
        widget:EnableMovable(true, true)
        widget:EnableResize(true)
        widget:SetSpecialFrame()
        widget:SetSize(300, 300)
        widget:SetTitle()
        widget:SetStatus()
    end,

    OnDragStart = function(widget, obj)
        if not obj:IsMovable() then
            return
        end
        obj:StartMoving()
    end,

    OnDragStop = function(widget, obj)
        if not obj:IsMovable() then
            return
        end
        obj:StopMovingOrSizing()
    end,
}

local methods = {
    ApplyTemplate = function(widget, obj, template, mixin)
        local t = widget:Set("template", type(template) == "table" and CreateFromMixins(mixin or templates.default, template) or templates[tostring(template):lower()] or templates.default)

        private:ApplyBackdrop(obj, t.frame)
        widget:SkinTitlebar()
        widget:SkinStatusbar()

        local anchors = {
            with = {
                CreateAnchor("TOP", obj.titlebar, "BOTTOM"),
                CreateAnchor("LEFT", obj, "LEFT"),
                CreateAnchor("RIGHT", obj.scrollBar, "LEFT", -4, 0),
                CreateAnchor("BOTTOM", obj.statusbar, "TOP"),
            },
            without = {
                CreateAnchor("TOP", obj.titlebar, "BOTTOM"),
                CreateAnchor("LEFT", obj, "LEFT"),
                CreateAnchor("RIGHT", obj, "RIGHT"),
                CreateAnchor("BOTTOM", obj.statusbar, "TOP"),
            },
        }

        ScrollUtil.AddManagedScrollBarVisibilityBehavior(obj.scrollBox, obj.scrollBar, anchors.with, anchors.without)
        private:SetScrollBarBackdrop(obj.scrollBar, t.scrollBar)
    end,

    EnableMovable = function(widget, obj, isEnabled, isClamped)
        obj:SetMovable(isEnabled or false)
        obj:SetClampedToScreen(isClamped or false)
    end,

    EnableResize = function(widget, obj, isEnabled, minWidth, minHeight, ...)
        if isEnabled then
            obj:SetResizable(true)
            obj:SetResizeBounds(minWidth or 300, minHeight or 300, ...)
            obj.resizer:Show()
        else
            obj:SetResizable(false)
            obj.resizer:Hide()
        end
    end,

    SetAnchors = function(widget, obj)
        local t = widget:Get("template")

        obj.titlebar:SetHeight(max(obj.title:GetStringHeight() + (t.titlebar.padding * 2), 20))
        obj.statusbar:SetHeight(max(obj.status:GetStringHeight() + (t.statusbar.padding * 2), 20))

        local closeSize = obj.titlebar:GetHeight() - (t.titlebar.padding / 2)
        obj.close:SetSize(closeSize, closeSize)
        obj.close:SetPoint("RIGHT", obj.titlebar, "RIGHT", -t.titlebar.padding, 0)

        obj.title:SetPoint("TOPLEFT", obj.titlebar, "TOPLEFT", t.titlebar.padding, -t.titlebar.padding)
        obj.title:SetPoint("RIGHT", obj.close, "LEFT", -t.titlebar.padding, 0)
        obj.title:SetPoint("BOTTOM", obj.titlebar, "BOTTOM", 0, t.titlebar.padding)

        obj.status:SetPoint("TOPLEFT", obj.statusbar, "TOPLEFT", t.statusbar.padding, -t.statusbar.padding)
        obj.status:SetPoint("RIGHT", obj.resizer, "LEFT", -t.statusbar.padding, 0)
        obj.status:SetPoint("BOTTOM", obj.statusbar, "BOTTOM", -t.statusbar.padding, t.statusbar.padding)
    end,

    SetSpecialFrame = function(widget, obj, isSpecial)
        if isSpecial then
            tinsert(UISpecialFrames, obj:GetName())
        else
            tDeleteItem(UISpecialFrames, obj:GetName())
        end
    end,

    SetStatus = function(widget, obj, text)
        obj.status:SetText(text or "")
        widget:SetAnchors()
    end,

    SetTitle = function(widget, obj, text)
        obj.title:SetText(text or "")
        widget:SetAnchors()
    end,

    SkinStatusbar = function(widget, obj)
        local t = widget:Get("template")

        obj.statusbar:SetTexture()
        obj.statusbar:SetTexCoord(0, 1, 0, 1)
        obj.statusbar:SetVertexColor(1, 1, 1, 1)

        if t.statusbar.enabled then
            obj.statusbar:SetTexture(t.statusbar.texture)
            obj.statusbar:SetTexCoord(unpack(t.statusbar.texCoord))
            obj.statusbar:SetVertexColor(t.statusbar.color:GetRGBA())
        end

        obj.statusborder:SetTexture()
        obj.statusborder:SetVertexColor(1, 1, 1, 1)
        obj.statusborder:SetHeight(0)
        obj.statusborder:ClearAllPoints()
        obj.statusborder:Hide()

        if t.statusborder.enabled then
            obj.statusborder:SetTexture(t.statusborder.texture)
            obj.statusborder:SetVertexColor(t.statusborder.color:GetRGBA())
            obj.statusborder:SetHeight(PixelUtil.GetNearestPixelSize(t.statusborder.edgeSize, private.UIParent:GetEffectiveScale(), 1))
            obj.statusborder:SetPoint("TOPLEFT", obj.statusbar, "TOPLEFT", 0, t.statusborder.inset)
            obj.statusborder:SetPoint("TOPRIGHT", obj.statusbar, "TOPRIGHT", 0, t.statusborder.inset)
            obj.statusborder:Show()
        end
    end,

    SkinTitlebar = function(widget, obj)
        local t = widget:Get("template")

        obj.titlebar:SetTexture()
        obj.titlebar:SetTexCoord(0, 1, 0, 1)
        obj.titlebar:SetVertexColor(1, 1, 1, 1)

        if t.titlebar.enabled then
            obj.titlebar:SetTexture(t.titlebar.texture)
            obj.titlebar:SetTexCoord(unpack(t.titlebar.texCoord))
            obj.titlebar:SetVertexColor(t.titlebar.color:GetRGBA())
        end

        obj.titleborder:SetTexture()
        obj.titleborder:SetVertexColor(1, 1, 1, 1)
        obj.titleborder:SetHeight(0)
        obj.titleborder:ClearAllPoints()
        obj.titleborder:Hide()

        if t.titleborder.enabled then
            obj.titleborder:SetTexture(t.titleborder.texture)
            obj.titleborder:SetVertexColor(t.titleborder.color:GetRGBA())
            obj.titleborder:SetHeight(PixelUtil.GetNearestPixelSize(t.titleborder.edgeSize, private.UIParent:GetEffectiveScale(), 1))
            obj.titleborder:SetPoint("BOTTOMLEFT", obj.titlebar, "BOTTOMLEFT", 0, t.titleborder.inset)
            obj.titleborder:SetPoint("BOTTOMRIGHT", obj.titlebar, "BOTTOMRIGHT", 0, t.titleborder.inset)
            obj.titleborder:Show()
        end
    end,
}

local childScripts = {
    close = {
        OnClick = function(self)
            local obj = self:GetParent()
            obj.widget:Release()
        end,
    },

    resizer = {
        OnMouseDown = function(self)
            local obj = self:GetParent()
            if obj:IsResizable() then
                obj:StartSizing()
            end
        end,

        OnMouseUp = function(self)
            local obj = self:GetParent()
            if obj:IsResizable() then
                obj:StopMovingOrSizing()
            end
        end,
    },
}

local function constructor()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), private.UIParent)
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
    frame.resizer:SetNormalTexture(386862)
    frame.resizer:SetHighlightTexture(386863)
    frame.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.resizer:SetSize(16, 16)
    frame.resizer:EnableMouse(true)
    frame.resizer:SetScript("OnMouseDown", childScripts.resizer.OnMouseDown)
    frame.resizer:SetScript("OnMouseUp", childScripts.resizer.OnMouseUp)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.status:SetJustifyH("LEFT")

    frame.scrollBar = CreateFrame("EventFrame", nil, frame, "LibInterfaceUtilsVerticalScrollBar")
    frame.scrollBar:SetPoint("TOPRIGHT", frame.titlebar, "BOTTOMRIGHT")
    frame.scrollBar:SetPoint("BOTTOMRIGHT", frame.statusbar, "TOPRIGHT")

    frame.scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")

    frame.scrollView = CreateScrollBoxLinearView()
    frame.scrollView:SetPanExtent(50)

    frame.content = CreateFrame("Frame", nil, frame.scrollBox, "ResizeLayoutFrame")
    frame.content:SetAllPoints(frame.scrollBox)
    frame.content.scrollable = true

    ScrollUtil.InitScrollBoxWithScrollBar(frame.scrollBox, frame.scrollBar, frame.scrollView)

    return private:RegisterContainer({ obj = frame, type = objectType, content = frame.content }, events, methods)
end

private:RegisterObjectPool(objectType, version, constructor)
