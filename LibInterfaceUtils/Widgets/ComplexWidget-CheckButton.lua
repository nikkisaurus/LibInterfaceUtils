local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "CheckButton", 1, false
local Widget = { _events = {} }

-- local defaultTemplate = {
-- 	Disabled = {
-- 		border = {
-- 			enabled = true,
-- 			size = 1,
-- 			texture = addon.defaultTexture,
-- 			color = { 1, 1, 1, 0.25 },
-- 		},
-- 		text = {
-- 			fontObject = GameFontDisable,
-- 		},
-- 		texture = {
-- 			texture = addon.defaultTexture,
-- 			color = { 0, 0, 0, 0.25 },
-- 		},
-- 	},
-- 	Highlight = {
-- 		border = {
-- 			enabled = true,
-- 			size = 1,
-- 			texture = addon.defaultTexture,
-- 			color = addon.colors.white,
-- 		},
-- 		text = {
-- 			fontObject = GameFontHighlight,
-- 		},
-- 		texture = {
-- 			texture = addon.defaultTexture,
-- 			color = addon.colors.black,
-- 		},
-- 	},
-- 	Normal = {
-- 		border = {
-- 			enabled = true,
-- 			size = 1,
-- 			texture = addon.defaultTexture,
-- 			color = addon.colors.black,
-- 		},
-- 		text = {
-- 			fontObject = GameFontNormal,
-- 		},
-- 		texture = {
-- 			texture = addon.defaultTexture,
-- 			color = addon.colors.elvBackdrop,
-- 		},
-- 	},
-- 	Pushed = {
-- 		border = {
-- 			enabled = true,
-- 			size = 1,
-- 			texture = addon.defaultTexture,
-- 			color = addon.colors.gold,
-- 		},
-- 		text = {
-- 			fontObject = GameFontNormal,
-- 		},
-- 		texture = {
-- 			texture = addon.defaultTexture,
-- 			color = addon.colors.elvBackdrop,
-- 		},
-- 	},
-- }

local function SetAnchors(self)
	local state = self._state
	local point = state.check.point
	local size = state.check.size
	local spacing = state.spacing
	local checkBox = self._frame.checkBox
	local text = self._frame.text
	local points = addon.getPoints(checkBox, spacing)[point]

	checkBox:SetSize(size, size)
	checkBox:ClearAllPoints()
	checkBox:SetPoint(unpack(points.texture))

	text:ClearAllPoints()
	text:SetPoint(unpack(points.text[1]))

	if state.autoWidth and not state.fullWidth and not state.availableWidth then
		self:SetWidth((points.textureWidth and (size + spacing.x) or 0) + text:GetWidth())
	else
		text:SetWidth(self:GetWidth() - (points.textureWidth and (size + spacing.x) or 0))
	end

	text:SetPoint(unpack(points.text[2]))
	if points.text[3] then
		text:SetPoint(unpack(points.text[3]))
	end

	self:SetHeight(max(size, (points.textureHeight and (size + spacing.y) or 0) + text:GetHeight()))
end

-- local function UpdateState(self)
-- 	local frame = self._frame
-- 	local text = frame.text

-- 	local state = (not frame:IsEnabled()) and "Disabled"
-- 		or (self._state.pushed and "Pushed")
-- 		or (self._state.highlight and "Highlight")
-- 		or "Normal"

-- 	local SetTexture = frame[("Set%sTexture"):format(state)]
-- 	local GetTexture = frame[("Get%sTexture"):format(state)]

-- 	local template = self._state.template[state]
-- 	local borderTemplate, textureTemplate, textTemplate = template.border, template.texture, template.text

-- 	for id, border in pairs(frame.borders) do
-- 		if borderTemplate.enabled then
-- 			if (id == "top" or id == "bottom") and (border:GetHeight() ~= borderTemplate.size) then
-- 				border:SetHeight(borderTemplate.size)
-- 			elseif border:GetWidth() ~= borderTemplate.size then
-- 				border:SetWidth(borderTemplate.size)
-- 			end

-- 			border:SetTexture(borderTemplate.texture)
-- 			border:SetVertexColor(unpack(borderTemplate.color))
-- 			border:Show()
-- 		else
-- 			border:Hide()
-- 		end
-- 	end

-- 	SetTexture(frame, textureTemplate.texture)
-- 	GetTexture(frame):SetVertexColor(unpack(textureTemplate.color))

