-- This file manages the events (calendar, cooldowns, etc..) supported by the addon

local addonName = ...
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

addon.Events = {}

local ns = addon.Events		-- ns = namespace

local IsNumberInString = addon.Helpers.IsNumberInString
local timerThresholds = { 30, 15, 10, 5, 4, 3, 2, 1 }
local timeTable = {}	-- to pass as an argument to time()	see http://lua-users.org/wiki/OsLibraryTutorial for details
local eventList

local function GetEventExpiry(event)
	-- returns the number of seconds in which a calendar event expires
	assert(type(event) == "table")

	local year, month, day = strsplit("-", event.eventDate)
	local hour, minute = strsplit(":", event.eventTime)

	timeTable.year = tonumber(year)
	timeTable.month = tonumber(month)
	timeTable.day = tonumber(day)
	timeTable.hour = tonumber(hour)
	timeTable.min = tonumber(minute)

	local gap = 0
	if DataStore_Agenda then
		gap = DataStore:GetClientServerTimeGap() or 0
	end
	
	return difftime(time(timeTable), time() + gap)	-- in seconds
end

-- ** Event Types **
local COOLDOWN_LINE = 1
local INSTANCE_LINE = 2
local CALENDAR_LINE = 3
local CONNECTMMO_LINE = 4
local TIMER_LINE = 5
local SHARED_CD_LINE = 6		-- this type is used for shared cooldowns (alchemy, etc..) among others.

local WARNING_TYPE_PROFESSION_CD = 1
local WARNING_TYPE_DUNGEON_RESET = 2
local WARNING_TYPE_CALENDAR_EVENT = 3
local WARNING_TYPE_ITEM_TIMER = 4

local eventToWarningType = {
	[COOLDOWN_LINE] = WARNING_TYPE_PROFESSION_CD,
	[INSTANCE_LINE] = WARNING_TYPE_DUNGEON_RESET,
	[CALENDAR_LINE] = WARNING_TYPE_CALENDAR_EVENT,
	[CONNECTMMO_LINE] = WARNING_TYPE_CALENDAR_EVENT,
	[TIMER_LINE] = WARNING_TYPE_ITEM_TIMER,
	[SHARED_CD_LINE] = WARNING_TYPE_PROFESSION_CD,
}

