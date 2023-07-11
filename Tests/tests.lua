local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

local function TestFrame()
	local frame, scrollFrame = lib:GetScrollableFrame()
	frame:SetTitle("Test Frame")

	local widgets = scrollFrame:New("Group")
	widgets:SetFullWidth(true)
	widgets:SetTitle("Widgets")

	local labels = widgets:New("Group")
	labels:SetFullWidth(true)
	labels:SetTitle("Labels")

	for i = 1, 10 do
		local label = labels:New("Label")
		label:SetFullWidth(true)
		label:SetIcon(134400)
		label:SetText("This is a header label " .. i)

		local lorem = labels:New("Label")
		lorem:SetFullWidth(true)
		lorem:SetText(
			"Veniam anim veniam sint enim. Exercitation nulla enim mollit sit non veniam nulla amet ad laborum ullamco excepteur voluptate cupidatat. Id anim labore minim dolor quis ad deserunt nulla in. Id minim minim minim eiusmod in ullamco eu veniam amet est est."
		)
	end

	local buttons = widgets:New("Group")
	buttons:SetFullWidth(true)
	buttons:SetTitle("Buttons")

	for i = 1, 10 do
		local button = buttons:New("Button")
		button:SetText("Button " .. i)
	end

	frame:DoLayout()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	TestFrame()
end)
