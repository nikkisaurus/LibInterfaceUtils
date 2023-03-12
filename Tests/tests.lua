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
    -- frame:SetLayout("List")
    frame:SetPoint("CENTER")
    frame:SetSize(800, 600)
    frame:SetTitle("Test Frame")
    frame:SetStatus("Loading...")
    frame:SetSpacing(5, 5)

    local header = frame:New("Header")
    header:SetText("WHAT happens if I make this a longer header in hopes that it would either wrap or see how the strikethrough works out?? I guess we'll see.")
    -- header:SetStyle("STRIKETHROUGH")

    local edit = frame:New("EditBox")
    edit:SetLabel("Value how about that other long label going on here? Huh?")
    -- edit:SetFullWidth(true)
    edit:EnableButton(true)
    edit:SetCallback("OnEnterPressed", function(self)
        print("Do something with this info:", self:GetText(), self:GetNumber())
    end)
    -- edit:SetBackdrop({ bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()) })

    local search = frame:New("SearchBox")
    search:SetLabel("Lookup:")
    search:SetCallback("OnEnterPressed", function(self)
        print("Search")
    end)
    search:SetCallback("OnEditCleared", function(self)
        print("Clear results")
    end)
    -- edit:SetFullWidth(true)
    -- edit:SetBackdrop({ bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()) })

    local multi = frame:New("MultiLineEditBox")
    multi:SetFullWidth(true)
    multi:SetLabel("Write me something good or I will fail you in this class and you'll lose out on your scholarship")
    multi:SetSize(300, 150)
    multi:SetCallback("OnEnterPressed", function(self)
        print("Solid D-")
    end)

    local toggle = frame:New("CheckButton")
    toggle:SetLabel("Click me eserunt ipsum in sit do elit amet ad. Culpa pariatur aute cupidatat eiusmod cillum sit minim sint nostrud")
    toggle:SetAutoWidth(false)
    toggle:SetWidth(150)

    local checkGroup = frame:New("OptionGroup")
    checkGroup:SetFullWidth(true)
    checkGroup:SetLabel("Select an option")
    -- checkGroup:EnableBackdrop(true, { bgEnabled = true })
    checkGroup:SetMultiselect()
    checkGroup:SetInfo({
        {
            label = "Option 1",
            func = function()
                print("option ", 1)
                print(checkGroup:GetSelected())
            end,
        },
        {
            label = "Option 2",
            func = function()
                print("option ", 2)
                print(checkGroup:GetSelected())
            end,
        },
        {
            label = "Option 3",
            func = function()
                print("option ", 3)
                print(checkGroup:GetSelected())
            end,
        },
        {
            label = "Option 4",
            func = function()
                print("option ", 4)
                print(checkGroup:GetSelected())
            end,
        },
        {
            label = "Option 5",
            func = function()
                print("option ", 5)
                print(checkGroup:GetSelected())
            end,
        },
    })

    local checkGroup2 = frame:New("OptionGroup")
    checkGroup2:SetFullWidth(true)
    checkGroup2:SetSpacing(5, 5)
    checkGroup2:SetLabel("Select multiple options")
    -- checkGroup:EnableBackdrop(true, { bgEnabled = true })
    -- checkGroup2:SetMultiselect()
    checkGroup2:SetInfo({
        {
            label = "Option 1",
            fullWidth = true,
            func = function()
                print("option ", 1)
                print(checkGroup2:GetSelected())
            end,
        },
        {
            label = "Option 2",
            fullWidth = true,
            func = function()
                print("option ", 2)
                print(checkGroup2:GetSelected())
            end,
        },
        {
            label = "Option 3",
            fullWidth = true,
            func = function()
                print("option ", 3)
                print(checkGroup2:GetSelected())
            end,
        },
        {
            label = "Option 4",
            fullWidth = true,
            func = function()
                print("option ", 4)
                print(checkGroup2:GetSelected())
            end,
        },
        {
            label = "Option 5",
            fullWidth = true,
            func = function()
                print("option ", 5)
                print(checkGroup2:GetSelected())
            end,
        },
    })

    local bunchaOptions = frame:New("CollapsibleGroup")
    bunchaOptions:SetFullWidth(true)
    bunchaOptions:SetLabel("Select multiple options")
    bunchaOptions:EnableBackdrop(true, { bgEnabled = true })

    local checkGroup3 = bunchaOptions:New("OptionGroup")
    checkGroup3:SetFullWidth(true)
    checkGroup3:SetSpacing(5, 5)
    checkGroup3:EnableBackdrop()
    local info = {}
    for i = 1, 50 do
        tinsert(info, {

            label = "Option " .. i,
            -- fullWidth = true,
            width = 150,
            func = function()
                print("option ", i)
                print(checkGroup3:GetSelected())
            end,
        })
    end
    checkGroup3:SetInfo(info)

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

    for k, v in pairs({ "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM" }) do
        local label = group:New("Label")
        label:SetFullWidth(true)
        label:SetText("Ad proident anim mollit excepteur ex deserunt non amet sit quis proident esse excepteur pariatur. Ea reprehenderit anim adipisicing irure exercitation. Incididunt in deserunt ipsum in sit do elit amet ad. Culpa pariatur aute cupidatat eiusmod cillum sit minim sint nostrud. Consequat labore exercitation ut elit aliqua minim. Amet eiusmod sint magna ex qui irure aute.")
        label:SetIcon(134400, nil, nil, v)
        -- label:SetCallback("OnMouseDown", function()
        --     print("Hi label")
        -- end)
    end

    local header = group:New("Header")
    header:SetText("No more wrapping!")
    header:SetStyle("STRIKETHROUGH")

    for k, v in pairs({ "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM" }) do
        local label = group:New("Label")
        label:SetFullWidth(true)
        label:SetWordWrap(false)
        label:SetText("Ad proident anim mollit excepteur ex deserunt non amet sit quis proident esse excepteur pariatur. Ea reprehenderit anim adipisicing irure exercitation. Incididunt in deserunt ipsum in sit do elit amet ad. Culpa pariatur aute cupidatat eiusmod cillum sit minim sint nostrud. Consequat labore exercitation ut elit aliqua minim. Amet eiusmod sint magna ex qui irure aute.")
        label:SetIcon(134400, nil, nil, v)
    end

    local buttongroup = frame:New("CollapsibleGroup")
    buttongroup:SetFullWidth(true)
    buttongroup:SetLabel("Yay colors")
    buttongroup:Collapse(true)

    for i = 1, 49 do
        local button = buttongroup:New("Button")
        button:SetText(i)
        button:SetBackdrop({ bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()) })
        button:SetCallback("OnClick", function()
            print("Clicked", i)
        end)

        if i == 10 then
            local divider = buttongroup:New("Divider")
            divider:SetHeight(10)
            divider:SetColorTexture(1, 0, 0, 1)
        end
    end

    local divider = frame:New("Divider")
    divider:SetHeight(10)
    -- divider:SetColorTexture(0, 1, 0, 1)

    local tex = frame:New("Texture")
    tex:SetAtlas("raceicon128-bloodelf-female")

    local texOverlay = lib:New("Texture")
    texOverlay:SetColorTexture(fastrandom(), fastrandom(), fastrandom(), 1)
    texOverlay:SetParent(tex)
    texOverlay:SetAllPoints(tex)

    texOverlay:SetInteractible(true)
    texOverlay:SetCallback("OnMouseDown", function(...)
        texOverlay:Release()
    end)

    local button = frame:New("Button")
    button:SetAutoWidth(true)
    -- local button = lib:New("Button")
    button:SetText(50)
    -- button:SetWidth(900)
    -- button:SetFullWidth(true)
    -- button:SetFillWidth(true)
    -- button:SetFullHeight(true)

    -- local f = lib:New("Frame")
    -- f:SetPoint("CENTER")
    -- f:SetSize(500, 500)

    local tex2 = frame:New("Texture")
    tex2:SetAtlas("CreditsScreen-Keyart-9")
    -- tex2:SetFullWidth(true)
    -- tex2:SetFullHeight(true)
    -- tex2:SetPoint("CENTER")

    C_Timer.After(10, function()
        -- f:AddChild(tex2)
    end)

    -- button:SetParent(tex2) -- Do not do this; should be added to a container
    -- button:SetPoint("CENTER", tex2, "CENTER") -- Note that if it's not properly parented, scrollboxes won't take this into account

    frame:DoLayout()
end

SLASH_LIBINTERFACEUTILS1 = "/liu"
SlashCmdList["LIBINTERFACEUTILS"] = function()
    print("New")
    lib:CreateTestFrame()
end
