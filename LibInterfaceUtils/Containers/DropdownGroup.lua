local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "DropdownGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    default = {
        frame = {
            bgEnabled = true,
            bordersEnabled = true,
        },
        selectedTab = {
            normal = {
                bgColor = private.assets.colors.lightFlair,
                bordersColor = private.assets.colors.black,
                highlightEnabled = true,
                highlightColor = private.assets.colors.dimmedFlair,
                font = "GameFontHighlight",
                color = private.assets.colors.white,
            },
            highlight = {
                bgColor = private.assets.colors.lightFlair,
                bordersColor = private.assets.colors.black,
                highlightEnabled = true,
                highlightColor = private.assets.colors.dimmedFlair,
                font = "GameFontHighlight",
                color = private.assets.colors.white,
            },
        },
        tab = {
            normal = {
                bgColor = private.assets.colors.darker,
                bordersColor = private.assets.colors.black,
                font = "GameFontNormal",
                color = private.assets.colors.flair,
            },
            highlight = {
                bgColor = private.assets.colors.lightFlair,
                bordersColor = private.assets.colors.black,
                font = "GameFontHighlight",
                color = private.assets.colors.white,
            },
        },
    },
}

local methods = {
    OnAcquire = function(self)
        self:AcquireChildren()
        self:SetLayout()
        self:SetSize(300, 300)
        self:ApplyTemplate("default")
        self:SetAnchors()
        self:SetMenu()
    end,

    OnRelease = function(self)
        self.dropdown:Release()
        self.content:Release()
    end,

    AcquireChildren = function(self)
        self.dropdown = lib:New("Dropdown")
        self.content = lib:New("ScrollFrame")
    end,

    AddChild = function(self, ...)
        assert(false, "The method 'AddChild' is forbidden for widget type 'DropdownGroup'. Use 'InitializeContent' to set a default content state.")
    end,

    ApplyTemplate = function(self, templateName, mixin)
        templateName = type(templateName) == "string" and templateName:lower() or templateName
        local template
        if type(templateName) == "table" then
            template = CreateFromMixins(templates.default, templateName)
        else
            template = templates[templateName or "default"] or templates.default
        end

        self.content:ApplyTemplate(template)

        self:SetUserData("template", template)
    end,

    DoLayout = function(self, ...)
        return self.content:DoLayout(...)
    end,

    GetAnchorX = function(self)
        return self.content:GetAnchorX()
    end,

    GetAvailableHeight = function(self)
        return self.content:GetAvailableHeight()
    end,

    GetAvailableWidth = function(self)
        return self.content:GetAvailableWidth()
    end,

    GetSelected = function(self, ...)
        return self.dropdown:GetSelected(...)
    end,

    InitializeContent = function(self, callback)
        self:SetUserData("defaultContent", callback)
        self:ResetContent()
    end,

    MarkDirty = function(self, ...)
        self.content:MarkDirty(...)
    end,

    New = function(self, ...)
        assert(false, "The method 'New' is forbidden for widget type 'DropdownGroup'. Use 'InitializeContent' to set a default content state.")
    end,

    ParentChild = function(self, ...)
        self.content:ParentChild(...)
    end,

    ReleaseChildren = function(self)
        self.content:ReleaseChildren()
    end,

    RemoveChild = function(self, ...)
        self.content:RemoveChild(...)
    end,

    ResetContent = function(self)
        local callback = self:GetUserData("defaultContent")
        self.content:ReleaseChildren()
        if callback then
            callback(self.content)
            self.content:DoLayoutDeferred()
        end
    end,

    Select = function(self, ...)
        self.dropdown:Select(...)
    end,

    SetAnchors = function(self)
        self.dropdown:SetParent(self)
        self.dropdown:SetPoint("TOPLEFT")

        self.content:SetParent(self)
        self.content:SetPoint("TOPLEFT", self.dropdown, "BOTTOMLEFT")
        self.content:SetPoint("BOTTOMRIGHT")
    end,

    SetLayout = function(self, ...)
        self.content:SetLayout(...)
    end,

    SetMenu = function(self, initializer, callbacks, localizations)
        if initializer then
            for i, info in ipairs(initializer) do
                initializer[i].func = function()
                    self:SetSelectedText()
                    self.content:ReleaseChildren()
                    if info.onClick then
                        info.onClick(self.content, info)
                        self.content:DoLayoutDeferred()
                    end
                end
            end
        end

        callbacks = callbacks or {}
        local OnClear = callbacks.OnClear
        callbacks.OnClear = function(...)
            self:SetSelectedText()
            self:ResetContent()
            if OnClear then
                OnClear(...)
            end
        end

        self.dropdown:SetInitializer(initializer, callbacks, localizations)
    end,

    SetSelectedText = function(self, ...)
        self.dropdown:SetSelectedText(...)
    end,

    SetStyle = function(self, ...)
        self.dropdown:SetStyle(...)
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterContainer(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
