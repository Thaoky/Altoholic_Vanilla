local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local THIS_ACCOUNT = "Default"

addon.Search = {}

local ns = addon.Search		-- ns = namespace

local updateHandler

function ns:Update()
	ns[updateHandler](ns)
end

function ns:SetUpdateHandler(h)
	updateHandler = h
end

local PLAYER_ITEM_LINE = 1
local GUILD_ITEM_LINE = 2
local PLAYER_CRAFT_LINE = 3
local GUILD_CRAFT_LINE = 4

local function Realm_UpdateEx(self, offset, desc)
	local line, LineDesc
	
	local frame = AltoholicFrameSearch
	local itemButton
	local rowFrame

	for rowIndex = 1, desc.NumLines do
		rowFrame = frame["Entry"..rowIndex]
		
		rowFrame.Name:SetWidth(240)
		rowFrame.Stat1:SetWidth(160)
		rowFrame.Stat1:SetPoint("LEFT", rowFrame.Name, "RIGHT", 5, 0)
		rowFrame.Stat2:SetWidth(150)
		rowFrame.Stat2:SetPoint("LEFT", rowFrame.Stat1, "RIGHT", 5, 0)
		
		for j=3, 6 do
			rowFrame["Stat"..j ]:Hide()
		end
		rowFrame.ILvl:Hide()
		rowFrame:SetScript("OnEnter", nil)
		rowFrame:SetScript("OnLeave", nil)
		
		line = rowIndex + offset
		local result = ns:GetResult(line)
		if result then
			LineDesc = desc.Lines[result.linetype]
			
			local owner, color = LineDesc:GetCharacter(result)
			rowFrame.Stat1:SetText(color .. owner)
			
			local realm, account, faction = LineDesc:GetRealm(result)
			local location = format("%s%s", colors[faction], realm)
			if account ~= THIS_ACCOUNT then
				location = location .. "\n" ..colors.white .. L["Account"] .. ": " ..colors.green.. account
			end
			rowFrame.Stat2:SetText(location)
			
			local hex = colors.white
			itemButton = rowFrame.Item
			itemButton.IconBorder:Hide()
			
			local item = result.link or result.id
			
			if item then
				local _, _, itemRarity = GetItemInfo(item)
				if itemRarity then
					local r, g, b
					r, g, b, hex = GetItemQualityColor(itemRarity)
					if itemRarity >= 2 then
						itemButton.IconBorder:SetVertexColor(r, g, b, 0.5)
						itemButton.IconBorder:Show()
					end
					hex = "|c" .. hex
				end
			end
			
			local name, source, sourceID = LineDesc:GetItemData(result, line)

			if name then
				rowFrame.Name:SetText(hex .. name)
				rowFrame.Source.Text:SetText(source)
				rowFrame.Source:SetID(sourceID)
			end
			
			itemButton:SetInfo(LineDesc:GetItemInfo(result))
			itemButton:SetIcon(LineDesc:GetItemTexture(result))			
			itemButton:SetCount(result.count)
			
			rowFrame:SetID(line)
			rowFrame:Show()
		end
	end

	local numResults = desc:GetSize()
	if (offset+desc.NumLines) <= numResults then
		AltoholicTabSearch.Status:SetText(numResults .. L[" results found (Showing "] .. (offset+1) .. "-" .. (offset+desc.NumLines) .. ")")
	else
		AltoholicTabSearch.Status:SetText(numResults .. L[" results found (Showing "] .. (offset+1) .. "-" .. numResults .. ")")
	end
	
	if not AltoholicFrameSearch:IsVisible() then
		AltoholicFrameSearch:Show()
	end
end

-- The principle behind ScrollFrame description is the following:
-- FauxScrollframes follow a roughly similar pattern, and are usually displaying different types of lines
-- so the idea is to standardize data collection from the raw tables that are used to populate the scrollframe
-- that way, a function called GetXXX can be used to display this info regardless of the line type, but can also be reused by sort functions

