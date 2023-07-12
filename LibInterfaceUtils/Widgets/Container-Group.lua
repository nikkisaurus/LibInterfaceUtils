local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Group", 1, true
local Widget = { _events = {} }

local function OnMouseDown(title)
	local widget = title:GetParent().widget
	widget:SetCollapsed(not widget._state.collapsed, widget._state.collapsed)
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

	if titleText then
		local padding = self._state.titlePadding
		local offset = self._state.contentOffset
		titlebar:SetPoint("TOPLEFT")
		titlebar:SetPoint("TOPRIGHT")

		title:SetPoint("TOPLEFT", padding.left, -padding.top)
		if self._state.collapsible then
			titlebar.icon:SetPoint("TOPRIGHT", -padding.right, -padding.top)
			title:SetPoint("TOPRIGHT", titlebar.icon, "TOPLEFT", -padding.right, 0)
		else
			title:SetPoint("TOPRIGHT", -padding.right, -padding.top)
		end

		content:SetPoint("TOP", titlebar, "BOTTOM", 0, offset)
		if not self._state.fullHeight and not self._state.autoHeight then
			local pendingHeight = self:GetHeight() + titlebar:GetHeight() + padding.top + padding.bottom - offset
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
	self:SetSize(300, 200)
	self:SetPadding(5, 5, 5, 5)
	self:SetSpacing(5, 5)
	self:SetTitle()
	self:SetTitlePadding()
	self:SetTitlebarBackdrop(addon.defaultBackdrop)
	self:SetTitlebarBackdropColor(unpack(addon.colors.elvTransparent))
	self:SetTitlebarBackdropBorderColor(unpack(addon.colors.black))
	self:SetFontObject(GameFontNormal)
	self:SetJustifyH()
	self:SetJustifyV()
	self:SetContentOffset()
	self:SetContentBackdrop(addon.defaultBackdrop)
	self:SetContentBackdropColor(unpack(addon.colors.elvTransparent))
	self:SetContentBackdropBorderColor(unpack(addon.colors.black))
	self:SetAutoHeight(true)
	self:SetCollapsible(true)
	self:SetCollapsed(true)
	self:Show()
end

function Widget._events:OnLayoutFinished(_, height)
	local state = self._state

	if state.autoHeight then
		local parent = state.parent
		if parent and parent._state.layout == "fill" then
			return
		end

		local padding = state.titlePadding
		local titleHeight = self._frame.titlebar.title:GetHeight()
		local pendingHeight = height + titleHeight + padding.top + padding.bottom - state.contentOffset

		if state.collapsed then
			pendingHeight = titleHeight + padding.top + padding.bottom
		end

		if self:GetHeight() ~= pendingHeight then
			self:SetHeight(pendingHeight)
		end
	end
end

function Widget._events:OnSizeChanged(sef)
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
	self:DoParentLayout()
end

function Widget:SetCollapsible(collapsible)
	local titlebar = self._frame.titlebar
	titlebar:EnableMouse(collapsible)
	titlebar:SetScript("OnMouseDown", OnMouseDown)
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
