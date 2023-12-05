local addonName = "Altoholic"
local addon = _G[addonName]
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

addon:Controller("AltoholicUI.RecipeRow", {
	Update = function(frame, itemID, color, isEnchanting, icon)
		
		-- ** set the crafted item **
		-- local craftedItemID, maxMade = DataStore:GetCraftResultItem(itemID)
		local maxMade = 1
		local itemName, itemLink, itemRarity
		
		if itemID then
			if isEnchanting then
				frame.CraftedItem:SetIcon(icon)
				frame.CraftedItem.spellID = itemID
				frame.CraftedItem.itemID = nil
				
				itemName = GetSpellInfo(itemID)	-- itemID is actually a spellID for enchanting
				itemRarity = 1
			else
				frame.CraftedItem:SetIcon(GetItemIcon(itemID))
				frame.CraftedItem.itemID = itemID
				frame.CraftedItem.spellID = nil
				itemName, itemLink, itemRarity = GetItemInfo(itemID)
			end
			
			
			frame.CraftedItem.Icon:SetVertexColor(1, 1, 1)
			if itemRarity then
				frame.CraftedItem:SetRarity(itemRarity)
			end
			
			if maxMade > 1 then
				frame.CraftedItem.Count:SetText(maxMade)
				frame.CraftedItem.Count:Show()
			else
				frame.CraftedItem.Count:Hide()
			end
			frame.CraftedItem:Show()
		else
			frame.CraftedItem:Hide()
		end
		
		-- ** set the recipe text **
		local recipeText
		
		if itemName then
			local _, _, _, hexColor = GetItemQualityColor(itemRarity)
			recipeText = format("|c%s%s", hexColor, itemName)
		end
	
		frame.RecipeLink.Text:SetText(recipeText)
		
		-- ** set the reagents **
		if isEnchanting then
			-- enchanting reagents are stored as : ["spell:7421"] = "6217,1|10940,1|10938,1"
			-- so convert the itemID which truly is a spellID
			itemID = format("spell:%d", itemID)		
		end
			
		local reagents = DataStore:GetCraftReagents(itemID)		-- reagents = "2996,2|2318,1|2320,1"
		local index = 1
		
		if reagents then
			for reagent in reagents:gmatch("([^|]+)") do
				local reagentIcon = frame["Reagent" .. index]
				local reagentID, reagentCount = strsplit(",", reagent)
				reagentID = tonumber(reagentID)
				
				if reagentID then
					reagentCount = tonumber(reagentCount)
					
					reagentIcon.itemID = reagentID
					reagentIcon:SetIcon(GetItemIcon(reagentID))
					reagentIcon.Count:SetText(reagentCount)
					reagentIcon.Count:Show()
				
					reagentIcon:Show()
					index = index + 1
				else
					reagentIcon:Hide()
				end				
			end
		end
		
		-- hide unused reagent icons
		while index <= 8 do
			frame["Reagent" .. index]:Hide()
			index = index + 1
		end

		frame:Show()
	end,
	
	Link_OnEnter = function(frame)
		-- Only for enchanting
		local spellID = frame.CraftedItem.spellID
		if not spellID then return end
		
		local name = GetSpellInfo(spellID)
		local desc = GetSpellDescription(spellID)
		
		local tt = AltoTooltip
		
		tt:ClearLines()
		tt:SetOwner(frame, "ANCHOR_CURSOR")
		tt:AddLine(name, 1,1,1)
		tt:AddLine(desc, nil, nil, nil, 1)

		tt:Show()
		
	end,
})
