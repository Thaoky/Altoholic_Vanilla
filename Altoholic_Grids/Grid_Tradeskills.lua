local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local LCI = LibStub("LibCraftInfo-1.0")
local LCL = LibStub("LibCraftLevels-1.0")

local ICON_QUESTIONMARK = "Interface\\RaidFrame\\ReadyCheck-Waiting"

local xPacks = {
	EXPANSION_NAME0,	-- "Classic"
}

local OPTION_XPACK = "UI.Tabs.Grids.Tradeskills.CurrentXPack"
local OPTION_TRADESKILL = "UI.Tabs.Grids.Tradeskills.CurrentTradeSkill"

local currentDDMText
local currentItemID
local currentList
local dropDownFrame

local function OnXPackChange(self)
	local currentXPack = self.value
	
	addon:SetOption(OPTION_XPACK, currentXPack)

	AltoholicTabGrids:SetViewDDMText(xPacks[currentXPack])
	AltoholicTabGrids:Update()
end

local function OnTradeSkillChange(self)
	dropDownFrame:Close()
	addon:SetOption(OPTION_TRADESKILL, self.value)
	AltoholicTabGrids:Update()
end

local function DropDown_Initialize(frame, level)

	if not level then return end

	local tradeskills = addon.TradeSkills.spellIDs
	local currentXPack = addon:GetOption(OPTION_XPACK)
	local currentTradeSkill = addon:GetOption(OPTION_TRADESKILL)
	
	if level == 1 then
		frame:AddCategoryButton(PRIMARY_SKILLS, 1, level)
		frame:AddCategoryButton(SECONDARY_SKILLS, 2, level)
		frame:AddTitle()
		
		-- XPack Selection
		for i, xpack in pairs(xPacks) do
			frame:AddButton(xpack, i, OnXPackChange, nil, (currentXPack == i))
		end
		frame:AddCloseMenu()
	
	elseif level == 2 then
		local spell, icon, _
		local firstSecondarySkill = addon.TradeSkills.firstSecondarySkillIndex
	
		if frame:GetCurrentOpenMenuValue() == 1 then				-- Primary professions
			for i = 1, (firstSecondarySkill - 1) do
				spell, _, icon = GetSpellInfo(tradeskills[i])
				frame:AddButton(spell, i, OnTradeSkillChange, icon, (currentTradeSkill == i), level)
			end
		
		elseif frame:GetCurrentOpenMenuValue() == 2 then		-- Secondary professions
			for i = firstSecondarySkill, #tradeskills do
				spell, _, icon = GetSpellInfo(tradeskills[i])
				frame:AddButton(spell, i, OnTradeSkillChange, icon, (currentTradeSkill == i), level)
			end
		end
	end
end

local function SortByCraftLevel(a, b)
	local o1, y1, g1, gr1 = LCL:GetCraftLevels(a)	-- get color level : orange, yellow, green, grey
	local o2, y2, g2, gr2 = LCL:GetCraftLevels(b)
	
	-- try the most common cases = by orange, then by yellow, then by green
	if o1 and o2 and o1 ~= o2 then
		return o1 < o2
	elseif y1 and y2 and y1 ~= y2 then
		return y1 < y2
	elseif g1 and g2 and g1 ~= g2 then
		return g1 < g2
	end	
	
	-- if none has worked, we have a craft with no value for one or multiple colors, so basically skip the missing ones
	-- ex: if no orange value, sort on yellow .. to be able to do so, start from the grey, then green, then yellow
	gr1 = gr1 or 0
	gr2 = gr2 or 0
	
	if gr1 ~= gr2 then
		return gr1 < gr2
	end
	
	g1 = g1 or gr1
	g2 = g2 or gr2
	
	if g1 ~= g2 then
		return g1 < g2
	end
	
	y1 = y1 or g1
	y2 = y2 or g2
	
	if y1 ~= y2 then
		return y1 < y2
	end
	
	-- if nothing worked, sort on spell id
	return a < b
end

