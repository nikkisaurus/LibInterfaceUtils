local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

private.UIParent = _G["LiuUIParent"] or CreateFrame("Frame", "LiuUIParent", UIParent)
private.UIParent:SetAllPoints(UIParent)
private.UIParent:SetFrameLevel(0)
private.UIParent:RegisterEvent("UI_SCALE_CHANGED")
private.UIParent:SetScript("OnEvent", function(self, event)
    local res = GetCVar("gxWindowedResolution")
    if res then
        local _, h = string.match(res, "(%d+)x(%d+)")
        self:SetScale((768 / h) / self:GetScale())
    end
end)

private.assets = {
    blankTexture = [[INTERFACE\BUTTONS\WHITE8X8]],
    colors = {
        darkest = CreateColor(0.025, 0.025, 0.025, 1),
        darker = CreateColor(0.05, 0.05, 0.05, 1),
        dark = CreateColor(0.1, 0.1, 0.1, 1),
        normal = CreateColor(0.15, 0.15, 0.15, 1),
        light = CreateColor(0.2, 0.2, 0.2, 1),
        lighter = CreateColor(0.25, 0.25, 0.25, 1),
        lightest = CreateColor(0.3, 0.3, 0.3, 1),
        bright = CreateColor(0.75, 0.75, 0.75, 1),

        dimmedBlack = CreateColor(0, 0, 0, 0.25),
        lightBlack = CreateColor(0, 0, 0, 0.5),
        black = CreateColor(0, 0, 0, 1),

        dimmedWhite = CreateColor(1, 1, 1, 0.25),
        lightWhite = CreateColor(1, 1, 1, 0.5),
        white = CreateColor(1, 1, 1, 1),

        red = CreateColor(1, 0, 0, 1),
        green = CreateColor(0, 1, 0, 1),

        -- dimmedClass = CreateColor(r, g, b, 0.25),
        -- lightClass = CreateColor(r, g, b, 0.5),
        -- class = CreateColor(r, g, b, 1),

        dimmedFlair = CreateColor(1, 0.82, 0, 0.25),
        lightFlair = CreateColor(1, 0.82, 0, 0.5),
        flair = CreateColor(1, 0.82, 0, 1),

        elvBackdrop = CreateColor(26 / 255, 26 / 255, 26 / 255, 1),
        elvTransparent = CreateColor(15 / 255, 15 / 255, 15 / 255, 0.8),

        highlight = CreateColor(0.1, 0.1, 0.1, 0.5),
    },
}

private.points = {
    TOP = { "BOTTOM", 0, -1, -1 },
    TOPLEFT = { "TOPRIGHT", 1, 0, -1 },
    TOPRIGHT = { "TOPLEFT", -1, 0, -1 },
    LEFT = { "RIGHT", 1, 0, -1 },
    RIGHT = { "LEFT", -1, 0, -1 },
    BOTTOMLEFT = { "BOTTOMRIGHT", 1, 0, 1 },
    BOTTOMRIGHT = { "BOTTOMLEFT", -1, 0, 1 },
    BOTTOM = { "TOP", 0, 1, 1 },
}

function private:CreateTextures(parent)
    parent.bg = parent:CreateTexture(nil, "BACKGROUND")
    parent.bg:SetAllPoints(parent)

    parent.borders = {}

    parent.borders.top = parent:CreateTexture(nil, "BORDER")
    parent.borders.top:SetPoint("TOPLEFT")
    parent.borders.top:SetPoint("TOPRIGHT")

    parent.borders.left = parent:CreateTexture(nil, "BORDER")
    parent.borders.left:SetPoint("TOPLEFT")
    parent.borders.left:SetPoint("BOTTOMLEFT")

    parent.borders.right = parent:CreateTexture(nil, "BORDER")
    parent.borders.right:SetPoint("TOPRIGHT")
    parent.borders.right:SetPoint("BOTTOMRIGHT")

    parent.borders.bottom = parent:CreateTexture(nil, "BORDER")
    parent.borders.bottom:SetPoint("BOTTOMLEFT")
    parent.borders.bottom:SetPoint("BOTTOMRIGHT")

    parent.highlight = parent:CreateTexture(nil, "OVERLAY")
    parent.highlight:SetAllPoints(parent)
    parent.highlight:Hide()

    return parent
