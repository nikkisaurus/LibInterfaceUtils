local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

local function GetNumObjects(self)
    assert(self.EnumerateActive and self.EnumerateInactive, "Attempting to call GetNumObjects on a non-pool object.")

    local count = 0
    for _, _ in self:EnumerateActive() do
        count = count + 1
    end
    for _, _ in self:EnumerateInactive() do
        count = count + 1
    end
    return count
end

local function Resetter(_, self)
    self:ClearAllPoints()
    self:Hide()
end

local children = {}
local ContainerMethods = {
    AddChild = function(self, object)
        local parent = object:GetUserData("parent")
        if parent then
            parent:RemoveChild(object)
        end
        tinsert(self.children, object)
        object:SetUserData("parent", self)
        self:DoLayoutDeferred()
    end,

    DoLayoutDeferred = function(self)
        self:SetScript("OnUpdate", function(...)
            self:DoLayout()
        end)
    end,

    DoLayout = function(self)
        local w, h = self:layoutFunc()
        self:Fire("OnLayoutFinished", w, h)
        self:SetScript("OnUpdate", nil)
        return private:round(self:GetWidth()), private:round(self:GetHeight())
    end,

    GetAnchorX = function(self)
        return self.content
    end,

    GetAvailableHeight = function(self)
        return private:round(self.content:GetHeight())
    end,

    GetAvailableWidth = function(self)
        return private:round(self.content:GetWidth())
    end,

    MarkDirty = function(self, usedWidth, usedHeight)
        self:SetSize(usedWidth, usedHeight)
    end,

    New = function(self, objectType)
        local object = lib:New(objectType)
        tinsert(self.children, object)
        object:SetUserData("parent", self)
        self:DoLayoutDeferred()
        return object
    end,

    ParentChild = function(self, child)
        child:SetParent(self.content)
    end,

    ReleaseChildren = function(self)
        for i, child in ipairs_reverse(self.children) do
            child:Release()
            tremove(self.children, i)
        end
    end,

    RemoveChild = function(self, object)
        for id, child in ipairs(self.children) do
            if child == object then
                tremove(self.children, id)
                self:DoLayoutDeferred()
                return
            end
        end
    end,

    PauseLayout = function(self)
        self:SetUserData("pauseLayout", true)
    end,

    ResumeLayout = function(self)
        self:SetUserData("pauseLayout")
        self:DoLayoutDeferred()
    end,

    SetLayoutPoint = function(self, point)
        self:SetUserData("point", point)
    end,

    SetLayout = function(self, layout, customFunc)
        layout = type(layout) == "string" and layout:lower() or layout
        if self.content and self.content.SetLayout then
            self.content:SetLayout(layout, customFunc)
        end

        self.layoutFunc = customFunc or private.layouts[layout or "flow"]
        self.layoutRef = customFunc and "custom" or layout or "flow"
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:SetUserData("spacingH", spacingH)
        self:SetUserData("spacingV", spacingV)
    end,
}

