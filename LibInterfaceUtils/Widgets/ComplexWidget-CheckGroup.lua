local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "CheckGroup", 1, true
local Widget = { _events = {} }

function Widget._events:_OnAcquire()
	self._state.options = {}
	self:SetMultiselect()
end

function Widget:AddOption(option, pos)
	assert(addon.isTable(option), "Invalid option table supplied to CheckGroup:AddOption().")

	local button = self:New("CheckButton")
	button:SetText(option.text or ("Option " .. (#self._state.options + 1)))
	button:SetCheckStyle(not self._state.multiselect and "radio")
	button:SetChecked((self._state.multiselect or not self:GetChecked()) and addon.safecall(option.checked))
	if addon.safecall(option.disabled) then
		button:Disable()
	else
		button:Enable()
	end

	button:RegisterCallback("OnClick", function(...)
		self:ClearSelected(button:GetChecked() and button)
		addon.safecall(option.onClick, ...)
	end)

	tinsert(self._state.options, button)
	if pos then
		self:MoveChild(#self._state.options, pos)
	end

	return button
end

function Widget:AddOptions(...)
	for _, option in ipairs({ ... }) do
		self:AddOption(option)
	end
end

function Widget:ClearSelected(ignoreButton)
	if self._state.multiselect then
		return
	end

	for _, button in ipairs(self._state.options) do
		if button ~= ignoreButton then
			button:SetChecked()
		end
	end
end

function Widget:GetChecked()
	local checked = {}
	for id, button in ipairs(self._state.options) do
		if button:GetChecked() then
			tinsert(checked, id)
		end
	end
	return unpack(checked)
end

function Widget:GetOption(key)
	return self._state.options[key]
end

function Widget:SetChecked(id, checked, force)
	local button = self:GetOption(id)
	assert(button, "Invalid option id supplied to CheckGroup:SetChecked()")
	if button:IsEnabled() or force then
		button:SetChecked(checked)
		self:ClearSelected(button)
	end
end

function Widget:SetMultiselect(multiselect)
	self._state.multiselect = multiselect

	for _, button in ipairs(self._state.options) do
		button:SetCheckStyle(not multiselect and "radio")
	end
end

lib:RegisterWidget(widgetType, version, isContainer, function()
	local Group = lib:New("Group")
	local widget = addon.mixin({}, Widget, Group)

	return widget
end)
