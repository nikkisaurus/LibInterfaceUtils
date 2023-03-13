local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "TabGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local selected = {}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 300)
        self:SetBackdrop()
        self:SetTabs()
    end,

    GetAvailableHeight = function(self)
        return self:GetHeight()
    end,

    GetAvailableWidth = function(self)
        return self:GetWidth()
    end,

    MarkDirty = function(self, width, height) end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self.content, backdrop)
    end,

    SetLayout = function(self, ...)
        self.content:SetLayout(...)
    end,

    SetTabs = function(self, tabs)
        self.tabs:ReleaseChildren()
        if not tabs then
            return
        end

        for _, tabInfo in ipairs(tabs) do
            local tab = self.tabs:New("Button")
            tab:SetText(tabInfo.text)
            tab:SetScript("OnClick", function()
                tabInfo.onClick(self.content, tabInfo)
            end)
        end

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
    frame.content = private:CreateTextures(frame.content)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterContainer(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
