--[[	*** Altoholic ***
Written by : Thaoky, EU-Marécages de Zangar
--]]

local addonName = ...
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local THIS_ACCOUNT = "Default"

local function InitLocalization()
	-- this function's purpose is to initialize the text attribute of widgets created in XML.
	-- in versions prior to 3.1.003, they were initialized through global constants named XML_ALTO_???
	-- the strings stayed in memory for no reason, and could not be included in the automated localization offered by curse, hence the change of approach.
	
	AltoAccountSharing_InfoButton.tooltip = format("%s|r\n%s\n%s\n\n%s",
		colors.white..L["Account Name"], 
		L["Enter an account name that will be\nused for |cFF00FF00display|r purposes only."],
		L["This name can be anything you like,\nit does |cFF00FF00NOT|r have to be the real account name."],
		L["This field |cFF00FF00cannot|r be left empty."])

	AltoholicFrameTab1:SetText(L["Summary"])
	AltoholicFrameTab2:SetText(L["Characters"])
	AltoholicFrameTab5:SetText(L["Agenda"])
	AltoholicFrameTab6:SetText(L["Grids"])
	
	AltoAccountSharingName:SetText(L["Account Name"])
	AltoAccountSharingText1:SetText(L["Send account sharing request to:"])
	AltoAccountSharingText2:SetText(colors.orange.."Available Content")
	AltoAccountSharingText3:SetText(colors.orange.."Size")
	AltoAccountSharingText4:SetText(colors.orange.."Date")
	AltoAccountSharing_UseNameText:SetText(L["Character"])
	
	AltoholicFrameSearchLabel:SetText(L["Search Containers"])
	AltoholicFrame_ResetButton:SetText(L["Reset"])

	-- if GetLocale() == "deDE" then
		-- This is a global string from wow, for some reason the original is causing problem. DO NOT copy this line in localization files
		-- ITEM_MOD_SPELL_POWER = "Erh\195\182ht die Zaubermacht um %d."; 
	-- end
end

local function BuildUnsafeItemList()
	-- This method will clean the unsafe item list currently in the DB. 
	-- In the previous game session, the list has been populated with items id's that were originally unsafe and for which a query was sent to the server.
	-- In this session, a getiteminfo on these id's will keep returning a nil if the item is really unsafe, so this method will get rid of the id's that are now valid.
	local TmpUnsafe = {}		-- create a temporary table with confirmed unsafe id's
	local unsafeItems = Altoholic.db.global.unsafeItems
	
	for _, itemID in pairs(unsafeItems) do
		local itemName = GetItemInfo(itemID)
		if not itemName then							-- if the item is really unsafe .. save it
			table.insert(TmpUnsafe, itemID)
		end
	end
	
	wipe(unsafeItems)	-- clear the DB table
	
	for _, itemID in pairs(TmpUnsafe) do
		table.insert(unsafeItems, itemID)	-- save the confirmed unsafe ids back in the db
	end
end

-- *** DB functions ***
local currentAlt = UnitName("player")
local currentRealm = GetRealmName()
local currentAccount = THIS_ACCOUNT

function addon:GetCharacterTable(name, realm, account)
	-- Usage: 
	-- 	local c = addon:GetCharacterTable(char, realm, account)
	--	all 3 parameters default to current player, realm or account
	-- use this for features that have to work regardless of an alt's location (any realm, any account)
	local key = format("%s.%s.%s", account or currentAccount, realm or currentRealm, name or currentAlt)
	return addon.db.global.Characters[key]
end

function addon:GetCharacterTableByLine(line)
	-- shortcut to get the right character table based on the line number in the info table.
	return addon:GetCharacterTable( addon.Characters:GetInfo(line) )
end

function addon:GetGuild(name, realm, account)
	name = name or GetGuildInfo("player")
	if not name then return end
	
	realm = realm or GetRealmName()
	account = account or THIS_ACCOUNT
	
	local key = format("%s.%s.%s", account, realm, name)
	return addon.db.global.Guilds[key]
end

function Altoholic:SetLastAccountSharingInfo(name, realm, account)
	local sharing = Altoholic.db.global.Sharing.Domains[format("%s.%s", account, realm)]
	sharing.lastSharingTimestamp = time()
	sharing.lastUpdatedWith = name
