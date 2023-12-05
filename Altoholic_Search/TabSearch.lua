local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local parentName = "AltoholicTabSearch"
local parent

local highlightIndex

addon.Tabs.Search = {}

local ns = addon.Tabs.Search		-- ns = namespace

local currentClass
local currentSubClass

-- from Blizzard_AuctionData.lua & LuaEnum.lua
-- Note : review this later on, I suspect Blizzard will change this again
local categories = {
	{
		name = AUCTION_CATEGORY_WEAPONS,
		class = LE_ITEM_CLASS_WEAPON,
		subClasses = {
			LE_ITEM_WEAPON_AXE1H, LE_ITEM_WEAPON_MACE1H, LE_ITEM_WEAPON_SWORD1H,
			LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_MACE2H, LE_ITEM_WEAPON_SWORD2H, 
			LE_ITEM_WEAPON_WARGLAIVE, LE_ITEM_WEAPON_DAGGER, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_WAND,
			LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_STAFF,
			LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_THROWN,
			LE_ITEM_WEAPON_FISHINGPOLE,
		},
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_ARMOR,
		class = LE_ITEM_CLASS_ARMOR,
		subClasses = {
			LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_LEATHER, LE_ITEM_ARMOR_CLOTH, 
			LE_ITEM_ARMOR_GENERIC, LE_ITEM_ARMOR_SHIELD, LE_ITEM_ARMOR_COSMETIC,
		},
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_CONTAINERS,
		class = LE_ITEM_CLASS_CONTAINER,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_CONTAINER) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_GEMS,
		class = LE_ITEM_CLASS_GEM,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_GEM) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_ITEM_ENHANCEMENT,
		class = LE_ITEM_CLASS_ITEM_ENHANCEMENT,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_ITEM_ENHANCEMENT) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_CONSUMABLES,
		class = LE_ITEM_CLASS_CONSUMABLE,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_CONSUMABLE) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_GLYPHS,
		class = LE_ITEM_CLASS_GLYPH,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_GLYPH) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_TRADE_GOODS,
		class = LE_ITEM_CLASS_TRADEGOODS,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_TRADEGOODS) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_RECIPES,
		class = LE_ITEM_CLASS_RECIPE,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_RECIPE) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_BATTLE_PETS,
		class = LE_ITEM_CLASS_BATTLEPET,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_BATTLEPET) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_QUEST_ITEMS,
		class = LE_ITEM_CLASS_QUESTITEM,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_QUESTITEM) },
		isCollapsed = true,
	},
	{
		name = AUCTION_CATEGORY_MISCELLANEOUS,
		class = LE_ITEM_CLASS_MISCELLANEOUS,
		subClasses = { GetAuctionItemSubClasses(LE_ITEM_CLASS_MISCELLANEOUS) },
		isCollapsed = true,
	},
}

local function Header_OnClick(frame)
	local header = categories[frame.itemTypeIndex]
	header.isCollapsed = not header.isCollapsed

	ns:Update()
end

local function Item_OnClick(frame)
	local category = categories[frame.itemTypeIndex]
	local class = category.class
	local subClass = category.subClasses[frame.itemSubTypeIndex]
	
	-- 1005 = class 1, sub 5
	highlightIndex = (frame.itemTypeIndex * 1000) + frame.itemSubTypeIndex
	ns:Update()
	
	addon.Search:FindItem(GetItemClassInfo(class), GetItemSubClassInfo(class, subClass))
end

function ns:OnLoad()
	parent = _G[parentName]
	parent.SortButtons.Sort1:SetText(L["Item / Location"])
	parent.SortButtons.Sort2:SetText(L["Character"])
	parent.SortButtons.Sort3:SetText(L["Realm"])
	parent.Slot:SetText(L["Equipment Slot"])
	parent.Location:SetText(L["Location"])
end

