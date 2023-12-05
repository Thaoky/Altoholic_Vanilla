local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local OPTION_REALMS = "UI.Tabs.Summary.CurrentRealms"
local OPTION_FACTIONS = "UI.Tabs.Summary.CurrentFactions"
local OPTION_LEVELS = "UI.Tabs.Summary.CurrentLevels"
local OPTION_LEVELS_MIN = "UI.Tabs.Summary.CurrentLevelsMin"
local OPTION_LEVELS_MAX = "UI.Tabs.Summary.CurrentLevelsMax"
local OPTION_CLASSES = "UI.Tabs.Summary.CurrentClasses"
local OPTION_TRADESKILL = "UI.Tabs.Summary.CurrentTradeSkill"

-- ** Icon events **

local function OnRealmFilterChange(frame)
	addon:SetOption(OPTION_REALMS, frame.value)
	addon.Characters:InvalidateView()
	addon.Summary:Update()
end

local function OnFactionFilterChange(frame)
	addon:SetOption(OPTION_FACTIONS, frame.value)
	addon.Characters:InvalidateView()
	addon.Summary:Update()
end

local function OnLevelFilterChange(frame, minLevel, maxLevel)
	addon:SetOption(OPTION_LEVELS, frame.value)
	addon:SetOption(OPTION_LEVELS_MIN, minLevel)
	addon:SetOption(OPTION_LEVELS_MAX, maxLevel)
	addon.Characters:InvalidateView()
	addon.Summary:Update()
end

local function OnTradeSkillFilterChange(frame)
	frame:GetParent():Close()

	addon:SetOption(OPTION_TRADESKILL, frame.value)
	addon.Characters:InvalidateView()
	addon.Summary:Update()
end

local function OnClassFilterChange(frame)
	addon:SetOption(OPTION_CLASSES, frame.value)
	addon.Characters:InvalidateView()
	addon.Summary:Update()
end

local function ShowOptionsCategory(self)
	addon:ToggleUI()
	InterfaceOptionsFrame_OpenToCategory(self.value)
end

local function ResetAllData_MsgBox_Handler(self, button)
	if not button then return end
	
	DataStore:ClearAllData()
	addon:Print(L["Information saved in DataStore has been completely deleted !"])
	
	-- rebuild the main character table, and all the menus
	addon.Characters:InvalidateView()
	addon.Summary:Update()
end

local function ResetAllData()
	-- reset all data stored in datastore modules
	AltoMessageBox:SetHandler(ResetAllData_MsgBox_Handler)
	AltoMessageBox:SetText(L["WIPE_DATABASE"])
	AltoMessageBox:Show()
end

-- ** Menu Icons **

local locationLabels = {
	format("%s %s(%s)", L["This realm"], colors.green, L["This account"]),
	format("%s %s(%s)", L["This realm"], colors.green, L["All accounts"]),
	format("%s %s(%s)", L["All realms"], colors.green, L["This account"]),
	format("%s %s(%s)", L["All realms"], colors.green, L["All accounts"]),
}

local function RealmsIcon_Initialize(frame, level)
	frame:AddTitle(L["FILTER_REALMS"])
	local option = addon:GetOption(OPTION_REALMS)

	-- add specific account/realm filters
	for key, text in ipairs(locationLabels) do
		frame:AddButton(text, key, OnRealmFilterChange, nil, (key == option))
	end
	frame:AddCloseMenu()
end

local function FactionIcon_Initialize(frame, level)
	local option = addon:GetOption(OPTION_FACTIONS)

	frame:AddTitle(L["FILTER_FACTIONS"])
	frame:AddButton(FACTION_ALLIANCE, 1, OnFactionFilterChange, nil, (option == 1))
	frame:AddButton(FACTION_HORDE, 2, OnFactionFilterChange, nil, (option == 2))
	frame:AddButton(L["Both factions"], 3, OnFactionFilterChange, nil, (option == 3))
	frame:AddButton(L["This faction"], 4, OnFactionFilterChange, nil, (option == 4))
	frame:AddCloseMenu()
end

local function LevelIcon_Initialize(frame, level)
	local option = addon:GetOption(OPTION_LEVELS)
	
	frame:AddTitle(L["FILTER_LEVELS"])
	frame:AddButtonWithArgs(ALL, 1, OnLevelFilterChange, 1, 60, (option == 1))
	frame:AddTitle()
	frame:AddButtonWithArgs("1-59", 2, OnLevelFilterChange, 1, 59, (option == 2))
	frame:AddButtonWithArgs("1-39", 3, OnLevelFilterChange, 1, 39, (option == 3))
	frame:AddButtonWithArgs("40-59", 4, OnLevelFilterChange, 40, 59, (option == 4))
	frame:AddButtonWithArgs("60", 5, OnLevelFilterChange, 60, 60, (option == 5))
	frame:AddCloseMenu()
end

