local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

function private.Fill(self)
    local child = self.children[1]
    if not child then
        return
    end

    self:ParentChild(child)
    child:ClearAllPoints()
    self:Fill(child)
end

function private.Flow(self)
    local usedWidth, usedHeight, maxWidth, rowHeight, xOffsets = 0, 0, 0, 0, 0
    local availableWidth = self:GetAvailableWidth()
    local availableHeight = self:GetAvailableHeight() - 2
    local spacingH = self:GetUserData("spacingH") or 0
    local spacingV = self:GetUserData("spacingV") or 0

    if self:GetUserData("collapsed") then
        self:MarkDirty(nil, usedHeight)
        return
    end

    local rowAnchor
    for id, child in ipairs(self.children) do
        -- Restore default height for fullHeight children so it doesn't get exponentially bigger, resulting in a scrollbar
        local height = child:GetUserData("height")
        if height then
            child:SetHeight(height)
        end

        local xOffset = child:GetUserData("xOffset") or 0
        local yOffset = child:GetUserData("yOffset") or 0
        local childWidth = child:GetWidth()
        local rawChildHeight = child:GetHeight()
        local childHeight = rawChildHeight - yOffset
        local pendingWidth = usedWidth + childWidth
        self:ParentChild(child)
        child:ClearAllPoints()

        local isFullWidth = child:GetFullWidth() or (child.widget.type == "Divider" or child.widget.type == "Header")

        if id == 1 then
            child:SetPoint("TOPLEFT", xOffset, yOffset)
            usedWidth = childWidth
            maxWidth = childWidth
            rowHeight = childHeight
            rowAnchor = child
        elseif pendingWidth > availableWidth or isFullWidth then
            usedHeight = usedHeight + rowHeight - yOffset + spacingV
            child:SetPoint("LEFT", rowAnchor, "LEFT", xOffset, 0)
            child:SetPoint("TOP", 0, -usedHeight)
            usedWidth = isFullWidth and availableWidth or childWidth
            maxWidth = max(usedWidth, maxWidth)
            rowHeight = childHeight
            rowAnchor = child
        else
            child:SetPoint("TOPLEFT", self.children[id - 1], "TOPRIGHT", xOffset + spacingH, yOffset)
            usedWidth = pendingWidth + spacingH
            maxWidth = max(usedWidth, maxWidth)
            rowHeight = max(rowHeight, childHeight)
        end

        xOffsets = xOffsets + xOffset

        if isFullWidth or child:GetFillWidth() then
            self:FillX(child)
        end

        if child:GetFullHeight() and self.widget.type ~= "Group" then
            usedWidth = usedWidth + xOffsets
            usedHeight = usedHeight + rowHeight
            maxWidth = max(usedWidth, maxWidth)

            if usedHeight < availableHeight then
                if not height then
                    child:SetUserData("height", rawChildHeight)
                end
                local extra = availableHeight - usedHeight
                child:SetHeight(rawChildHeight + extra)
                usedHeight = usedHeight + extra
            end

            self:MarkDirty(maxWidth, usedHeight)

            return
        end

        if child.DoLayout then
            child:DoLayout()
        end
    end

    usedWidth = usedWidth + xOffsets
    usedHeight = usedHeight + rowHeight
    maxWidth = max(usedWidth, maxWidth)

    self:MarkDirty(maxWidth, usedHeight)
end

function private.List(self)
    local usedWidth, usedHeight, xOffsets = 0, 0, 0
    local availableHeight = self:GetAvailableHeight()
    local spacingV = self:GetUserData("spacingV") or 0

    if self:GetUserData("collapsed") then
        self:MarkDirty(nil, usedHeight)
        return
    end

    for id, child in ipairs(self.children) do
        -- Restore default height for fullHeight children so it doesn't get exponentially bigger, resulting in a scrollbar
        local height = child:GetUserData("height")
        if height then
            child:SetHeight(height)
        end

        local xOffset = child:GetUserData("xOffset") or 0
        local yOffset = child:GetUserData("yOffset") or 0
        local childWidth = child:GetWidth()
        local rawChildHeight = child:GetHeight()
        local childHeight = rawChildHeight - yOffset
        self:ParentChild(child)
        child:ClearAllPoints()

        local isFullWidth = child:GetFullWidth() or (child.widget.type == "Divider" or child.widget.type == "Header")

        if id == 1 then
            child:SetPoint("TOPLEFT", xOffset, yOffset)
            usedWidth = childWidth
            usedHeight = childHeight
        else
            child:SetPoint("TOPLEFT", self.children[id - 1], "BOTTOMLEFT", xOffset, yOffset - spacingV)
            usedWidth = max(usedWidth, childWidth)
            usedHeight = usedHeight + childHeight + spacingV
        end

        xOffsets = xOffsets + xOffset

        if isFullWidth then
            self:FillX(child)
        end

        if child:GetFullHeight() and self.widget.type ~= "Group" then
            if usedHeight < availableHeight then
                if not height then
                    child:SetUserData("height", rawChildHeight)
                end
                local extra = availableHeight - usedHeight
                child:SetHeight(rawChildHeight + extra)
                usedHeight = usedHeight + extra
            end
            break
        end

        if child.DoLayout then
            child:DoLayout()
        end
    end

    usedWidth = usedWidth + xOffsets

    self:MarkDirty(usedWidth, usedHeight)
end
