local addonName = ...
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local addonList = {
	"Altoholic",
	"Altoholic_Summary",
	"Altoholic_Characters",
	"Altoholic_Search",
	"Altoholic_Guild",
	"Altoholic_Achievements",
	"Altoholic_Agenda",
	"Altoholic_Grids",
}

local url1 = "https://www.curseforge.com/wow/addons/altoholic"
local url2 = "https://www.wowinterface.com/downloads/info8533-Altoholic.html"
local url3 = "https://www.curseforge.com/wow/addons/altoholic/localization"

local help = {
	{	name = "General",
		questions = {
			"How do I remove a character that has been renamed/transfered/deleted?",
			"Does Altoholic support command line options?",
			"My minimap icon is gone, how do I get it back?",
			"What are the official homepages?",
			"What is this 'DataStore' thing? Why so many directories?",
			"I am developper, I want to know more about DataStore",
			"Does the add-on support FuBar?",
			"What is the add-on's memory footprint?",
			"Where have my suggestions gone?",
		},
		answers = {
			"Go into the 'Account Summary', mouse over the character, right-click it to get the contextual menu, and select 'Delete this Alt'.",
			"Type /alto or /altoholic to get the list of command line options.",
			"Go into Altoholic's main option panel, and check 'Show Minimap Icon'.\nYou can also type /alto show.",
			format("%s%s\n%s\n%s", "The add-on is only released on these two sites, it is recommended NOT TO get it through other means:", colors.green, url1, url2 ),
			"DataStore and its modules take care of storing data for client add-ons; Altoholic itself now only stores very little information. The main purpose of the numerous directories is to offer split databases, instead of one massive database containing all the information required by the add-on.",
			"Refer to DataStore's own help topic for more information.",
			"Not anymore. Instead, it supports LibDataBroker (aka LDB), if you really want FuBar, use Broker2FuBar.",
			"For 10 characters and 1 guild bank, the add-on takes around 4-5mb on my machine. Note that due to its name, the add-on is one of the first in the alphabet, and often gets credited of the memory/cpu usage of its libraries.",
			"Development is an iterative process, and I review parts of the add-on constantly. Depending on my spare time, some suggestions might take longer than others to make it into the add-on. Be patient, the add-on is still far from being complete.",
		}
	},
	{	name = "Containers",
		questions = {
			"Do I have to open all my bags to let the add-on know about their content?",
			"What about my bank? .. and my guild bank?",
			"Will the content of my bags be visible in the tooltip? Can I configure that?",
		},
		answers = {
			"No. This happens silently and does not require any action from your part.",
			"You have to open your bank in order to let the add-on read its content. Same goes for the guild bank, except that the add-on can only read it tab per tab, so make sure to open them all.",
			"Yes. There are several tooltip options that can be set to specify what you want to see or not."
		}
	},
	{	name = "Professions",
		questions = {
			"Do I have to open all professions manually?",
		},
		answers = {
			"Yes. Some advanced features require that you open the tradeskill pane once per profession.",
		}
	},
	{	name = "Mails",
		questions = {
			"Can Altoholic read my mails without being at the mailbox?",
			"Altoholic marks all my mails as read, how can I avoid that?",
			"My mailbox is full, can Altoholic read beyond the list of visible mails?",
		},
		answers = {
			"No. This is a restriction imposed by Blizzard. Your character must physically be at a mailbox to retrieve your mails.",
			"Go into the 'Options -> DataStore -> DataStore_Mails' and disable 'Scan mail body'.",
			"No. You will have to clear your mailbox to release mails that are queued server-side.",
		}
	},
	{	name = "Localization",
		questions = {
			"I found a bad translation, how can I help fixing it?",
		},
		answers = {
			format("Use the CurseForge localization tool, at %s|r.", colors.green..url3),
		}
	},
}	

