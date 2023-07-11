local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local layouts = {}
addon.layouts = layouts

function layouts.fill(self, frame, children, scrollBox)
	frame = scrollBox or frame
	local padding = self._state.padding
	local firstChild = children[1]

	if firstChild then
		-- Set the first child's size to fill the entire frame
		firstChild:SetSize(frame:GetWidth() - padding.left - padding.right, frame:GetHeight() - padding.top - padding.bottom)
		firstChild:SetPoint("TOPLEFT", frame, "TOPLEFT", padding.left, -padding.top)

		-- Perform child layout
		addon.safecall(firstChild.DoLayout, firstChild)
	end

	return frame:GetSize()
end

function layouts.flow(self, frame, children, scrollBox)
	local padding = self._state.padding
	local spacing = self._state.spacing
	local xOffset, yOffset = padding.left, -padding.top
	local rowHeight = 0
	local availableWidth = (scrollBox or frame):GetWidth() - padding.left - padding.right
	local rowWidth = 0
	local availableHeight = frame:GetHeight() - padding.top - padding.bottom

	-- Position child widgets and calculate row heights
	for i, child in ipairs(children) do
		-- Save the original size if not already saved
		if not child._state.originalSize then
			child._state.originalSize = {
				width = child:GetWidth(),
				height = child:GetHeight(),
			}
		end

		-- Start a new row if fullWidth is true or availableWidth is zero
		if child._state.fullWidth or availableWidth == 0 then
			xOffset = padding.left
			yOffset = yOffset - rowHeight - spacing.y
			rowHeight = 0
			rowWidth = 0
		end

		-- Calculate the remaining width for fillWidth child
		local remainingWidth = availableWidth - rowWidth
		if child._state.fullWidth and remainingWidth > 0 then
			-- Set the child width to the availableWidth
			child:SetSize(availableWidth, child:GetHeight())
			rowWidth = availableWidth
		elseif child._state.fillWidth and remainingWidth > 0 then
			-- Set the child width to the remainingWidth
			child:SetSize(remainingWidth, child:GetHeight())
			rowWidth = rowWidth + remainingWidth + spacing.x
		else
			-- Set the child width based on the original size and available width
			local childWidth = math.min(child._state.originalSize.width, availableWidth)
			if childWidth == availableWidth then
				child._state.availableWidth = true
			end
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

		-- Check if child has fullHeight property
		if child._state.fullHeight then
			-- Set the child height to the remaining height of the frame
			local childHeight = math.max(child._state.originalSize.height, availableHeight - math.abs(yOffset) - spacing.y)
			child:SetSize(child:GetWidth(), childHeight)
		end

		-- Position the child on the current row
		child:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

		-- Update xOffset, rowHeight, and adjust rowWidth
		xOffset = xOffset + child:GetWidth() + spacing.x
		rowHeight = math.max(rowHeight, child:GetHeight())
	end

	-- Perform child layout after positioning
	for _, child in ipairs(children) do
		addon.safecall(child.DoLayout, child)
	end

	-- Calculate the total content height based on the positioned child widgets
	local contentHeight = math.abs(yOffset) + rowHeight + padding.top + padding.bottom

	return (scrollBox or frame):GetWidth(), contentHeight
end

function layouts.list(self, frame, children, scrollBox)
	local padding = self._state.padding
	local spacing = self._state.spacing
	local yOffset = -padding.top
	local availableWidth = (scrollBox or frame):GetWidth() - padding.left - padding.right
	local availableHeight = frame:GetHeight() - padding.top - padding.bottom

	for i, child in ipairs(children) do
		-- Save the original size if not already saved
		if not child._state.originalSize then
			child._state.originalSize = {
				width = child:GetWidth(),
				height = child:GetHeight(),
			}
		end

		-- Start a new row for each child
		local xOffset = padding.left

		-- Set the child size based on the specified conditions
		if child._state.fullWidth or child._state.fillWidth or child:GetWidth() > availableWidth then
			child._state.availableWidth = true
			child:SetSize(availableWidth, child:GetHeight())
		else
			child._state.availableWidth = false
			local maxWidth = math.min(availableWidth, child._state.originalSize.width)
			child:SetSize(maxWidth, child:GetHeight())
		end

		-- Check if child has fullHeight property
		if child._state.fullHeight then
			-- Set the child height to the remaining height of the frame
			local childHeight = math.max(child._state.originalSize.height, availableHeight - math.abs(yOffset) - spacing.y)
			child:SetSize(child:GetWidth(), childHeight)
		end

		-- Position the child on the current row
		child:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)

		-- Update the y-offset for the next row
		yOffset = yOffset - child:GetHeight() - spacing.y

		-- Perform child layout after positioning
		addon.safecall(child.DoLayout, child)

		if child._state.fullHeight then
			break
		end
	end

	-- Adjust the frame height based on the children's layout
	local contentHeight = math.abs(yOffset) + padding.top + padding.bottom
	return (scrollBox or frame):GetWidth(), contentHeight
end
