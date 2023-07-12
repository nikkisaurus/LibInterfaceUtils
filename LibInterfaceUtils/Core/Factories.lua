local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

function lib:GetScrollableFrame()
	local frame = self:New("Frame")
	frame:SetLayout("fill")
	local scrollFrame = frame:New("ScrollFrame")
	scrollFrame:SetPadding(0, 0, 0, 0)

	return frame, scrollFrame
end

function lib:GetCollapsibleGroup(parent, collapse)
	local group = (parent or self):New("Group")
	group:SetTitlebarBackdrop(addon.defaultBackdrop)
	group:SetTitlebarBackdropColor(unpack(addon.colors.elvTransparent))
	group:SetTitlebarBackdropBorderColor(unpack(addon.colors.black))
	group:SetCollapsible(true)
	group:SetCollapsed(collapse)

	return group
end

function lib:GetSimpleGroup(parent)
	local group = (parent or self):New("Group")
	group:SetPadding(0, 0, 0, 0)
	group:SetContentBackdrop()

	return group
end

function lib:GetCheckGroup(parent, config)
	local group
	if config.title then
		group = (parent or self):New("Group")
		group:SetTitle(config.title)
	else
		group = self:GetSimpleGroup(parent)
	end

	local options = {}
	if addon.isTable(config.options) then
		for i, option in ipairs(config.options) do
			local check = group:New("CheckButton")
			check:SetCheckStyle(config.checkStyle)
			check:SetText(option.label)

			-- todo enable callback
			if option.disabled then
				check:Disable()
			else
				check:Enable()
			end

			check:RegisterCallback("OnClick", function()
				if check:GetChecked() and not config.multiSelect then
					for _, option in ipairs(options) do
						if option ~= check and option:GetChecked() then
							option:SetChecked()
						end
					end
				end
			end)

			if config.multiSelect then
				-- todo trigger callback... maybe add a "force"
				check:SetChecked(option.checked)
			end
			options[i] = check
		end
	else
		print(
			WrapTextInColorCode(
				("[%s] Warning: Missing config.options{} for :GetCheckGroup(). You will need to create your own options and handle the callbacks to implement unique selection."):format(
					addonName
				),
				"ffffd100"
			)
		)
	end

	return group, options
end
