local addonName = ...

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0", "LibMVC-1.0")

local addon = _G[addonName]

addon.Version = "v1.15.007"
addon.VersionNum = 115007

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local commPrefix = addonName

BINDING_HEADER_ALTOHOLIC = addonName
BINDING_NAME_ALTOHOLIC_TOGGLE = "Toggle UI"

local options = { 
	type = "group",
	args = {
		search = {
			type = "input",
			name = L['search'],
			usage = "<item name>",
			desc = L["Search in bags"],
			get = false,
			set = "CmdSearchBags",
		},
		show = {
			type = "execute",
			name = L['show'],
			desc = L["Shows the UI"],
			func = function() AltoholicFrame:Show() end
		},
		hide = {
			type = "execute",
			name = L['hide'],
			desc = L["Hides the UI"],
			func = function() AltoholicFrame:Hide() end
		},
		toggle = {
			type = "execute",
			name = L['toggle'],
			desc = L["Toggles the UI"],
			func = function() addon:ToggleUI() end
		},
	},
}
 
local AddonDB_Defaults = {
	global = {
		Guilds = {
			['*'] = {			-- ["Account.Realm.Name"] 
				hideInTooltip = nil,		-- true if this guild should not be shown in the tooltip counters
			},
		},
		Characters = {
			['*'] = {					-- ["Account.Realm.Name"] 
			},
		},
		Sharing = {
			Clients = {},
			SharedContent = {			-- lists the shared content
				--	["Account.Realm.Name"]  = true means the char is shared,
				--	["Account.Realm.Name.Module"]  = true means the module is shared for that char
			},
			Domains = {
				['*'] = {			-- ["Account.Realm"] 
					lastSharingTimestamp = nil,	-- a date, the last time information from this realm/account was queried and successfully saved.
					lastUpdatedWith = nil,		-- last player with whom the account sharing took place
				},
			},
		},
		unsafeItems = {},
		options = {
			-- ** Summary tab options **
			["UI.Tabs.Summary.ShowRestXP150pc"] = false,						-- display max rest xp in normal 100% mode or in level equivalent 150% mode ?
			["UI.Tabs.Summary.CurrentMode"] = 1,								-- current mode (1 = account summary, 2 = bags, ...)
			["UI.Tabs.Summary.CurrentColumn"] = "Name",						-- current column (default = "Name")
			["UI.Tabs.Summary.CurrentRealms"] = 2,								-- selected realms (current/all in current/all accounts)
			["UI.Tabs.Summary.CurrentFactions"] = 3,							-- 1 = Alliance, 2 = Horde, 3 = Both
			["UI.Tabs.Summary.CurrentLevels"] = 1,								-- 1 = All
			["UI.Tabs.Summary.CurrentLevelsMin"] = 1,							
			["UI.Tabs.Summary.CurrentLevelsMax"] = 70,					
			["UI.Tabs.Summary.CurrentClasses"] = 0,							-- 0 = All
			["UI.Tabs.Summary.CurrentTradeSkill"] = 0,						-- 0 = All
			["UI.Tabs.Summary.SortAscending"] = true,							-- ascending or descending sort order
			["UI.Tabs.Summary.ShowLevelDecimals"] = true,					-- display character level with decimals or not
			["UI.Tabs.Summary.ShowILevelDecimals"] = true,					-- display character level with decimals or not
			
			-- ** Character tab options **
			["UI.Tabs.Characters.ViewBags"] = true,
			["UI.Tabs.Characters.ViewBank"] = true,
			["UI.Tabs.Characters.ViewBagsAllInOne"] = false,
			["UI.Tabs.Characters.ViewBagsRarity"] = 0,						-- rarity level of items (not a boolean !)
			["UI.Tabs.Characters.SortAscending"] = true,						-- ascending or descending sort order
						
			-- ** Search tab options **
			["UI.Tabs.Search.ItemInfoAutoQuery"] = false,
			["UI.Tabs.Search.IncludeNoMinLevel"] = true,				-- include items with no minimum level
			["UI.Tabs.Search.IncludeMailboxItems"] = true,
			["UI.Tabs.Search.IncludeKnownRecipes"] = true,
			["UI.Tabs.Search.SortAscending"] = true,							-- ascending or descending sort order
			TotalLoots = 0,					-- make at least one search in the loot tables to initialize these values
			UnknownLoots = 0,
			
			-- ** Guild Bank tab options **
			["UI.Tabs.Guild.BankItemsRarity"] = 0,								-- rarity filter in the guild bank tab
			["UI.Tabs.Guild.BankAutoUpdate"] = false,							-- can the guild bank tabs update requests be answered automatically or not.
			["UI.Tabs.Guild.SortAscending"] = true,							-- ascending or descending sort order
			
			-- ** Grids tab options **
			["UI.Tabs.Grids.Reputations.CurrentXPack"] = 1,					-- Current expansion pack 
			["UI.Tabs.Grids.Reputations.CurrentFactionGroup"] = 1,		-- Current faction group in that xpack
			["UI.Tabs.Grids.Currencies.CurrentTokenType"] = nil,			-- Current token type (default to nil = all-in-one)
			["UI.Tabs.Grids.Tradeskills.CurrentXPack"] = 1,					-- Current expansion pack 
			["UI.Tabs.Grids.Tradeskills.CurrentTradeSkill"] = 1,			-- Current tradeskill index
			["UI.Tabs.Grids.Dungeons.CurrentXPack"] = 1,						-- Current expansion pack 
			["UI.Tabs.Grids.Dungeons.CurrentRaids"] = 1,						-- Current raid index

			-- ** Tooltip options **
			["UI.Tooltip.ShowItemSource"] = true,
			["UI.Tooltip.ShowItemCount"] = true,
			["UI.Tooltip.ShowSimpleCount"] = false,				-- display just the counter, without details (like AH, equipped, etc..)
			["UI.Tooltip.ShowTotalItemCount"] = true,
			["UI.Tooltip.ShowKnownRecipes"] = true,
			["UI.Tooltip.ShowItemID"] = false,						-- display item id & item level in the tooltip (default: off)
			["UI.Tooltip.ShowGatheringNodesCount"] = true,		-- display counters when mousing over a gathering node (default:  on)
			["UI.Tooltip.ShowCrossFactionCount"] = true,			-- display counters for both factions on a pve server
			["UI.Tooltip.ShowMergedRealmsCount"] = true,			-- display counters for characters on connected realms
			["UI.Tooltip.ShowAllAccountsCount"] = true,			-- display counters for all accounts on the same realm
			["UI.Tooltip.ShowSellPrice"] = true,					-- Sell price per unit
			
			-- ** Mail options **
			["UI.Mail.GuildMailWarning"] = true,					-- be informed when a guildie sends a mail to one of my alts
			["UI.Mail.AutoCompleteRecipient"] = true,				-- Auto complete recipient name when sending a mail
			["UI.Mail.LastExpiryWarning"] = 0,						-- Last time a mail expiry warning was triggered
			["UI.Mail.TimeToNextWarning"] = 3,						-- Time before the warning is repeated ('3' = no warning for 3 hours)
			
			-- ** Minimap options **
			["UI.Minimap.ShowIcon"] = true,
			["UI.Minimap.IconAngle"] = 180,
			["UI.Minimap.IconRadius"] = 78,
			
			-- ** Calendar options **
			["UI.Calendar.WarningsEnabled"] = true,
			["UI.Calendar.UseDialogBoxForWarnings"] = false,	-- use a dialog box for warnings (true), or default chat frame (false)
			["UI.Calendar.WeekStartsOnMonday"] = false,

			WarningType1 = "30|15|10|5|4|3|2|1",		-- for profession cooldowns
			WarningType2 = "30|15|10|5|4|3|2|1",		-- for dungeon resets
			WarningType3 = "30|15|10|5|4|3|2|1",		-- for calendar events
			WarningType4 = "30|15|10|5|4|3|2|1",		-- for item timers (like mysterious egg)
			
			-- ** Global options **
			["UI.AHColorCoding"] = true,					-- color coded recipes at the AH
			["UI.VendorColorCoding"] = true,				-- color coded recipes at vendors
			["UI.AccountSharing.IsEnabled"] = false,	-- account sharing communication handler is disabled by default
			
			["UI.Scale"] = 1.0,
			["UI.Transparency"] = 1.0,
			["UI.ClampWindowToScreen"] = false,

		},
	}
}