local eventTypes = {
	[COOLDOWN_LINE] = {
		GetReadyNowWarning = function(self, event)
				local name = DataStore:GetCraftCooldownInfo(event.source, event.parentID)
				return format(L["%s is now ready (%s on %s)"], name, event.char, event.realm)
			end,
		GetReadySoonWarning = function(self, event, minutes)
				local name = DataStore:GetCraftCooldownInfo(event.source, event.parentID)
				return format(L["%s will be ready in %d minutes (%s on %s)"], name, minutes, event.char, event.realm)
			end,
		GetInfo = function(self, event)
				local title, expiresIn = DataStore:GetCraftCooldownInfo(event.source, event.parentID)
				return title, format("%s %s", COOLDOWN_REMAINING, addon:GetTimeString(expiresIn))
			end,
	},
	[INSTANCE_LINE] = {
		GetReadyNowWarning = function(self, event)
				local instance = strsplit("|", event.parentID)
				return format(L["%s is now unlocked (%s on %s)"], instance, event.char, event.realm)
			end,
		GetReadySoonWarning = function(self, event, minutes)
				local instance = strsplit("|", event.parentID)
				return format(L["%s will be unlocked in %d minutes (%s on %s)"], instance, minutes, event.char, event.realm)
			end,
		GetInfo = function(self, event)
				-- title gets the instance name, desc gets the raid id
				local instanceName, raidID = strsplit("|", event.parentID)
		
				--	CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT = "%s Unlocks"; -- %s = Raid Name
				return instanceName, format("%s%s\nID: %s%s", colors.white,	format(CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT, instanceName), colors.green, raidID)
			end,
	},
	[CALENDAR_LINE] = {
		GetReadyNowWarning = function(self, event)
				local character = DataStore:GetCharacter(event.char, event.realm)
				local _, _, title = DataStore:GetCalendarEventInfo(character, event.parentID)
				return format(CALENDAR_EVENTNAME_FORMAT_START .. " (%s/%s)", title, event.char, event.realm)
			end,
		GetReadySoonWarning = function(self, event, minutes)
				local character = DataStore:GetCharacter(event.char, event.realm)
				local _, _, title = DataStore:GetCalendarEventInfo(character, event.parentID)
				return format(L["%s starts in %d minutes (%s on %s)"], title, minutes, event.char, event.realm)
			end,
		GetInfo = function(self, event)
				local character = DataStore:GetCharacter(event.char, event.realm)
				local _, _, title, eventType, inviteStatus = DataStore:GetCalendarEventInfo(character, event.parentID)

				inviteStatus = tonumber(inviteStatus)
				
				local desc
				if type(inviteStatus) == "number" and (inviteStatus > 1) and (inviteStatus < 8) then
					local StatusText = {
						CALENDAR_STATUS_INVITED,		-- CALENDAR_INVITESTATUS_INVITED   = 1
						CALENDAR_STATUS_ACCEPTED,		-- CALENDAR_INVITESTATUS_ACCEPTED  = 2
						CALENDAR_STATUS_DECLINED,		-- CALENDAR_INVITESTATUS_DECLINED  = 3
						CALENDAR_STATUS_CONFIRMED,		-- CALENDAR_INVITESTATUS_CONFIRMED = 4
						CALENDAR_STATUS_OUT,				-- CALENDAR_INVITESTATUS_OUT       = 5
						CALENDAR_STATUS_STANDBY,		-- CALENDAR_INVITESTATUS_STANDBY   = 6
						CALENDAR_STATUS_SIGNEDUP,		-- CALENDAR_INVITESTATUS_SIGNEDUP     = 7
						CALENDAR_STATUS_NOT_SIGNEDUP	-- CALENDAR_INVITESTATUS_NOT_SIGNEDUP = 8
					}
				
					desc = format("%s: %s", STATUS, colors.white..StatusText[inviteStatus]) 
				else 
					desc = format("%s", STATUS) 
				end
		
				return title, desc
			end,
	},
	[CONNECTMMO_LINE] = {
		GetReadyNowWarning = function(self, event) end,
		GetReadySoonWarning = function(self, event, minutes) end,
		GetInfo = function(self, event) end,
	},
	[TIMER_LINE] = {
		GetReadyNowWarning = function(self, event)
				local character = DataStore:GetCharacter(event.char, event.realm)
				local item = GetItemInfo(event.parentID)
				if item then
					return format(L["%s is now ready (%s on %s)"], item, event.char, event.realm)
				end
			end,
		GetReadySoonWarning = function(self, event, minutes)
				local character = DataStore:GetCharacter(event.char, event.realm)
				local item = GetItemInfo(event.parentID)
				if item then
					return format(L["%s will be ready in %d minutes (%s on %s)"], item, minutes, event.char, event.realm)
				end
			end,
		GetInfo = function(self, event)
				local character = DataStore:GetCharacter(event.char, event.realm)
				local item = GetItemInfo(event.parentID)
				local expiresIn = GetEventExpiry(event)
				return item, format("%s %s", COOLDOWN_REMAINING, Altoholic:GetTimeString(expiresIn))
			end,
	},
	[SHARED_CD_LINE] = {
		GetReadyNowWarning = function(self, event)
				return format(L["%s is now ready (%s on %s)"], event.source, event.char, event.realm)
			end,
		GetReadySoonWarning = function(self, event, minutes)
				return format(L["%s will be ready in %d minutes (%s on %s)"], event.source, minutes, event.char, event.realm)
			end,
		GetInfo = function(self, event)
				local expiresIn = GetEventExpiry(event)
				return event.source, format("%s %s", COOLDOWN_REMAINING, addon:GetTimeString(expiresIn))
			end,
	},
}

-- *** Utility functions ***
local function AddEvent(eventType, eventDate, eventTime, char, realm, account, index, externalTable)
	table.insert(eventList, {
		eventType = eventType, 
		eventDate = eventDate, 
		eventTime = eventTime, 
		char = char,
		realm = realm,
		account = account,
		parentID = index,
		source = externalTable})
end

local function SortEvents()
	table.sort(eventList, function(a, b)
		if (a.eventDate ~= b.eventDate) then			-- sort by date first ..
			return a.eventDate < b.eventDate
		elseif (a.eventTime ~= b.eventTime) then		-- .. then by hour
			return a.eventTime < b.eventTime
		elseif (a.char ~= b.char) then					-- .. then by alt
			return a.char < b.char
		end
	end)
end