local function ProfessionsIcon_Initialize(frame, level)
	if not level then return end

	local tradeskills = addon.TradeSkills.AccountSummaryFiltersSpellIDs
	local option = addon:GetOption(OPTION_TRADESKILL)
	
	if level == 1 then
		frame:AddTitle(L["FILTER_PROFESSIONS"])
		frame:AddButton(ALL, 0, OnTradeSkillFilterChange, nil, (option == 0))
		frame:AddTitle()
		frame:AddCategoryButton(PRIMARY_SKILLS, 1, level)
		frame:AddCategoryButton(SECONDARY_SKILLS, 2, level)
		frame:AddCloseMenu()
	
	elseif level == 2 then
		local spell, icon, _
		local firstSecondarySkill = addon.TradeSkills.AccountSummaryFirstSecondarySkillIndex
	
		if frame:GetCurrentOpenMenuValue() == 1 then				-- Primary professions
			for i = 1, (firstSecondarySkill - 1) do
				spell, _, icon = GetSpellInfo(tradeskills[i])
				frame:AddButton(spell, i, OnTradeSkillFilterChange, icon, (option == i), level)
			end
		
		elseif frame:GetCurrentOpenMenuValue() == 2 then		-- Secondary professions
			for i = firstSecondarySkill, #tradeskills do
				spell, _, icon = GetSpellInfo(tradeskills[i])
				
				frame:AddButton(spell, i, OnTradeSkillFilterChange, icon, (option == i), level)
			end
		end
	end
end

local function ClassIcon_Initialize(frame, level)
	local option = addon:GetOption(OPTION_CLASSES)
	
	frame:AddTitle(L["FILTER_CLASSES"])
	frame:AddButton(ALL, 0, OnClassFilterChange, nil, (option == 0))
	frame:AddTitle()
	
	-- See constants.lua
	for key, value in ipairs(CLASS_SORT_ORDER) do
		frame:AddButton(
			format("|c%s%s", RAID_CLASS_COLORS[value].colorStr, LOCALIZED_CLASS_NAMES_MALE[value]), 
			key, OnClassFilterChange, nil, (option == key)
		)
	end
	frame:AddCloseMenu()
end

local function AltoholicOptionsIcon_Initialize(frame, level)
	frame:AddTitle(format("%s: %s", GAMEOPTIONS_MENU, addonName))

	frame:AddButton(GENERAL, AltoholicGeneralOptions, ShowOptionsCategory)
	frame:AddButton(L["Calendar"], AltoholicCalendarOptions, ShowOptionsCategory)
	frame:AddButton(MAIL_LABEL, AltoholicMailOptions, ShowOptionsCategory)
	frame:AddButton(MISCELLANEOUS, AltoholicMiscOptions, ShowOptionsCategory)
	frame:AddButton(SEARCH, AltoholicSearchOptions, ShowOptionsCategory)
	frame:AddButton(L["Tooltip"], AltoholicTooltipOptions, ShowOptionsCategory)
	
	frame:AddTitle()
	frame:AddTitle(OTHER)	
	frame:AddButton("What's new?", AltoholicWhatsNew, ShowOptionsCategory)
	frame:AddButton("Getting support", AltoholicSupport, ShowOptionsCategory)
	frame:AddButton(L["Memory used"], AltoholicMemoryOptions, ShowOptionsCategory)
	frame:AddButton(HELP_LABEL, AltoholicHelp, ShowOptionsCategory)
	frame:AddCloseMenu()
end

local addonList = {
	"DataStore_Auctions",
	"DataStore_Characters",
	"DataStore_Inventory",
	"DataStore_Mails",
	"DataStore_Quests",
}

local function DataStoreOptionsIcon_Initialize(frame, level)
	frame:AddTitle(format("%s: %s", GAMEOPTIONS_MENU, "DataStore"))
	
	for _, module in ipairs(addonList) do
		if _G[module] then	-- only add loaded modules
			frame:AddButton(module, module, ShowOptionsCategory)
		end
	end
	
	frame:AddTitle()
	frame:AddButton(L["Reset all data"], nil, ResetAllData)
	frame:AddButton(HELP_LABEL, DataStoreHelp, ShowOptionsCategory)
	frame:AddCloseMenu()
end

local menuIconCallbacks = {
	RealmsIcon_Initialize,
	FactionIcon_Initialize,
	LevelIcon_Initialize,
	ProfessionsIcon_Initialize,
	ClassIcon_Initialize,
	AltoholicOptionsIcon_Initialize,
	DataStoreOptionsIcon_Initialize,
}

addon:Controller("AltoholicUI.TabSummaryIcon", {
	Icon_OnEnter = function(frame)
		local currentMenuID = frame:GetID()
		
		local menu = frame:GetParent().ContextualMenu
		
		menu:Initialize(menuIconCallbacks[currentMenuID], "LIST")
		menu:Close()
		menu:Toggle(frame, 0, 0)
	end,
})