local support = {
	{	name = "Reporting Bugs",
		questions = {
			"I found an error, how/where do I report it?",
			"What should I do before reporting?",
			"I just upgraded to the latest version, and there are so many Lua errors, what the..??",
			"I have multiple Lua errors at login, should I report them all?",
		},
		answers = {
			"Both Curse and WoWInterface have a ticket section, I also read comments and respond as often as I materially can, so feel free to report in one of these places.",
			format("%s\n\n%s\n%s\n%s\n%s\n%s\n", 
				"A few things:",
				colors.green.."1)|r Make sure you have the latest version of the add-on.\n",
				colors.green.."2)|r If you suspect a conflict with another add-on, try to reproduce the issue with only Altoholic enabled. As the add-on deals with a lot of things, a conflict is always possible.\n",
				colors.green.."3)|r Make sure your issue has not been reported by someone else.\n",
				colors.green.."4)|r Never, ever, report that 'it does not work', this is the most useless sentence in the world! Be specific about what does not work.\n",
				colors.green.."5)|r DO NOT copy the entire add-on list from Swatter. While conflicts are possible, they are the exception rather than the rule."
			),
			"I'm just human, I make mistakes. But because I'm human, I fix them too, so be patient. This is a project that I develop in my spare time, and it fluctuates a lot.",
			"No. Only the first error you will get is relevant, it means that something failed during the initialization process of the add-on, or of a library, and this is likely to cause several subsequent errors that are more often than not irrelevant.",
		}
	},
	{	name = "Live support",
		questions = {
			"Is there an IRC channel where I could get live support?",
		},
		answers = {
			format("Yes. Join the %s#altoholic|r IRC channel on Freenode : %sirc://irc.freenode.net:6667/|r", colors.white, colors.green),
		}
	},
}

-- this content will be subject to frequent changes, do not bother translating it !!
local whatsnew = {
	{	name = "1.13.011 Changes",
		bulletedList = {
			"DataStore_Crafts : fixed the color of enchanting recipes in the skill panel, which were all displayed as orange.",
			"You must reload the profession once to fix the database entries.",
			"Fixed the enchanting profession in the character's tab. Filtering by enchant name now also working.",
		},
	},
	{	name = "1.13.010 Changes",
		bulletedList = {
			"Fixed a profession scanning issue where recipes of one profession could be stored into another profession.",
			"If you were affected by this, just reopen your professions once.",
		},
	},
	{	name = "1.13.009 Changes",
		bulletedList = {
			"Removed the debug text displayed when opening a craft window. Sorry about this one.",
			"Added tracking for raid encounter kills. Note that bosses killed were just saved in the previous version, but in an improper format.",
			"Be sure to reload alts with raid id's (it only affects the agenda tab, but you will get an error when mousing over raids of alts you have not reloaded).",
			"Fixed a lua error when opening the 'Beast Training' window.",
			"[frFR] fixed problems related to 'Secourisme/Premiers soins'",
			"Fixed multiple minor issues related to professions.",
			"Fixed searching profession recipes.",
		},
	},
	{	name = "1.13.008 Changes",
		bulletedList = {
			"Fixed Enchanting",
			"Summary Tab - Miscellaneous : Fixed guild info not properly reset when leaving a guild",
			"Summary Tab - Added a faction filter for 'this faction'",
			"Fixed a Search issue related to the localized faction name. enUS & frFR clients were not affected, but most likely all other locales were.",
		},
	},
	{	name = "1.13.007 Changes",
		bulletedList = {
			"Fixed profession cooldowns not properly updating the agenda.",
			"Fixed a localization issue in DataStore_Crafts that impacted non-enUS clients.",
		},
	},
	{	name = "1.13.006 Changes",
		bulletedList = {
			"Fixed a Lua error in the date service, triggering a problem in the Agenda Tab.",
			"DataStore_Talents : fixed an issue when scanning talents.",
			"DataStore_Talents : fixed an issue checking the specialization of a low level alt.",
			"Agenda Tab : fixed reporting of professions cooldowns, and some refresh issues.",
			"Added tracking of the salt shaker cooldown.",
			"Fixed multiple issues with account sharing, it should now work without problems.",
			"Added support for LibDeflate, data transferred using the account sharing feature is now compressed, and the whole process is now much faster.",
			"Note that data transfer is still throttled, while the whole process will be 3-4 times faster than it was, it will never be lightning fast.",
		},
	},
	{	name = "1.13.005 Changes",
		bulletedList = {
			"Fixed a Lua error when mousing over some recipes.",
			"Fixed a Lua error in the event management.",
			"Fixed professions cooldowns.",
			"DataStore_Talents : fixed an issue that could cause account sharing not to work properly.",
			"DataStore_Inventory : fixed a potential division by zero when scanning the inventory of a naked alt (Thanks qwarlocknew for finding this one !).",
			"Fixed the recipe tooltips : the 'already know by' information is now correct.",
		},
	},
	{	name = "1.13.004 Changes",
		bulletedList = {
			"Agenda Tab : Fixed a Lua error using C_Calendar.",
			"The account sharing functionality has been reactivated. I could not test it extensively, please report if you have problems.",
			"DataStore_Crafts : Added support for the localized profession names which may not be unique in some regions.",
		},
	},
	{	name = "1.13.003 Changes",
		bulletedList = {
			"Summary Tab : fixed the tooltip of tradeskills, where the amount of recipes was improperly reported.",
			"Search Tab : fixed a Lua error preventing all searches.",
		},
	},
	{	name = "1.13.002 Changes",
		bulletedList = {
			"Release Candidate - not released publically.",
			"Summary Tab : added the miscellaneous menu item, as on retail.",
			"Characters Tab : talent trees are now working.",
			"Agenda Tab : is now working.",
			"Grids Tab : Fixed a few Lua errors, and added missing icons for the reputations.",
			"Grids Tab : added a panel for the raid attunements.",
			"Grids Tab : added a panel for keys and key-like items (ex: Scepter of Celebras), with the dungeon to which they are related and the appropriate level.",
		},
	},
	{	name = "1.13.001 Changes",
		bulletedList = {
			"Altoholic Summary : should be working fine, but limited to 'account summary', 'bags', 'skills', 'activity'",
			"Altoholic Characters : should be working fine, except for the talents.",
			"Altoholic Search : should be working fine",
			"Altoholic Guild : should be working fine, but only contains the 'guild' and not the 'guild bank' since it did not exist in classic.",
			"Altoholic Agenda : NOT WORKING, you should disable DataStore_Agenda.",
			"Altoholic Grids : should be working fine, but limited to 'Equipment', 'Reputations', 'Daily Quests', 'Tradeskills'",
			"	Reputations used to get their icons from the related achievements, which do not exist in Classic, so icons are bad/missing.",

			"DataStore_Achievements + Currencies + Garrisons + Pets : not supported at all in Classic.",
			"DataStore_Agenda + Stats + Talents : are provided as-is, they need to be adapted for Classic, they should be DISABLED in the addon list.",
			"Other DataStore modules : should be working fine.",
			"Added the sell price of items in the tooltip, and an option to show/hide it.",
		},
	},
	{	name = "Earlier changes",
		textLines = {
			"Refer to |cFF00FF00changelog.txt",
		},
	},
}

