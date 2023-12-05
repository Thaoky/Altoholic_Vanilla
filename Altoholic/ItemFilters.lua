local addonName = ...
local addon = _G[addonName]

local filters = {}
local searchedItem = {}

-- item filtering functions
local function FilterExistence()
	if searchedItem["itemName"] and searchedItem["itemRarity"] then
		return true	-- if both values are valid, the item exists in the game's item cache
	end
end

local function FilterType()
	local itemType = filters["itemType"]
	if not itemType or searchedItem["itemType"] == itemType then
		return true		-- no filter, or searched item is the same type as filter, keep it
	end
end

local function FilterSubType()
	local subType = filters["itemSubType"]
	if not subType or searchedItem["itemSubType"] == subType then
		return true		-- no filter, or searched item is the same sub type as filter, keep it
	end
end

local function FilterRarity()
	local rarity = filters["itemRarity"]
	if not rarity or searchedItem["itemRarity"] >= rarity then
		return true		-- no filter, or searched item has higher rarity than filter, keep it
	end
end

local function FilterItemLevel()
	if searchedItem["itemLevel"] > filters["itemLevel"] then		-- strictly superior, fully intentional
		return true		-- searched item has higher iLvl than filter, keep it
	end
end

local function FilterEquipmentSlot()
	if addon.Equipment:GetInventoryTypeIndex(searchedItem["itemEquipLoc"]) == filters["itemSlot"] then
		return true		-- same slot as filter, keep the item
	end
end

local function FilterName()
	if string.find(strlower(searchedItem["itemName"]), filters["itemName"], 1, true) then
		return true		-- name contains the filter value, keep the item
	end
end

local function FilterMinimumLevel()
	local minLevel = searchedItem["itemMinLevel"]
	if minLevel == 0 then
		if addon:GetOption("UI.Tabs.Search.IncludeNoMinLevel") then
			return true		-- include items with no minimum requireement
		end
	else
		if minLevel >= filters["itemMinLevel"] then
			return true		--  include if within the right level boundaries
		end
	end
end

local function FilterMaximumLevel()
	if searchedItem["itemMinLevel"] <= filters["itemMaxLevel"] then
		return true		-- item min level is below max filter, keep the item
	end
end

local filterFunctions = {
	["Existence"] = FilterExistence,
	["Type"] = FilterType,
	["SubType"] = FilterSubType,
	["Rarity"] = FilterRarity,
	["ItemLevel"] = FilterItemLevel,
	["EquipmentSlot"] = FilterEquipmentSlot,
	["Name"] = FilterName,
	["MinLevel"] = FilterMinimumLevel,
	["Maxlevel"] = FilterMaximumLevel,
}

addon.ItemFilters = {}

local ns = addon.ItemFilters		-- ns = namespace

function ns:SetFilterValue(field, value)
	filters[field] = value
end

function ns:GetFilterValue(field)
	return filters[field]
end

local NAMES = {}

function ns:EnableFilter(filter)
	if filterFunctions[filter] then
		filters.list = filters.list or {}
		table.insert(filters.list, filterFunctions[filter])
		table.insert(NAMES, filter)
	end
end

function ns:ItemPassesFilters(verbose)
	-- verbose: for debug purposes only

	-- Exclusive approach:
	-- 	by default, it is considered that no item is filtered out unless a specific filter is enabled.
	-- 	ex: if a user wants to filter items based on their level in the UI, it means he doesn't want to see items outside of the specifies boundaries, so the filter "Level" is enabled, and items are filtered out.

	if filters.list then		-- there might not be any filter
		for name, func in pairs(filters.list) do
			if verbose then
				print("Testing filter : " .. NAMES[name])
			end
		
			if not func() then		-- if any of the filters returns false/nil, exit
				if verbose then
					print("exiting on " .. NAMES[name])
					print(searchedItem["itemName"])
					print(filters["itemName"])
				end
				return
			end
		end
	end
	return true			-- return true if all filters have returned true
end

function ns:ClearFilters()
	wipe(filters)
end

function ns:TryFilter(filter)
	if filterFunctions[filter] then
		return filterFunctions[filter]()
	end
end

-- currently searched item
function ns:SetSearchedItem(itemID, itemLink, isBattlePet)
	local s = searchedItem
	local _

	s.itemID = itemID
	s.itemName, s.itemLink, s.itemRarity, s.itemLevel,	s.itemMinLevel, s.itemType, s.itemSubType, _, s.itemEquipLoc = GetItemInfo(itemLink or itemID)
end

function ns:GetSearchedItemInfo(field)
	return searchedItem[field]
end

function ns:ClearSearchedItem()
	wipe(searchedItem)
end
