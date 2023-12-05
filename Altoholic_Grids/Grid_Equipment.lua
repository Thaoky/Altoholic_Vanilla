local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Class constants, for readability, these values match the ones in Altoholic.Classes (altoholic.lua)
local CLASS_MAGE			= "MAGE"
local CLASS_WARRIOR		= "WARRIOR"
local CLASS_HUNTER		= "HUNTER"
local CLASS_ROGUE			= "ROGUE"
local CLASS_WARLOCK		= "WARLOCK"
local CLASS_DRUID			= "DRUID"
local CLASS_SHAMAN		= "SHAMAN"
local CLASS_PALADIN		= "PALADIN"
local CLASS_PRIEST		= "PRIEST"
local CLASS_DEATHKNIGHT	= "DEATHKNIGHT"

--[[

a few constants to increase readability in the tables below, 
some stats are taken from WoWUI's GlobalStrings.lua, but not all of them are suitable

SPELL_STAT1_NAME = "Strength";
SPELL_STAT2_NAME = "Agility";
SPELL_STAT3_NAME = "Stamina";
SPELL_STAT4_NAME = "Intellect";
SPELL_STAT5_NAME = "Spirit";

COMBAT_RATING_NAME1 = "Weapon Skill";
COMBAT_RATING_NAME10 = "Crit Rating"; -- Ranged crit rating
COMBAT_RATING_NAME11 = "Crit Rating"; -- Spell Crit Rating
COMBAT_RATING_NAME15 = "Resilience";
COMBAT_RATING_NAME2 = "Defense Rating";
COMBAT_RATING_NAME24 = "Expertise";
COMBAT_RATING_NAME3 = "Dodge Rating";
COMBAT_RATING_NAME4 = "Parry Rating";
COMBAT_RATING_NAME5 = "Block Rating";
COMBAT_RATING_NAME6 = "Hit Rating";
COMBAT_RATING_NAME7 = "Hit Rating"; -- Ranged hit rating
COMBAT_RATING_NAME8 = "Hit Rating"; -- Spell hit rating
COMBAT_RATING_NAME9 = "Crit Rating"; -- Melee crit rating

ATTACK_POWER_TOOLTIP = "Attack Power";
SPELLS = "Spells"; -- Generic "spells"  		note: replace this with a spell power constant in wotlk
MANA_REGEN = "Mana Regen";
BONUS_HEALING = "Bonus Healing";

ITEM_MOD_CRIT_RATING = "Improves critical strike rating by %d.";
 ITEM_MOD_CRIT_SPELL_RATING= "Improves spell critical strike rating by %d.";
ITEM_MOD_HIT_RATING = "Improves hit rating by %d.";
ITEM_MOD_HIT_SPELL_RATING = "Improves spell hit rating by %d.";
local STAT_HEALING = L["Increases healing done by up to %d+"]
local STAT_SPELLDMG = L["Increases damage and healing done by magical spells and effects by up to %d+"]
ITEM_MOD_DEFENSE_SKILL_RATING = "Increases defense rating by %d."; -- Increases defense rating by %d
ITEM_MOD_DODGE_RATING = "Increases your dodge rating by %d.";
ITEM_MOD_BLOCK_RATING = "Increases your shield block rating by %d.";
ITEM_MOD_SPELL_POWER = "Increases spell power by %d.";
ITEM_MOD_RESILIENCE_RATING = "Improves your resilience rating by %d.";
--]]

local STAT_AP = L["Increases attack power by %d+"]
local STAT_MP5 = L["Restores %d+ mana per"]
local STAT_SHAMAN_ONLY = L["Classes: Shaman"] .. "$"
local STAT_MAGE_ONLY = L["Classes: Mage"] .. "$"
local STAT_ROGUE_ONLY = L["Classes: Rogue"] .. "$"
local STAT_HUNTER_ONLY = L["Classes: Hunter"] .. "$"
local STAT_WARRIOR_ONLY = L["Classes: Warrior"] .. "$"
local STAT_PALADIN_ONLY = L["Classes: Paladin"] .. "$"
local STAT_WARLOCK_ONLY = L["Classes: Warlock"] .. "$"
local STAT_PRIEST_ONLY = L["Classes: Priest"] .. "$"
local STAT_DK_ONLY = L["Classes: Death Knight"] .. "$"
local STAT_RESIST = L["Resistance"]

-- addon.Equipment = {}		-- table created globally, no longer here