end

local defaultBackdrop = {
    bg = {
        enabled = true,
        atlas = false,
        texture = private.assets.blankTexture,
        texCoord = { 0, 1, 0, 1 },
        color = private.assets.colors.elvTransparent,
    },
    borders = {
        enabled = true,
        left = true,
        right = true,
        top = true,
        bottom = true,
        texture = private.assets.blankTexture,
        color = private.assets.colors.black,
        edgeFile = false,
        tile = true,
        tileSize = 1,
        edgeSize = 1,
        insets = {
            left = -1,
            right = 1,
            top = 1,
            bottom = -1,
        },
    },
}

function private:ApplyBackdrop(parent, backdrop)
    local bg = type(backdrop) == "table" and type(backdrop.bg) == "table" and backdrop.bg
    bg = setmetatable(bg or {}, { __index = defaultBackdrop.bg })
    local borders = type(backdrop) == "table" and type(backdrop.borders) == "table" and backdrop.borders
    borders = setmetatable(borders or {}, { __index = defaultBackdrop.borders })
    borders.insets = type(backdrop) == "table" and type(backdrop.borders) == "table" and type(backdrop.borders.insets) == "table" and backdrop.borders.insets
    borders.insets = setmetatable(borders.insets or {}, { __index = defaultBackdrop.borders.insets })

    -- assert(parent.bg, "ApplyBackdrop: parent is missing .bg texture.")
    -- assert(parent.borders, "ApplyBackdrop: parent is missing .borders texture.")
    if not parent.bg or not parent.borders then
        parent = private:CreateBackdrop(parent)
    end

    if bg.enabled then
        if bg.atlas then
            parent.bg:SetAtlas(bg.atlas)
        else
            parent.bg:SetTexture(bg.texture)
        end
        parent.bg:SetVertexColor(bg.color:GetRGBA())
    else
        parent.bg:SetTexture()
        parent.bg:SetVertexColor(1, 1, 1, 1)
    end

    parent.bg:SetTexCoord(unpack(bg.texCoord))

    private:DrawBorders(parent, borders)
end

function private:CreateBackdrop(parent)
    parent.bg = parent:CreateTexture(nil, "BACKGROUND")
    parent.bg:SetAllPoints(parent)

    parent.borders = {}

    parent.borders.top = parent:CreateTexture(nil, "BORDER")
    parent.borders.top:SetPoint("TOPLEFT")
    parent.borders.top:SetPoint("TOPRIGHT")

    parent.borders.left = parent:CreateTexture(nil, "BORDER")
    parent.borders.left:SetPoint("TOPLEFT")
    parent.borders.left:SetPoint("BOTTOMLEFT")

    parent.borders.right = parent:CreateTexture(nil, "BORDER")
    parent.borders.right:SetPoint("TOPRIGHT")
    parent.borders.right:SetPoint("BOTTOMRIGHT")

    parent.borders.bottom = parent:CreateTexture(nil, "BORDER")
    parent.borders.bottom:SetPoint("BOTTOMLEFT")
    parent.borders.bottom:SetPoint("BOTTOMRIGHT")

    return parent
end

function private:ResetBorders(parent)
    if parent.SetBackdrop then
        parent:SetBackdropBorderColor(1, 1, 1, 1)
        parent:ClearBackdrop()
    end

    for id, border in pairs(parent.borders) do
        border:SetTexture()
        border:SetVertexColor(1, 1, 1, 1)
        border:SetHeight(0)
        border:SetWidth(0)
        border:ClearAllPoints()
        border:Hide()
    end
end

