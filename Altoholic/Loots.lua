local addonName = ...
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local BB = LibStub("LibBabble-Boss-3.0"):GetLookupTable()
local LCI = LibStub("LibCraftInfo-1.0")
local LCL = LibStub("LibCraftLevels-1.0")
local TS = addon.TradeSkills.Names

-- Simplified loot table containing item ID's only, based on AtlasLoot v6.02.00
local lootTable = {
			
	-- to do: HardModeArena & HardModeArena2 from sets_en.lua
	-- to do : wotlk crafts
	-- to do : pvp non set 80, line 3000 in wotlk.lua of AL 5.04
	-- tier 8

	-- ** Miscellaneous **
	[L["Bash'ir Landing"]] = {	
		[L["Skyguard Raid"]] = { 32596, 32600, 32599, 32597, 32634, 32637, 32635, 32636, 32639, 32638, 
								32641, 32640, 32759, 32630, 32631, 32627, 32625, 32629, 32628, 32626, 32624 },
		[L["Stasis Chambers"]] = { 32522, 31577, 31569, 31553, 31561},
	},
	[L["Skettis"]] = {	
		[L["Darkscreecher Akkarai"]] = {	32529, 32715, 31558, 31555, 31566, 31563, 31574, 31571, 31582, 31579, 32514 },
		[L["Karrog"]] = {	32533, 32717, 31558, 31555, 31566, 31563, 31574, 31571, 31582, 31579, 32514 },
		[L["Gezzarak the Huntress"]] = { 32531, 32716, 31558, 31555, 31566, 31563, 31574, 31571, 31582, 31579, 32514 },
		[L["Vakkiz the Windrager"]] = {	32532, 32718, 31558, 31555, 31566, 31563, 31574, 31571, 31582, 31579, 32514 },
		[L["Terokk"]] = { 32540, 32541, 31556, 31564, 31572, 31580, 32535, 32534, 32782, 32536, 32537 }
	},
	[L["Ethereum Prison"]] = {	
		[L["Armbreaker Huffaz"]] = { 31943, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 },
		[L["Fel Tinkerer Zortan"]] = { 31573, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 },
		[L["Forgosh"]] = { 31940, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 },
		[L["Gul'bor"]] = { 31940, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 },
		[L["Malevus the Mad"]] = { 31581, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 },
		[L["Porfus the Gem Gorger"]] = { 31557, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 },
		[L["Wrathbringer Laz-tarash"]] = { 32520, 31939, 31938, 31936, 31935, 31937, 31957, 31928, 31929, 31925, 31926, 31927 }
	},
	[L["Abyssal Council"] .. " (Silithus)"] = {	--  "Silithus"
		[L["Crimson Templar (Fire)"]] = { 20657, 20655, 20656	},
		[L["Azure Templar (Water)"]] = { 20654, 20652, 20653 },
		[L["Hoary Templar (Wind)"]] = { 20658, 20659, 20660 },
		[L["Earthen Templar (Earth)"]] = { 20661, 20662, 20663 },
		[L["The Duke of Cinders (Fire)"]] = { 20665, 20666, 20514, 20664, 21989 },
		[L["The Duke of Fathoms (Water)"]] = { 20668, 20669, 20514, 20667 },
		[L["The Duke of Zephyrs (Wind)"]] = { 20674, 20675, 20514, 20673 },
		[L["The Duke of Shards (Earth)"]] = { 20671, 20672, 20514, 20670 },
		[BB["Prince Skaldrenox"] .. " (Fire)"] = { 20682, 20515, 20681, 20680	},
		[BB["Lord Skwol"] .. " (Water)"] = {	20685, 20515, 20684, 20683 },
		[BB["High Marshal Whirlaxis"] .. " (Wind)"] = { 20691, 20515, 20690, 20689 },
		[BB["Baron Kazum"] .. " (Earth)"] = { 20688, 20515, 20686, 20687 }
	},
	[L["Elemental Invasion"]] = {	
		[BB["Baron Charr"] .. " (Un'Goro Crater)"] = {	18671, 19268, 18672 },	-- "Un'Goro Crater"
		[BB["Princess Tempestria"] .. " (Winterspring)"] = { 18678, 19268, 21548, 18679 }, -- "Winterspring"
		[BB["Avalanchion"] .. " (Azshara)"] = { 18673, 19268, 18674 },	--  "Azshara"
		[BB["The Windreaver"] .. " (Silithus)"] = { 18676, 19268, 21548, 18677 }	-- "Silithus"
	},
	[L["Gurubashi Arena"]] = {	
		[L["Booty Run"]] = { 18709, 18710, 18711, 18712, 18706, 19024 }
	},
	[L["Fishing Extravaganza"]] = {	
		[L["First Prize"]] = { 19970, 19979	},
		[L["Rare Fish"]] = { 19805, 19803, 19806, 19808 },
		[L["Rare Fish Rewards"]] = { 19972, 19969, 19971 }
	},
	-- [L["Children's Week"]] = {	
		-- [BZ["Azeroth"]] = { 23007, 23015, 23002, 23022 },
		-- [BZ["Outland"]] = { 32616, 32622, 32617	}
	-- },
	[L["Love is in the air"]] = {	
		[L["Gift of Adoration"]] = { 34480, 22279, 22235, 22200, 22261, 22218, 21813, 34258 },
		[L["Box of Chocolates"]] = { 22237, 22238, 22236, 22239 },
		[L["Quest rewards"]] = { 22276, 22278, 22280, 22277, 22281, 22282	}
	},
	[L["Hallow's End"]] = {	
		[L["Various Locations"]] = { 33117, 20400, 18633, 18632, 18635, 20557 },
		[L["Treat Bag"]] = {	20410, 20409, 20399, 20398, 20397, 20413, 20411, 20414, 20389, 20388, 
									20390, 20561, 20391, 20566, 20564, 20570, 20572, 20568, 20573, 20562, 
									20392, 20565, 20563, 20569, 20571, 20567, 20574 },
		[L["Headless Horseman"]] = { 33808, 34075, 34073, 34074, 33292, 33154, 34068, 33226, 33182, 33184, 
									33176, 33183, 33189 }
	},
	[L["Feast of Winter Veil"]] = {	
		[L["Various Locations"]] = { 21525, 21524, 17712, 17202, 34191, 21212, 21519 },
		[L["Smokywood Pastures Vendor"]] = { 34262, 34319, 34261, 34413, 17201, 17200, 17344, 17406, 17407, 17408, 
								34410, 17404, 17405, 34412, 17196, 17403, 17402, 17194, 17303, 17304, 17307 },
		[L["Gaily Wrapped Present"]] = { 21301, 21308, 21305, 21309	},
		[L["Festive Gift"]] = {	21328 },
		[L["Winter Veil Gift"]] = { 34425 },
		[L["Gently Shaken Gift"]] = {	21235, 21241 },
		[L["Ticking Present"]] = {	21325, 21213, 17706, 17725, 17720, 17722, 17709, 17724 },
		[L["Carefully Wrapped Present"]] = { 21254 },
		[L["Smokywood Pastures Extra-Special Gift"]] = { 21215 }
	},
	[L["Noblegarden"]] = {	
		[L["Brightly Colored Egg"]] = { 19028, 6833, 6835, 7807, 7808, 7806 }
	},	
	[L["Harvest Festival"]] = {	
		[L["Quest rewards"]] = { 19697, 20009, 20010 },
		[L["Food"]] = { 19994, 19995, 19996, 19997 }
	},
	[L["Scourge Invasion"]] = {	
		[L["Miscellaneous"]] = { 23123, 23122, 22999, 23194, 23195, 23196	},
		[L["Cloth Set"]] = {	23085, 23091, 23084 },
		[L["Leather Set"]] = { 23089, 23093, 23081 },
		[L["Mail Set"]] = { 23088, 23092, 23082 },
		[L["Plate Set"]] = {	23087, 23090, 23078 },
		[L["Balzaphon"]] = {	23126, 23125, 23124 },
		[L["Lord Blackwood"]] = { 23156, 23132, 23139 },
		[L["Revanchion"]] = { 23127, 23129, 23128	},
		[L["Scorn"]] = { 23170, 23169, 23168 },
		[L["Sever"]] = { 23173, 23171 },
		[L["Lady Falther'ess"]] = { 23178, 23177 }
	},
	[L["Lunar Festival"]] = {	
		[L["Miscellaneous"]] = { 21540, 21157, 21538, 21539, 21541, 21544, 21543, 21537, 21713, 21100 },
		[L["Fireworks Pack"]] = { 21558, 21559, 21557, 21561, 21562, 21589, 21590, 21592, 21593, 21595 },
		[L["Lucky Red Envelope"]] = { 21744, 21745 },
		[TS.ENGINEERING] = { 21738, 21724, 21725, 21726, 21727, 21728, 21729, 21737, 21730, 21731, 
									21732, 21733, 21734, 21735 },
		[TS.TAILORING] = { 21722, 21723 }
	},
	[L["Midsummer Fire Festival"]] = {	
		[L["Miscellaneous"]] = { 34686, 23379, 23083, 23247, 23246, 23435, 23327, 23326, 
									23211, 34684, 23323, 23324, 34685, 34683 },
		[L["Lord Ahune"]] = { 35494, 35495, 35496, 35497, 35498, 35514, 35723, 34955, 35279, 35280 },
		[L["Lord Ahune"] .. L[" (Heroic)"]] = { 35507, 35509, 35508, 35511, 35498, 34955, 35723, 35279, 35280, 35497, 
									35496, 35494, 35495, 35514 }
	},
	[L["Shartuul"]] = {	
		[L["Blade Edge Mountains"]] = { 32941, 32676, 32675, 32677, 32678, 32672, 32673, 32674, 32670, 32671, 
									32679, 32942, 32655, 32656, 32665, 32664, 32658, 32659, 32660, 32663, 
									32661, 32662 }
	},
	[L["Brewfest"]] = {	
		[L["Miscellaneous"]] = { 33927, 33047, 33968, 33864, 33967, 33969, 33862, 33863, 33868, 33966, 
									33978, 33977, 33976, 32912, 34140, 32233, 33455, 34063, 34064, 33023, 
									33024, 33025, 33026, 33043, 33929 },
		[L["Barleybrew Brewery"]] = { 33030, 33028, 33029 },
		[L["Thunderbrew Brewery"]] = { 33031, 33032, 33033	},
		[L["Gordok Brewery"]] = { 33034, 33036, 33035 },
		["Coren Direbrew"] = { 37127, 38289, 38290, 38288, 38287, 37597 },
		[L["Drohn's Distillery"]] = { 34017, 34018, 34019 },
		[L["T'chali's Voodoo Brewery"]] = { 34020, 34021, 34022 }
	},
	
	-- ** Sets & PVP ***
	["Alterac Valley"] = {	-- "Alterac Valley"
		[L["Miscellaneous"].." (" .. FACTION_ALLIANCE .. ")"] = { 19045, 19032 },
		[L["Miscellaneous"].." (" .. FACTION_HORDE .. ")"] = {	19046, 19031 },
		[L["Miscellaneous"]] = { 19316, 17348, 17349, 19301, 19307, 19317, 17351, 17352, 19318	},
		[L["Superior Rewards"].." (" .. FACTION_ALLIANCE .. ")"] = { 19086, 19084, 19094, 19093, 19092, 19091, 19098, 19097, 19100, 19104, 
										19102, 19320, 19319 },
		[L["Superior Rewards"].." (" .. FACTION_HORDE .. ")"] = {	19085, 19083, 19090, 19089, 19088, 19087, 19096, 19095, 19099, 19103, 
										19101, 19320, 19319 },
		[L["Epic Rewards"].." (" .. FACTION_ALLIANCE .. ")"] = { 19030 },
		[L["Epic Rewards"].." (" .. FACTION_HORDE .. ")"] = { 19029 },
		[L["Epic Rewards"]] = {	19325, 19312, 19308, 19309, 19324, 19321, 21563, 19315, 19311, 19310, 19323 }
	},
	["Arathi Basin"] = {	--  "Arathi Basin"
		[L["Miscellaneous"].." (" .. FACTION_ALLIANCE .. ")"] = {	17349, 17352, 20225, 20227, 20226, 20243, 20237, 20244 },
		[L["Miscellaneous"].." (" .. FACTION_HORDE .. ")"] = {	17349, 17352, 20222, 20224, 20223, 20234, 20232, 20235 },
		[format(L["Lv %s Rewards"], "20-29").." (" .. FACTION_ALLIANCE .. ")"] = {	20099, 20096, 20117, 20105, 20120, 20090, 20114, 20102, 20123, 20093, 
										20108, 20126, 20111, 20129, 21119 },
		[format(L["Lv %s Rewards"], "20-29").." (" .. FACTION_HORDE .. ")"] = {	20164, 20162, 20191, 20172, 20152, 20197, 20188, 20169, 20201, 20157, 
										20178, 20207, 20182, 20210, 21120 },
		[format(L["Lv %s Rewards"], "30-39").." (" .. FACTION_ALLIANCE .. ")"] = {	20098, 20095, 20116, 20104, 20113, 20101, 21118 }, 
		[format(L["Lv %s Rewards"], "30-39").." (" .. FACTION_HORDE .. ")"] = {	20166, 20161, 20192, 20173, 20187, 20168, 21116 },
		[format(L["Lv %s Rewards"], "40-49").." (" .. FACTION_ALLIANCE .. ")"] = {	20097, 20094, 20115, 20103, 20112, 20100, 20089, 20088, 20119, 20118, 
										20092, 20091, 20122, 20121, 20107, 20106, 20125, 20124, 20110, 20109, 
										20128, 20127, 21117 }, 
		[format(L["Lv %s Rewards"], "40-49").." (" .. FACTION_HORDE .. ")"] = {	20165, 20160, 20193, 20174, 20189, 20170, 20153, 20151, 20198, 20196, 
										20156, 20155, 20200, 20202, 20180, 20179, 20206, 20205, 20183, 20185, 
										20209, 20211, 21115 },
		[format(L["Lv %s Rewards"], "50-59").." (" .. FACTION_ALLIANCE .. ")"] = {	20047, 20054, 20045, 20046, 20052, 20053, 20043, 20050, 20042, 20041, 
										20049, 20048, 20071 }, 
		[format(L["Lv %s Rewards"], "50-59").." (" .. FACTION_HORDE .. ")"] = {	20163, 20159, 20190, 20171, 20186, 20167, 20150, 20195, 20154, 20199, 
										20204, 20208, 20072 },
		[format(L["Lv %s Rewards"], "60").." (" .. FACTION_ALLIANCE .. ")"] = {	20073, 20061, 20059, 20060, 20055, 20056, 20058, 20057, 20070, 20069 }, 
		[format(L["Lv %s Rewards"], "60").." (" .. FACTION_HORDE .. ")"] = {	20068, 20176, 20194, 20175, 20158, 20203, 20212, 20214, 20220 },
		[L["PVP Cloth Set"].." (" .. FACTION_ALLIANCE .. ")"] = { 20061, 20047, 20054	},
		[L["PVP Cloth Set"].." (" .. FACTION_HORDE .. ")"] = { 20176, 20163, 20159 },
		[L["PVP Leather Sets"].." (" .. FACTION_ALLIANCE .. ")"] = { 20059, 20045, 20052, 20060, 20046, 20053 },
		[L["PVP Leather Sets"].." (" .. FACTION_HORDE .. ")"] = { 20194, 20190, 20186, 20175, 20171, 20167 },
		[L["PVP Mail Sets"].." (" .. FACTION_ALLIANCE .. ")"] = { 20055, 20043, 20050, 20056, 20044, 20051 },
		[L["PVP Mail Sets"].." (" .. FACTION_HORDE .. ")"] = { 20158, 20150, 20154, 20203, 20195, 20199 },
		[L["PVP Plate Sets"].." (" .. FACTION_ALLIANCE .. ")"] = { 20057, 20041, 20048, 20058, 20042, 20049 },
		[L["PVP Plate Sets"].." (" .. FACTION_HORDE .. ")"] = { 20212, 20204, 20208 }
	},
	["Warsong Gulch"] = {	--  "Warsong Gulch"
		[L["Miscellaneous"].." (" .. FACTION_ALLIANCE .. ")"] = {	19506 },
		[L["Miscellaneous"].." (" .. FACTION_HORDE .. ")"] = {	19505 },
		[L["Miscellaneous"]] = { 17348, 17349, 19060, 19062, 19067, 17351, 17352, 19061, 19066, 19068 },
		[format(L["Lv %s Rewards"], "10-19").." (" .. FACTION_ALLIANCE .. ")"] = {	20428, 20444, 20431, 20439, 20443, 20440, 20434, 20438 },
		[format(L["Lv %s Rewards"], "10-19").." (" .. FACTION_HORDE .. ")"] = {	20427, 20442, 20426, 20429, 20441, 20430, 20425, 20437 },
		[format(L["Lv %s Rewards"], "20-29").." (" .. FACTION_ALLIANCE .. ")"] = {	19533, 19541, 19525, 19517, 21568, 21566, 19549, 19557, 19573, 19565 },
		[format(L["Lv %s Rewards"], "20-29").." (" .. FACTION_HORDE .. ")"] = {	19529, 19537, 19521, 19513, 21568, 21566, 19545, 19553, 19569, 19561 },
		[format(L["Lv %s Rewards"], "30-39").." (" .. FACTION_ALLIANCE .. ")"] = {	19532, 19540, 19524, 19515, 19548, 19556, 19572, 19564 }, 
		[format(L["Lv %s Rewards"], "30-39").." (" .. FACTION_HORDE .. ")"] = {	19528, 19536, 19520, 19512, 19544, 19552, 19568, 19560 },
		[format(L["Lv %s Rewards"], "40-49").." (" .. FACTION_ALLIANCE .. ")"] = {	19597, 19590, 19584, 19581, 19531, 19539, 19523, 19516, 21567, 21565, 
													19547, 19555, 19571, 19563 }, 
		[format(L["Lv %s Rewards"], "40-49").." (" .. FACTION_HORDE .. ")"] = {	19597, 19590, 19584, 19581, 19527, 19535, 19519, 19511, 21567, 21565, 
													19543, 19551, 19567, 19559 },
		[format(L["Lv %s Rewards"], "50-59").." (" .. FACTION_ALLIANCE .. ")"] = {	19596, 19589, 19583, 19580, 19530, 19538, 19522, 19514, 19546, 19554, 19570, 19562 }, 
		[format(L["Lv %s Rewards"], "50-59").." (" .. FACTION_HORDE .. ")"] = {	19596, 19589, 19583, 19580, 19526, 19534, 19518, 19510, 19542, 19550, 
													19566, 19558 },
		[format(L["Lv %s Rewards"], "60").." (" .. FACTION_ALLIANCE .. ")"] = {	19595, 22752, 19587, 22749, 22750, 19582, 22748, 30497, 19578, 22753, 22672 }, 
		[format(L["Lv %s Rewards"], "60").." (" .. FACTION_HORDE .. ")"] = {	19595, 22747, 19587, 22740, 22741, 19582, 22673, 22676, 19578, 30498, 22651 }
	},
	[L["World PVP"]] = {	
		[L["Hellfire Fortifications"]] = { 27833, 27786, 28360, 27830, 27785, 27777, 24520, 24579, 24522, 24581 },
		[L["Twin Spire Ruins"]] = { 27990, 27984, 27922, 27929, 27939, 27983, 27920, 27927, 27930	},
		[L["Spirit Towers (Terrokar)"]] = { 28553, 28557, 28759, 28574, 28575, 28577, 28560, 28761, 32947, 28555, 
								28556, 28760, 28561, 28576, 28758, 28559, 32948	},
		[L["Halaa (Nagrand)"]] = {	28915, 27679, 27649, 27648, 27650, 27647, 27652, 27654, 27653, 24208, 
								29228, 27680, 27638, 27645, 27637, 27646, 27643, 27644, 27639, 33783, 
								32071, 30611, 30615, 30598, 30597, 30599, 30612, 30571, 30570, 30568 }
	},

	[format(L["Arena Season %d"], 1)] = {	
		[L["Druid Set"]] = { 28127, 28129, 28130, 28126, 28128, 28137, 28139, 28140, 28136, 28138,
								31376, 31378, 31379, 31375, 31377 },
		[L["Hunter Set"]] = { 28331, 28333, 28334, 28335, 28332 },
		[L["Mage Set"]] = { 25855, 25854, 25856, 25857, 25858 },
		[L["Paladin Set"]] = { 27704, 27706, 27702, 27703, 27705, 27881, 27883, 27879, 27880, 27882, 
								31616, 31619, 31613, 31614, 31618 },
		[L["Priest Set"]] = { 27708, 27710, 27711, 27707, 27709, 31410, 31412, 31413, 31409, 31411 },
		[L["Rogue Set"]] = {	25830, 25832, 25831, 25834, 25833 },
		[L["Shaman Set"]] = { 25998, 25999, 25997, 26000, 26001,27471, 27473, 27469, 27470, 27472, 
								31400, 31407, 31396, 31397, 31406 },
		[L["Warlock Set"]] = { 24553, 24554, 24552, 24556, 24555, 30187, 30186, 30200, 30188, 30201 },
		[L["Warrior Set"]] = { 24545, 24546, 24544, 24549, 24547 },
		[L["Weapons"]] = { 28313, 28314, 28297, 28312, 28310, 28295, 28307, 24550, 28308, 28309, 
								28298, 32450, 32451, 28305, 28302, 28299, 28476, 28300, 24557, 28358, 
								28319, 28294, 28320, 28346, 32452, 33945, 33942, 28355, 33936, 28356, 
								33948, 33939, 33951, 28357 }
	},
	[format(L["Arena Season %d"], 2)] = {	
		[L["Druid Set"]] = { 31968, 31971, 31972, 31967, 31969, 32057, 32059, 32060, 32056, 32058, 
								31988, 31990, 31991, 31987, 31989 },
		[L["Hunter Set"]] = { 31962, 31964, 31960, 31961, 31963 },
		[L["Mage Set"]] = { 32048, 32047, 32050, 32049, 32051 },
		[L["Paladin Set"]] = { 31997, 31996, 31992, 31993, 31995, 32041, 32043, 32039, 32040, 32042, 
								32022, 32024, 32020, 32021, 32023 },
		[L["Priest Set"]] = { 32035, 32037, 32038, 32034, 32036, 32016, 32018, 32019, 32015, 32017 },
		[L["Rogue Set"]] = {	31999, 32001, 32002, 31998, 32000 },
		[L["Shaman Set"]] = { 32006, 32008, 32004, 32005, 32007, 32011, 32013, 32009, 32010, 32012, 
								32031, 32033, 32029, 32030, 32032 },
		[L["Warlock Set"]] = { 31974, 31976, 31977, 31973, 31975, 31980, 31979, 31982, 31981, 31983 },
		[L["Warrior Set"]] = { 30488, 30490, 30486, 30487, 30489 },
		[L["Weapons"]] = { 32028, 32003, 32053, 32044, 32046, 32052, 32027, 31984, 31965, 31985, 
								31966, 32963, 32964, 32026, 31958, 31959, 32014, 32025, 32055, 33313, 
								33309, 32045, 32054, 31986, 32962, 31978, 32961, 33946, 33943, 33076, 
								33937, 33077, 33949, 33940, 33952, 33078 }
	},
	[format(L["Arena Season %d"], 3)] = {	
		[L["Druid Set"]] = { 33672, 33674, 33675, 33671, 33673, 33768, 33770, 33771, 33767, 33769, 
								33691, 33693, 33694, 33690, 33692 },
		[L["Hunter Set"]] = { 33666, 33668, 33664, 33665, 33667 },
		[L["Mage Set"]] = { 33758, 33757, 33760, 33759, 33761 },
		[L["Paladin Set"]] = { 33697, 33699, 33695, 33696, 33698, 33751, 33753, 33749, 33750, 33752, 
								33724, 33726, 33722, 33723, 33725 },
		[L["Priest Set"]] = { 33745, 33747, 33748, 33744, 33746, 33718, 33720, 33721, 33717, 33719  },
		[L["Rogue Set"]] = {	33701, 33703, 33704, 33700, 33702 },
		[L["Shaman Set"]] = { 33708, 33710, 33706, 33707, 33709, 33713, 33715, 33711, 33712, 33714, 
								33740, 33742, 33738, 33739, 33741 },
		[L["Warlock Set"]] = { 33677, 33679, 33680, 33676, 33678, 33683, 33682, 33685, 33684, 33686 },
		[L["Warrior Set"]] = { 33730, 33732, 33728, 33729, 33731 },
		[L["Weapons"]] = { 33737, 33705, 34016, 33763, 33754, 33801, 33756, 33762, 33734, 33688, 
								33669, 34015, 33689, 33670, 34014, 33687, 33743, 33733, 33662, 33663, 
								33727, 34540, 33716, 33766, 33661, 33735, 33755, 33765, 34529, 33006, 
								34530, 34059, 34066, 33764, 33681, 34033, 33736, 33947, 33944, 33841, 
								33938, 33842, 33950, 33941, 33953, 33843 }
	},
	[format(L["Arena Season %d"], 4)] = {
		[L["Druid Set"]] = { 34999, 35001, 35002, 34998, 35000, 35112, 35114, 35115, 35111, 35113, 
								35023, 35025, 35026, 35022, 35024 },
		[L["Hunter Set"]] = { 34992, 34994, 34990, 34991, 34993 },
		[L["Mage Set"]] = { 35097, 35096, 35099, 35098, 35100 },
		[L["Paladin Set"]] = { 35029, 35031, 35027, 5028, 35030, 35090, 35092, 35088, 35089, 35091, 
								35061, 35063, 35059, 35060, 35062 },
		[L["Priest Set"]] = { 35084, 35086, 35087, 35083, 35085, 35054, 35056, 35057, 35053, 35055 },
		[L["Rogue Set"]] = {	35033, 35035, 35036, 35032, 35034 },
		[L["Shaman Set"]] = { 35044, 35046, 35042, 35043, 35045, 35050, 35052, 35048, 35049, 35051, 
								35079, 35081, 35077, 35078, 35080 },
		[L["Warlock Set"]] = { 35004, 35006, 35007, 35003, 35005, 35010, 35009, 35012, 35011, 35013 },
		[L["Warrior Set"]] = { 35068, 35070, 35066, 35067, 35069 },
		[L["Weapons"]] = { 35076, 35038, 35037, 35102, 37739, 35093, 35058, 35095, 35101, 35072, 
								35015, 34996, 34995, 35017, 34997, 35110, 35014, 35082, 37740, 35071, 
								34988, 34989, 35064, 34987, 35103, 35109, 34986, 35073, 35094, 35108, 
								35047, 35018, 35075, 34985, 35065, 35107, 35008, 35016, 35074, 35019, 
								35020, 35021, 35039, 35040, 35041, 35104, 35105, 35106 }
	},
	
	[format(L["Level %d Honor PVP"], 60)] = {	
		[L["Druid Set"]] = { 16451, 16449, 16452, 16448, 16450, 16459, 23308, 23309, 23294, 23280, 
								23295, 23281, 16550, 16551, 16549, 16555, 16552, 16554, 23253, 23254, 
								22877, 22863, 22878, 22852 },
		[L["Hunter Set"]] = { 16465, 16468, 16466, 16463, 16467, 16462, 23306, 23307, 23292, 23279, 
								23293, 23278, 16566, 16568, 16565, 16571, 16567, 16569, 23251, 23252, 
								22874, 22862, 22875, 22843 },
		[L["Mage Set"]] = { 16441, 16444, 16443, 16440, 16442, 16437, 23318, 23319, 23305, 23290, 
								23304, 23291, 16533, 16536, 16535, 16540, 16534, 16539, 23263, 23264, 
								22886, 22870, 22883, 22860 },
		[L["Paladin Set"]] = { 16474, 16476, 16473, 16471, 16475, 16472, 23276, 23277, 23272, 23274, 
								23273, 23275, 29616, 29617, 29615, 29613, 29614, 29612, 29604, 29605, 
								29602, 29600, 29603, 29601 },
		[L["Priest Set"]] = { 17602, 17604, 17605, 17608, 17603, 17607, 23316, 23317, 23303, 23288, 
								23302, 23289, 17623, 17622, 17624, 17620, 17625, 17618, 23261, 23262, 
								22885, 22869, 22882, 22859 },
		[L["Rogue Set"]] = {	16455, 16457, 16453, 16454, 16456, 16446, 23312, 23313, 23298, 23284, 
								23299, 23285, 16561, 16562, 16563, 16560, 16564, 16558, 23257, 23258, 
								22879, 22864, 22880, 22856 },
		[L["Shaman Set"]] = { 29610, 29611, 29609, 29607, 29608, 29606, 29598, 29599, 29596, 29595, 
								29597, 29594, 16578, 16580, 16577, 16574, 16579, 16573, 23259, 23260, 
								22876, 22867, 22887, 22857 },
		[L["Warlock Set"]] = { 17578, 17580, 17581, 17584, 17579, 17583, 23310, 23311, 23297, 23282, 
								23296, 23283, 17591, 17590, 17592, 17588, 17593, 17586, 23255, 23256, 
								22884, 22865, 22881, 22855 },
		[L["Warrior Set"]] = { 16478, 16480, 16477, 16484, 16479, 16483, 23314, 23315, 23300, 23286, 
								23301, 23287, 16542, 16544, 16541, 16548, 16543, 16545, 23244, 23243, 
								22872, 22868, 22873, 22858 },
		[L["Weapons"] .. " (" .. FACTION_ALLIANCE .. ")"] = { 18843, 18847, 23451, 18838, 12584, 23456, 18876, 18827, 18830, 23454, 
								18865, 18867, 23455, 18869, 18873, 18825, 18833, 18836, 18855, 23452, 23453 },
		[L["Weapons"] .. " (" .. FACTION_HORDE .. ")"] = { 18844, 18848, 23466, 18840, 16345, 23467, 18877, 18828, 18831, 23464, 
								18866, 18868, 23465, 18871, 18874, 18826, 18835, 18837, 18860, 23468, 23469 },
		[L["Accessories"] .. " (" .. FACTION_ALLIANCE .. ")"] = { 29465, 29467, 29468, 29471, 35906, 18863, 18856, 18859, 18864, 18862, 
								18857, 29593, 18858, 18854, 18440, 18441, 16342, 18457, 18456, 18455, 
								18454, 18453, 18452, 18449, 18448, 18447, 18445, 18442, 18444, 18443, 
								15196, 15198, 18606, 18839, 18841, 32455 },
		[L["Accessories"] .. " (" .. FACTION_HORDE .. ")"] = { 29466, 29469, 29470, 29472, 34129, 18853, 18846, 18850, 29592, 18851, 
								18849, 18845, 18852, 18834, 18427, 16341, 18461, 18437, 16486, 18436, 
								18434, 18435, 16497, 18432, 16532, 18430, 18429, 15200, 18428, 16335, 
								15197, 15199, 18607, 18839, 18841, 32455 }
	},
	
	-- Tier 0 (dungeon 1) is already in the level 60 instances (strat, scholo ..)
	[L["Tier 0.5 Quests"]] = { 
		[L["Druid Set"]] = { 22109, 22112, 22113, 22108, 22110, 22106, 22111, 22107 },
		[L["Hunter Set"]] = { 22013, 22016, 22060, 22011, 22015, 22010, 22017, 22061 },
		[L["Mage Set"]] = { 22065, 22068, 22069, 22063, 22066, 22062, 22067, 22064 },
		[L["Paladin Set"]] = { 22091, 22093, 22089, 22088, 22090, 22086, 22092, 22087 },
		[L["Priest Set"]] = { 22080, 22082, 22083, 22079, 22081, 22078, 22085, 22084 },
		[L["Rogue Set"]] = { 22005, 22008, 22009, 22004, 22006, 22002, 22007, 22003 },
		[L["Shaman Set"]] = { 22097, 22101, 22102, 22095, 22099, 22098, 22100, 22096 },
		[L["Warlock Set"]] = { 22074, 22073, 22075, 22071, 22077, 22070, 22072, 22076 },
		[L["Warrior Set"]] = { 21999, 22001, 21997, 21996, 21998, 21994, 22000, 21995 }
	},	
	-- Dungeon 3 (level 70) is already in the BC 5-men
	
	-- Tier 1 is already in MC
	-- Tier 2 is already in BWL, Ony
	
	[format(L["Tier %d Tokens"], 3)] = {
		[L["Druid Set"]] = { 22490, 22491, 22488, 22495, 22493, 22494, 22489, 22492, 23064 },
		[L["Hunter Set"]] = { 22438, 22439, 22436, 22443, 22441, 22442, 22437, 22440, 23067 },
		[L["Mage Set"]] = { 22498, 22499, 22496, 22503, 22501, 22502, 22497, 22500, 23062 },
		[L["Paladin Set"]] = { 22428, 22429, 22425, 22424, 22426, 22431, 22427, 22430, 23066 },
		[L["Priest Set"]] = { 22514, 22515, 22512, 22519, 22517, 22518, 22513, 22516, 23061 },
		[L["Rogue Set"]] = { 22478, 22479, 22476, 22483, 22481, 22482, 22477, 22480, 23060 },
		[L["Shaman Set"]] = { 22466, 22467, 22464, 22471, 22469, 22470, 22465, 22468, 23065 },
		[L["Warlock Set"]] = { 22506, 22507, 22504, 22511, 22509, 22510, 22505, 22508, 23063 },
		[L["Warrior Set"]] = { 22418, 22419, 22416, 22423, 22421, 22422, 22417, 22420, 23059 }
	},
	

	[L["Blizzard Collectables"]] = {	
		[L["WoW Collector Edition"]] = {	13582, 13583, 13584 },
		[L["BC Collector Edition (Europe)"]] = { 25535, 30360 },
		[L["Blizzcon 2005"]] = { 20371 },
		[L["Blizzcon 2007"]] = { 33079 },
		["Worldwide Invitational Paris 2008"] = { 39656 },
		[L["Christmas Gift 2006"]] = { 22114 }
	},
	[L["Upper Deck"]] = {
		[L["Loot Card Items"]] = { 23705, 23713, 23720, 32588, 32566, 32542, 33225, 33224, 33223, 33219, 
					34493, 34492, 34499, 35226, 35225, 35223, 23709, 23714, 23716, 35227, 
					38050, 38301, 38233, 38312, 23709, 38313, 38309, 38310, 38314, 38314, 
					38311, 23716, 23714 }
	},
	
	[L["World Drops"]] = {
		[L["Level 30-39"]] = { 867, 1981, 1980, 869, 1982, 870, 868, 873, 1204, 2825 },
		[L["Level 40-49"]] = { 3075, 940, 14551, 17007, 14549, 1315, 942, 1447, 2164,  2163, 
								809, 871, 2291, 810, 2915, 812, 943, 1169, 1979, 2824, 2100 },
		[L["Level 50-60"]] = { 3475, 14553, 2245, 14552, 14554, 1443, 14558, 2246, 833, 14557,
								1728, 14555, 2244, 2801, 647, 811, 1263, 2243, 944, 1168, 2099 },
	},
	
	-- [] = {
	-- },
}

