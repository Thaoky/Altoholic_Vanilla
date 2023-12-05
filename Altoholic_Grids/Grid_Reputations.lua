local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- *** Reputations ***
local Factions = {
	-- Factions reference table, based on http://www.wowwiki.com/Factions
	{	-- [1]
		name = EXPANSION_NAME0,	-- "Classic"
		{	-- [1]
			name = FACTION_ALLIANCE,	-- 469
			{ name = DataStore:GetFactionName(69), icon = "Achievement_Character_Nightelf_Female" },	-- "Darnassus"
			{ name = DataStore:GetFactionName(54), icon = "INV_Misc_Head_Gnome_02" },	-- "Gnomeregan"
			{ name = DataStore:GetFactionName(47), icon = "Achievement_Character_Dwarf_Male" },		-- "Ironforge"
			{ name = DataStore:GetFactionName(72), icon = "INV_Misc_Head_Human_01" },		-- "Stormwind"
		},
		{	-- [2]
			name = FACTION_HORDE,
			{ name = DataStore:GetFactionName(530), icon = "Achievement_Character_Troll_Male" },		-- "Darkspear Trolls"
			{ name = DataStore:GetFactionName(76), icon = "INV_Misc_Head_Orc_01" },		-- "Orgrimmar"
			{ name = DataStore:GetFactionName(81), icon = "INV_Misc_Head_Tauren_01" },		-- "Thunder Bluff"
			{ name = DataStore:GetFactionName(68), icon = "INV_Misc_Head_Undead_02" },		-- "Undercity"
		},
		{	-- [3]
			name = L["Alliance Forces"],	-- 891
			{ name = DataStore:GetFactionName(509), icon = "inv_jewelry_talisman_05" },	--  name = "The League of Arathor" 
			{ name = DataStore:GetFactionName(890), icon = "inv_banner_03" },	-- "Silverwing Sentinels" 
			{ name = DataStore:GetFactionName(730), icon = "inv_jewelry_necklace_21" },		-- "Stormpike Guard"
		},
		{	-- [4]
			name = L["Horde Forces"],
			{ name = DataStore:GetFactionName(510), icon = "inv_jewelry_talisman_05" },		-- "The Defilers" 
			{ name = DataStore:GetFactionName(889), icon = "inv_banner_03" },	-- "Warsong Outriders" 
			{ name = DataStore:GetFactionName(729), icon = "inv_jewelry_necklace_21" },		-- "Frostwolf Clan" 
		},
		{	-- [5]
			name = L["Steamwheedle Cartel"],
			{ name = DataStore:GetFactionName(21), icon = "inv_helmet_66" },		-- "Booty Bay" 
			{ name = DataStore:GetFactionName(577), icon = "inv_helmet_66" },		-- "Everlook" 
			{ name = DataStore:GetFactionName(369), icon = "inv_helmet_66" },		-- "Gadgetzan" 
			{ name = DataStore:GetFactionName(470), icon = "inv_helmet_66" },		-- "Ratchet" 
		},
		{	-- [6]
			name = OTHER,
			{ name = DataStore:GetFactionName(529), icon = "INV_Jewelry_Talisman_07" },		-- "Argent Dawn" 
			{ name = DataStore:GetFactionName(87), icon = "INV_Helmet_66" },		-- "Bloodsail Buccaneers" 
			{ name = DataStore:GetFactionName(910), icon = "INV_Misc_Head_Dragon_Bronze" },		-- "Brood of Nozdormu" 
			{ name = DataStore:GetFactionName(609), icon = "INV_Scarab_Gold" },		-- "Cenarion Circle" 
			{ name = DataStore:GetFactionName(909), icon = "INV_Misc_Ticket_Darkmoon_01" },		-- "Darkmoon Faire" 
			{ name = DataStore:GetFactionName(92), icon = "INV_Misc_Head_Centaur_01" },			-- "Gelkis Clan Centaur" 
			{ name = DataStore:GetFactionName(749), icon = "inv_potion_83" },		-- "Hydraxian Waterlords" 
			{ name = DataStore:GetFactionName(93), icon = "INV_Misc_Head_Centaur_01" },		-- "Magram Clan Centaur" 
			{ name = DataStore:GetFactionName(349), icon = "INV_ThrowingKnife_04" },		-- "Ravenholdt" 
			{ name = DataStore:GetFactionName(809), icon = "inv_misc_book_11" },		-- "Shen'dralar" 
			{ name = DataStore:GetFactionName(70), icon = "INV_Misc_ArmorKit_03" },		-- "Syndicate" 
			{ name = DataStore:GetFactionName(59), icon = "INV_Ingot_Thorium" },		-- "Thorium Brotherhood" 
			{ name = DataStore:GetFactionName(576), icon = "inv_misc_horn_01" },		-- "Timbermaw Hold" 
			{ name = DataStore:GetFactionName(471), icon = "INV_Misc_Head_Dwarf_01" },		-- "Wildhammer Clan" 
			{ name = DataStore:GetFactionName(589), icon = "Ability_Mount_PinkTiger" },		-- "Wintersaber Trainers" 
			{ name = DataStore:GetFactionName(270), icon = "INV_Bijou_Green" },		-- "Zandalar Tribe" 
		}
	},
}

