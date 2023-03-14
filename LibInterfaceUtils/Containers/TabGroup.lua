local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "TabGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    backdrop = {
        tab = {
            bgColor = private.assets.colors.darker,
            highlightEnabled = false,
        },
        selectedTab = {
            bgColor = private.assets.colors.lightFlair,
            highlightEnabled = false,
        },
        content = {
            bgEnabled = true,
            bordersEnabled = true,
            bgColor = private.assets.colors.normal,
        },
    },
    font = {
        tab = {
            normal = {
                font = "GameFontNormal",
                color = private.assets.colors.flair,
            },
            highlight = {
                font = "GameFontHighlight",
                color = private.assets.colors.white,
            },
        },
        selectedTab = {
            normal = {
                font = "GameFontHighlight",
                color = private.assets.colors.white,
            },
            highlight = {
                font = "GameFontHighlight",
                color = private.assets.colors.white,
            },
        },
    },
}

local methods = {
    OnAcquire = function(self)
        self:SetLayout()
        self:SetSize(300, 300)
        self:SetBackdrop()
        self:SetTabs()
    end,

    OnRelease = function(self)
        self.tabs:ReleaseChildren()
        self.content:ReleaseChildren()
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

    SetBackdrop = function(self, backdrop)
        self.content:SetBackdrop(CreateFromMixins(defaults.backdrop.content, backdrop or {}))
    end,

    SetLayout = function(self, ...)
        self.content:SetLayout(...)
    end,

    SetSelected = function(self, selectedTab)
        self:GetUserData("selectedTab", selectedTab)

        for _, tab in pairs(self.tabs.children) do
            if tab ~= selectedTab then
                tab:SetFont("normal", defaults.font.tab.normal)
                tab:SetFont("highlight", defaults.font.tab.highlight)
                tab:SetBackdrop(defaults.backdrop.tab)
            else
                tab:SetFont("normal", defaults.font.selectedTab.normal)
                tab:SetFont("highlight", defaults.font.selectedTab.highlight)
                tab:SetBackdrop(defaults.backdrop.selectedTab)
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

    frame.tabs = lib:New("Group")
    frame.tabs:SetParent(frame)
    frame.tabs:SetPoint("TOPLEFT")
    frame.tabs:SetPoint("TOPRIGHT")
    frame.tabs:SetHeight(1)
    frame.tabs:SetPadding(0, 0, 0, 0)
    frame.tabs:SetLayout("TabFlow")

    frame.content = lib:New("ScrollFrame")
    frame.content:SetParent(frame)
    frame.content:SetPoint("TOP", frame.tabs, "BOTTOM")
    frame.content:SetPoint("LEFT")
    frame.content:SetPoint("BOTTOMRIGHT")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterContainer(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
