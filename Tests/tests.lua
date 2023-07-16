local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local usedIcons = {}

local icons = {
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Druid",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Hunter",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Paladin",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Priest",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-DemonHunter",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-DeathKnight",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Evoker",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Mage",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Rogue",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Warrior",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Warlock",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Shaman",
	"UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Monk",
}

local ipsum = {
	"Fugiat id veniam quis culpa minim velit et anim ad exercitation nulla dolor non deserunt. Sit adipisicing duis magna sit Lorem veniam minim ullamco. Duis et eiusmod reprehenderit adipisicing aute deserunt Lorem exercitation exercitation commodo sunt ut. Tempor adipisicing et nulla quis consectetur non est consectetur minim elit irure.",
	"Consectetur est pariatur aute cupidatat officia eu. Irure laboris consectetur esse pariatur enim sunt irure. Fugiat adipisicing Lorem consectetur dolor occaecat dolor consectetur enim incididunt id dolore amet commodo aliquip. Est incididunt aliquip labore ut minim eu eu elit sunt aliqua anim cillum aliqua minim. Fugiat laboris duis irure cillum aliquip aliquip.",
	"Proident aliquip aliquip commodo ut irure tempor non sint reprehenderit. Laboris excepteur eiusmod laboris sint aute qui velit minim. Deserunt reprehenderit eiusmod voluptate et cillum elit ad est. Sit ut esse veniam fugiat pariatur velit laborum ad irure. Eu ipsum pariatur duis non voluptate. Magna proident tempor aliqua excepteur commodo cupidatat laboris sint ex.",
	"Quis fugiat in sit exercitation pariatur. Anim ut aliquip commodo adipisicing incididunt eu proident in anim dolor qui velit aliquip. Occaecat enim elit ea id occaecat tempor minim minim.",
	"Pariatur id officia dolore ex. Incididunt in enim dolore laborum cupidatat proident minim excepteur cupidatat ullamco amet enim. Sunt labore deserunt minim pariatur irure nisi esse elit eiusmod eiusmod consectetur sit nisi in. Qui ullamco do nostrud quis cillum deserunt officia laborum Lorem velit amet esse exercitation esse. Velit labore et cillum tempor enim.",
	"Fugiat voluptate ex occaecat minim laboris occaecat officia ea do nostrud laborum consectetur eu. Veniam adipisicing deserunt ut eiusmod in proident id ea ad. Mollit occaecat irure excepteur voluptate do aliqua velit magna. Consectetur aute sit consectetur magna adipisicing mollit labore voluptate ullamco dolore. Culpa labore elit deserunt labore officia anim aliqua labore sint.",
	"Magna in sint culpa voluptate nostrud anim et. Commodo non occaecat sunt nostrud fugiat nulla Lorem. Aute elit culpa excepteur qui id. Voluptate velit elit irure eiusmod officia in eu ipsum.",
	"Cupidatat veniam tempor nisi consectetur nostrud dolore do nulla tempor do. Duis officia ad fugiat magna sint amet occaecat enim voluptate duis aliqua occaecat dolor. Cillum labore excepteur nostrud aliquip magna tempor nisi. Excepteur anim proident amet sint commodo est exercitation Lorem magna sit duis aute. Sunt incididunt ea velit qui minim non ea deserunt aute aliquip. Ad minim pariatur sit aliquip proident ex qui sint anim sit consectetur in. Et aliquip elit veniam quis dolore enim exercitation commodo aliquip eu.",
}

