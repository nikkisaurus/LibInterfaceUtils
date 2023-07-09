local lib = LibStub:NewLibrary("LibInterfaceUtils-1.0", 1)
if not lib then return end

-- *******************************
-- *** Events ***
-- *******************************

local function Fire(event, widget, ...)
	local callback = widget[event]
	if not callback or type(callback) ~= "function" then return end
	callback(widget, ...)
end

-- *******************************
-- *** Mixin ***
-- *******************************

local widget = {
	Fire = function(self, event, ...)
		local callback = self.callbacks[event]
		if callback then callback(...) end
	end,

	Get = function(self, key)
		return self.data[key]
	end,

	RegisterCallback = function(self, event, callback)
		assert(type(callback) == "function", "Invalid callback function supplied to :RegisterCallback()")
		if self._frame:HasScript(event) then
			self._frame:SetScript(event, callback)
		else
			self.callbacks[event] = callback
		end
	end,

	Release = function(self)
		assert(type(self) == "table", "Invalid widget reference supplied to :Release()")
		assert(self.pool, "Invalid widget reference supplied to :Release()")
		self.pool:Release(self)
		Fire("OnRelease", widget)
	end,

	Set = function(self, key, value)
		self.data[key] = value
	end,

	SetSize = function(self, ...)
		self._frame:SetSize(...)
	end,

	UnregisterCallback = function(self, event)
		if self._frame:HasScript(event) then
			self._frame:SetScript(event, nil)
		else
			self.callbacks[event] = nil
		end
	end,
}

-- *******************************
-- *** Container Mixin ***
-- *******************************

local container = Mixin({
	ClearAllPoints = function(self)
		self._frame:ClearAllPoints()
	end,

	Hide = function(self)
		self._frame:Hide()
	end,

	Show = function(self)
		self._frame:Show()
	end,
}, widget)

-- *******************************
-- *** Registration ***
-- *******************************

lib.pools = {}

local function Destructor(_, widget)
	widget:ClearAllPoints()
	widget:Hide()
end

function lib:RegisterWidget(widgetType, version, isContainer, constructor, destructor)
	assert(type(widgetType) == "string", ("Invalid widget type: '%s' must be a string value."):format(widgetType))
	assert(type(version) == "number", ("Invalid version number for widget type '%s'."):format(widgetType))
	assert(type(constructor) == "function", ("Invalid constructor function for widget type '%s'."):format(widgetType))

	local pool = lib.pools[widgetType]
	if not (pool and pool.version >= version) then
		pool = CreateObjectPool(function(...)
			local widget = Mixin(constructor(...), isContainer and container or widget)
			widget.callbacks = {}
			widget.data = {}
			if isContainer then
				assert(
					type(widget.content) == "table",
					("Widgets of type '%s' must provide a content frame."):format(widgetType)
				)
				widget.children = {}
			end

			widget._frame.widget = widget

			return widget
		end, destructor or Destructor)
		pool:SetResetDisallowedIfNew(true)
		pool.widgetType = widgetType
		pool.version = version
		lib.pools[widgetType] = pool
	end
end

-- *******************************
-- *** Acquisition ***
-- *******************************

function lib:New(widgetType)
	local pool = lib.pools[widgetType]
	assert(pool, ("Widget type '%s' does not exist."):format(widgetType))

	local widget = pool:Acquire()
	widget.pool = pool
	Fire("OnAcquire", widget)

	return widget
end

function lib:Release(widget)
	widget:Release()
end

-- *******************************
-- *** Helpers ***
-- *******************************

function lib:GetNextWidget(pool)
	assert(pool and pool.widgetType and lib.pools[pool.widgetType], "Invalid widget pool supplied to :GetNextWidget()")
	return ("LIU%s%d"):format(pool.widgetType, #pool + 1)
end
