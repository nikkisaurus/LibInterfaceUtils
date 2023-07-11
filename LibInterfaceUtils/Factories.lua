local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function lib:GetScrollableFrame()
	local frame = lib:New("Frame")
	frame:SetLayout("fill")
	local scrollFrame = frame:New("ScrollFrame")

	return frame, scrollFrame
end

function lib:GetSimpleGroup(parent)
	local group = (parent or lib):New("Group")
	group:SetBackdrop()
	group:SetCollapsible()

	return group
end