end

function Altoholic:GetLastAccountSharingInfo(realm, account)
	local sharing = Altoholic.db.global.Sharing.Domains[format("%s.%s", account, realm)]
	
	if sharing then
		return date("%m/%d/%Y %H:%M", sharing.lastSharingTimestamp), sharing.lastUpdatedWith
	end
end


-- *** Hooks ***
local Orig_ChatEdit_InsertLink = ChatEdit_InsertLink

function ChatEdit_InsertLink(text, ...)
	if text and AltoholicFrame_SearchEditBox:IsVisible() then
		if not DataStore_Crafts:IsTradeSkillWindowOpen() then
			AltoholicFrame_SearchEditBox:Insert(GetItemInfo(text))
			return true
		end
	end
	return Orig_ChatEdit_InsertLink(text, ...)
end

local Orig_SendMailNameEditBox_OnChar = SendMailNameEditBox:GetScript("OnChar")

SendMailNameEditBox:SetScript("OnChar", function(self, ...)
	if addon:GetOption("UI.Mail.AutoCompleteRecipient") then
		local text = self:GetText()
		local textlen = strlen(text)
		local currentFaction = UnitFactionGroup("player")
		
		for characterName, character in pairs(DataStore:GetCharacters()) do
			if DataStore:GetCharacterFaction(character) == currentFaction then
				if ( strfind(strupper(characterName), strupper(text), 1, 1) == 1 ) then
					-- SendMailNameEditBox:SetText(format("%s-%s", characterName, GetRealmName()))
					SendMailNameEditBox:SetText(characterName)
					SendMailNameEditBox:HighlightText(textlen, -1)
					return;
				end
			end
		end
	end
	
	if Orig_SendMailNameEditBox_OnChar then
		return Orig_SendMailNameEditBox_OnChar(self, ...)
	end
end)

local Orig_AuctionFrameBrowse_Update

function AuctionFrameBrowse_UpdateHook()
	-- Courtesy of Tirdal on WoWInterface
	local AuctioneerCompactUI = false;

	Orig_AuctionFrameBrowse_Update()		-- Let default stuff happen first ..
	
	if addon:GetOption("UI.AHColorCoding") == false then return end
	
	if IsAddOnLoaded("Auctioneer") and Auctioneer.ScanManager.IsScanning() then return end

	if IsAddOnLoaded("Auc-Advanced") then
		if AucAdvanced.Scan.IsScanning() then return end;
		if AucAdvanced.Settings.GetSetting("util.compactui.activated") then
			AuctioneerCompactUI = true
		end
	end

	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	local link
	for i = 1, NUM_BROWSE_TO_DISPLAY do			-- NUM_BROWSE_TO_DISPLAY = 8;
		local button = _G["BrowseButton"..i];
		local trueID = 0;
		-- Auctioneer Compatibility
		if (AuctioneerCompactUI and button:IsVisible()) then
			trueID = button.id;
		else
			trueID = button:GetID() + offset;
		end
		link = GetAuctionItemLink("list", trueID)
		if link and not link:match("battlepet:(%d+)") then		-- if there's a valid item link in this slot ..
			local itemID = addon:GetIDFromLink(link)
			local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemID)
			if itemType == L["ITEM_TYPE_RECIPE"] and itemSubType ~= L["ITEM_SUBTYPE_BOOK"] then		-- is it a recipe ?
				
				local _, couldLearn, willLearn = addon:GetRecipeOwners(itemSubType, link, addon:GetRecipeLevel(link))
				local tex

				if (AuctioneerCompactUI) then
					tex = button.Icon;
				else
					tex = _G["BrowseButton" .. i .. "ItemIconTexture"]
				end

				if tex then
					if #couldLearn == 0 and #willLearn == 0 then	-- nobody could learn the recipe, neither now nor later : red
						tex:SetVertexColor(1, 0, 0)
					elseif #couldLearn > 0 then			-- at least 1 could learn it : green (priority over "will learn")
						tex:SetVertexColor(0, 1, 0)
					elseif #willLearn > 0 then			-- nobody could learn it now, but some could later : yellow
						tex:SetVertexColor(1, 1, 0)
					end
				end
			
			elseif AuctioneerCompactUI and button:IsVisible() then
				-- Auctioneer retains the previous color for that offset icon.
				-- Have to reset in case previous search was a recipe.
				button.Icon:SetVertexColor(1,1,1);
			end
		end
	end
	AltoTooltip:Hide()