local function TestFrame()
	local frame, scrollFrame = lib:GetScrollableFrame()
	frame:SetTitle("Test Frame")

	local tabs = scrollFrame:New("Group")
	tabs:SetSpacing(0, 0)
	tabs:SetLayout("tabflow")
	tabs:SetFullWidth(true)
	tabs:SetTitle("Tab Group")

	for i = 1, 30 do
		local button = tabs:New("Button")
		button:SetAutoWidth(true)
		button:SetText("Tab " .. i)
	end

	local labels = lib:GetCollapsibleGroup(scrollFrame, true)
	labels:SetSpacing(10, 10)
	labels:SetFullWidth(true)
	labels:SetTitle("Labels")

	for k, v in pairs({ "TOP", "TOPLEFT", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM" }) do
		local label = labels:New("Label")
		label:SetFullWidth(true)
		label:SetText(v .. ": " .. ipsum[k])

		local icon = fastrandom(1, 13)
		while usedIcons[icon] do
			icon = fastrandom(1, 13)
		end
		usedIcons[icon] = true
		label:SetAtlas(icons[icon], v)
	end

	local buttons = lib:GetCollapsibleGroup(scrollFrame)
	buttons:SetFullWidth(true)
	buttons:SetTitle("Buttons")

	local simpleGroup = lib:GetSimpleGroup(scrollFrame)
	simpleGroup:SetFullWidth(true)

	local checkNum = 6

	for i = 1, 10 do
		local button = buttons:New("Button")
		button:SetText("Button " .. i)
		button:RegisterCallback("OnClick", function()
			local label = simpleGroup:New("Label")
			label:SetFullWidth(true)
			label:SetText("Simple group label " .. checkNum)
			label:SetAtlas("common-icon-redx", "LEFT", 11)

			label:SetInteractive(function()
				label:Release()
				-- if #simpleGroup.children == 0 then
				-- 	simpleGroup:Release()
				-- end
				scrollFrame:DoLayoutDeferred()
			end)

			checkNum = checkNum + 1
			scrollFrame:DoLayoutDeferred()
		end)
		if i > 2 then
			local r, g, b = fastrandom(), fastrandom(), fastrandom()
			if i > 6 then
				button:SetTheme({
					Disabled = { texture = { color = { r, g, b, 0.25 } }, border = { color = { r, g, b, 0.25 } } },
					Highlight = {
						texture = { color = { 0, 0, 0, 0.25 } },
						border = { color = { 1, 1, 1, 1 } },
						text = { color = { 1, 1, 1, 1 } },
					},
					Normal = {
						texture = { color = { r, g, b, 0.25 } },
						border = { color = { r, g, b, 0.25 } },
						text = { color = { r, g, b, 1 } },
					},
					Pushed = {
						texture = { color = { r, g, b, 0.25 } },
						border = { color = { r, g, b, 0.25 } },
						text = { color = { r, g, b, 1 } },
					},
				})
			else
				button:SetTheme({
					Normal = { text = { color = { r, g, b, 1 } } },
					Pushed = { border = { color = { r, g, b, 1 } }, text = { color = { r, g, b, 1 } } },
				})
			end
		end
	end

	-- Not necessary to show these off since you can see them with the CheckGroup
	-- local checkButtons = lib:GetSimpleGroup(widgets)
	-- checkButtons:SetFullWidth(true)
	-- checkButtons:SetTitle("Check Buttons")

	-- for i = 1, 10 do
	-- 	local button = checkButtons:New("CheckButton")
	-- 	button:SetText("Check button " .. i)
	-- end

	for i = 1, 5 do
		local label = simpleGroup:New("Label")
		label:SetFullWidth(true)
		label:SetText("Simple group label " .. i)
		label:SetAtlas("common-icon-redx", "LEFT", 11)

		label:SetInteractive(function()
			label:Release()
			-- if #simpleGroup.children == 0 then
			-- 	simpleGroup:Release()
			-- end
			scrollFrame:DoLayoutDeferred()
		end)
	end

	local tex = scrollFrame:New("Texture")
	tex:SetAtlas("Mobile-MechanicIcon-Lethal")
	tex:SetVertexColor(1, 0, 0, 1)
	
	local options = {}
	for i = 1, 5 do
		tinsert(options, {
			label = "Check option " .. i,
			disabled = fastrandom(1, 2) == 1,
			checked = fastrandom(1, 2) == 1,
		})
	end

	local checkGroup = scrollFrame:New("CheckGroup")
	checkGroup:SetFullWidth(true)
	checkGroup:SetTitle("Select multiple options:")


	-- local multiCheckGroup, multiChecks = lib:GetCheckGroup(scrollFrame, {
	-- 	title = "Select multiple options:",
	-- 	multiSelect = true,
	-- 	options = options,
	-- })
	-- multiCheckGroup:SetFullWidth(true)

	-- local checkGroup, checks = lib:GetCheckGroup(scrollFrame, {
	-- 	title = "Select one option:",
	-- 	checkStyle = "radio",
	-- 	options = options,
	-- })
	-- checkGroup:SetFullWidth(true)
	frame:DoLayout()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	TestFrame()
end)
