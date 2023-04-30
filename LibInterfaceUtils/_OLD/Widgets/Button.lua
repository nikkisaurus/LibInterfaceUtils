local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Button", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    disabled = {
        font = "GameFontDisable",
        color = private.assets.colors.lightWhite,
        wrap = false,
        borders = {
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        },
    },
    highlight = {
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        wrap = false,
        borders = {
            color = private.assets.colors.lightFlair,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        },
    },
    normal = {
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        wrap = false,
        bg = {
            color = private.assets.colors.darker,
        },
        borders = {
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        },
    },
}

local maps = {
    methods = {
        GetText = true,
    },
}

local scripts = {
    OnMouseDown = function(self)
        if self:IsDisabled() then
            return
        end

        local x, y = unpack(self:Get("offset") or { 1, -1 })
        self.text:AdjustPointsOffset(x, y)
    end,

    OnMouseUp = function(self)
        if self:IsDisabled() then
            return
        end

        local x, y = unpack(self:Get("offset") or { 1, -1 })
        self.text:AdjustPointsOffset(-x, -y)
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(100, 20)
        self:RegisterForDrag()
        self:SetPushedTextOffsets()
        self:ApplyTemplate()
        self:SetPadding()
        self:SetText()
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        self:Set("template", type(template) == "table" and CreateFromMixins(defaults, template) or defaults)
        self:SetState(self:IsDisabled() and "disabled" or "normal")
    end,

    IsAutoWidth = function(self)
        return self:Get("autoWidth")
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:Set("autoWidth", isAutoWidth)
        if isAutoWidth then
            self:SetWidth(self.text:GetStringWidth() + self:Get("padding"))
        end
    end,

    SetDisabled = function(self, isDisabled)
        self:Set("isDisabled", isDisabled)
        self:SetState(isDisabled and "disabled" or "normal")
        if isDisabled then
            self:Disable()
        else
            self:Enable()
        end
    end,

    SetPadding = function(self, left, right, top, bottom)
        self:Set("padding", (left or 5) + (right or 5))
        self.text:SetPoint("TOPLEFT", left or 5, -(top or 5))
        self.text:SetPoint("BOTTOMRIGHT", -(right or 5), bottom or 5)
    end,

    SetPushedTextOffsets = function(self, x, y)
        self:Set("offset", { x or 1, y or -1 })
    end,

    SetState = function(self, state)
        local t = self:Get("template")
        private:ApplyBackdrop(self, t[state])
        private:SetFont(self.text, t[state])
    end,

    SetText = function(self, text)
        self.text:SetText(text or "")
        if self:IsAutoWidth() then
            self:SetWidth(self.text:GetStringWidth() + self:Get("padding"))
        end
    end,
}

local function creationFunc()
    local button = private:Mixin(CreateFrame("Button", private:GetObjectName(objectType), private.UIParent, "BackdropTemplate"), "UserData")
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    local widget = {
        object = button,
        type = objectType,
        version = version,
    }

    private:Map(button, button.text, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
