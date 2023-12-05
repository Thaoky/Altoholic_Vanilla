local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MODE_SUMMARY = 1
local MODE_BAGS = 2
local MODE_SKILLS = 3
local MODE_ACTIVITY = 4
local MODE_MISCELLANEOUS = 5

local SKILL_CAP = 300

local INFO_REALM_LINE = 0
local INFO_CHARACTER_LINE = 1
local INFO_TOTAL_LINE = 2
local THIS_ACCOUNT = "Default"
local MAX_LOGOUT_TIMESTAMP = 5000000000

local VIEW_BAGS = 1
local VIEW_QUESTS = 2
local VIEW_TALENTS = 3
local VIEW_AUCTIONS = 4
local VIEW_BIDS = 5
local VIEW_MAILS = 6
local VIEW_COMPANIONS = 7
local VIEW_SPELLS = 8
local VIEW_PROFESSION = 9

local TEXTURE_FONT = "|T%s:%s:%s|t"

addon.Summary = {}

local ns = addon.Summary		-- ns = namespace

-- *** Utility functions ***
local function GetRestedXP(character)
	local rate, savedXP, savedRate, rateEarnedResting, xpEarnedResting, maxXP, isFullyRested, timeUntilFullyRested = DataStore:GetRestXPRate(character)

	-- display in 100% or 150% mode ?
	local coeff = 1
	if addon:GetOption("UI.Tabs.Summary.ShowRestXP150pc") then
		coeff = 1.5
	end
	
	-- coefficient remains the same for pandaren, only the max should be increased
	local maxCoeff = coeff
	if DataStore:GetCharacterRace(character) == "Pandaren" then 
		maxCoeff = maxCoeff * 2 -- show as "200%" or "300%" for pandaren, who can accumulate 3 levels instead of 1.5
	end
	
	rate = rate * maxCoeff
	
	-- second return value = the actual percentage of rest xp, as a numeric value (1 to 100, not 150)
	local color = colors.green
	if rate >= (100 * maxCoeff) then 
		rate = 100 * maxCoeff
	else
		if rate < (30 * coeff) then
			color = colors.red
		elseif rate < (60 * coeff) then
			color = colors.yellow
		end
	end

	return format("%s%2.0f", color, rate).."%", rate, savedXP, savedRate * maxCoeff, rateEarnedResting * maxCoeff, xpEarnedResting, maxXP, isFullyRested, timeUntilFullyRested
end

local function FormatBagType(link, bagType)
	link = link or ""
	if bagType and strlen(bagType) > 0 then
		return format("%s %s(%s)", link, colors.yellow, bagType)
	end
	
	-- not bag type ? just return the link
	return link
end

local function FormatBagSlots(size, free)
	return format(L["NUM_SLOTS_AND_FREE"], colors.cyan, size, colors.white, colors.green, free, colors.white)
end

local function FormatAiL(level)
	return format("%s%s %s%s", colors.yellow, L["COLUMN_ILEVEL_TITLE_SHORT"], colors.green, level)
end

local function FormatTexture(texture)
	-- all textures are formatted to be 18x18 on this panel
	return format("|T%s:18:18|t", texture)
end

local function FormatGreyIfEmpty(text, color)
	color = color or colors.white
		
	if not text or text == "" then
		text = NONE
		color = colors.grey
	end
	
	return format("%s%s", color, text)
end

local skillColors = { colors.recipeGrey, colors.red, colors.orange, colors.yellow, colors.green }

local function GetSkillRankColor(rank, skillCap)
	rank = rank or 0
	skillCap = skillCap or SKILL_CAP
	return skillColors[ floor(rank / (skillCap/4)) + 1 ]
end

local function TradeskillHeader_OnEnter(frame, tooltip)
	tooltip:AddLine(" ")
	tooltip:AddLine(format("%s%s|r %s %s", colors.recipeGrey, L["COLOR_GREY"], L["up to"], (floor(SKILL_CAP*0.25)-1)),1,1,1)
	tooltip:AddLine(format("%s%s|r %s %s", colors.red, RED_GEM, L["up to"], (floor(SKILL_CAP*0.50)-1)),1,1,1)
	tooltip:AddLine(format("%s%s|r %s %s", colors.orange, L["COLOR_ORANGE"], L["up to"], (floor(SKILL_CAP*0.75)-1)),1,1,1)
	tooltip:AddLine(format("%s%s|r %s %s", colors.yellow, YELLOW_GEM, L["up to"], (SKILL_CAP-1)),1,1,1)
	tooltip:AddLine(format("%s%s|r %s %s %s", colors.green, L["COLOR_GREEN"], L["at"], SKILL_CAP, L["and above"]),1,1,1)
end

local function Tradeskill_OnEnter(frame, skillName, showRecipeStats)
	local character = frame:GetParent().character
	if not DataStore:GetModuleLastUpdateByKey("DataStore_Crafts", character) then return end
	
	local curRank, maxRank = DataStore:GetProfessionInfo(DataStore:GetProfession(character, skillName))
	local profession = DataStore:GetProfession(character, skillName)

	local tt = AltoTooltip
	
	tt:ClearLines()
	tt:SetOwner(frame, "ANCHOR_RIGHT")
	tt:AddLine(skillName,1,1,1)
	tt:AddLine(format("%s%s/%s", GetSkillRankColor(curRank), curRank, maxRank),1,1,1)
	
	if showRecipeStats then	-- for primary skills + cooking & first aid
		-- if DataStore:GetProfessionSpellID(skillName) ~= 2366 and skillName ~= GetSpellInfo(8613) then		-- no display for herbalism & skinning
			tt:AddLine(" ")
			
			if not profession then
				tt:AddLine(L["No data"])
				tt:Show()
				return
			end

			local numCategories = DataStore:GetNumRecipeCategories(profession)
			
			if numCategories == 0 then
				tt:AddLine(format("%s: 0 %s", L["No data"], TRADESKILL_SERVICE_LEARN),1,1,1)
			else
				local orange, yellow, green, grey = DataStore:GetNumRecipesByColor(profession)
				
				tt:AddLine(" ")
				tt:AddLine(orange+yellow+green+grey .. " " .. TRADESKILL_SERVICE_LEARN,1,1,1)
				tt:AddLine(format("%s%d %s%s|r / %s%d %s%s|r / %s%d %s%s",
					colors.white, green, colors.recipeGreen, L["COLOR_GREEN"],
					colors.white, yellow, colors.yellow, L["COLOR_YELLOW"],
					colors.white, orange, colors.recipeOrange, L["COLOR_ORANGE"]))
			end
		-- end
	end

	local suggestion = addon:GetSuggestion(skillName, curRank)
	if suggestion then
		tt:AddLine(" ")
		tt:AddLine(format("%s: ", L["Suggestion"]),1,1,1)
		tt:AddLine(format("%s%s", colors.teal, suggestion),1,1,1)
	end
	
	-- parse profession cooldowns
	if profession then
		DataStore:ClearExpiredCooldowns(profession)
		local numCooldows = DataStore:GetNumActiveCooldowns(profession)
		
		if numCooldows == 0 then
			tt:AddLine(" ")
			tt:AddLine(L["All cooldowns are up"],1,1,1)
		else
			tt:AddLine(" ")
			for i = 1, numCooldows do
				local craftName, expiresIn = DataStore:GetCraftCooldownInfo(profession, i)
				tt:AddDoubleLine(craftName, addon:GetTimeString(expiresIn))
			end
		end
	end
	
	tt:Show()
