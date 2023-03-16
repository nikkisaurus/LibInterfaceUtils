local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "TabGroup", 1
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
        self:SetTabs()
        self:SetAnchors()
    end,

    OnRelease = function(self)
        self.tabs:Release()
        self.content:Release()
    end,

    AcquireChildren = function(self)
        self.tabs = lib:New("Group")
        self.tabs:SetHeight(1)
        self.tabs:SetPadding(0, 0, 0, 0)
        self.tabs:SetLayout("TabFlow")

        self.content = lib:New("ScrollFrame")
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

    MarkDirty = function(self, ...)
        self.content:MarkDirty(...)
    end,

    New = function(self, ...)
        return self.content:New(...)
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

    SetAnchors = function(self)
        self.tabs:SetParent(self)
        self.tabs:SetPoint("TOPLEFT")
        self.tabs:SetPoint("TOPRIGHT")

        self.content:SetParent(self)
        self.content:SetPoint("TOP", self.tabs, "BOTTOM")
        self.content:SetPoint("LEFT")
        self.content:SetPoint("BOTTOMRIGHT")
    end,

    SetLayout = function(self, ...)
        self.content:SetLayout(...)
    end,

    SetSelected = function(self, selectedTab)
        local template = self:GetUserData("template")

        for _, tab in pairs(self.tabs.children) do
            if tab ~= selectedTab then
                -- TODO
                tab:ApplyTemplate(template.tab)
                -- tab:SetFont("normal", template.tab.normal)
                -- tab:SetFont("highlight", template.tab.highlight)
                -- tab:SetBackdrop(template.tab)
            else
                tab:ApplyTemplate(template.selectedTab)
                -- tab:SetFont("normal", template.selectedTab.normal)
                -- tab:SetFont("highlight", template.selectedTab.highlight)
                -- tab:SetBackdrop(template.selectedTab)
            end
        end
    end,

    SetTabs = function(self, tabs)
        self.tabs:ReleaseChildren()

        if not tabs then
            return
        end

        for _, tabInfo in ipairs(tabs) do
            local tab = self.tabs:New("Button")
            tab:SetText(tabInfo.text)

            local disabled = tabInfo.disabled
            if type(disabled) == "boolean" then
                tab:SetDisabled(disabled)
            elseif type(disabled) == "function" then
                tab:SetDisabled(disabled())
            end

            tab:SetCallback("OnClick", function()
                self:SetSelected(tab)
                self.content:ReleaseChildren()
                tabInfo.onClick(self.content, tabInfo)
                self.content:DoLayout()
            end)
        end

        self:SetSelected()
        self.tabs:DoLayout()
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