local DataProviders

addon.Loots = {}

local ns = addon.Loots		-- ns = namespace

function ns:GetSource(searchedID)
	if InCombatLockdown() then	return nil end		-- exit if combat lockdown restrictions are active

	DataProviders = DataProviders or {			-- list of sources that have a :GetSource() method
		DataStore_Reputations,
		-- DataStore_Crafts,
		DataStore_Inventory,
	}

	local domain, subDomain
	for _, provider in pairs(DataProviders) do
		domain, subDomain = provider:GetSource(searchedID)
		if domain and subDomain then
			if type(subDomain == "boolean") and subDomain == true then	-- some items have no subDomain (ex: archeology)
				subDomain = nil
			end
			return domain, subDomain
		end
	end
	
	-- extremely fast: takes from 0.3 to 3 ms max, depends on the location of the item in the table (obviously longer if the item is at the end)
	for Instance, BossList in pairs(lootTable) do
		for Boss, LootList in pairs(BossList) do
			for itemID, _ in pairs(LootList) do
				if LootList[itemID] == searchedID then
					return Instance, Boss
				end
			end
		end
	end
	
	local name, spellID = LCI:GetItemSource(searchedID)
	
	if name and spellID then
		return name, LCL:GetCraftLearnedAtLevel(spellID)
	end	
	
	return nil