end

local function Tradeskill_OnClick(frame, skillName)
	local character = frame:GetParent().character
	if not skillName or not DataStore:GetModuleLastUpdateByKey("DataStore_Crafts", character) then return end

	local profession = DataStore:GetProfession(character, skillName)
	if not profession or DataStore:GetNumRecipeCategories(profession) == 0 then		-- if profession hasn't been scanned (or scan failed), exit
		return
	end
	
	local charName, realm, account = strsplit(".", character)
	local chat = ChatEdit_GetLastActiveWindow()
	
	if chat:IsShown() and IsShiftKeyDown() and realm == GetRealmName() then
		-- if shift-click, then display the profession link and exit
		local link = profession.FullLink	
		if link and link:match("trade:") then
			chat:Insert(link);
		end
		return
	end

	addon.Tabs:OnClick("Characters")
	addon.Tabs.Characters:SetAltKey(character)
	addon.Tabs.Characters:MenuItem_OnClick(AltoholicTabCharacters.Characters, "LeftButton")
	addon.Tabs.Characters:SetCurrentProfession(skillName)
end

local function CurrencyHeader_OnEnter(frame, currencyID)
	local tt = AltoTooltip
	
	tt:ClearLines()
	tt:SetOwner(frame, "ANCHOR_BOTTOM")
	-- tt:AddLine(select(1, GetCurrencyInfo(currencyID)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	tt:SetHyperlink(GetCurrencyLink(currencyID,0))
	tt:Show()
end

local Characters = addon.Characters

local function SortView(columnName)
	addon:SetOption("UI.Tabs.Summary.CurrentColumn", columnName)
	addon.Summary:Update()
end

local function GetColorFromAIL(level)
	if (level < 600) then return colors.grey end
	if (level <= 615) then return colors.green end
	if (level <= 630) then return colors.rare end
	return colors.epic
end


-- ** Right-Click Menu **
local function ViewAltInfo(self, characterInfoLine)
	addon.Tabs:OnClick("Characters")
	addon.Tabs.Characters:SetAlt(Characters:GetInfo(characterInfoLine))
	addon.Tabs.Characters:ViewCharInfo(self.value)
end

local function DeleteAlt_MsgBox_Handler(self, button, characterInfoLine)
	if not button then return end
	
	local name, realm, account = Characters:GetInfo(characterInfoLine)
	
	DataStore:DeleteCharacter(name, realm, account)
	
	-- rebuild the main character table, and all the menus
	Characters:InvalidateView()
	addon.Summary:Update()
		
	addon:Print(format( L["Character %s successfully deleted"], name))
end

local function DeleteAlt(self, characterInfoLine)
	local name, realm, account = Characters:GetInfo(characterInfoLine)
	
	if (account == THIS_ACCOUNT) and	(realm == GetRealmName()) and (name == UnitName("player")) then
		addon:Print(L["Cannot delete current character"])
		return
	end
	
	AltoMessageBox:SetHandler(DeleteAlt_MsgBox_Handler, characterInfoLine)
	AltoMessageBox:SetText(format("%s?\n%s", L["Delete this Alt"], name))
	AltoMessageBox:Show()
end

local function UpdateRealm(self, characterInfoLine)
	local _, realm, account = Characters:GetInfo(characterInfoLine)
	
	AltoAccountSharing_AccNameEditBox:SetText(account)
	AltoAccountSharing_UseTarget:SetChecked(nil)
	AltoAccountSharing_UseName:SetChecked(1)
	
	local _, updatedWith = addon:GetLastAccountSharingInfo(realm, account)
	AltoAccountSharing_AccTargetEditBox:SetText(updatedWith)
	
	addon.Tabs.Summary:AccountSharingButton_OnClick()
end

local function DeleteRealm_MsgBox_Handler(self, button, characterInfoLine)
	if not button then return end

	local _, realm, account = Characters:GetInfo(characterInfoLine)
	DataStore:DeleteRealm(realm, account)

	-- if the realm being deleted was the current ..
	local tc = addon.Tabs.Characters
	if tc and tc:GetRealm() == realm and tc:GetAccount() == account then
		
		-- reset to this player
		local player = UnitName("player")
		local realmName = GetRealmName()
		addon.Tabs.Characters:SetAlt(player, realmName, THIS_ACCOUNT)
		addon.Containers:UpdateCache()
		tc:ViewCharInfo(VIEW_BAGS)
	end
	
	-- rebuild the main character table, and all the menus
	Characters:InvalidateView()
	addon.Summary:Update()
		
	addon:Print(format( L["Realm %s successfully deleted"], realm))
end

local function DeleteRealm(self, characterInfoLine)
	local _, realm, account = Characters:GetInfo(characterInfoLine)
		
	if (account == THIS_ACCOUNT) and	(realm == GetRealmName()) then
		addon:Print(L["Cannot delete current realm"])
		return
	end

	AltoMessageBox:SetHandler(DeleteRealm_MsgBox_Handler, characterInfoLine)
	AltoMessageBox:SetText(format("%s?\n%s", L["Delete this Realm"], realm))
	AltoMessageBox:Show()
end

local function NameRightClickMenu_Initialize(frame)
	local characterInfoLine = ns.CharInfoLine
	if not characterInfoLine then return end

	local lineType = Characters:GetLineType(characterInfoLine)
	if not lineType then return end

	if lineType == INFO_REALM_LINE then
		local _, realm, account = Characters:GetInfo(characterInfoLine)
		local _, updatedWith = addon:GetLastAccountSharingInfo(realm, account)
		
		if updatedWith then
			frame:AddButtonWithArgs(format("Update from %s", colors.green..updatedWith), nil, UpdateRealm, characterInfoLine)
		end
		frame:AddButtonWithArgs(L["Delete this Realm"], nil, DeleteRealm, characterInfoLine)
		return
	end

	frame:AddTitle(DataStore:GetColoredCharacterName(Characters:Get(characterInfoLine).key))
	frame:AddTitle()
	frame:AddButtonWithArgs(L["View bags"], VIEW_BAGS, ViewAltInfo, characterInfoLine)
	frame:AddButtonWithArgs(L["View mailbox"], VIEW_MAILS, ViewAltInfo, characterInfoLine)
	frame:AddButtonWithArgs(L["View quest log"], VIEW_QUESTS, ViewAltInfo, characterInfoLine)
	frame:AddButtonWithArgs(L["View auctions"], VIEW_AUCTIONS, ViewAltInfo, characterInfoLine)
	frame:AddButtonWithArgs(L["View bids"], VIEW_BIDS, ViewAltInfo, characterInfoLine)
	frame:AddButtonWithArgs(COMPANIONS, VIEW_COMPANIONS, ViewAltInfo, characterInfoLine)
	frame:AddButtonWithArgs(L["Delete this Alt"], nil, DeleteAlt, characterInfoLine)
	frame:AddCloseMenu()
end

local function Name_OnClick(frame, button)
	local line = frame:GetParent():GetID()
	if line == 0 then return end

	local lineType = Characters:GetLineType(line)
	if lineType == INFO_TOTAL_LINE then
		return
	end
	
	if button == "RightButton" then
		ns.CharInfoLine = line	-- line containing info about the alt on which action should be taken (delete, ..)
		
		local scrollFrame = frame:GetParent():GetParent().ScrollFrame
		local menu = scrollFrame:GetParent():GetParent().ContextualMenu
		local offset = scrollFrame:GetOffset()
		
		menu:Initialize(NameRightClickMenu_Initialize, "LIST")
		menu:Close()
		menu:Toggle(frame, frame:GetWidth() - 20, 10)
			
		return
	elseif button == "LeftButton" and lineType == INFO_CHARACTER_LINE then
		addon.Tabs:OnClick("Characters")
		
		local tc = addon.Tabs.Characters
		tc:SetAlt(Characters:GetInfo(line))
		tc:MenuItem_OnClick(AltoholicTabCharacters.Characters, "LeftButton")
		addon.Containers:UpdateCache()
		tc:ViewCharInfo(VIEW_BAGS)
	end
end


-- *** Specific sort functions ***
local function GetCharacterLevel(self, character)
	local level = DataStore:GetCharacterLevel(character) or 0
	local rate = DataStore:GetXPRate(character) or 0

	return level + (rate / 100)
end

-- *** Column definitions ***
local columns = {}

-- ** Account Summary **
columns["Name"] = {
	-- Header
	headerWidth = 100,
	headerLabel = NAME,
	headerOnClick = function() SortView("Name") end,
	headerSort = DataStore.GetCharacterName,
	
	-- Content
	Width = 150,
	JustifyH = "LEFT",
	GetText = function(character) 
			local name = DataStore:GetColoredCharacterName(character)
			local class = DataStore:GetCharacterClass(character)
			local icon = icons[DataStore:GetCharacterFaction(character)] or "Interface/Icons/INV_BannerPVP_03"

			return format("%s %s (%s)", format(TEXTURE_FONT, icon, 18, 18), name, class)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character then return end
			
			local tt = AltoTooltip
		
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), DataStore:GetColoredCharacterFaction(character))
			tt:AddLine(format("%s %s%s |r%s %s", L["Level"], 
				colors.green, DataStore:GetCharacterLevel(character), DataStore:GetCharacterRace(character), DataStore:GetCharacterClass(character)),1,1,1)

			local zone, subZone = DataStore:GetLocation(character)
			tt:AddLine(format("%s: %s%s |r(%s%s|r)", L["Zone"], colors.gold, zone, colors.gold, subZone),1,1,1)
			
			local guildName = DataStore:GetGuildInfo(character)
			if guildName then
				tt:AddLine(format("%s: %s%s", GUILD, colors.green, guildName),1,1,1)
			end

			local suggestion = addon:GetSuggestion("Leveling", DataStore:GetCharacterLevel(character))
			if suggestion then
				tt:AddLine(" ")
				tt:AddLine(L["Suggested leveling zone: "],1,1,1)
				tt:AddLine(colors.teal .. suggestion,1,1,1)
			end

			-- parse saved instances
			local bLineBreak = true

			local dungeons = DataStore:GetSavedInstances(character)
			if dungeons then
				for key, _ in pairs(dungeons) do
					local hasExpired, expiresIn = DataStore:HasSavedInstanceExpired(character, key)
					
					if hasExpired then
						DataStore:DeleteSavedInstance(character, key)
					else
						if bLineBreak then
							tt:AddLine(" ")		-- add a line break only once
							bLineBreak = nil
						end
						
						local instanceName, instanceID = strsplit("|", key)
						tt:AddDoubleLine(format("%s (%sID: %s|r)", colors.gold..instanceName, colors.white, colors.green..instanceID), addon:GetTimeString(expiresIn))
					end
				end
			end

			tt:AddLine(" ")
			tt:AddLine(format("%s%s", colors.green, L["Right-Click for options"]))
			tt:Show()
		end,
	OnClick = Name_OnClick,
	GetTotal = function(line) return format("  %s", L["Totals"]) end,
}

