local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

lib.layouts = {
	flow = function(self, frame, children)
		local spacing = 10
		local xOffset, yOffset = 0, 10
		local rowHeight = 0

		for i, child in ipairs(children) do
			if child.state.fullWidth or xOffset + child:GetWidth() > frame:GetWidth() then
				xOffset = 0
				yOffset = yOffset - rowHeight - spacing
				rowHeight = 0
			end

			if child.state.fullWidth then child:SetSize(frame:GetWidth() - xOffset, child:GetHeight()) end

			child:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

			xOffset = xOffset + child:GetWidth() + spacing
			rowHeight = math.max(rowHeight, child:GetHeight())
		end
	end,
}
