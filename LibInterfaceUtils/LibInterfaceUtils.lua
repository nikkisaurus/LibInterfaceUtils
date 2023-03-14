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
    object:Show()

    return object
end
