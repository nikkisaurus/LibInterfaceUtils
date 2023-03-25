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

local ContainerMixin = {}

function ContainerMixin:InitContainer()
    self.layout = "flow"
    self.padding = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5,
    }
end

function private:MixinContainer(object)
    object = Mixin(object, ContainerMixin)
    object:InitContainer()
    return object
end

local UserDataMixin = {}

function UserDataMixin:InitUserData()
    self.userdata = {}
end

function UserDataMixin:Get(key)
    return self.userdata[key]
end

function UserDataMixin:Set(key, value)
    self.userdata[key] = value
    return self.userdata[key]
end

function private:MixinUserData(object)
    object = Mixin(object, UserDataMixin)
    object:InitUserData()
    return object
end

function private:Mixin(object, ...)
    for _, method in ipairs({ ... }) do
        object = private["Mixin" .. method](private, object)
    end
    return object
end

local children = {}
local ContainerMethods = {
    AddChild = function(self, object)
        local parent = object:Get("parent")
        if parent then
            parent:RemoveChild(object)
        end
        tinsert(self.children, object)
        object:Set("parent", self)
        -- self:DoLayoutDeferred()
    end,

    DoLayoutDeferred = function(self)
        if self:Get("pauseLayout") then
            return
        end

        self:SetScript("OnUpdate", function(...)
            self:DoLayout()
        end)
    end,

    DoLayout = function(self)
        if self:Get("pauseLayout") then
            return
        end

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
        object:Set("parent", self)
        -- self:DoLayoutDeferred()
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
                -- self:DoLayoutDeferred()
                return
            end
        end
    end,

    PauseLayout = function(self)
        self:Set("pauseLayout", true)
    end,

    ResumeLayout = function(self)
        self:Set("pauseLayout")
        -- self:DoLayoutDeferred()
    end,

    SetLayoutPoint = function(self, point)
        self:Set("point", point)
    end,

    SetLayout = function(self, layout, customFunc)
        layout = type(layout) == "string" and layout:lower() or layout
        -- if self.content and self.content.SetLayout then
        --     self.content:SetLayout(layout, customFunc)
        -- end

        self.layoutFunc = customFunc or private.layouts[layout or "flow"]
        self.layoutRef = customFunc and "custom" or layout or "flow"
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:Set("spacingH", spacingH)
        self:Set("spacingV", spacingV)
    end,
}

local ObjectMethods = {
    CancelUpdater = function(self)
        local ticker = self:Get("ticker")
        if ticker then
            ticker:Cancel()
        end
    end,

    Fire = function(self, script, ...)
        if self:Get("isDisabled") then
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
        return self:Get("fillWidth")
    end,

    GetFullHeight = function(self)
        return self:Get("fullHeight")
    end,

    GetFullWidth = function(self)
        return self:Get("fullWidth")
    end,

    GetRelativeHeight = function(self)
        return self:Get("relHeight")
    end,

    GetRelativeWidth = function(self)
        return self:Get("relWidth")
    end,

    GetState = function(self)
        return self:Get("state")
    end,

    HideTooltip = function(self)
        local truncated = self:Get("showTruncatedText")
        local tooltipInitializer = self:Get("tooltipInitializer")
        if (not truncated or not self:IsTruncated()) and not tooltipInitializer then
            return
        end

        local info = self:Get("tooltip")
        local tooltip = info and info.tooltip or GameTooltip
        tooltip:ClearLines()
        tooltip:Hide()
    end,

    IsDisabled = function(self)
        return self:Get("isDisabled")
    end,

    InitUserData = function(self, key, value)
        if not self:Get(key) then
            self:Set(key, value)
        end
    end,

    Release = function(self)
        self:Fire("OnRelease")

        if self.ReleaseChildren then
            self:ReleaseChildren()
        end

        local parent = self:Get("parent")
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
        local ticker = self:Get("ticker")
        if ticker then
            ticker:Cancel()
            self:Set("ticker")
        end

        if callback then
            callback(self) -- Initialize by running instantly

            local ticker = C_Timer.NewTicker(seconds or 1, function()
                callback(self)
            end, iterations)
            self:Set("ticker", ticker)
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
        self:Set("fillWidth", fillWidth)
    end,

    SetFullHeight = function(self, isFullHeight)
        self:Set("fullHeight", isFullHeight)
    end,

    SetFullWidth = function(self, isFullWidth)
        self:Set("fullWidth", isFullWidth)
    end,

    SetRelativeHeight = function(self, relHeight)
        self:Set("relHeight", relHeight)
    end,

    SetRelativeWidth = function(self, relWidth)
        self:Set("relWidth", relWidth)
    end,

    SetOffsets = function(self, xOffset, yOffset, xFill, yFill)
        self:Set("xOffset", xOffset)
        self:Set("yOffset", yOffset)
        self:Set("xFill", xFill)
        self:Set("yFill", yFill)
    end,

    SetTooltip = function(self, initializer, tooltip)
        self:Set("tooltip", tooltip)
        self:Set("tooltipInitializer", initializer)
    end,

    ShowTooltip = function(self)
        local truncated = self:Get("showTruncatedText")
        local tooltipInitializer = self:Get("tooltipInitializer")
        if (not truncated or not self:IsTruncated()) and not tooltipInitializer then
            return
        end

        local info = self:Get("tooltip")
        local tooltip = info and info.tooltip or GameTooltip
        local anchor = info and info.anchor or "ANCHOR_RIGHT"
        local x = info and info.x or 0
        local y = info and info.y or 0
        tooltip:SetOwner(self, anchor, x, y)
        if truncated and self.GetText then
            tooltip:AddLine(self:GetText())
        end
        if tooltipInitializer then
            tooltipInitializer(self, tooltip)
        end
        tooltip:Show()
    end,

    ShowTruncatedText = function(self, show)
        self:Set("showTruncatedText", show)
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
                local isDisabled = self:Get("isDisabled")
                if isDisabled and script ~= "OnHide" and script ~= "OnShow" and script ~= "OnSizeChanged" then
                    return
                end

                if type(handler) == "function" then
                    handler(...)
                end

                if script == "OnEnter" then
                    self:ShowTooltip()
                    if not isDisabled and self.SetState then
                        self:SetState("highlight")
                    end
                end

                if script == "OnLeave" then
                    self:HideTooltip()
                    if not isDisabled and self.SetState then
                        self:SetState("normal")
                    end
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
    -- lib.pool[objectType]:SetResetDisallowedIfNew(true)
    lib.pool[objectType].GetNumObjects = GetNumObjects
end
