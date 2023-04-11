local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Label", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    disabled = {
        justifyH = "LEFT",
        color = private.assets.colors.dimmedWhite,
    },
    highlight = {
        justifyH = "LEFT",
    },
    normal = {
        justifyH = "LEFT",
    },
}

local maps = {
    methods = {
        GetText = true,
        IsTruncated = true,
        SetJustifyH = true,
        SetJustifyV = true,
        SetFontObject = true,
        SetFont = true,
        SetTextColor = true,
    },
}

local scripts = {
    -- OnSizeChanged = function(self)
    --     -- print("size changed")
    --     -- if self:Get("fullWidth") then
    --     --     print(self:GetWidth())
    --     --     self:SetStaticWidth(self:GetWidth())
    --     --     self:SetAnchors()
    --     -- end
    --     -- if self.label:CanWordWrap() and self.label:GetStringHeight() ~= self:GetHeight() then
    --     --     self:SetHeight(self.label:GetStringHeight())
    --     -- end
    -- end,
}

local methods = {
    OnAcquire = function(self)
        self:SetHeight(20)
        self:ApplyTemplate()
        self:SetWordWrap(true)
        self:SetText()
        self.icon:EnableMouse(false)
        self.label:EnableMouse(false)
        self:SetDisabled()
    end,

    ApplyTemplate = function(self, template)
        self:Set("template", type(template) == "table" and CreateFromMixins(defaults, template) or defaults)
        self:SetState(self:IsDisabled() and "disabled" or "normal")
    end,

    -- DoLayout = function(self, availableWidth, availableHeight)
    --     if availableWidth then
    --         print(availableWidth)
    --         self:SetWidth(availableWidth)
    --         self:SetAnchors()
    --     end
    --     return self:GetWidth(), self:GetHeight()
    -- end,

    SetAnchors = function(self)
        self.icon:ClearAllPoints()
        self.label:ClearAllPoints()

        local hasIcon = self:Get("icon")
        local iconPoint = self:Get("iconPoint")
        local canWrap = self.label:CanWordWrap()

        if hasIcon then
            self.icon:SetPoint(iconPoint)
            self.icon:Show()

            self.label:SetPoint(iconPoint, self.icon, private.points[iconPoint][1], private.points[iconPoint][2] * 5, private.points[iconPoint][3] * 5)
            self.label:SetPoint(private.points[iconPoint][1])

            if private.points[iconPoint][3] ~= 0 then
                self.label:SetPoint("LEFT")
                self.label:SetPoint("RIGHT")
                self.label:SetWidth(self:GetWidth())
                if canWrap then
                    self:SetHeight(self.icon:GetHeight() + self.label:GetStringHeight() + 5)
                else
                    self:SetHeight(self.icon:GetHeight() + self.label:GetHeight() + 5)
                end
            else
                self.label:SetWidth(self:GetWidth() - self.icon:GetWidth() - 5)
                if canWrap then
                    self:SetHeight(max(self.icon:GetHeight(), self.label:GetStringHeight() + 5))
                else
                    self:SetHeight(self.icon:GetHeight())
                end
            end
            self:SetSize(self:Get("width") or self.label:GetStringWidth(), self.label:GetStringHeight())
        else
            self.icon:SetSize(0, 0)
            self.icon:Hide()

            self.label:SetPoint("TOPLEFT")
            self.label:SetPoint("TOPRIGHT")

            print("width", self:GetWidth())
            -- if self:Get("fullWidth") then
            --     print(self:GetWidth(), self:GetRight(), self:GetLeft())
            -- end

            -- self:SetWidth(availableWidth or self:Get("width") or self.label:GetStringWidth())
            -- self.label:SetWidth(self:GetWidth())

            -- self.label:SetPoint("TOPLEFT")
            -- self.label:SetPoint("TOPRIGHT")
            -- if not self:Get("fullWidth") then
            --     self:SetWidth(self:Get("width") or self.label:GetStringWidth())
            --     -- print(self:GetText(), self:Get("width") or self.label:GetStringWidth())
            -- else
            --     self:SetWidth(self:GetWidth())
            -- end
            -- self.label:SetWidth(self:GetWidth())
            -- local width = self:GetWidth(true)
            -- self.label:SetWidth(width > 0 and width or self.label:GetStringWidth())
            -- print(width > 0 and width, self.label:GetStringWidth(), self:GetWidth())
            -- self:SetWidth(175)
            -- print(self:GetWidth(), self:GetWidth(true))
            -- -- self.label:SetWidth(self:Get("fullWidth") and self:GetWidth() or width or self.label:GetStringWidth())

            if canWrap then
                self:SetHeight(self.label:GetStringHeight())
            else
                self:SetHeight(20)
            end

            -- if not canWrap then
            --     self:SetHeight(max(self.icon:GetHeight(), self.label:GetStringHeight()))
            --     self.label:SetWidth(self:Get("width") or self.label:GetStringWidth())
            -- else
            --     self.label:SetWidth(self:Get("width") or self.label:GetStringWidth())
            --     self:SetHeight(max(self.icon:GetHeight(), self.label:GetStringHeight()))
            -- end
        end

        -- self:SetSize(self:Get("width") or self.label:GetStringWidth(), max(self.icon:GetHeight(), self.label:GetStringHeight()))
    end,

    SetDisabled = function(self, isDisabled)
        self:Set("isDisabled", isDisabled)
        self:SetState(isDisabled and "disabled" or "normal")
        self:EnableMouse(not isDisabled)
    end,

    SetIcon = function(self, icon, iconWidth, iconHeight, iconPoint, padding)
        self:Set("icon", icon)
        self:Set("iconPoint", iconPoint or "TOPLEFT")
        self:Set("padding", padding or 5)

        self.icon:SetTexture(icon)
        self.icon:SetWidth(iconWidth or 20)
        self.icon:SetHeight(iconHeight or 20)

        self:SetAnchors()
    end,

    SetState = function(self, state)
        self:Set("state", state)
        private:SetFont(self.label, self:Get("template")[state])
    end,

    SetStaticWidth = function(self, width)
        self:Set("width", width)
        print("static", width)
        self:SetWidth(width)
        self:SetAnchors()
    end,

    SetText = function(self, text)
        self.label:SetText(text or "")
        self:SetAnchors()
    end,

    SetWordWrap = function(self, ...)
        self.label:SetWordWrap(...)
        self:SetAnchors()
    end,
}

local function creationFunc()
    -- local label = private:Mixin(private.UIParent:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), "UserData")
    local frame = private:Mixin(CreateFrame("Frame", private:GetObjectName(objectType), private.UIParent), "UserData")
    private:ApplyBackdrop(frame)
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.label:SetAllPoints(frame)

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    private:Map(frame, frame.label, maps)

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
