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

        dimmedBlack = CreateColor(0, 0, 0, 0.25),
        lightBlack = CreateColor(0, 0, 0, 0.5),
        black = CreateColor(0, 0, 0, 1),

        dimmedWhite = CreateColor(1, 1, 1, 0.25),
        lightWhite = CreateColor(1, 1, 1, 0.5),
        white = CreateColor(1, 1, 1, 1),

        red = CreateColor(1, 0, 0, 1),
        green = CreateColor(0, 1, 0, 1),

        dimmedClass = CreateColor(r, g, b, 0.25),
        lightClass = CreateColor(r, g, b, 0.5),
        class = CreateColor(r, g, b, 1),

        dimmedFlair = CreateColor(1, 0.82, 0, 0.25),
        lightFlair = CreateColor(1, 0.82, 0, 0.5),
        flair = CreateColor(1, 0.82, 0, 1),

        elvBackdrop = CreateColor(26 / 255, 26 / 255, 26 / 255, 1),
        elvTransparent = CreateColor(15 / 255, 15 / 255, 15 / 255, 0.8),
    },
}

private.points = {
    TOP = { "BOTTOM", 0, -1, true },
    TOPLEFT = { "TOPRIGHT", 1, 0, false },
    TOPRIGHT = { "TOPLEFT", -1, 0, false },
    LEFT = { "RIGHT", 1, 0, false },
    RIGHT = { "LEFT", -1, 0, false },
    BOTTOMLEFT = { "BOTTOMRIGHT", 1, 0, false },
    BOTTOMRIGHT = { "BOTTOMLEFT", -1, 0, false },
    BOTTOM = { "TOP", 0, 1, true },
}

function private:CreateTextures(parent)
    parent.bg = parent:CreateTexture("$parentBackground", "BACKGROUND")
    parent.bg:SetAllPoints(parent)

    parent.borders = {}

    parent.borders.top = parent:CreateTexture("$parentBorderTop", "BORDER")
    parent.borders.top:SetPoint("TOPLEFT")
    parent.borders.top:SetPoint("TOPRIGHT")

    parent.borders.left = parent:CreateTexture("$parentBorderLeft", "BORDER")
    parent.borders.left:SetPoint("TOPLEFT")
    parent.borders.left:SetPoint("BOTTOMLEFT")

    parent.borders.right = parent:CreateTexture("$parentBorderRight", "BORDER")
    parent.borders.right:SetPoint("TOPRIGHT")
    parent.borders.right:SetPoint("BOTTOMRIGHT")

    parent.borders.bottom = parent:CreateTexture("$parentBorderBottom", "BORDER")
    parent.borders.bottom:SetPoint("BOTTOMLEFT")
    parent.borders.bottom:SetPoint("BOTTOMRIGHT")

    parent.highlight = parent:CreateTexture("$parentHighlight", "HIGHLIGHT")
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

function private:ResetBorders(borders)
    for id, border in pairs(borders) do
        border:SetTexture()
        border:SetVertexColor(1, 1, 1, 1)
        border:SetHeight(0)
        border:Hide()
    end
end

local defaultBackdrop = {
    bgEnabled = true,
    bgTexture = private.assets.blankTexture,
    bgColor = private.assets.colors.dark,

    bordersEnabled = true,
    bordersTexture = private.assets.blankTexture,
    bordersColor = private.assets.colors.black,
    bordersSize = 1,

    highlightEnabled = false,
    highlightTexture = private.assets.blankTexture,
    highlightColor = private.assets.colors.light,
    highlightBlendMode = "ADD",
}

local backdropMetatable = {
    __index = defaultBackdrop,
}

function private:SetBackdrop(object, backdrop)
    local info = setmetatable(backdrop or {}, backdropMetatable)

    if object.bg then
        if info.bgEnabled then
            object.bg:SetTexture(info.bgTexture)
            object.bg:SetVertexColor(info.bgColor:GetRGBA())
        else
            object.bg:SetTexture()
            object.bg:SetVertexColor(1, 1, 1, 1)
        end
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
            object.highlight:SetTexture(info.highlightTexture)
            object.highlight:SetVertexColor(info.highlightColor:GetRGBA())
            object.highlight:SetBlendMode(info.highlightBlendMode)
        else
            object.highlight:SetTexture()
            object.highlight:SetVertexColor(1, 1, 1, 1)
        end
    end
end

function private:SetFont(fontString, font)
    assert(type(font) == "table")

    if type(font.font) == "string" then
        fontString:SetFontObject(_G[font.font])
    elseif type(font.font) == "table" then
        fontString:SetFont(unpack(font.font))
    end

    if font.color then
        fontString:SetTextColor(font.color:GetRGBA())
    end
end

function private:strcheck(str)
    -- Validates string exists and is not empty
    return str and str ~= ""
end
