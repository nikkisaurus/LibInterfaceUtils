local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Scripts ***
-- *******************************

local function OnDragStart(frame)
	frame:StartMoving()
end

local function OnDragStop(frame)
	frame:StopMovingOrSizing()
end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Frame", 1

local widget = {
	OnAcquire = function(self)
		self:SetBackdrop({
			bgFile = [[INTERFACE/BUTTONS/WHITE8X8]],
			edgeFile = [[INTERFACE/BUTTONS/WHITE8X8]],
			edgeSize = 1,
		})
		self:SetBackdropColor(0, 0, 0, 0.75)
		self:SetBackdropBorderColor(0, 0, 0, 1)
		self:SetMovable(true)
		self:SetPoint("CENTER")
		self:SetSize(700, 500)
		self:Show()
	end,

	OnRelease = function(self)
		self:Fire("OnRelease")
	end,

	SetBackdrop = function(self, ...)
		self._frame:SetBackdrop(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self._frame:SetBackdropBorderColor(...)
	end,

	SetBackdropColor = function(self, ...)
		self._frame:SetBackdropColor(...)
	end,

	SetMovable = function(self, movable, ...)
		local widget = self._frame

		widget:EnableMouse(movable)
		widget:SetMovable(movable)
		if movable then
			widget:RegisterForDrag((...) or "LeftButton", ...)
		else
			widget:RegisterForDrag()
		end

		widget:SetScript("OnDragStart", movable and OnDragStart or nil)
		widget:SetScript("OnDragStop", movable and OnDragStop or nil)
	end,

	SetPoint = function(self, ...)
		self._frame:SetPoint(...)
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

local mt = {
	__index = widget,
}

lib:RegisterWidget(widgetType, version, true, function(pool)
	local frame = setmetatable({
		_frame = CreateFrame("Frame", lib:GetNextWidget(pool), UIParent, "BackdropTemplate"),
	}, mt)

	frame.content = CreateFrame("Frame", nil, frame._frame, "BackdropTemplate")
	frame.content:SetAllPoints(frame._frame)
	-- frame.content:SetBackdrop({
	-- 	bgFile = [[INTERFACE/BUTTONS/WHITE8X8]],
	-- 	edgeFile = [[INTERFACE/BUTTONS/WHITE8X8]],
	-- 	edgeSize = 1,
	-- })
	-- frame.content:SetBackdropColor(1, 0, 0, 0.75)
	-- frame.content:SetBackdropBorderColor(1, 0, 0, 1)

	return frame
end)