end

local filters = addon.ItemFilters

local function ParseAltoholicLoots(OnMatch, OnNoMatch)
	assert(type(OnMatch) == "function")
	local count = 0
	
	for Instance, BossList in pairs(lootTable) do
		for Boss, LootList in pairs(BossList) do
			for _, itemID in pairs(LootList) do
				count = count + 1
				filters:SetSearchedItem(itemID)
				
				if filters:ItemPassesFilters() then
					OnMatch(Instance, Boss)
				else
					if OnNoMatch then
						OnNoMatch()
					end
				end
			end
		end
	end
	
	filters:ClearSearchedItem()
	return count
end

local function ParseLPTSet(set, OnMatch, OnNoMatch)
	assert(type(OnMatch) == "function")
	
	local PT = LibStub("LibPeriodicTable-3.1")
	if not PT then return 0 end		-- exit if LPT is not active

	-- LPT stores certain sets twice, but does not offer the possibility to differentiate entries (instances that are part of hubs)
	-- So keep track of the sets we've already parsed, to avoid returning items twice.
	local doneSets = {}
	local count = 0

	for _, list in pairs(PT:GetSetTable(set)) do
		local _, domain, subdomain = strsplit(".", list.set)
		
		if not doneSets[list.set] then			-- if this set hasn't been parsed yet, proceed..
			for itemID, value in pairs(list) do
				if tostring(itemID) ~= "set" then
					count = count + 1
					filters:SetSearchedItem(itemID)
					
					if filters:ItemPassesFilters() then
						OnMatch(domain, subdomain or value)		-- pass the value in case "subdomain" is nil
					else
						if OnNoMatch then
							OnNoMatch()
						end
					end
				end
			end
		end
		doneSets[list.set] = true
	end
	
	filters:ClearSearchedItem()
	return count
