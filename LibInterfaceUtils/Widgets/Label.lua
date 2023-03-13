local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Label", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local maps = {
    methods = {
        EnableMouse = true,
        SetJustifyH = true,
        SetJustifyV = true,
        SetWordWrap = true,
    },
}

local registry = {
    OnEnter = true,
    OnHide = true,
    OnLeave = true,
    OnMouseDown = true,
    OnMouseUp = true,
    OnShow = true,
}

local scripts = {
    OnSizeChanged = function(self)
        self:SetAnchors()
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 20)
        self:SetLabelFont(GameFontHighlight)
        self:SetJustifyH("LEFT")
        self:SetJustifyV("MIDDLE")
        self:SetWordWrap(true)
        self:SetIcon()
        self:SetText()
        self:SetInteractible()
    end,

    SetAnchors = function(self)
        self.icon:ClearAllPoints()
        self.label:ClearAllPoints()

        local iconPoint = self:GetUserData("iconPoint")
        local hasIcon = self:GetUserData("icon")
        local canWrap = self.label:CanWordWrap()

        if hasIcon then
            self.icon:SetPoint(iconPoint)
            self.label:SetPoint(iconPoint, self.icon, private.points[iconPoint][1], private.points[iconPoint][2] * 5, private.points[iconPoint][3] * 5)
            self.label:SetPoint(private.points[iconPoint][1], -(private.points[iconPoint][2] * 5), -(private.points[iconPoint][3] * 5))

            if private.points[iconPoint][3] ~= 0 then
                self.label:SetPoint("LEFT")
                self.label:SetPoint("RIGHT")
                self.label:SetWidth(self:GetWidth())
                if canWrap then
                    self:SetHeight(self.icon:GetHeight() + self.label:GetStringHeight() + 10)
                else
                    self:SetHeight(self.icon:GetHeight() + self.label:GetHeight() + 10)
                end
            else
                -- TODO FIX ME label height is cutting off
                self.label:SetWidth(self:GetWidth() - self.icon:GetWidth() - 5)
                if canWrap then
                    self:SetHeight(max(self.icon:GetHeight(), self.label:GetStringHeight()))
                else
                    self:SetHeight(self.icon:GetHeight())
                end
            end
        else
            self.icon:SetSize(0, 0)
            self.label:SetPoint("TOPLEFT")
            self.label:SetPoint("TOPRIGHT")
            self.label:SetWidth(self:GetWidth()) -- need to set to make sure height is properly calculated
            if canWrap then
                self:SetHeight(self.label:GetStringHeight())
            end
        end
    end,

    SetIcon = function(self, icon, width, height, point)
        self:SetUserData("icon", icon)
        self.icon:SetTexture(icon)
        self.icon:SetWidth(width or 20)
        self.icon:SetHeight(height or 20)
        self:SetUserData("iconPoint", point or "TOPLEFT")

        self:SetAnchors()
    end,

    SetInteractible = function(self, isInteractible)
        self:EnableMouse(isInteractible or false)
    end,

    SetText = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    SetLabelFont = function(self, fontObject, color)
        self.label:SetFontObject(fontObject)
        self.label:SetTextColor((color or private.assets.colors.white):GetRGBA())
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
        registry = registry,
    }

    private:Map(frame, frame.label, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
