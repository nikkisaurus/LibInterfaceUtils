local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

addon.colors = {
	black = { 0, 0, 0, 1 },
	elvBackdrop = { 26 / 255, 26 / 255, 26 / 255, 1 },
	elvTransparent = { 15 / 255, 15 / 255, 15 / 255, 0.8 },
	gold = { 1, 0.82, 0, 1 },
	transparent = { 0, 0, 0, 0 },
	white = { 1, 1, 1, 1 },
}

addon.defaultTexture = [[INTERFACE/BUTTONS/WHITE8X8]]

addon.defaultBackdrop = {
	bgFile = addon.defaultTexture,
	edgeFile = addon.defaultTexture,
	edgeSize = 1,
}
