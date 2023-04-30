local addonName, private = ...
local lib, oldminor = LibStub:NewLibrary(addonName, 1)
if not lib then
    return
end
