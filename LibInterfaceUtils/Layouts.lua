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
    -- TODO FIX ME the issue with nested groups not laying out correctly is due to the scrollbar behavior
    local usedWidth = 0
    local usedHeight = 0

    local maxWidth = 0
    local rowHeight = 0

    local availableWidth = self:GetAvailableWidth()
    local availableHeight = self:GetAvailableHeight()

    local spacingH = self:GetUserData("spacingH") or 0
    local spacingV = self:GetUserData("spacingV") or 0

    for i, child in ipairs(self.children) do
        local xOffset = child:GetUserData("xOffset") or 0
        local yOffset = child:GetUserData("yOffset") or 0
        local isFullWidth = child:GetFullWidth() or child.widget.type == "Divider" or child.widget.type == "Header"
        local fillWidth = child:GetFillWidth()
        local isFullHeight = child:GetFullHeight()

        self:ParentChild(child)
        child:ClearAllPoints()

        if child:GetUserData("width") then
            child:SetWidth(child:GetUserData("width"))
        end

        if child:GetUserData("height") then
            child:SetHeight(child:GetUserData("height"))
        end

        local childWidth = private:round(child:GetWidth())
        local childHeight = private:round(child:GetHeight())

        if child.DoLayout then
            childWidth, childHeight = child:DoLayout()
        end

        if fillWidth then
            child:InitUserData("width", childWidth)
        end

        if isFullHeight then
            child:InitUserData("height", childHeight)
        end

        if i == 1 then
            child:SetPoint("TOPLEFT", xOffset, yOffset)
            if isFullWidth or fillWidth then
                child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                childWidth = child:GetWidth()
            end
            usedWidth = childWidth + xOffset
            maxWidth = usedWidth
            rowHeight = childHeight + yOffset
        elseif isFullWidth or (usedWidth + childWidth + xOffset) > availableWidth then
            usedHeight = usedHeight + rowHeight + spacingV
            maxWidth = max(maxWidth, usedWidth)
            usedWidth = 0
            child:SetPoint("TOPLEFT", xOffset, -usedHeight + yOffset)
            if isFullWidth or fillWidth then
                child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                childWidth = child:GetWidth()
            end
            usedWidth = childWidth + xOffset
            rowHeight = childHeight + spacingV + yOffset
        else
            child:SetPoint("TOPLEFT", usedWidth + spacingH + xOffset, -usedHeight + yOffset)
            if fillWidth then
                child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                childWidth = child:GetWidth()
            end
            usedWidth = usedWidth + childWidth + xOffset
            maxWidth = max(maxWidth, usedWidth)
            rowHeight = max(rowHeight, childHeight + yOffset)
        end

        if isFullHeight and self.widget.type ~= "Group" and self.widget.type ~= "CollapsibleGroup" then
            local extraHeight = availableHeight - usedHeight - spacingH - yOffset
            if extraHeight > childHeight then
                child:SetHeight(availableHeight - usedHeight - spacingH - yOffset)
            end
            rowHeight = max(rowHeight, child:GetHeight() + spacingH + yOffset)
            break
        end
    end

    usedHeight = usedHeight + rowHeight

    if self:GetUserData("collapsed") then
        self:MarkDirty(nil, 0)
    else
        self:MarkDirty(maxWidth, usedHeight)
    end
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

        if child.DoLayout then
            child:DoLayout()
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

        if child:GetFullHeight() and self.widget.type ~= "Group" and self.widget.type ~= "CollapsibleGroup" then
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
    end

    usedWidth = usedWidth + xOffsets

    self:MarkDirty(usedWidth, usedHeight)
end