end

local function IsBOPItemKnown(itemID)
	-- Check if a given item is BOP and known by the current player
	local _, link = GetItemInfo(itemID)
	if not link then return end

	-- ITEM_BIND_ON_EQUIP = "Binds when equipped";
	-- ITEM_BIND_ON_PICKUP = "Binds when picked up";
	-- ITEM_BIND_ON_USE = "Binds when used";
	-- ITEM_SPELL_KNOWN = "Already known";
	
	AltoTooltip:SetOwner(AltoholicFrame, "ANCHOR_LEFT")
	AltoTooltip:SetHyperlink(link)
	
	local tooltipLine
	local isBOP
	local isKnown	-- by the current character only
	
	for i = 1, AltoTooltip:NumLines() do
		tooltipLine = _G[ "AltoTooltipTextLeft" .. i]:GetText()
		if tooltipLine then
			if tooltipLine == ITEM_BIND_ON_PICKUP and i <= 4 then	
				-- some items will have "Binds when picked up" twice.. only care about the occurence in the first 4 lines
				isBOP = true
			elseif tooltipLine == ITEM_SPELL_KNOWN then
				isKnown = true
			end
		end
	end

	return (isBOP and isKnown) -- only return true if both are true
end

local Orig_MerchantFrame_UpdateMerchantInfo

local function MerchantFrame_UpdateMerchantInfoHook()
	
	Orig_MerchantFrame_UpdateMerchantInfo()		-- Let default stuff happen first ..
	
	if addon:GetOption("UI.VendorColorCoding") == false then return end
	
   local numItems = GetMerchantNumItems()
	local index, link

	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
		if index <= numItems then
			link = GetMerchantItemLink(index)
	
			if link then		-- if there's a valid item link in this slot ..
				local itemID = addon:GetIDFromLink(link)
				if itemID and itemID ~= 0 then		-- if there's a valid item link 
					local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemID)
					
					local r, g, b = 1, 1, 1
					
					-- also applies to garrison blueprints
					if IsBOPItemKnown(itemID) then		-- recipe is bop and already known, useless to alts : red.
						r, g, b = 1, 0, 0
					elseif itemType == L["ITEM_TYPE_RECIPE"] and itemSubType ~= L["ITEM_SUBTYPE_BOOK"] then		-- is it a recipe ?
						local _, couldLearn, willLearn = addon:GetRecipeOwners(itemSubType, link, addon:GetRecipeLevel(link))
						if #couldLearn == 0 and #willLearn == 0 then		-- nobody could learn the recipe, neither now nor later : red
							r, g, b = 1, 0, 0
						elseif #couldLearn > 0 then							-- at least 1 could learn it : green (priority over "will learn")
							r, g, b = 0, 1, 0
						elseif #willLearn > 0 then								-- nobody could learn it now, but some could later : yellow
							r, g, b = 1, 1, 0
						end
					end
					
					local button = _G["MerchantItem" .. i .. "ItemButton"]
					if button then
						SetItemButtonTextureVertexColor(button, r, g, b)
						SetItemButtonNormalTextureVertexColor(button, r, g, b)
					end
				end
			end
		end
	end
	AltoTooltip:Hide()
end

-- *** Event Handlers ***
local function OnAuctionHouseClosed()
	addon:UnregisterEvent("AUCTION_HOUSE_CLOSED")
	if addon.AuctionHouse then
		addon.AuctionHouse:InvalidateView()
	end
end

local function OnAuctionHouseShow()
	addon:RegisterEvent("AUCTION_HOUSE_CLOSED", OnAuctionHouseClosed)

	-- hook the AH update function
	if not Orig_AuctionFrameBrowse_Update then
		Orig_AuctionFrameBrowse_Update = AuctionFrameBrowse_Update
		AuctionFrameBrowse_Update = AuctionFrameBrowse_UpdateHook
	end
