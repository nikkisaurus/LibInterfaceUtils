local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "MultiLineEditbox", 1, false
local Widget = { _events = {} }

local function OnEnterPressed(widget, self)
	if not IsControlKeyDown() then
		self:Insert("\n")
	else
		self:ClearFocus()
	end
end

local function OnEscapePressed(_, self)
	self:ClearFocus()
end

local function OnTextChanged(widget, self)
	widget:UpdateMaxIndicator()
	widget._frame.container.editFrame:GetScrollBox():ScrollToEnd()
end

local function SetAnchors(self)
	local frame = self._frame
	local title = frame.title
	local container = frame.container
	local scrollBar = frame.scrollBar
	local maxIndicator = container.maxIndicator
	local hasTitle = addon.isValidString(title:GetText())
	local maxLetters = self._state.maxLetters
	local hasScrollBar = scrollBar:IsVisible()

	container.editFrame:GetScrollBox():SetAllPoints(container.editFrame)

	if hasTitle then
		local padding = self._state.padding

		title:SetPoint("TOPLEFT", frame, "TOPLEFT", padding.left, -padding.top)
		title:SetPoint("RIGHT", frame, "RIGHT", padding.right, 0)
		scrollBar:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -padding.bottom - 4)
		container:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -padding.bottom)
	else
		scrollBar:SetPoint("TOPRIGHT", 0, -4)
		container:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	end

	if maxLetters and maxLetters > 0 then
		maxIndicator:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
		maxIndicator:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
		scrollBar:SetPoint("BOTTOMRIGHT", maxIndicator, "TOPRIGHT", 0, 4)
		container:SetPoint("BOTTOMRIGHT", maxIndicator, "TOPRIGHT", 0, 4)
	else
		scrollBar:SetPoint("BOTTOMRIGHT", 0, 4)
		container:SetPoint("BOTTOMRIGHT")
	end

	if hasScrollBar then
		container:SetPoint("BOTTOMRIGHT", scrollBar, "BOTTOMLEFT", -7, 0)
	end
end

local function SetEvent(widget, editbox, event, callback)
	editbox:SetScript(event, function(...)
		callback(widget, ...)
		addon.safecall(widget._callbacks[event], widget, ...)
	end)
end

function Widget._events:OnAcquire()
	self:SetSize(200, 100)
	self:SetBackdrop(addon.defaultBackdrop)
	self:SetBackdropColor(unpack(addon.colors.elvBackdrop))
	self:SetBackdropBorderColor(unpack(addon.colors.black))

	self:SetPadding(0, 0, 0, 5)
	self:SetTitleFontObject(GameFontNormal)
	self:SetFontObject(GameFontHighlight, true)
	self:SetMaxIndicatorFontObject(GameFontHighlight)
	self:SetJustifyH("LEFT")
	self:SetJustifyV("MIDDLE")
	self:SetTitleJustifyH("LEFT")
	self:SetTitleJustifyV("MIDDLE")

	self:SetTextInsets(10, 10, 10, 10)
	self:SetHighlightColor(0.4, 0.4, 0.4, 1)
	self:SetBlinkSpeed(0.5)
	self:SetAutoFocus()
	self:SetMaxBytes(0)
	self:SetMaxLetters(0)
	self:SetSpacing(0)
	self:SetEnabled(true)

	self:SetTitle("")
	self:ClearText()

	self:Show()
	SetAnchors(self)
end

function Widget:ClearText()
	self._frame.container.editFrame:ClearText()
end

function Widget:HighlightText(...)
	self._frame.editbox:HighlightText(...)
end

function Widget:Insert(...)
	self._frame.editbox:Insert(...)
end

function Widget:IsEnabled()
	return self._frame.editbox:IsEnabled()
end

function Widget:SetAutoFocus(...)
	self._frame.editbox:SetAutoFocus(...)
end

function Widget:SetBackdrop(...)
	self._frame.container:SetBackdrop(...)
end

function Widget:SetBackdropColor(...)
	self._frame.container:SetBackdropColor(...)
end

function Widget:SetBackdropBorderColor(...)
	self._frame.container:SetBackdropBorderColor(...)
end

function Widget:SetBlinkSpeed(...)
	self._frame.editbox:SetBlinkSpeed(...)
end

function Widget:SetCountInvisibleLetters(...)
	self._frame.editbox:SetCountInvisibleLetters(...)
end

function Widget:SetCursorPosition(...)
	self._frame.editbox:SetCursorPosition(...)
end

function Widget:SetEnabled(...)
	self._frame.container.editFrame:SetEnabled(...)