addon.Colors = {
	white	= "|cFFFFFFFF",
	red = "|cFFFF0000",
	darkred = "|cFFF00000",
	green = "|cFF00FF00",
	orange = "|cFFFF7F00",
	yellow = "|cFFFFFF00",
	gold = "|cFFFFD700",
	teal = "|cFF00FF9A",
	cyan = "|cFF1CFAFE",
	lightBlue = "|cFFB0B0FF",
	battleNetBlue = "|cff82c5ff",
	grey = "|cFF909090",
	
	-- classes
	classMage = "|cFF69CCF0",
	classHunter = "|cFFABD473",
	
	-- recipes
	recipeGrey = "|cFF808080",
	recipeGreen = "|cFF40C040",
	recipeOrange = "|cFFFF8040",
	
	-- rarity : http://wow.gamepedia.com/Quality
	common = "|cFFFFFFFF",
	uncommon = "|cFF1EFF00",
	rare = "|cFF0070DD",
	epic = "|cFFA335EE",
	legendary = "|cFFFF8000",
	heirloom = "|cFFE6CC80",

	Alliance = "|cFF2459FF",
	Horde = "|cFFFF0000"
}

addon.Icons = {
	ready = "\124TInterface\\RaidFrame\\ReadyCheck-Ready:14\124t",
	waiting = "\124TInterface\\RaidFrame\\ReadyCheck-Waiting:14\124t",
	notReady = "\124TInterface\\RaidFrame\\ReadyCheck-NotReady:14\124t",
	questionMark = "Interface\\RaidFrame\\ReadyCheck-Waiting",

	Alliance = "Interface\\Icons\\INV_BannerPVP_02",
	Horde = "Interface\\Icons\\INV_BannerPVP_01",
	Neutral = "Interface\\Icons\\Achievement_character_pandaren_female",
}

