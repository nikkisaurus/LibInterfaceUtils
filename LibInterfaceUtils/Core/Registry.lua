local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

lib.pools = {}

local function Constructor(widgetType, isContainer, constructor)
	local widget = Mixin(constructor(), Mixin(isContainer and addon.Container or {}, addon.Widget))
	widget._frame.widget = widget
	widget._callbacks = {}
	widget._state = {}
	widget.data = {}

	for event, _ in pairs(widget._events) do
		addon.RegisterEvent(widget._frame, event)
	end

	if isContainer then
		assert(type(widget._frame.content) == "table", ("Widgets of type '%s' must provide a content frame."):format(widgetType))

		widget.children = {}
		widget:SetLayout("flow")
		addon.RegisterEvent(widget._frame, "OnSizeChanged", GenerateClosure(widget.DoLayoutDeferred, widget))
	end

	return widget
end

local function Destructor(_, widget)
	widget:ClearAllPoints()
	widget:Hide()
end

function addon.Fire(event, widget, ...)
	local callback = widget._events[event]
	addon.safecall(callback, widget, ...)
	widget:Fire(event, ...)
end

function addon.GenerateWidgetName(widgetType)
	local pool = lib.pools[widgetType]
	local count = 1

	for _, _ in pool:EnumerateActive() do
		count = count + 1
	end

	for _, _ in pool:EnumerateInactive() do
		count = count + 1
	end

	return ("Liu%s%d"):format(widgetType, count)
end

function addon.OnEvent(event, frame, ...)
	local widget = frame.widget
	local onEvent = widget._events[event]
	local callback = widget._callbacks[event]

	print(callback)
	addon.safecall(onEvent, widget, ...)
	addon.safecall(callback, widget, ...)
end

function lib:RegisterWidget(widgetType, version, isContainer, constructor, destructor)
	assert(type(widgetType) == "string", ("Invalid widget type: '%s' must be a string value."):format(widgetType))
	assert(type(version) == "number", ("Invalid version number for widget type '%s'."):format(widgetType))
	assert(type(constructor) == "function", ("Invalid constructor function for widget type '%s'."):format(widgetType))

	local pool = self.pools[widgetType]
	if not (pool and pool.version >= version) then
		pool = CreateObjectPool(GenerateClosure(Constructor, widgetType, isContainer, constructor), destructor or Destructor)
		pool:SetResetDisallowedIfNew(true)
		pool.widgetType = widgetType
		pool.version = version
		self.pools[widgetType] = pool
	end
end

function addon.RegisterEvent(frame, event, callback)
	local widget = frame.widget
	local handler = widget._events[event]
	local userCallback = widget._callbacks[event]

	if frame:HasScript(event) then
		if not handler and not userCallback and not callback then
			-- Unregister event
			frame:SetScript(event, nil)
		end
		frame:SetScript(event, function(...)
			addon.safecall(handler, widget, ...)
			addon.safecall(userCallback, widget, ...)
			addon.safecall(callback, widget, ...)
		end)
	end
end
