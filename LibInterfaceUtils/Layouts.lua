local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

lib.layouts = {
	flow = function(self, frame, children)
		local padding = self.state.padding
		local spacing = self.state.spacing
		local xOffset, yOffset = padding.left, -padding.top
		local rowHeight = 0
		local availableWidth = frame:GetWidth() - padding.left - padding.right
		local rowWidth = 0
		local currentRowFullWidth = false

		for i, child in ipairs(children) do
			-- Save the original size if not already saved
			if not child.state.originalSize then
				child.state.originalSize = {
					width = child:GetWidth(),
					height = child:GetHeight(),
				}
			end

			-- Start a new row if fullWidth is true or availableWidth is zero
			if child.state.fullWidth or availableWidth == 0 or currentRowFullWidth then
				xOffset = padding.left
				yOffset = yOffset - rowHeight - spacing.y
				rowHeight = 0
				rowWidth = 0
				currentRowFullWidth = false
			end

			-- Calculate the remaining width for fillWidth child
			local remainingWidth = availableWidth - rowWidth
			if (child.state.fillWidth or child.state.fullWidth) and remainingWidth > 0 then
				child:SetSize(remainingWidth, child:GetHeight())
				rowWidth = availableWidth
			else
				-- Set the child width based on the original size and available width
				local childWidth = math.min(child.state.originalSize.width, availableWidth)
				child:SetSize(childWidth, child:GetHeight())

				-- Update row width
				rowWidth = rowWidth + childWidth + spacing.x

				-- Start a new row if child width exceeds available width
				if rowWidth > availableWidth then
					xOffset = padding.left
					yOffset = yOffset - rowHeight - spacing.y
					rowHeight = 0
					rowWidth = childWidth + spacing.x
				end
			end

			-- Position the child on the current row
			child:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

			-- Update xOffset, rowHeight, and adjust rowWidth
			xOffset = xOffset + child:GetWidth() + spacing.x
			rowHeight = math.max(rowHeight, child:GetHeight())
			rowWidth = rowWidth + spacing.x

			if child.state.fullWidth then currentRowFullWidth = true end
		end

		-- Adjust the frame height based on the children's layout
		frame:SetHeight(math.abs(yOffset) + rowHeight + padding.top + padding.bottom)
	end,
}