local function ClearExpiredEvents()
	
	for account in pairs(DataStore:GetAccounts()) do
		for realm in pairs(DataStore:GetRealms(account)) do
			for characterName, character in pairs(DataStore:GetCharacters(realm, account)) do
				-- Profession Cooldowns
				local professions = DataStore:GetProfessions(character)
				if professions then
					for professionName, profession in pairs(professions) do
						DataStore:ClearExpiredCooldowns(profession)
					end
				end
				
				-- Saved Instances
				local dungeons = DataStore:GetSavedInstances(character)
				if dungeons then
					for key, _ in pairs(dungeons) do
						if DataStore:HasSavedInstanceExpired(character, key) then
							DataStore:DeleteSavedInstance(character, key)
						end
					end
				end
				
				-- Calendar events 
				local num = DataStore:GetNumCalendarEvents(character) or 0 
				for i = num, 1, -1 do
					if DataStore:HasCalendarEventExpired(character, i) then
						DataStore:DeleteCalendarEvent(character, i)
					end
				end
			end
		end
	end
	
	ns:BuildList()
end

local function Warning_MsgBox_Handler(self, button)
	if not button then return end

	addon:ToggleUI()
	addon.Tabs:OnClick("Agenda")
	addon.Tabs.Agenda:MenuItem_OnClick(1)
end

local function ShowExpiryWarning(index, minutes)
	local event = ns:Get(index)
	local CalendarEvent = eventTypes[event.eventType]
	
	local warning
	if minutes == 0 then
		warning = CalendarEvent:GetReadyNowWarning(event)
	else
		warning = CalendarEvent:GetReadySoonWarning(event, minutes)
	end
	if not warning then return end
	
	-- print instead of dialog box if player is in combat
	if addon:GetOption("UI.Calendar.UseDialogBoxForWarnings") and not UnitAffectingCombat("player") then
		AltoMessageBox:SetHandler(Warning_MsgBox_Handler)
		AltoMessageBox:SetText(format("%s%s\n%s", colors.white, warning, L["Do you want to open Altoholic's calendar for details ?"]))
		AltoMessageBox:Show()
	else
		addon:Print(warning)
	end
end

local function InitialExpiryCheck()
	for index, event in pairs(eventList) do			-- browse all events
		local expiresIn = GetEventExpiry(event)
		if expiresIn < 0 then					-- if the event has expired
			event.markForDeletion = true		-- .. mark it for deletion (no table.remove in this pass, to avoid messing up indexes)
			ShowExpiryWarning(index, 0)		-- .. and do the appropriate warning
		end
	end
	
	for i = #eventList, 1, -1 do			-- browse the event table backwards
		if eventList[i].markForDeletion then	-- erase marked events
			table.remove(eventList, i)
		end
	end
	
	ClearExpiredEvents()
end

local function ToggleWarningThreshold(self)
	local id = self.arg1
	local warnings = addon:GetOption("WarningType"..id)		-- Gets something like "15|5|1"
	
	local t = {}		-- create a temporary table to store checked values
	for v in warnings:gmatch("(%d+)") do
		v = tonumber(v)
		if v ~= self.value then		-- add all values except the one that was clicked
			table.insert(t, v)
		end
	end
	
	if not IsNumberInString(self.value, warnings) then		-- if number is not yet in the string, save it (we're checking it, otherwise we're unchecking)
		table.insert(t, self.value)
	end
	
	addon:SetOption("WarningType"..id, table.concat(t, "|"))		-- Sets something like "15|5|10|1"
end

function ns:Get(index)
	return eventList[index]
end

function ns:GetList()
	return eventList
end

function ns:GetInfo(index)
	local event = ns:Get(index)		-- dereference event
	if not event then return end
	
	local character = DataStore:GetCharacter(event.char, event.realm, event.account)
	local char = DataStore:GetColoredCharacterName(character)
	
	if event.realm ~= GetRealmName() then	-- different realm ?
		char = format("%s %s(%s)", char, colors.green, event.realm)
	end
	
	local title, desc = eventTypes[event.eventType]:GetInfo(event)

	return char, event.eventTime, title, desc, character, event.eventType, event.parentID 
end

function ns:GetDayCount(year, month, day)
	-- returns the number of events on a given day
	
	local eventDate = format("%04d-%02d-%02d", year, month, day)
	local count = 0
	for k, v in pairs(eventList) do
		if v.eventDate == eventDate then
			count = count + 1
		end
	end
	return count
end

