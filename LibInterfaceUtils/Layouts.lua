local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

private.List = function(self)
    local height = 0
    local usedWidth = 0
    for _, child in pairs(self.children) do
        child:SetPoint("TOPLEFT", 0, -height)
        height = height + child:GetHeight()

        if child:GetFullWidth() then
            self:SetFullAnchor(child, height)
        end
        usedWidth = max(child:GetWidth(), usedWidth)
    end

    self:MarkDirty(usedWidth, height)
end
