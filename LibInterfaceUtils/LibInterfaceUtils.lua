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
		if not callback then return end
		callback(...)
	end,

	Get = function(self, key)
		return self.data[key]
	end,

	RegisterCallback = function(self, event, callback)
		assert(type(callback) == "function", "Invalid callback function supplied to :RegisterCallback()")
		self.callbacks[event] = callback
		if self._frame:HasScript(event) then self._frame:SetScript(event, callback) end
	end,

	Release = function(self)
		assert(type(self) == "table", "Invalid widget reference supplied to :Release()")
		assert(self.pool, "Invalid widget reference supplied to :Release()")
		self.pool:Release(self)
	end,

	Set = function(self, key, value)
		self.data[key] = value
	end,

	SetSize = function(self, ...)
		self._frame:SetSize(...)
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
	Fire("OnRelease", widget)
end

local function GetNext(self)
	return ("LIU%s%d"):format(self.widgetType, #self + 1)
end

function lib:RegisterWidget(widgetType, version, constructor, isContainer)
	assert(type(widgetType) == "string", ("Invalid widget type: '%s' must be a string value."):format(widgetType))
	assert(type(version) == "number", ("Invalid version number for widget type '%s'."):format(widgetType))
	assert(type(constructor) == "function", ("Invalid constructor function for widget type '%s'."):format(widgetType))

	local pool = lib.pools[widgetType]
	if not (pool and pool.version >= version) then
		pool = CreateObjectPool(function(...)
			return Mixin(constructor(...), isContainer and container or widget)
		end, Destructor)
		pool:SetResetDisallowedIfNew(true)
		pool.widgetType = widgetType
		pool.version = version
		pool.GetNext = GetNext
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
	widget.callbacks = {}
	widget.data = {}
	widget.pool = pool
	Fire("OnAcquire", widget)

	return widget
end

function lib:Release(widget)
	widget:Release()
end
