local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "ScrollFrame", 1

local Widget = {
	OnAcquire = function(self)
		self:SetBackdrop(lib.defaultBackdrop)
		self:SetBackdropColor(1, 0, 0, 1)
		-- self:SetBackdropColor(unpack(lib.colors.elvTransparent))
		self:SetBackdropBorderColor(unpack(lib.colors.black))
		-- self:SetContentBackdrop(lib.defaultBackdrop)
		-- self:SetContentBackdropColor(unpack(lib.colors.elvTransparent))
		-- self:SetContentBackdropBorderColor(unpack(lib.colors.black))
		-- self:SetMovable(true)
		-- self:EnableResize(true, 100, 100)
		-- self:SetPoint("CENTER")
		self:SetPadding(5, 5, 5, 5)
		self:SetSpacing(5, 5)
		self:Show()
	end,

	-- EnableResize = function(self, enable, ...)
	-- 	local frame = self._frame
	-- 	frame:SetResizable(enable)
	-- 	frame:SetResizeBounds(...)
	-- 	frame.resizer:SetEnabled(enable)
	-- 	frame.resizer[enable and "Show" or "Hide"](frame.resizer)
	-- end,

	SetBackdrop = function(self, ...)
		self._frame:SetBackdrop(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self._frame:SetBackdropBorderColor(...)
	end,

	SetBackdropColor = function(self, ...)
		self._frame:SetBackdropColor(...)
	end,

	-- SetContentBackdrop = function(self, ...)
	-- 	self.content:SetBackdrop(...)
	-- end,

	-- SetContentBackdropBorderColor = function(self, ...)
	-- 	self.content:SetBackdropBorderColor(...)
	-- end,

	-- SetContentBackdropColor = function(self, ...)
	-- 	self.content:SetBackdropColor(...)
	-- end,

	-- SetMovable = function(self, movable, ...)
	-- 	local frame = self._frame

	-- 	frame:EnableMouse(movable)
	-- 	frame:SetMovable(movable)
	-- 	if movable then
	-- 		frame:RegisterForDrag((...) or "LeftButton", ...)
	-- 	else
	-- 		frame:RegisterForDrag()
	-- 	end

	-- 	frame:SetScript("OnDragStart", movable and OnDragStart or nil)
	-- 	frame:SetScript("OnDragStop", movable and OnDragStop or nil)
	-- end,

	SetPadding = function(self, left, right, top, bottom)
		self.state.padding = {
			left = left or 0,
			right = right or 0,
			top = top or 0,
			bottom = bottom or 0,
		}
	end,

	SetSpacing = function(self, x, y)
		self.state.spacing = {
			x = x or 0,
			y = y or 0,
		}
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

lib:RegisterWidget(widgetType, version, true, function(pool)
	local widget = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GetNextWidget(widgetType), UIParent, "BackdropTemplate"),
	}, Widget)

	widget.content = CreateFrame("Frame", nil, widget._frame, "BackdropTemplate")
	widget.content:SetAllPoints(widget._frame)

	return widget
end)
