local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Button", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    backdrop = {
        normal = {
            bgColor = private.assets.colors.darker,
            highlightEnabled = true,
            highlightColor = private.assets.colors.highlight,
        },
    },
    font = {
        normal = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
        },
        highlight = {
            font = "GameFontNormal",
            color = private.assets.colors.flair,
        },
        disabled = {
            font = "GameFontDisable",
            color = private.assets.colors.lightWhite,
        },
    },
}

local registry = {
    OnClick = true,
    OnDoubleClick = true,
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
    PostClick = true,
    PreClick = true,
}

local scripts = {
    OnEnter = function(self)
        private:SetFont(self.text, self:GetUserData("highlight"))
    end,

    OnLeave = function(self)
        private:SetFont(self.text, self:GetUserData("normal"))
    end,

    OnMouseDown = function(self)
        if not self:IsDisabled() then
            self.text:AdjustPointsOffset(1, -1)
        end
    end,

    OnMouseUp = function(self)
        if not self:IsDisabled() then
            self.text:AdjustPointsOffset(-1, 1)
        end
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetPushedTextOffset(1, -1)
        self:SetText("")

        self:SetSize(100, 20)
        self:SetDraggable()
        self:EnableMouse(true) -- this gets disabled during SetDraggable

        self:SetBackdrop()
        self:SetDefaultFonts()
    end,

    IsAutoWidth = function(self)
        return self:GetUserData("autoWidth")
    end,

    IsDisabled = function(self)
        return self:GetUserData("isDisabled")
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self, CreateFromMixins(defaults.backdrop.normal, backdrop or {}))
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:SetUserData("autoWidth", isAutoWidth)
        if isAutoWidth then
            self:SetWidth(self:GetTextWidth() + 20)
        end
    end,

    SetDisabled = function(self, isDisabled)
        self:SetUserData("isDisabled", isDisabled)
        if isDisabled then
            self:Disable()
            private:SetFont(self.text, self:GetUserData("disabled"))
        else
            self:Enable()
            private:SetFont(self.text, self:GetUserData("normal"))
        end
    end,

    SetDefaultFonts = function(self, font)
        self:SetUserData("normal", defaults.font.normal)
        self:SetUserData("highlight", defaults.font.highlight)
        self:SetUserData("disabled", defaults.font.disabled)
        private:SetFont(self.text, self:GetUserData("normal"))
    end,

    SetFont = function(self, fontType, font)
        self:SetUserData(fontType, font)
        private:SetFont(self.text, self:GetUserData(self:IsDisabled() and "disabled" or "normal"))
    end,

    SetText = function(self, text)
        self.text:SetText(text or "")
        if self:IsAutoWidth() then
            self:SetWidth(self.text:GetStringWidth() + 20)
        end
    end,
}

local function creationFunc()
    local button = CreateFrame("Button", private:GetObjectName(objectType), UIParent)
    button = private:CreateTextures(button)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("TOPLEFT")
    button.text:SetPoint("BOTTOMRIGHT")

    local widget = {
        object = button,
        type = objectType,
        version = version,
        registry = registry,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
