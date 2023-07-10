local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Group", 1

local widget = {
	OnAcquire = function(self)
		self:SetSize(300, 200)
		self:SetPadding(5, 5, 5, 5)
		self:SetSpacing(5, 5)
		self:SetFont()
		self:SetJustifyH()
		self:SetJustifyV()
		self:SetTitle()
		self:SetBackdrop(lib.defaultBackdrop)
		self:SetBackdropColor(unpack(lib.colors.elvTransparent))
		self:SetBackdropBorderColor(unpack(lib.colors.black))
		self:SetAutoHeight(true)
		self:SetCollapsible(true)
		self:Show()
	end,

	OnLayoutFinished = function(self, _, height)
		if self.state.autoHeight then
			local padding = self.state.titlePadding
			local pendingHeight = height + self._frame.title:GetHeight() + padding.top + padding.bottom
			if self:GetHeight() ~= pendingHeight then self:SetHeight(pendingHeight) end
		end
	end,

	SetAnchors = function(self)
		local title = self._frame.title
		local titleText = lib:IsStringValid(title:GetText())
		local content = self.content

		title:ClearAllPoints()
		if titleText then
			local padding = self.state.titlePadding
			title:SetPoint("TOPLEFT", padding.left, -padding.top)
			title:SetPoint("TOPRIGHT", -padding.right, -padding.top)
			content:SetPoint("TOP", title, "BOTTOM", 0, -padding.bottom)
			if not self.state.fullHeight and not self.state.autoHeight then
				local pendingHeight = self:GetHeight() + title:GetHeight() + padding.top + padding.bottom
				if self:GetHeight() ~= pendingHeight then self:SetHeight(pendingHeight) end
			end
		else
			content:SetPoint("TOP")
		end

		content:SetPoint("LEFT")
		content:SetPoint("BOTTOMRIGHT")
	end,

	SetAutoHeight = function(self, autoHeight)
		self.state.autoHeight = autoHeight
		self:SetAnchors()
	end,

	SetBackdrop = function(self, ...)
		self.content:SetBackdrop(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self.content:SetBackdropBorderColor(...)
	end,

	SetBackdropColor = function(self, ...)
		self.content:SetBackdropColor(...)
	end,

	SetCollapsible = function(self, collapsible)
		self.state.collapsible = collapsible
	end,

	SetFont = function(self, font)
		lib:SetFont(self._frame.title, Mixin(font or {}, { fontObject = GameFontNormalLarge, color = lib.colors.gold }))
	end,

	SetJustifyH = function(self, justifyH)
		self._frame.title:SetJustifyH(justifyH or "LEFT")
	end,

	SetJustifyV = function(self, justifyV)
		self._frame.title:SetJustifyV(justifyV or "MIDDLE")
	end,

	SetPadding = function(self, left, right, top, bottom)
		self.state.padding = {
			left = left or 0,
			right = right or 0,
			top = top or 0,
			bottom = bottom or 0,
		}
	end,

	SetSpacing = function(self, x, y)
		self.state.spacing = {
			x = x or 0,
			y = y or 0,
		}
	end,

	SetTitle = function(self, text, left, right, top, bottom)
		self.state.titlePadding = Mixin(self.state.titlePadding or {}, {
			left = left or 4,
			right = right or 4,
			top = top or 4,
			bottom = bottom or 4,
		})

		self._frame.title:SetText(text or "")
		self:SetAnchors()
	end,
}

-- *******************************
-- *** Registration ***
-- *******************************

lib:RegisterWidget(widgetType, version, true, function(pool)
	local frame = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GetNextWidget(pool), UIParent, "BackdropTemplate"),
	}, widget)

	frame._frame.title = frame._frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.content = CreateFrame("Frame", nil, frame._frame, "BackdropTemplate")

	return frame
end)