function addon:GetOption(name)
	if addon.db and addon.db.global and addon.db.global.options then
		return addon.db.global.options[name]
	end
end

function addon:SetOption(name, value)
	if addon.db and addon.db.global and addon.db.global.options then 
		addon.db.global.options[name] = value
	end
end

function addon:ToggleOption(frame, option)
	local value
	
	if frame then
		value = frame:GetChecked() and true or false
	else
		value = not addon:GetOption(option)
	end
	
	addon:SetOption(option, value)
end

function addon:SetupOptions()
	-- create categories in Blizzard's options panel
	
	DataStore:AddOptionCategory(AltoholicGeneralOptions, addonName)
	LibStub("LibAboutPanel").new(addonName, addonName);
	DataStore:AddOptionCategory(AltoholicHelp, HELP_LABEL, addonName)
	DataStore:AddOptionCategory(AltoholicSupport, "Getting support", addonName)
	DataStore:AddOptionCategory(AltoholicWhatsNew, "What's new?", addonName)
	DataStore:AddOptionCategory(AltoholicMemoryOptions, L["Memory used"], addonName)
	DataStore:AddOptionCategory(AltoholicSearchOptions, SEARCH, addonName)
	DataStore:AddOptionCategory(AltoholicMailOptions, MAIL_LABEL, addonName)
	DataStore:AddOptionCategory(AltoholicMiscOptions, MISCELLANEOUS, addonName)
	DataStore:AddOptionCategory(AltoholicAccountSharingOptions, L["Account Sharing"], addonName)
	DataStore:AddOptionCategory(AltoholicSharedContent, "Shared Content", addonName)
	DataStore:AddOptionCategory(AltoholicTooltipOptions, L["Tooltip"], addonName)
	DataStore:AddOptionCategory(AltoholicCalendarOptions, L["Calendar"], addonName)

	DataStore:SetupInfoPanel(help, AltoholicHelp_Text)
	DataStore:SetupInfoPanel(support, AltoholicSupport_Text)
	DataStore:SetupInfoPanel(whatsnew, AltoholicWhatsNew_Text)
	
	help = nil
	support = nil
	whatsnew = nil
	
	local value
	local f = AltoholicGeneralOptions
	
	-- ** General **
	f.Title:SetText(colors.teal..format("%s %s", addonName, addon.Version))
	f.BankAutoUpdate.Text:SetText(L["Automatically authorize guild bank updates"])
	f.BankAutoUpdate.tooltip = format("%s%s%s",
		L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto update their guild bank information with yours automatically.\n\n"],
		L["When |cFFFF0000disabled|cFFFFFFFF, your confirmation will be\nrequired before sending any information.\n\n"],
		L["Security hint: disable this if you have officer rights\non guild bank tabs that may not be viewed by everyone,\nand authorize requests manually"])
	
	f.ClampWindowToScreen.Text:SetText(L["Clamp window to screen"])
	
	L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto update their guild bank information with yours automatically.\n\n"] = nil
	L["When |cFFFF0000disabled|cFFFFFFFF, your confirmation will be\nrequired before sending any information.\n\n"] = nil
	L["Security hint: disable this if you have officer rights\non guild bank tabs that may not be viewed by everyone,\nand authorize requests manually"] = nil
	L["Max rest XP displayed as 150%"] = nil
	L["Automatically authorize guild bank updates"] = nil
	
	value = AltoholicGeneralOptions_SliderAngle:GetValue()
	AltoholicGeneralOptions_SliderAngle.tooltipText = L["Move to change the angle of the minimap icon"]
	AltoholicGeneralOptions_SliderAngleLow:SetText("1");
	AltoholicGeneralOptions_SliderAngleHigh:SetText("360"); 
	AltoholicGeneralOptions_SliderAngleText:SetText(format("%s (%s)", L["Minimap Icon Angle"], value))
	L["Move to change the angle of the minimap icon"] = nil
	
	value = AltoholicGeneralOptions_SliderRadius:GetValue()
	AltoholicGeneralOptions_SliderRadius.tooltipText = L["Move to change the radius of the minimap icon"]; 
	AltoholicGeneralOptions_SliderRadiusLow:SetText("1");
	AltoholicGeneralOptions_SliderRadiusHigh:SetText("200"); 
	AltoholicGeneralOptions_SliderRadiusText:SetText(format("%s (%s)", L["Minimap Icon Radius"], value))
	L["Move to change the radius of the minimap icon"] = nil
	
	f = AltoholicGeneralOptions
	f.ShowMinimapIcon.Text:SetText(L["Show Minimap Icon"])
	L["Show Minimap Icon"] = nil
	
	value = AltoholicGeneralOptions_SliderAlpha:GetValue()
	AltoholicGeneralOptions_SliderAlphaLow:SetText("0.1");
	AltoholicGeneralOptions_SliderAlphaHigh:SetText("1.0"); 
	AltoholicGeneralOptions_SliderAlphaText:SetText(format("%s (%1.2f)", L["Transparency"], value));
	
	-- ** Memory **
	AltoholicMemoryOptions_AddonsText:SetText(colors.orange..ADDONS)
	local list = ""
	for index, module in ipairs(addonList) do
		list = format("%s%s:\n", list, module)
	end

	list = format("%s\n%s", list, format("%s:", L["Memory used"]))
	
	AltoholicMemoryOptions_AddonsList:SetText(list)
	
	-- ** Search **
	f = AltoholicSearchOptions
	f.ItemInfoAutoQuery.Text:SetText(L["AutoQuery server |cFFFF0000(disconnection risk)"])
	f.ItemInfoAutoQuery.tooltip = format("%s%s%s%s",
		L["|cFFFFFFFFIf an item not in the local item cache\nis encountered while searching loot tables,\nAltoholic will attempt to query the server for 5 new items.\n\n"],
		L["This will gradually improve the consistency of the searches,\nas more items are available in the item cache.\n\n"],
		L["There is a risk of disconnection if the queried item\nis a loot from a high level dungeon.\n\n"],
		L["|cFF00FF00Disable|r to avoid this risk"])	
	
	f.IncludeNoMinLevel.Text:SetText(L["Include items without level requirement"])
	f.IncludeMailboxItems.Text:SetText(L["Include mailboxes"])
	f.IncludeKnownRecipes.Text:SetText(L["Include known recipes"])
	L["AutoQuery server |cFFFF0000(disconnection risk)"] = nil
	L["Sort loots in descending order"] = nil
	L["Include items without level requirement"] = nil
	L["Include mailboxes"] = nil
	L["Include guild bank(s)"] = nil
	L["Include known recipes"] = nil
	
	-- ** Mail **
	value = AltoholicMailOptions_SliderTimeToNextWarning:GetValue()
	AltoholicMailOptions_SliderTimeToNextWarning.tooltipText = L["TIME_TO_NEXT_WARNING_TOOLTIP"]
	AltoholicMailOptions_SliderTimeToNextWarningLow:SetText("1");
	AltoholicMailOptions_SliderTimeToNextWarningHigh:SetText("12"); 
	AltoholicMailOptions_SliderTimeToNextWarningText:SetText(format("%s (%s)", L["TIME_TO_NEXT_WARNING_TEXT"], format(D_HOURS, value)))

	f = AltoholicMailOptions
	f.GuildMailWarning.Text:SetText(L["New mail notification"])
	f.GuildMailWarning.tooltip = format("%s",	L["Be informed when a guildmate sends a mail to one of my alts.\n\nMail content is directly visible without having to reconnect the character"])
	f.AutoCompleteRecipient.Text:SetText("Auto-complete recipient name" )
	L["New mail notification"] = nil

	f = AltoholicMiscOptions
	f.AHColorCoding.Text:SetText(L["Use color-coding for recipes at the AH"])
	f.VendorColorCoding.Text:SetText(L["Use color-coding for recipes at vendors"])
				
	-- ** Account Sharing **
	f = AltoholicAccountSharingOptions
	f.Text1:SetText(colors.white.."Authorizations")
	f.Text2:SetText(colors.white..L["Character"])
	f.IconNever:SetText("\124TInterface\\RaidFrame\\ReadyCheck-NotReady:14\124t")
	f.IconAsk:SetText("\124TInterface\\RaidFrame\\ReadyCheck-Waiting:14\124t")
	f.IconAuto:SetText("\124TInterface\\RaidFrame\\ReadyCheck-Ready:14\124t")
	f.IsEnabled.Text:SetText(L["Account Sharing Enabled"])
	f.IsEnabled.tooltip = format("%s%s%s%s",
		L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto send you account sharing requests.\n"],
		L["Your confirmation will still be required any time someone requests your information.\n\n"],
		L["When |cFFFF0000disabled|cFFFFFFFF, all requests will be automatically rejected.\n\n"],
		L["Security hint: Only enable this when you actually need to transfer data,\ndisable otherwise"])

	L["Account Sharing Enabled"] = nil
	L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto send you account sharing requests.\n"] = nil
	L["Your confirmation will still be required any time someone requests your information.\n\n"] = nil
	L["When |cFFFF0000disabled|cFFFFFFFF, all requests will be automatically rejected.\n\n"] = nil
	L["Security hint: Only enable this when you actually need to transfer data,\ndisable otherwise"] = nil

	AltoholicAccountSharingOptions_InfoButton.tooltip = format("%s\n%s\n\n%s", 
	
	colors.white.."This list allows you to automate responses to account sharing requests.",
	"You can choose to automatically accept or reject requests, or be asked when a request comes in.",
	"If account sharing is totally disabled, this list will be ignored, and all requests will be rejected." )
	
	
	-- ** Shared Content **
	AltoholicSharedContentText1:SetText(colors.white.."Shared Content")
	AltoholicSharedContent_SharedContentInfoButton.tooltip = format("%s\n%s", 
		colors.white.."Select the content that will be visible to players who send you",
		"account sharing requests.")
	
	
	-- ** Tooltip **
	f = AltoholicTooltipOptions
	f.ShowItemSource.Text:SetText(L["Show item source"])
	f.ShowItemCount.Text:SetText(L["Show item count per character"])
	f.ShowSimpleCount.Text:SetText(L["Show item count without details"])
	f.ShowTotalItemCount.Text:SetText(L["Show total item count"])
	f.ShowItemSellPrice.Text:SetText("Show item sell price")
	f.ShowKnownRecipes.Text:SetText(L["Show recipes already known/learnable by"])
	f.ShowItemID.Text:SetText(L["Show item ID and item level"])
	f.ShowGatheringNodesCount.Text:SetText(L["Show counters on gathering nodes"])
	f.ShowCrossFactionCount.Text:SetText(L["Show counters for both factions"])
	f.ShowMergedRealmsCount.Text:SetText(L["Show counters for connected realms"])
	f.ShowAllAccountsCount.Text:SetText(L["Show counters for all accounts"])
	L["Show item source"] = nil
	L["Show item count per character"] = nil
	L["Show item count without details"] = nil
	L["Show total item count"] = nil
	L["Show guild bank count"] = nil
	L["Show already known/learnable by"] = nil
	L["Show recipes already known/learnable by"] = nil
	L["Show item ID and item level"] = nil
	L["Show counters on gathering nodes"] = nil
	L["Show counters for both factions"] = nil
	L["Show counters for all accounts"] = nil
	L["Include guild bank count in the total count"] = nil
	
	-- ** Calendar **
	f = AltoholicCalendarOptions
	f.WeekStartsOnMonday.Text:SetText(L["Week starts on Monday"])
	f.UseDialogBoxForWarnings.Text:SetText(L["Display warnings in a dialog box"])
	f.WarningsEnabled.Text:SetText(L["Disable warnings"])
	L["Week starts on Monday"] = nil
	L["Warn %d minutes before an event starts"] = nil
	L["Display warnings in a dialog box"] = nil
	
	for i = 1, 4 do 
		addon:DDM_Initialize(_G["AltoholicCalendarOptions_WarningType"..i], Altoholic.Events.WarningType_Initialize)
	end
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType1, "Profession Cooldowns")
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType2, "Dungeon Resets")
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType3, "Calendar Events")
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType4, "Item Timers")
end

