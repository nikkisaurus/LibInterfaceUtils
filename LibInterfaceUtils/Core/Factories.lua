local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function lib:GetScrollableFrame()
	local frame = self:New("Frame")
	frame:SetLayout("fill")

	local scrollFrame = frame:New("ScrollFrame")
	scrollFrame:SetPadding(0, 0, 0, 0)

	return frame, scrollFrame
end

function lib:GetCollapsibleGroup(parent, collapse)
	local group = (parent or self):New("Group")
	group:SetTitlebarBackdrop(addon.defaultBackdrop)
	group:SetTitlebarBackdropColor(unpack(addon.colors.elvTransparent))
	group:SetTitlebarBackdropBorderColor(unpack(addon.colors.black))
	group:SetCollapsible(true)
	group:SetCollapsed(collapse)

	return group
end

function lib:GetSimpleGroup(parent)
	local group = (parent or self):New("Group")
	group:SetPadding(0, 0, 0, 0)
	group:SetContentBackdrop()

	return group
end
