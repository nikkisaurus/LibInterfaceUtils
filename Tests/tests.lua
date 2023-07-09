local lib = LibStub:GetLibrary("LibInterfaceUtils-1.0")
if not lib then return end

local function TestFrame()
	local frame = lib:New("Frame")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	TestFrame()
end)