end

local allowedQueries, unknownCount

local function OnMatch(domain, subdomain)
	Altoholic.Search:AddResult( {
		id = filters:GetSearchedItemInfo("itemID"),
		iLvl = filters:GetSearchedItemInfo("itemLevel"),
		dropLocation = domain,
		bossName = subdomain,
	} )
end

local function Currency_OnMatch(domain, subdomain)
	Altoholic.Search:AddResult( {
		id = filters:GetSearchedItemInfo("itemID"),
		iLvl = filters:GetSearchedItemInfo("itemLevel"),
		dropLocation = domain,
		bossName = subdomain.."x",
	} )
end

local function OnNoMatch()
--	if FilterByExistence() then return end 	-- if the item exists, do nothing
	if filters:TryFilter("Existence") then return end 	-- if the item exists, do nothing
	unknownCount = unknownCount + 1
	
	if allowedQueries > 0 then
		if addon:GetOption("UI.Tabs.Search.ItemInfoAutoQuery") then		-- if autoquery is enabled
			local itemID = filters:GetSearchedItemInfo("itemID")
			if not addon:IsItemUnsafe(itemID) then		-- if the item is not known to be unsafe
				GameTooltip:SetHyperlink("item:"..itemID..":0:0:0:0:0:0:0")	-- this line queries the server for an unknown id
				GameTooltip:ClearLines(); -- don't leave residual info in the tooltip after the server query

				-- save ALL tested id's, clean the list in OnEnable during the next session.
				-- the unsafe list will be cleaned in OnEnable, by parsing all ids and testing if getiteminfo returns a nil or not, if so, it's a definite unsafe link
				addon:SaveUnsafeItem(itemID)			-- save id to unsafe list
			end
		end
		allowedQueries = allowedQueries - 1
	end
