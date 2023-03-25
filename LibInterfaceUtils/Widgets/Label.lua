local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Label", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    disabled = {
        justifyH = "LEFT",
        color = private.assets.colors.dimmedWhite,
    },
    highlight = {
        justifyH = "LEFT",
    },
    normal = {
        justifyH = "LEFT",
    },
}

local methods = {
    OnAcquire = function(self)
        self:ApplyTemplate()
        self:SetWordWrap(true)
        self:SetText()
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        self:Set("template", type(template) == "table" and CreateFromMixins(defaults, template) or defaults)
        self:SetState(self:IsDisabled() and "disabled" or "normal")
    end,

    SetDisabled = function(self, isDisabled)
        self:Set("isDisabled", isDisabled)
        self:EnableMouse(not isDisabled)
        self:SetState(isDisabled and "disabled" or "normal")
    end,

    SetState = function(self, state)
        self:SetUserData("state", state)
        private:SetFont(self, self:Get("template")[state])
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
