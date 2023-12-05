local addonName = "Altoholic"
local addon = _G[addonName]

addon:Controller("AltoholicUI.ToggleButton", {
	Toggle = function(frame)
		if not frame.isCollapsed then
			frame.isCollapsed = true
			frame:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		else
			frame.isCollapsed = nil
			frame:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
		end
	end,
})