-- ** LDB Launcher **
LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(addonName, {
	type = "launcher",
	icon = "Interface\\Icons\\INV_Drink_13",
	OnClick = function(clickedframe, button)
		addon:ToggleUI()
	end,
	text = (Broker2FuBar) and addonName or nil,		-- only for fubar,  not for ldb
	label = addonName,
})



local guildMembersVersion = {} 	-- hash table containing guild member info

-- Message types
local MSG_SEND_VERSION							= 1	-- Send Altoholic's version
local MSG_VERSION_REPLY							= 2	-- Reply

-- *** Utility functions ***
local function GuildBroadcast(messageType, ...)
	local serializedData = addon:Serialize(messageType, ...)
	addon:SendCommMessage(commPrefix, serializedData, "GUILD")
end

local function GuildWhisper(player, messageType, ...)
	if DataStore:IsGuildMemberOnline(player) then
		local serializedData = addon:Serialize(messageType, ...)
		addon:SendCommMessage(commPrefix, serializedData, "WHISPER", player)
	end
end

local function SaveVersion(sender, version)
	guildMembersVersion[sender] = version
end

-- *** Guild Comm ***
local function OnAnnounceLogin(self, guildName)
	GuildBroadcast(MSG_SEND_VERSION, addon.Version)
end

local function OnSendVersion(sender, version)
	if sender ~= UnitName("player") then								-- don't send back to self
		GuildWhisper(sender, MSG_VERSION_REPLY, addon.Version)		-- reply by sending my own version
	end
	SaveVersion(sender, version)											-- .. and save it
end

local function OnVersionReply(sender, version)
	SaveVersion(sender, version)
end

local GuildCommCallbacks = {
	[MSG_SEND_VERSION] = OnSendVersion,
	[MSG_VERSION_REPLY] = OnVersionReply,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options)

	addon:RegisterChatCommand("Altoholic", "ChatCommand")
	addon:RegisterChatCommand("Alto", "ChatCommand")
	
	DataStore:SetGuildCommCallbacks(commPrefix, GuildCommCallbacks)

	addon:RegisterMessage("DATASTORE_ANNOUNCELOGIN", OnAnnounceLogin)
	
	addon:RegisterComm("AltoShare", "AccSharingHandler")
	addon:RegisterComm(commPrefix, DataStore:GetGuildCommHandler())
	
	-- this event MUST stay here, we have to be able to respond to a request event if the guild tab is not loaded
	-- addon:RegisterMessage("DATASTORE_BANKTAB_REQUESTED")
	addon:RegisterMessage("DATASTORE_GUILD_MAIL_RECEIVED")
	addon:RegisterMessage("DATASTORE_GLOBAL_MAIL_EXPIRY")
	addon:RegisterMessage("DATASTORE_CS_TIMEGAP_FOUND")
	addon:RegisterMessage("DATASTORE_GUILD_LEFT")
end

function addon:GetGuildMemberVersion(member)
	if guildMembersVersion[member] then			-- version number of a main ?
		return guildMembersVersion[member]		-- return it immediately
	end
	
	-- check if member is an alt
	local main = DataStore:GetNameOfMain(member)
	if main and guildMembersVersion[main] then
		return guildMembersVersion[main]
	end
end

function addon:ChatCommand(input)
	if not input then
		LibStub("AceConfigDialog-3.0"):Open(addonName)
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(addon, "Alto", "Altoholic", input)
	end
end

