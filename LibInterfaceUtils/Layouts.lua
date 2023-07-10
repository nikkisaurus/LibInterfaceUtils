local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

lib.layouts = {
	flow = function(self, frame, children)
		local padding = self.state.padding
		local spacing = self.state.spacing
		local xOffset, yOffset = padding.left or 0, -(padding.top or 0)
		local rowHeight = 0
		local availableWidth = frame:GetWidth() - (padding.left or 0) - (padding.right or 0)

		for i, child in ipairs(children) do
			local childWidth = child:GetWidth()

			if child.state.fullWidth or xOffset + childWidth > availableWidth then
				xOffset = padding.left or 0
				yOffset = yOffset - rowHeight - spacing.y
				rowHeight = 0
			end

			-- Save the original size if not already saved
			child.state.originalSize = child.state.originalSize
				or {
					width = child:GetWidth(),
					height = child:GetHeight(),
				}

			if child.state.fullWidth or childWidth > availableWidth then
				child:SetSize(availableWidth, child:GetHeight())
				childWidth = availableWidth
			elseif child.state.originalSize.width <= availableWidth then
				child:SetSize(child.state.originalSize.width, child:GetHeight())
				childWidth = child.state.originalSize.width
			end

			if childWidth < child.state.originalSize.width and child.state.originalSize.width <= availableWidth then
				-- Fill the rest of the available width if the child is smaller than its original size
				local remainingWidth = availableWidth - childWidth
				child:SetWidth(childWidth + remainingWidth)
				childWidth = childWidth + remainingWidth
			end

			child:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

			xOffset = xOffset + childWidth + spacing.x
			rowHeight = math.max(rowHeight, child:GetHeight())
		end

		-- Adjust the frame height based on the children's layout
		frame:SetHeight(math.abs(yOffset) + rowHeight + (padding.top or 0) + (padding.bottom or 0))
	end,
}
