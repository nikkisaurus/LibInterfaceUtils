local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

private.Fill = function(self)
    -- TODO implement insets
    local child = self.children[1]
    if not child then
        return
    end

    child:ClearAllPoints()
    self:Fill(child, 0, 0)
end

private.Flow = function(self)
    local usedWidth, usedHeight, rowHeight = 0, 0, 0, 0
    local availableWidth = self:GetAvailableWidth() - 10
    local spacingH = self:GetUserData("spacingH") or 0
    local spacingV = self:GetUserData("spacingV") or 0

    for id, child in pairs(self.children) do
        local xOffset = child:GetUserData("xOffset") or 0
        local yOffset = child:GetUserData("yOffset") or 0
        local childWidth = child:GetWidth() + xOffset
        local childHeight = child:GetHeight() - yOffset
        local pendingWidth = usedWidth + childWidth
        self:ParentChild(child)
        child:ClearAllPoints()

        if id == 1 then
            child:SetPoint("TOPLEFT", xOffset, yOffset)
            usedWidth = childWidth
            rowHeight = childHeight
        elseif pendingWidth > availableWidth then
            usedHeight = usedHeight + rowHeight + yOffset + spacingV
            child:SetPoint("LEFT", self.children[1], "LEFT", xOffset, 0)
            child:SetPoint("TOP", 0, -usedHeight)
            usedWidth = childWidth
            rowHeight = childHeight
        else
            child:SetPoint("TOPLEFT", self.children[id - 1], "TOPRIGHT", xOffset + spacingH, yOffset)
            usedWidth = pendingWidth + spacingH
            rowHeight = max(rowHeight, childHeight)
        end
    end

    usedHeight = usedHeight + rowHeight

    self:MarkDirty(usedWidth, usedHeight)
end

private.List = function(self)
    local usedWidth, usedHeight, xOffsets = 0, 0, 0
    local spacingV = self:GetUserData("spacingV") or 0

    for id, child in pairs(self.children) do
        local xOffset = child:GetUserData("xOffset") or 0
        local yOffset = child:GetUserData("yOffset") or 0
        local childWidth = child:GetWidth()
        local childHeight = child:GetHeight() - yOffset
        self:ParentChild(child)
        child:ClearAllPoints()

        if id == 1 then
            child:SetPoint("TOPLEFT", xOffset, yOffset)
            usedWidth = childWidth
            usedHeight = childHeight
            xOffsets = xOffsets + xOffset
        else
            child:SetPoint("TOPLEFT", self.children[id - 1], "BOTTOMLEFT", xOffset, yOffset - spacingV)
            usedWidth = max(usedWidth, childWidth)
            usedHeight = usedHeight + childHeight + spacingV
            xOffsets = xOffsets + xOffset
        end
    end

    usedWidth = usedWidth + xOffsets

    self:MarkDirty(usedWidth, usedHeight)
end