local ns = addon.Equipment		-- ns = namespace

-- When processing item stats, exclude an item if one of these strings is encountered, then discard the item
-- ex: if you're searching an update for the shoulder slot of your warrior, then the items listed will be of type "Armor" & subtype "Plate",
-- 	so parsing each line of stat is necessary to determine if a warrior can use the item.. therefore, the algorithm tries to find one of the words
--	that will help filtering out the item (if plate has +intel or +mana, it's obviously not for a warrior ..)
ns.ExcludeStats = {
	[CLASS_MAGE.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		STAT_AP, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_PRIEST_ONLY, 
		STAT_WARLOCK_ONLY
	},
	[CLASS_WARRIOR.."Tank"]	= { 
		STAT_RESIST, 
		SPELL_STAT4_NAME, 
		SPELL_STAT5_NAME, 
		STAT_MP5, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_RESILIENCE_RATING, 
		STAT_AP, 
		STAT_PALADIN_ONLY
	},
	[CLASS_WARRIOR.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT4_NAME, 
		SPELL_STAT5_NAME, 
		STAT_MP5, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		STAT_PALADIN_ONLY
	},
	[CLASS_HUNTER.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_SHAMAN_ONLY
	},
	[CLASS_ROGUE.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT4_NAME, 
		STAT_MP5, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING
	},
	[CLASS_WARLOCK.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		STAT_AP, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_MAGE_ONLY, 
		STAT_PRIEST_ONLY
	},
	[CLASS_DRUID.."Tank"] = { 
		STAT_RESIST, 
		ITEM_MOD_SPELL_POWER, 
		STAT_ROGUE_ONLY, 
		ITEM_MOD_RESILIENCE_RATING
	},
	[CLASS_DRUID.."Heal"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_RESILIENCE_RATING, 
		STAT_AP
	},
	[CLASS_DRUID.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT4_NAME, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_ROGUE_ONLY
	},
	[CLASS_DRUID.."Balance"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_AP
	},
	[CLASS_SHAMAN.."Heal"] = { 
		STAT_RESIST, 
		ITEM_MOD_CRIT_RATING, 
		SPELL_STAT2_NAME, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_RESILIENCE_RATING, 
		STAT_AP
	},
	[CLASS_SHAMAN.."DPS"] = { 
		STAT_RESIST, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_HUNTER_ONLY
	},
	[CLASS_SHAMAN.."Elemental"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		ITEM_MOD_HIT_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_AP, 
		ITEM_MOD_CRIT_RATING
	},
	[CLASS_PALADIN.."Tank"]	= { 
		STAT_RESIST, 
		SPELL_STAT2_NAME, 
		STAT_AP, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_RESILIENCE_RATING, 
		ITEM_MOD_CRIT_RATING, 
		STAT_WARRIOR_ONLY
	},
	[CLASS_PALADIN.."Heal"]	= { 
		STAT_RESIST, 
		SPELL_STAT2_NAME, 
		ITEM_MOD_CRIT_RATING, 
		STAT_AP, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_HIT_RATING, 
		ITEM_MOD_RESILIENCE_RATING
	},
	[CLASS_PALADIN.."DPS"] = { 
		STAT_RESIST, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		STAT_WARRIOR_ONLY },
	[CLASS_PRIEST.."Heal"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		ITEM_MOD_RESILIENCE_RATING, 
		STAT_AP, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING
	},
	[CLASS_PRIEST.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT1_NAME, 
		SPELL_STAT2_NAME, 
		STAT_AP, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		STAT_MAGE_ONLY, 
		STAT_WARLOCK_ONLY
	},
	[CLASS_DEATHKNIGHT.."Tank"] = { 
		STAT_RESIST, 
		SPELL_STAT4_NAME, 
		SPELL_STAT5_NAME, 
		STAT_MP5, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_RESILIENCE_RATING, 
		STAT_WARRIOR_ONLY,
		STAT_PALADIN_ONLY
	},
	[CLASS_DEATHKNIGHT.."DPS"] = { 
		STAT_RESIST, 
		SPELL_STAT4_NAME, 
		SPELL_STAT5_NAME, 
		STAT_MP5, 
		ITEM_MOD_DEFENSE_SKILL_RATING, 
		ITEM_MOD_DODGE_RATING, 
		ITEM_MOD_BLOCK_RATING, 
		ITEM_MOD_SPELL_POWER, 
		ITEM_MOD_RESILIENCE_RATING,
		STAT_WARRIOR_ONLY,
		STAT_PALADIN_ONLY
	}
}

ns.BaseStats = {	-- the order of these strings should match the "-s" in the associated entry of the FormatStats table
	[CLASS_MAGE.."DPS"]		= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, SPELL_STAT5_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, ITEM_MOD_SPELL_POWER },
	[CLASS_WARRIOR.."Tank"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING },
	[CLASS_WARRIOR.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, SPELL_STAT2_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_HUNTER.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT2_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_ROGUE.."DPS"]		= { SPELL_STAT3_NAME, SPELL_STAT2_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_WARLOCK.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, ITEM_MOD_SPELL_POWER },
	[CLASS_DRUID.."Tank"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, SPELL_STAT2_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING },
	[CLASS_DRUID.."Heal"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, SPELL_STAT5_NAME, ITEM_MOD_CRIT_RATING, STAT_MP5, ITEM_MOD_SPELL_POWER },
	[CLASS_DRUID.."DPS"]		= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, SPELL_STAT2_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_DRUID.."Balance"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, STAT_MP5, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, ITEM_MOD_SPELL_POWER },
	[CLASS_SHAMAN.."Heal"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_RATING, STAT_MP5, ITEM_MOD_SPELL_POWER },
	[CLASS_SHAMAN.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, SPELL_STAT2_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_SHAMAN.."Elemental"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, STAT_MP5, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, ITEM_MOD_SPELL_POWER },
	[CLASS_PALADIN.."Tank"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING, ITEM_MOD_SPELL_POWER },
	[CLASS_PALADIN.."Heal"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_RATING, STAT_MP5, ITEM_MOD_SPELL_POWER },
	[CLASS_PALADIN.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, SPELL_STAT4_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP },
	[CLASS_PRIEST.."Heal"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, SPELL_STAT5_NAME, ITEM_MOD_CRIT_RATING, STAT_MP5, ITEM_MOD_SPELL_POWER },
	[CLASS_PRIEST.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT4_NAME, SPELL_STAT5_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, ITEM_MOD_SPELL_POWER },
	[CLASS_DEATHKNIGHT.."Tank"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, ITEM_MOD_DEFENSE_SKILL_RATING, ITEM_MOD_DODGE_RATING, ITEM_MOD_HIT_RATING },
	[CLASS_DEATHKNIGHT.."DPS"]	= { SPELL_STAT3_NAME, SPELL_STAT1_NAME, SPELL_STAT2_NAME, ITEM_MOD_CRIT_RATING, ITEM_MOD_HIT_RATING, STAT_AP }
}

