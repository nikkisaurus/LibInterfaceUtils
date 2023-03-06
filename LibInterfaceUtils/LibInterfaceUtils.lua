local addonName, private = ...
local lib, oldminor = LibStub:NewLibrary(addonName, 1)

if not lib then
    return
end

lib.pool = {}
lib.versions = {}

function lib:New(objectType)
    local object = self.pool[objectType]:Acquire()
    object:Fire("OnAcquire")
    object.overrideForbidden = false

    return object
end

function lib:CreateTestFrame()
    local frame = self:New("Frame")
    -- frame:SetLayout("List")
    frame:SetPoint("CENTER")
    frame:SetSize(800, 600)
    frame:SetTitle("Test Frame")
    frame:SetStatus("Loading...")
    frame:SetSpacing(5, 5)
    for i = 1, 49 do
        local button = frame:New("Button")
        button:SetText(i)
    end

    local button = frame:New("Button")
    button:SetText(50)
    button:SetWidth(900)
    -- button:SetFillWidth(true)
    -- button:SetFullWidth(true)
    button:SetFullHeight(true)

    frame:DoLayout()
end

local ContainerMethods, ObjectMethods

ContainerMethods = {
    DoLayout = function(self)
        self:layoutFunc()
        self:Fire("OnLayoutFinished")
    end,

    New = function(self, objectType)
        local object = lib:New(objectType)
        tinsert(self.children, object)

        return object
    end,

    ReleaseChildren = function(self)
        for _, child in pairs(self.children) do
            child:Release()
        end
    end,

    SetLayout = function(self, layout, customFunc)
        self.layoutFunc = customFunc or private[layout or "Flow"]
        self.layoutRef = customFunc and "custom" or layout or "Flow"
    end,

    -- Required container methods (relies on protected frames): Fill, FillX, FillY, GetAvailableWidth, MarkDirty, ParentChild
}

ObjectMethods = {
    Fire = function(self, script, ...)
        if self:HasScript(script) then
            self:GetScript(script)(self, ...)
        elseif self[script] then
            self[script](self, ...)
        end
    end,

    GetFillWidth = function(self)
        return self:GetUserData("fillWidth")
    end,

    GetFullHeight = function(self)
        return self:GetUserData("fullHeight")
    end,

    GetFullWidth = function(self)
        return self:GetUserData("fullWidth")
    end,

    GetUserData = function(self, key)
        return self.widget.userdata[key]
    end,

    Release = function(self)
        if self.ReleaseChildren then
            self:ReleaseChildren()
            wipe(self.children)
        end

        lib.pool[self.widget.type]:Release(self)

        self:Fire("OnRelease")
        wipe(self.widget.userdata)
    end,

    SetCallback = function(self, script, handler)
        self.widget.callbacks[script] = handler
    end,

    SetDraggable = function(self, isDraggable, ...)
        self:EnableMouse(isDraggable or false)
        self:SetMovable(isDraggable or false)
        self:RegisterForDrag(...)
    end,

    SetFillWidth = function(self, fillWidth)
        self:SetUserData("fillWidth", fillWidth)
    end,

    SetFullHeight = function(self, isFullHeight)
        self:SetUserData("fullHeight", isFullHeight)
    end,

    SetFullWidth = function(self, isFullWidth)
        self:SetUserData("fullWidth", isFullWidth)
    end,

    SetOffsets = function(self, xOffset, yOffset, xFill, yFill)
        self:SetUserData("xOffset", xOffset)
        self:SetUserData("yOffset", yOffset)
        self:SetUserData("xFill", xFill)
        self:SetUserData("yFill", yFill)
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:SetUserData("spacingH", spacingH)
        self:SetUserData("spacingV", spacingV)
    end,

    SetUserData = function(self, key, value)
        self.widget.userdata[key] = value
    end,
}

local function GetNumObjects(self)
    assert(self.EnumerateActive and self.EnumerateInactive, "Attempting to call GetNumObjects on a non-pool object.")

    local count = 0
    for _, _ in self:EnumerateActive() do
        count = count + 1
    end
    for _, _ in self:EnumerateInactive() do
        count = count + 1
    end
    return count
end

local function Resetter(_, self)
    self:ClearAllPoints()
    self:Hide()
end