columns["Level"] = {
	-- Header
	headerWidth = 60,
	headerLabel = L["COLUMN_LEVEL_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_LEVEL_TITLE"],
	tooltipSubTitle = L["COLUMN_LEVEL_SUBTITLE"],
	headerOnClick = function() SortView("Level") end,
	headerSort = GetCharacterLevel,
	
	-- Content
	Width = 50,
	JustifyH = "CENTER",
	GetText = function(character) 
		local level = DataStore:GetCharacterLevel(character)
		if level ~= MAX_PLAYER_LEVEL and addon:GetOption("UI.Tabs.Summary.ShowLevelDecimals") then
			local rate = DataStore:GetXPRate(character)
			level = format("%.1f", level + (rate/100))		-- show level as 98.4 if not level cap
		end
	
		return format("%s%s", colors.green, level)
	end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Inventory", character) then
				return
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), L["COLUMN_LEVEL_TITLE"])
			tt:AddLine(format("%s %s%s |r%s %s", L["Level"], 
				colors.green, DataStore:GetCharacterLevel(character), DataStore:GetCharacterRace(character), DataStore:GetCharacterClass(character)),1,1,1)
			
			tt:AddLine(" ")
			tt:AddLine(format("%s %s%s%s/%s%s%s (%s%s%%%s)", EXPERIENCE_COLON,
				colors.green, DataStore:GetXP(character), colors.white,
				colors.green, DataStore:GetXPMax(character), colors.white,
				colors.green, DataStore:GetXPRate(character), colors.white),1,1,1)
			tt:Show()
		end,
	OnClick = function(frame, button)
			addon:ToggleOption(nil, "UI.Tabs.Summary.ShowLevelDecimals")
			addon.Summary:Update()
		end,
	GetTotal = function(line) return Characters:GetField(line, "level") end,
}

