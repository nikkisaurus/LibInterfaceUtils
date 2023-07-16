local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "CheckButton", 1, false
local Widget = { _events = {} }

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

local function ToggleChecked(self)
	if self:GetChecked() then
		self:SetChecked(false)
	else
		self:SetChecked(true)
	end
end

function Widget._events:OnAcquire()
	self:SetSpacing()
	self:SetCheck()
	self:SetSize(150, 25)
	self:SetAutoWidth(true)
	self:SetTheme()
	self:SetIcon()
	self:SetCheckStyle()
	self:SetChecked()
	self:Enable()
	self:Show()

	local text = self._frame.text
	text:Fire("OnAcquire")
	text:SetInteractive(GenerateClosure(ToggleChecked, self))
	text:SetTheme({ Disabled = { fontObject = GameFontDisable } })
end

function Widget._events:OnClick()
	self._state.checked = not self._state.checked
	self:SetChecked(self._state.checked)
end

function Widget._events:OnSizeChanged()
	SetAnchors(self)
end

function Widget:Disable()
	local frame = self._frame
	frame:Disable()
	if self._state.checkStyle == "radio" then
		frame.check:SetDesaturated(true)
	else
		frame.check:SetDesaturated(false)
		frame.check:SetAtlas("checkmark-minimal-disabled")
	end
	frame.text:SetInteractive()
	self:UpdateState()
end

function Widget:Enable()
	local frame = self._frame
	frame:Enable()
	frame.check:SetDesaturated(false)
	frame.check:SetAtlas(self._state.checkStyle == "radio" and "common-radiobutton-dot" or "checkmark-minimal")
	frame.text:SetInteractive(GenerateClosure(ToggleChecked, self))
	self:UpdateState()
end

function Widget:GetChecked()
	return self._state.checked
end

function Widget:IsEnabled()
	return self._frame:IsEnabled()
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

function Widget:SetCheckStyle(style)
	self._state.checkStyle = style
	local frame = self._frame
	frame.check:SetDesaturated(false)
	frame.check:SetAtlas(style == "radio" and "common-radiobutton-dot" or "checkmark-minimal")
	frame.checkBox:SetAtlas(style == "radio" and "common-radiobutton-circle" or "checkbox-minimal")
end

function Widget:SetChecked(isChecked)
	self._state.checked = isChecked
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

function Widget:SetTheme(...)
	self._frame.text:SetTheme(...)
end

function Widget:SetWordWrap(canWrap)
	self._frame.text:SetWordWrap(canWrap or false)
	SetAnchors(self)
end

function Widget:UpdateState()
	self._frame.text:UpdateState()
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local widget = CreateFromMixins({
		_frame = CreateFrame("Button", lib:GenerateWidgetName(widgetType), UIParent),
	}, Widget)

	local frame = widget._frame

	-- Using a Label widget due to the complexities it already has implemented, such as the
	-- ability to add and move an icon.
	local text = lib:New("Label")
	text:RegisterCallback("OnMouseDown", function()
		widget:Fire("OnClick")
	end)
	text._frame:SetParent(frame)

	-- It's not necessary to use Texture widgets since it is simple to work with already.
	local checkBox = frame:CreateTexture(nil, "BACKGROUND")

	local check = frame:CreateTexture(nil, "ARTWORK")
	check:SetAllPoints(checkBox)

	frame.checkBox = checkBox
	frame.check = check
	frame.text = text

	return widget
end)