end

local function OnChatMsgLoot(event, arg)
	addon:RefreshTooltip()		-- any loot message should cause a refresh
end

function addon:OnEnable()
	InitLocalization()
	addon:SetupOptions()
	-- Only needed in debug
	-- addon.Profiler:Init()
	addon.Tasks:Init()
	addon.Events:Init()
	addon:InitTooltip()

	addon:RegisterEvent("AUCTION_HOUSE_SHOW", OnAuctionHouseShow)	-- must stay here for the AH hook (to manage recipe coloring)

	-- hook the Merchant update function
	Orig_MerchantFrame_UpdateMerchantInfo = MerchantFrame_UpdateMerchantInfo
	MerchantFrame_UpdateMerchantInfo = MerchantFrame_UpdateMerchantInfoHook
	
	AltoholicFrameName:SetText(format("Altoholic Classic %s%s by %sThaoky", colors.white, addon.Version, colors.classMage))

	local realm = GetRealmName()
	local player = UnitName("player")
	local key = format("%s.%s.%s", THIS_ACCOUNT, realm, player)
	addon.ThisCharacter = addon.db.global.Characters[key]

	-- Do not move this line, minimap initialization must happen AFTER OnEnable, otherwise options are not yet ready
	if addon:GetOption("UI.Minimap.ShowIcon") then
		Minimap.AltoholicButton:Move()
		Minimap.AltoholicButton:Show()
	else
		Minimap.AltoholicButton:Hide()
	end
	
	addon:RestoreOptionsToUI()
	addon:RegisterEvent("CHAT_MSG_LOOT", OnChatMsgLoot)
	
	BuildUnsafeItemList()
	
	-- create an empty frame to manage the timer via its Onupdate
	addon.TimerFrame = CreateFrame("Frame", "AltoholicTimerFrame", UIParent)
	local f = addon.TimerFrame
	
	f:SetWidth(1)
	f:SetHeight(1)
	f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 1, 1)
	f:SetScript("OnUpdate", function(addon, elapsed) Altoholic.Tasks:OnUpdate(elapsed) end)
	f:Show()
end

function addon:OnDisable()
end

function addon:ToggleUI()
	if (AltoholicFrame:IsVisible()) then
		AltoholicFrame:Hide()
	else
		AltoholicFrame:Show()
	end
end

function addon:OnShow()
	SetPortraitTexture(AltoholicFramePortrait, "player")
	
	if not addon.Tabs.current then
		addon.Tabs:OnClick("Summary")
		local mode = addon:GetOption("UI.Tabs.Summary.CurrentMode")
		AltoholicTabSummary["MenuItem"..mode]:Item_OnClick()
	end
end


-- *** Utility functions ***

function Altoholic:ScrollFrameUpdate(desc)
	assert(type(desc) == "table")		-- desc is the table that contains a standardized description of the scrollframe
	
	local frame = desc.Frame
	local entry = frame.."Entry"

	-- hide all lines and set their id to 0, the update function is responsible for showing and setting id's of valid lines	
	for i = 1, desc.NumLines do
		_G[ entry..i ]:SetID(0)
		_G[ entry..i ]:Hide()
	end
	
	local scrollFrame = _G[ frame.."ScrollFrame" ]
	local offset = scrollFrame:GetOffset()

	-- call the update handler
	desc:Update(offset, entry, desc)
	
	local last = (desc:GetSize() < desc.NumLines) and desc.NumLines or desc:GetSize()
	scrollFrame:Update(last, desc.NumLines, desc.LineHeight);
end

function addon:Item_OnEnter(frame)
	if not frame.id then return end
	
	GameTooltip:SetOwner(frame, "ANCHOR_LEFT");
	frame.link = frame.link or select(2, GetItemInfo(frame.id) )
	
	if frame.link then
		GameTooltip:SetHyperlink(frame.link)
	else
		GameTooltip:SetHyperlink("item:"..frame.id..":0:0:0:0:0:0:0")	-- this line queries the server for an unknown id
		GameTooltip:ClearLines()	-- don't leave residual info in the tooltip after the server query
	end
	GameTooltip:Show()
end

