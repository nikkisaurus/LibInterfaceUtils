local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Constants ***
-- *******************************

local TEXTURES = {
	Disabled = {
		border = {
			enabled = true,
			size = 1,
			texture = lib.defaultTexture,
			color = { 1, 1, 1, 0.25 },
		},
		text = {
			fontObject = "GameFontDisable",
		},
		texture = {
			texture = lib.defaultTexture,
			color = { 0, 0, 0, 0.25 },
		},
	},
	Highlight = {
		border = {
			enabled = true,
			size = 1,
			texture = lib.defaultTexture,
			color = lib.colors.white,
		},
		text = {
			fontObject = "GameFontHighlight",
		},
		texture = {
			texture = lib.defaultTexture,
			color = lib.colors.black,
		},
	},
	Normal = {
		border = {
			enabled = true,
			size = 1,
			texture = lib.defaultTexture,
			color = lib.colors.black,
		},
		text = {
			fontObject = "GameFontNormal",
		},
		texture = {
			texture = lib.defaultTexture,
			color = lib.colors.elvBackdrop,
		},
	},
	Pushed = {
		border = {
			enabled = true,
			size = 1,
			texture = lib.defaultTexture,
			color = lib.colors.gold,
		},
		text = {
			fontObject = "GameFontNormal",
		},
		texture = {
			texture = lib.defaultTexture,
			color = lib.colors.elvBackdrop,
		},
	},
}

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Button", 1

local tex
local widget = {
	OnAcquire = function(self)
		self:SetSize(150, 25)
		self:SetJustifyH("CENTER")
		self:SetJustifyV("MIDDLE")
		self:SetWordWrap()
		self:SetPushedTextOffset(1, -1)
		self:SetTextures()
		self:SetText()
		self:Enable()
		self:Show()
	end,

	OnClick = function(self) end,

	OnEnter = function(self)
		self.state.highlight = true
		self:UpdateState()
	end,

	OnLeave = function(self)
		self.state.highlight = false
		self:UpdateState()
	end,

	OnMouseDown = function(self)
		self.state.pushed = true
		self:UpdateState()
	end,

	OnMouseUp = function(self)
		self.state.pushed = false
		self:UpdateState()
	end,

	Disable = function(self)
		self._frame:Disable()
		self:UpdateState()
	end,

	Enable = function(self)
		self._frame:Enable()
		self:UpdateState()
	end,

	-- SetAutoHeight = function(self, autoHeight)
	-- 	self.state.autoHeight = autoHeight
	-- 	self:SetAnchors()
	-- end,

	SetJustifyH = function(self, ...)
		self._frame.text:SetJustifyH(...)
	end,

	SetJustifyV = function(self, ...)
		self._frame.text:SetJustifyV(...)
	end,

	SetPushedTextOffset = function(self, ...)
		self._frame:SetPushedTextOffset(...)
	end,

	SetText = function(self, text)
		self.state.text = text
		self._frame.text:SetText(text or "")
	end,

	SetTextures = function(self, textures)
		self.state.textures = textures or {}
		lib:SetMetatables(self.state.textures, TEXTURES)
		self:UpdateState()
	end,

	SetWordWrap = function(self, canWrap)
		self.state.canWrap = canWrap or false
		self._frame.text:SetWordWrap(canWrap or false)
	end,

	UpdateState = function(self)
		local state = not self._frame:IsEnabled() and "Disabled"
			or (self.state.pushed and "Pushed")
			or (self.state.highlight and "Highlight")
			or "Normal"
		local template = self.state.textures[state]

		for id, border in pairs(self.borders) do
			local borderTemplate = template.border
			if borderTemplate.enabled then
				if (id == "top" or id == "bottom") and (border:GetHeight() ~= borderTemplate.size) then
					border:SetHeight(borderTemplate.size)
				elseif border:GetWidth() ~= borderTemplate.size then
					border:SetWidth(borderTemplate.size)
				end

				border:SetTexture(borderTemplate.texture)
				border:SetVertexColor(unpack(borderTemplate.color))
				border:Show()
			else
				border:Hide()
			end
		end

		local set = self._frame[("Set%sTexture"):format(state)]
		set(self._frame, template.texture.texture)
		local get = self._frame[("Get%sTexture"):format(state)]
		get(self._frame):SetVertexColor(unpack(template.texture.color))

		lib:SetFont(self._frame.text, template.text)
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

lib:RegisterWidget(widgetType, version, false, function(pool)
	local frame = CreateFromMixins({
		_frame = CreateFrame("Button", lib:GetNextWidget(widgetType), UIParent, "BackdropTemplate"),
	}, widget)

	frame.borders = {
		top = frame._frame:CreateTexture(nil, "OVERLAY"),
		left = frame._frame:CreateTexture(nil, "OVERLAY"),
		right = frame._frame:CreateTexture(nil, "OVERLAY"),
		bottom = frame._frame:CreateTexture(nil, "OVERLAY"),
	}

	frame.borders.top:SetPoint("TOPLEFT")
	frame.borders.top:SetPoint("TOPRIGHT")
	frame.borders.left:SetPoint("TOPLEFT")
	frame.borders.left:SetPoint("BOTTOMLEFT")
	frame.borders.right:SetPoint("TOPRIGHT")
	frame.borders.right:SetPoint("BOTTOMRIGHT")
	frame.borders.bottom:SetPoint("BOTTOMLEFT")
	frame.borders.bottom:SetPoint("BOTTOMRIGHT")

	frame._frame.text = frame._frame:CreateFontString(nil, "OVERLAY")
	frame._frame.text:SetAllPoints(frame._frame)
	frame._frame:SetFontString(frame._frame.text)

	-- frame._frame:SetScript("OnEnter", function()
	-- 	local borders = frame.state.textures.border
	-- 	if borders then
	-- 		for _, border in pairs(frame.borders) do
	-- 			border:SetVertexColor(unpack(borders[4]))
	-- 		end
	-- 	end
	-- end)

	-- frame._frame:SetScript("OnLeave", function()
	-- 	local borders = frame.state.textures.border
	-- 	if borders then
	-- 		for _, border in pairs(frame.borders) do
	-- 			border:SetVertexColor(unpack(borders[1]))
	-- 		end
	-- 	end
	-- end)

	-- frame._frame:SetScript("OnMouseDown", function()
	-- 	local borders = frame.state.textures.border
	-- 	if borders then
	-- 		for _, border in pairs(frame.borders) do
	-- 			border:SetVertexColor(unpack(borders[5]))
	-- 		end
	-- 	end
	-- end)

	-- frame._frame:SetScript("OnMouseUp", function()
	-- 	local borders = frame.state.textures.border
	-- 	if borders then
	-- 		for _, border in pairs(frame.borders) do
	-- 			border:SetVertexColor(unpack(borders[GetMouseFocus() == frame.frame and 4 or 1]))
	-- 		end
	-- 	end
	-- end)

	return frame
end)
