local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local SKILL_ANY = 0
local SKILL_ORANGE = 1
local SKILL_YELLOW = 2
local SKILL_GREEN = 3
local SKILL_GREY = 4

local RecipeColors = { 
	[SKILL_GREY] = colors.recipeGrey,
	[SKILL_GREEN] = colors.recipeGreen, 
	[SKILL_YELLOW] = colors.yellow, 
	[SKILL_ORANGE] = colors.recipeOrange, 
}
local RecipeColorNames = { 
	[SKILL_GREY] = L["COLOR_GREY"],
	[SKILL_GREEN] = L["COLOR_GREEN"], 
	[SKILL_YELLOW] = L["COLOR_YELLOW"], 
	[SKILL_ORANGE] = L["COLOR_ORANGE"], 
}

local currentProfession
local mainCategory
local currentColor = SKILL_ANY
local currentSlots = ALL_INVENTORY_SLOTS
local currentSearch = ""

-- *** Utility functions ***
local function IsEnchanting(profession)
	return (profession == GetSpellInfo(7411))
end

local function SetStatus(character, professionName, mainCategory, numRecipes)
	local profession = DataStore:GetProfession(character, professionName)
	local allCategories = (mainCategory == 0)
	
	local text = ""
	
	if not allCategories then
		local categoryName = DataStore:GetRecipeCategoryInfo(profession, mainCategory)
		text = format("%s / %s", professionName, categoryName)
	else
		text = professionName		-- full list, just display "Tailoring"
	end

	local status = format("%s|r / %s (%d %s)", DataStore:GetColoredCharacterName(character), text, numRecipes, TRADESKILL_SERVICE_LEARN)
	AltoholicTabCharacters.Status:SetText(status)
end

local function RecipePassesColorFilter(color)
	-- the recipe is accounter for if we want any color, or if it matches a specific one
	return ((currentColor == SKILL_ANY) or (currentColor == color))
end

local function RecipePassesSlotFilter(itemID)
	if currentSlots == ALL_INVENTORY_SLOTS then return true end
	
	-- if recipeID then	-- on a data line, recipeID is numeric
		-- local itemID = DataStore:GetCraftResultItem(recipeID)
		if itemID then
			local _, _, _, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemID)
			
			if itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) or itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) then
				if itemEquipLoc and strlen(itemEquipLoc) > 0 then
					if currentSlots == itemEquipLoc then
						return true
					end
				end
			else	-- not a weapon or armor ? then test if it's a generic "Created item"
				if currentSlots == NONEQUIPSLOT then
					return true
				end
			end
		else		-- enchants, like socket bracer, might not have an item id, so hide the line
			return false
		end
	-- else
		-- if currentSlots ~= NONEQUIPSLOT then
			-- return false
		-- end
	-- end
end

local isSearchingEnchanting

local function RecipePassesSearchFilter(itemID)
	-- no search filter ? ok
	if currentSearch == "" then return true end
	
	local name = isSearchingEnchanting and GetSpellInfo(itemID) or GetItemInfo(itemID)
	
	if name and string.find(strlower(name), currentSearch, 1, true) then
		return true
	end
end

local function GetRecipeList(character, professionName, mainCategory)
	local list = {}
	
	local profession = DataStore:GetProfession(character, professionName)
	
	isSearchingEnchanting = IsEnchanting(professionName)

	DataStore:IterateRecipes(profession, mainCategory, function(color, itemID, index) 
		
		-- if RecipePassesColorFilter(color) and RecipePassesSlotFilter(recipeID) and RecipePassesSearchFilter(recipeID) then
		if RecipePassesColorFilter(color) and RecipePassesSlotFilter(itemID) and RecipePassesSearchFilter(itemID) then
			table.insert(list, index)
		end
		
	end)
	
	return list
end

addon:Controller("AltoholicUI.Recipes", {
	SetCurrentProfession = function(frame, prof) currentProfession = prof end,
	GetCurrentProfession = function(frame) return currentProfession end,
	SetMainCategory = function(frame, cat) mainCategory = cat end,
	GetMainCategory = function(frame) return mainCategory end,
	SetCurrentSlots = function(frame, slot) currentSlots = slot end,
	GetCurrentSlots = function(frame) return currentSlots end,
	SetCurrentColor = function(frame, color) currentColor = color end,
	GetCurrentColor = function(frame) return currentColor end,
	GetRecipeColorName = function(frame, index) return RecipeColors[index]..RecipeColorNames[index] end,

	Update = function(frame)
		local character = addon.Tabs.Characters:GetAltKey()
		local recipeList = GetRecipeList(character, currentProfession, mainCategory)
		
		local isEnchanting = IsEnchanting(currentProfession)
		
		SetStatus(character, currentProfession, mainCategory, #recipeList)
	
		local scrollFrame = frame.ScrollFrame
		local numRows = scrollFrame.numRows
		local offset = scrollFrame:GetOffset()

		for rowIndex = 1, numRows do
			local rowFrame = scrollFrame:GetRow(rowIndex)
			local line = rowIndex + offset
			
			if line <= #recipeList then	-- if the line is visible
				local color, itemID, icon = DataStore:GetRecipeInfo(character, currentProfession, recipeList[line])
				
				rowFrame:Update(itemID, RecipeColors[color], isEnchanting, icon)
				rowFrame:Show()
			else
				rowFrame:Hide()
			end
		end

		scrollFrame:Update(#recipeList)
		frame:Show()
	end,
	Link_OnClick = function(frame, button)
		if button ~= "LeftButton" then return end
		
		if addon.Tabs.Characters:GetRealm() ~= GetRealmName() then
			addon:Print(L["Cannot link another realm's tradeskill"])
			return
		end

		local character = addon.Tabs.Characters:GetAltKey()
		local profession = DataStore:GetProfession(character, currentProfession)
		local link = profession.FullLink

		if not link then
			addon:Print(L["Invalid tradeskill link"])
			return
		end
		
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			chat:Insert(format("%s: %s", addon.Tabs.Characters:GetAlt(), link))
		end
	end,
	OnSearchTextChanged = function(frame, self)
		currentSearch = self:GetText()
		frame:Update()
	end,
})
