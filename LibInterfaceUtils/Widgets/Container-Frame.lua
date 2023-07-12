local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Frame", 1, true
local Widget = { _events = {} }
-- Custom events: OnResizeStart, OnResizeStop

local function OnClick(closeButton)
	local frame = closeButton:GetParent()
	frame.widget:Release()
end

local function OnMouseDown(resizer)
	local frame = resizer:GetParent()
	frame:StartSizing()
	frame.widget:Fire("OnResizeStart")
end

local function OnMouseUp(resizer)
	local frame = resizer:GetParent()
	frame:StopMovingOrSizing()
	frame.widget:Fire("OnResizeStop")
end

function Widget._events:OnAcquire()
	self:SetContainerBackdrop(addon.defaultBackdrop)
	self:SetContainerBackdropBorderColor(addon.colors.black)
	self:SetContainerBackdropColor(addon.colors.elvTransparent)
	self:SetContentBackdrop(addon.defaultBackdrop)
	self:SetContentBackdropBorderColor(addon.colors.black)
	self:SetContentBackdropColor(addon.colors.elvTransparent)
	self:SetMovable(true)
	self:EnableResize(true, 100, 100)
	self:SetPoint("CENTER")
	self:SetSize(700, 500)
	self:SetPadding(5, 5, 5, 5)
	self:SetSpacing(5, 5)
	self:SetTitle()
	self:Show()
end

function Widget._events:OnDragStart(args)
	if self._state.movable then
		self._frame:StartMoving()
	end
end

function Widget._events:OnDragStop(args)
	if self._state.movable then
		self._frame:StopMovingOrSizing()
	end
end

function Widget:EnableResize(isEnabled, ...)
	local frame = self._frame
	local resizer = frame.resizer

	frame:SetResizable(isEnabled)
	frame:SetResizeBounds(...)
	resizer:SetEnabled(isEnabled)
	resizer[isEnabled and "Show" or "Hide"](resizer)
end

function Widget:SetContainerBackdrop(...)
	self._frame:SetBackdrop(...)
end

function Widget:SetContainerBackdropBorderColor(...)
	self._frame:SetBackdropBorderColor(addon.unpack(...))
end

function Widget:SetContainerBackdropColor(...)
	self._frame:SetBackdropColor(addon.unpack(...))
end

function Widget:SetContentBackdrop(...)
	self._frame.content:SetBackdrop(...)
end

function Widget:SetContentBackdropBorderColor(...)
	self._frame.content:SetBackdropBorderColor(addon.unpack(...))
end

function Widget:SetContentBackdropColor(...)
	self._frame.content:SetBackdropColor(addon.unpack(...))
end

function Widget:SetMovable(movable, ...)
	local frame = self._frame
	frame:EnableMouse(movable)
	frame:SetMovable(movable)

	if movable then
		frame:RegisterForDrag((...) or "LeftButton", ...)
	else
		frame:RegisterForDrag()
	end

	self._state.movable = movable
end

function Widget:SetTitle(text)
	self._frame.title:SetText(text or "")
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent, "BackdropTemplate"),
	}, Widget)

	local frame = widget._frame

	local resizer = CreateFrame("Button", nil, frame)
	resizer:SetNormalTexture(386862)
	resizer:SetHighlightTexture(386863)
	resizer:SetPoint("BOTTOMRIGHT", 0, 0)
	resizer:SetSize(16, 16)
	resizer:Hide()
	resizer:SetScript("OnMouseDown", OnMouseDown)
	resizer:SetScript("OnMouseUp", OnMouseUp)

	local closeButton = CreateFrame("Button", nil, frame)
	closeButton:SetNormalAtlas("common-search-clearbutton")
	closeButton:SetPoint("TOPRIGHT", -4, -4)
	closeButton:SetSize(12, 12)
	closeButton:SetScript("OnClick", OnClick)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", 4, -4)
	title:SetPoint("BOTTOMRIGHT", closeButton, "BOTTOMLEFT", -4, 0)

	local content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	content:SetPoint("TOP", title, "BOTTOM", 0, -4)
	content:SetPoint("LEFT")
	content:SetPoint("BOTTOMRIGHT")

	frame.resizer = resizer
	frame.close = closeButton
	frame.title = title
	frame.content = content

	return widget
end)