columns["RestXP"] = {
	-- Header
	headerWidth = 65,
	headerLabel = L["COLUMN_RESTXP_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_RESTXP_TITLE"],
	tooltipSubTitle = L["COLUMN_RESTXP_SUBTITLE"],
	headerOnEnter = function(frame, tooltip)
			tooltip:AddLine(" ")
			tooltip:AddLine(L["COLUMN_RESTXP_DETAIL_1"], 1,1,1)
			tooltip:AddLine(L["COLUMN_RESTXP_DETAIL_2"], 1,1,1)
			tooltip:AddLine(L["COLUMN_RESTXP_DETAIL_3"], 1,1,1)
			tooltip:AddLine(" ")
			tooltip:AddLine(format(L["COLUMN_RESTXP_DETAIL_4"], 100, 100))
			tooltip:AddLine(format(L["COLUMN_RESTXP_DETAIL_4"], 150, 150))
		end,
	headerOnClick = function() SortView("RestXP") end,
	headerSort = DataStore.GetRestXPRate,
	
	-- Content
	Width = 65,
	JustifyH = "CENTER",
	GetText = function(character) 
		if DataStore:GetCharacterLevel(character) == MAX_PLAYER_LEVEL then
			return colors.white .. "0%"	-- show 0% at max level
		end

		return GetRestedXP(character)
	end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Inventory", character) then
				return
			end

			local restXP = DataStore:GetRestXP(character)
			-- if not restXP or restXP == 0 then return end
			if not restXP or DataStore:GetCharacterLevel(character) == MAX_PLAYER_LEVEL then return end

			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddLine(DataStore:GetColoredCharacterName(character),1,1,1)
			tt:AddLine(" ")
			
			local rate, _, savedXP, savedRate, rateEarnedResting, xpEarnedResting, maxXP, isFullyRested, timeUntilFullyRested = GetRestedXP(character)
			
			tt:AddLine(format("%s: %s%d", L["Maximum Rest XP"], colors.green, maxXP),1,1,1)
			tt:AddLine(format("%s: %s%d %s(%2.1f%%)", L["Saved Rest XP"], colors.green, savedXP, colors.yellow, savedRate),1,1,1)
			tt:AddLine(format("%s: %s%d %s(%2.1f%%)", L["XP earned while resting"], colors.green, xpEarnedResting, colors.yellow, rateEarnedResting),1,1,1)
			tt:AddLine(" ")
			if isFullyRested then
				tt:AddLine(format("%s", L["Fully rested"]),1,1,1)
			else
				tt:AddLine(format("%s%s: %s", colors.white, L["Fully rested in"], addon:GetTimeString(timeUntilFullyRested)))
			end
			
			tt:Show()
		end,
	OnClick = function(frame, button)
			addon:ToggleOption(nil, "UI.Tabs.Summary.ShowRestXP150pc")
			addon.Summary:Update()
		end,	
}

columns["Money"] = {
	-- Header
	headerWidth = 115,
	headerLabel = format("%s  %s", FormatTexture("Interface\\Icons\\inv_misc_coin_01"), L["COLUMN_MONEY_TITLE_SHORT"]),
	tooltipTitle = L["COLUMN_MONEY_TITLE"],
	tooltipSubTitle = L["COLUMN_MONEY_SUBTITLE_"..random(5)],
	headerOnClick = function() SortView("Money") end,
	headerSort = DataStore.GetMoney,
	
	-- Content
	Width = 110,
	JustifyH = "RIGHT",
	GetText = function(character) 
		return addon:GetMoneyString(DataStore:GetMoney(character))
	end,
	GetTotal = function(line) return addon:GetMoneyString(Characters:GetField(line, "money"), colors.white) end,
}

columns["Played"] = {
	-- Header
	headerWidth = 100,
	headerLabel = L["COLUMN_PLAYED_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_PLAYED_TITLE"],
	tooltipSubTitle = L["COLUMN_PLAYED_SUBTITLE"],
	headerOnClick = function() SortView("Played") end,
	headerSort = DataStore.GetPlayTime,
	
	-- Content
	Width = 100,
	JustifyH = "RIGHT",
	GetText = function(character) 
		return addon:GetTimeString(DataStore:GetPlayTime(character))
	end,
	OnClick = function(frame, button)
			DataStore:ToggleOption(nil, "DataStore_Characters", "HideRealPlayTime")
			addon.Summary:Update()
		end,
	GetTotal = function(line) return Characters:GetField(line, "played") end,
}

columns["AiL"] = {
	-- Header
	headerWidth = 55,
	headerLabel = L["COLUMN_ILEVEL_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_ILEVEL_TITLE"],
	tooltipSubTitle = L["COLUMN_ILEVEL_SUBTITLE"],
	headerOnClick = function() SortView("AiL") end,
	headerSort = DataStore.GetAverageItemLevel,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character) 
		local AiL = DataStore:GetAverageItemLevel(character) or 0
		if addon:GetOption("UI.Tabs.Summary.ShowILevelDecimals") then
			return format("%s%.1f", colors.yellow, AiL)
		else
			return format("%s%d", colors.yellow, AiL)
		end
	end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Inventory", character) then
				return
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddLine(DataStore:GetColoredCharacterName(character),1,1,1)
			tt:AddLine(format("%s%s: %s%.1f",
				colors.white, L["COLUMN_ILEVEL_TITLE"],
				colors.green, DataStore:GetAverageItemLevel(character)
			),1,1,1)

			addon:AiLTooltip()
			tt:Show()
		end,
	OnClick = function(frame, button)
			addon:ToggleOption(nil, "UI.Tabs.Summary.ShowILevelDecimals")
			addon.Summary:Update()
		end,
	GetTotal = function(line) return colors.white..format("%.1f", Characters:GetField(line, "realmAiL")) end,
}

columns["LastOnline"] = {
	-- Header
	headerWidth = 90,
	headerLabel = L["COLUMN_LASTONLINE_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_LASTONLINE_TITLE"],
	tooltipSubTitle = L["COLUMN_LASTONLINE_SUBTITLE"],
	headerOnClick = function() SortView("LastOnline") end,
	headerSort = DataStore.GetLastLogout,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character) 
		local account, realm, player = strsplit(".", character)
		
		if (player == UnitName("player")) and (realm == GetRealmName()) and (account == "Default") then
			return format("%s%s", colors.green, GUILD_ONLINE_LABEL)
		end
		
		local lastLogout = DataStore:GetLastLogout(character)
		if lastLogout == MAX_LOGOUT_TIMESTAMP then
			return UNKNOWN
		end
		
		return format("%s%s", colors.white, addon:FormatDelay(lastLogout))
	end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Inventory", character) then
				return
			end
			
			local text
			local account, realm, player = strsplit(".", character)
			
			if (player == UnitName("player")) and (realm == GetRealmName()) and (account == "Default") then
				-- current player ? show ONLINE
				text = format("%s%s", colors.green, GUILD_ONLINE_LABEL)
			else
				-- other player, show real time since last online
				local lastLogout = DataStore:GetLastLogout(character)
				
				if lastLogout == MAX_LOGOUT_TIMESTAMP then
					text = UNKNOWN
				else
					text = format("%s: %s", LASTONLINE, SecondsToTime(time() - lastLogout))
				end
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddLine(DataStore:GetColoredCharacterName(character),1,1,1)
			tt:AddLine(" ")
			-- then - now = x seconds
			tt:AddLine(text,1,1,1)
			tt:Show()
		end,
}


