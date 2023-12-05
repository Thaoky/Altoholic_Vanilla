local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local parentName = "AltoholicTabCharacters"
local parent

local currentView = 0		-- current view in the characters category
local currentSpellTab
local currentProfession			-- currently selected profession
local currentMenuProfession	-- profession currently being navigated in the DDM

local THIS_ACCOUNT = "Default"
local currentAccount = THIS_ACCOUNT
local currentRealm = GetRealmName()
local currentAlt = UnitName("player")

local SKILL_ANY = 0

-- ** Icons Menus **
local VIEW_BAGS = 1
local VIEW_QUESTS = 2
local VIEW_TALENTS = 3
local VIEW_AUCTIONS = 4
local VIEW_BIDS = 5
local VIEW_MAILS = 6
local VIEW_COMPANIONS = 7
local VIEW_SPELLS = 8
local VIEW_PROFESSION = 9

-- Second mini easter egg, the bag icon changes depending on the amount of chars at level max (on the current realm), or based on the time of the year
local BAG_ICONS = {
	"Interface\\Icons\\INV_MISC_BAG_09",			-- mini pouch
	"Interface\\Icons\\INV_MISC_BAG_10_BLUE",		-- small bag
	"Interface\\Icons\\INV_Misc_Bag_12",			-- larger bag
	"Interface\\Icons\\INV_Misc_Bag_19",			-- bag 14
	"Interface\\Icons\\INV_Misc_Bag_08",			-- bag 16
	"Interface\\Icons\\INV_Misc_Bag_23_Netherweave",	-- 18
	"Interface\\Icons\\INV_Misc_Bag_EnchantedMageweave",	-- 20
	"Interface\\Icons\\INV_Misc_Bag_25_Mooncloth",
	"Interface\\Icons\\INV_Misc_Bag_26_Spellfire",
	"Interface\\Icons\\INV_Misc_Bag_33",
	"Interface\\Icons\\inv_misc_basket_05",
	"Interface\\Icons\\inv_tailoring_hexweavebag",
}

local ICON_BAGS_HALLOWSEND = "Interface\\Icons\\INV_Misc_Bag_28_Halloween"
local ICON_VIEW_BAGS = "Interface\\Icons\\INV_MISC_BAG_09"

-- ** Left menu **
local ICON_CHARACTERS = "Interface\\Icons\\Achievement_GuildPerk_Everyones a Hero_rank2"

addon.Tabs.Characters = {}

local ns = addon.Tabs.Characters		-- ns = namespace

-- *** Utility functions ***
local function HideAll()
	
	AltoholicTabCharacters.QuestLog:Hide()
	AltoholicTabCharacters.Talents:Hide()
	AltoholicTabCharacters.Spellbook:Hide()
	AltoholicTabCharacters.Recipes:Hide()
	
	AltoholicFrameContainers:Hide()

	AltoholicFrameMail:Hide()
	AltoholicFramePets:Hide()
	AltoholicFrameAuctions:Hide()
end

local function EnableIcon(frame)
	frame:Enable()
	frame.Icon:SetDesaturated(false)
end

local DDM_Add = addon.Helpers.DDM_Add
local DDM_AddTitle = addon.Helpers.DDM_AddTitle
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu

function ns:OnShow()
	if currentView == 0 then
		ns:ViewCharInfo(VIEW_BAGS)
	end
end

function ns:MenuItem_OnClick(frame, button)
	-- 2017/05/15 : frame no longer used, callers not yet updated
	HideAll()
	DropDownList1:Hide()		-- hide any right-click menu that could be open

	local menuIcons = parent.MenuIcons
	menuIcons.CharactersIcon:Show()
	menuIcons.BagsIcon:Show()
	menuIcons.QuestsIcon:Show()
	menuIcons.TalentsIcon:Show()
	menuIcons.AuctionIcon:Show()
	menuIcons.MailIcon:Show()
	menuIcons.SpellbookIcon:Show()
	menuIcons.ProfessionsIcon:Show()
end

function ns:ViewCharInfo(index)
	index = index or self.value
	
	currentView = index
	HideAll()
	ns:SetMode(index)
	ns:ShowCharInfo(index)
end

