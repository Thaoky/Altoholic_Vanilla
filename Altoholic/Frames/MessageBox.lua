local addonName = ...
local addon = _G[addonName]

addon:Controller("AltoholicUI.MessageBox", {
	SetText = function(frame, text)
		frame.Text:SetText(text)
	end,
	SetHandler = function(frame, func, arg1, arg2)
		frame.onClickCallback = func
		frame.arg1 = arg1
		frame.arg2 = arg2
	end,
	Button_OnClick = function(frame, button)
		-- until I have time to check all the places where msgbox is used, keep "button" as 1 for yes, and nil for no
		-- also, change the handler to work with ...

		if frame.onClickCallback then
			frame:onClickCallback(button, frame.arg1, frame.arg2)
			frame.onClickCallback = nil		-- prevent subsequent calls from coming back here
			frame.arg1 = nil
			frame.arg2 = nil
		else
			addon:Print("MessageBox Handler not defined")
		end
		
		frame:Hide()
		frame:SetHeight(100)
		frame.Text:SetHeight(28)	
	end,
})
