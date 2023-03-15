local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)
if not lib then
    return
end

function lib:CreateFrame()
    local frame = self:New("Frame")
    frame:SetPoint("CENTER")
    frame:SetSize(800, 600)
    frame:SetTitle("Frame")
    frame:SetSpacing(5, 5)
    frame:SetCallback("OnUpdate", function()
        frame:SetStatus(date("%x %X", time()))
    end)
    -- frame:SetLayout("List")
    -- frame:ApplyTemplate("transparent")
    -- frame:ApplyTemplate({
    --     frame = {
    --         -- bgTexture = "interface/professions/professionbackgroundartalchemy",
    --         -- bgColor = CreateColor(1, 1, 1, 1),
    --         -- bgTexCoord = { 0, 0.75, 0, 0.25 },
    --         -- bgAtlas = "Professions-Recipe-Background-Alchemy",
    --         -- highlightColor = CreateColor(1, 1, 1, 1),
    --         -- highlightEnabled = true,
    --         -- highlightAtlas = "Professions-Recipe-Background-Enchanting",
    --         -- highlightBlendMode = "DISABLE",
    --     },
    -- })

    local header = frame:New("Header")
    header:SetText("Widgets")

    local editBoxes = frame:New("CollapsibleGroup")
    editBoxes:SetFullWidth(true)
    editBoxes:SetSpacing(5, 5)
    editBoxes:SetLabel("EditBoxes")
    editBoxes:ApplyTemplate("bordered")
    editBoxes:Collapse(true)
    -- editBoxes:SetLayout("List")

    local searchBox = editBoxes:New("SearchBox")
    searchBox:SetLabel("SearchBox")
    searchBox:SetCallback("OnEnterPressed", function(self)
        print("Process search")
    end)
    searchBox:SetCallback("OnEditCleared", function(self)
        -- searchBox only
        print("Clear results")
    end)

    -- local divider = editBoxes:New("Divider")
    -- divider:SetHeight(1)
    -- divider:SetUserData("yOffset", 2)

    local editBox = editBoxes:New("EditBox")
    editBox:SetLabel("EditBox")

    local multi = editBoxes:New("MultiLineEditBox")
    multi:SetFullWidth(true)
    multi:SetLabel("MultiLineEditBox")

    -- local checkButtons = frame:New("Group")
    local checkButtons = frame:New("CollapsibleGroup")
    checkButtons:Collapse(true)
    checkButtons:SetFullWidth(true)
    checkButtons:SetLabel("CheckButtons")
    checkButtons:SetSpacing(5, 5)
    checkButtons:ApplyTemplate("bordered")
    -- checkButtons:SetLayout("List")

    local checkButton1 = checkButtons:New("CheckButton")
    checkButton1:SetLabel("Ad adipisicing ut laboris enim commodo duis duis veniam adipisicing occaecat aliquip minim Lorem.")
    checkButton1:SetAutoWidth(false)
    checkButton1:SetWidth(150)

    local checkButton2 = checkButtons:New("CheckButton")
    checkButton2:SetLabel("Ut nisi cupidatat ipsum pariatur consectetur cillum ex in deserunt. Voluptate enim sunt laborum tempor cupidatat velit velit. Aliquip velit excepteur commodo exercitation pariatur pariatur cupidatat ad mollit est fugiat elit labore officia. Occaecat proident id nisi pariatur dolore irure voluptate do aliqua dolore aute incididunt magna. Est cillum sunt nisi ea sit velit eu ullamco ea adipisicing. Sit dolore id laborum non ex Lorem dolore do.")
    checkButton2:SetAutoWidth(false)
    checkButton2:SetWidth(150)
    checkButton2:SetFillWidth(true)

    -- for i = 1, 150 do
    --     local check = checkButtons:New("CheckButton")
    --     check:SetLabel("Check " .. i)
    -- end

    local info = {}
    for i = 1, 50 do
        tinsert(info, {
            label = "Option " .. i,
            width = 150,
            func = function(group)
                print(i, "Selected:", group:GetSelected())
            end,
        })
    end

    local radioGroup = checkButtons:New("OptionGroup")
    radioGroup:SetFullWidth(true)
    radioGroup:SetLabel("Select an option")
    radioGroup:SetMultiselect()
    radioGroup:SetInfo(info)

    local checkGroup = checkButtons:New("OptionGroup")
    checkGroup:SetFullWidth(true)
    checkGroup:SetLabel("Select multiple options")
    checkGroup:SetInfo(info)

    local collapsibleCheckGroup = checkButtons:New("CollapsibleGroup")
    collapsibleCheckGroup:SetUserData("name", "collapsibleCheckGroup")
    collapsibleCheckGroup:SetFullWidth(true)
    collapsibleCheckGroup:SetLabel("Select multiple options")
    collapsibleCheckGroup:ApplyTemplate("bordered")

    local collapsibleCheckOptions = collapsibleCheckGroup:New("OptionGroup")
    collapsibleCheckOptions:SetUserData("name", "collapsibleCheckOptions")
    collapsibleCheckOptions:SetFullWidth(true)
    collapsibleCheckOptions:SetInfo(info)
    collapsibleCheckOptions:SetPadding(0, 0, 0, 0)
    collapsibleCheckOptions:ApplyTemplate()

    local labels = frame:New("CollapsibleGroup")
    labels:SetFullWidth(true)
    labels:SetSpacing(5, 5)
    labels:SetLabel("Labels")
    labels:ApplyTemplate("bordered")
    labels:Collapse(true)

    for k, v in pairs({ "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM" }) do
        local label = labels:New("Label")
        label:SetFullWidth(true)
        label:SetText("Ipsum minim ut est ea. Nostrud nulla nostrud anim sit proident. Nisi proident excepteur nostrud do fugiat consequat irure fugiat exercitation. Ipsum mollit culpa esse nisi occaecat laborum excepteur proident enim sint cupidatat laboris laborum officia. Voluptate aliquip sint quis anim ex aliqua et velit sunt exercitation ut elit. Magna dolor in dolor non mollit labore eiusmod et ullamco adipisicing do et sunt.")
        label:SetIcon(134400, nil, nil, v)
    end

    local header = labels:New("Header")
    header:SetText("Without Word Wrap")
    header:SetStyle("STRIKETHROUGH")

    for k, v in pairs({ "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM" }) do
        local label = labels:New("Label")
        label:SetFullWidth(true)
        label:SetWordWrap(false)
        label:SetText("Amet fugiat dolore deserunt et consectetur irure. Commodo occaecat occaecat ullamco magna dolor voluptate qui et. Pariatur consectetur non nulla consequat deserunt et nostrud magna incididunt id aliquip reprehenderit. Non do est occaecat velit sunt nostrud cillum et eu labore deserunt.")
        label:SetIcon(134400, nil, nil, v)
    end

    local buttons = frame:New("CollapsibleGroup")
    buttons:SetFullWidth(true)
    buttons:SetLabel("Buttons")
    buttons:Collapse(true)
    -- buttons:SetLayout("List")

    for i = 1, 50 do
        local button = buttons:New("Button")
        button:SetText(i)
        -- button:SetBackdrop({ bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom()) })
        -- button:SetWidth(500)
        button:SetCallback("OnClick", function()
            print("Clicked", i)
        end)
    end

    local divider = frame:New("Divider")
    divider:SetHeight(10)
    -- divider:SetColorTexture(0, 0, 1, 1)

    local texture = frame:New("Texture")
    texture:SetAtlas(format("Rune-0%d-light", fastrandom(1, 9)))
    -- texture:SetAtlas("raceicon128-bloodelf-female")

    local giftWrapping = frame:New("Texture")
    giftWrapping:SetColorTexture(fastrandom(), fastrandom(), fastrandom(), 1)
    giftWrapping:SetInteractible(true)
    giftWrapping:SetCallback("OnMouseDown", function(...)
        -- giftWrapping:Release()
        giftWrapping:SetTexture(236547)
    end)

    local btn = frame:New("Button")
    btn:SetText("Click")
    btn:SetCallback("OnClick", function()
        editBoxes:Release()
    end)

    local artwork = frame:New("Texture")
    artwork:SetAtlas("CreditsScreen-Keyart-9")
    artwork:SetFullWidth(true)
    artwork:SetFullHeight(true)

    frame:DoLayout()
