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
        self.tabs = lib:New("ScrollFrame")
        self.tabs:SetLayout("TabFlow")
        self.tabs:SetCallback("OnLayoutFinished", function(_, usedHeight)
            local maxHeight = (self:GetHeight() * (1 / 3))
            local numTabs = #self.tabs.children
            local availableWidth = self.tabs:GetAvailableWidth()
            local tabWidth, tabHeight = self.tabs.children[1]:GetSize()
            local tabsPerRow = floor(availableWidth / tabWidth)
            local rows = ceil(numTabs / tabsPerRow)
            local height = (tabHeight * rows) + 10
            height = min(height, maxHeight)

            if self.tabs:GetHeight() ~= height then
                self.tabs:SetHeight(height)
            end
        end)

        self.content = lib:New("ScrollFrame")
    end,

    AddChild = function(self, ...)
        assert(false, "The method 'AddChild' is forbidden for widget type 'TabGroup'.")
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
        assert(false, "The method 'New' is forbidden for widget type 'TabGroup'.")
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

    Select = function(self, value)
        for _, tab in ipairs(self.tabs.children) do
            if tab:GetUserData("info").value == value then
                tab:Fire("OnClick")
                return
            end
        end
    end,

    SetAnchors = function(self)
        self.tabs:SetParent(self)
        self.tabs:SetPoint("TOPLEFT")
        self.tabs:SetPoint("TOPRIGHT")

        self.content:SetParent(self)
        self.content:SetPoint("TOP", self.tabs, "BOTTOM", 0, 6)
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
                tab:ApplyTemplate(template.tab)
            else
                tab:ApplyTemplate(template.selectedTab)
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
            tab:SetUserData("info", tabInfo)

            local disabled = tabInfo.disabled
            if type(disabled) == "boolean" then
                tab:SetDisabled(disabled)
            elseif type(disabled) == "function" then
                tab:SetDisabled(disabled())
            end

            tab:SetCallback("OnClick", function()
                self:SetSelected(tab)
                self.content:ReleaseChildren()
                if tabInfo.onClick then
                    tabInfo.onClick(self.content, tabInfo)
                    self.content:DoLayoutDeferred()
                end
            end)
        end

        self:SetSelected()
        self.tabs:DoLayoutDeferred()
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
