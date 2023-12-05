local addonName = "Altoholic"
local addon = _G[addonName]

local SPELLS_PER_PAGE = 12

local currentSchool
local currentPage

addon:Controller("AltoholicUI.SpellbookPanel", {
	Update = function(frame)
		local character = addon.Tabs.Characters:GetAltKey()
		AltoholicTabCharacters.Status:SetText(format("%s|r / %s / %s", DataStore:GetColoredCharacterName(character), SPELLBOOK, currentSchool))
		
		local itemName, itemButton

		local maxSpells = DataStore:GetNumSpells(character, currentSchool)
		local offset = (currentPage-1) * SPELLS_PER_PAGE
		local spellIndex = offset + 1
		
		local index = 1
		while index <= SPELLS_PER_PAGE do
			local spellID, rank = DataStore:GetSpellInfo(character, currentSchool, spellIndex)
			
			if spellID then
				frame["SpellIcon" .. index]:SetSpell(spellID, rank)
				frame["SpellIcon" .. index]:Show()
				index = index + 1
			end
			
			spellIndex = spellIndex + 1
		
			if spellIndex > maxSpells then
				break
			end
		end
		
		while index <= SPELLS_PER_PAGE do
			itemButton = frame["SpellIcon" .. index]
			itemButton:Hide()
			index = index + 1
		end
		
		frame:Show()
	end,
	GoToPreviousPage = function(frame)
		frame:SetPage(currentPage - 1)
	end,
	GoToNextPage = function(frame)
		frame:SetPage(currentPage + 1)
	end,
	SetPage = function(frame, pageNum)
		currentPage = pageNum
		
		local character = addon.Tabs.Characters:GetAltKey()

		-- fix minimum page number
		currentPage = (currentPage < 1) and 1 or currentPage
		
		if currentPage == 1 then
			frame.PrevPage:Disable()
		else
			frame.PrevPage:Enable()
		end
		
		local maxPages = 1

		if currentSchool then
			maxPages = ceil(DataStore:GetNumSpells(character, currentSchool) / SPELLS_PER_PAGE)
		end
		
		if maxPages == 0 then
			maxPages = 1
		end
		
		-- fix maximum page number
		currentPage = (currentPage > maxPages) and maxPages or currentPage
		
		if currentPage == maxPages then
			frame.NextPage:Disable()
		else
			frame.NextPage:Enable()
		end

		frame.PageNumber:SetText(format(PAGE_NUMBER, currentPage))	
		
		if currentSchool then frame:Update() end
	end,
	SetSchool = function(frame, school)
		currentSchool = school
		frame:SetPage(1)
	end,
	OnMouseWheel = function(frame, delta)
		if (delta > 0) then
			frame:GoToPreviousPage()
		else
			frame:GoToNextPage()
		end
	end,
})
