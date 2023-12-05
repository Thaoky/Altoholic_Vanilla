local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local ICON_VIEW_QUESTS = "Interface\\LFGFrame\\LFGIcon-Quest"

local questList
local view

local function BuildView()
	questList = {}
	view = {}
	
	local account, realm = AltoholicTabGrids:GetRealm()
	
	-- Dailies are actual dailies that have been completed, + emissaries that have been completed
	for _, character in pairs(DataStore:GetCharacters(realm, account)) do	-- all alts on this realm
		local num = DataStore:GetDailiesHistorySize(character) or 0
		for i = 1, num do
			local id, title = DataStore:GetDailiesHistoryInfo(character, i)
			
			if not questList[id] then
				questList[id] = {}
				questList[id].title = title
				questList[id].completedBy = {}
			end
			
			questList[id].completedBy[character] = true
		end
	end
	
	for k, v in pairs(questList) do
		table.insert(view, k)
	end

	table.sort(view, function(a,b) 
		return questList[a].title < questList[b].title
	end)
end

local callbacks = {
	OnUpdate = function() 
			BuildView()
			if not questList then
				addon:RegisterMessage("DATASTORE_QUEST_TURNED_IN")
			end
			
			AltoholicTabGrids:SetStatus("Daily Quests")
		end,
	GetSize = function() return #view end,
	RowSetup = function(self, rowFrame, dataRowID)
			local name = questList[ view[dataRowID] ].title
			if name then
				rowFrame.Name.Text:SetText(format("%s%s", colors.white, name))
				rowFrame.Name.Text:SetJustifyH("LEFT")
			end
		end,
	RowOnEnter = function() end,
	RowOnLeave = function() end,
	ColumnSetup = function(self, button, dataRowID, character)
			button.Name:SetFontObject("GameFontNormalSmall")
			button.Name:SetJustifyH("CENTER")
			button.Name:SetPoint("BOTTOMRIGHT", 5, 0)
			button.Background:SetDesaturated(false)
			button.Background:SetTexCoord(0, 1, 0, 1)
			button.Background:SetTexture(ICON_VIEW_QUESTS)

			if questList[view[dataRowID]].completedBy[character]  then
				button.Background:SetVertexColor(1.0, 1.0, 1.0)
				button.Name:SetText(icons.ready)
			else
				button.Background:SetVertexColor(0.4, 0.4, 0.4)
				button.Name:SetText(icons.notReady)
			end
		end,
	OnEnter = nil,
	OnClick = nil,
	OnLeave = nil,
		
	InitViewDDM = function(frame, title) 
			frame:Hide()
			title:Hide()
		end,
}

function addon:DATASTORE_QUEST_TURNED_IN(event, sender, character)
	BuildView()
	AltoholicTabGrids:Update()
end

AltoholicTabGrids:RegisterGrid(3, callbacks)