function ns:ShowCharInfo(view)
	if view == VIEW_BAGS then
		addon.Containers:SetView(addon:GetOption("UI.Tabs.Characters.ViewBagsAllInOne"))
		AltoholicFrameContainers:Show()
		addon.Containers:Update()
		
	elseif view == VIEW_QUESTS then
		AltoholicTabCharacters.QuestLog:Update()
	elseif view == VIEW_TALENTS then
		AltoholicTabCharacters.Talents:Update()
	
	elseif view == VIEW_AUCTIONS then
		addon.AuctionHouse:SetListType("Auctions")
		AltoholicFrameAuctions:Show()
		addon.AuctionHouse:InvalidateView()
		addon.AuctionHouse:Update()
	elseif view == VIEW_BIDS then
		addon.AuctionHouse:SetListType("Bids")
		AltoholicFrameAuctions:Show()
		addon.AuctionHouse:InvalidateView()
		addon.AuctionHouse:Update()
	elseif view == VIEW_MAILS then
		AltoholicFrameMail:Show()
		addon.Mail:BuildView()
		addon.Mail:Update()
		
	elseif view == VIEW_SPELLS then
		AltoholicTabCharacters.Spellbook:Update()

	elseif view == VIEW_COMPANIONS then
		addon.Pets:SetSinglePetView("CRITTER")
		addon.Pets:UpdatePets()

	elseif view == VIEW_PROFESSION then
		AltoholicTabCharacters.Recipes:Update()
	end
end

function ns:SetMode(mode)
	if not mode then return end		-- called without parameter for professions

	local showButtons = false
	
	if mode == VIEW_MAILS then
		parent.SortButtons:SetButton(1, MAIL_SUBJECT_LABEL, 220, function(self) addon.Mail:Sort(self, "name") end)
		parent.SortButtons:SetButton(2, FROM, 140, function(self) addon.Mail:Sort(self, "from") end)
		parent.SortButtons:SetButton(3, L["Expiry:"], 200, function(self) addon.Mail:Sort(self, "expiry") end)
		showButtons = true
		
	elseif mode == VIEW_AUCTIONS then
		parent.SortButtons:SetButton(1, HELPFRAME_ITEM_TITLE, 220, function(self) addon.AuctionHouse:Sort(self, "name", "Auctions") end)
		parent.SortButtons:SetButton(2, HIGH_BIDDER, 160, function(self) addon.AuctionHouse:Sort(self, "highBidder", "Auctions") end)
		parent.SortButtons:SetButton(3, CURRENT_BID, 170, function(self) addon.AuctionHouse:Sort(self, "buyoutPrice", "Auctions") end)
		showButtons = true
	
	elseif mode == VIEW_BIDS then
		parent.SortButtons:SetButton(1, HELPFRAME_ITEM_TITLE, 220, function(self) addon.AuctionHouse:Sort(self, "name", "Bids") end)
		parent.SortButtons:SetButton(2, NAME, 160, function(self) addon.AuctionHouse:Sort(self, "owner", "Bids") end)
		parent.SortButtons:SetButton(3, CURRENT_BID, 170, function(self) addon.AuctionHouse:Sort(self, "buyoutPrice", "Bids") end)
		showButtons = true
	end
	
	if showButtons then
		parent.SortButtons:ShowChildFrames()
	else
		parent.SortButtons:HideChildFrames()
	end
end

function ns:SetCurrentProfession(prof)
	if not prof then return end
	
	currentProfession = prof

	local recipes = AltoholicTabCharacters.Recipes
	recipes:SetCurrentProfession(currentProfession)
	recipes:SetMainCategory(0)
	recipes:SetCurrentColor(SKILL_ANY)
	recipes:SetCurrentSlots(ALL_INVENTORY_SLOTS)
	
	ns:ViewCharInfo(VIEW_PROFESSION)
end

-- ** DB / Get **
function ns:GetAccount()
	return currentAccount
end

function ns:GetRealm()
	return currentRealm, currentAccount
end


function ns:GetAlt()
	return currentAlt, currentRealm, currentAccount
end

function ns:GetAltKey()
	if currentAlt and currentRealm and currentAccount then
		return format("%s.%s.%s", currentAccount, currentRealm, currentAlt)
	end
end

-- ** DB / Set **
function ns:SetAlt(alt, realm, account)
	currentAlt = alt
	currentRealm = realm
	currentAccount = account
end

function ns:SetAltKey(key)
	local account, realm, char = strsplit(".", key)
	ns:SetAlt(char, realm, account)
end