local RealmScrollFrame_Desc = {
	NumLines = 7,
	Frame = "AltoholicFrameSearch",
	GetSize = function() return ns:GetNumResults() end,
	Update = Realm_UpdateEx,
	Lines = {
		[PLAYER_ITEM_LINE] = {
			GetItemData = function(self, result)		-- GetItemData..just to avoid calling it GetItemInfo
					local name = GetItemInfo(result.id)
					
					-- return name, source, sourceID
					return name, colors.teal .. result.location, 0 
				end,
			GetItemTexture = function(self, result)
					return (result.id) and GetItemIcon(result.id) or "Interface\\Icons\\Trade_Engraving"
				end,
			GetCharacter = function(self, result)
					local character = result.source
					return DataStore:GetCharacterName(character), DataStore:GetCharacterClassColor(character)
				end,
			GetRealm = function(self, result)
					local character = result.source
					local account, realm = strsplit(".", character)
					return realm, account, DataStore:GetCharacterFaction(character)
				end,
			GetItemInfo = function(self, result)
					return result.id, result.link
				end,
		},
		[GUILD_ITEM_LINE] = {
			GetItemData = function(self, result)		-- GetItemData..just to avoid calling it GetItemInfo
					local name = GetItemInfo(result.id)
			
					-- return name, source, sourceID
					return name, colors.teal .. result.location, 0 
				end,
			GetItemTexture = function(self, result)
					return (result.id) and GetItemIcon(result.id) or "Interface\\Icons\\Trade_Engraving"
				end,
			GetCharacter = function(self, result)
					local _, _, guildName = strsplit(".", result.source)
					return guildName, colors.green
				end,
			GetRealm = function(self, result)
					local account, realm, name = strsplit(".", result.source)
					local guild = DataStore:GetGuild(name, realm, account)
					
					return realm, account, DataStore:GetGuildBankFaction(guild)
				end,
			GetItemInfo = function(self, result)
					return result.id, result.link
				end,
		},
		[PLAYER_CRAFT_LINE] = {
			GetItemData = function(self, result, line)
					
					-- return GetSpellInfo(result.spellID), source, line
					
					local isEnchanting = (result.professionName == GetSpellInfo(7411))
					
					if isEnchanting then
						local source = addon:GetRecipeLink(result.spellID, result.professionName)
						
						return GetSpellInfo(result.spellID), source, line
					else
						return GetItemInfo(result.spellID), result.professionName, line
					end
				end,
			GetItemTexture = function(self, result)
					-- local itemID = DataStore:GetCraftResultItem(result.spellID)
					
					local isEnchanting = (result.professionName == GetSpellInfo(7411))
					
					if isEnchanting then
						return "Interface\\Icons\\Trade_Engraving"
					else
						local itemID = result.spellID
						return (itemID) and GetItemIcon(itemID) or "Interface\\Icons\\Trade_Engraving"
					end
				end,
			GetCharacter = function(self, result)
					local character = result.char
					local _, _, name = strsplit(".", character)
					
					-- name, color
					return name, DataStore:GetCharacterClassColor(character)
				end,
			GetRealm = function(self, result)
					local character = result.char
					local account, realm, name = strsplit(".", character)
		
					return realm, account, DataStore:GetCharacterFaction(character)
				end,
			GetItemInfo = function(self, result)
					-- return the itemID
					-- local itemID = DataStore:GetCraftResultItem(result.spellID)
					-- do not make a direct return of the result					
					-- return itemID
					
					local isEnchanting = (result.professionName == GetSpellInfo(7411))
					if not isEnchanting then
						return result.spellID
					end
				end,
		},
		[GUILD_CRAFT_LINE] = {
			GetItemData = function(self, result, line)
					-- return name, source, sourceID
					local profession = LTL:GetSkillName(result.skillID)
					local source = addon:GetRecipeLink(result.spellID, profession)
					
					return GetSpellInfo(result.spellID), source, line
				end,
			GetItemTexture = function(self, result)
					local itemID = DataStore:GetCraftResultItem(result.spellID)
					if itemID then		-- if the craft is known, return its icon, else return the profession icon
						return GetItemIcon(itemID)	
					end
			
					local profession = LTL:GetSkillName(result.skillID)
					return addon:GetSpellIcon(addon.ProfessionSpellID[profession])
				end,
			GetCharacter = function(self, result)
					local _, _, _, _, _, _, _, _, _, _, englishClass = DataStore:GetGuildMemberInfo(result.char)
					return result.char, DataStore:GetClassColor(englishClass)
				end,
			GetRealm = function(self, result)
					return GetRealmName(), THIS_ACCOUNT, UnitFactionGroup("player")
				end,
			GetItemInfo = function(self, result)
					local itemID = DataStore:GetCraftResultItem(result.spellID)
					-- do not make a direct return of the result					
					return itemID
				end,
		},
	}
}

