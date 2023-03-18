local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "OptionGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local selected = {}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 20)
        self:SetPadding()
        self:ApplyTemplate("bordered")
        self:SetMultiselect(true)
        self:SetInfo()
    end,

    GetSelected = function(self)
        wipe(selected)
        for id, optionButton in ipairs(self:GetUserData("options")) do
            if optionButton:GetChecked() then
                tinsert(selected, id)
            end
        end

        return unpack(selected)
    end,

    SetInfo = function(self, info)
        self:SetUserData("options", {})
        local options = self:GetUserData("options")
        if type(info) ~= "table" then
            self:ReleaseChildren()
        else
            local isMultiSelect = self:GetUserData("multiSelect")
            for id, option in ipairs(info) do
                local checkButton = self:New("CheckButton")
                options[id] = checkButton
                checkButton:SetFullWidth(option.fullWidth)
                checkButton:SetCheckAlignment("LEFT")
                checkButton:SetLabel(option.label)
                checkButton:SetStyle(not isMultiSelect and "radio")

                if option.width then
                    checkButton:SetAutoWidth(false)
                    checkButton:SetWidth(option.width)
                end

                checkButton:SetCallback("OnClick", function(...)
                    if not isMultiSelect then
                        for _, optionButton in ipairs(options) do
                            optionButton:SetChecked(optionButton == checkButton)
                        end
                    end
                    option.func(self, ...)
                end)
            end

            self:DoLayoutDeferred()
        end
    end,

    SetMultiselect = function(self, isMultiSelect)
        self:SetUserData("multiSelect", isMultiSelect)
    end,
}

local function creationFunc()
    local frame = lib:New("Group")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        registry = registry,
    }

    return private:RegisterWidget(widget, methods)
end

private:RegisterWidgetPool(objectType, creationFunc)
