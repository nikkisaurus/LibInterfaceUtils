local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "Button", 1, false
local Widget = { _events = {} }

local defaultTemplate = {
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

local function UpdateState(self)
	local frame = self._frame
	local text = frame.text

	local state = (not frame:IsEnabled()) and "Disabled"
		or (self._state.pushed and "Pushed")
		or (self._state.highlight and "Highlight")
		or "Normal"

	local SetTexture = frame[("Set%sTexture"):format(state)]
	local GetTexture = frame[("Get%sTexture"):format(state)]

	local template = self._state.template[state]
	local borderTemplate, textureTemplate, textTemplate = template.border, template.texture, template.text

	for id, border in pairs(frame.borders) do
		if borderTemplate.enabled then
			if (id == "top" or id == "bottom") and (border:GetHeight() ~= borderTemplate.size) then
				border:SetHeight(borderTemplate.size)
			elseif border:GetWidth() ~= borderTemplate.size then
				border:SetWidth(borderTemplate.size)
			end

			border:SetTexture(borderTemplate.texture)
			border:SetVertexColor(unpack(borderTemplate.color))
			border:Show()
		else
			border:Hide()
		end
	end

	SetTexture(frame, textureTemplate.texture)
	GetTexture(frame):SetVertexColor(unpack(textureTemplate.color))

	if textTemplate.fontObject then
		local fontObject = textTemplate.fontObject
		fontObject = (addon.isTable(fontObject)) and fontObject or _G[fontObject]
		assert(fontObject.GetFont, "Invalid fontObject supplied to Button's :SetTemplate().")

		text:SetFontObject(fontObject)
		text:SetTextColor(fontObject:GetTextColor())
	end

	if textTemplate.font then
		text:SetFont(addon.unpack(textTemplate.font))
	end

	if textTemplate.color then
		text:SetTextColor(addon.unpack(textTemplate.color))
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
	self:SetTemplate()
	self:SetText()
	self:Enable()
	self:SetAutoWidth()
	self:SetAutoHeight()
	self:Show()
end

function Widget._events:OnClick() end

function Widget._events:OnEnter()
	self._state.highlight = true
	UpdateState(self)
end

function Widget._events:OnLeave()
	self._state.highlight = false
	UpdateState(self)
end

function Widget._events:OnMouseDown()
	self._state.pushed = true
	UpdateState(self)
end

function Widget._events:OnMouseUp()
	self._state.pushed = false
	UpdateState(self)
end

function Widget._events:OnSizeChanged()
	UpdateWidth(self)
end

function Widget:Disable()
	self._frame:Disable()
	UpdateState(self)
end

function Widget:Enable()
	self._frame:Enable()
	UpdateState(self)
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

function Widget:SetTemplate(template)
	self._state.template = template or {}
	addon.setNestedMetatables(self._state.template, defaultTemplate)
	UpdateWidth(self)
	UpdateState(self)
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