end

function Widget:SetFont(...)
	self._frame.editbox:SetFont(...)
end
function Widget:SetFontObject(fontObject, resetColor)
	local editFrame = self._frame.container.editFrame
	local fontName = addon.safecall(fontObject.GetName, fontObject)
	editFrame:SetFontObject(fontName or fontObject)
	if resetColor then
		self:SetTextColor((fontName and fontObject or _G[fontName]):GetTextColor())
	end
end

function Widget:SetHighlightColor(...)
	self._frame.editbox:SetHighlightColor(...)
end

function Widget:SetJustifyH(...)
	self._frame.editbox:SetJustifyH(...)
end

function Widget:SetJustifyV(...)
	self._frame.editbox:SetJustifyV(...)
end

function Widget:SetMaxBytes(...)
	self._frame.editbox:SetMaxBytes(...)
end

function Widget:SetMaxIndicatorFont(...)
	self._frame.container.maxIndicator:SetFont(...)
	SetAnchors(self)
end

function Widget:SetMaxIndicatorFontObject(...)
	self._frame.container.maxIndicator:SetFontObject(...)
	SetAnchors(self)
end

function Widget:SetMaxLetters(maxLetters)
	self._state.maxLetters = maxLetters
	self._frame.editbox:SetMaxLetters(maxLetters)
	self:UpdateMaxIndicator()
end

function Widget:SetPadding(left, right, top, bottom)
	self._state.padding = {
		left = left or 0,
		right = right or 0,
		top = top or 0,
		bottom = bottom or 0,
	}
end

function Widget:SetSpacing(...)
	self._frame.editbox:SetSpacing(...)
end

function Widget:SetTextColor(...)
	self._frame.container.editFrame:SetTextColor(CreateColor(...))
end

function Widget:SetText(text)
	self._frame.editbox:SetText(text or "")
end

function Widget:SetTextInsets(...)
	self._frame.editbox:SetTextInsets(...)
end

function Widget:SetTitle(text)
	self._frame.title:SetText(text or "")
	SetAnchors(self)
end

function Widget:SetTitleFont(...)
	self._frame.title:SetFont(...)
	SetAnchors(self)
end

function Widget:SetTitleFontObject(...)
	self._frame.title:SetFontObject(...)
	SetAnchors(self)
end

function Widget:SetTitleJustifyH(...)
	self._frame.title:SetJustifyH(...)
end

function Widget:SetTitleJustifyV(...)
	self._frame.title:SetJustifyV(...)
end

function Widget:UpdateMaxIndicator()
	local frame = self._frame
	local maxIndicator = frame.container.maxIndicator
	local maxLetters = self._state.maxLetters

	if maxLetters > 0 then
		maxIndicator:SetText(("%d/%d"):format(frame.editbox:GetNumLetters(), maxLetters))
		maxIndicator:Show()
	else
		maxIndicator:SetText("")
		maxIndicator:Hide()
	end

	SetAnchors(self)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent),
	}, Widget)

	local frame = widget._frame

	local title = frame:CreateFontString(nil, "OVERLAY")
	local container = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	local maxIndicator = container:CreateFontString(nil, "OVERLAY")
	maxIndicator:SetJustifyH("RIGHT")
	local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
	local editFrame = CreateFrame("Frame", nil, container, "ScrollingEditBoxTemplate")
	editFrame:SetAllPoints(container)

	local anchors = {
		with = {
			CreateAnchor("TOPLEFT", container, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0),
		},
		without = {
			CreateAnchor("TOPLEFT", container, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0),
		},
	}

	local behavior = ScrollUtil.AddManagedScrollBarVisibilityBehavior(editFrame:GetScrollBox(), scrollBar, anchors.with, anchors.without)
	ScrollUtil.RegisterScrollBoxWithScrollBar(editFrame:GetScrollBox(), scrollBar)

	behavior:RegisterCallback("OnVisibilityChanged", function(_, isVisible)
		SetAnchors(widget)
	end)

	frame.title = title
	frame.container = container
	frame.container.maxIndicator = maxIndicator
	frame.scrollBar = scrollBar
	frame.container.editFrame = editFrame
	frame.editbox = editFrame:GetEditBox()

	SetEvent(widget, frame.editbox, "OnEnterPressed", OnEnterPressed)
	SetEvent(widget, frame.editbox, "OnEscapePressed", OnEscapePressed)
	SetEvent(widget, frame.editbox, "OnTextChanged", OnTextChanged)

	return widget
end)
