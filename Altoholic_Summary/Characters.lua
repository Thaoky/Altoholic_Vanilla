local addonName = "Altoholic"
local addon = _G[addonName]
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local colors = addon.Colors

local THIS_ACCOUNT = "Default"
local INFO_REALM_LINE = 0
local INFO_CHARACTER_LINE = 1
local INFO_TOTAL_LINE = 2

local THISREALM_THISACCOUNT = 1
local THISREALM_ALLACCOUNTS = 2
local ALLREALMS_THISACCOUNT = 3
local ALLREALMS_ALLACCOUNTS = 4

addon.Characters = {}

local ns = addon.Characters		-- ns = namespace

local characterList
local view
local isViewValid

local OPTION_FACTIONS = "UI.Tabs.Summary.CurrentFactions"
local OPTION_LEVELS_MIN = "UI.Tabs.Summary.CurrentLevelsMin"
local OPTION_LEVELS_MAX = "UI.Tabs.Summary.CurrentLevelsMax"
local OPTION_TRADESKILL = "UI.Tabs.Summary.CurrentTradeSkill"
local OPTION_CLASSES = "UI.Tabs.Summary.CurrentClasses"

local function ProcessRealms(func)
	local mode = addon:GetOption("UI.Tabs.Summary.CurrentRealms")
	local thisRealm = GetRealmName()
	
	-- this account only
	if mode == THISREALM_THISACCOUNT then
		func(THIS_ACCOUNT, thisRealm)
		
	elseif mode == ALLREALMS_THISACCOUNT then	
		for realm in pairs(DataStore:GetRealms()) do
			func(THIS_ACCOUNT, realm)
		end

	-- all accounts
	elseif mode == THISREALM_ALLACCOUNTS then
		for account in pairs(DataStore:GetAccounts()) do
			for realm in pairs(DataStore:GetRealms(account)) do
				if realm == thisRealm then
					func(account, realm)
				end
			end
		end
		
	elseif mode == ALLREALMS_ALLACCOUNTS then
		for account in pairs(DataStore:GetAccounts()) do
			for realm in pairs(DataStore:GetRealms(account)) do
				func(account, realm)
			end
		end
	end
end

local collapsedRealms = {}

local totalMoney
local totalPlayed
local totalLevels
local realmCount