function addon:RestoreOptionsToUI()
	local O = Altoholic.db.global.options
	
	local f = AltoholicGeneralOptions
	
	f.BankAutoUpdate:SetChecked(O["UI.Tabs.Guild.BankAutoUpdate"])
	f.ClampWindowToScreen:SetChecked(O["UI.ClampWindowToScreen"])

	AltoholicGeneralOptions_SliderAngle:SetValue(O["UI.Minimap.IconAngle"])
	AltoholicGeneralOptions_SliderRadius:SetValue(O["UI.Minimap.IconRadius"])
	f.ShowMinimapIcon:SetChecked(O["UI.Minimap.ShowIcon"])
	AltoholicGeneralOptions_SliderScale:SetValue(O["UI.Scale"])
	AltoholicFrame:SetScale(O["UI.Scale"])
	AltoholicGeneralOptions_SliderAlpha:SetValue(O["UI.Transparency"])

	-- set communication handlers according to user settings.
	if O["UI.AccountSharing.IsEnabled"] then
		Altoholic.Comm.Sharing:SetMessageHandler("ActiveHandler")
	else
		Altoholic.Comm.Sharing:SetMessageHandler("EmptyHandler")
	end
	
	
	f = AltoholicSearchOptions
	
	f.ItemInfoAutoQuery:SetChecked(O["UI.Tabs.Search.ItemInfoAutoQuery"])
	f.IncludeNoMinLevel:SetChecked(O["UI.Tabs.Search.IncludeNoMinLevel"])
	f.IncludeMailboxItems:SetChecked(O["UI.Tabs.Search.IncludeMailboxItems"])
	f.IncludeKnownRecipes:SetChecked(O["UI.Tabs.Search.IncludeKnownRecipes"])

	AltoholicSearchOptionsLootInfo:SetText(colors.green .. O.TotalLoots .. "|r " .. L["Loots"] .. " / " .. colors.green .. O.UnknownLoots .. "|r " .. L["Unknown"])
	AltoholicSearchOptionsLootInfo:SetText(format("%s%s|r %s / %s%s|r %s", colors.green, O.TotalLoots, L["Loots"], colors.green, O.UnknownLoots, L["Unknown"]))
	
	f = AltoholicMailOptions
	AltoholicMailOptions_SliderTimeToNextWarning:SetValue(O["UI.Mail.TimeToNextWarning"])
	f.GuildMailWarning:SetChecked(O["UI.Mail.GuildMailWarning"])
	f.AutoCompleteRecipient:SetChecked(O["UI.Mail.AutoCompleteRecipient"])
	
	f = AltoholicMiscOptions
	f.AHColorCoding:SetChecked(O["UI.AHColorCoding"])
	f.VendorColorCoding:SetChecked(O["UI.VendorColorCoding"])
	
	f = AltoholicAccountSharingOptions
	f.IsEnabled:SetChecked(O["UI.AccountSharing.IsEnabled"])
	
	f = AltoholicTooltipOptions
	f.ShowItemSource:SetChecked(O["UI.Tooltip.ShowItemSource"])
	f.ShowItemCount:SetChecked(O["UI.Tooltip.ShowItemCount"])
	f.ShowTotalItemCount:SetChecked(O["UI.Tooltip.ShowTotalItemCount"])
	f.ShowKnownRecipes:SetChecked(O["UI.Tooltip.ShowKnownRecipes"])
	f.ShowItemID:SetChecked(O["UI.Tooltip.ShowItemID"])
	f.ShowGatheringNodesCount:SetChecked(O["UI.Tooltip.ShowGatheringNodesCount"])
	f.ShowCrossFactionCount:SetChecked(O["UI.Tooltip.ShowCrossFactionCount"])
	f.ShowMergedRealmsCount:SetChecked(O["UI.Tooltip.ShowMergedRealmsCount"])
	f.ShowAllAccountsCount:SetChecked(O["UI.Tooltip.ShowAllAccountsCount"])
	
	f = AltoholicCalendarOptions
	f.WeekStartsOnMonday:SetChecked(O["UI.Calendar.WeekStartsOnMonday"])
	f.UseDialogBoxForWarnings:SetChecked(O["UI.Calendar.UseDialogBoxForWarnings"])
	f.WarningsEnabled:SetChecked(O["UI.Calendar.WarningsEnabled"])
