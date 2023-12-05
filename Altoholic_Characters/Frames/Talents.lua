local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local currentTalentGroup
local currentClass		-- ex: "MAGE"
local currentTreeName	-- ex: "Fire"
local currentTreeID
local currentGuildKey
local currentGuildMember	-- guild member currently displayed in the right pane
local currentGuildMemberTalentGroup = 1
local rightTreeKey		-- character key to use when drawing the rightmost tree

addon:Controller("AltoholicUI.TalentIcon", {
	Icon_OnEnter = function(frame)
		local treeName = DataStore:GetTreeNameByID(currentClass, frame:GetID())
		if treeName then
			AltoTooltip:ClearLines()
			AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT")
			AltoTooltip:AddLine(treeName,1,1,1)
			AltoTooltip:Show()
		end
	end,
	Icon_OnClick = function(frame, button)
		currentTreeID = frame:GetID()					-- set the current tree
		
		local group = frame:GetParent():GetID()	-- which group of icons did we click ? 1 to 4
		local isPlayer = (group < 3)					-- 1 or 2 = player, 3 or 4 = guild
		local isPrimary = (group % 2 == 1)			-- 1 or 3 = primary, 2 or 4 = secondary

		if isPlayer then
			if isPrimary then
				currentTalentGroup = 1
			else
				currentTalentGroup = 2
			end
		else
			if isPrimary then
				currentGuildMemberTalentGroup = 1
			else
				currentGuildMemberTalentGroup = 2
			end
		end
		
		frame:GetParent():GetParent():Update()
	end,
	
	StopAutoCast = function(frame)
		-- AutoCastShine_AutoCastStop(frame.Shine)
	end,

	StartAutoCast = function(frame, group, id)
		-- if an id is specified, start auto cast shine on this icon
		-- AutoCastShine_AutoCastStart(frame.Shine _G[ format("%s_Icons%d_SpecIcon%dShine", parent, group, id) ] )
	end,
	
})

addon:Controller("AltoholicUI.TalentPanel", {
	OnBind = function(frame)
		-- local function OnPlayerTalentUpdate()
			-- if frame:IsVisible() then
				-- frame:Update()
			-- end
		-- end	

		-- addon:RegisterEvent("PLAYER_TALENT_UPDATE", OnPlayerTalentUpdate)
		-- addon:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", OnPlayerTalentUpdate)
	end,
	DrawClassIcons = function(frame, iconGroup, class, character, guildMember)
		local text = frame[format("Icons%d", iconGroup)].Text
		local icon1 = frame[format("Icons%d", iconGroup)].SpecIcon1

		local isPlayer = (iconGroup < 3)					-- 1 or 2 = player, 3 or 4 = guild
		-- local isPrimary = (iconGroup % 2 == 1)			-- 1 or 3 = primary, 2 or 4 = secondary
		
		if isPlayer then
			text:SetJustifyH("LEFT")
			icon1:SetPoint("TOPLEFT", 10, -15)
		else
			text:SetJustifyH("RIGHT")
			icon1:SetPoint("TOPLEFT", 90, -15)
		end
		
		-- if isPrimary then
			text:SetText(TALENT_SPEC_PRIMARY)
		-- else
			-- text:SetText(TALENT_SPEC_SECONDARY)
		-- end
		
		local index = 1
		for tree in DataStore:GetClassTrees(class) do						-- draw spec icons
			local itemButton = frame[format("Icons%d", iconGroup)][format("SpecIcon%d", index)]
			local itemCount = itemButton.Count
			local icon = DataStore:GetTreeInfo(class, tree)
			
			itemButton.Icon:SetTexture(icon)
			
			local count = 0
			if character then
				count = DataStore:GetNumPointsSpent(character, tree)
			elseif guildMember then
				count = DataStore:GetGuildMemberNumPointsSpent(currentGuildKey, guildMember, tree)
			end
			itemCount:SetText(format("%s%d", colors.white, count))
			itemCount:Show()
			itemButton:Show()
			
			if not isPlayer then
				itemButton.Icon:SetDesaturated((character or guildMember) and 0 or 1)
			end
			
			index = index + 1
		end
	end,
	Update = function(frame)
		frame:Hide()
		
		local character = addon.Tabs.Characters:GetAltKey()
		if not character then return end
		
		AltoholicTabCharacters.Status:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), TALENTS))
		
		_, currentClass = DataStore:GetCharacterClass(character)
		if not DataStore:IsClassKnown(currentClass) then return end
		
		local level = DataStore:GetCharacterLevel(character)
		if not level or level < 10 then return end
		
		currentTreeName = DataStore:GetTreeNameByID(currentClass, currentTreeID or 1)

		-- background
		frame.PlayerSpec:DrawBackground(currentClass, currentTreeName)
		frame.GuildSpec:DrawBackground(currentClass, currentTreeName, (not currentGuildMember and not rightTreeKey))
		
		-- icons
		-- AutoCastShine_AutoCastStop(frame.Icons1.Shine)
		-- AutoCastShine_AutoCastStop(frame.Icons3.Shine)
		
		frame:DrawClassIcons(1, currentClass, character)
		-- frame:DrawClassIcons(2, currentClass, character)
		frame:DrawClassIcons(3, currentClass, rightTreeKey, currentGuildMember)
		-- frame:DrawClassIcons(4, currentClass, rightTreeKey, currentGuildMember)
		
		-- StartAutoCast(currentTalentGroup, currentTreeID)
		-- AutoCastShine_AutoCastStart( _G[ format("%s_Icons%d_SpecIcon%dShine", parent, group, id) ] )
		-- AutoCastShine_AutoCastStart(frame[format("Icons%d", i)].Shine)
		
		-- StartAutoCast(currentGuildMemberTalentGroup+2, currentTreeID)

		-- trees
		frame.PlayerSpec:DrawTree(currentClass, currentTreeName, character)
		frame.GuildSpec:DrawTree(currentClass, currentTreeName, rightTreeKey, currentGuildMember)
		
		frame:Show()
	end,
})
