local addonName = ...
local addon = _G[addonName]
local colors = addon.Colors

addon:Service("AltoholicUI.Formatter",  function() 
	return {
		MoneyString = function(copper, color, noTexture)
			copper = copper or 0
			color = color or colors.gold

			local gold = floor(copper / 10000)
			copper = mod(copper, 10000)
			local silver = floor(copper / 100)
			copper = mod(copper, 100)

			if noTexture then				-- use noTexture for places where the texture does not fit too well,  ex: tooltips
				copper = format("%s%s%s%s", color, copper, "|cFFEDA55F", COPPER_AMOUNT_SYMBOL)
				silver = format("%s%s%s%s", color, silver, "|cFFC7C7CF", SILVER_AMOUNT_SYMBOL)
				gold = format("%s%s%s%s", color, gold, colors.gold, GOLD_AMOUNT_SYMBOL)
			else
				copper = color..format(COPPER_AMOUNT_TEXTURE, copper, 13, 13)
				silver = color..format(SILVER_AMOUNT_TEXTURE, silver, 13, 13)
				gold = color..format(GOLD_AMOUNT_TEXTURE_STRING, BreakUpLargeNumbers(gold), 13, 13)
			end
			return format("%s %s %s", gold, silver, copper)
		end,

		TimeString = function(seconds)
			seconds = seconds or 0      -- TotalTime is expressed in seconds

			local days = floor(seconds / 86400)
			seconds = mod(seconds, 86400)
			local hours = floor(seconds / 3600)
			seconds = mod(seconds, 3600)
			local minutes = floor(seconds / 60)
			seconds = mod(seconds, 60)

			return format("%s%s|rd %s%s|rh %s%s|rm", colors.white, days, colors.white, hours, colors.white, minutes)
		end,
        
		Delay = function(timeStamp)
			-- timeStamp = value when time() was last called for a given variable (ex: last time the mailbox was checked)
			if not timeStamp then return format("%s%s", colors.yellow, NEVER) end
			if timeStamp == 0 then return format("%sN/A", colors.yellow) end

			local seconds = (time() - timeStamp)

			-- 86400 seconds per day
			-- assuming 30 days / month = 2.592.000 seconds
			-- assuming 365 days / year = 31.536.000 seconds
			-- in the absence of possibility to track real dates, these approximations will have to do the trick, as it's not possible at this point to determine the number of days in a month, or in a year.

			local year = floor(seconds / 31536000)
			seconds = mod(seconds, 31536000)

			local month = floor(seconds / 2592000)
			seconds = mod(seconds, 2592000)

			local day = floor(seconds / 86400)
			seconds = mod(seconds, 86400)

			local hour = floor(seconds / 3600)
			seconds = mod(seconds, 3600)

			-- note: RecentTimeDate is not a direct API function, it's in UIParent.lua
			return RecentTimeDate(year, month, day, hour)
		end,
}end)
