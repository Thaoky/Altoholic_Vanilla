local addonName = "Altoholic"
local addon = _G[addonName]

addon:Controller("AltoholicUI.TabSummaryMenuItem", {
	Item_OnClick = function(frame)
		-- Hide all sort buttons when changing mode
		local parent = frame:GetParent()
		
		for _, child in ipairs( {parent.SortButtons:GetChildren()} ) do
			child.ascendingSort = nil
			child.Arrow:Hide()
			child:Hide()
		end

		-- update the highlight, unlock all, lock current
		local i = 1
		while parent["MenuItem"..i] do
			parent["MenuItem"..i]:UnlockHighlight()
			i = i + 1
		end
		frame:LockHighlight()
		
		addon.Summary:SetMode(frame:GetID())
		addon.Summary:Update()
	end,
})
