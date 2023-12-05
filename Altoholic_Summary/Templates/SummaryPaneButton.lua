local addonName = "Altoholic"
local addon = _G[addonName]

local function EmptyFunc()
end

addon:Controller("AltoholicUI.SummaryPaneButton", {
	SetColumnData = function(frame, character, column)
		-- Set basic properties
		frame:SetWidth(column.Width)
		frame.Text:SetWidth(column.Width)
		frame.Text:SetJustifyH(column.JustifyH)
		frame.Text:SetText(column.GetText(character))
		frame:Show()

		-- Set Scripts
		frame:SetScript("OnEnter", column.OnEnter or EmptyFunc)
		frame:SetScript("OnClick", column.OnClick or EmptyFunc)
	end,
	SetColumnTotal = function(frame, line, column)
		-- Set basic properties
		frame:SetWidth(column.Width)
		frame.Text:SetWidth(column.Width)
		
		if column.TotalJustifyH then
			frame.Text:SetJustifyH(column.TotalJustifyH)
		else
			frame.Text:SetJustifyH(column.JustifyH)
		end

		-- if column.GetTotal ~= EmptyFunc then
		if type(column.GetTotal) == "function" then
			frame.Text:SetText(column.GetTotal(line))
			frame:Show()
		else
			frame:Hide()
		end

		-- Set Scripts
		frame:SetScript("OnEnter", EmptyFunc)
		frame:SetScript("OnClick", EmptyFunc)
	end,
})
