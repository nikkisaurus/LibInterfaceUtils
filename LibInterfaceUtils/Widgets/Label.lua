local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Constants ***
-- *******************************

local POINTS = function(icon)
	return {
		TOP = {
			icon = { "TOP" },
			iconWidth = false,
			iconHeight = true,
			text = {
				{ "TOP", icon, "BOTTOM", 0, 0 },
				{ "LEFT" },
				{ "RIGHT" },
			},
		},
		BOTTOM = {
			icon = { "BOTTOM" },
			iconWidth = false,
			iconHeight = true,
			text = {
				{ "BOTTOM", icon, "TOP", 0, 0 },
				{ "LEFT" },
				{ "RIGHT" },
			},
		},
		TOPLEFT = {
			icon = { "TOPLEFT" },
			iconWidth = true,
			iconHeight = false,
			text = {
				{ "TOPLEFT", icon, "TOPRIGHT", 0, 0 },
				{ "TOPRIGHT" },
			},
		},
		TOPRIGHT = {
			icon = { "TOPRIGHT" },
			iconWidth = true,
			iconHeight = false,
			text = {
				{ "TOPRIGHT", icon, "TOPLEFT", 0, 0 },
				{ "TOPLEFT" },
			},
		},
		LEFT = {
			icon = { "LEFT" },
			iconWidth = true,
			iconHeight = false,
			text = {
				{ "LEFT", icon, "RIGHT", 0, 0 },
				{ "RIGHT" },
			},
		},
		RIGHT = {
			icon = { "RIGHT" },
			iconWidth = true,
			iconHeight = false,
			text = {
				{ "RIGHT", icon, "LEFT", 0, 0 },
				{ "LEFT" },
			},
		},
		BOTTOMLEFT = {
			icon = { "BOTTOMLEFT" },
			iconWidth = true,
			iconHeight = false,
			text = {
				{ "BOTTOMLEFT", icon, "BOTTOMRIGHT", 0, 0 },
				{ "BOTTOMRIGHT" },
			},
		},
		BOTTOMRIGHT = {
			icon = { "BOTTOMRIGHT" },
			iconWidth = true,
			iconHeight = false,
			text = {
				{ "BOTTOMRIGHT", icon, "BOTTOMLEFT", 0, 0 },
				{ "BOTTOMLEFT" },
			},
		},
	}
end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Label", 1

local widget = {
	OnAcquire = function(self)
		self:SetSize(100, 0)
		self:SetFontObject(GameFontHighlight)
		self:SetJustifyH("LEFT")
		self:SetJustifyV("MIDDLE")
		self:SetWordWrap(true)
		self:SetIcon()
		self:SetText()
		self:SetAutoWidth(true)
		self:Show()
	end,

	SetAnchors = function(self)
		local point, size
		if self.state.icon.texture then
			point = self.state.icon.point
			size = self.state.icon.size
		end

		local icon = self._frame.icon
		icon:ClearAllPoints()
		icon:Hide()

		local text = self._frame.text
		text:ClearAllPoints()

		if point then
			local points = POINTS(icon)[point]
			icon:SetPoint(unpack(points.icon))
			text:SetPoint(unpack(points.text[1]))

			if self.state.autoWidth and not self.state.fullWidth then
				text:SetWidth(text:GetStringWidth())
				self:SetWidth((points.iconWidth and size or 0) + text:GetWidth())
			else
				text:SetWidth(self:GetWidth() - (points.iconWidth and size or 0))
			end

			text:SetPoint(unpack(points.text[2]))
			if points.text[3] then text:SetPoint(unpack(points.text[3])) end
			self:SetHeight(max(size, (points.iconHeight and size or 0) + text:GetStringHeight()))

			icon:Show()
		else
			text:SetPoint("TOPLEFT")

			if self.state.autoWidth and not self.state.fullWidth then
				text:SetWidth(text:GetStringWidth())
				self:SetWidth(text:GetWidth())
			else
				text:SetWidth(self:GetWidth())
			end

			text:SetPoint("TOPRIGHT")
			self:SetHeight(text:GetStringHeight())
		end
	end,

	SetAutoHeight = function(self, autoHeight)
		self.state.autoHeight = autoHeight
		self:SetAnchors()
	end,

	SetAutoWidth = function(self, autoWidth)
		self.state.autoWidth = autoWidth
		self:SetAnchors()
	end,

	SetFontObject = function(self, ...)
		self._frame.text:SetFontObject(...)
	end,

	SetJustifyH = function(self, ...)
		self._frame.text:SetJustifyH(...)
	end,

	SetJustifyV = function(self, ...)
		self._frame.text:SetJustifyV(...)
	end,

	SetIcon = function(self, texture, size, point)
		self.state.icon = {
			texture = texture ~= "" and texture,
			size = size or 14,
			point = point or "TOPLEFT",
		}

		local icon = self._frame.icon
		icon:SetTexture(texture)
		icon:SetSize(size or 14, size or 14)
		self:SetAnchors()
	end,

	SetText = function(self, text)
		self.state.text = text
		self._frame.text:SetText(text or "")
		self:SetAnchors()
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
		_frame = CreateFrame("Frame", lib:GetNextWidget(pool), UIParent, "BackdropTemplate"),
	}, mt)

	frame._frame.icon = frame._frame:CreateTexture(nil, "ARTWORK")
	frame._frame.text = frame._frame:CreateFontString(nil, "OVERLAY")

	frame._frame:SetBackdrop({
		bgFile = [[INTERFACE/BUTTONS/WHITE8X8]],
	})
	frame._frame:SetBackdropColor(0, 1, 0, 0.75)

	return frame
end)