local function ScrollFrameUpdate(desc)
	-- copy of the function in Altoholic.lua, made local here temporarily to avoid messing up with other consumers of the function
	
	assert(type(desc) == "table")		-- desc is the table that contains a standardized description of the scrollframe
	
	local frame = _G[desc.Frame]
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	local rowFrame

	-- hide all lines and set their id to 0, the update function is responsible for showing and setting id's of valid lines	
	for rowIndex = 1, numRows do
		rowFrame = frame["Entry"..rowIndex]
		rowFrame:SetID(0)
		rowFrame:Hide()
	end
	
	local offset = scrollFrame:GetOffset()
	-- call the update handler
	desc:Update(offset, desc)
	
	local last = (desc:GetSize() < numRows) and numRows or desc:GetSize()
	scrollFrame:Update(last)
end

function ns:Realm_Update()
	ScrollFrameUpdate(RealmScrollFrame_Desc)
end

function ns:Loots_Update()
	
	local frame = AltoholicFrameSearch
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	local numResults = ns:GetNumResults()
	
	if numResults == 0 then
		-- Hides all entries of the scrollframe, and updates it accordingly
		for rowIndex = 1, numRows do	
			frame["Entry"..rowIndex]:Hide()
		end
		scrollFrame:Update(numRows)
		return
	end

	local offset = scrollFrame:GetOffset()

	local itemButton
	local rowFrame
	
	for rowIndex = 1, numRows do
		rowFrame = frame["Entry"..rowIndex]
		rowFrame.Name:SetWidth(240)
		rowFrame.Stat1:SetWidth(160)
		rowFrame.Stat1:SetPoint("LEFT", rowFrame.Name, "RIGHT", 5, 0)
		rowFrame.Stat2:SetWidth(150)
		rowFrame.Stat2:SetPoint("LEFT", rowFrame.Stat1, "RIGHT", 5, 0)
		
		for j=3, 6 do
			rowFrame["Stat"..j ]:Hide()
		end
		rowFrame.ILvl:Hide()
		
		rowFrame:SetScript("OnEnter", nil)
		rowFrame:SetScript("OnLeave", nil)
		
		local line = rowIndex + offset
		local result = ns:GetResult(line)
		if result then
			local itemID = result.id
			
			itemButton = rowFrame.Item
			itemButton.IconBorder:Hide()
			
			local itemName, _, itemRarity, itemLevel = GetItemInfo(itemID)
			local r, g, b, hex = GetItemQualityColor(itemRarity)
			
			if itemRarity >= 2 then
				itemButton.IconBorder:SetVertexColor(r, g, b, 0.5)
				itemButton.IconBorder:Show()
			end
			
			itemButton.Icon:SetTexture(GetItemIcon(itemID));

			rowFrame.Stat2:SetText(colors.yellow .. itemLevel)
			rowFrame.Name:SetText("|c" .. hex .. itemName)
			rowFrame.Source.Text:SetText(colors.teal .. result.dropLocation)
			rowFrame.Source:SetID(0)
			
			rowFrame.Stat1:SetText(colors.green .. result.bossName)

			itemButton:SetInfo(itemID)
			itemButton:SetCount(result.count)
			rowFrame:Show()
		else
			rowFrame:Hide()
		end
	end

	if (offset+numRows) <= numResults then
		AltoholicTabSearch.Status:SetText(numResults .. L[" results found (Showing "] .. (offset+1) .. "-" .. (offset+numRows) .. ")")
	else
		AltoholicTabSearch.Status:SetText(numResults .. L[" results found (Showing "] .. (offset+1) .. "-" .. numResults .. ")")
	end
	
	if numResults < numRows then
		scrollFrame:Update(numRows)
	else
		scrollFrame:Update(numResults)
	end
	
	if not AltoholicFrameSearch:IsVisible() then
		AltoholicFrameSearch:Show()
	end
end

