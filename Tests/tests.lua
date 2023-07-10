local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

local function TestFrame()
	local frame = lib:New("Frame")
	frame:RegisterCallback("OnRelease", function()
		print("Bye")
	end)

	local button = frame:New("Button")
	button:SetText("Click Me! You'll never guess what I do.")
	button:RegisterCallback("OnClick", function()
		print("I pressed a button!")
	end)

	local label = frame:New("Label")
	label:SetIcon(134400)
	label:SetText("Testing string size and whatnot TOPLEFT blah blah need this to be a little longer")
	label:SetFullWidth(true)
	label:SetInteractive(true)

	local label2 = frame:New("Label")
	label2:SetIcon(134400, nil, "TOPRIGHT")
	label2:SetText("Testing string size and whatnot TOPRIGHT")
	label2:SetInteractive(true, function()
		frame:ReleaseChild(label2)
	end)

	local label3 = frame:New("Label")
	label3:SetIcon(134400, nil, "BOTTOMLEFT")
	label3:SetText("Testing string size and whatnot BOTTOMLEFT")

	local label4 = frame:New("Label")
	label4:SetIcon(134400, nil, "BOTTOMRIGHT")
	label4:SetText("Testing string size and whatnot BOTTOMRIGHT")

	local label5 = frame:New("Label")
	label5:SetIcon(134400, nil, "LEFT")
	label5:SetText("Testing string size and whatnot LEFT")

	local label6 = frame:New("Label")
	label6:SetIcon(134400, nil, "RIGHT")
	label6:SetText("Testing string size and whatnot RIGHT")

	local label7 = frame:New("Label")
	label7:SetIcon(134400, nil, "TOP")
	label7:SetText("Testing string size and whatnot TOP")

	local label8 = frame:New("Label")
	label8:SetIcon(134400, nil, "BOTTOM")
	label8:SetText("Testing string size and whatnot BOTTOM")

	frame:DoLayout()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	TestFrame()
end)