local SPELL_ID_ALCHEMY = 2259
local SPELL_ID_BLACKSMITHING = 3100
local SPELL_ID_ENCHANTING = 7411
local SPELL_ID_ENGINEERING = 4036
local SPELL_ID_LEATHERWORKING = 2108

local SPELL_ID_TAILORING = 3908
local SPELL_ID_SKINNING = 8613
local SPELL_ID_MINING = 2575
local SPELL_ID_HERBALISM = 2366
-- local SPELL_ID_SMELTING = 2656

local SPELL_ID_COOKING = 2550
local SPELL_ID_FIRSTAID = 3273
local SPELL_ID_FISHING = 7732			-- do not use 7733, it's "Artisan Fishing", not "Fishing"

addon.TradeSkills = {
	Recipes = {},
	-- spell IDs in alphabetical order (english), primary then secondary
	spellIDs = { 2259, 3100, 7411, 4036, 2108, 3908, 8613, 2575, 2366, 2550, 3273, 7732 },
	firstSecondarySkillIndex = 10, -- index of the first secondary profession in the table
	
	AccountSummaryFiltersSpellIDs = { 2259, 3100, 7411, 4036, 2108, 3908, 8613, 2575, 2366, 2550, 3273, 7732 },
	AccountSummaryFirstSecondarySkillIndex = 10, -- index of the first secondary profession in the table
		
	Names = {
		ALCHEMY = GetSpellInfo(2259),
		BLACKSMITHING = GetSpellInfo(3100),
		COOKING = GetSpellInfo(2550),
		ENCHANTING = GetSpellInfo(7411),
		ENGINEERING = GetSpellInfo(4036),
		FIRSTAID = GetSpellInfo(3273),
		FISHING = GetSpellInfo(7732),
		HERBALISM = GetSpellInfo(2366),
		LEATHERWORKING = GetSpellInfo(2108),
		MINING = GetSpellInfo(2575),
		SKINNING = GetSpellInfo(8613),
		-- SMELTING = GetSpellInfo(2656),
		TAILORING = GetSpellInfo(3908),
	},
}

-- ** Tabs **
local tabList = {
	"Summary",
	"Characters",
	"Search",
	"Guild",
	"Agenda",
	"Grids",
}

local frameToID = {}
for index, name in ipairs(tabList) do
	frameToID[name] = index
end

local function SafeLoadAddOn(name)
	if not IsAddOnLoaded(name) then
		LoadAddOn(name)
	end
end

local function ShowTab(name)
	local tab = _G[addonName.."Tab" .. name]
	if tab then
		tab:Show()
	end
end

local function HideTab(name)
	local tab = _G[addonName.."Tab" .. name]
	if tab then
		tab:Hide()
	end
end

addon.Tabs = {}

function addon.Tabs:HideAll()
	for _, tabName in pairs(tabList) do
		HideTab(tabName)
	end
end

function addon.Tabs:OnClick(index)
	if type(index) == "string" then
		index = frameToID[index]
	end
	
	PanelTemplates_SetTab(_G[addonName.."Frame"], index);
	self:HideAll()
	self.current = index
	
	if index >= 1 and index <= 7 then
		local moduleName = format("%s_%s", addonName, tabList[index])
		SafeLoadAddOn(moduleName)		-- make this part a bit more generic once we'll have more LoD parts
		
		local parentLevel = AltoholicFrame:GetFrameLevel()
		local childName = format("%sTab%s", addonName, tabList[index])

		local tabFrame = _G[ childName ]
		
		if tabFrame then
			local childLevel = tabFrame:GetFrameLevel()
			
			if childLevel <= parentLevel then	-- if for any reason a child frame has a level lower or equal to its parent, fix it
				tabFrame:SetFrameLevel(parentLevel+1)
			end
		else
			addon:Print(format("%s is disabled.", moduleName))
		end
	end
	
	ShowTab(tabList[index])
end

-- Allow ESC to close the main frame
tinsert(UISpecialFrames, "AltoholicFrame")
tinsert(UISpecialFrames, "AltoMessageBox")

function addon:CmdSearchBags(arg1, arg2)
	-- arg 1 is a table, no idea of what it does, investigate later, only  arg2 matters at this point
	
	if string.len(arg2) == 0 then
		addon:Print("|cFF00FF9A" .. L["Altoholic:|r Usage = /altoholic search <item name>"])
		return
	end
	
	if not (AltoholicFrame:IsVisible()) then
		AltoholicFrame:Show()
	end
	AltoholicFrame_SearchEditBox:SetText(strlower(arg2))
	addon.Tabs:OnClick("Search")
	addon.Search:FindItem()
end	