-- ** Icon events **
local function OnCharacterChange(self)
	local oldAlt = currentAlt
	ns:SetAltKey(self.value)
	local newAlt = currentAlt
	
	local menuIcons = parent.MenuIcons
	EnableIcon(menuIcons.BagsIcon)
	EnableIcon(menuIcons.QuestsIcon)
	EnableIcon(menuIcons.TalentsIcon)
	EnableIcon(menuIcons.AuctionIcon)
	EnableIcon(menuIcons.MailIcon)
	EnableIcon(menuIcons.SpellbookIcon)
	EnableIcon(menuIcons.ProfessionsIcon)
	
	DropDownList1:Hide()
	
	if (not oldAlt) or (oldAlt == newAlt) then return end

	currentSpellTab = nil
	currentProfession = nil
	
	if currentView ~= VIEW_SPELLS and currentView ~= VIEW_PROFESSION then
		ns:ShowCharInfo(currentView)		-- this will show the same info from another alt (ex: containers/mail/ ..)
	else
		HideAll()
		parent.Status:SetText(format("%s|r /", DataStore:GetColoredCharacterName(self.value)))
	end
end

local function OnContainerChange(self)
	if self.value == 1 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewBags")
	elseif self.value == 2 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewBank")
	elseif self.value == 3 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewBagsAllInOne")
	end
	
	ns:ViewCharInfo(VIEW_BAGS)
end

local function OnRarityChange(self)
	addon:SetOption("UI.Tabs.Characters.ViewBagsRarity", self.value)
	addon.Containers:Update()
end

local function OnQuestHeaderChange(self)
	AltoholicTabCharacters.QuestLog:SetCategory(self.value or 0)
	ns:ViewCharInfo(VIEW_QUESTS)
end


local function OnTalentChange(self)
	CloseDropDownMenus()
	
	ns:ViewCharInfo(VIEW_TALENTS)
end

local function OnSpellTabChange(self)
	CloseDropDownMenus()
	
	if self.value then
		currentSpellTab = self.value
		AltoholicTabCharacters.Spellbook:SetSchool(self.value)
		ns:ViewCharInfo(VIEW_SPELLS)
	end
end

local function OnProfessionChange(self)
	CloseDropDownMenus()
	ns:SetCurrentProfession(self.value)
end

local function OnProfessionColorChange(self)
	CloseDropDownMenus()
	
	if not self.value then return end
	
	AltoholicTabCharacters.Recipes:SetCurrentColor(self.value)
	ns:ViewCharInfo(VIEW_PROFESSION)
end

local function OnProfessionSlotChange(self)
	CloseDropDownMenus()
	
	if not self.value then return end
	
	AltoholicTabCharacters.Recipes:SetCurrentSlots(self.value)
	ns:ViewCharInfo(VIEW_PROFESSION)
end

local function OnProfessionCategoryChange(self)
	CloseDropDownMenus()
	
	if not self.value then return end
	
	currentView = VIEW_PROFESSION
	HideAll()
	ns:SetMode(VIEW_PROFESSION)
	
	local previousProfession = currentProfession
	local professionName, mainCategory = strsplit(",", self.value)
	currentProfession = professionName
	
	local recipes = AltoholicTabCharacters.Recipes
	-- if profession has changed, reset the slots filter
	if previousProfession and previousProfession ~= currentProfession then
		recipes:SetCurrentColor(SKILL_ANY)
		recipes:SetCurrentSlots(ALL_INVENTORY_SLOTS)
	end
	recipes:SetCurrentProfession(currentProfession)
	recipes:SetMainCategory(tonumber(mainCategory))
	recipes:Update()
end

local function OnViewChange(self)
	if self.value then
		ns:ViewCharInfo(self.value)
	end
end

local function OnClearAHEntries(self)
	local character = ns:GetAltKey()
	
	local listType
	if currentView == VIEW_AUCTIONS then
		listType = "Auctions"
	elseif currentView == VIEW_BIDS then
		listType = "Bids"
	end
	
	if (self.value == 1) or (self.value == 3) then	-- clean this faction's data
		DataStore:ClearAuctionEntries(character, listType, 0)
	end
	
	if (self.value == 2) or (self.value == 3) then	-- clean goblin AH
		DataStore:ClearAuctionEntries(character, listType, 1)
	end
	
	addon.AuctionHouse:InvalidateView()
end

local function OnClearMailboxEntries(self)
	local character = ns:GetAltKey()
	DataStore:ClearMailboxEntries(character)
	addon.Mail:Update()