function ns:Upgrade_Update()
	local frame = AltoholicFrameSearch
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	local numResults = ns:GetNumResults()
	
	if numResults == 0 then
		-- Hides all entries of the scrollframe, and updates it accordingly
		for rowIndex = 1, numRows do	
			frame["Entry"..rowIndex]:Hide()
		end
		scrollFrame:Update(numRows)
		return
	end

	local offset = scrollFrame:GetOffset()

	local itemButton
	local rowFrame
	local stat
	
	for rowIndex = 1, numRows do
		rowFrame = frame["Entry"..rowIndex]

		rowFrame.Name:SetWidth(190)
		rowFrame.Stat1:SetWidth(50)
		rowFrame.Stat1:SetPoint("LEFT", rowFrame.Name, "RIGHT", 0, 0)
		rowFrame.Stat2:SetWidth(50)
		rowFrame.Stat2:SetPoint("LEFT", rowFrame.Stat1, "RIGHT", 0, 0)
		rowFrame:SetScript("OnEnter", function(self) ns:TooltipStats(self) end)
		rowFrame:SetScript("OnLeave", function(self) AltoTooltip:Hide() end)
		
		local line = rowIndex + offset
		local result = ns:GetResult(line)
		if result then
			local itemID = result.id
			
			itemButton = rowFrame.Item
			itemButton.IconBorder:Hide()
			
			local itemName, _, itemRarity, itemLevel = GetItemInfo(itemID)
			local r, g, b, hex = GetItemQualityColor(itemRarity)
			
			if itemRarity >= 2 then
				itemButton.IconBorder:SetVertexColor(r, g, b, 0.5)
				itemButton.IconBorder:Show()
			end
			
			itemButton.Icon:SetTexture(GetItemIcon(itemID));

			rowFrame.Name:SetText("|c" .. hex .. itemName)
			rowFrame.Source.Text:SetText(colors.teal .. result.dropLocation)
			rowFrame.Source:SetID(0)
		
			for j=1, 6 do
				stat = rowFrame["Stat"..j]
				
				if result["stat"..j] ~= nil then
					local statValue, diff = strsplit("|", result["stat"..j])
					local color
					diff = tonumber(diff)
					
					if diff < 0 then
						color = colors.red
					elseif diff > 0 then 
						color = colors.green
					else
						color = colors.white
					end
					
					stat:SetText(color .. statValue)
					stat:Show()
				else
					stat:Hide()
				end
			end

			rowFrame.ILvl:SetText(colors.yellow .. itemLevel)
			rowFrame.ILvl:Show()
			
			itemButton:SetInfo(itemID)
			itemButton:SetCount(result.count)
			rowFrame:SetID(line)
			rowFrame:Show()
		else
			rowFrame:Hide()
		end
	end

	if (offset+numRows) <= numResults then
		AltoholicTabSearch.Status:SetText(numResults .. L[" results found (Showing "] .. (offset+1) .. "-" .. (offset+numRows) .. ")")
	else
		AltoholicTabSearch.Status:SetText(numResults .. L[" results found (Showing "] .. (offset+1) .. "-" .. numResults .. ")")
	end
	
	if numResults < numRows then
		scrollFrame:Update(numRows)
	else
		scrollFrame:Update(numResults)
	end
	
	if not AltoholicFrameSearch:IsVisible() then
		AltoholicFrameSearch:Show()
	end
end

-- ** Sort functions **
local function GetCraftName(char, profession, num)
	-- this is a helper function to quickly retrieve the name of a craft based on a character, profession and line number
	
	local c = addon:GetCharacterTableByLine(char)
	local _, _, spellID = strsplit("^", c.recipes[profession].list[num])
	return GetSpellInfo(tonumber(spellID))
end

local function SortByItemName(a, b, ascending)
	local nameA, nameB
	if a.id then
		nameA = GetItemInfo(a.id)
	else		-- some crafts do not have an item ID, since no item is created (ex: enchanting)
		nameA = GetCraftName(a.char, a.location, a.craftNum)
	end

	if b.id then
		nameB = GetItemInfo(b.id)
	else
		nameB = GetCraftName(b.char, b.location, b.craftNum)
	end
	
	if ascending then
		return nameA < nameB
	else
		return nameA > nameB
	end
end