function private:DrawBorders(parent, info)
    private:ResetBorders(parent)

    if info.edgeFile and parent.SetBackdrop then
        parent:SetBackdrop({
            edgeFile = info.edgeFile,
            tile = info.tile,
            tileSize = info.tileSize,
            edgeSize = info.edgeSize,
            insets = info.insets,
        })

        parent:SetBackdropBorderColor(info.color:GetRGBA())

        return
    end

    for id, border in pairs(parent.borders) do
        if info.enabled and info[id] then
            border:SetTexture(info.texture)
            border:SetVertexColor(info.color:GetRGBA())

            local size = PixelUtil.GetNearestPixelSize(info.edgeSize, private.UIParent:GetEffectiveScale(), 1)
            local inset = info.insets[id]
            local offset = abs(inset)

            if id == "top" or id == "bottom" then
                border:SetHeight(size)
                border:SetPoint("LEFT", -offset, 0)
                border:SetPoint("RIGHT", offset, 0)
                border:SetPoint(id:upper(), 0, inset)
            elseif id == "left" or id == "right" then
                border:SetWidth(size)
                border:SetPoint("TOP", 0, offset)
                border:SetPoint("BOTTOM", 0, -offset)
                border:SetPoint(id:upper(), inset, 0)
            end

            border:Show()
        end
    end
end

function private:GetPixel(size)
    return PixelUtil.GetNearestPixelSize(size, UIParent:GetEffectiveScale(), 1)
end

function private:ParseValue(value, ...)
    if type(value) == "function" then
        return value(...)
    else
        return value
    end
end

function private:round(num, decimals, roundDown)
    if roundDown then
        local power = 10 ^ decimals
        return math.floor(num * power) / power
    else
        return tonumber((("%%.%df"):format(decimals)):format(num))
    end
end

local defaultBackdrop = {
    bgEnabled = true,
    bgAtlas = false,
    bgTexCoord = { 0, 1, 0, 1 },
    bgTexture = private.assets.blankTexture,
    bgColor = private.assets.colors.elvTransparent,

    bordersEnabled = true,
    bordersTexture = private.assets.blankTexture,
    bordersColor = private.assets.colors.black,
    bordersSize = 1,

    highlightEnabled = false,
    highlightAtlas = false,
    highlightTexCoord = { 0, 1, 0, 1 },
    highlightTexture = private.assets.blankTexture,
    highlightColor = private.assets.colors.dimmedWhite,
    highlightBlendMode = "ADD",
}

local backdropMetatable = {
    __index = defaultBackdrop,
}

function private:SetBackdrop(object, backdrop)
    local info = setmetatable(backdrop or {}, backdropMetatable)

    if object.bg then
        if info.bgEnabled then
            if info.bgAtlas then
                object.bg:SetAtlas(info.bgAtlas)
            else
                object.bg:SetTexture(info.bgTexture)
            end
            object.bg:SetVertexColor(info.bgColor:GetRGBA())
        else
            object.bg:SetTexture()
            object.bg:SetVertexColor(1, 1, 1, 1)
        end

        object.bg:SetTexCoord(unpack(info.bgTexCoord))
    end

    if object.borders then
        if info.bordersEnabled then
            private:DrawBorders(object.borders, info.bordersTexture, info.bordersColor, info.bordersSize)
        else
            private:ResetBorders(object.borders)
        end
    end

    if object.highlight then
        if info.highlightEnabled then
            if info.highlightAtlas then
                object.highlight:SetAtlas(info.highlightAtlas)
            else
                object.highlight:SetTexture(info.highlightTexture)
            end
            object.highlight:SetVertexColor(info.highlightColor:GetRGBA())
            object.highlight:SetBlendMode(info.highlightBlendMode)
        else
            object.highlight:SetTexture()
            object.highlight:SetVertexColor(1, 1, 1, 1)
        end

        object.highlight:SetTexCoord(unpack(info.highlightTexCoord))
    end
end

local defaultFont = {
    font = "GameFontHighlight", -- "fontObject"|{"FONT", height, flags...}
    color = private.assets.colors.white,
    wrap = true,
    justifyH = "CENTER",
    justifyV = "MIDDLE",
}

function private:SetFont(fontString, font)
    local info = setmetatable(font or {}, { __index = defaultFont })

    if type(info.font) == "string" then
        fontString:SetFontObject(_G[info.font])
    elseif type(info.font) == "table" then
        fontString:SetFont(unpack(info.font))
    end

    fontString:SetTextColor(info.color:GetRGBA())
    if fontString.SetWordWrap then -- EditBox doesn't have word wrap
        fontString:SetWordWrap(info.wrap or false)
    end
    fontString:SetJustifyH(info.justifyH)
    fontString:SetJustifyV(info.justifyV)
