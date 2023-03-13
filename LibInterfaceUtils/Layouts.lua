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
    child:SetPoint("TOPLEFT")
    child:SetPoint("BOTTOMRIGHT")

    if child.DoLayout then
        child:DoLayout()
    end

    self:MarkDirty(self:GetAvailableWidth(), self:GetAvailableHeight())
end

function private.Flow(self)
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
                childWidth = isFullWidth and availableWidth or child:GetWidth()
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
                childWidth = isFullWidth and availableWidth or child:GetWidth()
            end
            usedWidth = childWidth + xOffset
            rowHeight = childHeight + spacingV + yOffset
        else
            child:SetPoint("TOPLEFT", usedWidth + spacingH + xOffset, -usedHeight + yOffset)
            if fillWidth then
                child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                childWidth = isFullWidth and availableWidth or child:GetWidth()
            end
            usedWidth = usedWidth + childWidth + spacingH + xOffset
            maxWidth = max(maxWidth, usedWidth)
            rowHeight = max(rowHeight, childHeight + yOffset)
        end

        if (self.widget.type == "Group" or self.widget.type == "CollapsibleGroup") and child:GetWidth() > availableWidth then
            -- Since groups can't have horizontal scrollbars, we want to make sure nothing gets cut off
            child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
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

    usedHeight = usedHeight + rowHeight - spacingV

    if self:GetUserData("collapsed") then
        self:MarkDirty(nil, 0)
    else
        self:MarkDirty(maxWidth, usedHeight)
    end
end

function private.List(self)
    local usedWidth = 0
    local usedHeight = 0

    local maxWidth = 0
    local rowHeight = 0

    local availableWidth = self:GetAvailableWidth()
    local availableHeight = self:GetAvailableHeight()

    local spacingV = self:GetUserData("spacingV") or 0

    for id, child in ipairs(self.children) do
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
                childWidth = isFullWidth and availableWidth or child:GetWidth()
            end
            usedWidth = childWidth + xOffset
            maxWidth = usedWidth
            rowHeight = childHeight + yOffset
        else
            usedHeight = usedHeight + rowHeight + spacingV
            maxWidth = max(maxWidth, usedWidth)
            usedWidth = 0
            child:SetPoint("TOPLEFT", xOffset, -usedHeight + yOffset)
            if isFullWidth or fillWidth then
                child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                childWidth = isFullWidth and availableWidth or child:GetWidth()
            end
            usedWidth = childWidth + xOffset
            rowHeight = childHeight + spacingV + yOffset
        end

        if (self.widget.type == "Group" or self.widget.type == "CollapsibleGroup") and child:GetWidth() > availableWidth then
            -- Since groups can't have horizontal scrollbars, we want to make sure nothing gets cut off
            child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
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

    usedHeight = usedHeight + rowHeight - spacingV

    if self:GetUserData("collapsed") then
        self:MarkDirty(nil, 0)
    else
        self:MarkDirty(usedWidth, usedHeight)
    end
end

function private.TabFlow(self)
    -- Used for TabGroup, so I'm not really bothered with customization as far as spacing and offsets go
    local usedWidth = 0
    local usedHeight = 0
    local rowHeight = 0

    local availableWidth = self:GetAvailableWidth()

    for i, child in ipairs(self.children) do
        self:ParentChild(child)
        child:ClearAllPoints()

        local childWidth = private:round(child:GetWidth())
        local childHeight = private:round(child:GetHeight())

        if i == 1 then
            child:SetPoint("BOTTOMLEFT", usedWidth, usedHeight)
            usedWidth = childWidth
            rowHeight = childHeight
        elseif usedWidth + childWidth > availableWidth then
            usedHeight = usedHeight + rowHeight
            usedWidth = 0
            child:SetPoint("BOTTOMLEFT", usedWidth, usedHeight)
            usedWidth = childWidth
            rowHeight = childHeight
        else
            child:SetPoint("BOTTOMLEFT", usedWidth, usedHeight)
            usedWidth = usedWidth + childWidth
            rowHeight = max(rowHeight, childHeight)
        end
    end
    usedHeight = usedHeight + rowHeight

    self:MarkDirty(usedWidth, usedHeight)
end