local CAT_ALLINONE = #Factions + 1

local VertexColors = {
	[FACTION_STANDING_LABEL1] = { r = 0.4, g = 0.13, b = 0.13 },	-- hated
	[FACTION_STANDING_LABEL2] = { r = 0.5, g = 0.0, b = 0.0 },		-- hostile
	[FACTION_STANDING_LABEL3] = { r = 0.6, g = 0.4, b = 0.13 },		-- unfriendly
	[FACTION_STANDING_LABEL4] = { r = 0.6, g = 0.6, b = 0.0 },		-- neutral
	[FACTION_STANDING_LABEL5] = { r = 0.0, g = 0.6, b = 0.0 },		-- friendly
	[FACTION_STANDING_LABEL6] = { r = 0.0, g = 0.6, b = 0.6 },		-- honored
	[FACTION_STANDING_LABEL7] = { r = 0.9, g = 0.3, b = 0.9 },		-- revered
	[FACTION_STANDING_LABEL8] = { r = 1.0, g = 1.0, b = 1.0 },		-- exalted
}

local view
local isViewValid

local OPTION_XPACK = "UI.Tabs.Grids.Reputations.CurrentXPack"
local OPTION_FACTION = "UI.Tabs.Grids.Reputations.CurrentFactionGroup"

local currentFaction
local currentDDMText
local dropDownFrame

local function BuildView()
	view = view or {}
	wipe(view)
	
	local currentXPack = addon:GetOption(OPTION_XPACK)
	local currentFactionGroup = addon:GetOption(OPTION_FACTION)

	if (currentXPack ~= CAT_ALLINONE) then
		for index, faction in ipairs(Factions[currentXPack][currentFactionGroup]) do
			table.insert(view, faction)	-- insert the table pointer
		end
	else	-- all in one, add all factions
		for xPackIndex, xpack in ipairs(Factions) do		-- all xpacks
			for factionGroupIndex, factionGroup in ipairs(xpack) do 	-- all faction groups
				for index, faction in ipairs(factionGroup) do
					table.insert(view, faction)	-- insert the table pointer
				end
			end
		end
		
		table.sort(view, function(a,b) 	-- sort all factions alphabetically
			if not a.name then
				DEFAULT_CHAT_FRAME:AddMessage(a.icon)
			end
			if not b.name then
				DEFAULT_CHAT_FRAME:AddMessage(b.icon)
			end
			
			return a.name < b.name
		end)
	end
	
	isViewValid = true
end

