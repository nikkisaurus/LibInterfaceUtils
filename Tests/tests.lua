local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
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
        button:SetBackdrop({ bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()) })
        button:SetCallback("OnClick", function()
            print("Clicked", i)
        end)

        if i == 10 then
            local divider = frame:New("Divider")
            divider:SetHeight(10)
            divider:SetColorTexture(1, 0, 0, 1)
        end
    end

    local tex = frame:New("Texture")
    tex:SetAtlas("raceicon128-bloodelf-female")

    local texOverlay = lib:New("Texture")
    texOverlay:SetColorTexture(1, 1, 1, 0.5)
    texOverlay:SetParent(tex)
    texOverlay:SetAllPoints(tex)
    texOverlay:SetBlendMode("ADD")

    tex:EnableMouse(true)
    tex:SetCallback("OnMouseDown", function(...)
        texOverlay:Release()
    end)

    local tex2 = frame:New("Texture")
    tex2:SetAtlas("CreditsScreen-Keyart-9")
    tex2:SetFullWidth(true)
    tex2:SetFullHeight(true)

    local button = frame:New("Button")
    -- local button = lib:New("Button")
    button:SetText(50)
    button:SetWidth(900)

    -- button:SetParent(tex2) -- Do not do this; should be added to a container
    -- button:SetPoint("CENTER", tex2, "CENTER") -- Note that if it's not properly parented, scrollboxes won't take this into account
    -- button:SetFillWidth(true)
    -- button:SetFullWidth(true)
    -- button:SetFullHeight(true)

    frame:DoLayout()
end

SLASH_LIBINTERFACEUTILS1 = "/liu"
SlashCmdList["LIBINTERFACEUTILS"] = function()
    lib:CreateTestFrame()
end
