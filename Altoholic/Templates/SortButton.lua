local addonName = "Altoholic"
local addon = _G[addonName]

addon:Controller("AltoholicUI.SortButton", {
	OnBind = function(frame)
		frame.Arrow:Hide()
	end,
	DrawArrow = function(frame, ascending)
		local arrow = frame.Arrow
		
		if ascending then
			arrow:SetTexCoord(0, 0.5625, 1.0, 0)		-- arrow pointing up
		else
			arrow:SetTexCoord(0, 0.5625, 0, 1.0)		-- arrow pointing down
		end
		arrow:Show()
	end,
})
