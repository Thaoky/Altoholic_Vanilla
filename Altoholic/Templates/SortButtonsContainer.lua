local addonName = "Altoholic"
local addon = _G[addonName]

addon:Controller("AltoholicUI.SortButtonsContainer", {
	OnBind = function(frame)
		-- auto create the sort buttons, with the quantity passed as key
		for i = 1, frame.numButtons do
			local button = CreateFrame("Button", nil, frame, "AltoSortButtonTemplate")
			
			if i == 1 then
				button:SetPoint("TOPLEFT")
			else
				-- attach to previous frame
				button:SetPoint("LEFT", frame["Sort"..(i-1)], "RIGHT", 0, 0)
			end
			
			frame["Sort"..i] = button
		end
	end,
	SetButton = function(frame, id, title, width, func)
		local button = frame["Sort"..id]

		if not title then		-- no title ? hide the button
			button:Hide()
			return
		end
		
		button:SetText(title)
		button:SetWidth(width)
		button.func = func
		button:Show()	
	end,
})