-- ** Bag Usage **
columns["BagSlots"] = {
	-- Header
	headerWidth = 100,
	headerLabel = format("%s  %s", FormatTexture("Interface\\Icons\\inv_misc_bag_08"), L["COLUMN_BAGS_TITLE_SHORT"]),
	tooltipTitle = L["COLUMN_BAGS_TITLE"],
	tooltipSubTitle = L["COLUMN_BAGS_SUBTITLE_"..random(2)],
	headerOnClick = function() SortView("BagSlots") end,
	headerSort = DataStore.GetNumBagSlots,
	
	-- Content
	Width = 100,
	JustifyH = "LEFT",
	GetText = function(character)
				if not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
					return UNKNOWN
				end
				
				return format("%s/%s|r/%s|r/%s|r/%s",
					DataStore:GetContainerSize(character, 0),
					DataStore:GetColoredContainerSize(character, 1),
					DataStore:GetColoredContainerSize(character, 2),
					DataStore:GetColoredContainerSize(character, 3),
					DataStore:GetColoredContainerSize(character, 4)
				)
			end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), L["COLUMN_BAGS_TITLE"])
			tt:AddLine(" ")
			
			local _, link, size, free, bagType = DataStore:GetContainerInfo(character, 0)
			tt:AddDoubleLine(format("%s[%s]", colors.white, BACKPACK_TOOLTIP), FormatBagSlots(size, free))
			
			for i = 1, 4 do
				_, link, size, free, bagType = DataStore:GetContainerInfo(character, i)

				if size ~= 0 then
					tt:AddDoubleLine(FormatBagType(link, bagType), FormatBagSlots(size, free))
				end
			end
			tt:Show()
		end,
	GetTotal = function(line) return format("%s%s |r%s", colors.white, Characters:GetField(line, "bagSlots"), L["slots"]) end,
	TotalJustifyH = "CENTER",
}

columns["FreeBagSlots"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_FREEBAGSLOTS_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_FREEBAGSLOTS_TITLE"],
	tooltipSubTitle = L["COLUMN_FREEBAGSLOTS_SUBTITLE"],
	headerOnClick = function() SortView("FreeBagSlots") end,
	headerSort = DataStore.GetNumFreeBagSlots,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			if not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return 0
			end
			
			local numSlots = DataStore:GetNumBagSlots(character)
			local numFree = DataStore:GetNumFreeBagSlots(character)
			local color = ((numFree / numSlots) <= 0.1) and colors.red or colors.green
			
			return format("%s%s|r/%s%s", color, numFree, colors.cyan, numSlots)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), L["COLUMN_FREEBAGSLOTS_TITLE"])
			tt:AddLine(" ")
			tt:AddLine(FormatBagSlots(DataStore:GetNumBagSlots(character), DataStore:GetNumFreeBagSlots(character)))
			tt:Show()
		end,
	GetTotal = function(line) return format("%s%s", colors.white, Characters:GetField(line, "freeBagSlots")) end,
}

columns["BankSlots"] = {
	-- Header
	headerWidth = 160,
	headerLabel = format("%s  %s", FormatTexture("Interface\\Icons\\inv_box_01"), L["COLUMN_BANK_TITLE_SHORT"]),
	-- headerLabel = L["COLUMN_BANK_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_BANK_TITLE"],
	tooltipSubTitle = L["COLUMN_BANK_SUBTITLE_"..random(2)],
	headerOnClick = function() SortView("BankSlots") end,
	headerSort = DataStore.GetNumBankSlots,
	
	-- Content
	Width = 160,
	JustifyH = "LEFT",
	GetText = function(character)
			if not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return UNKNOWN
			end

			if DataStore:GetNumBankSlots(character) == 0 then
				return L["Bank not visited yet"]
			end
			
			return format("%s/%s|r/%s|r/%s|r/%s|r/%s|r/%s|r/%s",
				DataStore:GetContainerSize(character, 100),
				DataStore:GetColoredContainerSize(character, 5),
				DataStore:GetColoredContainerSize(character, 6),
				DataStore:GetColoredContainerSize(character, 7),
				DataStore:GetColoredContainerSize(character, 8),
				DataStore:GetColoredContainerSize(character, 9),
				DataStore:GetColoredContainerSize(character, 10),
				DataStore:GetColoredContainerSize(character, 11)
			)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), L["COLUMN_BANK_TITLE"])
			tt:AddLine(" ")
			
			if DataStore:GetNumBankSlots(character) == 0 then
				tt:AddLine(L["Bank not visited yet"],1,1,1)
				tt:Show()
				return
			end
			
			local _, link, size, free, bagType = DataStore:GetContainerInfo(character, 100)
			tt:AddDoubleLine(format("%s[%s]", colors.white, L["Bank"]), FormatBagSlots(size, free))
				
			for i = 5, 11 do
				_, link, size, free, bagType = DataStore:GetContainerInfo(character, i)
				
				if size ~= 0 then
					tt:AddDoubleLine(FormatBagType(link, bagType), FormatBagSlots(size, free))
				end
			end
			tt:Show()
		end,
	GetTotal = function(line) return format("%s%s |r%s", colors.white, Characters:GetField(line, "bankSlots"), L["slots"]) end,
	TotalJustifyH = "CENTER",
}

columns["FreeBankSlots"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_FREEBANKLOTS_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_FREEBANKLOTS_TITLE"],
	tooltipSubTitle = L["COLUMN_FREEBANKLOTS_SUBTITLE"],
	headerOnClick = function() SortView("FreeBankSlots") end,
	headerSort = DataStore.GetNumFreeBankSlots,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			if not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return 0
			end
			
			local numSlots = DataStore:GetNumBankSlots(character)
			if numSlots == 0 then		-- Bank not visited yet
				return 0			
			end
			
			local numFree = DataStore:GetNumFreeBankSlots(character)
			local color = ((numFree / numSlots) <= 0.1) and colors.red or colors.green
			
			return format("%s%s|r/%s%s", color, numFree, colors.cyan, numSlots)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Containers", character) then
				return
			end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), L["COLUMN_FREEBANKLOTS_TITLE"])
			tt:AddLine(" ")
			tt:AddLine(FormatBagSlots(DataStore:GetNumBankSlots(character), DataStore:GetNumFreeBankSlots(character)))
			tt:Show()
		end,
	GetTotal = function(line) return format("%s%s", colors.white, Characters:GetField(line, "freeBankSlots")) end,
}

