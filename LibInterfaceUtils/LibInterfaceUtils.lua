local addonName, private = ...
local lib, oldminor = LibStub:NewLibrary(addonName, 1)

if not lib then
    return
end

local ContainerMethods, ObjectMethods

ContainerMethods = {
    New = function(self, objectType)
        local object = lib:New(objectType)
        object:SetParent(self.content)
        tinsert(self.children, object)

        return object
    end,

    DoLayout = function(self)
        self.layoutFunc(self)
        self:Fire("OnLayoutFinished")
    end,

    ReleaseChildren = function(self)
        for _, child in pairs(self.children) do
            child:Release()
        end
    end,

    SetLayout = function(self, func)
        self.layoutFunc = func or private.List
    end,
}

ObjectMethods = {
    Fire = function(self, handler, ...)
        if self[handler] then
            self[handler](self, ...)
        end
    end,

    GetFullWidth = function(self)
        return self:GetUserData("fullWidth")
    end,

    GetUserData = function(self, key)
        return self.userdata[key]
    end,

    Release = function(self)
        if self.ReleaseChildren then
            self:ReleaseChildren()
            wipe(self.children)
        end

        lib.pool[self.type]:Release(self)

        self:Fire("OnRelease")
        wipe(self.userdata)
    end,

    SetFullWidth = function(self, isFullWidth)
        self:SetUserData("fullWidth", isFullWidth)
    end,

    SetUserData = function(self, key, value)
        self.userdata[key] = value
    end,
}

lib.pool = {}

private.assets = {
    colors = {
        backdrop = CreateColor(26 / 255, 26 / 255, 26 / 255, 1),
        black = CreateColor(0, 0, 0, 1),
        dimmedBackdrop = CreateColor(15 / 255, 15 / 255, 15 / 255, 0.8),
        uiGold = CreateColor(1, 0.82, 0, 1),
    },
}

local function ForbiddenFunc(objectType, method)
    error(format("Method '%s' for object type '%s' is forbidden.", method, objectType))
end

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

private.List = function(self)
    local height = 0
    local usedWidth = 0
    for _, child in pairs(self.children) do
        child:SetPoint("TOPLEFT", 0, -height)
        height = height + child:GetHeight()

        if child:GetFullWidth() then
            child:SetPoint("TOPRIGHT", self.verticalBox, "TOPRIGHT", 0, -height)
        end
        usedWidth = max(child:GetWidth(), usedWidth)
    end

    self.content:SetSize(usedWidth, height)
    self:MarkDirty()
end

function private:GetObjectName(objectType)
    return addonName .. objectType .. (lib.pool[objectType]:GetNumObjects() + 1)
end

function lib:New(objectType)
    local object = self.pool[objectType]:Acquire()
    object:Fire("OnAcquire")
    object.overrideForbidden = false

    return object
end

function private:RegisterContainer(object, ...)
    object.children = {}

    object = Mixin(object, ContainerMethods)
    object:SetLayout()

    return private:RegisterObject(object, ...)
end

function private:RegisterObject(object, objectType, version, handlers, methods, scripts)
    object.type = objectType
    object.version = version
    object.userdata = {}

    object = Mixin(object, ObjectMethods)

    if handlers then
        object = Mixin(object, handlers)
    end

    if methods then
        for method, _ in pairs(methods) do
            local original = object[method]
            object[method] = function(...)
                if object.overrideForbidden then
                    return original(...)
                else
                    ForbiddenFunc(objectType, method)
                end
            end
        end
    end

    if scripts then
        for script, handler in pairs(scripts) do
            assert(object:HasScript(script), format("Script '%s' does not exist for object type '%s'.", script, objectType))

            object:SetScript(script, handler)
        end
    end

    return object
end

function private:RegisterObjectPool(objectType, creationFunc, resetterFunc)
    lib.pool[objectType] = CreateObjectPool(creationFunc, resetterFunc or Resetter)
    lib.pool[objectType]:SetResetDisallowedIfNew(true)
    lib.pool[objectType].GetNumObjects = GetNumObjects
end
