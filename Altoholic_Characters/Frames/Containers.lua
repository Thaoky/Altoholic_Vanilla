local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

addon.Containers = {}

local ns = addon.Containers		-- ns = namespace

local bagIndices

local function UpdateBagIndices(bag, size)
	-- the BagIndices table will be used by self:Containers_Update to determine which part of a bag should be displayed on a given line
	-- ex: [1] = bagID = 0, from 1, to 12
	-- ex: [2] = bagID = 0, from 13, to 16

	local lowerLimit = 1

	while size > 0 do					-- as long as there are slots to process ..
		table.insert(bagIndices, { bagID=bag, from=lowerLimit} )
	
		if size <= 12 then			-- no more lines ? leave
			return
		else
			size = size - 12			-- .. or adjust counters
			lowerLimit = lowerLimit + 12
		end
	end
end

local function UpdateSpread()

	local rarity = addon:GetOption("UI.Tabs.Characters.ViewBagsRarity")
	
	local frame = AltoholicFrameContainers
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	
	if #bagIndices == 0 then
		for rowIndex = 1, numRows do
			local rowFrame = scrollFrame:GetRow(rowIndex) 
			rowFrame:Hide()
		end
		
		scrollFrame:Update(numRows)
		return
	end
	
	local character = Altoholic.Tabs.Characters:GetAltKey()
	local DS = DataStore
	local offset = scrollFrame:GetOffset()
	
	AltoholicTabCharacters.Status:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), L["Containers"]))
	
	local rowFrame
	local itemButton
	
	for i=1, numRows do
		rowFrame = scrollFrame:GetRow(i)
		
		local line = i + offset
		
		if line <= #bagIndices then
		
			local containerID = bagIndices[line].bagID
			local container = DS:GetContainer(character, containerID)
			local containerIcon, _, containerSize = DS:GetContainerInfo(character, containerID)
			
			-- Column 1 : the bag
			itemButton = rowFrame.Item1
			
			if bagIndices[line].from == 1 then		-- if this is the first line for this bag .. draw bag icon
				itemButton.Icon:SetDesaturated(false)
				itemButton:SetID(containerID)
				
				itemButton.Icon:SetTexture(containerIcon)
				itemButton:SetScript("OnEnter", function(self)
					local id = self:GetID()
					GameTooltip:SetOwner(self, "ANCHOR_LEFT");
					if id == 0 then
						GameTooltip:AddLine(BACKPACK_TOOLTIP,1,1,1);
						GameTooltip:AddLine(format(CONTAINER_SLOTS, 16, BAGSLOT),1,1,1);
						
					elseif id == 100 then
						GameTooltip:AddLine(L["Bank"],0.5,0.5,1);
						GameTooltip:AddLine(L["28 Slot"],1,1,1);
					else
						local character = Altoholic.Tabs.Characters:GetAltKey()
						local _, link = DS:GetContainerInfo(character, id)
						GameTooltip:SetHyperlink(link);
						if (id >= 5) and (id <= 11) then
							GameTooltip:AddLine(L["Bank bag"],0,1,0);
						end
					end
					GameTooltip:Show();
				end)
				itemButton.Count:Hide()
				itemButton:Show()
			else
				itemButton:Hide()
			end
			
			-- Column 2 : empty
			itemButton = rowFrame.Item2
			itemButton:Hide()
			itemButton:SetInfo(nil, nil)
			
			-- Columns 3 to 14 : bag content
			for j=3, 14 do
				itemButton = rowFrame["Item"..j]
				
				local slotID = bagIndices[line].from - 3 + j
				local itemID, itemLink, itemCount, isBattlePet = DS:GetSlotInfo(container, slotID)
				
				if (slotID <= containerSize) then 
					itemButton:SetItem(itemID, itemLink, rarity)
					itemButton:SetCount(itemCount)
					if isBattlePet then
						itemButton:SetIcon(itemID)	-- override the icon if one is returned by datastore
					end
					
					local startTime, duration, isEnabled = DS:GetContainerCooldownInfo(container, slotID)
					itemButton:SetCooldown(startTime, duration, isEnabled)
					itemButton:Show()
				else
					itemButton:Hide()
					itemButton:SetInfo(nil, nil)
					itemButton.startTime = nil
					itemButton.duration = nil
				end
			end
			rowFrame:Show()
		else
			rowFrame:Hide()
		end
	end
	
	if #bagIndices < numRows then
		scrollFrame:Update(numRows)
	else
		scrollFrame:Update(#bagIndices)
	end	
end	

local function UpdateAllInOne()
	local rarity = addon:GetOption("UI.Tabs.Characters.ViewBagsRarity")
	local frame = AltoholicFrameContainers
	local scrollFrame = frame.ScrollFrame
	local numRows = scrollFrame.numRows
	
	local character = Altoholic.Tabs.Characters:GetAltKey()
	AltoholicTabCharacters.Status:SetText(format("%s|r / %s / %s", DataStore:GetColoredCharacterName(character), L["Containers"], L["All-in-one"]))

	local offset = scrollFrame:GetOffset()
	
	local minSlotIndex = offset * 14
	local currentSlotIndex = 0		-- this indexes the non-empty slots
	local rowIndex = 1
	local colIndex = 1
	
	local containerList = {}

	if addon:GetOption("UI.Tabs.Characters.ViewBags") then
		for i = 0, 4 do
			table.insert(containerList, i)
		end
	end
	
	if addon:GetOption("UI.Tabs.Characters.ViewBank") then
		for i = 5, 11 do
			table.insert(containerList, i)
		end
		table.insert(containerList, 100)
	end
	
	local itemButton
	if #containerList > 0 then
		local DS = DataStore
		
		for _, containerID in pairs(containerList) do
			local container = DS:GetContainer(character, containerID)
			local _, _, containerSize = DS:GetContainerInfo(character, containerID)

			for slotID = 1, containerSize do
				local itemID, itemLink, itemCount, isBattlePet = DS:GetSlotInfo(container, slotID)

				if itemID then
					currentSlotIndex = currentSlotIndex + 1
					if (currentSlotIndex > minSlotIndex) and (rowIndex <= numRows) then
						itemButton = frame["Entry"..rowIndex]["Item"..colIndex]
						itemButton:SetItem(itemID, itemLink, rarity)
						itemButton:SetCount(itemCount)
						if isBattlePet then
							itemButton:SetIcon(itemID)	-- override the icon if one is returned by datastore
						end
						
						local startTime, duration, isEnabled = DS:GetContainerCooldownInfo(container, slotID)
						itemButton:SetCooldown(startTime, duration, isEnabled)
						itemButton:Show()
						
						colIndex = colIndex + 1
						if colIndex > 14 then
							colIndex = 1
							rowIndex = rowIndex + 1
						end
					end				
				end
			end
		end
	end
		
	while rowIndex <= numRows do
		while colIndex <= 14 do
			itemButton = frame["Entry"..rowIndex]["Item"..colIndex]
			itemButton:Hide()
			itemButton:SetInfo(nil, nil)
			-- itemButton.id = nil
			-- itemButton.link = nil
			itemButton.startTime = nil
			itemButton.duration = nil
			colIndex = colIndex + 1
		end
	
		colIndex = 1
		rowIndex = rowIndex + 1
	end
	
	for i = 1, numRows do
		frame["Entry"..i]:Show()
	end

	scrollFrame:Update(ceil(currentSlotIndex / 14))
end


function ns:SetView(isAllInOne)
	if not isAllInOne then	-- not an all-in-one view
		ns.Update = UpdateSpread
		ns:UpdateCache()
		AltoholicFrameContainers.ScrollFrame:SetOffset(0)
	else
		ns.Update = UpdateAllInOne
	end
end

function ns:UpdateCache()
	bagIndices = bagIndices or {}
	wipe(bagIndices)

	local character = addon.Tabs.Characters:GetAltKey()
	
	if addon:GetOption("UI.Tabs.Characters.ViewBags") then
		for bagID = 0, 4 do
			if DataStore:GetContainer(character, bagID) then
				local _, _, size = DataStore:GetContainerInfo(character, bagID)
				UpdateBagIndices(bagID, size)
			end
		end	
	end
	
	if addon:GetOption("UI.Tabs.Characters.ViewBank") then
		for bagID = 5, 11 do
			if DataStore:GetContainer(character, bagID) then
				local _, _, size = DataStore:GetContainerInfo(character, bagID)
				UpdateBagIndices(bagID, size)
			end
		end
		
		if DataStore:GetContainer(character, 100) then 	-- if bank has been visited, add it
			UpdateBagIndices(100, 28)
		end
	end
end

-- *** Event Handlers ***
local function OnBagUpdate(bag)
	addon:RefreshTooltip()

	if DataStore:IsMailBoxOpen() and AltoholicFrameMail:IsVisible() then	
		-- if a bag is updated while the mailbox is opened, this means an attachment has been taken.
		addon.Mail:BuildView()
		addon.Mail:Update()
	end
end

addon:RegisterEvent("BAG_UPDATE", OnBagUpdate)
