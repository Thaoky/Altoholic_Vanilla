local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- *** Event Handlers ***

local function OnGuildAltsReceived(frame, event, sender, alts)
	frame.Members:InvalidateView()
	frame:Refresh()
end

local function OnGuildMemberOffline(frame, event, member)
	frame.Members:InvalidateView()
	frame:Refresh()
end

local function OnRosterUpdate(frame)
	local _, onlineMembers = GetNumGuildMembers()
	frame.MenuItem1.Text:SetText(format("%s %s(%d)", L["Guild Members"], colors.green, onlineMembers))
	
	frame.Members:InvalidateView()
	frame:Refresh()
end

addon:Controller("AltoholicUI.TabGuild", {
	OnBind = function(frame)
		frame.MenuItem1:SetText(L["Guild Members"])
		frame:MenuItem_Highlight(1)
		frame:SetMode(1)

		addon:RegisterMessage("DATASTORE_GUILD_ALTS_RECEIVED", OnGuildAltsReceived, frame)
		addon:RegisterMessage("DATASTORE_GUILD_MEMBER_OFFLINE", OnGuildMemberOffline, frame)
		
		if IsInGuild() then
			addon:RegisterEvent("GUILD_ROSTER_UPDATE", OnRosterUpdate, frame)
		end
	end,
	HideAll = function(frame)
		frame.Members:Hide()
	end,
	Refresh = function(frame)
		if frame.Members:IsVisible() then
			frame.Members:Update()
		end
	end,
	SetMode = function(frame, mode)
		if mode == 1 then
			frame.SortButtons:ShowChildFrames()
			frame.SortButtons:SetButton(1, NAME, 100, function() frame.Members:Sort("name") end)
			frame.SortButtons:SetButton(2, LEVEL, 60, function() frame.Members:Sort("level") end)
			frame.SortButtons:SetButton(3, "AiL", 65, function() frame.Members:Sort("averageItemLvl") end)
			frame.SortButtons:SetButton(4, GAME_VERSION_LABEL, 80, function() frame.Members:Sort("version") end)
			frame.SortButtons:SetButton(5, CLASS, 100, function() frame.Members:Sort("englishClass") end)
		else
			frame.SortButtons:HideChildFrames()
		end
	end,
	SetStatus = function(frame, text)
		frame.Status:SetText(text)
	end,
	MenuItem_Highlight = function(frame, id)
		-- highlight the current menu item
		local numItems = 1	-- number of menu items
		
		for i = 1, numItems do 
			frame["MenuItem"..i]:UnlockHighlight()
		end
		frame["MenuItem"..id]:LockHighlight()
	end,
	MenuItem_OnClick = function(frame, id, panel)
		frame:HideAll()
		frame:MenuItem_Highlight(id)

		frame:SetMode(id)
		
		if panel then
			frame[panel]:Update()
		end
	end,
})