function addon:Item_OnClick(frame, button)
	if button ~= "LeftButton" or not frame.id then return end
	
	local link = frame.link
	
	if not link then
		link = select(2, GetItemInfo(frame.id) )
	end
	if not link then return end		-- still not valid ? exit
	
	if IsControlKeyDown() then
		DressUpItemLink(link)
	elseif IsShiftKeyDown() then
		local chat = ChatEdit_GetLastActiveWindow()
	
		if chat:IsShown() then
			chat:Insert(link)
		else
			AltoholicFrame_SearchEditBox:SetText(GetItemInfo(link))
		end
	end
end

function addon:SetItemButtonTexture(button, texture, width, height)
	-- wrapper for SetItemButtonTexture from ItemButtonTemplate.lua
	width = width or 36
	height = height or 36

	local itemTexture = _G[button.."IconTexture"]
	
	itemTexture:SetWidth(width);
	itemTexture:SetHeight(height);
	itemTexture:SetAllPoints(_G[button]);
	
	SetItemButtonTexture(_G[button], texture)
end

local equipmentSlotIcons = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrists",
	"Hands",
	"Finger",
	"Finger",
	"Trinket",
	"Trinket",
	"Chest",
	"MainHand",
	"SecondaryHand",
	"Ranged",
	"Tabard"
}

function addon:GetEquipmentSlotIcon(index)
	if index and equipmentSlotIcons[index] then
		return "Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. equipmentSlotIcons[index]
	end
end

function addon:GetSpellIcon(spellID)
	return select(3, GetSpellInfo(spellID))
end

function addon:GetRecipeLink(spellID, profession, color)
	local name = GetSpellInfo(spellID) or ""
	color = color or "|cffffd000"
	return format("%s|Henchant:%s|h[%s: %s]|h|r", color, spellID, profession, name)
end

function addon:GetIDFromLink(link)
	if link then
		return tonumber(link:match("item:(%d+)"))
		
		-- local linktype, id = string.match(link, "|H([^:]+):(%d+)")
		-- if id then
			-- return tonumber(id)
		-- end
	end
end

-- copied to formatter service
function addon:GetMoneyString(copper, color, noTexture)
	copper = copper or 0
	color = color or colors.gold

	local gold = floor( copper / 10000 );
	copper = mod(copper, 10000)
	local silver = floor( copper / 100 );
	copper = mod(copper, 100)
	
	if noTexture then				-- use noTexture for places where the texture does not fit too well,  ex: tooltips
		copper = format("%s%s%s%s", color, copper, "|cFFEDA55F", COPPER_AMOUNT_SYMBOL)
		silver = format("%s%s%s%s", color, silver, "|cFFC7C7CF", SILVER_AMOUNT_SYMBOL)
		gold = format("%s%s%s%s", color, gold, colors.gold, GOLD_AMOUNT_SYMBOL)
	else
		copper = color..format(COPPER_AMOUNT_TEXTURE, copper, 13, 13)
		silver = color..format(SILVER_AMOUNT_TEXTURE, silver, 13, 13)
		gold = color..format(GOLD_AMOUNT_TEXTURE_STRING, BreakUpLargeNumbers(gold), 13, 13)
	end
	return format("%s %s %s", gold, silver, copper)
end

function addon:GetMoneyStringShort(copper, color, noTexture)
	-- the "short" version print only value that are > 0
	copper = copper or 0
	color = color or colors.gold

	local gold = floor(copper / 10000)
	copper = mod(copper, 10000)
	
	local silver = floor(copper / 100)
	copper = mod(copper, 100)
	
	local goldText, silverText, copperText
	
	if noTexture then				-- use noTexture for places where the texture does not fit too well,  ex: tooltips
		copperText = format("%s%s%s%s", color, copper, "|cFFEDA55F", COPPER_AMOUNT_SYMBOL)
		silverText = format("%s%s%s%s", color, silver, "|cFFC7C7CF", SILVER_AMOUNT_SYMBOL)
		goldText = format("%s%s%s%s", color, gold, colors.gold, GOLD_AMOUNT_SYMBOL)
	else
		copperText = color..format(COPPER_AMOUNT_TEXTURE, copper, 13, 13)
		silverText = color..format(SILVER_AMOUNT_TEXTURE, silver, 13, 13)
		goldText = color..format(GOLD_AMOUNT_TEXTURE_STRING, BreakUpLargeNumbers(gold), 13, 13)
	end
	
	if gold > 0 then
		return format("%s %s %s", goldText, silverText, copperText)
	elseif silver > 0 then
		return format("%s %s", silverText, copperText)
	else
		return format("%s", copperText)
	end