end

function ns:Find()
	unknownCount = 0
	allowedQueries = 5
	local count = ParseAltoholicLoots(OnMatch, OnNoMatch)
	count = count + ParseLPTSet("InstanceLoot", OnMatch, OnNoMatch)
	count = count + ParseLPTSet("InstanceLootHeroic", OnMatch, OnNoMatch)
	count = count + ParseLPTSet("CurrencyItems", Currency_OnMatch, OnNoMatch)

	addon:SetOption("TotalLoots", count)
	addon:SetOption("UnknownLoots", unknownCount)
end

function ns:FindUpgrade()
	local function OnMatch(domain, subdomain)
		addon.Search:AddResult( {
			id = filters:GetSearchedItemInfo("itemID"),
			iLvl = filters:GetSearchedItemInfo("itemLevel"),
			dropLocation = domain,
			bossName = subdomain,
		} )
	end
	
	ParseAltoholicLoots(OnMatch)
	ParseLPTSet("InstanceLoot", OnMatch)
	ParseLPTSet("InstanceLootHeroic", OnMatch)
	ParseLPTSet("CurrencyItems", Currency_OnMatch)
end

local tooltipLines			-- cache containing the text lines of the tooltip "+15 stamina, etc.."
local rawItemStats			-- contains the raw stats of the item currently being searched, placed here to avoid creating/deleting the table during the search
local currentItemStats		-- contains the stats of the item for which we'll try to find upgrades

