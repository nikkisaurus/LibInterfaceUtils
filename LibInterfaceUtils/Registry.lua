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

local function OnSizeChanged(self)
    local object = self.widget.object
    object:DoLayout()
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
        self:DoLayout()
    end,

    DoLayout = function(self)
        self:layoutFunc()
        self:Fire("OnLayoutFinished")
        return private:round(self:GetWidth()), private:round(self:GetHeight())
    end,

    New = function(self, objectType)
        local object = lib:New(objectType)
        tinsert(self.children, object)
        object:SetUserData("parent", self)
        self:DoLayout()
        return object
    end,

    ReleaseChildren = function(self)
        for i = #self.children, 1, -1 do
            self.children[i]:Release()
            tremove(self.children, i)
        end
    end,

    RemoveChild = function(self, object)
        for id, child in ipairs(self.children) do
            if child == object then
                tremove(self.children, id)
                self:DoLayout()
                return
            end
        end
    end,

    SetLayout = function(self, layout, customFunc)
        if self.content.SetLayout then
            self.content:SetLayout(layout, customFunc)
        end

        self.layoutFunc = customFunc or private[layout or "Flow"]
        self.layoutRef = customFunc and "custom" or layout or "Flow"
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:SetUserData("spacingH", spacingH)
        self:SetUserData("spacingV", spacingV)
    end,
}

local ObjectMethods = {
    Fire = function(self, script, ...)
        if self:HasScript(script) and self:GetScript(script) then
            self:GetScript(script)(self, ...)
        elseif self[script] then
            self[script](self, ...)
        elseif self.target and self.target:HasScript(script) and self.target:GetScript(script) then
            self.target:GetScript(script)(self.target, ...)
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

    GetUserData = function(self, key)
        return self.widget.userdata[key]
    end,

    InitUserData = function(self, key, value)
        if not self:GetUserData(key) then
            self:SetUserData(key, value)
        end
    end,

    Release = function(self)
        if self.ReleaseChildren then
            self:ReleaseChildren()
        end

        local parent = self:GetUserData("parent")
        if parent then
            parent:RemoveChild(self)
        end

        lib.pool[self.widget.type]:Release(self)
        wipe(self.widget.userdata)
        wipe(self.widget.callbacks)

        self:Fire("OnRelease")
    end,

    SetCallback = function(self, script, handler)
        self.widget.callbacks[script] = handler
    end,

    SetDraggable = function(self, isDraggable, ...)
        self:EnableMouse(isDraggable or false)
        self:SetMovable(isDraggable or false)
        self:RegisterForDrag(...)
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

    SetOffsets = function(self, xOffset, yOffset, xFill, yFill)
        self:SetUserData("xOffset", xOffset)
        self:SetUserData("yOffset", yOffset)
        self:SetUserData("xFill", xFill)
        self:SetUserData("yFill", yFill)
    end,

    SetUserData = function(self, key, value)
        self.widget.userdata[key] = value
    end,
}

function private:GetObjectName(objectType)
    return addonName .. objectType .. (lib.pool[objectType]:GetNumObjects() + 1)
end

function private:Map(parent, target, maps)
    if maps.methods then
        for method, _ in pairs(maps.methods) do
            parent[method] = function(self, ...)
                return target[method](target, ...)
            end
        end
    end

    if maps.scripts then
        for script, func in pairs(maps.scripts) do
            target:SetScript(script, function(self, ...)
                local handler = parent:HasScript(script) and parent:GetScript(script)
                if handler then
                    handler(parent, ...)
                end

                if type(func) == "function" then
                    func(parent, ...)
                end

                local callback = parent.widget.callbacks[script]
                if callback then
                    callback(parent, ...)
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

    local registry = widget.registry

    if scripts then
        for script, handler in pairs(scripts) do
            assert(widget.object:HasScript(script), format("Script '%s' does not exist for object type '%s'.", script, widget.type))

            widget.object:SetScript(script, function(...)
                handler(...)

                if registry and registry[script] and widget.callbacks[script] then
                    widget.callbacks[script](...)
                end
            end)
        end
    end

    if registry then
        for script, _ in pairs(registry) do
            if widget.object:HasScript(script) and not widget.object:GetScript(script) then
                widget.object:SetScript(script, function(...)
                    if widget.callbacks[script] then
                        widget.callbacks[script](...)
                    end
                end)
            end
        end
    end

    if widget.forbidden then
        for method, _ in pairs(widget.forbidden) do
            local originalMethod = widget.object[method]

            widget.object[method] = function(...)
                if widget.object.overrideForbidden then
                    return originalMethod(...)
                else
                    error(format("Method '%s' for object type '%s' is forbidden.", method, widget.type))
                end
            end
        end
    end

    return widget.object
end

function private:RegisterWidgetPool(objectType, creationFunc, resetterFunc)
    lib.pool[objectType] = CreateObjectPool(creationFunc, resetterFunc or Resetter)
    lib.pool[objectType]:SetResetDisallowedIfNew(true)
    lib.pool[objectType].GetNumObjects = GetNumObjects
end
