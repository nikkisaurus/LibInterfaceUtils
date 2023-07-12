local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Button", 1, false
local Widget = { _events = {} }

local defaultTheme = {
	Disabled = {
		border = {
			enabled = true,
			size = 1,
			texture = addon.defaultTexture,
			color = { 1, 1, 1, 0.25 },
		},
		text = {
			fontObject = GameFontDisable,
		},
		texture = {
			texture = addon.defaultTexture,
			color = { 0, 0, 0, 0.25 },
		},
	},
	Highlight = {
		border = {
			enabled = true,
			size = 1,
			texture = addon.defaultTexture,
			color = addon.colors.white,
		},
		text = {
			fontObject = GameFontHighlight,
		},
		texture = {
			texture = addon.defaultTexture,
			color = addon.colors.black,
		},
	},
	Normal = {
		border = {
			enabled = true,
			size = 1,
			texture = addon.defaultTexture,
			color = addon.colors.black,
		},
		text = {
			fontObject = GameFontNormal,
		},
		texture = {
			texture = addon.defaultTexture,
			color = addon.colors.elvBackdrop,
		},
	},
	Pushed = {
		border = {
			enabled = true,
			size = 1,
			texture = addon.defaultTexture,
			color = addon.colors.gold,
		},
		text = {
			fontObject = GameFontNormal,
		},
		texture = {
			texture = addon.defaultTexture,
			color = addon.colors.elvBackdrop,
		},
	},
}

local function UpdateTheme(self)
	local frame = self._frame
	local text = frame.text
	local state = self:GetState()
	local SetTexture = frame[("Set%sTexture"):format(state)]
	local GetTexture = frame[("Get%sTexture"):format(state)]
	local theme = self._state.theme[state]
	local borderTheme, textureTheme, textTheme = theme.border, theme.texture, theme.text

	for id, border in pairs(frame.borders) do
		if borderTheme.enabled then
			if (id == "top" or id == "bottom") and (border:GetHeight() ~= borderTheme.size) then
				border:SetHeight(borderTheme.size)
			elseif border:GetWidth() ~= borderTheme.size then
				border:SetWidth(borderTheme.size)
			end

			border:SetTexture(borderTheme.texture)
			border:SetVertexColor(unpack(borderTheme.color))
			border:Show()
		else
			border:Hide()
		end
	end

	SetTexture(frame, textureTheme.texture)
	GetTexture(frame):SetVertexColor(unpack(textureTheme.color))

	if textTheme.fontObject then
		local fontObject = textTheme.fontObject
		fontObject = (addon.isTable(fontObject)) and fontObject or _G[fontObject]
		assert(fontObject.GetFont, "Invalid fontObject supplied to Button's :SetTheme().")

		text:SetFontObject(fontObject)
		text:SetTextColor(fontObject:GetTextColor())
	end

	if textTheme.font then
		text:SetFont(addon.unpack(textTheme.font))
	end

	if textTheme.color then
		text:SetTextColor(addon.unpack(textTheme.color))
	end
end

local function UpdateWidth(self)
	local frame = self._frame
	local textContainer = frame.textContainer
	local text = frame.text
	local padding = self._state.padding

	textContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", padding.left, 0)
	textContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding.right, 0)

	text:SetWidth(textContainer:GetWidth())
	text:SetHeight(textContainer:GetHeight())

	if self._state.autoWidth then
		self:SetWidth(text:GetStringWidth() + padding.left + padding.right)
	end

	if self._state.autoHeight then
		self:SetHeight(text:GetStringHeight() + padding.top + padding.bottom)
	end
end

function Widget._events:OnAcquire()
	self:SetPadding() -- must call before :SetSize to initialize padding before UpdateWidth is triggered
	self:SetSize(150, 25)
	self:SetJustifyH("CENTER")
	self:SetJustifyV("MIDDLE")
	self:SetWordWrap()
	self:SetPushedTextOffset(1, -1)
	self:SetTheme()
	self:SetText()
	self:Enable()
	self:SetAutoWidth()
	self:SetAutoHeight()
	self:Show()
end

function Widget._events:OnSizeChanged()
	UpdateWidth(self)
end

function Widget:Disable()
	self._frame:Disable()
	self:UpdateState()
end

function Widget:Enable()
	self._frame:Enable()
	self:UpdateState()
end

function Widget:IsEnabled()
	return self._frame:IsEnabled()
end

function Widget:SetAutoHeight(autoHeight)
	self._state.autoHeight = autoHeight
	UpdateWidth(self)
end

function Widget:SetAutoWidth(autoWidth)
	self._state.autoWidth = autoWidth
	UpdateWidth(self)
end

function Widget:SetJustifyH(...)
	self._frame.text:SetJustifyH(...)
end

function Widget:SetJustifyV(...)
	self._frame.text:SetJustifyV(...)
end

function Widget:SetPadding(left, right, top, bottom)
	self._state.padding = {
		left = left or 10,
		right = right or 10,
		top = top or 5,
		bottom = bottom or 5,
	}
end

function Widget:SetPushedTextOffset(...)
	self._frame:SetPushedTextOffset(...)
end

function Widget:SetText(text)
	self._frame.text:SetText(text or "")
	UpdateWidth(self)
end

function Widget:SetTheme(theme)
	self._state.theme = theme or {}
	addon.setNestedMetatables(self._state.theme, defaultTheme)
	lib:RegisterStateHandlers(self, self._frame, UpdateTheme)
	UpdateWidth(self)
end

function Widget:SetWordWrap(canWrap)
	self._frame.text:SetWordWrap(canWrap or false)
	UpdateWidth(self)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Button", lib:GenerateWidgetName(widgetType), UIParent, "BackdropTemplate"),
	}, Widget)

	local frame = widget._frame

	local borders = {
		top = frame:CreateTexture(nil, "OVERLAY"),
		left = frame:CreateTexture(nil, "OVERLAY"),
		right = frame:CreateTexture(nil, "OVERLAY"),
		bottom = frame:CreateTexture(nil, "OVERLAY"),
	}

	borders.top:SetPoint("TOPLEFT")
	borders.top:SetPoint("TOPRIGHT")
	borders.left:SetPoint("TOPLEFT")
	borders.left:SetPoint("BOTTOMLEFT")
	borders.right:SetPoint("TOPRIGHT")
	borders.right:SetPoint("BOTTOMRIGHT")
	borders.bottom:SetPoint("BOTTOMLEFT")
	borders.bottom:SetPoint("BOTTOMRIGHT")

	-- By setting the text's parent to the textContainer, we can control the width and height of the text
	-- independently of the frame's size.
	-- This is being done to allow the button to resize based on its text width while also truncating the
	-- text if it fills its parent container due to a lack of available width.
	local textContainer = CreateFrame("Frame", nil, frame)
	local text = textContainer:CreateFontString(nil, "OVERLAY")
	frame:SetFontString(text)

	frame.borders = borders
	frame.text = text
	frame.textContainer = textContainer

	return widget
end)