end

function lib:CreateTabWindow()
    local window = self:New("Window")
    window:SetPoint("CENTER")
    window:SetSize(800, 600)
    window:SetTitle("Tab Group")
    window:SetSpacing(5, 5)
    window:SetLayout("Fill")
    -- window:ApplyTemplate("transparent")

    local tabs = {}
    for i = 1, fastrandom(1, 40) do
        tinsert(tabs, {
            text = "Tab " .. i,
            disabled = fastrandom(1, 2) == 1,
            onClick = function(content)
                for x = 1, fastrandom(1, 200) do
                    local button = content:New("Button")
                    -- button:SetFullWidth(true)
                    button:SetText(x)
                    button:SetDisabled(fastrandom(1, 2) == 1)
                    button:ApplyTemplate({
                        disabled = {
                            bgColor = private.assets.colors.darkest,
                        },
                        highlight = {
                            bordersColor = private.assets.colors.black,
                            bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                        },
                        normal = {
                            bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                        },
                    })
                end
            end,
        })
    end

    local tabGroup = window:New("TabGroup")
    tabGroup:SetTabs(tabs)
    -- tabGroup:SetLayout("List")
end

function lib:CreateTreeWindow()
    local window = self:New("Window")
    window:SetPoint("CENTER")
    window:SetSize(800, 600)
    window:SetTitle("Tree Group")
    window:SetSpacing(5, 5)
    window:SetLayout("Fill")

    local tree = {}
    for i = 1, fastrandom(1, 40) do
        tinsert(tree, {
            -- text = "Node " .. i .. (fastrandom(1, 2) == 1 and " long node name so I can check out the wrapping situation" or ""),
            text = "Node " .. i,
            -- icon = fastrandom(1, 2) == 1 and 134400,
            -- icon = 134400,
            disabled = fastrandom(1, 2) == 1,
            children = fastrandom(1, 2) == 1 and {
                {
                    text = "Child " .. 1,
                    -- icon = fastrandom(1, 2) == 1 and 134400,
                    icon = 134400,
                    disabled = fastrandom(1, 2) == 1,
                    onClick = function(content)
                        for x = 1, fastrandom(1, 200) do
                            local button = content:New("Button")
                            -- button:SetFullWidth(true)
                            button:SetText(x)
                            button:SetDisabled(fastrandom(1, 2) == 1)
                            button:ApplyTemplate({
                                disabled = {
                                    bgColor = private.assets.colors.darkest,
                                },
                                highlight = {
                                    bordersColor = private.assets.colors.black,
                                    bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                                },
                                normal = {
                                    bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                                },
                            })
                        end
                    end,
                },
                {
                    text = "Child " .. 2,
                    -- icon = fastrandom(1, 2) == 1 and 134400,
                    icon = 134400,
                    disabled = fastrandom(1, 2) == 1,
                    onClick = function(content)
                        for x = 1, fastrandom(1, 200) do
                            local button = content:New("Button")
                            -- button:SetFullWidth(true)
                            button:SetText(x)
                            button:SetDisabled(fastrandom(1, 2) == 1)
                            button:ApplyTemplate({
                                disabled = {
                                    bgColor = private.assets.colors.darkest,
                                },
                                highlight = {
                                    bordersColor = private.assets.colors.black,
                                    bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                                },
                                normal = {
                                    bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                                },
                            })
                        end
                    end,
                },
            },
            onClick = function(content)
                for x = 1, fastrandom(1, 200) do
                    local button = content:New("Button")
                    -- button:SetFullWidth(true)
                    button:SetText(x)
                    button:SetDisabled(fastrandom(1, 2) == 1)
                    button:ApplyTemplate({
                        disabled = {
                            bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 0.1),
                        },
                        highlight = {
                            bordersColor = private.assets.colors.black,
                            bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                        },
                        normal = {
                            bgColor = CreateColor(fastrandom(), fastrandom(), fastrandom(), 1),
                        },
                    })
                end
            end,
        })
    end

    local treeGroup = window:New("TreeGroup")
    treeGroup:SetTree(tree)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    -- lib:CreateFrame()
    -- lib:CreateTabWindow()
    lib:CreateTreeWindow()
end)

SLASH_LIBINTERFACEUTILS1 = "/liu"
SlashCmdList["LIBINTERFACEUTILS"] = function(input)
    input = input and input:lower()
    if input == "tabwindow" then
        lib:CreateTabWindow()
    elseif input == "treewindow" then
        lib:CreateTreeWindow()
    else
        lib:CreateFrame()
    end
end