local function AddRealm(AccountName, RealmName)

	local comm = Altoholic.Comm.Sharing
	if comm.SharingInProgress then
		if comm.account == AccountName and RealmName == GetRealmName() then
			-- if we're trying to add the account+realm we're currently copying, then don't add it now.
			return
		end
	end

	local realmMoney = 0
	local realmPlayed = 0
	local realmLevels = 0
	local realmBagSlots = 0
	local realmFreeBagSlots = 0
	local realmBankSlots = 0
	local realmFreeBankSlots = 0
	local realmAiL = 0
	local realmOffset = realmCount*3
	local numCharacters = 0

	-- let's get our filter values
	local factions = addon:GetOption(OPTION_FACTIONS)
	local minLevel = addon:GetOption(OPTION_LEVELS_MIN)
	local maxLevel = addon:GetOption(OPTION_LEVELS_MAX)
	local class = addon:GetOption(OPTION_CLASSES)
	local tradeskill = addon:GetOption(OPTION_TRADESKILL)
	local firstSecondary = addon.TradeSkills.AccountSummaryFirstSecondarySkillIndex
	
	local shouldAddCharacter = true
	
	if factions == 4 then
		factions = (UnitFactionGroup("player") == "Alliance") and 1 or 2
	end
	
	-- 1) Add the realm name
	table.insert(characterList, { linetype = INFO_REALM_LINE + realmOffset,
		account = AccountName,
		realm = RealmName
	} )
	
	-- 2) Add the characters (if they pass filters)
	for characterName, character in pairs(DataStore:GetCharacters(RealmName, AccountName)) do
		shouldAddCharacter = true
	
		local characterLevel = DataStore:GetCharacterLevel(character)
		local characterFaction = DataStore:GetCharacterFaction(character)
		local _, characterClass = DataStore:GetCharacterClass(character)
		
		if (characterLevel < minLevel) then shouldAddCharacter = false end
		if (characterLevel > maxLevel) then shouldAddCharacter = false end
	
		if (factions == 1) and (characterFaction ~= "Alliance") then
			shouldAddCharacter = false
		elseif (factions == 2) and (characterFaction ~= "Horde") then
			shouldAddCharacter = false
		end
		
		if (class ~= 0) and CLASS_SORT_ORDER[class] ~= characterClass then shouldAddCharacter = false end
		if (tradeskill ~= 0) then 

			-- primary profession
			if tradeskill < addon.TradeSkills.AccountSummaryFirstSecondarySkillIndex then
				local tradeskillID = addon.TradeSkills.AccountSummaryFiltersSpellIDs[tradeskill]
				local _, _, _, name1 = DataStore:GetProfession1(character)
				local _, _, _, name2 = DataStore:GetProfession2(character)
				local prof1 = DataStore:GetProfessionSpellID(name1) or 0
				local prof2 = DataStore:GetProfessionSpellID(name2) or 0
				
				if tradeskillID ~= prof1 and tradeskillID ~= prof2 then 
					shouldAddCharacter = false 
				end
				
			elseif tradeskill == firstSecondary then
				local rank = DataStore:GetCookingRank(character) or 0
				if rank == 0 then
					shouldAddCharacter = false 
				end

			elseif tradeskill == firstSecondary+1 then
				local rank = DataStore:GetFirstAidRank(character) or 0
				if rank == 0 then
					shouldAddCharacter = false 
				end

			elseif tradeskill == firstSecondary+2 then
				local rank = DataStore:GetFishingRank(character) or 0
				if rank == 0 then
					shouldAddCharacter = false 
				end

			end
		end
		
		-- filters passed ?
		if shouldAddCharacter then
			realmLevels = realmLevels + (DataStore:GetCharacterLevel(character) or 0)
			realmMoney = realmMoney + (DataStore:GetMoney(character) or 0)
			realmPlayed = realmPlayed + (DataStore:GetPlayTime(character) or 0)
			
			realmBagSlots = realmBagSlots + (DataStore:GetNumBagSlots(character) or 0)
			realmFreeBagSlots = realmFreeBagSlots + (DataStore:GetNumFreeBagSlots(character) or 0)
			realmBankSlots = realmBankSlots + (DataStore:GetNumBankSlots(character) or 0)
			realmFreeBankSlots = realmFreeBankSlots + (DataStore:GetNumFreeBankSlots(character) or 0)
			realmAiL = realmAiL + (DataStore:GetAverageItemLevel(character) or 0)
			table.insert(characterList, { linetype = INFO_CHARACTER_LINE + realmOffset, key = character } )
			
			numCharacters = numCharacters + 1
		end
	end

	-- 3) Add the totals
	table.insert(characterList, { linetype = INFO_TOTAL_LINE + realmOffset,
		level = colors.white .. realmLevels,
		money = realmMoney,
		played = Altoholic:GetTimeString(realmPlayed),
		bagSlots = realmBagSlots,
		freeBagSlots = realmFreeBagSlots,
		bankSlots = realmBankSlots,
		freeBankSlots = realmFreeBankSlots,
		realmAiL = (numCharacters ~= 0) and (realmAiL / numCharacters) or 0,
	} )

	totalMoney = totalMoney + realmMoney
	totalPlayed = totalPlayed + realmPlayed
	totalLevels = totalLevels + realmLevels
	realmCount = realmCount + 1
	
	-- remove empty realms if no characters have passed filters
	if numCharacters == 0 then
		table.remove(characterList)	-- remove the last 2 lines, which are the header and the total if no characters were found
		table.remove(characterList)
	end
end