local classExcludedStats
local classBaseStats

local function AddCurrentlyEquippedItem(itemID, class)

	AltoTooltip:SetOwner(AltoholicFrame, "ANCHOR_LEFT")
	local _, itemLink, _, itemLevel = GetItemInfo(itemID)
	AltoTooltip:SetHyperlink(itemLink)
	
	local statLine = addon.Equipment.FormatStats[class]
	local numLines = AltoTooltip:NumLines()
	
	local j=1
	for _, BaseStat in pairs(classBaseStats) do
		for i = 4, numLines do
			local tooltipText = _G[ "AltoTooltipTextLeft" .. i]:GetText()
			if tooltipText then
				if string.find(tooltipText, BaseStat) ~= nil then
					currentItemStats[BaseStat] = tonumber(string.sub(tooltipText, string.find(tooltipText, "%d+")))
					statLine = string.gsub(statLine, "-s", colors.white .. currentItemStats[BaseStat], 1)
					
					rawItemStats[j] = currentItemStats[BaseStat] .. "|0"
					break
				end
			end
		end
		if not currentItemStats[BaseStat] then
			rawItemStats[j] = "0|0"
		
			currentItemStats[BaseStat] = 0 -- Set the current stat to zero if it was not found on the item
			statLine = string.gsub(statLine, "-s", colors.white .. "0", 1)
		end
		j = j + 1
	end
	AltoTooltip:ClearLines();
	
	-- Save currently equipped item to the results table
	addon.Search:AddResult( {
		id = itemID,
		iLvl = itemLevel,
		dropLocation = "Currently equipped",
		stat1 = rawItemStats[1],
		stat2 = rawItemStats[2],
		stat3 = rawItemStats[3],
		stat4 = rawItemStats[4],
		stat5 = rawItemStats[5],
		stat6 = rawItemStats[6]
	} )
