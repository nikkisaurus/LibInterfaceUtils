local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

lib.layouts = {
	flow = function(self, frame, children)
		local spacing = 10
		local xOffset, yOffset = 0, 0
		local rowHeight = 0

		for i, child in ipairs(children) do
			if child.fillRow or xOffset + child:GetWidth() > frame:GetWidth() then
				xOffset = 0
				yOffset = yOffset - rowHeight - spacing
				rowHeight = 0
			end

			if child.fillRow then
				child:SetSize(frame:GetWidth() - xOffset, child:GetHeight())
			else
				-- child:SetSize(300, 300)
			end

			child:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

			xOffset = xOffset + child:GetWidth() + spacing
			rowHeight = math.max(rowHeight, child:GetHeight())
		end
	end,
}

-- local frame = CreateFrame("Frame", "MyAddonFrame", UIParent)
-- frame:SetSize(200, 200)

-- local widgets = {
--   { width = 80, height = 30, text = "Button 1", fillRow = false },
--   { width = 100, height = 25, text = "Button 2", fillRow = false },
--   { width = 120, height = 20, text = "Button 3", fillRow = true },
--   -- Add more widgets with different sizes and fillRow settings
-- }

-- local spacing = 10 -- Set the spacing between widgets

-- local xOffset, yOffset = 0, 0
-- local rowHeight = 0

-- for i, widgetData in ipairs(widgets) do
--   local widget = CreateFrame("Button", "MyButton"..i, frame, "UIPanelButtonTemplate")
--   widget:SetText(widgetData.text)
--   widgets[i] = widget

--   if widgetData.fillRow or xOffset + widgetData.width > frame:GetWidth() then
--     xOffset = 0
--     yOffset = yOffset - rowHeight - spacing
--     rowHeight = 0
--   end

--   if widgetData.fillRow then
--     widget:SetSize(frame:GetWidth() - xOffset, widgetData.height)
--   else
--     widget:SetSize(widgetData.width, widgetData.height)
--   end

--   widget:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

--   xOffset = xOffset + widget:GetWidth() + spacing
--   rowHeight = math.max(rowHeight, widget:GetHeight())
-- end