ns.FormatStats = {
	[CLASS_MAGE.."DPS"]		= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. SPELL_STAT5_NAME .."|".. COMBAT_RATING_NAME11 .."|".. COMBAT_RATING_NAME8 .."|".. SPELLS,
	[CLASS_WARRIOR.."Tank"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. COMBAT_RATING_NAME2 .."|".. COMBAT_RATING_NAME3 .."|".. COMBAT_RATING_NAME6,
	[CLASS_WARRIOR.."DPS"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. SPELL_STAT2_NAME .."|".. COMBAT_RATING_NAME9 .."|".. COMBAT_RATING_NAME6 .."|" .. ATTACK_POWER_TOOLTIP,
	[CLASS_HUNTER.."DPS"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT2_NAME .."|".. SPELL_STAT4_NAME .."|".. COMBAT_RATING_NAME10 .."|".. COMBAT_RATING_NAME7 .."|".. ATTACK_POWER_TOOLTIP,
	[CLASS_ROGUE.."DPS"]		= SPELL_STAT3_NAME .."|".. SPELL_STAT2_NAME .."|".. COMBAT_RATING_NAME9 .."|".. COMBAT_RATING_NAME6 .."|".. ATTACK_POWER_TOOLTIP,
	[CLASS_WARLOCK.."DPS"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. COMBAT_RATING_NAME11 .."|".. COMBAT_RATING_NAME8 .."|".. SPELLS,
	[CLASS_DRUID.."Tank"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. SPELL_STAT2_NAME .."|".. COMBAT_RATING_NAME2 .."|".. COMBAT_RATING_NAME3 .."|".. COMBAT_RATING_NAME6,
	[CLASS_DRUID.."Heal"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. SPELL_STAT5_NAME .."|".. COMBAT_RATING_NAME11 .."|".. MANA_REGEN .."|".. BONUS_HEALING,
	[CLASS_DRUID.."DPS"]		= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. SPELL_STAT2_NAME .."|".. COMBAT_RATING_NAME9 .."|".. COMBAT_RATING_NAME6 .."|".. ATTACK_POWER_TOOLTIP,
	[CLASS_DRUID.."Balance"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. MANA_REGEN .."|".. COMBAT_RATING_NAME11 .."|".. COMBAT_RATING_NAME8 .."|".. SPELLS,
	[CLASS_SHAMAN.."Heal"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. COMBAT_RATING_NAME11 .."|".. MANA_REGEN .."|".. BONUS_HEALING,
	[CLASS_SHAMAN.."DPS"]	=  SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. SPELL_STAT2_NAME .."|".. COMBAT_RATING_NAME9 .."|".. COMBAT_RATING_NAME6 .."|".. ATTACK_POWER_TOOLTIP,
	[CLASS_SHAMAN.."Elemental"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. MANA_REGEN .."|".. COMBAT_RATING_NAME11 .."|".. COMBAT_RATING_NAME8 .."|".. SPELLS,
	[CLASS_PALADIN.."Tank"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. COMBAT_RATING_NAME2 .."|".. COMBAT_RATING_NAME3 .."|".. COMBAT_RATING_NAME6 .."|".. SPELLS,
	[CLASS_PALADIN.."Heal"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. COMBAT_RATING_NAME11 .."|".. MANA_REGEN .."|".. BONUS_HEALING,
	[CLASS_PALADIN.."DPS"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. SPELL_STAT4_NAME .."|".. COMBAT_RATING_NAME9 .."|".. COMBAT_RATING_NAME6 .."|".. ATTACK_POWER_TOOLTIP,
	[CLASS_PRIEST.."Heal"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. SPELL_STAT5_NAME .."|".. COMBAT_RATING_NAME11 .."|".. MANA_REGEN .."|".. BONUS_HEALING,
	[CLASS_PRIEST.."DPS"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT4_NAME .."|".. SPELL_STAT5_NAME .."|".. COMBAT_RATING_NAME11 .."|".. COMBAT_RATING_NAME8 .."|".. SPELLS,
	[CLASS_DEATHKNIGHT.."Tank"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. COMBAT_RATING_NAME2 .."|".. COMBAT_RATING_NAME3 .."|".. COMBAT_RATING_NAME6,
	[CLASS_DEATHKNIGHT.."DPS"]	= SPELL_STAT3_NAME .."|".. SPELL_STAT1_NAME .."|".. SPELL_STAT2_NAME .."|".. COMBAT_RATING_NAME9 .."|".. COMBAT_RATING_NAME6 .."|" .. ATTACK_POWER_TOOLTIP
}

local DDM_Add = addon.Helpers.DDM_Add
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu

local function RightClickMenu_Initialize()
	local searchCB = addon.Search.FindEquipmentUpgrade		-- search callback

	DDM_Add(format("%s %s", L["Find Upgrade"], colors.green .. L["(based on iLvl)"]), -1, searchCB)
	
	local class = addon.Search:GetClass()

	-- Tank upgrade
	if (class == CLASS_WARRIOR) or
		(class == CLASS_DRUID) or
		(class == CLASS_DEATHKNIGHT) or
		(class == CLASS_PALADIN) then
		
		DDM_Add(format("%s %s(%s)", L["Find Upgrade"], colors.green, L["Tank"]), class .. "Tank", searchCB)
	end
	
	-- DPS upgrade
	if class then
		DDM_Add(format("%s %s(%s)", L["Find Upgrade"], colors.green, L["DPS"]), class .. "DPS", searchCB)
	end
		
	if class == CLASS_DRUID then
		DDM_Add(format("%s %s(%s)", L["Find Upgrade"], colors.green, L["Balance"]), class .. "Balance", searchCB)
	elseif class == CLASS_SHAMAN then
		DDM_Add(format("%s %s(%s)", L["Find Upgrade"], colors.green, L["Elemental Shaman"]), class .. "Elemental", searchCB)
	end
		
	-- Heal upgrade
	if (class == CLASS_PRIEST) or
		(class == CLASS_SHAMAN) or
		(class == CLASS_DRUID) or
		(class == CLASS_PALADIN) then
		
		DDM_Add(format("%s %s(%s)", L["Find Upgrade"], colors.green, L["Heal"]), class .. "Heal", searchCB)
	end
	
	DDM_AddCloseMenu()
end

local callbacks = {
	OnUpdate = function() end,
	GetSize = function() return ns:GetNumSlotTypes() end,
	RowSetup = function(self, rowFrame, dataRowID)
			local name, color = ns:GetSlotTypeInfo(dataRowID)

			rowFrame.Name.Text:SetText(color .. name)
			rowFrame.Name.Text:SetJustifyH("RIGHT")
		end,
	RowOnEnter = function()	end,
	RowOnLeave = function() end,
	ColumnSetup = function(self, button, dataRowID, character)
			button.Background:SetDesaturated(false)
			button.Background:SetVertexColor(1.0, 1.0, 1.0)
			button.Background:SetTexCoord(0, 1, 0, 1)
			
			button.Name:SetFontObject("NumberFontNormalSmall")
			button.Name:SetJustifyH("RIGHT")
			button.Name:SetPoint("BOTTOMRIGHT", 0, 0)
			
			local item = DataStore:GetInventoryItem(character, dataRowID)
			if item then
				button.key = character
				
				button.Background:SetTexture(GetItemIcon(item))
				
				-- display the coloured border
				local _, _, itemRarity, itemLevel = GetItemInfo(item)
				if itemRarity and itemRarity >= 2 then
					local r, g, b = GetItemQualityColor(itemRarity)
					button.IconBorder:SetVertexColor(r, g, b, 0.5)
					button.IconBorder:Show()
				end
				
				-- This returns a correct iLvl for upgraded items
				-- There are mistakes though, sometimes for leveling items, it returns an iLvl higher than what is shown in the tooltip (+10, +20)
				if type(item) == "string" then
					itemLevel = GetDetailedItemLevelInfo(item)
				end

				button.Name:SetText(itemLevel)
			else
				button.key = nil
				button.Background:SetTexture(addon:GetEquipmentSlotIcon(dataRowID))
				button.Name:SetText("")
			end
			
			button.id = dataRowID
		end,
		
	OnEnter = function(frame) 
			local character = frame.key
			if not character then return end

			local item = DataStore:GetInventoryItem(character, frame.id)
			if not item then return end

			GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
			local link
			if type(item) == "number" then
				link = select(2, GetItemInfo(item))
			else
				link = item
			end
			
			if not link then
				GameTooltip:AddLine(L["Unknown link, please relog this character"],1,1,1)
				GameTooltip:Show()
				return
			end
			
			GameTooltip:SetHyperlink(link)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(colors.green .. L["Right-Click to find an upgrade"])
			GameTooltip:Show()
		end,
	OnClick = function(frame, button)
			local character = frame.key
			if not character then return end

			local slotID = frame.id
			if slotID == 0 then return end		-- class icon

			local item = DataStore:GetInventoryItem(character, slotID)
			if not item then return end
			
			local link
			if type(item) == "number" then
				link = select(2, GetItemInfo(item))
			else
				link = item
			end
			
			if not link then return end
			
			if button == "RightButton" then
				if not IsAddOnLoaded("Altoholic_Search") then
					LoadAddOn("Altoholic_Search")
					addon:DDM_Initialize(AltoholicFrameGridsRightClickMenu, RightClickMenu_Initialize)
				end
				
				addon.Search:SetCurrentItem( addon:GetIDFromLink(link) ) 		-- item ID of the item to find an upgrade for
				local _, class = DataStore:GetCharacterClass(character)
				addon.Search:SetClass(class)
				
				ToggleDropDownMenu(1, nil, AltoholicFrameGridsRightClickMenu, frame:GetName(), 0, -5);
				return
			end
			
			if ( button == "LeftButton" ) and ( IsControlKeyDown() ) then
				DressUpItemLink(link)
			elseif ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
				local chat = ChatEdit_GetLastActiveWindow()
				if chat:IsShown() then
					chat:Insert(link)
				else
					AltoholicFrame_SearchEditBox:SetText(GetItemInfo(link))
				end
			end
		end,
	OnLeave = function(self)
			GameTooltip:Hide() 
		end,
	InitViewDDM = function(frame, title) 
			frame:Hide()
			title:Hide()
		end,
}

AltoholicTabGrids:RegisterGrid(1, callbacks)