local function SortByName(a, b, ascending)
	local desc = RealmScrollFrame_Desc			-- get the line description for the 2 items
	local LineDescA = desc.Lines[a.linetype]
	local LineDescB = desc.Lines[b.linetype]

	local nameA = LineDescA:GetItemData(a)			-- retrieve the name ..
	local nameB = LineDescB:GetItemData(b)
	
	if ascending then
		return nameA < nameB
	else
		return nameA > nameB
	end
end

local function SortByChar(a, b, ascending)
	local desc = RealmScrollFrame_Desc			-- get the line description for the 2 items
	local LineDescA = desc.Lines[a.linetype]
	local LineDescB = desc.Lines[b.linetype]

	local nameA = LineDescA:GetCharacter(a)			-- retrieve the name ..
	local nameB = LineDescB:GetCharacter(b)

	if nameA == nameB then								-- if it's the same character name ..
		return SortByName(a, b, ascending)			-- .. then sort by item name
	elseif ascending then
		return nameA < nameB
	else
		return nameA > nameB
	end
end

local function SortByRealm(a, b, ascending)
	local desc = RealmScrollFrame_Desc			-- get the line description for the 2 items
	local LineDescA = desc.Lines[a.linetype]
	local LineDescB = desc.Lines[b.linetype]

	local nameA = LineDescA:GetRealm(a)					-- retrieve the name ..
	local nameB = LineDescB:GetRealm(b)	
	
	if nameA == nameB then								-- if it's the same realm ..
		return SortByChar(a, b, ascending)	-- .. then sort by character name
	elseif ascending then
		return nameA < nameB
	else
		return nameA > nameB
	end
end

local function SortByStat(a, b, field, ascending)
	local statA = strsplit("|", a[field])
	local statB = strsplit("|", b[field])
	
	statA = tonumber(statA)
	statB = tonumber(statB)
	
	if ascending then
		return statA < statB
	else
		return statA > statB
	end
end

local function SortByField(a, b, field, ascending)
	if ascending then
		return a[field] < b[field]
	else
		return a[field] > b[field]
	end
end

-- ** Results **
local results

function ns:ClearResults()
	results = results or {}
	wipe(results)
end

function ns:AddResult(t)
	table.insert(results, t)
end

function ns:GetNumResults()
	return #results or 0
end

function ns:GetResult(n)
	if n then
		return results[n]
	end
end

function ns:SortResults(frame, field)
	if ns:GetNumResults() == 0 then return end

	local id = frame:GetID()
	local ascending = addon:GetOption("UI.Tabs.Search.SortAscending")
		
	if field == "name" then
		table.sort(results, function(a, b) return SortByName(a, b, ascending) end)
	elseif field == "item" then
		table.sort(results, function(a, b) return SortByItemName(a, b, ascending) end)
	elseif field == "char" then
		table.sort(results, function(a, b) return SortByChar(a, b, ascending) end)
	elseif field == "realm" then
		table.sort(results, function(a, b) return SortByRealm(a, b, ascending) end)
	elseif field == "stat" then
		table.sort(results, function(a, b) return SortByStat(a, b, "stat" .. id-1, ascending) end)
	else
		table.sort(results, function(a, b) return SortByField(a, b, field, ascending) end)
	end
	
	ns:Update()
end

local SEARCH_THISCHAR = 1
local SEARCH_THISREALM_THISFACTION = 2
local SEARCH_THISREALM_BOTHFACTIONS = 3
local SEARCH_ALLREALMS = 4
local SEARCH_ALLACCOUNTS = 5
local SEARCH_LOOTS = 6

local filters = addon.ItemFilters

-- ** Search attributes **
local currentValue				-- the value being searched (entered in the edit box)

local currentResultType			-- type of result currently being searched (eg: PLAYER_ITEM_LINE or GUILD_ITEM_LINE)
local currentResultKey			-- key defining who is being searched (eg: a datastore character or guild key)
local currentResultLocation	-- what is actually being searched (bags, bank, equipment, mail, etc..)

local MYTHIC_KEYSTONE = 138019

