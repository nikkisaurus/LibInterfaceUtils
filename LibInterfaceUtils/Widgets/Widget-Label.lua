local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Label", 1, false
local Widget = { _events = {} }

local defaultTheme = {
	Disabled = {
		fontObject = GameFontHighlight,
	},
	Highlight = {
		fontObject = GameFontNormal,
	},
	Normal = {
		fontObject = GameFontHighlight,
	},
	Pushed = {
		fontObject = GameFontNormal,
	},
}

local function UpdateTheme(self)
	local text = self._frame.text
	local theme = self._state.theme[self:GetState()]

	if theme.fontObject then
		local fontObject = theme.fontObject
		fontObject = (addon.isTable(fontObject)) and fontObject or _G[fontObject]
		assert(fontObject.GetFont, "Invalid fontObject supplied to Button's :SetTheme().")

		text:SetFontObject(fontObject)
		text:SetTextColor(fontObject:GetTextColor())
	end

	if theme.font then
		text:SetFont(addon.unpack(theme.font))
	end

	if theme.color then
		text:SetTextColor(addon.unpack(theme.color))
	end
end

local function SetAnchors(self)
	local point, size
	if self._state.icon.texture then
		point = self._state.icon.point
		size = self._state.icon.size
	end

	local icon = self._frame.icon
	icon:ClearAllPoints()
	icon:Hide()

	local text = self._frame.text
	text:ClearAllPoints()

	local spacing = self._state.spacing

	if point then
		local points = addon.getPoints(icon, self._state.spacing)[point]
		icon:SetPoint(unpack(points.texture))
		text:SetPoint(unpack(points.text[1]))

		if self._state.autoWidth and not self._state.fullWidth and not self._state.availableWidth then
			self:SetWidth((points.textureWidth and (size + spacing.x) or 0) + text:GetStringWidth())
		else
			text:SetWidth(self:GetWidth() - (points.textureWidth and (size + spacing.x) or 0))
		end

		text:SetPoint(unpack(points.text[2]))
		if points.text[3] then
			text:SetPoint(unpack(points.text[3]))
		end
		self:SetHeight(max(size, (points.textureHeight and size or 0) + text:GetStringHeight()))

		icon:Show()
	else
		text:SetPoint("TOPLEFT")
		text:SetPoint("TOPRIGHT")
		self:SetWidth(text:GetWidth())
		self:SetHeight(text:GetStringHeight())
	end
end

function Widget._events:OnAcquire()
	self:SetSpacing()
	self:SetSize(200, 0)
	self:SetIcon()
	self:SetFontObject(GameFontHighlight, true)
	self:SetJustifyH("LEFT")
	self:SetJustifyV("MIDDLE")
	self:SetWordWrap(true)
	self:SetAutoWidth(true)
	self:SetTheme()
	self:SetText()
	self:SetInteractive()
	self:Show()
end

function Widget._events:OnMouseDown()
	addon.safecall(self._state.interactive)
end

function Widget:IsEnabled()
	return self._state.interactive
end

function Widget._events:OnSizeChanged()
	SetAnchors(self)
end

function Widget:SetAtlas(atlas, point, size)
	self._state.icon = {
		texture = atlas,
		size = size or 14,
		point = point or "TOPLEFT",
	}

	local icon = self._frame.icon
	icon:SetAtlas(atlas)
	icon:SetSize(size or 14, size or 14)
	SetAnchors(self)
end

function Widget:SetAutoWidth(autoWidth)
	self._state.autoWidth = autoWidth
	SetAnchors(self)
end

function Widget:SetFont(...)
	self._frame.text:SetFont(...)
end

function Widget:SetFontObject(fontObject, resetColor)
	local text = self._frame.text
	text:SetFontObject(fontObject)
	if resetColor then
		text:SetTextColor(fontObject:GetTextColor())
	end
end

function Widget:SetIcon(texture, point, size)
	self._state.icon = {
		texture = texture ~= "" and texture,
		size = size or 14,
		point = point or "TOPLEFT",
	}

	local icon = self._frame.icon
	icon:SetTexture(texture)
	icon:SetSize(size or 14, size or 14)
	SetAnchors(self)
end

function Widget:SetInteractive(isInteractive)
	self._state.interactive = isInteractive
	self:UpdateState()
end

function Widget:SetJustifyH(...)
	self._frame.text:SetJustifyH(...)
end

function Widget:SetJustifyV(...)
	self._frame.text:SetJustifyV(...)
end

function Widget:SetSpacing(x, y)
	self._state.spacing = {
		x = x or 4,
		y = y or 4,
	}
end

function Widget:SetText(text)
	self._frame.text:SetText(text or "")
	SetAnchors(self)
end

function Widget:SetTextColor(...)
	self._frame.text:SetTextColor(...)
end

function Widget:SetTheme(theme)
	self._state.theme = theme or {}
	addon.setNestedMetatables(self._state.theme, defaultTheme)
	lib:RegisterStateHandlers(self, self._frame, UpdateTheme)
	SetAnchors(self)
end

function Widget:SetWordWrap(canWrap)
	self._frame.text:SetWordWrap(canWrap or false)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent, "BackdropTemplate"),
	}, Widget)

	local frame = widget._frame
	frame:EnableMouse(true)
	frame.icon = frame:CreateTexture(nil, "ARTWORK")
	frame.text = frame:CreateFontString(nil, "OVERLAY")

	return widget
end)