local ObjectMethods = {
    CancelUpdater = function(self)
        local ticker = self:GetUserData("ticker")
        if ticker then
            ticker:Cancel()
        end
    end,

    Fire = function(self, script, ...)
        if self:GetUserData("isDisabled") then
            return
        end

        if self:HasScript(script) and self:GetScript(script) then
            self:GetScript(script)(self, ...)
        elseif self[script] then
            self[script](self, ...)
            if self.widget.callbacks[script] then
                self.widget.callbacks[script](self, ...)
            end
        elseif self.target and self.target:HasScript(script) and self.target:GetScript(script) then
            self.target:GetScript(script)(self.target, ...)
        elseif self.widget.callbacks[script] then
            self.widget.callbacks[script](self, ...)
        end
    end,

    GetFillWidth = function(self)
        return self:GetUserData("fillWidth")
    end,

    GetFullHeight = function(self)
        return self:GetUserData("fullHeight")
    end,

    GetFullWidth = function(self)
        return self:GetUserData("fullWidth")
    end,

    GetRelativeHeight = function(self)
        return self:GetUserData("relHeight")
    end,

    GetRelativeWidth = function(self)
        return self:GetUserData("relWidth")
    end,

    GetUserData = function(self, key)
        return self.widget.userdata[key]
    end,

    HideTooltip = function(self)
        local truncated = self:GetUserData("showTruncatedText")
        local tooltipInitializer = self:GetUserData("tooltipInitializer")
        if (not truncated or not self:IsTruncated()) and not tooltipInitializer then
            return
        end

        local info = self:GetUserData("tooltip")
        local tooltip = info and info.tooltip or GameTooltip
        tooltip:ClearLines()
        tooltip:Hide()
    end,

    InitUserData = function(self, key, value)
        if not self:GetUserData(key) then
            self:SetUserData(key, value)
        end
    end,

    Release = function(self)
        self:Fire("OnRelease")

        if self.ReleaseChildren then
            self:ReleaseChildren()
        end

        local parent = self:GetUserData("parent")
        if parent then
            parent:RemoveChild(self)
        end

        self:CancelUpdater()

        -- self:SetParent(UIParent)
        lib.pool[self.widget.type]:Release(self)
        wipe(self.widget.userdata)
        wipe(self.widget.callbacks)
        private:InitializeScripts(self)
    end,

    ScheduleUpdater = function(self, callback, seconds, iterations)
        local ticker = self:GetUserData("ticker")
        if ticker then
            ticker:Cancel()
            self:SetUserData("ticker")
        end

        if callback then
            callback(self) -- Initialize by running instantly

            local ticker = C_Timer.NewTicker(seconds or 1, function()
                callback(self)
            end, iterations)
            self:SetUserData("ticker", ticker)
        end
    end,

    SetCallback = function(self, script, handler)
        self.widget.callbacks[script] = handler
    end,

    SetCallbacks = function(self, callbacks)
        for script, handler in pairs(callbacks) do
            self.widget.callbacks[script] = handler
        end
    end,

    SetFillWidth = function(self, fillWidth)
        self:SetUserData("fillWidth", fillWidth)
    end,

    SetFullHeight = function(self, isFullHeight)
        self:SetUserData("fullHeight", isFullHeight)
    end,

    SetFullWidth = function(self, isFullWidth)
        self:SetUserData("fullWidth", isFullWidth)
    end,

    SetRelativeHeight = function(self, relHeight)
        self:SetUserData("relHeight", relHeight)
    end,

    SetRelativeWidth = function(self, relWidth)
        self:SetUserData("relWidth", relWidth)
    end,

    SetOffsets = function(self, xOffset, yOffset, xFill, yFill)
        self:SetUserData("xOffset", xOffset)
        self:SetUserData("yOffset", yOffset)
        self:SetUserData("xFill", xFill)
        self:SetUserData("yFill", yFill)
    end,

    SetTooltip = function(self, initializer, tooltip)
        self:SetUserData("tooltip", tooltip)
        self:SetUserData("tooltipInitializer", initializer)
    end,

    SetUserData = function(self, key, value)
        self.widget.userdata[key] = value
    end,

    ShowTooltip = function(self)
        local truncated = self:GetUserData("showTruncatedText")
        local tooltipInitializer = self:GetUserData("tooltipInitializer")
        if (not truncated or not self:IsTruncated()) and not tooltipInitializer then
            return
        end

        local info = self:GetUserData("tooltip")
        local tooltip = info and info.tooltip or GameTooltip
        local anchor = info and info.anchor or "ANCHOR_RIGHT"
        local x = info and info.x or 0
        local y = info and info.y or 0
        tooltip:SetOwner(self, anchor, x, y)
        if truncated then
            tooltip:AddLine(self:GetText())
        end
        if tooltipInitializer then
            tooltipInitializer(self, tooltip)
        end
        tooltip:Show()
    end,
}

local defaultScripts = {
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
    -- OnUpdate = true, -- Use :ScheduleUpdater instead
    PostClick = true,
    PreClick = true,
}

function private:GetObjectName(objectType)
    return addonName .. objectType .. (lib.pool[objectType]:GetNumObjects() + 1)
end

function private:InitializeScripts(self)
    local widget = self.widget
    for script, handler in pairs(widget.scripts) do
        if self:HasScript(script) then
            self:SetScript(script, function(...)
                if self:GetUserData("isDisabled") and script ~= "OnHide" and script ~= "OnShow" and script ~= "OnSizeChanged" then
                    return
                end

                if type(handler) == "function" then
                    handler(...)
                end

                if script == "OnEnter" then
                    self:ShowTooltip()
                end

                if script == "OnLeave" then
                    self:HideTooltip()
                end

                local callback = widget.callbacks[script]
                if callback then
                    callback(...)
                end
            end)
        end
    end
end

function private:Map(parent, target, maps)
    if maps and maps.methods then
        for method, _ in pairs(maps.methods) do
            parent[method] = function(self, ...)
                return target[method](target, ...)
            end
        end
    end

    local scripts = CreateFromMixins(defaultScripts, maps and maps.scripts or {})
    for script, func in pairs(scripts) do
        if target:HasScript(script) then
            target:SetScript(script, function(self, ...)
                local handler = parent:HasScript(script) and parent:GetScript(script)
                if handler then
                    handler(parent, ...)
                else
                    local callback = parent.widget.callbacks[script]
                    if callback then
                        callback(parent, ...)
                    end
                end

                if type(func) == "function" then
                    func(parent, ...)
                end
            end)
        end
    end

    parent.target = target
end

function private:RegisterContainer(container, ...)
    container.object.children = {}
    container.object = Mixin(container.object, ContainerMethods)
    container.object:SetLayout()

    return private:RegisterWidget(container, ...)
end

function private:RegisterWidget(widget, methods, scripts)
    widget.callbacks = {}
    widget.userdata = {}

    lib.versions[widget.type] = widget.version

    widget.object.widget = widget
    widget.object = Mixin(widget.object, ObjectMethods)

    if methods then
        widget.object = Mixin(widget.object, methods)
    end

    scripts = CreateFromMixins(defaultScripts, scripts or {})
    widget.scripts = scripts
    private:InitializeScripts(widget.object)

    return widget.object
end

function private:RegisterWidgetPool(objectType, creationFunc, resetterFunc)
    lib.pool[objectType] = CreateObjectPool(creationFunc, resetterFunc or Resetter)
    lib.pool[objectType]:SetResetDisallowedIfNew(true)
    lib.pool[objectType].GetNumObjects = GetNumObjects
end
