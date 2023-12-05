local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

addon:Controller("AltoholicUI.CalendarEvent", {
	SetDate = function(frame, weekdayName, monthName, day, year, month)
		frame.Date:SetText(format(FULLDATE, weekdayName, monthName, day, year, month))
		frame.Date:Show()
		frame.Background:Show()

		frame.Hour:Hide()
		frame.Character:Hide()
		frame.Title:Hide()
	end,
	SetInfo = function(frame, characterName, eventTime, title)
		frame.Hour:SetText(eventTime)
		frame.Character:SetText(characterName)
		frame.Title:SetText(title)
		
		frame.Hour:Show()
		frame.Character:Show()
		frame.Title:Show()

		frame.Date:Hide()
		frame.Background:Hide()
	end,
	Event_OnEnter = function(frame)
		-- local s = view[frame:GetID()]
		-- if not s or s.linetype == EVENT_DATE then return end
		
		local eventList = frame:GetParent()
		local eventIndex = eventList:GetEventIndex(frame:GetID())
		if not eventIndex then return end
		
		AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		AltoTooltip:ClearLines()
		-- local eventDate = format("%04d-%02d-%02d", self.year, self.month, self.day)
		-- local weekday = GetWeekdayIndex(mod(self:GetID(), 7))
		-- AltoTooltip:AddLine(colors.teal..format(FULLDATE, GetFullDate(weekday, self.month, self.day, self.year)));
		
		-- local char, eventTime, title, desc = addon.Events:GetInfo(s.parentID)
		
		local char, eventTime, title, desc, character, eventType, parentID = addon.Events:GetInfo(eventIndex)
		
		AltoTooltip:AddDoubleLine(format("%s%s %s", colors.white, eventTime, char), title)
		if desc then
			AltoTooltip:AddLine(" ")
			AltoTooltip:AddLine(desc)
		end
		
		-- 2 = INSTANCE_LINE, add the bosskills
		if eventType == 2 then
			AltoTooltip:AddLine(" ")
	
			for i = 1, DataStore:GetSavedInstanceNumEncounters(character, parentID) do
				local name, isKilled = DataStore:GetSavedInstanceEncounterInfo(character, parentID, i)
				local color = isKilled and colors.green or colors.red
	
				AltoTooltip:AddLine(format("%s%s", color, name))
			end
		end
		
		AltoTooltip:Show()
	end,
})