end

local function MatchUpgradeByStats(itemID)
	filters:SetSearchedItem(itemID)
	if not filters:ItemPassesFilters() then 
		filters:ClearSearchedItem()
		return
	end

	AltoTooltip:ClearLines();	
	AltoTooltip:SetOwner(AltoholicFrame, "ANCHOR_LEFT");
	AltoTooltip:SetHyperlink(filters:GetSearchedItemInfo("itemLink"))
	
	-- save some time by trying to find out if the item could be excluded
	wipe(tooltipLines)
	for i = 4, AltoTooltip:NumLines() do	-- parse all tooltip lines, one by one, start at 4 since 1= item name, 2 = binds on.., 3 = type/slot/unique ..etc
		-- in this first pass, save the lines into a cache, reused below
		local tooltipLine = _G[ "AltoTooltipTextLeft" .. i]:GetText()
		if tooltipLine then
			if string.find(tooltipLine, L["Socket"]) == nil then
				for _, v in pairs(classExcludedStats) do
					--if string.find(tooltipLine, v, 1, true) ~= nil then return end
					if string.find(tooltipLine, v) ~= nil then return end
				end
				tooltipLines[i] = tooltipLine
			end
		end
	end
	
	local statFound
	local j=1
	for _, BaseStat in pairs(classBaseStats) do

		statFound = nil
		for i, tooltipText in pairs(tooltipLines) do
			--if string.find(tooltipText, BaseStat, 1, true) ~= nil then
			if string.find(tooltipText, BaseStat) ~= nil then
				--local stat = tonumber(string.sub(tooltipText, string.find(tooltipText, "%d+")))
				local stat = tonumber(string.match(tooltipText, "%d+"))
				
				rawItemStats[j] = stat .. "|" .. (stat - currentItemStats[BaseStat])
				table.remove(tooltipLines, i)	-- remove the current entry, so it won't be parsed in the next loop cycle
				statFound = true
				break
			end
		end
		
		if not statFound then
			rawItemStats[j] = "0|" .. (0 - currentItemStats[BaseStat])
		end
		j = j + 1
	end
	
	local iLvl = filters:GetSearchedItemInfo("itemLevel")
	filters:ClearSearchedItem()
		
	-- All conditions ok ? save it
	return true, iLvl
end

-- modify this one after 3.2, to use GetItemStats
function ns:FindUpgradeByStats(currentID, class)
	classExcludedStats = addon.Equipment.ExcludeStats[class]
	classBaseStats = addon.Equipment.BaseStats[class]
	
	rawItemStats = {}
	currentItemStats = {}
	tooltipLines = {}
	
	AddCurrentlyEquippedItem(currentID, class)
	
	for Instance, BossList in pairs(lootTable) do		-- parse the loot table to find an upgrade
		for Boss, LootList in pairs(BossList) do
			for _, itemID in pairs(LootList) do
			
				local matches, itemLevel = MatchUpgradeByStats(itemID)
				
				if matches then
					addon.Search:AddResult( {
						id = itemID,
						iLvl = itemLevel,
						dropLocation = Instance .. ", " .. colors.green .. Boss,
						stat1 = rawItemStats[1],
						stat2 = rawItemStats[2],
						stat3 = rawItemStats[3],
						stat4 = rawItemStats[4],
						stat5 = rawItemStats[5],
						stat6 = rawItemStats[6]
					} )
				end
			end
		end
	end
	
	classExcludedStats = nil
	classBaseStats = nil
	currentItemStats = nil
	tooltipLines = nil
	rawItemStats = nil
end
