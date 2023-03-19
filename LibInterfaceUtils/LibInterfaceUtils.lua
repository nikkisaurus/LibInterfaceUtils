local addonName, private = ...
local lib, oldminor = LibStub:NewLibrary(addonName, 1)
if not lib then
    return
end

lib.pool = {}
lib.versions = {}

function lib:GetDropdownSelectedString(info, selected)
    local str
    if type(selected) == "table" then
        str = table.concat(
            private:TransformTable(selected, function(v)
                return info[FindInTableIf(info, function(V)
                    return V.value == v
                end)].text
            end),
            ", "
        )
    else
        str = info[FindInTableIf(info, function(V)
            return V.value == selected
        end)].text
    end

    return str
end

function lib:New(objectType)
    local object = self.pool[objectType]:Acquire()
    object:Show()
    object:Fire("OnAcquire")

    return object
end