end

function addon:UpdateMyMemoryUsage()
	DataStore:UpdateMemoryUsage(addonList, AltoholicMemoryOptions, format("%s:", L["Memory used"]))
end

local function ResizeScrollFrame(frame, width, height)
	-- just a small wrapper, nothing generic in here.
	
	local name = frame:GetName()
	_G[name]:SetWidth(width-45)
	_G[name.."_ScrollFrame"]:SetWidth(width-45)
	_G[name]:SetHeight(height-30)
	_G[name.."_ScrollFrame"]:SetHeight(height-30)
	_G[name.."_Text"]:SetWidth(width-80)
end

local OnSizeUpdate = {	-- custom resize functions
	AltoholicHelp = ResizeScrollFrame,
	AltoholicSupport = ResizeScrollFrame,
	AltoholicWhatsNew = ResizeScrollFrame,
}

local OptionsPanelWidth, OptionsPanelHeight
local lastOptionsPanelWidth = 0
local lastOptionsPanelHeight = 0

function addon:OnUpdate(self, mandatoryResize)
	OptionsPanelWidth = InterfaceOptionsFramePanelContainer:GetWidth()
	OptionsPanelHeight = InterfaceOptionsFramePanelContainer:GetHeight()
	
	if not mandatoryResize then -- if resize is not mandatory, allow exit
		if OptionsPanelWidth == lastOptionsPanelWidth and OptionsPanelHeight == lastOptionsPanelHeight then return end		-- no size change ? exit
	end
		
	lastOptionsPanelWidth = OptionsPanelWidth
	lastOptionsPanelHeight = OptionsPanelHeight
	
	local frameName = self:GetName()
	if frameName and OnSizeUpdate[frameName] then
		OnSizeUpdate[frameName](self, OptionsPanelWidth, OptionsPanelHeight)
	end
end