end

local function GetCharacterLoginText(character)
	local last = DataStore:GetLastLogout(character)
	local _, _, name = strsplit(".", character)
	
	if last then
		if name == UnitName("player") then
			last = colors.green..GUILD_ONLINE_LABEL
		else
			last = format("%s: %s", LASTONLINE, colors.yellow..date("%m/%d/%Y %H:%M", last))
		end
	else
		last = format("%s: %s", LASTONLINE, RED..L["N/A"])
	end
	return format("%s %s(%s%s)", DataStore:GetColoredCharacterName(character), colors.white, last, colors.white)
end

-- ** Menu Icons **
local function CharactersIcon_Initialize(self, level)
	
	if level == 1 then
		DDM_AddTitle(L["Characters"])
		
		for account in pairs(DataStore:GetAccounts()) do
			for realm in pairs(DataStore:GetRealms(account)) do

				local info = UIDropDownMenu_CreateInfo()

				info.text = realm
				info.hasArrow = 1
				info.checked = nil
				info.value = format("%s.%s", account, realm)
				info.func = nil
				UIDropDownMenu_AddButton(info, level)
			end
		end

		DDM_AddCloseMenu()

	elseif level == 2 then
		local menuAccount, menuRealm = strsplit(".", UIDROPDOWNMENU_MENU_VALUE)
		
		local nameList = {}		-- we want to list characters alphabetically
		for _, character in pairs(DataStore:GetCharacters(menuRealm, menuAccount)) do
			table.insert(nameList, character)	-- we can add the key instead of just the name, since they will all be like account.realm.name, where account & realm are identical
		end
		table.sort(nameList)
		
		local currentCharacterKey = ns:GetAltKey()
		for _, character in ipairs(nameList) do
			
			local info = UIDropDownMenu_CreateInfo()
			
			info.text		= GetCharacterLoginText(character)
			info.value		= character
			info.func		= OnCharacterChange
			info.icon		= nil
			info.checked	= (currentCharacterKey == character)
			
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

local function BagsIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end

	DDM_AddTitle(format("%s / %s", L["Containers"], DataStore:GetColoredCharacterName(currentCharacterKey)))
	DDM_Add(L["View"], nil, function() ns:ViewCharInfo(VIEW_BAGS) end)
	DDM_Add(L["Bags"], 1, OnContainerChange, nil, addon:GetOption("UI.Tabs.Characters.ViewBags"))
	DDM_Add(L["Bank"], 2, OnContainerChange, nil, addon:GetOption("UI.Tabs.Characters.ViewBank"))
	DDM_Add(L["All-in-one"], 3, OnContainerChange, nil, addon:GetOption("UI.Tabs.Characters.ViewBagsAllInOne"))
		
	DDM_AddTitle(" ")
	DDM_AddTitle("|r" ..RARITY)
	local rarity = addon:GetOption("UI.Tabs.Characters.ViewBagsRarity")
	DDM_Add(L["Any"], 0, OnRarityChange, nil, (rarity == 0))
	
	for i = LE_ITEM_QUALITY_UNCOMMON, LE_ITEM_QUALITY_HEIRLOOM do		-- Quality: 0 = poor .. 5 = legendary
		DDM_Add(format("|c%s%s", select(4, GetItemQualityColor(i)), _G["ITEM_QUALITY"..i.."_DESC"]), i, OnRarityChange, nil, (rarity == i))
	end
	
	DDM_AddCloseMenu()
end

local function QuestsIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	local questLog = AltoholicTabCharacters.QuestLog
	
	DDM_AddTitle(format("%s / %s", QUESTS_LABEL, DataStore:GetColoredCharacterName(currentCharacterKey)))
	DDM_Add(ALL, 0, OnQuestHeaderChange, nil, (questLog:GetCategory() == 0))
	
	-- get the list of quest headers/categories
	local sortedHeaders = {}
	for headerIndex, header in pairs(DataStore:GetQuestHeaders(currentCharacterKey)) do
		table.insert(sortedHeaders, { name = header, index = headerIndex })
	end
	-- sort them
	table.sort(sortedHeaders, function(a, b) return a.name < b.name end)

	-- then add them to the drop-down
	for _, v in pairs(sortedHeaders) do
		DDM_Add(v.name, v.index, OnQuestHeaderChange, nil, (questLog:GetCategory() == v.index))
	end
	
	DDM_AddTitle("|r ")
	DDM_AddTitle(GAMEOPTIONS_MENU)
	if DataStore_Quests then
		DDM_Add("DataStore Quests", nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory("DataStore_Quests") end)
	end
	DDM_AddCloseMenu()
