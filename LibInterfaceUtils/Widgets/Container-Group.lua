local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

-- *******************************
-- *** Scripts ***
-- *******************************

local function OnMouseDown(title)
	local widget = title:GetParent().widget
	widget:SetCollapsed(not widget._state.collapsed, widget._state.collapsed)
end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Group", 5

local widget = {
	_events = {
		OnAcquire = function(self)
			self:SetSize(300, 200)
			self:SetPadding(5, 5, 5, 5)
			self:SetSpacing(5, 5)
			self:SetTitle()
			self:SetTitlebarBackdrop(addon.defaultBackdrop)
			self:SetTitlebarBackdropColor(unpack(addon.colors.elvTransparent))
			self:SetTitlebarBackdropBorderColor(unpack(addon.colors.black))
			self:SetFont()
			self:SetJustifyH()
			self:SetJustifyV()
			self:SetBackdrop(addon.defaultBackdrop)
			self:SetBackdropColor(unpack(addon.colors.elvTransparent))
			self:SetBackdropBorderColor(unpack(addon.colors.black))
			self:SetAutoHeight(true)
			self:SetCollapsible(true)
			self:SetCollapsed(true)
			self:Show()
		end,

		OnLayoutFinished = function(self, _, height)
			if self._state.autoHeight then
				local parent = self._state.parent
				if parent and parent._state.layout == "fill" then
					return
				end
				local padding = self._state.titlePadding
				local titleHeight = self._frame.titlebar.title:GetHeight()
				local pendingHeight = height + titleHeight + padding.top + padding.bottom - padding.content
				if self._state.collapsed then
					pendingHeight = titleHeight + padding.top + padding.bottom
				end
				if self:GetHeight() ~= pendingHeight then
					self:SetHeight(pendingHeight)
				end
			end
		end,

		OnSizeChanged = function(self)
			print("Built in group call")
			local titlebar = self._frame.titlebar
			local title = titlebar.title
			local padding = self._state.titlePadding
			titlebar:SetHeight(title:GetHeight() + padding.top + padding.bottom)
		end,
	},

	SetAnchors = function(self)
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
			titlebar:SetPoint("TOPLEFT")
			titlebar:SetPoint("TOPRIGHT")

			title:SetPoint("TOPLEFT", padding.left, -padding.top)
			if self._state.collapsible then
				titlebar.icon:SetPoint("TOPRIGHT", -padding.right, -padding.top)
				title:SetPoint("TOPRIGHT", titlebar.icon, "TOPLEFT", -padding.right, 0)
			else
				title:SetPoint("TOPRIGHT", -padding.right, -padding.top)
			end

			content:SetPoint("TOP", titlebar, "BOTTOM", 0, padding.content)
			if not self._state.fullHeight and not self._state.autoHeight then
				local pendingHeight = self:GetHeight() + titlebar:GetHeight() + padding.top + padding.bottom - padding.content
				if self:GetHeight() ~= pendingHeight then
					self:SetHeight(pendingHeight)
				end
			end
		else
			content:SetPoint("TOP")
		end

		content:SetPoint("LEFT")
		content:SetPoint("BOTTOMRIGHT")
	end,

	SetAutoHeight = function(self, autoHeight)
		self._state.autoHeight = autoHeight
		self:SetAnchors()
	end,

	SetBackdrop = function(self, ...)
		self._frame.content:SetBackdrop(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self._frame.content:SetBackdropBorderColor(...)
	end,

	SetBackdropColor = function(self, ...)
		self._frame.content:SetBackdropColor(...)
	end,

	SetCollapsed = function(self, collapsed, restore)
		self._state.collapsed = collapsed and self:GetHeight()

		if collapsed then
			self._frame.content:Hide()
			self:SetHeight(self._state.collapsed - self._frame.content:GetHeight() + self._state.titlePadding.content)
		else
			self._frame.content:Show()
			if restore then
				self:SetHeight(restore)
			end
		end

		self:UpdateIconState()
		self:DoParentLayout()
	end,

	SetCollapsible = function(self, collapsible)
		self._state.collapsible = collapsible
		self._frame.titlebar:EnableMouse(collapsible)
		self._frame.titlebar:SetScript("OnMouseDown", OnMouseDown)
		self:UpdateIconState()
		self:SetAnchors()
	end,

	SetFont = function(self, font)
		lib:SetFont(self._frame.titlebar.title, Mixin(font or {}, { fontObject = GameFontNormalLarge, color = addon.colors.gold }))
	end,

	SetJustifyH = function(self, justifyH)
		self._frame.titlebar.title:SetJustifyH(justifyH or "LEFT")
	end,

	SetJustifyV = function(self, justifyV)
		self._frame.titlebar.title:SetJustifyV(justifyV or "MIDDLE")
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

	SetTitle = function(self, text, left, right, top, bottom, content)
		self._state.titlePadding = Mixin(self._state.titlePadding or {}, {
			left = left or 4,
			right = right or 4,
			top = top or 4,
			bottom = bottom or 4,
			content = content or 1,
		})

		self._frame.titlebar.title:SetText(text or "")
		self:SetAnchors()
	end,

	SetTitlebarBackdrop = function(self, ...)
		self._frame.titlebar:SetBackdrop(...)
	end,

	SetTitlebarBackdropBorderColor = function(self, ...)
		self._frame.titlebar:SetBackdropBorderColor(...)
	end,

	SetTitlebarBackdropColor = function(self, ...)
		self._frame.titlebar:SetBackdropColor(...)
	end,

	UpdateIconState = function(self)
		self._frame.titlebar.icon:SetAtlas(self._state.collapsed and "Gamepad_Rev_Plus_32" or "Gamepad_Rev_Minus_32")
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

lib:RegisterWidget(widgetType, version, true, function(pool)
	local frame = CreateFromMixins({
		_frame = CreateFrame("Frame", addon.GenerateWidgetName(widgetType), UIParent, "BackdropTemplate"),
	}, widget)

	frame._frame.titlebar = CreateFrame("Frame", nil, frame._frame, "BackdropTemplate")
	frame._frame.titlebar:SetBackdrop(addon.defaultBackdrop)
	frame._frame.titlebar.title = frame._frame.titlebar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame._frame.titlebar.icon = frame._frame.titlebar:CreateTexture(nil, "OVERLAY")
	frame._frame.titlebar.icon:SetSize(16, 16)
	frame._frame.content = CreateFrame("Frame", nil, frame._frame, "BackdropTemplate")

	return frame
end)
