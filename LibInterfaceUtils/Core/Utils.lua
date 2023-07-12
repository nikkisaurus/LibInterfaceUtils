local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function addon.getPoints(anchor, spacing)
	local spacingX = addon.isTable(spacing) and spacing.x or 0
	local spacingY = addon.isTable(spacing) and spacing.y or 0

	return {
		TOP = {
			texture = { "TOP" },
			textureWidth = false,
			textureHeight = true,
			text = {
				{ "TOP", anchor, "BOTTOM", 0, -spacingY },
				{ "LEFT" },
				{ "RIGHT" },
			},
		},
		BOTTOM = {
			texture = { "BOTTOM" },
			textureWidth = false,
			textureHeight = true,
			text = {
				{ "BOTTOM", anchor, "TOP", 0, spacingY },
				{ "LEFT" },
				{ "RIGHT" },
			},
		},
		TOPLEFT = {
			texture = { "TOPLEFT" },
			textureWidth = true,
			textureHeight = false,
			text = {
				{ "TOPLEFT", anchor, "TOPRIGHT", spacingX, 0 },
				{ "TOPRIGHT" },
			},
		},
		TOPRIGHT = {
			texture = { "TOPRIGHT" },
			textureWidth = true,
			textureHeight = false,
			text = {
				{ "TOPRIGHT", anchor, "TOPLEFT", -spacingX, 0 },
				{ "TOPLEFT" },
			},
		},
		LEFT = {
			texture = { "LEFT" },
			textureWidth = true,
			textureHeight = false,
			text = {
				{ "LEFT", anchor, "RIGHT", spacingX, 0 },
				{ "RIGHT" },
			},
		},
		RIGHT = {
			texture = { "RIGHT" },
			textureWidth = true,
			textureHeight = false,
			text = {
				{ "RIGHT", anchor, "LEFT", -spacingX, 0 },
				{ "LEFT" },
			},
		},
		BOTTOMLEFT = {
			texture = { "BOTTOMLEFT" },
			textureWidth = true,
			textureHeight = false,
			text = {
				{ "BOTTOMLEFT", anchor, "BOTTOMRIGHT", spacingX, 0 },
				{ "BOTTOMRIGHT" },
			},
		},
		BOTTOMRIGHT = {
			texture = { "BOTTOMRIGHT" },
			textureWidth = true,
			textureHeight = false,
			text = {
				{ "BOTTOMRIGHT", anchor, "BOTTOMLEFT", -spacingX, 0 },
				{ "BOTTOMLEFT" },
			},
		},
	}
end

function addon.isValidString(str)
	return type(str) == "string" and str ~= "" and str
end

function addon.isTable(tbl)
	return type(tbl) == "table"
end

function addon.safecall(func, ...)
	if type(func) == "function" then
		return func(...)
	end
end

function addon.setNestedMetatables(target, source)
	setmetatable(target, { __index = source })
	for key, value in pairs(target) do
		if addon.isTable(value) and addon.isTable(source[key]) then
			addon.setNestedMetatables(value, source[key])
		end
	end
end

function addon.unpack(...)
	if addon.isTable(...) then
		return unpack(...)
	else
		return ...
	end
end