-- ** Skills **
columns["Prof1"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_PROFESSION_1_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_PROFESSION_1_TITLE"],
	tooltipSubTitle = nil,
	headerOnEnter = TradeskillHeader_OnEnter,
	headerOnClick = function() SortView("Prof1") end,
	headerSort = DataStore.GetProfession1,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			local rank, _, _, name = DataStore:GetProfession1(character)
			local spellID = DataStore:GetProfessionSpellID(name)
			local icon = spellID and format(TEXTURE_FONT, addon:GetSpellIcon(spellID), 18, 18) .. " " or ""
			
			return format("%s%s%s", icon, GetSkillRankColor(rank), rank)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			local _, _, _, skillName = DataStore:GetProfession1(character)
			Tradeskill_OnEnter(frame, skillName, true)
		end,
	OnClick = function(frame, button)
			local character = frame:GetParent().character
			local _, _, _, skillName = DataStore:GetProfession1(character)
			Tradeskill_OnClick(frame, skillName)
		end,
}

columns["Prof2"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_PROFESSION_2_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_PROFESSION_2_TITLE"],
	tooltipSubTitle = nil,
	headerOnEnter = TradeskillHeader_OnEnter,
	headerOnClick = function() SortView("Prof2") end,
	headerSort = DataStore.GetProfession2,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			local rank, _, _, name = DataStore:GetProfession2(character)
			local spellID = DataStore:GetProfessionSpellID(name)
			local icon = spellID and format(TEXTURE_FONT, addon:GetSpellIcon(spellID), 18, 18) .. " " or ""
			
			return format("%s%s%s", icon, GetSkillRankColor(rank), rank)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			local _, _, _, skillName = DataStore:GetProfession2(character)
			Tradeskill_OnEnter(frame, skillName, true)
		end,
	OnClick = function(frame, button)
			local character = frame:GetParent().character
			local _, _, _, skillName = DataStore:GetProfession2(character)
			Tradeskill_OnClick(frame, skillName)
		end,
}

columns["ProfCooking"] = {
	-- Header
	headerWidth = 60,
	headerLabel = "   " .. format(TEXTURE_FONT, addon:GetSpellIcon(2550), 18, 18),
	tooltipTitle = GetSpellInfo(2550),
	tooltipSubTitle = nil,
	headerOnEnter = TradeskillHeader_OnEnter,
	headerOnClick = function() SortView("ProfCooking") end,
	headerSort = DataStore.GetCookingRank,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character)
			local rank = DataStore:GetCookingRank(character)
			return format("%s%s", GetSkillRankColor(rank), rank)
		end,
	OnEnter = function(frame)
			Tradeskill_OnEnter(frame, GetSpellInfo(2550), true)
		end,
	OnClick = function(frame, button)
			Tradeskill_OnClick(frame, GetSpellInfo(2550))
		end,
}

columns["ProfFirstAid"] = {
	-- Header
	headerWidth = 60,
	headerLabel = "   " .. format(TEXTURE_FONT, addon:GetSpellIcon(3273), 18, 18),
	tooltipTitle = GetSpellInfo(3273),
	tooltipSubTitle = nil,
	headerOnEnter = TradeskillHeader_OnEnter,
	headerOnClick = function() SortView("ProfFirstAid") end,
	headerSort = DataStore.GetFirstAidRank,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character)
			local rank = DataStore:GetFirstAidRank(character)
			return format("%s%s", GetSkillRankColor(rank), rank)
		end,
	OnEnter = function(frame)
			Tradeskill_OnEnter(frame, GetSpellInfo(3273), true)
		end,
	OnClick = function(frame, button)
			Tradeskill_OnClick(frame, GetSpellInfo(3273))
		end,
}

columns["ProfFishing"] = {
	-- Header
	headerWidth = 60,
	headerLabel = "   " .. format(TEXTURE_FONT, addon:GetSpellIcon(7732), 18, 18),
	tooltipTitle = GetSpellInfo(7732),
	tooltipSubTitle = nil,
	headerOnEnter = TradeskillHeader_OnEnter,
	headerOnClick = function() SortView("ProfFishing") end,
	headerSort = DataStore.GetFishingRank,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character)
			local rank = DataStore:GetFishingRank(character)
			return format("%s%s", GetSkillRankColor(rank), rank)
		end,
	OnEnter = function(frame)
			Tradeskill_OnEnter(frame, GetSpellInfo(7732), true)
		end,
}

-- ** Activity **
columns["Mails"] = {
	-- Header
	headerWidth = 60,
	headerLabel = L["COLUMN_MAILS_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_MAILS_TITLE"],
	tooltipSubTitle = L["COLUMN_MAILS_SUBTITLE"],
	headerOnEnter = function(frame, tooltip)
			tooltip:AddLine(" ")
			tooltip:AddLine(L["COLUMN_MAILS_DETAIL_1"], 1,1,1)
			tooltip:AddLine(L["COLUMN_MAILS_DETAIL_2"], 1,1,1)
		end,
	headerOnClick = function() SortView("Mails") end,
	headerSort = DataStore.GetNumMails,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character)
			local color = colors.grey
			local num = DataStore:GetNumMails(character) or 0

			if num ~= 0 then
				color = colors.green		-- green by default, red if at least one mail is about to expire
							
				local threshold = DataStore:GetOption("DataStore_Mails", "MailWarningThreshold")
				if DataStore:GetNumExpiredMails(character, threshold) > 0 then
					color = colors.red
				end
			end
			return format("%s%s", color, num)
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character then return end
			
			local num = DataStore:GetNumMails(character)
			if not num or num == 0 then return end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), L["COLUMN_MAILS_TITLE"])
			tt:AddLine(" ")
			tt:AddLine(format("%sMails found: %s%d", colors.white, colors.green, num))
			
			local numReturned, numDeleted, numExpired = 0, 0, 0
			local closestReturn
			local closestDelete
			
			for index = 1, num do
				local _, _, _, _, _, isReturned = DataStore:GetMailInfo(character, index)
				local _, seconds = DataStore:GetMailExpiry(character, index)
				
				if seconds < 0 then		-- mail has already expired
					if isReturned then	-- .. and it was a returned mail
						numExpired = numExpired + 1
					end
				else
					if isReturned then
						numDeleted = numDeleted + 1
						
						if not closestDelete then
							closestDelete = seconds
						else
							if seconds < closestDelete then
								closestDelete = seconds
							end
						end
					else
						numReturned = numReturned + 1
						
						if not closestReturn then
							closestReturn = seconds
						else
							if seconds < closestReturn then
								closestReturn = seconds
							end
						end
					end
				end
			end

			tt:AddLine(" ")
			tt:AddLine(format("%s%d %swill be returned upon expiry", colors.green, numReturned, colors.white))
			if closestReturn then
				tt:AddLine(format("%sClosest return in %s%s", colors.white, colors.green, SecondsToTime(closestReturn)))
			end
			
			if numDeleted > 0 then
				tt:AddLine(" ")
				tt:AddLine(format("%s%d %swill be %sdeleted%s upon expiry", colors.green, numDeleted, colors.white, colors.red, colors.white))
				if closestDelete then
					tt:AddLine(format("%sClosest deletion in %s%s", colors.white, colors.green, SecondsToTime(closestDelete)))
				end
			end
			
			if numExpired > 0 then
				tt:AddLine(" ")
				tt:AddLine(format("%s%d %shave expired !", colors.red, numExpired, colors.white))
			end
			
			tt:Show()
		end,
	OnClick = function(frame, button)
			local character = frame:GetParent().character
			if not character then return end
	
			local num = DataStore:GetNumMails(character)
			if not num or num == 0 then return end

			addon.Tabs:OnClick("Characters")
			addon.Tabs.Characters:SetAltKey(character)
			addon.Tabs.Characters:MenuItem_OnClick(AltoholicTabCharacters.Characters, "LeftButton")
			addon.Tabs.Characters:ViewCharInfo(VIEW_MAILS)
		end,
}

