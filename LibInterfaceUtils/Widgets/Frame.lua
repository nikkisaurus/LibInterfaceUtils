local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

-- *******************************
-- *** Scripts ***
-- *******************************

local function OnClick(close)
	close:GetParent().widget:Release()
end

local function OnDragStart(frame)
	frame:StartMoving()
end

local function OnDragStop(frame)
	frame:StopMovingOrSizing()
end

local function OnMouseDown(resizer)
	resizer:GetParent():StartSizing()
end

local function OnMouseUp(resizer)
	resizer:GetParent():StopMovingOrSizing()
end

-- *******************************
-- *** Widget ***
-- *******************************

local widgetType, version = "Frame", 1

local widget = {
	OnAcquire = function(self)
		self:SetBackdrop(lib.defaultBackdrop)
		self:SetBackdropColor(unpack(lib.colors.elvBackdrop))
		self:SetBackdropBorderColor(0, 0, 0, 1)
		self:SetMovable(true)
		self:EnableResize(true, 100, 100)
		self:SetPoint("CENTER")
		self:SetSize(700, 500)
		self:SetPadding(5, 5, 5, 5)
		self:SetSpacing(5, 5)
		self:Show()
	end,

	EnableResize = function(self, enable, ...)
		local frame = self._frame
		frame:SetResizable(enable)
		frame:SetResizeBounds(...)
		frame.resizer:SetEnabled(enable)
		frame.resizer[enable and "Show" or "Hide"](frame.resizer)
	end,

	SetBackdrop = function(self, ...)
		self._frame:SetBackdrop(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self._frame:SetBackdropBorderColor(...)
	end,

	SetBackdropColor = function(self, ...)
		self._frame:SetBackdropColor(...)
	end,

	SetMovable = function(self, movable, ...)
		local frame = self._frame

		frame:EnableMouse(movable)
		frame:SetMovable(movable)
		if movable then
			frame:RegisterForDrag((...) or "LeftButton", ...)
		else
			frame:RegisterForDrag()
		end

		frame:SetScript("OnDragStart", movable and OnDragStart or nil)
		frame:SetScript("OnDragStop", movable and OnDragStop or nil)
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
}

-- *******************************
-- *** Registration ***
-- *******************************

lib:RegisterWidget(widgetType, version, true, function(pool)
	local frame = CreateFromMixins({
		_frame = CreateFrame("Frame", lib:GetNextWidget(pool), UIParent, "BackdropTemplate"),
	}, widget)

	frame._frame.resizer = CreateFrame("Button", nil, frame._frame)
	frame._frame.resizer:SetNormalTexture(386862)
	frame._frame.resizer:SetHighlightTexture(386863)
	frame._frame.resizer:SetPoint("BOTTOMRIGHT", 0, 0)
	frame._frame.resizer:SetSize(16, 16)
	frame._frame.resizer:Hide()
	frame._frame.resizer:SetScript("OnMouseDown", OnMouseDown)
	frame._frame.resizer:SetScript("OnMouseUp", OnMouseUp)

	local close = CreateFrame("Button", nil, frame._frame)
	close:SetNormalAtlas("common-search-clearbutton")
	close:SetPoint("TOPRIGHT", -4, -4)
	close:SetSize(12, 12)
	close:SetScript("OnClick", OnClick)

	local title = frame._frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", 4, -4)
	title:SetPoint("BOTTOMRIGHT", close, "BOTTOMLEFT", -4, 0)
	title:SetText("Frame")

	frame.content = CreateFrame("Frame", nil, frame._frame, "BackdropTemplate")
	frame.content:SetPoint("TOP", title, "BOTTOM", 0, -4)
	frame.content:SetPoint("LEFT")
	frame.content:SetPoint("BOTTOMRIGHT")

	frame.content:SetBackdrop({
		bgFile = lib.defaultTexture,
		edgeFile = lib.defaultTexture,
		edgeSize = 1,
	})
	frame.content:SetBackdropColor(unpack(lib.colors.elvTransparent))
	frame.content:SetBackdropBorderColor(0, 0, 0, 1)

	return frame
end)