local function OnFactionChange(self, xpackIndex, factionGroupIndex)
	dropDownFrame:Close()

	addon:SetOption(OPTION_XPACK, xpackIndex)
	addon:SetOption(OPTION_FACTION, factionGroupIndex)
		
	local factionGroup = Factions[xpackIndex][factionGroupIndex]
	currentDDMText = factionGroup.name
	AltoholicTabGrids:SetViewDDMText(currentDDMText)
	
	isViewValid = nil
	AltoholicTabGrids:Update()
end

local function OnAllInOneSelected(self)
	dropDownFrame:Close()
	addon:SetOption(OPTION_XPACK, CAT_ALLINONE)
	addon:SetOption(OPTION_FACTION, 1)
	
	currentDDMText = L["All-in-one"]
	AltoholicTabGrids:SetViewDDMText(currentDDMText)
	isViewValid = nil
	AltoholicTabGrids:Update()
end

local function DropDown_Initialize(frame, level)
	if not level then return end

	local info = frame:CreateInfo()
	
	local currentXPack = addon:GetOption(OPTION_XPACK)
	local currentFactionGroup = addon:GetOption(OPTION_FACTION)
	
	if level == 1 then
		for xpackIndex = 1, (CAT_ALLINONE - 1) do
			info.text = Factions[xpackIndex].name
			info.hasArrow = 1
			info.checked = (currentXPack == xpackIndex)
			info.value = xpackIndex
			frame:AddButtonInfo(info, level)
		end
		
		info.text = L["All-in-one"]
		info.hasArrow = nil
		info.func = OnAllInOneSelected
		info.checked = (currentXPack == CAT_ALLINONE)
		frame:AddButtonInfo(info, level)
		
		frame:AddCloseMenu()
	
	elseif level == 2 then
		local menuValue = frame:GetCurrentOpenMenuValue()
		
		for factionGroupIndex, factionGroup in ipairs(Factions[menuValue]) do
			info.text = factionGroup.name
			info.func = OnFactionChange
			info.checked = ((currentXPack == menuValue) and (currentFactionGroup == factionGroupIndex))
			info.arg1 = menuValue
			info.arg2 = factionGroupIndex
			frame:AddButtonInfo(info, level)
		end
	end
end