end

local defaultScrollBar = {
    thumbs = {
        color = private.assets.colors.dimmedWhite,
    },
    track = {
        texture = private.assets.blankTexture,
        color = private.assets.colors.dimmedWhite,
    },
    background = {
        enabled = true,
        texture = private.assets.blankTexture,
        color = private.assets.colors.darker,
    },
}

function private:SetScrollBarBackdrop(scrollBar, backdrop)
    local thumbs = setmetatable(backdrop and backdrop.thumbs or {}, { __index = defaultScrollBar.thumbs })
    local track = setmetatable(backdrop and backdrop.track or {}, { __index = defaultScrollBar.track })
    local background = setmetatable(backdrop and backdrop.background or {}, { __index = defaultScrollBar.background })

    scrollBar.Track.Thumb.Main:SetTexture(track.texture)
    scrollBar.Track.Thumb.Main:SetVertexColor(track.color:GetRGBA())

    scrollBar.Back.Texture:SetVertexColor(thumbs.color:GetRGBA())
    scrollBar.Forward.Texture:SetVertexColor(thumbs.color:GetRGBA())

    if background.enabled then
        scrollBar.Background.Main:SetTexture(background.texture)
        scrollBar.Background.Main:SetVertexColor(background.color:GetRGBA())
        scrollBar.Background.Main:Show()
    else
        scrollBar.Background.Main:Hide()
    end
end

function private:strcheck(str)
    -- Validates string exists and is not empty
    return str and str ~= ""
end

function private:TransformTable(tbl, op)
    local result = {}
    for k, v in pairs(tbl) do
        table.insert(result, op(v))
    end
    return result
end

local defaultAnchors = {
    horizontal = {
        scrollBar = function(parent)
            local padding = parent.padding
            return {
                CreateAnchor("LEFT", padding.left, 0),
                CreateAnchor("RIGHT", parent, "RIGHT", -padding.right, 0),
                CreateAnchor("BOTTOM", parent.statusbar, "TOP", 0, padding.bottom),
            }
        end,
        with = function(parent)
            local padding = parent.padding
            return {
                CreateAnchor("TOPLEFT", parent.verticalBox or parent, "TOPLEFT"),
                CreateAnchor("BOTTOMRIGHT", parent.verticalBox or parent, "BOTTOMRIGHT"),
            }
        end,
        without = function(parent)
            local padding = parent.padding
            return {
                CreateAnchor("TOPLEFT", parent.verticalBox or parent, "TOPLEFT"),
                CreateAnchor("BOTTOMRIGHT", parent.verticalBox or parent, "BOTTOMRIGHT"),
            }
        end,
    },
    vertical = {
        scrollBar = function(parent)
            local padding = parent.padding
            local bottom
            if parent.horizontalBar and parent.horizontalBar:IsShown() then
                bottom = CreateAnchor("BOTTOM", parent.horizontalBar, "TOP", 0, padding.bottom)
            else
                bottom = CreateAnchor("BOTTOM", parent.statusbar, "TOP", 0, padding.bottom)
            end

            return {
                CreateAnchor("TOP", parent.titlebar, "BOTTOM", 0, -padding.top),
                CreateAnchor("RIGHT", -padding.right, 0),
                bottom,
            }
        end,
        with = function(parent)
            local padding = parent.padding
            local bottom
            if parent.horizontalBar and parent.horizontalBar:IsShown() then
                bottom = CreateAnchor("BOTTOM", parent.horizontalBar, "TOP", 0, padding.bottom)
            else
                bottom = CreateAnchor("BOTTOM", parent.statusbar, "TOP", 0, padding.bottom)
            end

            return {
                CreateAnchor("TOPLEFT", parent.titlebar, "BOTTOMLEFT", padding.left, -padding.top),
                CreateAnchor("RIGHT", parent.verticalBar, "LEFT", -padding.right, 0),
                bottom,
            }
        end,
        without = function(parent)
            local padding = parent.padding
            local bottom
            if parent.horizontalBar and parent.horizontalBar:IsShown() then
                bottom = CreateAnchor("BOTTOM", parent.horizontalBar, "TOP", 0, padding.bottom)
            else
                bottom = CreateAnchor("BOTTOM", parent.statusbar, "TOP", 0, padding.bottom)
            end

            return {
                CreateAnchor("TOPLEFT", parent.titlebar, "BOTTOMLEFT", padding.left, -padding.top),
                CreateAnchor("RIGHT", -padding.right, 0),
                bottom,
            }
        end,
    },
}

