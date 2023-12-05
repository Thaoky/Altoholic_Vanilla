local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- *** Dungeons ***
local Dungeons = {
	{	-- [1]
		name = EXPANSION_NAME0,	-- "Classic"
		{	-- [1] 10 player raids
			name = format("%s - 10 Players", RAIDS),
			{ id = 160, achID = 689 },	-- Ahn'Qiraj Ruins
		},
		{	-- [2] 40 player raids
			name = format("%s - 40 Players", RAIDS),
			{ id = 48, achID = 686 },	-- Molten Core
			{ id = 50, achID = 685 },	-- Blackwing Lair
			{ id = 161, achID = 687 },	-- Ahn'Qiraj Temple
		},
	},
}

local view
local isViewValid

local OPTION_XPACK = "UI.Tabs.Grids.Dungeons.CurrentXPack"
local OPTION_RAIDS = "UI.Tabs.Grids.Dungeons.CurrentRaids"

local currentDDMText
local currentTexture
local dropDownFrame

local function BuildView()
	view = view or {}
	wipe(view)
	
	local currentXPack = addon:GetOption(OPTION_XPACK)
	local currentRaids = addon:GetOption(OPTION_RAIDS)

	for index, raidList in ipairs(Dungeons[currentXPack][currentRaids]) do
		table.insert(view, raidList)	-- insert the table pointer
	end
	
	isViewValid = true
end

local function OnRaidListChange(self, xpackIndex, raidListIndex)
	dropDownFrame:Close()

	addon:SetOption(OPTION_XPACK, xpackIndex)
	addon:SetOption(OPTION_RAIDS, raidListIndex)
		
	local raidList = Dungeons[xpackIndex][raidListIndex]
	currentDDMText = raidList.name
	AltoholicTabGrids:SetViewDDMText(currentDDMText)
	
	isViewValid = nil
	AltoholicTabGrids:Update()
end

local function DropDown_Initialize(frame, level)
	if not level then return end

	local info = frame:CreateInfo()
	
	local currentXPack = addon:GetOption(OPTION_XPACK)
	local currentRaids = addon:GetOption(OPTION_RAIDS)
	
	if level == 1 then
		for xpackIndex = 1, #Dungeons do
			info.text = Dungeons[xpackIndex].name
			info.hasArrow = 1
			info.checked = (currentXPack == xpackIndex)
			info.value = xpackIndex
			frame:AddButtonInfo(info, level)
		end
		frame:AddCloseMenu()
	
	elseif level == 2 then
		local menuValue = frame:GetCurrentOpenMenuValue()
		
		for raidListIndex, raidList in ipairs(Dungeons[menuValue]) do
			info.text = raidList.name
			info.func = OnRaidListChange
			info.checked = ((currentXPack == menuValue) and (currentRaids == raidListIndex))
			info.arg1 = menuValue
			info.arg2 = raidListIndex
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
			local currentRaids = addon:GetOption(OPTION_RAIDS)
			
			AltoholicTabGrids:SetStatus(format("%s / %s", Dungeons[currentXPack].name, Dungeons[currentXPack][currentRaids].name))
		end,
	GetSize = function() return #view end,
	RowSetup = function(self, rowFrame, dataRowID)
			local dungeonID = view[dataRowID].id

			rowFrame.Name.Text:SetText(colors.white .. GetLFGDungeonInfo(dungeonID))
			rowFrame.Name.Text:SetJustifyH("LEFT")
		end,
	RowOnEnter = function()	end,
	RowOnLeave = function() end,
	ColumnSetup = function(self, button, dataRowID, character)
			local _, _, _, _, _, _, _, _, _, achImage = GetAchievementInfo(view[dataRowID].achID)
			button.Background:SetTexture(achImage)
			button.Background:SetTexCoord(0, 1, 0, 1)
			button.Background:SetDesaturated(false)
			
			local dungeonID = view[dataRowID].id
			local count = DataStore:GetLFGDungeonKillCount(character, dungeonID)
			
			if count > 0 then 
				button.Background:SetVertexColor(1.0, 1.0, 1.0)
				button.key = character
				button:SetID(dungeonID)

				button.Name:SetJustifyH("CENTER")
				button.Name:SetPoint("BOTTOMRIGHT", 3, 2)
				button.Name:SetFontObject("NumberFontNormalLarge")

				if view[dataRowID].bosses then
					button.Name:SetText(colors.green..format("%s/%s", count, view[dataRowID].bosses))
				else
					button.Name:SetText(colors.green..format("%s/%s", count, GetLFGDungeonNumEncounters(view[dataRowID].id)))
				end
				
				-- button.Name:SetText(colors.green..count)
			else
				button.Background:SetVertexColor(0.3, 0.3, 0.3)		-- greyed out
				button.Name:SetJustifyH("CENTER")
				button.Name:SetPoint("BOTTOMRIGHT", 5, 0)
				button.Name:SetFontObject("GameFontNormalSmall")
				button.Name:SetText(icons.notReady)
				button:SetID(0)
				button.key = nil
			end
		end,
		
	OnEnter = function(frame) 
			local character = frame.key
			if not character then return end

			local dungeonID = frame:GetID()
			local dungeonName, _, _, _, _, _, _, _, _, _, _, difficulty = GetLFGDungeonInfo(dungeonID)
			
			AltoTooltip:SetOwner(frame, "ANCHOR_LEFT")
			AltoTooltip:ClearLines()
			AltoTooltip:AddLine(DataStore:GetColoredCharacterName(character),1,1,1)
			AltoTooltip:AddLine(dungeonName,1,1,1)
			AltoTooltip:AddLine(GetDifficultyInfo(difficulty),1,1,1)
			
			AltoTooltip:AddLine(" ",1,1,1)
			
			local color
			for i = 1, GetLFGDungeonNumEncounters(dungeonID) do
				local bossName = GetLFGDungeonEncounterInfo(dungeonID, i)
				
				-- current display is confusing, only show the "already looted" for the time being, skip the others until a better solution is possible
				if DataStore:IsBossAlreadyLooted(character, dungeonID, bossName) then
					AltoTooltip:AddDoubleLine(bossName, colors.red..ERR_LOOT_GONE)
				-- else
					-- AltoTooltip:AddDoubleLine(bossName, colors.green..BOSS_ALIVE)
				end
			end
			
			AltoTooltip:Show()
			
		end,
	OnClick = nil,
	OnLeave = function(self)
			AltoTooltip:Hide() 
		end,
	InitViewDDM = function(frame, title) 
			dropDownFrame = frame
			frame:Show()
			title:Show()

			local currentXPack = addon:GetOption(OPTION_XPACK)
			local currentRaids = addon:GetOption(OPTION_RAIDS)
			
			currentDDMText = Dungeons[currentXPack][currentRaids].name
			
			frame:SetMenuWidth(100) 
			frame:SetButtonWidth(20)
			frame:SetText(currentDDMText)
			frame:Initialize(DropDown_Initialize, "MENU_NO_BORDERS")
		end,
}

AltoholicTabGrids:RegisterGrid(7, callbacks)
