local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Dropdown", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    disabled = {
        font = "GameFontDisable",
        color = private.assets.colors.lightWhite,
        wrap = false,
        justifyH = "RIGHT",
    },
    highlight = {
        bordersColor = private.assets.colors.lightFlair,
        font = "GameFontHighlight",
        color = private.assets.colors.white,
        wrap = false,
        justifyH = "RIGHT",
    },
    normal = {
        bgColor = private.assets.colors.darker,
        font = "GameFontHighlight",
        color = private.assets.colors.white,
        wrap = false,
        justifyH = "RIGHT",
    },
    listButton = {
        normal = {
            content = {
                bgEnabled = false,
                bordersEnabled = false,
            },
        },
        highlight = {
            content = {
                bgEnabled = true,
                bordersEnabled = false,
                bgColor = private.assets.colors.dimmedFlair,
            },
        },
    },
}

local menus = {}

local styles = {
    default = {
        checkStyle = false,
        multiSelect = false,
        selectAll = false,
        clear = false,
        search = false,
        hideOnClick = true,
        maxHeight = 200,
        iconWidth = 14,
        iconHeight = 14,
        iconPoint = "LEFT",
    },
    select = {
        checkStyle = "radio",
        multiSelect = false,
        selectAll = false,
        clear = true,
        search = false,
        hideOnClick = true,
        maxHeight = 200,
        iconWidth = 14,
        iconHeight = 14,
        iconPoint = "RIGHT",
    },
    multiselect = {
        checkStyle = "check",
        multiSelect = true,
        selectAll = true,
        clear = true,
        search = false,
        hideOnClick = false,
        maxHeight = 200,
        iconWidth = 14,
        iconHeight = 14,
        iconPoint = "RIGHT",
    },
}