columns["LastMailCheck"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_MAILBOX_VISITED_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_MAILBOX_VISITED_TITLE"],
	tooltipSubTitle = L["COLUMN_MAILBOX_VISITED_SUBTITLE"],
	headerOnClick = function() SortView("LastMailCheck") end,
	headerSort = DataStore.GetMailboxLastVisit,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			return format("%s%s", colors.white, addon:FormatDelay(DataStore:GetMailboxLastVisit(character)))
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Mails", character) then
				return
			end
			
			local lastVisit = DataStore:GetMailboxLastVisit(character)
			if not lastVisit then return end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), MINIMAP_TRACKING_MAILBOX)
			tt:AddLine(" ")
			tt:AddLine(format("%s: %s", L["COLUMN_MAILBOX_VISITED_TITLE_SHORT"], SecondsToTime(time() - lastVisit)),1,1,1)
			tt:Show()
		end,
}

columns["Auctions"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_AUCTIONS_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_AUCTIONS_TITLE"],
	tooltipSubTitle = L["COLUMN_AUCTIONS_SUBTITLE"],
	headerOnClick = function() SortView("Auctions") end,
	headerSort = DataStore.GetNumAuctions,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			local num = DataStore:GetNumAuctions(character) or 0
			return format("%s%s", ((num == 0) and colors.grey or colors.green), num)
		end,
	OnClick = function(frame)
			local character = frame:GetParent().character
			if not character then return end
			
			local num = DataStore:GetNumAuctions(character)
			if not num or num == 0 then return end

			addon.Tabs:OnClick("Characters")
			addon.Tabs.Characters:SetAltKey(character)
			addon.Tabs.Characters:MenuItem_OnClick(AltoholicTabCharacters.Characters, "LeftButton")
			addon.Tabs.Characters:ViewCharInfo(VIEW_AUCTIONS)
		end,
}

columns["Bids"] = {
	-- Header
	headerWidth = 60,
	headerLabel = L["COLUMN_BIDS_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_BIDS_TITLE"],
	tooltipSubTitle = L["COLUMN_BIDS_SUBTITLE"],
	headerOnClick = function() SortView("Bids") end,
	headerSort = DataStore.GetNumBids,
	
	-- Content
	Width = 60,
	JustifyH = "CENTER",
	GetText = function(character)
			local num = DataStore:GetNumBids(character) or 0
			return format("%s%s", ((num == 0) and colors.grey or colors.green), num)
		end,
	OnClick = function(frame)
			local character = frame:GetParent().character
			if not character then return end
			
			local num = DataStore:GetNumBids(character)
			if not num or num == 0 then return end

			addon.Tabs:OnClick("Characters")
			addon.Tabs.Characters:SetAltKey(character)
			addon.Tabs.Characters:MenuItem_OnClick(AltoholicTabCharacters.Characters, "LeftButton")
			addon.Tabs.Characters:ViewCharInfo(VIEW_BIDS)
		end,
}

columns["AHLastVisit"] = {
	-- Header
	headerWidth = 70,
	headerLabel = L["COLUMN_AUCTIONHOUSE_VISITED_TITLE_SHORT"],
	tooltipTitle = L["COLUMN_AUCTIONHOUSE_VISITED_TITLE"],
	tooltipSubTitle = L["COLUMN_AUCTIONHOUSE_VISITED_SUBTITLE"],
	headerOnClick = function() SortView("AHLastVisit") end,
	headerSort = DataStore.GetAuctionHouseLastVisit,
	
	-- Content
	Width = 70,
	JustifyH = "CENTER",
	GetText = function(character)
			return format("%s%s", colors.white, addon:FormatDelay(DataStore:GetAuctionHouseLastVisit(character)))
		end,
	OnEnter = function(frame)
			local character = frame:GetParent().character
			if not character or not DataStore:GetModuleLastUpdateByKey("DataStore_Mails", character) then
				return
			end
			
			local lastVisit = DataStore:GetAuctionHouseLastVisit(character)
			if not lastVisit then return end
			
			local tt = AltoTooltip
			tt:ClearLines()
			tt:SetOwner(frame, "ANCHOR_RIGHT")
			tt:AddDoubleLine(DataStore:GetColoredCharacterName(character), BUTTON_LAG_AUCTIONHOUSE)
			tt:AddLine(" ")
			tt:AddLine(format("%s: %s", L["Visited"], SecondsToTime(time() - lastVisit)),1,1,1)
			tt:Show()
		end,
}

-- ** Miscellaneous **
columns["GuildName"] = {
	-- Header
	headerWidth = 120,
	headerLabel = format("%s  %s", FormatTexture("Interface\\Icons\\inv_shirt_guildtabard_01"), GUILD),
	tooltipTitle = L["COLUMN_GUILD_TITLE"],
	tooltipSubTitle = L["COLUMN_GUILD_SUBTITLE"],
	headerOnClick = function() SortView("GuildName") end,
	headerSort = GetGuildOrRank,
	
	-- Content
	Width = 120,
	JustifyH = "CENTER",
	GetText = function(character) 
		local guildName, guildRank = DataStore:GetGuildInfo(character)
		
		if addon:GetOption("UI.Tabs.Summary.ShowGuildRank") then
			return FormatGreyIfEmpty(guildRank)
		else
			return FormatGreyIfEmpty(guildName, colors.green)
		end
	end,
	
	OnClick = function(frame, button)
			addon:ToggleOption(nil, "UI.Tabs.Summary.ShowGuildRank")
			addon.Summary:Update()
		end,	
}

columns["Hearthstone"] = {
	-- Header
	headerWidth = 120,
	headerLabel = format("%s  %s",	FormatTexture("Interface\\Icons\\inv_misc_rune_01"), L["COLUMN_HEARTHSTONE_TITLE"]),
	tooltipTitle = L["COLUMN_HEARTHSTONE_TITLE"],
	tooltipSubTitle = L["COLUMN_HEARTHSTONE_SUBTITLE"],
	headerOnClick = function() SortView("Hearthstone") end,
	headerSort = DataStore.GetBindLocation,
	
	-- Content
	Width = 120,
	JustifyH = "CENTER",
	GetText = function(character) 
		return FormatGreyIfEmpty(DataStore:GetBindLocation(character))
	end,
}