local function VerifyItem(item, itemCount, itemLink)
	if type(item) == "string" then		-- convert a link to its item id, only data saved
	
		if item:match("|Hkeystone:") then
			item = MYTHIC_KEYSTONE			-- mythic keystones are actually all using the same item id
		else
			item = tonumber(item:match("item:(%d+)"))
		end	
	end
	
	if type(itemLink) ~= "string" then              -- a link is not a link - delete it
		itemLink = nil
	end
	
	filters:SetSearchedItem(item, (item ~= MYTHIC_KEYSTONE) and itemLink or nil)
	-- local isOK = filters:ItemPassesFilters((item == 138019))	-- debug item 
	local isOK = filters:ItemPassesFilters()
	
	if isOK then			-- All conditions ok ? save it
		ns:AddResult( {
			linetype = currentResultType,			-- PLAYER_ITEM_LINE or GUILD_ITEM_LINE 
			id = item,
			link = itemLink,
			source = currentResultKey,				-- character or guild key in DataStore
			count = itemCount,
			location = currentResultLocation,
		} )
	end
end

local function CraftMatchFound(spellID, value, isEnchanting)
	local name
	
	if spellID then
		if isEnchanting then
			name = GetSpellInfo(spellID)
		else
			name = GetItemInfo(spellID)
		end
	end
	
	if name and string.find(strlower(name), value, 1, true) then
		return true
	end
end

local function BrowseCharacter(character)

	currentResultType = PLAYER_ITEM_LINE	
	currentResultKey = character
	
	local itemID, itemLink, itemCount
	local containers = DataStore:GetContainers(character)
	if containers then
		for containerName, container in pairs(containers) do
			if string.sub(containerName, 1, string.len("VoidStorage")) == "VoidStorage" then
				currentResultLocation = VOID_STORAGE
			elseif (containerName == "Bag100") then
				currentResultLocation = L["Bank"]
			elseif (containerName == "Bag-2") then
				currentResultLocation = KEYRING
			else
				local bagNum = tonumber(string.sub(containerName, 4))
				if (bagNum >= 0) and (bagNum <= 4) then
					currentResultLocation = L["Bags"]
				else
					currentResultLocation = L["Bank"]
				end			
			end
		
			for slotID = 1, container.size do
				itemID, itemLink, itemCount = DataStore:GetSlotInfo(container, slotID)
				
				-- use the link before the id if there's one
				if itemID then
					-- VerifyItem(itemLink or itemID, itemCount, itemLink)
					VerifyItem(itemID, itemCount, itemLink)
				end
			end
		end
	end
	
	currentResultLocation = L["Equipped"]

	local inventory = DataStore:GetInventory(character)
	if inventory then
		for _, v in pairs(inventory) do
			VerifyItem(v, 1, v)
		end
	end
	
	if addon:GetOption("UI.Tabs.Search.IncludeMailboxItems") then			-- check mail ?
		currentResultLocation = L["Mail"]
		local num = DataStore:GetNumMails(character) or 0
		for i = 1, num do
			local _, count, link = DataStore:GetMailInfo(character, i)
			if link then
				VerifyItem(link, count, link)
			end
		end
	end
	
	if addon:GetOption("UI.Tabs.Search.IncludeKnownRecipes")			-- check known recipes ?
		and (filters:GetFilterValue("itemType") == nil) 
		-- and (filters:GetFilterValue("itemSlot") == 0)				-- is now nil .. not zero anymore, keep commented for reference
		and (filters:GetFilterValue("itemRarity") == 0) then
		
		local professions = DataStore:GetProfessions(character)
		if professions then
			for professionName, profession in pairs(professions) do
			
				local isEnchanting = (professionName == GetSpellInfo(7411))
			
				DataStore:IterateRecipes(profession, 0, function(color, spellID)
					if CraftMatchFound(spellID, currentValue, isEnchanting) then
						ns:AddResult(	{
							linetype = PLAYER_CRAFT_LINE,
							char = currentResultKey,
							professionName = professionName,
							profession = profession,
							spellID = spellID
						} )
					end
				end)
			end
		end
	end
	
	currentResultType = nil
	currentResultKey = nil
	currentResultLocation = nil
end