end

-- copied to formatter service
function addon:GetTimeString(seconds)
	seconds = seconds or 0

	local days = floor(seconds / 86400);				-- TotalTime is expressed in seconds
	seconds = mod(seconds, 86400)
	local hours = floor(seconds / 3600);
	seconds = mod(seconds, 3600)
	local minutes = floor(seconds / 60);
	seconds = mod(seconds, 60)

	return format("%s%s|rd %s%s|rh %s%s|rm", colors.white, days, colors.white, hours, colors.white, minutes)
end

-- copied to formatter service
function addon:FormatDelay(timeStamp)
	-- timeStamp = value when time() was last called for a given variable (ex: last time the mailbox was checked)
	if not timeStamp then
		return format("%s%s", colors.yellow, NEVER)
	end
	
	if timeStamp == 0 then
		return format("%sN/A", colors.yellow)
	end
	
	local seconds = (time() - timeStamp)
	
	-- 86400 seconds per day
	-- assuming 30 days / month = 2.592.000 seconds
	-- assuming 365 days / year = 31.536.000 seconds
	-- in the absence of possibility to track real dates, these approximations will have to do the trick, as it's not possible at this point to determine the number of days in a month, or in a year.

	local year = floor(seconds / 31536000)
	seconds = mod(seconds, 31536000)

	local month = floor(seconds / 2592000)
	seconds = mod(seconds, 2592000)

	local day = floor(seconds / 86400)
	seconds = mod(seconds, 86400)

	local hour = floor(seconds / 3600)
	seconds = mod(seconds, 3600)

	-- note: RecentTimeDate is not a direct API function, it's in UIParent.lua
	return RecentTimeDate(year, month, day, hour)
end

function addon:GetSuggestion(index, level)
	if addon.Suggestions[index] then 
		for _, v in pairs( addon.Suggestions[index] ) do
			if level < v[1] then		-- the suggestions are sorted by level, so whenever we're below, return the text
				return v[2]
			end
		end
	end
end

function addon:GetRecipeLevel(link, tooltip)
	-- if not tooltip then	-- if no tooltip is provided for scanning, let's make one
		-- tooltip = AltoTooltip
		
		-- tooltip:ClearLines();	
		-- tooltip:SetOwner(AltoholicFrame, "ANCHOR_LEFT");
		-- tooltip:SetHyperlink(link)
	-- end

	local tooltip = AltoScanningTooltip
	
	tooltip:ClearLines()
	tooltip:SetHyperlink(link)
	
	local tooltipName = tooltip:GetName()
	
	for i = tooltip:NumLines(), 2, -1 do			-- parse all tooltip lines, from last to second
		local tooltipText = _G[tooltipName .. "TextLeft" .. i]:GetText()
		if tooltipText then
			local _, _, rLevel = string.find(tooltipText, "%((%d+)%)") -- find number enclosed in brackets
			if rLevel then
				return tonumber(rLevel)
			end
		end
	end
end

function addon:ListCharsOnQuest(questName, player, tooltip)
	if not questName then return nil end

	local charsOnQuest = DataStore:GetCharactersOnQuest(questName, player)
	if charsOnQuest and #charsOnQuest > 0 then
		tooltip:AddLine(" ",1,1,1)
		tooltip:AddLine(format("%s%s", colors.green, L["Are also on this quest:"]))
		
		for _, character in pairs(charsOnQuest) do
			tooltip:AddLine(DataStore:GetColoredCharacterName(character))
		end
	end
end

function addon:UpdateSlider(frame, text, field)
	local name = frame:GetName()
	local value = frame:GetValue()

	_G[name .. "Text"]:SetText(format("%s (%d)", text, value))
	if addon.db and addon.db.global then 
		addon:SetOption(field, value)
		Minimap.AltoholicButton:Move()
	end