columns["ClassAndSpec"] = {
	-- Header
	headerWidth = 160,
	headerLabel = format("%s   %s / %s", FormatTexture("Interface\\Addons\\Altoholic_Summary\\Textures\\Spell_Nature_NatureGuardian"), CLASS, SPECIALIZATION),
	tooltipTitle = format("%s / %s", CLASS, SPECIALIZATION),
	tooltipSubTitle = L["COLUMN_CLASS_SUBTITLE"],
	headerOnClick = function() SortView("ClassAndSpec") end,
	headerSort = DataStore.GetCharacterClass,
	
	-- Content
	Width = 160,
	JustifyH = "CENTER",
	GetText = function(character)
	
		local class = DataStore:GetCharacterClass(character)
		local spec = DataStore:GetMainSpecialization(character)
		local color = DataStore:GetCharacterClassColor(character)
		
		return format("%s%s |r/ %s", color, class, FormatGreyIfEmpty(spec, color))
	end,
	OnClick = function(frame, button)
			local character = frame:GetParent().character
			if not character then return end

			-- Exit if no specialization yet
			local spec = DataStore:GetMainSpecialization(character)
			if not spec or spec == "" or spec == NONE then return end

			addon.Tabs:OnClick("Characters")
			addon.Tabs.Characters:SetAltKey(character)
			addon.Tabs.Characters:MenuItem_OnClick(AltoholicTabCharacters.Characters, "LeftButton")
			addon.Tabs.Characters:ViewCharInfo(VIEW_TALENTS)
		end,	
}


local function ColumnHeader_OnEnter(frame)
	local column = frame.column
	if not frame.column then return end		-- invalid data ? exit
	
	local tooltip = AltoTooltip
	
	tooltip:ClearLines()
	tooltip:SetOwner(frame, "ANCHOR_BOTTOM")
	
	-- Add the tooltip title
	if column.tooltipTitle then
		tooltip:AddLine(column.tooltipTitle)
	end

	-- Add the tooltip subtitle in cyan
	if column.tooltipSubTitle then
		tooltip:AddLine(column.tooltipSubTitle, 0, 1, 1)
	end

	-- Add the extra tooltip content, if any
	if column.headerOnEnter then
		column.headerOnEnter(frame, tooltip)
	end
	
	tooltip:Show()
end

local modes = {
	[MODE_SUMMARY] = { "Name", "Level", "RestXP", "Money", "Played", "AiL", "LastOnline" },
	[MODE_BAGS] = { "Name", "Level", "BagSlots", "FreeBagSlots", "BankSlots", "FreeBankSlots" },
	[MODE_SKILLS] = { "Name", "Level", "Prof1", "Prof2", "ProfCooking", "ProfFirstAid", "ProfFishing" },
	[MODE_ACTIVITY] = { "Name", "Level", "Mails", "LastMailCheck", "Auctions", "Bids", "AHLastVisit" },
	[MODE_MISCELLANEOUS] = { "Name", "Level", "GuildName", "Hearthstone", "ClassAndSpec" },
}

function ns:SetMode(mode)
	addon:SetOption("UI.Tabs.Summary.CurrentMode", mode)
	
	local parent = AltoholicTabSummary
	
	-- add the appropriate columns for this mode
	for i = 1, #modes[mode] do
		local columnName = modes[mode][i]
		local column = columns[columnName]
		
		parent.SortButtons:SetButton(i, column.headerLabel, column.headerWidth, column.headerOnClick)
		parent.SortButtons["Sort"..i].column = column
		parent.SortButtons["Sort"..i]:SetScript("OnEnter", ColumnHeader_OnEnter)
		parent.SortButtons["Sort"..i]:SetScript("OnLeave", function() AltoTooltip:Hide() end)
	end
end

function ns:Update()
	local frame = AltoholicFrameSummary
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	local offset = scrollFrame:GetOffset()

	local isRealmShown
	local numVisibleRows = 0
	local numDisplayedRows = 0

	local sortOrder = addon:GetOption("UI.Tabs.Summary.SortAscending")
	local currentColumn = addon:GetOption("UI.Tabs.Summary.CurrentColumn")
	local currentModeIndex = addon:GetOption("UI.Tabs.Summary.CurrentMode")
	local currentMode = modes[currentModeIndex]
	
	-- rebuild and get the view, then sort it
	Characters:InvalidateView()
	local view = Characters:GetView()
	if columns[currentColumn] then	-- an old column name might still be in the DB.
		Characters:Sort(sortOrder, columns[currentColumn].headerSort)
	end

	-- attempt to restore the arrow to the right sort button
	local container = AltoholicTabSummary.SortButtons
	for i = 0, #currentMode do
		if currentMode[i] == currentColumn then
			container["Sort"..i]:DrawArrow(sortOrder)
		end
	end
	
	local rowIndex = 1
	local item
	
	for _, line in pairs(view) do
		local rowFrame = scrollFrame:GetRow(rowIndex)
		local lineType = Characters:GetLineType(line)
		
		if (offset > 0) or (numDisplayedRows >= numRows) then		-- if the line will not be visible
			if lineType == INFO_REALM_LINE then								-- then keep track of counters
				if not Characters:IsRealmCollapsed(line) then
					isRealmShown = true
				else
					isRealmShown = false
				end
				
				numVisibleRows = numVisibleRows + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			elseif isRealmShown then
				numVisibleRows = numVisibleRows + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			end
		else		-- line will be displayed
			if lineType == INFO_REALM_LINE then
				local _, realm, account = Characters:GetInfo(line)
				
				if not Characters:IsRealmCollapsed(line) then
					isRealmShown = true
				else
					isRealmShown = false
				end
				rowFrame:DrawRealmLine(line, realm, account, Name_OnClick)
			
				rowIndex = rowIndex + 1
				numVisibleRows = numVisibleRows + 1
				numDisplayedRows = numDisplayedRows + 1
			elseif isRealmShown then
				if (lineType == INFO_CHARACTER_LINE) then
					rowFrame:DrawCharacterLine(line, columns, currentMode)
				elseif (lineType == INFO_TOTAL_LINE) then
					rowFrame:DrawTotalLine(line, columns, currentMode)
				end

				rowIndex = rowIndex + 1
				numVisibleRows = numVisibleRows + 1
				numDisplayedRows = numDisplayedRows + 1
			end
		end
	end
	
	while rowIndex <= numRows do
		local rowFrame = scrollFrame:GetRow(rowIndex) 
		
		rowFrame:SetID(0)
		rowFrame:Hide()
		rowIndex = rowIndex + 1
	end

	scrollFrame:Update(numVisibleRows)
end

function addon:AiLTooltip()
	local tt = AltoTooltip
	
	tt:AddLine(" ")
	tt:AddDoubleLine(format("%sTier 0", colors.teal), FormatAiL("58-63"))
	tt:AddDoubleLine(format("%sTier 1", colors.teal), FormatAiL("66"))
	tt:AddDoubleLine(format("%sTier 2", colors.teal), FormatAiL("76"))
	tt:AddDoubleLine(format("%sTier 3", colors.teal), FormatAiL("86-92"))
end