end

local function TalentsIcon_Initialize(self, level)
	
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s / %s", TALENTS, DataStore:GetColoredCharacterName(currentCharacterKey)))
	DDM_AddTitle(" ")
	DDM_Add(TALENTS, 1, OnTalentChange, nil, nil)
	-- DDM_Add(TALENT_SPEC_SECONDARY, 2, OnTalentChange, nil, nil)
	DDM_AddCloseMenu()
end

local function AuctionIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s / %s", BUTTON_LAG_AUCTIONHOUSE, DataStore:GetColoredCharacterName(currentCharacterKey)))
	
	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Auctions", currentCharacterKey)
	if DataStore_Auctions and last then
		local numAuctions = DataStore:GetNumAuctions(currentCharacterKey) or 0
		local numBids = DataStore:GetNumBids(currentCharacterKey) or 0
		
		DDM_Add(format(L["Auctions %s(%d)"], colors.green, numAuctions), VIEW_AUCTIONS, OnViewChange, nil, (currentView == VIEW_AUCTIONS))
		DDM_Add(format(L["Bids %s(%d)"], colors.green, numBids), VIEW_BIDS, OnViewChange, nil, (currentView == VIEW_BIDS))
	else
		DDM_Add(format(L["Auctions %s(%d)"], colors.grey, 0), nil, nil)
		DDM_Add(format(L["Bids %s(%d)"], colors.grey, 0), nil, nil)
	end
	
	-- actions
	DDM_AddTitle(" ")
	DDM_Add(colors.white .. L["Clear your faction's entries"], 1, OnClearAHEntries)
	DDM_Add(colors.white .. L["Clear goblin AH entries"], 2, OnClearAHEntries)
	DDM_Add(colors.white .. L["Clear all entries"], 3, OnClearAHEntries)
	
	DDM_AddTitle("|r ")
	DDM_AddTitle(GAMEOPTIONS_MENU)
	if DataStore_Auctions then
		DDM_Add("DataStore Auctions", nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory("DataStore_Auctions") end)
	end
	DDM_AddCloseMenu()
end

local function MailIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
		
	DDM_AddTitle(format("%s / %s", MINIMAP_TRACKING_MAILBOX, DataStore:GetColoredCharacterName(currentCharacterKey)))

	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Mails", currentCharacterKey)
	if DataStore_Mails and last then
		local numMails = DataStore:GetNumMails(currentCharacterKey) or 0
		DDM_Add(format(L["Mails %s(%d)"], colors.green, numMails), VIEW_MAILS, OnViewChange, nil, (currentView == VIEW_MAILS))
	else
		DDM_Add(format(L["Mails %s(%d)"], colors.grey, 0), nil, nil)
	end

	DDM_Add(colors.white .. L["Clear all entries"], nil, OnClearMailboxEntries)
	DDM_AddTitle("|r ")
	DDM_AddTitle(GAMEOPTIONS_MENU)
	DDM_Add(MAIL_LABEL, nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory(AltoholicMailOptions) end)
	if DataStore_Mails then
		DDM_Add("DataStore Mails", nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory(DataStoreMailOptions) end)
	end
	
	DDM_AddCloseMenu()
end

local function SpellbookIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s / %s", SPELLBOOK, DataStore:GetColoredCharacterName(currentCharacterKey)))
	
	for index, spellTab in ipairs(DataStore:GetSpellTabs(currentCharacterKey)) do
		DDM_Add(spellTab, spellTab, OnSpellTabChange, nil, (currentSpellTab == spellTab))
	end
	
	DDM_AddCloseMenu()
end