local scripts = {
    OnClick = function(self)
        local info = self:GetUserData("info")

        if self:IsDisabled() or not info then
            return
        elseif self:GetUserData("closeMenu") then
            self:SetUserData("closeMenu")
            return
        end

        self.menu = lib:New("ScrollList")
        self.menu:SetFrameStrata("DIALOG")
        self.menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
        self.menu:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
        self.menu:SetHeight(200)
        self.menu:ApplyTemplate({ frame = { bgColor = private.assets.colors.elvBackdrop } }, "bordered")
        self.menu:SetUserData("dropdown", self)
        tinsert(menus, self.menu)
        private:CloseMenus(self.menu)

        self.menu:RegisterEvent("GLOBAL_MOUSE_DOWN")
        self.menu:SetScript("OnEvent", function(menu, ...)
            local scale = menu:GetEffectiveScale()
            local left, bottom, width, height = menu:GetRect()
            local cx, cy = GetCursorPosition()
            cx = (cx / scale - left) / width
            cy = (bottom + height - cy / scale) / height

            -- If cursor is outside of menu:
            if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
                local scale = self:GetEffectiveScale()
                local left, bottom, width, height = self:GetRect()
                local cx, cy = GetCursorPosition()
                cx = (cx / scale - left) / width
                cy = (bottom + height - cy / scale) / height

                -- If cursor is inside of button:
                if cx > 0 and cx < 1 and cy > 0 and cy < 1 then
                    self:SetUserData("closeMenu", true)
                end

                menu:UnregisterAllEvents()
                private:CloseMenu(menu)
            end
        end)

        self:SetDataProvider()
    end,
    OnEnter = function(self)
        self:SetState("highlight")
    end,
    OnLeave = function(self)
        self:SetState("normal")
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(200, 20)
        self:ApplyTemplate()
        self:SetText("")
        self:SetStyle()
        self:SetInitializer()
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

    ClearSelected = function(self)
        if self:GetUserData("style").multiSelect then
            wipe(self:GetUserData("selected"))
        else
            self:SetUserData("selected")
        end
    end,

    DrawListButton = function(self, frame, elementData, focusSearch)
        if not self.menu then
            return
        end

        local style = self:GetUserData("style")
        local callbacks = elementData.callbacks
        local localizations = elementData.localizations
        local disabled = private:ParseValue(elementData.disabled)

        local group = frame.group or lib:New("Group")
        group:SetParent(frame)
        group:SetAllPoints(frame)
        group:SetSpacing(5, 0)
        group:ApplyTemplate(defaults.listButton.normal)
        frame.group = group

        group:SetCallback("OnEnter")
        group:SetCallback("OnLeave")
        group:SetCallback("OnMouseDown")
        group:ReleaseChildren()

        if elementData.type == "search" then
            local search = group:New("SearchBox")
            search:SetFullWidth(true)
            search:SetText(self:GetUserData("searchText") or "")
            if focusSearch then
                search:SetFocus()
            end

            search:SetCallback("OnEnterPressed", function()
                local text = search:GetText()
                self:SetUserData("searchText", text)
                self:FilterInfo()
                self:SetDataProvider(self.menu:GetVerticalScroll())
                if callbacks and callbacks.OnSearch then
                    callbacks.OnSearch(self, text)
                end
            end)

            search:SetCallback("OnTextChanged", function(_, userInput)
                if userInput then
                    local text = search:GetText()
                    self:SetUserData("searchText", text)
                    self:FilterInfo()
                    self:SetDataProvider(self.menu:GetVerticalScroll(), true)
                    if callbacks and callbacks.OnSearchChanged then
                        callbacks.OnSearchChanged(self, text)
                    end
                end
            end)

            search:SetCallback("OnEditCleared", function()
                self:SetUserData("searchText")
                self:FilterInfo()
                self:SetDataProvider(self.menu:GetVerticalScroll())
                if callbacks and callbacks.OnSearchCleared then
                    callbacks.OnSearchCleared(self)
                end
            end)
        elseif elementData.type == "extra" then
            group:SetSpacing(0, 0)

            if style.selectAll and style.multiSelect then
                local selectAll = group:New("Button")
                selectAll:SetText(localizations and localizations.selectAll or "Select All")

                if not style.clear then
                    selectAll:SetFullWidth(true)
                else
                    selectAll:SetRelativeWidth(0.5)
                end

                selectAll:SetCallback("OnClick", function()
                    self:SelectAll()

                    if callbacks and callbacks.OnSelectAll then
                        callbacks.OnSelectAll(self)
                    end

                    if style.hideOnClick then
                        self.menu:UnregisterAllEvents()
                        private:CloseMenu(self.menu)
                    else
                        self:SetDataProvider(self.menu:GetVerticalScroll())
                    end
                end)
            end

            if style.clear then
                local clear = group:New("Button")
                clear:SetText(localizations and localizations.clear or "Clear")

                if not style.selectAll or not style.multiSelect then
                    clear:SetFullWidth(true)
                else
                    clear:SetRelativeWidth(0.5)
                end

                clear:SetCallback("OnClick", function()
                    self:ClearSelected()

                    if callbacks and callbacks.OnClear then
                        callbacks.OnClear(self)
                    end

                    if style.hideOnClick then
                        self.menu:UnregisterAllEvents()
                        private:CloseMenu(self.menu)
                    else
                        self:SetDataProvider(self.menu:GetVerticalScroll())
                    end
                end)
            end
        elseif elementData.isTitle then
            local header = group:New("Header")
            header:SetFullWidth(true)
            header:SetText(elementData.text)
        else
            local callback = function(checked)
                self:SetSelected(elementData.value, checked)
                if elementData.func then
                    elementData.func(self, checked)
                end

                if style.hideOnClick then
                    self.menu:UnregisterAllEvents()
                    private:CloseMenu(self.menu)
                end
            end

            if not disabled then
                group:SetCallback("OnEnter", function()
                    group:ApplyTemplate(defaults.listButton.highlight)
                end)

                group:SetCallback("OnLeave", function()
                    group:ApplyTemplate(defaults.listButton.normal)
                end)
            end

            local checkButton
            if style.checkStyle then
                checkButton = group:New("CheckButton")
                checkButton:SetChecked(private:ParseValue(elementData.checked, self))
                checkButton:SetDisabled(disabled)
                checkButton:SetStyle(style.checkStyle)
                checkButton:SetHeight(20)

                checkButton:SetCallback("OnClick", function()
                    callback(checkButton:GetChecked())
                end)

                checkButton:SetCallback("OnEnter", function()
                    group:Fire("OnEnter")
                end)

                checkButton:SetCallback("OnLeave", function()
                    group:Fire("OnLeave")
                end)
            end

            local label = group:New("Label")
            label:SetHeight(20)
            label:SetAutoWidth(false)
            label:SetFillWidth(true)
            label:SetText(elementData.text)
            label:SetIcon(elementData.icon, elementData.iconWidth or style.iconWidth, elementData.iconHeight or style.iconHeight, style.iconPoint)
            label:SetInteractible(true)
            label:SetDisabled(disabled)

            label:SetCallback("OnEnter", function()
                group:Fire("OnEnter")
            end)

            label:SetCallback("OnLeave", function()
                group:Fire("OnLeave")
            end)

            label:SetCallback("OnMouseDown", function()
                if checkButton then
                    checkButton:Fire("OnClick")
                else
                    callback()
                end
            end)

            group:SetCallback("OnMouseDown", function()
                label:Fire("OnMouseDown")
            end)
        end

        local height = self.menu.scrollBox:GetScrollTarget():GetHeight() + 10
        if height < style.maxHeight then
            self.menu:SetHeight(height)
        elseif height > style.maxHeight then
            self.menu:SetHeight(style.maxHeight)
        end
    end,

    FilterInfo = function(self)
        local info = self:GetUserData("info")
        local selected = self:GetUserData("selected")
        local searchText = self:GetUserData("searchText")

        for i, listButton in ipairs(info) do
            info[i].filter = searchText and not strfind(listButton.text:lower(), searchText:lower())
        end
    end,

    GetSelected = function(self)
        local selected = self:GetUserData("selected")
        if type(selected) == "table" then
            return unpack(selected)
        else
            return selected
        end
    end,

    IsDisabled = function(self)
        return self:GetUserData("isDisabled")
    end,

    IsValueSelected = function(self, value)
        local selected = self:GetUserData("selected")
        if type(selected) == "table" then
            return tContains(selected, value)
        else
            return selected == value
        end
    end,

    SelectAll = function(self)
        local info = self:GetUserData("info")
        local selected = self:GetUserData("selected")

        for i, listButton in ipairs(info) do
            if not listButton.isTitle and not private:ParseValue(listButton.disabled) then
                tInsertUnique(selected, listButton.value)
            end
        end
    end,

    SetBackdrop = function(self, backdrop)
        private:SetBackdrop(self, CreateFromMixins(defaults.backdrop.normal, backdrop or {}))
    end,

    SetDataProvider = function(self, scrollPercentage, focusSearch)
        if not self.menu then
            return
        end

        local style = self:GetUserData("style")
        local info = self:GetUserData("info")
        local callbacks = self:GetUserData("callbacks")
        local localizations = self:GetUserData("localizations")

        self.menu:Initialize(function(index, elementData)
            if elementData.type == "search" or elementData.type == "extra" then
                return 30
            end

            return 20
        end, function(frame, elementData)
            self:DrawListButton(frame, elementData, focusSearch)
        end)

        self.menu:SetDataProvider(function(provider)
            if style.search then
                provider:Insert({ type = "search", callbacks = callbacks, localizations = localizations })
            end

            for _, listButton in ipairs(info) do
                if not listButton.filter then
                    provider:Insert(listButton)
                end
            end

            if style.selectAll or style.clear then
                provider:Insert({ type = "extra", callbacks = callbacks, localizations = localizations })
            end
        end)

        if scrollPercentage then
            self.menu:SetVerticalScroll(scrollPercentage)
        end
    end,

    SetDefaultText = function(self, text)
        self:SetUserData("defaultText", text)
        self:SetText(text)
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

    SetInitializer = function(self, info, callbacks, localizations)
        self:SetUserData("info", info)
        self:SetUserData("callbacks", callbacks)
        self:SetUserData("localizations", localizations)
    end,

    SetSelected = function(self, value, isSelected)
        if self:GetUserData("style").multiSelect then
            local selected = self:GetUserData("selected")
            if isSelected then
                tInsertUnique(selected, value)
            else
                tDeleteItem(selected, value)
            end
        else
            self:SetUserData("selected", value)
        end
    end,

    SetSelectedText = function(self)
        local info = self:GetUserData("info")
        local selected = self:GetUserData("selected")

        local str
        if type(selected) == "table" then
            str = table.concat(
                private:TransformTable(selected, function(v)
                    return info[FindInTableIf(info, function(V)
                        return V.value == v
                    end)].text
                end),
                ", "
            )
        else
            local v = info[FindInTableIf(info, function(V)
                return V.value == selected
            end)]
            str = v and v.text
        end

        if not private:strcheck(str) then
            str = self:GetUserData("defaultText")
        end

        self:SetText(str)
    end,

    SetState = function(self, state)
        local template = self:GetUserData(state)
        private:SetBackdrop(self, template)
        private:SetFont(self.text, template)
    end,

    SetStyle = function(self, styleName, mixin)
        styleName = type(styleName) == "string" and styleName:lower() or styleName
        local style
        if type(styleName) == "table" then
            style = CreateFromMixins(styles[mixin] or styles.default, styleName)
        else
            style = styles[styleName or "default"] or styles.default
        end

        self:SetUserData("style", style)
        self:SetUserData("selected", style.multiSelect and {})
    end,

    SetText = function(self, text)
        self.text:SetText(text or "")
    end,
}