local function BrowseRealm(realm, account, bothFactions)
	local playerFaction = UnitFactionGroup("player")

	for characterName, character in pairs(DataStore:GetCharacters(realm, account)) do
		if bothFactions or DataStore:GetCharacterFaction(character) == playerFaction then
			BrowseCharacter(character)
		end
	end
	
	if addon:GetOption("UI.Tabs.Search.IncludeGuildBankItems") then	-- Check guild bank(s) ?
		currentResultType = GUILD_ITEM_LINE

		for guildName, guild in pairs(DataStore:GetGuilds(realm, account)) do
			if bothFactions or DataStore:GetGuildBankFaction(guild) == playerFaction then
				currentResultKey = format("%s.%s.%s", account, realm, guildName)
				
				for tabID = 1, 8 do
					local tab = DataStore:GetGuildBankTab(guild, tabID)
					if tab.name then
						for slotID = 1, 98 do
							currentResultLocation = format("%s, %s - col %d/row %d)", GUILD_BANK, tab.name, floor((slotID-1)/7)+1, ((slotID-1)%7)+1)
							local id, link, count = DataStore:GetSlotInfo(tab, slotID)
							if id then
								link = link or id
								VerifyItem(link, count, link)
							end
						end
					end
				end
				
				currentResultKey = nil
			end
		end	-- end guild
		currentResultType = nil
		currentResultLocation = nil
	end
end

local ongoingSearch

function ns:FindItem(searchType, searchSubType)
	if ongoingSearch then
		return		-- if a search is already happening .. then exit
	end
	
	ongoingSearch = true
	
	-- Set Filters
	local value = AltoholicFrame_SearchEditBox:GetText() or ""
	
	currentValue = strlower(value)

	filters:EnableFilter("Existence")	-- should be first in the list !
	
	if value ~= "" then
		filters:SetFilterValue("itemName", currentValue)
		filters:EnableFilter("Name")
	end
	
	if searchType then
		filters:SetFilterValue("itemType", searchType)
		filters:EnableFilter("Type")
	end

	if searchSubType then
		filters:SetFilterValue("itemSubType", searchSubType)
		filters:EnableFilter("SubType")
	end
		
	local itemMinLevel = AltoholicTabSearch.MinLevel:GetNumber()
	filters:SetFilterValue("itemMinLevel", itemMinLevel)
	filters:EnableFilter("MinLevel")
	
	local itemMaxLevel = AltoholicTabSearch.MaxLevel:GetNumber()	
	if itemMaxLevel ~= 0 then			-- enable the filter only if a max level has been set
		filters:SetFilterValue("itemMaxLevel", itemMaxLevel)
		filters:EnableFilter("Maxlevel")
	end	
	
	local itemSlot = UIDropDownMenu_GetSelectedValue(AltoholicTabSearch.SelectSlot)
	if itemSlot ~= 0 then	-- don't apply filter if = 0, it means we take them all
		filters:EnableFilter("EquipmentSlot")
		filters:SetFilterValue("itemSlot", itemSlot)
	end	
	
	filters:SetFilterValue("itemRarity", UIDropDownMenu_GetSelectedValue(AltoholicTabSearch.SelectRarity))
	filters:EnableFilter("Rarity")
	
	-- Start the search
	local searchLocation = UIDropDownMenu_GetSelectedValue(AltoholicTabSearch.SelectLocation)
	
	ns:ClearResults()
	
	local SearchLoots
	if searchLocation == SEARCH_THISCHAR then
		BrowseCharacter(DataStore:GetCharacter())
	elseif searchLocation == SEARCH_THISREALM_THISFACTION or	searchLocation == SEARCH_THISREALM_BOTHFACTIONS then
		BrowseRealm(GetRealmName(), THIS_ACCOUNT, (searchLocation == SEARCH_THISREALM_BOTHFACTIONS))
	elseif searchLocation == SEARCH_ALLREALMS then
		for realm in pairs(DataStore:GetRealms()) do
			BrowseRealm(realm, THIS_ACCOUNT, true)
		end
	elseif searchLocation == SEARCH_ALLACCOUNTS then
		-- this account first ..
		for realm in pairs(DataStore:GetRealms()) do
			BrowseRealm(realm, THIS_ACCOUNT, true)
		end
		
		-- .. then all other accounts
		for account in pairs(DataStore:GetAccounts()) do
			if account ~= THIS_ACCOUNT then
				for realm in pairs(DataStore:GetRealms(account)) do
					BrowseRealm(realm, account, true)
				end
			end
		end
	else	-- search loot tables
		SearchLoots = true -- this value will be tested in ns:Update() to resize columns properly
		addon.Loots:Find()
	end
	
	filters:ClearFilters()
	
	if not AltoholicTabSearch:IsVisible() then
		addon.Tabs:OnClick("Search")
	end
	
	if ns:GetNumResults() == 0 then
		if currentValue == "" then 
			AltoholicTabSearch.Status:SetText(L["No match found!"])
		else
			AltoholicTabSearch.Status:SetText(value .. L[" not found!"])
		end
	end
	ongoingSearch = nil 	-- search done
	
	if SearchLoots then
		addon.Tabs.Search:SetMode("loots")
		-- if addon:GetOption("UI.Tabs.Search.SortDescending") then 		-- descending sort ?
			-- AltoholicTabSearch.SortButtons.Sort3.ascendingSort = true		-- say it's ascending now, it will be toggled
			-- ns:SortResults(AltoholicTabSearch.SortButtons.Sort3, "iLvl")
		-- else
			-- AltoholicTabSearch.SortButtons.Sort3.ascendingSort = nil
			-- ns:SortResults(AltoholicTabSearch.SortButtons.Sort3, "iLvl")
		-- end
	else
		addon.Tabs.Search:SetMode("realm")
	end

	ns:Update()
	collectgarbage()