end

function addon:ShowWidgetTooltip(frame)
	if not frame.tooltip then return end
	
	AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
	AltoTooltip:ClearLines();
	AltoTooltip:AddLine(frame.tooltip)
	AltoTooltip:Show(); 
end

function addon:OnTimeToNextWarningChanged(frame)
	local name = frame:GetName()
	local timeToNext = frame:GetValue()

	_G[name .. "Text"]:SetText(format("%s (%s)", L["TIME_TO_NEXT_WARNING_TEXT"], format(D_HOURS, timeToNext)))
	addon:SetOption("UI.Mail.TimeToNextWarning", timeToNext)
end

function addon:DDM_Initialize(frame, func)
	-- This should be used instead of UIDropDownMenu_Initialize, which causes tainting.
	frame.displayMode = "MENU" 
	frame.initialize = func
end

local ICON_PATH = "Interface\\Addons\\Altoholic_Summary\\Textures\\"
local ICON_CHARACTERS_ALLIANCE = ICON_PATH .. "Achievement_Character_Gnome_Female"
local ICON_CHARACTERS_HORDE = ICON_PATH .. "Achievement_Character_Orc_Male"
-- mini Easter egg icons, if you read the code using these, please don't spoil it :)

local ICON_CHARACTERS_HALLOWSEND_ALLIANCE = ICON_PATH .. "INV_Mask_06"
local ICON_CHARACTERS_HALLOWSEND_HORDE = ICON_PATH .. "INV_Mask_03"
local ICON_CHARACTERS_DOTD_ALLIANCE = ICON_PATH .. "INV_Misc_Bone_HumanSkull_02"
local ICON_CHARACTERS_DOTD_HORDE = ICON_PATH .. "INV_Misc_Bone_OrcSkull_01"

function addon:GetCharacterIcon()
	local faction = UnitFactionGroup("player")
	local isAlliance = (faction == "Alliance")
	local icon = isAlliance and ICON_CHARACTERS_ALLIANCE or ICON_CHARACTERS_HORDE
	local day = (tonumber(date("%m")) * 100) + tonumber(date("%d"))	-- ex: dec 15 = 1215, for easy tests below
	

	if (day >= 1018) and (day <= 1031) then		-- hallow's end
		icon = isAlliance and ICON_CHARACTERS_HALLOWSEND_ALLIANCE or ICON_CHARACTERS_HALLOWSEND_HORDE
	elseif (day >= 1101) and (day <= 1102) then		-- day of the dead
		icon = isAlliance and ICON_CHARACTERS_DOTD_ALLIANCE or ICON_CHARACTERS_DOTD_HORDE
	end
	
	return icon
end


-- ** Calendar stuff **
local calendarFirstWeekday = 1
-- 1 = Sunday, recreated locally to avoid the problem caused by the calendar addon not being loaded at startup.
-- On an EU client, CALENDAR_FIRST_WEEKDAY = 1 when the game is loaded, but becomes 2 as soon as the calendar is launched.
-- So default it to 1, and add an option to select Monday as 1st day of the week instead. If need be, use a slider.
-- Although the calendar is LoD, avoid it.

function addon:SetFirstDayOfWeek(day)
	calendarFirstWeekday = day
end

function addon:GetFirstDayOfWeek()
	return calendarFirstWeekday
end

-- ** Unsafe Items **
function addon:SaveUnsafeItem(itemID)
	if not addon:IsItemUnsafe(itemID) then			-- if the item is not a known unsafe item, save it in the db
		table.insert(Altoholic.db.global.unsafeItems, itemID)
	end
end

function addon:IsItemUnsafe(itemID)
	for _, v in pairs(Altoholic.db.global.unsafeItems) do 	-- browse current realm's unsafe item list
		if v == itemID then		-- if the itemID passed as parameter is a known unsafe item .. return true to skip it
			return true
		end
	end
end


-- ** Equipment ** 
-- 02/09/2012 : Global to the add-on, should be loaded in the core, ideally code should be in its own file. This will happen later.

addon.Equipment = {}

local ns = addon.Equipment		-- ns = namespace