local function creationFunc()
    local button = CreateFrame("Button", private:GetObjectName(objectType), UIParent)
    button = private:CreateTextures(button)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(15, 15)
    button.icon:SetPoint("RIGHT", -4, 0)
    button.icon:SetAtlas("UI-HUD-ActionBar-PageDownArrow-Mouseover")
    button.icon:SetDesaturated(true)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("TOPLEFT", 4, 0)
    button.text:SetPoint("RIGHT", button.icon, "LEFT", -4, 0)
    button.text:SetPoint("BOTTOM")

    local widget = {
        object = button,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)

function private:CloseMenu(closeMenu)
    for id, menu in ipairs(menus) do
        if menu == closeMenu then
            local dropdown = menu:GetUserData("dropdown")
            if dropdown then
                dropdown.menu = nil
            end
            menu:SetFrameStrata("HIGH")
            menu:Release()
            tremove(menus, id)
            return
        end
    end
end

function private:CloseMenus(ignoredMenu)
    for id, menu in ipairs_reverse(menus) do
        if menu ~= ignoredMenu then
            local dropdown = menu:GetUserData("dropdown")
            if dropdown then
                dropdown.menu = nil
            end
            menu:SetFrameStrata("HIGH")
            menu:Release()
            tremove(menus, id)
        end
    end
end
