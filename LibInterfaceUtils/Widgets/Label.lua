local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Label", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    justifyH = "LEFT",
    disabledColor = private.assets.colors.dimmedWhite,
}

local methods = {
    OnAcquire = function(self)
        self:ApplyTemplate()
        self:SetWordWrap(true)
        self:SetPadding()
        self:SetText()
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        local t = self:Set("template", type(template) == "table" and CreateFromMixins(defaults, template) or defaults)
        private:SetFont(self, t)
    end,

    IsDisabled = function(self)
        return self:Get("isDisabled")
    end,

    SetDisabled = function(self, isDisabled)
        self:Set("isDisabled", isDisabled)
        self:EnableMouse(not isDisabled)
        local t = self:Get("template")
        if isDisabled then
            private:SetFont(self, CreateFromMixins(t, { color = t.disabledColor }))
        else
            private:SetFont(self, t)
        end
    end,

    SetPadding = function(self, padding)
        self:Set("padding", padding or 20)
    end,

    ShowTruncatedText = function(self, show)
        self:Set("showTruncatedText", show)
    end,
}

local function creationFunc()
    local label = private:Mixin(private.UIParent:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), "UserData")

    local widget = {
        object = label,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
