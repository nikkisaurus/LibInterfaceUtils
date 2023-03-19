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
    },
    highlight = {
        bordersColor = private.assets.colors.lightFlair,
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        wrap = false,
    },
    normal = {
        bgColor = private.assets.colors.darker,
        font = "GameFontNormal",
        color = private.assets.colors.flair,
        wrap = false,
    },
}

local maps = {
    methods = {
        GetText = true,
    },
}

local scripts = {
    OnEnter = function(self)
        self:SetState("highlight")
    end,
    OnLeave = function(self)
        self:SetState("normal")
    end,
    OnMouseDown = function(self)
        if not self:IsDisabled() then
            local x, y = unpack(self:GetUserData("offset") or { 1, -1 })
            self.text:AdjustPointsOffset(x, y)
        end
    end,
    OnMouseUp = function(self)
        if not self:IsDisabled() then
            local x, y = unpack(self:GetUserData("offset") or { 1, -1 })
            self.text:AdjustPointsOffset(-x, -y)
        end
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetText("")

        self:SetSize(100, 20)

        self:RegisterForDrag()
        self:SetPushedTextOffsets()
        self:ApplyTemplate()
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        local normal = CreateFromMixins(defaults.normal, template and template.normal or {})
        local highlight = CreateFromMixins(defaults.highlight, template and template.highlight or {})
        local disabled = CreateFromMixins(defaults.disabled, template and template.disabled or {})

        self:SetUserData("normal", normal)
        self:SetUserData("highlight", highlight)
        self:SetUserData("disabled", disabled)
        self:SetState(self:IsDisabled() and "disabled" or "normal")
    end,

    IsAutoWidth = function(self)
        return self:GetUserData("autoWidth")
    end,

    IsDisabled = function(self)
        return self:GetUserData("isDisabled")
    end,

    IsTruncated = function(self)
        return (self.text:GetStringWidth()) > self:GetWidth()
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self, CreateFromMixins(defaults.backdrop.normal, backdrop or {}))
    end,

    SetAutoWidth = function(self, isAutoWidth)
        self:SetUserData("autoWidth", isAutoWidth)
        if isAutoWidth then
            self:SetWidth(self.text:GetStringWidth() + 20)
        end
    end,

    SetDisabled = function(self, isDisabled)
        self:SetUserData("isDisabled", isDisabled)
        if isDisabled then
            self:Disable()
            self:SetState("disabled")
        else
            self:Enable()
            self:SetState("normal")
        end
    end,

    SetPushedTextOffsets = function(self, x, y)
        self:SetUserData("offset", { x or 1, y or -1 })
    end,

    SetState = function(self, state)
        local template = self:GetUserData(state)
        private:SetBackdrop(self, template)
        private:SetFont(self.text, template)
    end,

    SetText = function(self, text)
        self.text:SetText(text or "")
        if self:IsAutoWidth() then
            self:SetWidth(self.text:GetStringWidth() + 20)
        end
    end,

    ShowTruncatedText = function(self, show)
        self:SetUserData("showTruncatedText", show)
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
    }

    private:Map(button, button.text, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
