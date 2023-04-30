local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

private.UIParent = _G["LiuUIParent"] or CreateFrame("Frame", "LiuUIParent", UIParent)
private.UIParent:SetAllPoints(UIParent)
private.UIParent:SetFrameLevel(0)
-- private.UIParent:RegisterEvent("UI_SCALE_CHANGED")
-- private.UIParent:SetScript("OnEvent", function(self, event)
--     local res = GetCVar("gxWindowedResolution")
--     if res then
--         local _, h = string.match(res, "(%d+)x(%d+)")
--         self:SetScale((768 / h) / UIParent:GetScale())
--         self:SetScale((768 / h) / self:GetScale())
--     end
-- end)

function private:GetObjectName(objectType)
    local pool = lib.pool[objectType]
    local count = 0

    for _, _ in pool:EnumerateActive() do
        count = count + 1
    end

    for _, _ in pool:EnumerateInactive() do
        count = count + 1
    end

    return addonName .. objectType .. (count + 1)
end

private.colors = {
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
}

local defaultBackdrop = {
    bg = {
        enabled = true,
        atlas = false,
        texture = 1030961,
        texCoord = { 0, 1, 0, 1 },
        color = private.colors.elvTransparent,
    },
    borders = {
        enabled = true,
        left = true,
        right = true,
        top = true,
        bottom = true,
        texture = 1030961,
        color = private.colors.black,
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

    return parent
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

local defaultFont = {
    font = "GameFontHighlight", -- "fontObject"|{"FONT", height, flags...}
    color = private.colors.white,
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
        color = private.colors.dimmedWhite,
    },
    track = {
        texture = 1030961,
        color = private.colors.dimmedWhite,
    },
    background = {
        enabled = true,
        texture = 1030961,
        color = private.colors.darker,
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