local function ProfessionsIcon_Initialize(self, level)
	if not DataStore_Crafts then return end
	
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	local recipes = AltoholicTabCharacters.Recipes
	
	if level == 1 then
		DDM_AddTitle(format("%s / %s", TRADE_SKILLS, DataStore:GetColoredCharacterName(currentCharacterKey)))

		local last = DataStore:GetModuleLastUpdateByKey("DataStore_Crafts", currentCharacterKey)
		local rank, professionName, _

		-- Cooking
		rank = DataStore:GetCookingRank(currentCharacterKey)
		if last and rank then
			local info = UIDropDownMenu_CreateInfo()
			
			info.text = format("%s %s(%s)", PROFESSIONS_COOKING, colors.green, rank )
			info.hasArrow = 1
			info.checked = (PROFESSIONS_COOKING == (currentProfession or ""))
			info.value = PROFESSIONS_COOKING
			info.func = OnProfessionChange
			UIDropDownMenu_AddButton(info, level)
			
		else
			DDM_Add(format("%s%s", colors.grey, PROFESSIONS_COOKING), nil, nil)
		end
		
		-- First Aid
		rank = DataStore:GetFirstAidRank(currentCharacterKey)
		if last and rank then
			local info = UIDropDownMenu_CreateInfo()
			local firstAidLabel = GetSpellInfo(3273)
			
			info.text = format("%s %s(%s)", firstAidLabel, colors.green, rank )
			info.hasArrow = 1
			info.checked = (firstAidLabel == (currentProfession or ""))
			info.value = firstAidLabel
			info.func = OnProfessionChange
			UIDropDownMenu_AddButton(info, level)
			
		else
			DDM_Add(format("%s%s", colors.grey, firstAidLabel), nil, nil)
		end		
		
		
		-- Profession 1
		rank, _, _, professionName = DataStore:GetProfession1(currentCharacterKey)
		if last and rank and professionName then
			local info = UIDropDownMenu_CreateInfo()
			
			info.text = format("%s %s(%s)", professionName, colors.green, rank )
			info.hasArrow = 1
			info.checked = (professionName == (currentProfession or ""))
			info.value = professionName
			info.func = OnProfessionChange
			UIDropDownMenu_AddButton(info, level)
			
		elseif professionName then
			DDM_Add(colors.grey..professionName, nil, nil)
		end
		
		-- Profession 2
		rank, _, _, professionName = DataStore:GetProfession2(currentCharacterKey)
		if last and rank and professionName then
			local info = UIDropDownMenu_CreateInfo()
			
			info.text = format("%s %s(%s)", professionName, colors.green, rank )
			info.hasArrow = 1
			info.checked = (professionName == (currentProfession or ""))
			info.value = professionName
			info.func = OnProfessionChange
			UIDropDownMenu_AddButton(info, level)
			
		elseif professionName then
			DDM_Add(colors.grey..professionName, nil, nil)
		end
		
		DDM_AddTitle(" ")
		DDM_AddTitle(FILTERS)
		
		if currentProfession then		-- if a profession is visible, display filters
			local info = UIDropDownMenu_CreateInfo()

			info.text = format("%s%s", colors.white, COLOR)
			info.hasArrow = 1
			info.checked = nil
			info.value = "colors"
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.text = format("%s%s", colors.white, SLOT_ABBR)
			info.hasArrow = 1
			info.checked = nil
			info.value = "slots"
			info.func = nil
			UIDropDownMenu_AddButton(info, level)
			
		else		-- grey out filters
			DDM_Add(format("%s%s", colors.grey, COLOR), nil, nil)
			DDM_Add(format("%s%s", colors.grey, SLOT_ABBR), nil, nil)
		end
		
		DDM_AddCloseMenu()
		
	elseif level == 2 then	-- ** filters **
		local info = UIDropDownMenu_CreateInfo()

		if UIDROPDOWNMENU_MENU_VALUE == "colors" then
			for index = 1, 4 do 
				info.text = recipes:GetRecipeColorName(index)
				info.value = index
				info.checked = (recipes:GetCurrentColor() == index)
				info.func = OnProfessionColorChange
				UIDropDownMenu_AddButton(info, level)
			end

			info.text = L["Any"]
			info.value = SKILL_ANY
			info.checked = (recipes:GetCurrentColor() == SKILL_ANY)
			info.func = OnProfessionColorChange
			UIDropDownMenu_AddButton(info, level)
			
		elseif UIDROPDOWNMENU_MENU_VALUE == "slots" then
			info.text = ALL_INVENTORY_SLOTS
			info.value = ALL_INVENTORY_SLOTS
			info.checked = (recipes:GetCurrentSlots() == ALL_INVENTORY_SLOTS)
			info.func = OnProfessionSlotChange
			UIDropDownMenu_AddButton(info, level)
			
			local invSlots = {}
			local profession = DataStore:GetProfession(currentCharacterKey, currentProfession)
			
			DataStore:IterateRecipes(profession, 0, function(color, itemID, index) 
			
				if not itemID then return end
					
				local _, _, _, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemID)

				if itemEquipLoc and strlen(itemEquipLoc) > 0 then
					local slot = Altoholic.Equipment:GetInventoryTypeName(itemEquipLoc)
					if slot then
						invSlots[slot] = itemEquipLoc
					end
				end
			end)

			for k, v in pairs(invSlots) do		-- add all the slots found
				info.text = k
				info.value = v
				info.checked = (recipes:GetCurrentSlots() == v)
				info.func = OnProfessionSlotChange
				UIDropDownMenu_AddButton(info, level)
			end

			--NONEQUIPSLOT = "Created Items"; -- Items created by enchanting
			info.text = NONEQUIPSLOT
			info.value = NONEQUIPSLOT
			info.checked = (recipes:GetCurrentSlots() == NONEQUIPSLOT)
			info.func = OnProfessionSlotChange
			UIDropDownMenu_AddButton(info, level)
			
		else
			local profession = DataStore:GetProfession(currentCharacterKey, UIDROPDOWNMENU_MENU_VALUE)
			
			for index = 1, DataStore:GetNumRecipeCategories(profession) do
				local name = DataStore:GetRecipeCategoryInfo(profession, index)
				
				info.text = name
				info.value = format("%s,%d", UIDROPDOWNMENU_MENU_VALUE, index)		-- "Tailoring,1"
				-- info.checked = ((recipes:GetCurrentProfession() == UIDROPDOWNMENU_MENU_VALUE) and (recipes:GetMainCategory() == index))
				info.checked = false
				info.func = OnProfessionCategoryChange
				UIDropDownMenu_AddButton(info, level)	
			end
		end
	end