local function BuildList()
	characterList = characterList or {}
	wipe(characterList)
	
	totalMoney = 0
	totalPlayed = 0
	totalLevels = 0
	realmCount = 0 -- will be required for sorting purposes
	ProcessRealms(AddRealm)

	local levels = format("%s%s |rLv", colors.white, BreakUpLargeNumbers(totalLevels))
	local gold = format(GOLD_AMOUNT_TEXTURE_STRING, BreakUpLargeNumbers(floor( totalMoney / 10000 )), 13, 13)
	local played = format("%s%sd", BreakUpLargeNumbers(floor(totalPlayed / 86400)), colors.gold)
	
	local f = AltoholicTabSummary
	
	f.Totals:SetText(L["Totals"])
	f.TotalLv:SetText(levels)
	f.TotalGold:SetText(gold)
	f.TotalPlayed:SetText(played)
end

local function AddRealmView(AccountName, RealmName)
	for index, line in pairs(characterList) do
		if mod(line.linetype, 3) == INFO_REALM_LINE then
			if (line.account == AccountName) and (line.realm == RealmName) then
				-- insert index to current line (INFO_REALM_LINE)
				table.insert(view, index)
				index = index + 1

				-- insert index to the rest of the realm 
				local linetype = mod(characterList[index].linetype, 3)
				while (linetype ~= INFO_REALM_LINE) do
					table.insert(view, index)
					index = index + 1
					if index > #characterList then
						return
					end
					linetype = mod(characterList[index].linetype, 3)
				end
				return
			end
		end
	end
end

local function BuildView()
	-- The character info index is a small table that basically indexes character info
	-- ex: character info contains data for 4 realms on two accounts, but the index only cares about the summary tab filter,
	-- and indexes just one realm, or one account
	view = view or {}
	wipe(view)
	
	ProcessRealms(AddRealmView)
	isViewValid = true
end

local function SortByFunction(a, b, func, ascending)
	if (a.linetype ~= b.linetype) then			-- sort by linetype first ..
		return a.linetype < b.linetype
	else													-- and when they're identical, sort  by func xx
		if mod(a.linetype, 3) ~= INFO_CHARACTER_LINE then
			return false		-- don't swap lines if they're not INFO_CHARACTER_LINE
		end

		local retA = func(self, a.key) or 0		-- set to zero if a return value is nil, so that they can be compared
		local retB = func(self, b.key) or 0
		
		if ascending then
			return retA < retB
		else
			return retA > retB
		end
	end
end

function ns:Sort(ascending, func)
	table.sort(characterList, function(a, b) return SortByFunction(a, b, func, ascending) end)
end

function ns:Get(index)
	return characterList[index]
end

function ns:GetView()
	if not isViewValid then
		BuildList()
		BuildView()
	end
	return view
end

function ns:InvalidateView()
	isViewValid = nil
end

function ns:GetNum()
	return #characterList or 0
end

function ns:GetInfo(index)
	-- with the line number in the characterList table, return the name, realm & account of a char.
	local lineType = ns:GetLineType(index)
	
	if lineType == INFO_REALM_LINE then
		local line = characterList[index]
		return nil, line.realm, line.account
	elseif lineType == INFO_CHARACTER_LINE then
		local account, realm, name = strsplit(".", characterList[index].key)
		return name, realm, account
	end
end

function ns:GetLineType(index)
	return mod(characterList[index].linetype, 3)
end

function ns:GetField(index, field)
	local character = characterList[index]
	if character then
		return character[field]
	end
end

function ns:ToggleView(frame)
	for _, line in pairs(characterList) do
		if mod(line.linetype, 3) == INFO_REALM_LINE then
			local key = format("%s.%s", line.account, line.realm)
			collapsedRealms[key] = frame.isCollapsed
		end
	end
end

function ns:ToggleHeader(frame)
	local line = frame:GetParent():GetID()
	if line == 0 then return end

	local header = characterList[line]
	local key = format("%s.%s", header.account, header.realm)

	if not collapsedRealms[key] then
		collapsedRealms[key] = true
	else
		collapsedRealms[key] = nil
	end
end

function ns:IsRealmCollapsed(line)
	local header = characterList[line]
	local key = format("%s.%s", header.account, header.realm)

	return collapsedRealms[key]
end
