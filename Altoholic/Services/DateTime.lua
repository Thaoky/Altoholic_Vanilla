local addonName = ...
local addon = _G[addonName]

local monthOffset = 0		-- month offset from the current month (-1 = past month, +1 = next month)

-- Porting https://wow.gamepedia.com/API_C_Calendar.GetMonthInfo here
-- Source: C# implementation of DateTime
-- https://referencesource.microsoft.com/#mscorlib/system/datetime.cs
local daysToMonth365 = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 }
local daysToMonth366 = { 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 }

local function IsLeapYear(year)
	return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function GetNumDaysInMonth(year, month)
	local days = IsLeapYear(year) and daysToMonth366 or daysToMonth365
	return days[month + 1] - days[month]
end

local function AddMonths(months)
	months = months or 0
	
	local DateInfo = C_DateAndTime.GetTodaysDate()
	local year = DateInfo.year
	local month = DateInfo.month
	local day = DateInfo.day
	
	local i = month - 1 + months
	
	if (i > 0) then
		month = math.floor(i % 12) + 1
		year = year + math.floor(i / 12)
	else
		-- this line changes from the C# implementation
		-- in C# : -2 % 12 = -2; -23 % 12 = -11; 23 % 12 = 11
		-- in Lua : -2 % 12 = 10 -23 % 12 = 1; 23 % 12 = 11
		month = 12 - (-(i+1) % 12)
		
		-- Same here :
		-- in C# : -23/12 = -1
		-- in Lua : -23/12 = -1.9.. so math.ceil
		year = year + math.ceil((i - 11) / 12)
	end
	
	-- adjust for last days of month
	-- 	if we are Jan 31st, and we add one month
	--		we should be Feb 28th or 29th
	local days = GetNumDaysInMonth(year, month)
	if day > days then day = days end
	
	return year, month, day
end

local function GetDateDifference(refDay, refMonth, refYear)
	-- Set the reference time to midnight on some day
	local reference = time { day = refDay, month = refMonth, year = refYear, hour = 0, min = 0}

	local hour = date("%H")
	local minute = date("%M")
	local secs = date("%S")
	local numSecs = (hour * 3600) + (minute * 60) + secs

	-- Calculate the difference between today at midnight (now - numSecs) and the reference date
	local daysFrom = difftime(time() - numSecs, reference) / (24 * 60 * 60) -- seconds in a day

	-- today = 0 days difference
	--	yesterday = 1 day has passed
	-- tomorrow = -1
	
	-- This should be an integer, but just in case, floor it.
	return math.floor(daysFrom)
end

addon:Service("AltoholicUI.DateTime", function()
	local service = {}

	service.GetMonthInfo = function(offset, monthOffset)
			offset = offset or 0
			monthOffset = monthOffset or 0
			
			local year, month = AddMonths(offset + monthOffset)
			
			local info = {}
			
			info.year = year					-- year : Year at the offset date (2004+)
			info.month = month				-- month	: Month index (1-12)
			
			-- numDays : Number of days in the month (28-31)
			info.numDays = GetNumDaysInMonth(info.year, info.month)
			
			-- firstWeekday : Weekday on which the month begins (1 = Sunday, 2 = Monday, ..., 7 = Saturday)	
			local daysDiff = GetDateDifference(1, month, year)
			daysDiff = -daysDiff % 7
			
			-- date("%w") ==> (0 = Sunday, 1 = Monday ..)
			local dayOfWeek = date("%w") + daysDiff
			
			-- Final adjustment
			if dayOfWeek >= 7 then dayOfWeek = dayOfWeek - 7 end
			
			-- adjust from Sunday = 0 to Sunday = 1
			info.firstWeekday = dayOfWeek + 1
			
			return info
		end
		
	service.GetDay = function(fullday)
			-- full day = a date as YYYY-MM-DD
			-- this function is actually different than the one in Blizzard_Calendar.lua, since weekday can't necessarily be determined from a UI button
			local refDate = {}		-- let's use the 1st of current month as reference date
			local refMonthFirstDay
			local _
			
			local CurMonthInfo = service.GetMonthInfo()
			refDate.month, refDate.year, refMonthFirstDay = CurMonthInfo.month, CurMonthInfo.year, CurMonthInfo.firstWeekday
			refDate.day = 1

			local t = {}
			local year, month, day = strsplit("-", fullday)
			t.year = tonumber(year)
			t.month = tonumber(month)
			t.day = tonumber(day)

			local numDays = floor(difftime(time(t), time(refDate)) / 86400)
			local weekday = mod(refMonthFirstDay + numDays, 7)
			
			-- at this point, weekday might be negative or 0, simply add 7 to keep it in the proper range
			weekday = (weekday <= 0) and (weekday+7) or weekday
			
			return t.year, t.month, t.day, weekday
		end
	
	return service
end)