function private:CreateTexture(parent)
    assert(parent, "Invalid argument for private:CreateTexture(parent): parent")

    local bg = parent:CreateTexture("$parentBackground", "BACKGROUND")
    bg:SetAllPoints(parent)

    local borders = {}

    local top = parent:CreateTexture("%parentBorderTop", "BORDER")
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    borders.top = top

    local left = parent:CreateTexture("%parentBorderLeft", "BORDER")
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    borders.left = left

    local right = parent:CreateTexture("%parentBorderRight", "BORDER")
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    borders.right = right

    local bottom = parent:CreateTexture("%parentBorderBottom", "BORDER")
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    borders.bottom = bottom

    return bg, borders
end

function private:DrawBorders(borders, borderSize, borderColor)
    for id, border in pairs(borders) do
        border:SetColorTexture((borderColor or private.assets.colors.black):GetRGBA())
        local size = PixelUtil.GetNearestPixelSize(borderSize or 1, UIParent:GetEffectiveScale(), 1)

        if id == "top" or id == "bottom" then
            border:SetHeight(size)
        elseif id == "left" or id == "right" then
            border:SetWidth(size)
        end
    end
end

function private:GetObjectName(objectType)
    return addonName .. objectType .. (lib.pool[objectType]:GetNumObjects() + 1)
end

function private:RegisterContainer(container, ...)
    container.object.children = {}
    container.object = Mixin(container.object, ContainerMethods)
    container.object:SetLayout()

    return private:RegisterWidget(container, ...)
end

function private:RegisterWidget(widget, methods, scripts)
    widget.callbacks = {}
    widget.userdata = {}

    lib.versions[widget.type] = widget.version

    widget.object.widget = widget
    widget.object = Mixin(widget.object, ObjectMethods)

    if methods then
        widget.object = Mixin(widget.object, methods)
    end

    local registry = widget.callbackRegistry

    if scripts then
        for script, handler in pairs(scripts) do
            assert(widget.object:HasScript(script), format("Script '%s' does not exist for object type '%s'.", script, widget.type))

            widget.object:SetScript(script, function(...)
                handler(...)

                if registry and registry[script] and widget.callbacks[script] then
                    widget.callbacks[script](...)
                end
            end)
        end
    end

    if registry then
        for script, _ in pairs(registry) do
            if widget.object:HasScript(script) and not widget.object:GetScript(script) then
                widget.object:SetScript(script, function(...)
                    if widget.callbacks[script] then
                        widget.callbacks[script](...)
                    end
                end)
            end
        end
    end

    if widget.forbidden then
        for method, _ in pairs(widget.forbidden) do
            local originalMethod = widget.object[method]

            widget.object[method] = function(...)
                if widget.object.overrideForbidden then
                    return originalMethod(...)
                else
                    error(format("Method '%s' for object type '%s' is forbidden.", method, widget.type))
                end
            end
        end
    end

    return widget.object
end

function private:RegisterWidgetPool(objectType, creationFunc, resetterFunc)
    lib.pool[objectType] = CreateObjectPool(creationFunc, resetterFunc or Resetter)
    lib.pool[objectType]:SetResetDisallowedIfNew(true)
    lib.pool[objectType].GetNumObjects = GetNumObjects
end

function private:SetBackdrop(bg, borders, backdrop)
    if bg then
        bg:SetColorTexture((backdrop and backdrop.bgColor or private.assets.colors.dimmedBackdrop):GetRGBA())
    end
    if borders then
        private:DrawBorders(borders, 1, (backdrop and backdrop.borderColor or private.assets.colors.black))
    end
end

function private:SetFont(fontString, font)
    if not font then
        return
    end

    if type(font.font) == "string" then
        fontString:SetFontObject(_G[font.font])
    elseif type(font.font) == "table" then
        fontString:SetFont(unpack(font.font))
    end

    if font.color then
        fontString:SetTextColor(font.color:GetRGBA())
    end
end

private.assets = {
    colors = {
        backdrop = CreateColor(26 / 255, 26 / 255, 26 / 255, 1),
        black = CreateColor(0, 0, 0, 1),
        dimmedBackdrop = CreateColor(15 / 255, 15 / 255, 15 / 255, 0.8),
        uiGold = CreateColor(1, 0.82, 0, 1),
    },
}
