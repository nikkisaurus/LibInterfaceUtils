local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

local ObjectMixin = {
    Get = function(self, key)
        return self.userdata[key]
    end,

    Release = function(self)
        if self.children then -- TODO ?
            for i, child in ipairs(self.children) do
                child:Release()
            end
        end

        lib.pool[self.type]:Release(self)
        self:TriggerEvent("OnRelease")
        self.userdata = {}
    end,

    Set = function(self, key, value)
        self.userdata[key] = value
        return self.userdata[key]
    end,
}

function private:MixinObject(widget)
    for method, func in pairs(ObjectMixin) do
        widget[method] = func
    end
end

local maps = {
    container = {
        Hide = true,
        SetPoint = true,
        SetSize = true,
        Show = true,
    },
    widget = {},
}

function private:RegisterMaps(widget, maps, self)
    for method, _ in pairs(maps) do
        widget[method] = function(_, ...)
            widget.obj[method](self or widget.obj, ...)
        end
    end
end

function private:InitializeEvents(widget, ...)
    widget = Mixin(widget, CallbackRegistryMixin)
    widget:GenerateCallbackEvents({ ... })
    CallbackRegistryMixin.OnLoad(widget)
end

function private:RegisterEventCallbacks(widget, events)
    if type(events) ~= "table" then
        return
    end

    for event, callback in pairs(events) do
        if widget:DoesFrameHaveEvent(event) then
            widget:RegisterCallback(event, callback, widget)
        elseif widget.obj and widget.obj:HasScript(event) then
            widget.obj:SetScript(event, function(...)
                callback(widget, ...)
            end)
        end
    end
end

function private:RegisterMethods(widget, methods)
    if type(methods) ~= "table" then
        return
    end

    for method, func in pairs(methods) do
        widget[method] = function(_, ...)
            func(widget, widget.obj, ...)
        end
    end
end

function private:RegisterContainer(widget, events, methods)
    widget.children = {}

    widget.callbacks = {}
    widget.userdata = {}

    widget.obj.widget = widget

    private:RegisterMethods(widget, methods)
    private:InitializeEvents(widget, "OnAcquire", "OnRelease")
    private:RegisterEventCallbacks(widget, events)
    private:RegisterMaps(widget, maps.container)
    private:MixinObject(widget)

    return widget
end

local function Resetter(_, widget)
    widget.obj:ClearAllPoints()
    widget.obj:Hide()
end

function private:RegisterObjectPool(objectType, version, creationFunc, resetterFunc)
    assert(not lib.pool[objectType], "Object pool [" .. objectType .. "] has already been registered.")
    lib.pool[objectType] = CreateObjectPool(creationFunc, resetterFunc or Resetter)
    lib.versions[objectType] = version
end