end

local menuIconCallbacks = {
	CharactersIcon_Initialize,
	BagsIcon_Initialize,
	QuestsIcon_Initialize,
	TalentsIcon_Initialize,
	AuctionIcon_Initialize,
	MailIcon_Initialize,
	SpellbookIcon_Initialize,
	ProfessionsIcon_Initialize,
}

function ns:Icon_OnEnter(frame)
	local currentMenuID = frame:GetID()
	
	addon:DDM_Initialize(parent.ContextualMenu, menuIconCallbacks[currentMenuID])
	
	CloseDropDownMenus()

	ToggleDropDownMenu(1, nil, parent.ContextualMenu, AltoholicTabCharacters_MenuIcons, (currentMenuID-1)*42, -5)
end

function ns:OnLoad()
	parent = _G[parentName]

	-- Menu Icons
	-- mini easter egg, change the character icon depending on the time of year :)
	-- if you find this code, please don't spoil it :)

	local day = (tonumber(date("%m")) * 100) + tonumber(date("%d"))	-- ex: dec 15 = 1215, for easy tests below
	local bagIcon = ICON_VIEW_BAGS

	-- bag icon gets better with more chars at lv max
	local LVMax = 110
	local numLvMax = 0
	for _, character in pairs(DataStore:GetCharacters()) do
		if DataStore:GetCharacterLevel(character) >= LVMax then
			numLvMax = numLvMax + 1
		end
	end

	if numLvMax > 0 then
		bagIcon = BAG_ICONS[numLvMax]
	end
	
	if (day >= 1018) and (day <= 1031) then		-- hallow's end
		bagIcon = ICON_BAGS_HALLOWSEND
	end
	
	local menuIcons = parent.MenuIcons
	menuIcons.CharactersIcon.Icon:SetTexture(addon:GetCharacterIcon())
	menuIcons.BagsIcon.Icon:SetTexture(bagIcon)
	menuIcons.QuestsIcon.Icon:SetTexCoord(0, 0.75, 0, 0.75)
	
	addon:RegisterMessage("DATASTORE_RECIPES_SCANNED")
	addon:RegisterMessage("DATASTORE_QUESTLOG_SCANNED")
end

function addon:DATASTORE_RECIPES_SCANNED(event, sender, tradeskillName)
	local recipes = AltoholicTabCharacters.Recipes
	if recipes:IsVisible() then
		recipes:Update()
	end
end

function addon:DATASTORE_QUESTLOG_SCANNED(event, sender)
	if AltoholicTabCharacters.QuestLog:IsVisible() then 
		AltoholicTabCharacters.QuestLog:Update()
	end
end

