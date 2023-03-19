local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

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

    parent.highlight = parent:CreateTexture(nil, "HIGHLIGHT")
    parent.highlight:SetAllPoints(parent)

    return parent
end

function private:DrawBorders(borders, texture, color, size)
    for id, border in pairs(borders) do
        border:SetTexture(texture)
        border:SetVertexColor(color:GetRGBA())

        local size = PixelUtil.GetNearestPixelSize(size, UIParent:GetEffectiveScale(), 1)

        if id == "top" or id == "bottom" then
            border:SetHeight(size)
        elseif id == "left" or id == "right" then
            border:SetWidth(size)
        end

        border:Show()
    end
end

function private:ParseValue(value, ...)
    if type(value) == "function" then
        return value(...)
    else
        return value
    end
end

function private:ResetBorders(borders)
    for id, border in pairs(borders) do
        border:SetTexture()
        border:SetVertexColor(1, 1, 1, 1)
        border:SetHeight(0)
        border:Hide()
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