-- These two tables are necessary to find equivalences between INVTYPEs returned by GetItemInfo and the actual equipment slots.
-- For instance, the "ranged" slot can contain bows/guns/wands/relics/thrown weapons.
local inventoryTypes = {
	["INVTYPE_HEAD"] = 1,		-- 1 means first entry in the EquipmentSlots table (just below this one)
	["INVTYPE_SHOULDER"] = 2,
	["INVTYPE_CHEST"] = 3,
	["INVTYPE_ROBE"] = 3,
	["INVTYPE_WRIST"] = 4,
	["INVTYPE_HAND"] = 5,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	
	["INVTYPE_NECK"] = 9,
	["INVTYPE_CLOAK"] = 10,
	["INVTYPE_FINGER"] = 11,
	["INVTYPE_TRINKET"] = 12,
	["INVTYPE_WEAPON"] = 13,
	["INVTYPE_2HWEAPON"] = 14,
	["INVTYPE_WEAPONMAINHAND"] = 15,
	["INVTYPE_WEAPONOFFHAND"] = 16,
	["INVTYPE_HOLDABLE"] = 16,
	["INVTYPE_SHIELD"] = 17,
	["INVTYPE_RANGED"] = 18,
	["INVTYPE_THROWN"] = 18,
	["INVTYPE_RANGEDRIGHT"] = 18,
	["INVTYPE_RELIC"] = 18
}

local slotNames = {
	[1] = INVTYPE_HEAD,
	[2] = INVTYPE_SHOULDER,
	[3] = INVTYPE_CHEST,
	[4] = INVTYPE_WRIST,
	[5] = INVTYPE_HAND,
	[6] = INVTYPE_WAIST,
	[7] = INVTYPE_LEGS,
	[8] = INVTYPE_FEET,
	[9] = INVTYPE_NECK,
	[10] = INVTYPE_CLOAK,
	[11] = INVTYPE_FINGER,
	[12] = INVTYPE_TRINKET,
	[13] = INVTYPE_WEAPON,
	[14] = INVTYPE_2HWEAPON,
	[15] = INVTYPE_WEAPONMAINHAND,
	[16] = INVTYPE_WEAPONOFFHAND,
	[17] = INVTYPE_SHIELD,
	[18] = INVTYPE_RANGED
}

local slotTypeInfo = {
	{ color = colors.classMage, name = INVTYPE_HEAD },
	{ color = colors.classHunter, name = INVTYPE_NECK },
	{ color = colors.classMage, name = INVTYPE_SHOULDER },
	{ color = colors.white, name = INVTYPE_BODY },
	{ color = colors.classMage, name = INVTYPE_CHEST },
	{ color = colors.classMage, name = INVTYPE_WAIST },
	{ color = colors.classMage, name = INVTYPE_LEGS },
	{ color = colors.classMage, name = INVTYPE_FEET },
	{ color = colors.classMage, name = INVTYPE_WRIST },
	{ color = colors.classMage, name = INVTYPE_HAND },
	{ color = colors.orange, name = INVTYPE_FINGER .. " 1" },
	{ color = colors.orange, name = INVTYPE_FINGER .. " 2" },
	{ color = colors.orange, name = INVTYPE_TRINKET .. " 1" },
	{ color = colors.orange, name = INVTYPE_TRINKET .. " 2" },
	{ color = colors.classHunter, name = INVTYPE_CLOAK },
	{ color = colors.yellow, name = INVTYPE_WEAPONMAINHAND },
	{ color = colors.yellow, name = INVTYPE_WEAPONOFFHAND },
	{ color = colors.classHunter, name = INVTYPE_RANGED },
	{ color = colors.white, name = INVTYPE_TABARD }
}

function ns:GetSlotName(slot)
	return slotNames[slot]
end

function ns:GetNumSlotTypes()
	return #slotTypeInfo
end

function ns:GetSlotTypeInfo(index)
	local item = slotTypeInfo[index]
	return item.name, item.color
end

function ns:GetInventoryTypeIndex(inv)
	return inventoryTypes[inv]
end

function ns:GetInventoryTypeName(inv)
	return slotNames[ inventoryTypes[inv] ]
end