end

local currentClass				-- the current character class
local currentItemID				-- itemID of the item for which we're searching for an upgrade

function ns:SetClass(class)
	currentClass = class
end

function ns:GetClass()
	return currentClass
end

function ns:SetCurrentItem(itemID)
	currentItemID = itemID
end

function ns:GetRealmsLineDesc(line)
	return RealmScrollFrame_Desc.Lines[line]
end

function ns:FindEquipmentUpgrade()
	local upgradeType = self.value

	ns:ClearResults()
	
	-- Set Filters
	local _, itemLink, _, itemLevel, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(currentItemID)
	local itemSlot = addon.Equipment:GetInventoryTypeIndex(itemEquipLoc)
	
	filters:SetFilterValue("itemLevel", itemLevel)
	filters:SetFilterValue("itemType", itemType)
	filters:SetFilterValue("itemSubType", itemSubType)

	filters:EnableFilter("Existence")
	filters:EnableFilter("ItemLevel")
	filters:EnableFilter("Type")
	filters:EnableFilter("SubType")
	
	if itemSlot ~= 0 then	-- don't apply filter if = 0, it means we take them all
		filters:SetFilterValue("itemSlot", itemSlot)
		filters:EnableFilter("EquipmentSlot")
	end
	
	-- Start the search
	if upgradeType ~= -1 then	-- not an item level upgrade
		ns:SetClass(upgradeType)
		addon.Loots:FindUpgradeByStats( currentItemID, upgradeType)

	else	-- simple search, point to simple VerifyUpgrade method
		addon.Loots:FindUpgrade()
		AltoholicSearchOptionsLootInfo:SetText( colors.green .. addon:GetOption("TotalLoots") .. "|r " .. L["Loots"] .. " / "
				.. colors.green .. addon:GetOption("UnknownLoots") .. "|r " .. L["Unknown"])
	end
	
	filters:ClearFilters()
	currentItemID = nil

	AltoTooltip:Hide();	-- mandatory hide after processing	
	
	if not AltoholicTabSearch:IsVisible() then
		addon.Tabs:OnClick("Search")
	end
	
	if upgradeType ~= -1 then	-- not an item level upgrade
		addon.Tabs.Search:SetMode("upgrade")
	else
		addon.Tabs.Search:SetMode("loots")
	end
	
	-- if addon:GetOption("UI.Tabs.Search.SortDescending") then 		-- descending sort ?
		-- AltoholicTabSearch.SortButtons.Sort8.ascendingSort = true		-- say it's ascending now, it will be toggled
		-- ns:SortResults(AltoholicTabSearch.SortButtons.Sort8, "iLvl")
	-- else
		-- AltoholicTabSearch.SortButtons.Sort8.ascendingSort = nil
		-- ns:SortResults(AltoholicTabSearch.SortButtons.Sort8, "iLvl")
	-- end

	ns:Update()
end
