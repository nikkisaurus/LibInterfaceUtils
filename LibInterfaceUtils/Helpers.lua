local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

lib.colors = {
	black = { 0, 0, 0, 1 },
	gold = { 1, 0.82, 0, 1 },
	elvBackdrop = { 26 / 255, 26 / 255, 26 / 255, 1 },
	elvTransparent = { 15 / 255, 15 / 255, 15 / 255, 0.8 },
	white = { 1, 1, 1, 1 },
}

lib.defaultTexture = [[INTERFACE/BUTTONS/WHITE8X8]]

lib.defaultBackdrop = {
	bgFile = lib.defaultTexture,
	edgeFile = lib.defaultTexture,
	edgeSize = 1,
}

function lib:IsStringValid(str)
	return type(str) == "string" and str ~= "" and str
end

function lib:safecall(func, ...)
	if type(func) == "function" then return func(...) end
end

function lib:SetFont(fontString, font)
	if font.font then fontString:SetFont(unpack(font.font)) end

	if font.fontObject then
		local fontObject = _G[font.fontObject] or font.fontObject
		fontString:SetFont(fontObject:GetFont())
		fontString:SetFontObject(fontObject)
	end

	if font.color then fontString:SetTextColor(unpack(font.color)) end
end

function lib:SetMetatables(target, source)
	setmetatable(target, { __index = source })
	for key, value in pairs(target) do
		if type(value) == "table" and type(source[key]) == "table" then lib:SetMetatables(value, source[key]) end
	end
end
