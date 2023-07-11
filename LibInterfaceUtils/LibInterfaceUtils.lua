local lib = LibStub:NewLibrary("LibInterfaceUtils-1.0", 1)
if not lib then return end

-- *******************************
-- *** Throttler ***
-- *******************************

local frame = CreateFrame("Frame")
frame:Hide()

-- *******************************
-- *** Events ***
-- *******************************

local function Fire(event, widget, ...)
	local callback = widget[event]
	if type(callback) == "function" then callback(widget, ...) end
	widget:Fire(event, ...)
end

-- *******************************
-- *** Mixin ***
-- *******************************

local widget = {
	ClearAllPoints = function(self)
		self._frame:ClearAllPoints()
	end,

	DoParentLayout = function(self)
		local parent = self.state.parent
		while parent do
			parent:DoLayout()
			parent = parent.state.parent
		end
	end,

	Fire = function(self, event, ...)
		local callback = self.callbacks[event]
		if callback then callback(...) end
	end,

	Get = function(self, key)
		return self.data[key]
	end,

	GetWidth = function(self)
		return self._frame:GetWidth()
	end,

	GetHeight = function(self)
		return self._frame:GetHeight()
	end,

	Hide = function(self)
		self._frame:Hide()
	end,

	RegisterCallback = function(self, event, callback)
		assert(type(callback) == "function", "Invalid callback function supplied to :RegisterCallback()")
		if self._frame:HasScript(event) then
			self._frame:SetScript(event, function(frame, ...)
				if frame.widget[event] then frame.widget[event](frame.widget, ...) end
				callback(...)
			end)
		else
			self.callbacks[event] = callback
		end
	end,

	Release = function(self)
		assert(type(self) == "table", "Invalid widget reference supplied to :Release()")
		assert(self.pool, "Invalid widget reference supplied to :Release()")
		self._frame:SetParent(UIParent)
		self.state.parent = nil
		self.pool:Release(self)
		Fire("OnRelease", self)
	end,

	Set = function(self, key, value)
		self.data[key] = value
	end,

	SetFillWidth = function(self, fillWidth)
		self.state.fillWidth = fillWidth
	end,

	SetFullHeight = function(self, fullHeight)
		self.state.fullHeight = fullHeight
	end,

	SetFullWidth = function(self, fullWidth)
		self.state.fullWidth = fullWidth
	end,

	SetPoint = function(self, ...)
		self._frame:SetPoint(...)
	end,

	SetSize = function(self, ...)
		self._frame:SetSize(...)
	end,

	SetHeight = function(self, ...)
		self._frame:SetHeight(...)
	end,

	SetWidth = function(self, ...)
		self._frame:SetWidth(...)
	end,

	Show = function(self)
		self._frame:Show()
	end,

	UnregisterCallback = function(self, event)
		if self._frame:HasScript(event) then
			self._frame:SetScript(event, self[event] and function(frame, ...)
				if frame.widget[event] then frame.widget[event](frame.widget, ...) end
			end or nil)
		else
			self.callbacks[event] = nil
		end
	end,
}

-- *******************************
-- *** Container Mixin ***
-- *******************************

local container = Mixin({
	AddChild = function(self, widget)
		widget._frame:SetParent(self.content)
		widget.state.parent = self
		tinsert(self.children, widget)
	end,

	DoLayoutDeferred = function(self)
		C_Timer.NewTicker(0.1, function()
			self:DoLayout()
		end, 1)
	end,

	DoLayout = function(self, child)
		if self.state.paused then return end
		local width, height = self:layout(self.content, self.children)
		Fire("OnLayoutFinished", self, width, height)
		return width, height
	end,

	New = function(self, widgetType)
		local widget = lib:New(widgetType)
		widget._frame:SetParent(self.content)
		widget.state.parent = self
		tinsert(self.children, widget)
		return widget
	end,

	PauseLayout = function(self)
		self.state.paused = true
	end,

	ReleaseChild = function(self, widget)
		for i, child in ipairs(self.children) do
			if child == widget then
				tremove(self.children, i)
				break
			end
		end
		widget:Release()
		self:DoLayoutDeferred()
	end,

	ReleaseChildren = function(self)
		for _, child in ipairs(self.children) do
			child:Release()
		end
		self.children = {}
		self:DoLayoutDeferred()
	end,

	ResumeLayout = function(self)
		self.state.paused = nil
	end,

	SetLayout = function(self, layout)
		layout = layout:lower()
		self.state.layout = layout
		self.layout = lib.layouts[layout] or layout
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
			widget.state = {}
			if isContainer then
				assert(
					type(widget.content) == "table",
					("Widgets of type '%s' must provide a content frame."):format(widgetType)
				)
				widget.children = {}
				widget.layout = lib.layouts.list
				widget._frame:SetScript("OnSizeChanged", function()
					widget:DoLayoutDeferred()
				end)
			end

			widget._frame.widget = widget

			for event, callback in pairs(widget) do
				if widget._frame:HasScript(event) then
					widget._frame:SetScript(event, function(frame, ...)
						if frame.widget[event] then frame.widget[event](frame.widget, ...) end
					end)
				end
			end

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

function lib:GetNextWidget(widgetType)
	local pool = lib.pools[widgetType]
	local count = 0

	for _, _ in pool:EnumerateActive() do
		count = count + 1
	end

	for _, _ in pool:EnumerateInactive() do
		count = count + 1
	end

	return ("LIU%s%d"):format(widgetType, count + 1)
end