function ns:CheckExpiries(elapsed)
	if addon:GetOption("UI.Calendar.WarningsEnabled") == false then	-- warnings disabled ? do nothing
		return
	end

	-- called every 60 seconds
	local hasEventExpired
	
	for k, v in pairs(eventList) do
		local numMin = floor(GetEventExpiry(v) / 60)

		if numMin > -1440 and numMin < 0 then		-- expiry older than 1 day is ignored
			hasEventExpired = true		-- at least one event has expired
		elseif numMin == 0 then
			ShowExpiryWarning(k, 0)
			hasEventExpired = true		-- at least one event has expired
		elseif numMin > 0 and numMin <= 30 then
			local warnings = addon:GetOption("WarningType"..eventToWarningType[v.eventType])		-- Gets something like "15|5|1"
			for _, threshold in pairs(timerThresholds) do
				if threshold == numMin then			-- if snooze is allowed for this value
					if IsNumberInString(threshold, warnings) then
						ShowExpiryWarning(k, numMin)
					end
					break
				elseif threshold < numMin then		-- save some cpu cycles, exit if threshold too low
					break
				end
			end
		end
	end
	
	if hasEventExpired then		-- if at least one event has expired, rebuild the list & Update
		ClearExpiredEvents()
		
		-- should be removed, nothing to do here
		-- nsEvents:BuildView()
		-- Altoholic.Summary:Update()
	end
end

function ns:WarningType_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	local id = self:GetID()
	local warnings = addon:GetOption("WarningType"..id)		-- Gets something like "15|5|1"
	
	for _, threshold in pairs(timerThresholds) do
		info.text = format(D_MINUTES, threshold)
		info.value = threshold
		info.func = ToggleWarningThreshold
		info.checked = IsNumberInString(threshold, warnings)
		info.arg1 = id		-- save the id of the current option
		UIDropDownMenu_AddButton(info, 1); 
	end
end

function ns:BuildList()
	eventList = eventList or {}
	wipe(eventList)

	local timeGap = DataStore:GetClientServerTimeGap() or 0
	
	for account in pairs(DataStore:GetAccounts()) do
		for realm in pairs(DataStore:GetRealms(account)) do
			for characterName, character in pairs(DataStore:GetCharacters(realm, account)) do
				-- add all timers, even expired ones. Expiries will be handled elsewhere.
				
				-- Profession Cooldowns
				local professions = DataStore:GetProfessions(character)
				if professions then
					for professionName, profession in pairs(professions) do
						local supportsSharedCD
						if professionName == GetSpellInfo(2259) or			-- alchemy
							-- professionName == GetSpellInfo(3908) or 			-- tailoring
							professionName == GetSpellInfo(2575) then			-- mining
							supportsSharedCD = true		-- current profession supports shared cooldowns
						end
						
						if supportsSharedCD then
							local sharedCDFound		-- is there a shared cd for this profession ?
							for i = 1, DataStore:GetNumActiveCooldowns(profession) do
								local _, _, _, expiresAt = DataStore:GetCraftCooldownInfo(profession, i)

								if not sharedCDFound then
									sharedCDFound = true
									AddEvent(SHARED_CD_LINE, date("%Y-%m-%d", expiresAt), date("%H:%M", expiresAt), characterName, realm, account, nil, professionName)
								end
							end
						else
							for i = 1, DataStore:GetNumActiveCooldowns(profession) do
								local _, _, _, expiresAt = DataStore:GetCraftCooldownInfo(profession, i)
								AddEvent(COOLDOWN_LINE, date("%Y-%m-%d", expiresAt), date("%H:%M", expiresAt), characterName, realm, account, i, profession)
							end
						end
					end
				end

				-- Saved Instances
				local dungeons = DataStore:GetSavedInstances(character)
				if dungeons then
					for key, _ in pairs(dungeons) do
						local reset, lastCheck = DataStore:GetSavedInstanceInfo(character, key)
						local expires = reset + lastCheck + timeGap
						
						AddEvent(INSTANCE_LINE, date("%Y-%m-%d",expires), date("%H:%M",expires), characterName, realm, account, key)
					end
				end
				
				-- Calendar Events
				local num = DataStore:GetNumCalendarEvents(character) or 0 
				for i = 1, num do
					local eventDate, eventTime = DataStore:GetCalendarEventInfo(character, i)
					
					-- TODO: do not add declined invitations
					AddEvent(CALENDAR_LINE, eventDate, eventTime, characterName, realm, i)
				end
				
				-- Salt Shaker
				local saltShakerID = 15846
				
				DataStore:SearchBagsForItem(character, saltShakerID, function(bagName, container, slotID) 
					local startTime, duration = DataStore:GetContainerCooldownInfo(container, slotID)
					if startTime then
						local expires = startTime + duration
						AddEvent(TIMER_LINE, date("%Y-%m-%d",expires), date("%H:%M",expires), characterName, realm, account, saltShakerID)				
					end
				end)
			end
		end
	end
	
	-- sort by time
	SortEvents()
end

function ns:Init()
	--[[ Sequence of operations : 
	
		Build a list of events
		Check for expiries  + Warning
		Clear expiries
		Rebuild the list of events
	--]]
	
	ns:BuildList()
	InitialExpiryCheck()
end