-- 	if textTemplate.fontObject then
-- 		local fontObject = textTemplate.fontObject
-- 		fontObject = (addon.isTable(fontObject)) and fontObject or _G[fontObject]
-- 		assert(fontObject.GetFont, "Invalid fontObject supplied to Button's :SetTemplate().")

-- 		text:SetFontObject(fontObject)
-- 		text:SetTextColor(fontObject:GetTextColor())
-- 	end

-- 	if textTemplate.font then
-- 		text:SetFont(addon.unpack(textTemplate.font))
-- 	end

-- 	if textTemplate.color then
-- 		text:SetTextColor(addon.unpack(textTemplate.color))
-- 	end
-- end

function Widget._events:OnAcquire()
	self:SetSpacing()
	self:SetCheck()
	self:SetSize(150, 25)
	self:SetAutoWidth(true)
	self:SetPushedTextOffset(0, 0)
	-- self:SetTemplate()
	self:SetIcon() -- TODO remove
	self:SetChecked()
	self:Enable()
	self:Show()

	local text = self._frame.text
	text:Fire("OnAcquire")
	text:SetInteractive()
end

function Widget._events:OnClick()
	self._state.checked = not self._state.checked
	self:SetChecked(self._state.checked)
end

-- function Widget._events:OnEnter()
-- 	self._state.highlight = true
-- 	UpdateState(self)
-- end

-- function Widget._events:OnLeave()
-- 	self._state.highlight = false
-- 	UpdateState(self)
-- end

-- function Widget._events:OnMouseDown()
-- 	self._state.pushed = true
-- 	UpdateState(self)
-- end

-- function Widget._events:OnMouseUp()
-- 	self._state.pushed = false
-- 	UpdateState(self)
-- end

function Widget._events:OnSizeChanged()
	SetAnchors(self)
end

function Widget:Disable()
	local frame = self._frame
	frame:Disable()
	frame.check:SetAtlas("checkmark-minimal-disabled")
	-- UpdateState(self)
end

function Widget:Enable()
	local frame = self._frame
	frame:Enable()
	frame.check:SetAtlas("checkmark-minimal")
	-- UpdateState(self)
end

function Widget:SetAutoWidth(autoWidth)
	self._state.autoWidth = autoWidth
	SetAnchors(self)
	self._frame.text:SetAutoWidth(autoWidth)
end

function Widget:SetCheck(point, size)
	self._state.check = {
		point = point or "LEFT",
		size = size or 14,
	}
	SetAnchors(self)
end

function Widget:SetChecked(isChecked)
	self._frame.check[isChecked and "Show" or "Hide"](self._frame.check)
end

function Widget:SetFont(...)
	self._frame.text:SetFont(...)
end

function Widget:SetFontObject(...)
	self._frame.text:SetFontObject(...)
end

function Widget:SetIcon(...)
	self._frame.text:SetIcon(...)
end

function Widget:SetJustifyH(...)
	self._frame.text:SetJustifyH(...)
end

function Widget:SetJustifyV(...)
	self._frame.text:SetJustifyV(...)
end

function Widget:SetPushedTextOffset(...)
	self._frame:SetPushedTextOffset(...)
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

-- function Widget:SetTemplate(template)
-- 	self._state.template = template or {}
-- 	addon.setNestedMetatables(self._state.template, defaultTemplate)
-- 	UpdateWidth(self)
-- 	UpdateState(self)
-- end

function Widget:SetWordWrap(canWrap)
	self._frame.text:SetWordWrap(canWrap or false)
	SetAnchors(self)
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Button", lib:GenerateWidgetName(widgetType), UIParent),
	}, Widget)

	local frame = widget._frame

	-- Using a Label widget due to the complexities it already has implemented, such as the
	-- ability to add and move an icon.
	local text = lib:New("Label")
	text:SetInteractive()
	text._frame:SetParent(frame)
	-- frame:SetFontString(text._frame.text)

	-- It's not necessary to use Texture widgets since it is simple to work with already.
	local checkBox = frame:CreateTexture(nil, "BACKGROUND")
	checkBox:SetAtlas("checkbox-minimal")

	local check = frame:CreateTexture(nil, "ARTWORK")
	check:SetAllPoints(checkBox)

	frame.checkBox = checkBox
	frame.check = check
	frame.text = text

	return widget
end)