function private:CreateScrollFrame(parent, anchors)
    parent.anchors = CreateFromMixins(defaultAnchors, anchors or {})

    parent.verticalBar = CreateFrame("EventFrame", nil, parent, "LibInterfaceUtilsVerticalScrollBar")
    parent.horizontalBar = CreateFrame("EventFrame", nil, parent, "LibInterfaceUtilsHorizontalScrollBar")

    -- parent.verticalBar:RegisterCallback("OnScroll", function(...)
    --     -- print(...)
    --     parent:DoLayout()
    -- end, parent.verticalBar)

    parent.verticalBox = CreateFrame("Frame", nil, parent, "WowScrollBox")
    parent.horizontalBox = CreateFrame("Frame", nil, parent.verticalBox, "WowScrollBox")
    parent.horizontalBox.scrollable = true
    parent.horizontalBox:SetScript("OnMouseWheel", nil)

    parent.verticalView = CreateScrollBoxLinearView()
    parent.verticalView:SetPanExtent(50)
    parent.horizontalView = CreateScrollBoxLinearView()
    parent.horizontalView:SetPanExtent(50)
    parent.horizontalView:SetHorizontal(true)

    parent.content = CreateFrame("Frame", nil, parent.horizontalBox, "ResizeLayoutFrame")
    parent.content:SetAllPoints(parent.horizontalBox)
    parent.content.scrollable = true

    ScrollUtil.InitScrollBoxWithScrollBar(parent.verticalBox, parent.verticalBar, parent.verticalView)
    ScrollUtil.InitScrollBoxWithScrollBar(parent.horizontalBox, parent.horizontalBar, parent.horizontalView)

    function parent:EvaluateVisibility(orientation, force)
        local scrollBox = self[orientation .. "Box"]
        local scrollBar = self[orientation .. "Bar"]

        local visible = scrollBox:HasScrollableExtent()

        if force or visible ~= scrollBar:IsShown() then
            scrollBar:SetShown(visible)

            if self.anchors then
                local barAnchors = private:ParseValue(self.anchors[orientation].scrollBar, self)
                if self[orientation .. "BarAnchors"] ~= barAnchors then
                    self[orientation .. "BarAnchors"] = barAnchors
                    scrollBar:ClearAllPoints()
                    for _, anchor in ipairs(barAnchors) do
                        anchor:SetPoint(scrollBar, false)
                    end
                end

                local boxAnchors = private:ParseValue(self.anchors[orientation][visible and "with" or "without"], self)
                if self[orientation .. "BoxAnchors"] ~= boxAnchors then
                    self[orientation .. "BoxAnchors"] = boxAnchors
                    scrollBox:ClearAllPoints()
                    for _, anchor in ipairs(boxAnchors) do
                        anchor:SetPoint(scrollBox, false)
                    end
                end
            end

            self:TriggerEvent(self.Event.OnVisibilityChanged, orientation, visible)
        end
    end

    parent = Mixin(parent, CallbackRegistryMixin)
    parent:GenerateCallbackEvents({ "OnVisibilityChanged" })
    CallbackRegistryMixin.OnLoad(parent)
    parent:RegisterCallback("OnVisibilityChanged", function(_, orientation, visible)
        if orientation == "horizontal" then
            parent:EvaluateVisibility("vertical", true)
        end
    end, parent)
    local onSizeChanged = function(_, orientation)
        parent:EvaluateVisibility("vertical")
        parent:EvaluateVisibility("horizontal")
    end
    parent.horizontalBox:RegisterCallback(BaseScrollBoxEvents.OnSizeChanged, onSizeChanged, parent.horizontalBar, "horizontal")
    parent:EvaluateVisibility("horizontal", true)
    parent:EvaluateVisibility("vertical", true)

    return parent.content
end
