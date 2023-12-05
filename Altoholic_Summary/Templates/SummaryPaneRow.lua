local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local icons = addon.Icons

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local THIS_ACCOUNT = "Default"

local TEXTURE_HORDE = format("|T%s:%s:%s|t", icons.Horde, 18, 18)
local TEXTURE_ALLIANCE = format("|T%s:%s:%s|t", icons.Alliance, 18, 18)

local function EmptyFunc()
end

local function GetFactionTotals(f, line)
	local _, realm, account = addon.Characters:GetInfo(line)
	
	local level = 0
	local money = 0
	local played = 0
	
	-- to fix : this does not take filters into account !
	for _, character in pairs(DataStore:GetCharacters(realm, account)) do
		if DataStore:GetCharacterFaction(character) == f then
			level = level + DataStore:GetCharacterLevel(character)
			money = money + DataStore:GetMoney(character)
			played = played + DataStore:GetPlayTime(character)
		end
	end
	
	return level, money, played
end

local function ShowTotals(frame)
	local line = frame:GetParent():GetID()
	local tt = AltoTooltip
	
	tt:ClearLines()
	tt:SetOwner(frame, "ANCHOR_TOP")
	tt:AddLine(L["Totals"])
	
	local aLevels, aMoney, aPlayed = GetFactionTotals("Alliance", line)
	local hLevels, hMoney, hPlayed = GetFactionTotals("Horde", line)
	
	
	tt:AddLine(" ")
	tt:AddDoubleLine(format("%s%s", colors.white, L["Levels"]), format("%s%s", colors.white, addon.Characters:GetField(line, "level")))
	tt:AddDoubleLine(TEXTURE_ALLIANCE, format("%s%s", colors.white, aLevels))
	tt:AddDoubleLine(TEXTURE_HORDE, format("%s%s", colors.white, hLevels))
	
	tt:AddLine(" ")
	tt:AddDoubleLine(format("%s%s", colors.white, MONEY), addon:GetMoneyString(addon.Characters:GetField(line, "money")))
	tt:AddDoubleLine(TEXTURE_ALLIANCE, addon:GetMoneyString(aMoney, colors.white))
	tt:AddDoubleLine(TEXTURE_HORDE, addon:GetMoneyString(hMoney, colors.white))
	
	tt:AddLine(" ")
	tt:AddDoubleLine(format("%s%s", colors.white, PLAYED), addon.Characters:GetField(line, "played"))
	tt:AddDoubleLine(TEXTURE_ALLIANCE, addon:GetTimeString(aPlayed))
	tt:AddDoubleLine(TEXTURE_HORDE, addon:GetTimeString(hPlayed))
	
	
	-- tt:AddLine(" ",1,1,1)
	-- tt:AddDoubleLine(colors.white..L["Levels"] , format("%s|r (%s %s|r, %s %s|r)", 
		-- addon.Characters:GetField(line, "level"),
		-- TEXTURE_ALLIANCE, colors.white..aLevels,
		-- TEXTURE_HORDE, colors.white..hLevels))
	
	-- tt:AddLine(" ",1,1,1)
	-- tt:AddDoubleLine(colors.white..MONEY, format("%s|r (%s %s|r, %s %s|r)", 
		-- addon:GetMoneyString(addon.Characters:GetField(line, "money"), colors.white, true),
		-- TEXTURE_ALLIANCE, addon:GetMoneyString(aMoney, colors.white, true),
		-- TEXTURE_HORDE, addon:GetMoneyString(hMoney, colors.white, true)))
	
	-- tt:AddLine(" ",1,1,1)
	-- tt:AddDoubleLine(colors.white..PLAYED , format("%s|r (%s %s|r, %s %s|r)",
		-- addon.Characters:GetField(line, "played"),
		-- TEXTURE_ALLIANCE, addon:GetTimeString(aPlayed),
		-- TEXTURE_HORDE, addon:GetTimeString(hPlayed)))
	
	tt:Show()
end

addon:Controller("AltoholicUI.SummaryPaneRow", {
	HideItems = function(frame, from, to)
		for i = from, to do
			frame["Item"..i]:Hide()
		end
	end,
	DrawRealmLine = function(frame, line, realm, account, Name_OnClick)
		local item = frame.Item1
		
		item:SetWidth(300)
		item:SetPoint("TOPLEFT", 25, 0)
		item.Text:SetWidth(300)
		item.Text:SetJustifyH("LEFT")

		if account == THIS_ACCOUNT then	-- saved as default, display as localized.
			item.Text:SetText(format("%s (%s".. L["Account"]..": %s%s|r)", realm, colors.white, colors.green, L["Default"]))
		else
			local last = addon:GetLastAccountSharingInfo(realm, account)
			item.Text:SetText(format("%s (%s".. L["Account"]..": %s%s %s%s|r)", realm, colors.white, colors.green, account, colors.yellow, last or ""))
		end

		item:SetScript("OnEnter", EmptyFunc)
		item:SetScript("OnClick", Name_OnClick)	-- this one is temporary, split the delete realm from delete char

		frame.Collapse:Show()
		frame.character = nil
		frame:HideItems(2, 10)
		frame:SetID(line)
		frame:Show()
	end,
	DrawCharacterLine = function(frame, line, columns, currentMode)
		local character = DataStore:GetCharacter( addon.Characters:GetInfo(line) )
		
		frame.Collapse:Hide()
		frame.Item1:SetPoint("TOPLEFT", 10, 0)

		-- fill the visible cells for this mode
		for i = 1, #currentMode do
			frame["Item"..i]:SetColumnData(character, columns[currentMode[i]])
		end
		
		frame.character = character
		frame:HideItems(#currentMode+1, 10)
		frame:SetID(line)
		frame:Show()
	end,
	DrawTotalLine = function(frame, line, columns, currentMode)
		frame.Collapse:Hide()

		-- fill the visible cells for this mode
		for i = 1, #currentMode do
			frame["Item"..i]:SetColumnTotal(line, columns[currentMode[i]])
		end

		frame.Item1:SetPoint("TOPLEFT", 10, 0)
		frame.Item1:SetScript("OnEnter", ShowTotals)
		
		frame.character = nil
		frame:HideItems(#currentMode+1, 10)
		frame:SetID(line)
		frame:Show()
	end,
})
