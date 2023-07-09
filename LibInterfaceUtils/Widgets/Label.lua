local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Label", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    default = {
        icon = {
            size = 12,
            desaturated = false,
            point = "TOPLEFT",
        },
    },
}

local events = {
    OnAcquire = function(widget)
        widget:SetSize(200, 20)
        widget:SetTemplate()
        widget:SetIcon()
        widget:SetText()
    end,
}

local methods = {
    SetAnchors = function(widget, obj)
        local t = widget:Get("template")
    end,

    SetIcon = function(widget, obj, icon)
        obj.icon:SetTexture(icon)
    end,

    SetTemplate = function(widget, obj, template, mixin)
        local t = widget:Set("template", type(template) == "table" and CreateFromMixins(mixin or templates.default, template) or templates[tostring(template):lower()] or templates.default)
        widget:SetAnchors()
    end,

    SetText = function(widget, obj, text)
        obj.text:SetText(text or "")
        widget:SetAnchors()
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), private.UIParent)
    private:ApplyBackdrop(frame, { bg = { color = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1) } })

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    return private:RegisterWidget({ obj = frame, type = objectType }, events, methods)
end

private:RegisterObjectPool(objectType, version, creationFunc)