local callbacks = {
	OnUpdate = function() 
			local tradeskills = addon.TradeSkills.spellIDs
			local currentXPack = addon:GetOption(OPTION_XPACK)
			local currentTradeSkill = addon:GetOption(OPTION_TRADESKILL)
			
			currentList = LCI:GetProfessionCraftList(tradeskills[currentTradeSkill], currentXPack)
			if not currentList.isSorted then
				table.sort(currentList, SortByCraftLevel)
				currentList.isSorted = true
			end
			
			local prof = GetSpellInfo(tradeskills[currentTradeSkill])
			AltoholicTabGrids:SetStatus(format("%s%s", colors.green, prof))
		end,
	OnUpdateComplete = function() end,
	GetSize = function() return #currentList end,
	RowSetup = function(self, rowFrame, dataRowID)
			local spellID = currentList[dataRowID]
			local itemName = GetSpellInfo(spellID)
			local text
			
			if not itemName then
				-- DEFAULT_CHAT_FRAME:AddMessage("spell : " .. spellID)
				return
			end
			
			currentItemID = DataStore:GetCraftResultItem(spellID)
			local orange, yellow, green, grey = LCL:GetCraftLevels(spellID)
			
			if orange then
				text = format("%s\n%s %s %s %s",
					colors.white..itemName, 
					-- colors.white..spellID, 
					colors.recipeOrange..orange, 
					colors.yellow..yellow, 
					colors.recipeGreen..green, 
					colors.recipeGrey..grey )
			end
			
			text = text or format("%s", colors.white..itemName)

			rowFrame.Name.Text:SetText(text)
			rowFrame.Name.Text:SetJustifyH("LEFT")
		end,
	RowOnEnter = function()	end,
	RowOnLeave = function() end,
	ColumnSetup = function(self, button, dataRowID, character)
			button.Name:SetFontObject("GameFontNormalSmall")
			button.Name:SetJustifyH("CENTER")
			button.Name:SetPoint("BOTTOMRIGHT", 5, 0)
			button.Background:SetDesaturated(false)
			button.Background:SetTexCoord(0, 1, 0, 1)
			
			button.Background:SetTexture(GetItemIcon(currentItemID) or ICON_QUESTIONMARK)

			local text = icons.notReady
			local vc = 0.25	-- vertex color
			local tradeskills = addon.TradeSkills.spellIDs
			local profession = DataStore:GetProfession(character, GetSpellInfo(tradeskills[addon:GetOption(OPTION_TRADESKILL)]))			

			if #profession.Crafts ~= 0 then
				-- do not enable this yet .. working fine, but better if more filtering allowed. ==> filtering on rarity
				
				-- local _, _, itemRarity, itemLevel = GetItemInfo(currentItemID)
				-- if itemRarity and itemRarity >= 2 then
					-- local r, g, b = GetItemQualityColor(itemRarity)
					-- button.IconBorder:SetVertexColor(r, g, b, 0.5)
					-- button.IconBorder:Show()
				-- end
				
				if DataStore:IsCraftKnown(profession, currentList[dataRowID]) then
					vc = 1.0
					text = icons.ready
				else
					vc = 0.4
				end
			end

			button.Background:SetVertexColor(vc, vc, vc)
			button.Name:SetText(text)
			button.id = currentItemID
		end,
	OnEnter = function(self) 
			self.link = nil
			addon:Item_OnEnter(self) 
		end,
	OnClick = function(self, button)
			self.link = nil
			addon:Item_OnClick(self, button)
		end,
	OnLeave = function(self)
			GameTooltip:Hide() 
		end,
		
	InitViewDDM = function(frame, title)
			dropDownFrame = frame
			frame:Show()
			title:Show()
			
			frame:SetMenuWidth(100) 
			frame:SetButtonWidth(20)
			frame:SetText(xPacks[addon:GetOption(OPTION_XPACK)])
			frame:Initialize(DropDown_Initialize, "MENU_NO_BORDERS")
		end,
}

AltoholicTabGrids:RegisterGrid(4, callbacks)
