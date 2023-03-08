local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

function lib:CreateTestFrame()
    -- local loner = self:New("Button")
    -- loner:SetPoint("TOP")
    -- loner:SetFullWidth(true)

    local frame = self:New("Frame")
    frame:SetLayout("List")
    frame:SetPoint("CENTER")
    frame:SetSize(800, 600)
    frame:SetTitle("Test Frame")
    frame:SetStatus("Loading...")
    frame:SetSpacing(5, 5)

    local group = frame:New("CollapsibleGroup")
    -- group:SetLayout("List")
    group:SetFullWidth(true)
    group:SetLabel("Group")
    -- group:SetLabelFont(GameFontNormalHuge, CreateColor(0, 1, 0, 1))
    -- group:SetLabelFont(GameFontNormalHuge)
    -- group:EnableHeaderBackdrop(true, { bgEnabled = false })
    group:EnableBackdrop(true, { bgEnabled = true })
    -- group:SetBackdrop({
    --     -- bgEnabled = true,
    --     bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()),
    --     -- bordersEnabled = true,
    --     -- bordersColor = CreateColor(fastrandom(), fastrandom(), fastrandom()),
    -- })

    for i = 1, 49 do
        local button = group:New("Button")
        button:SetText(i)
        button:SetBackdrop({ bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()) })
        button:SetCallback("OnClick", function()
            print("Clicked", i)
        end)

        if i == 10 then
            local divider = group:New("Divider")
            divider:SetHeight(10)
            divider:SetColorTexture(1, 0, 0, 1)
        end
    end

    local divider = group:New("Divider")
    divider:SetHeight(10)
    divider:SetColorTexture(0, 1, 0, 1)

    local tex = group:New("Texture")
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

    local button = frame:New("Button")
    -- local button = lib:New("Button")
    button:SetText(50)
    -- button:SetWidth(900)
    button:SetFullWidth(true)
    -- button:SetFillWidth(true)
    -- button:SetFullHeight(true)

    -- local f = lib:New("Frame")
    -- f:SetPoint("CENTER")
    -- f:SetSize(500, 500)

    local tex2 = frame:New("Texture")
    tex2:SetAtlas("CreditsScreen-Keyart-9")
    tex2:SetFullWidth(true)
    tex2:SetFullHeight(true)
    tex2:SetPoint("CENTER")

    C_Timer.After(10, function()
        -- f:AddChild(tex2)
    end)

    -- button:SetParent(tex2) -- Do not do this; should be added to a container
    -- button:SetPoint("CENTER", tex2, "CENTER") -- Note that if it's not properly parented, scrollboxes won't take this into account

    frame:DoLayout()
end

SLASH_LIBINTERFACEUTILS1 = "/liu"
SlashCmdList["LIBINTERFACEUTILS"] = function()
    lib:CreateTestFrame()
end