function ns:Update()
	local itemTypeCacheIndex		-- index of the item type in the cache table
	local MenuCache = {}
	
	for categoryIndex, category in ipairs (categories) do
	
		table.insert(MenuCache, { linetype = 1, dataIndex = categoryIndex } )
		itemTypeCacheIndex = #MenuCache
	
		if category.isCollapsed == false then
			for subCategoryIndex, subCategory in ipairs(category.subClasses) do
				table.insert(MenuCache, { linetype = 2, dataIndex = subCategoryIndex, parentIndex = categoryIndex } )
				
				if (highlightIndex) and (highlightIndex == ((categoryIndex*1000)+ subCategoryIndex)) then
					MenuCache[#MenuCache].needsHighlight = true
					MenuCache[itemTypeCacheIndex].needsHighlight = true
				end
			end
		end
	end
	
	local buttonWidth = 156
	if #MenuCache > 15 then
		buttonWidth = 136
	end
	
	local scrollFrame = parent.ScrollFrame
	local numRows = scrollFrame.numRows
	local offset = scrollFrame:GetOffset()
	local menuButton
	
	for rowIndex = 1, numRows do
		menuButton = scrollFrame:GetRow(rowIndex)
		
		local line = rowIndex + offset
		
		if line > #MenuCache then
			menuButton:Hide()
		else
			local p = MenuCache[line]
			
			menuButton:SetWidth(buttonWidth)
			menuButton.Text:SetWidth(buttonWidth - 21)
			if p.needsHighlight then
				menuButton:LockHighlight()
			else
				menuButton:UnlockHighlight()
			end			
			
			if p.linetype == 1 then
				menuButton.Text:SetText(format("%s%s", colors.white, categories[p.dataIndex].name))
				menuButton:SetScript("OnClick", Header_OnClick)
				menuButton.itemTypeIndex = p.dataIndex
			elseif p.linetype == 2 then
				local category = categories[p.parentIndex]
				local class = category.class
				local subClass = category.subClasses[p.dataIndex]
			
				menuButton.Text:SetText("|cFFBBFFBB   " .. GetItemSubClassInfo(class, subClass))
				menuButton:SetScript("OnClick", Item_OnClick)
				menuButton.itemTypeIndex = p.parentIndex
				menuButton.itemSubTypeIndex = p.dataIndex
			end

			menuButton:Show()
		end
	end
	
	scrollFrame:Update(#MenuCache)
end

function ns:Reset()
	AltoholicFrame_SearchEditBox:SetText("")
	parent.MinLevel:SetText("")
	parent.MaxLevel:SetText("")
	parent.Status:SetText("")				-- .. the search results
	AltoholicFrameSearch:Hide()
	addon.Search:ClearResults()
	collectgarbage()
	
	for _, category in pairs(categories) do			-- rebuild the cache
		category.isCollapsed = true
	end
	highlightIndex = nil
	
	for i = 1, 8 do 
		parent.SortButtons["Sort"..i]:Hide()
		parent.SortButtons["Sort"..i].ascendingSort = nil
	end
	ns:Update()
end

function ns:DropDownRarity_Initialize()
	local info = UIDropDownMenu_CreateInfo(); 

	for i = 0, LE_ITEM_QUALITY_HEIRLOOM do		-- Quality: 0 = poor .. 5 = legendary ..
		info.text = format("|c%s%s", select(4, GetItemQualityColor(i)), _G["ITEM_QUALITY"..i.."_DESC"])
		info.value = i
		info.func = function(self)	
			UIDropDownMenu_SetSelectedValue(parent.SelectRarity, self.value)
		end
		info.checked = nil; 
		info.icon = nil; 
		UIDropDownMenu_AddButton(info, 1);
	end
end 

local slotNames = {		-- temporary workaround
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

function ns:DropDownSlot_Initialize()
	local function SetSearchSlot(self) 
		UIDropDownMenu_SetSelectedValue(parent.SelectSlot, self.value);
	end
	
	local info = UIDropDownMenu_CreateInfo(); 
	info.text = L["Any"]
	info.value = 0
	info.func = SetSearchSlot
	info.checked = nil; 
	info.icon = nil; 
	UIDropDownMenu_AddButton(info, 1); 	
	
	for i = 1, 18 do
		--info.text = addon.Equipment:GetSlotName(i)
		info.text = slotNames[i]		-- temporary workaround
		info.value = i
		info.func = SetSearchSlot
		info.checked = nil; 
		info.icon = nil; 
		UIDropDownMenu_AddButton(info, 1); 
	end
end 

function ns:DropDownLocation_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local text = {
		L["This character"],
		format("%s %s(%s)", L["This realm"], colors.green, L["This faction"]),
		format("%s %s(%s)", L["This realm"], colors.green, L["Both factions"]),
		L["All realms"],
		L["All accounts"],
		L["Loot tables"]
	}
	
	for i = 1, #text do
		info.text = text[i]
		info.value = i
		info.func = function(self) 
				UIDropDownMenu_SetSelectedValue(parent.SelectLocation, self.value)
			end
		info.checked = nil; 
		info.icon = nil; 
		UIDropDownMenu_AddButton(info, 1); 		
	end
end

function ns:SetMode(mode)

	-- sets the search mode, and prepares the frame accordingly (search update callback, column sizes, headers, etc..)
	if mode == "realm" then
		addon.Search:SetUpdateHandler("Realm_Update")
		
		parent.SortButtons:SetButton(1, L["Item / Location"], 240, function(self) addon.Search:SortResults(self, "name") end)
		parent.SortButtons:SetButton(2, L["Character"], 160, function(self) addon.Search:SortResults(self, "char") end)
		parent.SortButtons:SetButton(3, L["Realm"], 150, function(self) addon.Search:SortResults(self, "realm") end)
	
	elseif mode == "loots" then
		addon.Search:SetUpdateHandler("Loots_Update")
		
		parent.SortButtons:SetButton(1, L["Item / Location"], 240, function(self) addon.Search:SortResults(self, "item") end)
		parent.SortButtons:SetButton(2, L["Source"], 160, function(self) addon.Search:SortResults(self, "bossName") end)
		parent.SortButtons:SetButton(3, L["Item Level"], 150, function(self) addon.Search:SortResults(self, "iLvl") end)
		
	elseif mode == "upgrade" then
		addon.Search:SetUpdateHandler("Upgrade_Update")

		parent.SortButtons:SetButton(1, L["Item / Location"], 200, function(self) addon.Search:SortResults(self, "item") end)
		
		for i=1, 6 do 
			local text = select(i, strsplit("|", addon.Equipment.FormatStats[addon.Search:GetClass()]))
			
			if text then
				parent.SortButtons:SetButton(i+1, string.sub(text, 1, 3), 50, function(self)
					addon.Search:SortResults(self, "stat") -- use a getID to know which stat
				end)
			else
				parent.SortButtons:SetButton(i+1, nil)
			end
		end
		
		parent.SortButtons:SetButton(8, "iLvl", 50, function(self) addon.Search:SortResults(self, "iLvl") end)
	end
end

function ns:TooltipStats(frame)
	AltoTooltip:ClearLines();
	AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	
	AltoTooltip:AddLine(STATS_LABEL)
	AltoTooltip:AddLine(" ");
	
	local s = addon.Search:GetResult(frame:GetID())

	for i=1, 6 do
		local text = select(i, strsplit("|", addon.Equipment.FormatStats[addon.Search:GetClass()]))
		if text then 
			local color
			local diff = select(2, strsplit("|", s["stat"..i]))
			diff = tonumber(diff)

			if diff < 0 then
				color = colors.red
			elseif diff > 0 then 
				color = colors.green
				diff = "+" .. diff
			else
				color = colors.white
			end
			AltoTooltip:AddLine(format("%s%s %s", color, diff, text))
		end
	end
	AltoTooltip:Show()
end
