local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

private.List = function(self)
    local height = 0
    local usedWidth = 0
    for _, child in pairs(self.children) do
        self:ParentChild(child)
        child:ClearAllPoints()
        child:SetPoint("TOPLEFT", 0, -height)
        height = height + child:GetHeight()

        if child:GetFullWidth() then
            local usedWidth = self:SetFullAnchor(child, 0, -height)
        end
        usedWidth = max(child:GetWidth(), usedWidth)
    end

    self:MarkDirty(usedWidth, height)
end

private.Fill = function(self)
    local child = self.children[1]
    if not child then
        return
    end

    child:ClearAllPoints()
    self:Fill(child, 0, 0)
end
