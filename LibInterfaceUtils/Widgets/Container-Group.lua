local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Group", 1, true
local Widget = { _events = {} }
-- Custom events: OnGroupToggle

local function OnMouseDown(title)
	local widget = title:GetParent().widget
	if widget._state.collapsible then
		widget:SetCollapsed(not widget._state.collapsed, widget._state.collapsed)
	end
end

local function SetAnchors(self)
	local titlebar = self._frame.titlebar
	local title = titlebar.title
	local titleText = addon.isValidString(title:GetText())
	local icon = titlebar.icon
	local content = self._frame.content

	titlebar:ClearAllPoints()
	title:ClearAllPoints()
	icon:ClearAllPoints()

	local padding = self._state.padding
	local titlePadding = self._state.titlePadding
	local offset = self._state.contentOffset
	if titleText then
		titlebar:SetPoint("TOPLEFT")
		titlebar:SetPoint("TOPRIGHT")

		title:SetPoint("TOPLEFT", titlePadding.left, -titlePadding.top)
		if self._state.collapsible then
			titlebar.icon:SetPoint("TOPRIGHT", -titlePadding.right, -titlePadding.top)
			title:SetPoint("TOPRIGHT", titlebar.icon, "TOPLEFT", -titlePadding.right, 0)
		else
			title:SetPoint("TOPRIGHT", -titlePadding.right, -titlePadding.top)
		end

		content:SetPoint("TOP", titlebar, "BOTTOM", 0, offset)
		if not self._state.fullHeight and not self._state.autoHeight then
			local pendingHeight = content:GetHeight() + titlebar:GetHeight() - offset
			if self:GetHeight() ~= pendingHeight then
				self:SetHeight(pendingHeight)
			end
		end
	else
		content:SetPoint("TOP")
	end

	content:SetPoint("LEFT")
	content:SetPoint("BOTTOMRIGHT")
end

local function UpdateIconState(self)
	self._frame.titlebar.icon:SetAtlas(self._state.collapsed and "Gamepad_Rev_Plus_32" or "Gamepad_Rev_Minus_32")
end

function Widget._events:OnAcquire()
	self:SetContentOffset()
	self:SetTitlePadding()
	self:SetSpacing(5, 5)
	self:SetPadding(5, 5, 5, 5)
	self:SetSize(300, 200)
	self:SetTitle()
	self:SetFontObject(GameFontNormal, true)
	self:SetJustifyH()
	self:SetJustifyV()
	self:SetContentBackdrop(addon.defaultBackdrop)
	self:SetContentBackdropColor(unpack(addon.colors.elvTransparent))
	self:SetContentBackdropBorderColor(unpack(addon.colors.black))
	self:SetAutoHeight(true)
	self:SetCollapsible()
	self:SetCollapsed()
	self:Show()
end

function Widget._events:OnGroupToggle()
	self:DoParentLayout(true)
end

function Widget._events:OnLayoutFinished(_, height)
	local state = self._state

	if state.autoHeight then
		local parent = state.parent
		if parent and parent._state.layout == "fill" then
			return
		end

		local padding = state.padding
		local titleHeight = self._frame.titlebar:GetHeight()
		local pendingHeight = height + titleHeight - state.contentOffset - padding.bottom

		if state.collapsed then
			pendingHeight = titleHeight
		end

		if self:GetHeight() ~= pendingHeight then
			self:SetHeight(pendingHeight)
		end
	end
end

function Widget._events:OnSizeChanged()
	local titlebar = self._frame.titlebar
	local title = titlebar.title
	local padding = self._state.titlePadding
	titlebar:SetHeight(title:GetHeight() + padding.top + padding.bottom)
end

function Widget:SetAutoHeight(autoHeight)
	self._state.autoHeight = autoHeight
	SetAnchors(self)
end

function Widget:SetCollapsed(collapsed, restore)
	local state = self._state
	local frame = self._frame

	if not state.collapsible then
		return
	end
	state.collapsed = collapsed and self:GetHeight()

	if collapsed then
		frame.content:Hide()
		self:SetHeight(state.collapsed - frame.content:GetHeight() + state.contentOffset)
	else
		frame.content:Show()
		if type(restore) == "number" then
			self:SetHeight(restore)
		end
	end

	UpdateIconState(self)
	self._state.changing = true
	addon.Fire(self, "OnGroupToggle")
end

function Widget:SetCollapsible(collapsible)
	local titlebar = self._frame.titlebar
	titlebar:EnableMouse(collapsible)
	titlebar:SetScript("OnMouseDown", OnMouseDown)
	self:SetCollapsed()
	self._state.collapsible = collapsible

	SetAnchors(self)
	UpdateIconState(self)
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

function Widget:SetContentOffset(offset)
	self._state.contentOffset = offset or 1
end

function Widget:SetFont(...)
	self._frame.titlebar.title:SetFont(...)
end

function Widget:SetFontObject(fontObject, resetColor)
	local title = self._frame.titlebar.title
	title:SetFontObject(fontObject)
	if resetColor then
		title:SetTextColor(fontObject:GetTextColor())
	end
end

function Widget:SetJustifyH(justifyH)
	self._frame.titlebar.title:SetJustifyH(justifyH or "LEFT")
end

function Widget:SetJustifyV(justifyV)
	self._frame.titlebar.title:SetJustifyV(justifyV or "MIDDLE")
end

function Widget:SetTextColor(...)
	self._frame.titlebar.title:SetTextColor(...)
end

function Widget:SetTitle(text)
	self._frame.titlebar.title:SetText(text or "")
	SetAnchors(self)
end

function Widget:SetTitlebarBackdrop(...)
	self._frame.titlebar:SetBackdrop(...)
end

function Widget:SetTitlebarBackdropBorderColor(...)
	self._frame.titlebar:SetBackdropBorderColor(...)
end

function Widget:SetTitlebarBackdropColor(...)
	self._frame.titlebar:SetBackdropColor(...)
end

function Widget:SetTitlePadding(left, right, top, bottom)
	self._state.titlePadding = Mixin(self._state.titlePadding or {}, {
		left = left or 4,
		right = right or 4,
		top = top or 4,
		bottom = bottom or 4,
	})
	SetAnchors(self)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent, "BackdropTemplate"),
	}, Widget)

	local frame = widget._frame

	local titlebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	titlebar.title = titlebar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titlebar.icon = titlebar:CreateTexture(nil, "OVERLAY")
	titlebar.icon:SetSize(12, 12)

	frame.content = CreateFrame("Frame", nil, frame, "BackdropTemplate")

	frame.titlebar = titlebar

	return widget
end)
