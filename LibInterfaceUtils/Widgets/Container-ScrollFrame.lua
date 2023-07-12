local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "ScrollFrame", 1, true
local Widget = { _events = {} }

function Widget._events:OnAcquire()
	self:SetPadding(5, 5, 5, 5)
	self:SetSpacing(5, 5)
	self:Show()
end

function Widget._events:OnLayoutFinished(...)
	local frame = self._frame
	frame.content:SetSize(...)
	frame.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
end

function Widget:SetContainerBackdrop(...)
	self._frame:SetBackdrop(...)
end

function Widget:SetContainerBackdropBorderColor(...)
	self._frame:SetBackdropBorderColor(...)
end

function Widget:SetContainerBackdropColor(...)
	self._frame:SetBackdropColor(...)
end

function Widget:SetContentBackdrop(...)
	self._frame.content:SetBackdrop(...)
end

function Widget:SetContentBackdropBorderColor(...)
	self._frame.content:SetBackdropBorderColor(...)
end

function Widget:SetContentBackdropColor(...)
	self._frame.content:SetBackdropColor(...)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent, "BackdropTemplate"),
	}, Widget)

	local frame = widget._frame

	local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
	local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
	scrollBar:SetPoint("TOPRIGHT", -2, 0)
	scrollBar:SetPoint("BOTTOMRIGHT", -2, 0)
	local scrollView = CreateScrollBoxLinearView()
	scrollView:SetPanExtent(50)

	local content = CreateFrame("Frame", nil, scrollBox, "ResizeLayoutFrame, BackdropTemplate")
	content.scrollable = true
	content:SetAllPoints(scrollBox)

	local anchors = {
		with = {
			CreateAnchor("TOPLEFT", frame, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", scrollBar, "BOTTOMLEFT", -7, 0),
		},
		without = {
			CreateAnchor("TOPLEFT", frame, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0),
		},
	}

	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, anchors.with, anchors.without)
	ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollView)

	frame.scrollBar = scrollBar
	frame.scrollBox = scrollBox
	frame.content = content
	frame.scrollView = scrollView

	return widget
end)
