local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "ScrollFrame", 1

local Widget = {
	_events = {
		OnAcquire = function(self)
			self:SetPadding(5, 5, 5, 5)
			self:SetSpacing(5, 5)
			self:Show()
		end,

		OnLayoutFinished = function(self, ...)
			self._frame.content:SetSize(...)
			self._frame.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
		end,
	},

	SetBackdrop = function(self, ...)
		self._frame:SetBackdrop(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self._frame:SetBackdropBorderColor(...)
	end,

	SetBackdropColor = function(self, ...)
		self._frame:SetBackdropColor(...)
	end,

	SetContentBackdrop = function(self, ...)
		self._frame.content:SetBackdrop(...)
	end,

	SetContentBackdropBorderColor = function(self, ...)
		self._frame.content:SetBackdropBorderColor(...)
	end,

	SetContentBackdropColor = function(self, ...)
		self._frame.content:SetBackdropColor(...)
	end,

	SetPadding = function(self, left, right, top, bottom)
		self._state.padding = {
			left = left or 0,
			right = right or 0,
			top = top or 0,
			bottom = bottom or 0,
		}
	end,

	SetSpacing = function(self, x, y)
		self._state.spacing = {
			x = x or 0,
			y = y or 0,
		}
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

lib:RegisterWidget(widgetType, version, true, function(pool)
	local frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent, "BackdropTemplate")
	local widget = CreateFromMixins({
		_frame = frame,
	}, Widget)

	frame.scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
	frame.scrollBar:SetPoint("TOPRIGHT", -2, 0)
	frame.scrollBar:SetPoint("BOTTOMRIGHT", -2, 0)

	frame.scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")

	frame.content = CreateFrame("Frame", nil, frame.scrollBox, "ResizeLayoutFrame, BackdropTemplate")
	frame.content.scrollable = true
	frame.content:SetAllPoints(frame.scrollBox)

	frame.scrollView = CreateScrollBoxLinearView()
	frame.scrollView:SetPanExtent(50)

	local anchors = {
		with = {
			CreateAnchor("TOPLEFT", frame, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", frame.scrollBar, "BOTTOMLEFT", -7, 0),
		},
		without = {
			CreateAnchor("TOPLEFT", frame, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0),
		},
	}

	ScrollUtil.AddManagedScrollBarVisibilityBehavior(frame.scrollBox, frame.scrollBar, anchors.with, anchors.without)
	ScrollUtil.InitScrollBoxWithScrollBar(frame.scrollBox, frame.scrollBar, frame.scrollView)

	return widget
end)
