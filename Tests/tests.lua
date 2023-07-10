local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

local function TestFrame()
	local frame = lib:New("Frame")
	frame:RegisterCallback("OnRelease", function()
		print("Bye")
	end)
	-- frame:SetLayout("fill")

	-- local nestMe = frame:New("Group")
	-- nestMe:SetFullWidth(true)
	-- nestMe:SetAutoHeight(false)
	-- nestMe:SetBackdrop()

	-- local group = nestMe:New("Group")
	local group = frame:New("Group")
	-- group:SetLayout("fill")
	group:SetFullWidth(true)
	group:SetTitle("Nest Container")
	-- group:RegisterCallback("OnSizeChanged", function()
	-- 	print("Hijacking")
	-- end)

	local nestedGroup = group:New("Group")
	nestedGroup:SetLayout("flow")
	nestedGroup:SetTitle("Test Buttons")
	-- group:SetFullHeight(true)

	local button = nestedGroup:New("Button")
	button:SetText("Click Me!")
	button:Disable()
	button:SetFullWidth(true)

	local button1 = nestedGroup:New("Button")
	button1:SetText("Click Me!")
	button1:Disable()

	local button2 = nestedGroup:New("Button")
	button2:SetText("Click Me!")
	button2:SetFillWidth(true)

	local button3 = nestedGroup:New("Button")
	button3:SetText("Click Me!")
	-- button3:SetFullHeight(true)
	button3:SetFullWidth(true)

	local button4 = nestedGroup:New("Button")
	button4:SetText("Click Me!")
	button4:SetFullWidth(true)
	-- button:SetText("Click Me! You'll never guess what I do.")
	-- button:RegisterCallback("OnClick", function()
	-- 	print("I pressed a button!")
	-- end)

	button1:RegisterCallback("OnEnter", function()
		print("Hijacking")
	end)

	-- button:UnregisterCallback("OnEnter")

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
