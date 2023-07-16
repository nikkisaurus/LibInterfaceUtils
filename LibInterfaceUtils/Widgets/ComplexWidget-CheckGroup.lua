local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local widgetType, version, isContainer = "CheckGroup", 1, false
local Widget = { _events = {} }


function Widget._events:OnAcquire()
    -- self._events:_OnAcquire()
    self:Fire("_OnAcquire")
-- 	self:SetSpacing()
-- 	self:SetCheck()
	-- self:SetSize(150, 25)
-- 	self:SetAutoWidth(true)
-- 	self:SetTheme()
-- 	self:SetIcon()
-- 	self:SetCheckStyle()
-- 	self:SetChecked()
-- 	self:Enable()
	-- self:Show()

    -- self._frame.group:Fire("OnAcquire")
    -- local check = self._frame.group:New("CheckButton")
	-- 	check:SetText("Check button " .. 1)

-- 	local text = self._frame.text
-- 	text:Fire("OnAcquire")
-- 	text:SetInteractive(GenerateClosure(ToggleChecked, self))
-- 	text:SetTheme({ Disabled = { fontObject = GameFontDisable } })
end

-- function Widget:SetTitle(...)
--     self._frame.group:SetTitle(...)
-- end


lib:RegisterWidget(widgetType, version, isContainer, function()
    local Group = lib:New("Group")
    local widget = CreateFromMixins(Widget, Group)
    -- Widget._events._OnAcquire = widget._events.OnAcquire
    -- widget._events = Mixin(widget._events, Widget._events)
	-- local widget = CreateFromMixins({
	-- 	_frame = CreateFrame("Frame", lib:GenerateWidgetName(widgetType), UIParent),
	-- }, Widget)

	-- local frame = widget._frame

    -- local group = lib:New("Group")
	-- group._frame:SetParent(frame)
    -- group._frame:SetAllPoints(frame)
    -- group:RegisterCallback("OnSizeChanged", function()
    --    widget:SetSize(group._frame:GetWidth(), group._frame:GetHeight())
    -- end)

	-- -- Using a Label widget due to the complexities it already has implemented, such as the
	-- -- ability to add and move an icon.
	-- local text = lib:New("Label")
	-- text:RegisterCallback("OnMouseDown", function()
	-- 	widget:Fire("OnClick")
	-- end)
	-- text._frame:SetParent(frame)

	-- -- It's not necessary to use Texture widgets since it is simple to work with already.
	-- local checkBox = frame:CreateTexture(nil, "BACKGROUND")

	-- local check = frame:CreateTexture(nil, "ARTWORK")
	-- check:SetAllPoints(checkBox)

	-- frame.checkBox = checkBox
	-- frame.check = check
	-- frame.text = text
    -- frame.group = group

	return widget
end)