local callbacks = {
	OnUpdate = function() 
			if not isViewValid then
				BuildView()
			end

			local currentXPack = addon:GetOption(OPTION_XPACK)
			local currentFactionGroup = addon:GetOption(OPTION_FACTION)
			
			if (currentXPack == CAT_ALLINONE) then
				AltoholicTabGrids:SetStatus(L["All-in-one"])
			else
				AltoholicTabGrids:SetStatus(format("%s / %s", Factions[currentXPack].name, Factions[currentXPack][currentFactionGroup].name))
			end
		end,
	GetSize = function() return #view end,
	RowSetup = function(self, rowFrame, dataRowID)
			currentFaction = view[dataRowID]

			rowFrame.Name.Text:SetText(colors.white .. currentFaction.name)
			rowFrame.Name.Text:SetJustifyH("LEFT")
		end,
	RowOnEnter = function()	end,
	RowOnLeave = function() end,
	ColumnSetup = function(self, button, dataRowID, character)
			local faction = currentFaction
			
			if faction.left then		-- if it's not a full texture, use tcoords
				button.Background:SetTexture(faction.icon)
				button.Background:SetTexCoord(faction.left, faction.right, faction.top, faction.bottom)
			else
				button.Background:SetTexture("Interface\\Icons\\"..faction.icon)
				button.Background:SetTexCoord(0, 1, 0, 1)
			end		
			
			button.Name:SetFontObject("GameFontNormalSmall")
			button.Name:SetJustifyH("CENTER")
			button.Name:SetPoint("BOTTOMRIGHT", 5, 0)
			button.Background:SetDesaturated(false)
			
			local status, _, _, rate = DataStore:GetReputationInfo(character, faction.name)
			if status and rate then 
				local text
				if status == FACTION_STANDING_LABEL8 then
					text = icons.ready
				else
					button.Background:SetDesaturated(true)
					button.Name:SetFontObject("NumberFontNormalSmall")
					button.Name:SetJustifyH("RIGHT")
					button.Name:SetPoint("BOTTOMRIGHT", 0, 0)
					text = format("%2d", floor(rate)) .. "%"
				end

				local vc = VertexColors[status]
				button.Background:SetVertexColor(vc.r, vc.g, vc.b);
				
				local color = colors.white
				if status == FACTION_STANDING_LABEL1 or status == FACTION_STANDING_LABEL2 then
					color = colors.darkred
				end

				button.key = character
				button:SetID(dataRowID)
				button.Name:SetText(color..text)
			else
				button.Background:SetVertexColor(0.3, 0.3, 0.3);	-- greyed out
				button.Name:SetText(icons.notReady)
				button:SetID(0)
				button.key = nil
			end
		end,
		
	OnEnter = function(frame) 
			local character = frame.key
			if not character then return end

			local faction = view[ frame:GetID() ].name
			local status, currentLevel, maxLevel, rate = DataStore:GetReputationInfo(character, faction)
			if not status then return end
			
			AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
			AltoTooltip:ClearLines();
			AltoTooltip:AddLine(DataStore:GetColoredCharacterName(character) .. colors.white .. " @ " ..	colors.teal .. faction,1,1,1);

			rate = format("%d", floor(rate)) .. "%"
			AltoTooltip:AddLine(format("%s: %d/%d (%s)", status, currentLevel, maxLevel, rate),1,1,1 )
						
			local bottom = DataStore:GetRawReputationInfo(character, faction)
			
			AltoTooltip:AddLine(" ",1,1,1)
			AltoTooltip:AddLine(format("%s = %s", icons.notReady, UNKNOWN), 0.8, 0.13, 0.13)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL1, 0.8, 0.13, 0.13)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL2, 1.0, 0.0, 0.0)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL3, 0.93, 0.4, 0.13)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL4, 1.0, 1.0, 0.0)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL5, 0.0, 1.0, 0.0)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL6, 0.0, 1.0, 0.8)
			AltoTooltip:AddLine(FACTION_STANDING_LABEL7, 1.0, 0.4, 1.0)
			AltoTooltip:AddLine(format("%s = %s", icons.ready, FACTION_STANDING_LABEL8), 1, 1, 1)
			AltoTooltip:Show()
		end,
	OnClick = function(frame, button)
			local character = frame.key
			if not character then return end

			local faction = view[ frame:GetParent():GetID() ].name
			local status, currentLevel, maxLevel, rate = DataStore:GetReputationInfo(character, faction)
			if not status then return end
			
			if ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
				local chat = ChatEdit_GetLastActiveWindow()
				if chat:IsShown() then
					chat:Insert(format(L["%s is %s with %s (%d/%d)"], DataStore:GetCharacterName(character), status, faction, currentLevel, maxLevel))
				end
			end
		end,
	OnLeave = function(self)
			AltoTooltip:Hide() 
		end,
	InitViewDDM = function(frame, title)
			dropDownFrame = frame
			frame:Show()
			title:Show()

			local currentXPack = addon:GetOption(OPTION_XPACK)
			local currentFactionGroup = addon:GetOption(OPTION_FACTION)
			
			if (currentXPack ~= CAT_ALLINONE) then
				currentDDMText = Factions[currentXPack][currentFactionGroup].name
			else
				currentDDMText = L["All-in-one"]
			end
			
			frame:SetMenuWidth(100) 
			frame:SetButtonWidth(20)
			frame:SetText(currentDDMText)
			frame:Initialize(DropDown_Initialize, "MENU_NO_BORDERS")
		end,
}

AltoholicTabGrids:RegisterGrid(2, callbacks)
