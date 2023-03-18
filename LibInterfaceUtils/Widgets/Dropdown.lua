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

local registry = {
    OnClick = true,
    OnDoubleClick = true,
    OnDragStart = true,
    OnDragStop = true,
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnReceiveDrag = true,
    OnShow = true,
    OnSizeChanged = true,
    PostClick = true,
    PreClick = true,
}

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
        elseif self.menu then
            private:CloseMenus()
            return
        end

        self.menu = lib:New("ScrollFrame")
        self.menu:SetParent(self)
        self.menu:SetFrameStrata("DIALOG")
        self.menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
        self.menu:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
        self.menu:SetHeight(200)
        -- self.menu:SetLayout("List")
        self.menu:SetSpacing(0, 5)
        self.menu:ApplyTemplate({ frame = { bgColor = private.assets.colors.elvBackdrop } }, "bordered")
        self.menu:SetUserData("dropdown", self)
        tinsert(menus, self.menu)

        private:CloseMenus(self.menu)
        self:RefreshMenu(info)
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

    InitializeMenu = function(self)
        self.menu = lib:New("ScrollFrame")
        self.menu:SetParent(self)
        self.menu:SetFrameStrata("DIALOG")
        self.menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
        self.menu:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
        self.menu:SetHeight(200)
        -- self.menu:SetLayout("List")
        self.menu:SetSpacing(0, 5)
        self.menu:ApplyTemplate({ frame = { bgColor = private.assets.colors.elvBackdrop } }, "bordered")
        tinsert(menus, self.menu)

        local style = self:GetUserData("style")
        local info = self:GetUserData("info")
        local callbacks = self:GetUserData("callbacks")
        local locales = self:GetUserData("locales")

        self.menu:PauseLayout()
        self.menu:ReleaseChildren()

        if style.search then
            local search = self.menu:New("SearchBox")
            search:SetFullWidth(true)
            search:SetText(self:GetUserData("searchText") or "")
            if focus then
                search:SetFocus()
            end

            search:SetCallback("OnEnterPressed", function()
                local text = search:GetText()
                self:SetUserData("searchText", text)
                self:FilterInfo()
                if callbacks and callbacks.OnSearch then
                    callbacks.OnSearch(self, text)
                end
                self:RefreshMenu(info, self.menu:GetVerticalScroll())
            end)

            -- search:SetCallback("OnTextChanged", function(_, userInput)
            --     local text = search:GetText()
            --     self:SetUserData("searchText", text)
            --     self:FilterInfo()
            --     if callbacks and callbacks.OnSearchChanged then
            --         callbacks.OnSearchChanged(self, text)
            --     end

            --     if not userInput then
            --         return
            --     end

            --     self:RefreshMenu(info, self.menu:GetVerticalScroll(), true)
            -- end)

            search:SetCallback("OnEditCleared", function()
                self:SetUserData("searchText")
                self:FilterInfo()
                if callbacks and callbacks.OnSearchCleared then
                    callbacks.OnSearchCleared(self)
                end
                -- self:RefreshMenu(info, self.menu:GetVerticalScroll())
            end)
        end

        for i, listButton in ipairs(info) do
            if not listButton.filter then
                local group = self.menu:New("Group")
                group:SetFullWidth(true)
                group:SetSpacing(2, 0)
                group:SetPadding(0, 0, 0, 0)
                group:ApplyTemplate(defaults.listButton.normal)

                if listButton.isTitle then
                    local header = group:New("Header")
                    header:SetText(listButton.text)
                else
                    local callback = function(checked)
                        self:SetSelected(i, checked)
                        if listButton.func then
                            listButton.func(self, checked)
                        end

                        if style.hideOnClick then
                            self.menu:Hide()
                            -- private:CloseMenus()
                        end
                    end

                    -- group:SetCallback("OnEnter", function()
                    --     group:ApplyTemplate(defaults.listButton.highlight)
                    -- end)

                    -- group:SetCallback("OnLeave", function()
                    --     group:ApplyTemplate(defaults.listButton.normal)
                    -- end)

                    local checkButton
                    if style.checkStyle then
                        checkButton = group:New("CheckButton")
                        checkButton:SetChecked(private:ParseValue(listButton.checked, self))
                        checkButton:SetDisabled(private:ParseValue(listButton.disabled))
                        checkButton:SetStyle(style.checkStyle)
                        checkButton:SetAutoWidth(true)

                        checkButton:SetCallback("OnClick", function()
                            callback(checkButton:GetChecked())
                        end)

                        -- checkButton:SetCallback("OnEnter", function()
                        --     group:Fire("OnEnter")
                        -- end)

                        -- checkButton:SetCallback("OnLeave", function()
                        --     group:Fire("OnLeave")
                        -- end)
                    end

                    local label = group:New("Label")
                    label:SetAutoWidth(false)
                    label:SetFillWidth(true)
                    label:SetText(listButton.text)
                    label:SetIcon(listButton.icon, listButton.iconWidth or style.iconWidth, listButton.iconHeight or style.iconHeight, style.iconPoint)
                    label:SetInteractible(true)
                    label:SetDisabled(private:ParseValue(listButton.disabled))

                    -- label:SetCallback("OnEnter", function()
                    --     group:Fire("OnEnter")
                    -- end)

                    -- label:SetCallback("OnLeave", function()
                    --     group:Fire("OnLeave")
                    -- end)

                    label:SetCallback("OnMouseDown", function()
                        if checkButton then
                            checkButton:Fire("OnClick")
                        else
                            callback()
                        end
                    end)

                    -- group:SetCallback("OnMouseDown", function()
                    --     label:Fire("OnMouseDown")
                    -- end)
                end
            end
        end

        if (style.selectAll and style.multiSelect) or style.clear then
            local group = self.menu:New("Group")
            group:SetFullWidth(true)
            group:SetSpacing(0, 0)
            group:SetPadding(0, 0, 0, 0)

            local selectAll
            if style.selectAll and style.multiSelect then
                selectAll = group:New("Button")
                selectAll:SetText(locales and locales.selectAll or "Select All")

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
                        -- private:CloseMenus()
                        self.menu:Hide()
                    else
                        -- self:RefreshMenu(info, self.menu:GetVerticalScroll())
                    end
                end)
            end

            local clear
            if style.clear then
                clear = group:New("Button")
                clear:SetText(locales and locales.clear or "Clear")

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
                        -- private:CloseMenus()
                        self.menu:Hide()
                    else
                        -- self:RefreshMenu(info, self.menu:GetVerticalScroll())
                    end
                end)
            end
        end

        self.menu:ResumeLayout()
        self.menu:DoLayoutDeferred()

        -- private:CloseMenus(self.menu)
        -- self:RefreshMenu(info)
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

    RefreshMenu = function(self, info, percentage, focus)
        if not self.menu then
            return
        end

        local style = self:GetUserData("style")
        local callbacks = self:GetUserData("callbacks")
        local locales = self:GetUserData("locales")

        -- self.menu:SetCallback("OnLayoutFinished", function(width, height)
        --     if not self.menu then
        --         return
        --     end

        --     local contentHeight = self.menu.content:GetHeight()
        --     if contentHeight < style.maxHeight then
        --         self.menu:SetHeight(contentHeight + 12)
        --     elseif self:GetHeight() > style.maxHeight then
        --         self.menu:SetHeight(style.maxHeight)
        --     end

        --     if percentage then
        --         self.menu:SetVerticalScroll(percentage)
        --     end
        -- end)

        self.menu:PauseLayout()
        self.menu:ReleaseChildren()

        if style.search then
            local group = self.menu:New("Group")
            group:SetFullWidth(true)
            group:SetSpacing(0, 0)
            group:SetPadding(0, 0, 0, 0)

            local search = group:New("SearchBox")
            search:SetFullWidth(true)
            search:SetText(self:GetUserData("searchText") or "")
            if focus then
                search:SetFocus()
            end

            search:SetCallback("OnEnterPressed", function()
                local text = search:GetText()
                self:SetUserData("searchText", text)
                self:FilterInfo()
                if callbacks and callbacks.OnSearch then
                    callbacks.OnSearch(self, text)
                end
                self:RefreshMenu(info, self.menu:GetVerticalScroll())
            end)

            search:SetCallback("OnTextChanged", function(_, userInput)
                local text = search:GetText()
                self:SetUserData("searchText", text)
                self:FilterInfo()
                if callbacks and callbacks.OnSearchChanged then
                    callbacks.OnSearchChanged(self, text)
                end

                if not userInput then
                    return
                end

                self:RefreshMenu(info, self.menu:GetVerticalScroll(), true)
            end)

            search:SetCallback("OnEditCleared", function()
                self:SetUserData("searchText")
                self:FilterInfo()
                if callbacks and callbacks.OnSearchCleared then
                    callbacks.OnSearchCleared(self)
                end
                self:RefreshMenu(info, self.menu:GetVerticalScroll())
            end)
        end

        for i, listButton in ipairs(info) do
            if not listButton.filter then
                local group = self.menu:New("Group")
                group:SetFullWidth(true)
                group:SetSpacing(2, 0)
                group:SetPadding(0, 0, 0, 0)
                group:ApplyTemplate(defaults.listButton.normal)

                if listButton.isTitle then
                    local header = group:New("Header")
                    header:SetText(listButton.text)
                else
                    local callback = function(checked)
                        self:SetSelected(i, checked)
                        if listButton.func then
                            listButton.func(self, checked)
                        end

                        if style.hideOnClick then
                            private:CloseMenus()
                        end
                    end

                    group:SetCallback("OnEnter", function()
                        group:ApplyTemplate(defaults.listButton.highlight)
                    end)

                    group:SetCallback("OnLeave", function()
                        group:ApplyTemplate(defaults.listButton.normal)
                    end)

                    local checkButton
                    if style.checkStyle then
                        checkButton = group:New("CheckButton")
                        checkButton:SetChecked(private:ParseValue(listButton.checked, self))
                        checkButton:SetDisabled(private:ParseValue(listButton.disabled))
                        checkButton:SetStyle(style.checkStyle)

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
                    label:SetAutoWidth(false)
                    label:SetFillWidth(true)
                    label:SetText(listButton.text)
                    label:SetIcon(listButton.icon, listButton.iconWidth or style.iconWidth, listButton.iconHeight or style.iconHeight, style.iconPoint)
                    label:SetInteractible(true)
                    label:SetDisabled(private:ParseValue(listButton.disabled))

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
            end
        end

        if (style.selectAll and style.multiSelect) or style.clear then
            local group = self.menu:New("Group")
            group:SetFullWidth(true)
            group:SetSpacing(0, 0)
            group:SetPadding(0, 0, 0, 0)

            local selectAll
            if style.selectAll and style.multiSelect then
                selectAll = group:New("Button")
                selectAll:SetText(locales and locales.selectAll or "Select All")

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
                        private:CloseMenus()
                    else
                        self:RefreshMenu(info, self.menu:GetVerticalScroll())
                    end
                end)
            end

            local clear
            if style.clear then
                clear = group:New("Button")
                clear:SetText(locales and locales.clear or "Clear")

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
                        private:CloseMenus()
                    else
                        self:RefreshMenu(info, self.menu:GetVerticalScroll())
                    end
                end)
            end
        end

        self.menu:ResumeLayout()
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

    SetInitializer = function(self, info, callbacks, locales)
        self:SetUserData("info", info)
        self:SetUserData("callbacks", callbacks)
        self:SetUserData("locales", locales)
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
        registry = registry,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)

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
