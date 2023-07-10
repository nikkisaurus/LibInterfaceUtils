local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Constants ***
-- *******************************

local TEXTURE = function(frame)
	local texture = frame:CreateTexture(nil)
end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Button", 1

local widget = {
	OnAcquire = function(self)
		self:SetSize(150, 25)
		self:SetFontObject(GameFontNormal)
		self:SetJustifyH("CENTER")
		self:SetJustifyV("MIDDLE")
		self:SetWordWrap()
		self:SetText()
		self:Show()
	end,

	-- SetAutoHeight = function(self, autoHeight)
	-- 	self.state.autoHeight = autoHeight
	-- 	self:SetAnchors()
	-- end,

	SetFontObject = function(self, ...)
		self._frame.text:SetFontObject(...)
	end,

	SetJustifyH = function(self, ...)
		self._frame.text:SetJustifyH(...)
	end,

	SetJustifyV = function(self, ...)
		self._frame.text:SetJustifyV(...)
	end,

	SetText = function(self, text)
		self.state.text = text
		self._frame.text:SetText(text or "")
	end,

	SetWordWrap = function(self, canWrap)
		self.state.canWrap = canWrap or false
		self._frame.text:SetWordWrap(canWrap or false)
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

local mt = {
	__index = widget,
}

lib:RegisterWidget(widgetType, version, false, function(pool)
	local frame = setmetatable({
		_frame = CreateFrame("Button", lib:GetNextWidget(pool), UIParent, "BackdropTemplate"),
	}, mt)

	frame._frame.text = frame._frame:CreateFontString(nil, "OVERLAY")
	frame._frame.text:SetAllPoints(frame._frame)

	frame._frame:SetNormalTexture([[INTERFACE/BUTTONS/WHITE8x8]])
	frame._frame:GetNormalTexture():SetVertexColor(0, 0, 0, 0.75)

	return frame
end)
