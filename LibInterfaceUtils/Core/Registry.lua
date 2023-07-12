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
		assert(addon.isTable(widget._frame.content), ("Widgets of type '%s' must provide a content frame."):format(widgetType))

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

function lib:GenerateWidgetName(widgetType)
	local pool = self.pools[widgetType]
	local count = 1

	for _, _ in pool:EnumerateActive() do
		count = count + 1
	end

	for _, _ in pool:EnumerateInactive() do
		count = count + 1
	end

	return ("Liu%s%d"):format(widgetType, count)
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
