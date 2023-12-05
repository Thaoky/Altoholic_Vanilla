local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local CHARS_PER_FRAME = 12
local gridCallbacks = {}

addon:Controller("AltoholicUI.TabGrids", {
	OnBind = function(frame)
		frame.Label1:SetText(L["Realm"])
		frame.Equipment.text = L["Equipment"]
		frame.Factions.text = L["Reputations"]
		frame.Dailies.text = L["Daily Quests"]
		frame.Attunements.text = L["Attunements"]
		frame.Keys.text = L["Keys"]
		
		frame.SelectRealm:RegisterClassEvent("RealmChanged", function()
				frame.Status:SetText("")
				frame:Update()
			end)
		
		frame.ClassIcons.OnCharacterChanged = function()
				frame:Update()
			end
			
		frame.Equipment:StartAutoCastShine()
		frame.currentGridID = 1
	end,
	RegisterGrid = function(frame, gridID, callbacks)
		gridCallbacks[gridID] = callbacks
	end,
	InitializeGrid = function(frame, gridID)
		if gridCallbacks[gridID] then
			gridCallbacks[gridID].InitViewDDM(frame.SelectView, frame.TextView)
		end
		frame.currentGridID = gridID
	end,
	Update = function(frame)
		local account, realm = frame.SelectRealm:GetCurrentRealm()
		frame.ClassIcons:Update(account, realm)

		local grids = AltoholicFrameGrids
		local scrollFrame = grids.ScrollFrame
		local numRows = scrollFrame.numRows
		grids:Show()
			
		local offset = scrollFrame:GetOffset()
		frame:SetStatus("")
		
		local obj = gridCallbacks[frame.currentGridID]	-- point to the callbacks of the current object (equipment, tabards, ..)
		obj:OnUpdate()
		
		local size = obj:GetSize()
		local itemButton
		
		for rowIndex = 1, numRows do
			local rowFrame = scrollFrame:GetRow(rowIndex)
			local dataRowID = rowIndex + offset
			if dataRowID <= size then	-- if the row is visible

				obj:RowSetup(rowFrame, dataRowID)
				itemButton = rowFrame.Name
				itemButton:SetScript("OnEnter", obj.RowOnEnter)
				itemButton:SetScript("OnLeave", obj.RowOnLeave)
				
				for colIndex = 1, CHARS_PER_FRAME do
					itemButton = rowFrame["Item"..colIndex]
					itemButton.IconBorder:Hide()
					
					character = addon:GetOption(format("Tabs.Grids.%s.%s.Column%d", account, realm, colIndex))
					if character then
						itemButton:SetScript("OnEnter", obj.OnEnter)
						itemButton:SetScript("OnClick", obj.OnClick)
						itemButton:SetScript("OnLeave", obj.OnLeave)
						
						itemButton:Show()	-- note: this Show() must remain BEFORE the next call, if the button has to be hidden, it's done in ColumnSetup
						obj:ColumnSetup(itemButton, dataRowID, character)
					else
						itemButton.id = nil
						itemButton:Hide()
					end
				end

				rowFrame:Show()
			else
				rowFrame:Hide()
			end
		end

		scrollFrame:Update(size)
	end,
	UpdateMenuIcons = function(frame)
		if DataStore_Inventory then
			frame.Equipment:EnableIcon()
		else
			frame.Equipment:DisableIcon()
		end

		if DataStore_Reputations then
			frame.Factions:EnableIcon()
		else
			frame.Factions:DisableIcon()
		end

		if DataStore_Quests then
			frame.Attunements:EnableIcon()
			frame.Dailies:EnableIcon()
		else
			frame.Attunements:DisableIcon()
			frame.Dailies:DisableIcon()
		end
		
		if DataStore_Agenda then
			frame.Dungeons:EnableIcon()
		else
			frame.Dungeons:DisableIcon()
		end
	end,
	SetStatus = function(frame, text)
		frame.Status:SetText(text or "")
	end,
	SetViewDDMText = function(frame, text)
		frame.SelectView:SetText(text)
	end,
	GetRealm = function(frame)
		return frame.SelectRealm:GetCurrentRealm()	-- returns : account, realm
	end,
})
