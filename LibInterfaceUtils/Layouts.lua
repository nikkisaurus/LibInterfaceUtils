local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

private.layouts = {
    fill = function(self)
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
        return self:GetAvailableWidth(), self:GetAvailableHeight()
    end,

    filllefttoright = function(self)
        local left = self.children[1]
        if not left then
            return
        end

        self:ParentChild(left)
        left:ClearAllPoints()
        left:SetPoint("TOPLEFT")
        local height = left:GetHeight()

        local right = self.children[2]
        if right then
            self:ParentChild(right)
            right:ClearAllPoints()
            right:SetPoint("TOPRIGHT")
            left:SetPoint("TOPRIGHT", right, "TOPLEFT")
            height = max(height, right:GetHeight())
        else
            left:SetPoint("TOPRIGHT")
        end

        self:MarkDirty(self:GetWidth(), height)
        return self:GetWidth(), usedHeight
    end,

    -- flow = function(self)
    --     local width = 0
    --     local height = 0
    --     local offset = 0

    --     local layoutFunction = function(index, frame, offset, scrollTarget)
    --         -- local indent = self:GetElementIndent(frame)
    --         -- local setPoint = self:IsHorizontal() and ScrollBoxViewUtil.SetHorizontalPoint or ScrollBoxViewUtil.SetVerticalPoint
    --         -- return setPoint(frame, offset, indent, scrollTarget)
    --     end

    --     local scrollTarget = self.verticalBox:GetScrollTarget()
    --     local offset = self.verticalBox:GetDerivedScrollOffset()

    --     for index, frame in ipairs(self.children) do
    --         if height < self.verticalBox:GetHeight() or (height > offset and height < (self.verticalBox:GetHeight() + offset)) then
    --             frame:SetParent(scrollTarget)
    --             frame:ClearAllPoints()
    --             frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", 0, -height)
    --             frame:SetPoint("TOPRIGHT", scrollTarget, "TOPRIGHT", 0, -height)
    --         end
    --         height = height + frame:GetHeight()

    --         -- if frameLevelCounter then
    --         --     frame:SetFrameLevel(frameLevelCounter())
    --         -- end
    --     end
    --     -- self.horizontalBox:SetHeight(height)
    --     -- for _, child in ipairs(self.children) do
    --     --     child:SetParent(self.content)
    --     --     child:ClearAllPoints()
    --     --     child:SetHeight(20)
    --     --     child:SetPoint("TOPLEFT", 0, -height)
    --     --     width = max(width, child:GetWidth())
    --     --     print(child:GetHeight())
    --     --     height = height + child:GetHeight()
    --     -- end

    --     self:MarkDirty(width, height)
    -- end,

    flow = function(self)
        local usedWidth = 0
        local usedHeight = 0

        local maxWidth = 0
        local rowHeight = 0

        local availableWidth = self:GetAvailableWidth()
        local availableHeight = self:GetAvailableHeight()

        local point = self:Get("point") or "TOPLEFT"
        local points = private.points[point]
        local spacingH = self:Get("spacingH") or 0
        local spacingV = self:Get("spacingV") or 0

        for i, child in ipairs(self.children) do
            local xOffset = child:Get("xOffset") or 0
            local yOffset = child:Get("yOffset") or 0
            local isFullWidth = child:GetFullWidth() or child.widget.type == "Divider" or child.widget.type == "Header"
            local fillWidth = child:GetFillWidth()
            local isFullHeight = child:GetFullHeight()
            local relWidth = child:GetRelativeWidth()
            local relHeight = child:GetRelativeHeight()

            self:ParentChild(child)
            child:ClearAllPoints()

            if child:Get("width") then
                child:SetWidth(child:Get("width"))
            end

            if child:Get("height") then
                child:SetHeight(child:Get("height"))
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

            if relWidth then
                childWidth = availableWidth * relWidth
                child:SetWidth(childWidth)
            end

            if relHeight then
                childHeight = availableHeight * relHeight
                child:SetHeight(childHeight)
            end

            if i == 1 then
                child:SetPoint(point, points[2] * xOffset, points[3] * yOffset)
                if isFullWidth or fillWidth then
                    child:SetPoint(points[1], self:GetAnchorX(), points[1])
                    if child.DoLayout then
                        childWidth, childHeight = child:DoLayout()
                    else
                        childWidth = private:round(child:GetWidth())
                    end
                    childWidth = isFullWidth and availableWidth or childWidth
                end
                usedWidth = childWidth + xOffset
                maxWidth = usedWidth
                rowHeight = childHeight + yOffset
            elseif isFullWidth or (usedWidth + childWidth + xOffset) > availableWidth then
                usedHeight = usedHeight + rowHeight + spacingV
                maxWidth = max(maxWidth, usedWidth)
                usedWidth = 0
                child:SetPoint(point, points[2] * xOffset, points[4] * (usedHeight + yOffset))
                if isFullWidth or fillWidth then
                    child:SetPoint(points[1], self:GetAnchorX(), points[1])
                    if child.DoLayout then
                        childWidth, childHeight = child:DoLayout()
                    else
                        childWidth = private:round(child:GetWidth())
                    end
                    childWidth = isFullWidth and availableWidth or childWidth
                end
                usedWidth = childWidth + xOffset
                rowHeight = childHeight + yOffset
            else
                child:SetPoint(point, points[2] * (usedWidth + spacingH + xOffset), points[4] * (usedHeight + yOffset))
                if fillWidth then
                    child:SetPoint(points[1], self:GetAnchorX(), points[1])
                    if child.DoLayout then
                        childWidth, childHeight = child:DoLayout()
                    else
                        childWidth = private:round(child:GetWidth())
                    end
                    childWidth = isFullWidth and availableWidth or childWidth
                end
                usedWidth = usedWidth + childWidth + spacingH + xOffset
                maxWidth = max(maxWidth, usedWidth)
                rowHeight = max(rowHeight, childHeight + yOffset)
            end

            if (self.widget.type == "Group" or self.widget.type == "CollapsibleGroup") and childWidth > availableWidth then
                -- Since groups can't have horizontal scrollbars, we want to make sure nothing gets cut off
                child:SetPoint(points[1], self:GetAnchorX(), points[1])
                if child.DoLayout then
                    childWidth, childHeight = child:DoLayout()
                else
                    childWidth = private:round(child:GetWidth())
                end
            end

            if isFullHeight and self.widget.type ~= "Group" and self.widget.type ~= "CollapsibleGroup" then
                local extraHeight = availableHeight - usedHeight - spacingV - yOffset
                if extraHeight > childHeight then
                    child:SetHeight(extraHeight)
                end
                rowHeight = max(rowHeight, child:GetHeight() + yOffset)
                break
            end
        end

        usedHeight = usedHeight + rowHeight

        if self:Get("collapsed") then
            self:MarkDirty(usedWidth, 0)
            return usedWidth, 0
        else
            self:MarkDirty(maxWidth, usedHeight)
            return usedWidth, usedHeight
        end
    end,

    list = function(self)
        local usedWidth = 0
        local usedHeight = 0

        local maxWidth = 0
        local rowHeight = 0

        local availableWidth = self:GetAvailableWidth()
        local availableHeight = self:GetAvailableHeight()

        local spacingV = self:Get("spacingV") or 0

        for id, child in ipairs(self.children) do
            local xOffset = child:Get("xOffset") or 0
            local yOffset = child:Get("yOffset") or 0
            local isFullWidth = child:GetFullWidth() or child.widget.type == "Divider" or child.widget.type == "Header"
            local fillWidth = child:GetFillWidth()
            local isFullHeight = child:GetFullHeight()
            local relWidth = child:GetRelativeWidth()
            local relHeight = child:GetRelativeHeight()

            self:ParentChild(child)
            child:ClearAllPoints()

            if child:Get("width") then
                child:SetWidth(child:Get("width"))
            end

            if child:Get("height") then
                child:SetHeight(child:Get("height"))
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

            if relWidth then
                childWidth = availableWidth * relWidth
                child:SetWidth(childWidth)
            end

            if relHeight then
                childHeight = availableHeight * relHeight
                child:SetHeight(childHeight)
            end

            if value == 1 then
                child:SetPoint("TOPLEFT", xOffset, yOffset)
                if isFullWidth or fillWidth then
                    child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                    if child.DoLayout then
                        childWidth, childHeight = child:DoLayout()
                    else
                        childWidth = private:round(child:GetWidth())
                    end
                    childWidth = isFullWidth and availableWidth or childWidth
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
                    if child.DoLayout then
                        childWidth, childHeight = child:DoLayout()
                    else
                        childWidth = private:round(child:GetWidth())
                    end
                    childWidth = isFullWidth and availableWidth or childWidth
                end
                usedWidth = childWidth + xOffset
                rowHeight = childHeight + yOffset
            end

            if (self.widget.type == "Group" or self.widget.type == "CollapsibleGroup") and childWidth > availableWidth then
                -- Since groups can't have horizontal scrollbars, we want to make sure nothing gets cut off
                child:SetPoint("RIGHT", self:GetAnchorX(), "RIGHT")
                if child.DoLayout then
                    childWidth, childHeight = child:DoLayout()
                else
                    childWidth = private:round(child:GetWidth())
                end
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

        if self:Get("collapsed") then
            self:MarkDirty(usedWidth, 0)
            return usedWidth, 0
        else
            self:MarkDirty(usedWidth, usedHeight)
            return usedWidth, usedHeight
        end
    end,

    row = function(self)
        local w = 0
        local h = 0

        local spacingH = self:Get("spacingH") or 0

        for i, child in ipairs(self.children) do
            local xOffset = child:Get("xOffset") or 0
            self:ParentChild(child)
            child:ClearAllPoints()

            if i == 1 then
                child:SetPoint("LEFT")
            else
                child:SetPoint("LEFT", self.children[i - 1], "RIGHT", xOffset + spacingH, 0)
            end
            w = w + child:GetWidth() + xOffset + spacingH
            h = max(h, child:GetHeight())
        end

        self:MarkDirty(w, h)
        return w, h
    end,
}
