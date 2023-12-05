local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local raidDungeons = {
	-- Onyxia's Lair
	{ name = C_Map.GetAreaInfo(2159), icon = "inv_jewelry_talisman_11", questIDs = "6502,6602" },		
	
	-- Molten Core
	{ name = C_Map.GetAreaInfo(2717), icon = "Spell_Fire_LavaSpawn", questIDs = "7847,7848" },
	
	-- Blackwing Lair
	{ name = C_Map.GetAreaInfo(2677), icon = "inv_misc_head_dragon_black", questIDs = "7761" },
	
	-- Naxxramas
	{ name = C_Map.GetAreaInfo(3456), icon = "INV_Armor_Shield_Naxxramas_D_01", questIDs = "9121,9122,9123" },
}

local callbacks = {
	OnUpdate = function() end,
	GetSize = function() return #raidDungeons end,
	RowSetup = function(self, rowFrame, dataRowID)
			rowFrame.Name.Text:SetText(format("%s%s", colors.white, raidDungeons[dataRowID].name))
			rowFrame.Name.Text:SetJustifyH("LEFT")
		end,
	ColumnSetup = function(self, button, dataRowID, character)
			local raid = raidDungeons[dataRowID]
	
			button.Name:SetFontObject("GameFontNormalSmall")
			button.Name:SetJustifyH("CENTER")
			button.Name:SetPoint("BOTTOMRIGHT", 5, 0)
			button.Background:SetDesaturated(false)
			button.Background:SetTexCoord(0, 1, 0, 1)
			button.Background:SetTexture(format("Interface\\ICONS\\%s", raid.icon))

			local isQuestCompleted = false
			
			for _, questID in pairs({strsplit(",", raid.questIDs)}) do
				questID = tonumber(questID)
				
				if DataStore:IsQuestCompletedBy(character, questID) then
					isQuestCompleted = true
					break
				end
			end
			
			if isQuestCompleted then
				button.Background:SetVertexColor(1.0, 1.0, 1.0)
				button.Name:SetText(icons.ready)
			else
				button.Background:SetVertexColor(0.4, 0.4, 0.4)
				button.Name:SetText(icons.notReady)
			end
		end,
	InitViewDDM = function(frame, title) 
			frame:Hide()
			title:Hide()
		end,
}

AltoholicTabGrids:RegisterGrid(5, callbacks)
