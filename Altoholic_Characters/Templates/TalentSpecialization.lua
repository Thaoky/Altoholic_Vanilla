local addonName = "Altoholic"
local addon = _G[addonName]
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local colors = addon.Colors

-- ** Arrows **
local INITIAL_OFFSET_X = 10				-- constants used for positioning talents
local INITIAL_OFFSET_Y = 8
local TALENT_OFFSET_X = 50
local TALENT_OFFSET_Y = 42
local TALENT_BUTTON_SIZE = 28
local NUM_TALENT_TIERS = 7
local NUM_TALENT_COLUMNS = 4
local NUM_TALENT_BUTTONS = 28

local TALENT_ARROW_TEXTURECOORDS = {
	top = {
		[1] = {0, 0.5, 0, 0.5},
		[-1] = {0, 0.5, 0.5, 1.0}
	},
	right = {
		[1] = {1.0, 0.5, 0, 0.5},
		[-1] = {1.0, 0.5, 0.5, 1.0}
	},
	left = {
		[1] = {0.5, 1.0, 0, 0.5},
		[-1] = {0.5, 1.0, 0.5, 1.0}
	},
}

-- ** Branches **

local TALENT_BRANCH_TEXTURECOORDS = {
	up = {
		[1] = {0.12890625, 0.25390625, 0 , 0.484375},
		[-1] = {0.12890625, 0.25390625, 0.515625 , 1.0}
	},
	down = {
		[1] = {0, 0.125, 0, 0.484375},
		[-1] = {0, 0.125, 0.515625, 1.0}
	},
	left = {
		[1] = {0.2578125, 0.3828125, 0, 0.5},
		[-1] = {0.2578125, 0.3828125, 0.5, 1.0}
	},
	right = {
		[1] = {0.2578125, 0.3828125, 0, 0.5},
		[-1] = {0.2578125, 0.3828125, 0.5, 1.0}
	},
	topright = {
		[1] = {0.515625, 0.640625, 0, 0.5},
		[-1] = {0.515625, 0.640625, 0.5, 1.0}
	},
	topleft = {
		[1] = {0.640625, 0.515625, 0, 0.5},
		[-1] = {0.640625, 0.515625, 0.5, 1.0}
	},
	bottomright = {
		[1] = {0.38671875, 0.51171875, 0, 0.5},
		[-1] = {0.38671875, 0.51171875, 0.5, 1.0}
	},
	bottomleft = {
		[1] = {0.51171875, 0.38671875, 0, 0.5},
		[-1] = {0.51171875, 0.38671875, 0.5, 1.0}
	},
	tdown = {
		[1] = {0.64453125, 0.76953125, 0, 0.5},
		[-1] = {0.64453125, 0.76953125, 0.5, 1.0}
	},
	tup = {
		[1] = {0.7734375, 0.8984375, 0, 0.5},
		[-1] = {0.7734375, 0.8984375, 0.5, 1.0}
	},
}

addon:Controller("AltoholicUI.TalentSpecialization", {
	-- ** Arrows **
	ResetArrowCount = function(frame)
		frame.numArrows = 1
	end,
	HideUnusedArrows = function(frame)
		while frame.numArrows <= 30 do
			frame.Tree.ArrowsFrame[format("Arrow%d", frame.numArrows)]:Hide()
			frame.numArrows = frame.numArrows + 1
		end
		frame.numArrows = nil
	end,
	DrawArrow = function(frame, tier, column, prereqTier, prereqColumn, blocked)
		local arrowType					-- algorithm taken from TalentFrameBase.lua, adjusted for my needs
		
		if column == prereqColumn then			-- Same column ? ==> TOP
			arrowType = "top"
		elseif tier == prereqTier then			-- Same tier ? ==> LEFT or RIGHT
			arrowType = (column < prereqColumn) and "right" or "left"
		else												-- None of these ? ==> diagonal
			if not blocked then
				arrowType = "top"
			else
				arrowType = (column < prereqColumn) and "right" or "left"
			end
		end
		
		if not arrowType then return end
		
		local x, y
		if arrowType == "top" then
			x = 2
			y = 18
		elseif arrowType == "left" then
			x = -17
			y = -2
		elseif arrowType == "right" then
			x = 17
			y = -2
		end
		
		x = x + INITIAL_OFFSET_X + ((column-1) * TALENT_OFFSET_X)
		y = y - (INITIAL_OFFSET_Y + ((tier-1) * TALENT_OFFSET_Y)) - 8
		
		local arrow = frame.Tree.ArrowsFrame[format("Arrow%d", frame.numArrows)]
		local tc = TALENT_ARROW_TEXTURECOORDS[arrowType][1]
		
		arrow:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
		arrow:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", x, y)
		arrow:Show()
		
		frame.numArrows = frame.numArrows + 1
	end,

	-- ** Talent Buttons **
	ResetButtonCount = function(frame)
		frame.numButtons = 1
	end,
	HideUnusedButtons = function(frame)
		while frame.numButtons <= NUM_TALENT_BUTTONS do
			local button = frame.Tree[format("Talent%d", frame.numButtons)]
			button:Hide()
			button:SetID(0)	
			
			frame.numButtons = frame.numButtons + 1
		end
		frame.numButtons = nil
	end,
	DrawTalent = function(frame, texture, tier, column, rank, maxRank, talentName, id)
		local itemButton = frame.Tree[format("Talent%d", frame.numButtons)]

		itemButton:SetPoint("TOPLEFT", itemButton:GetParent(), "TOPLEFT", 
			INITIAL_OFFSET_X + ((column-1) * TALENT_OFFSET_X), 
			-(INITIAL_OFFSET_Y + ((tier-1) * TALENT_OFFSET_Y)))
		itemButton:SetID(id)

		if texture then
			itemButton:SetIcon(texture)
		end
		
		local itemCount = itemButton.Count
		
		if rank and rank > 0 then
			itemCount:SetText(format("%s%d", colors.green, rank))
			itemCount:Show()
			itemButton:EnableIcon()
		else
			itemButton:DisableIcon()
			itemCount:Hide()
		end
		itemButton:Show()
		
		itemButton.talentName = talentName
		itemButton.rank = rank
		itemButton.maxRank = maxRank

		frame.numButtons = frame.numButtons + 1
	end,

	-- ** Branches **
	ResetBranchCount = function(frame)
		frame.numBranches = 1
	end,
	HideUnusedBranches = function(frame)
		while frame.numBranches <= 30 do
			frame.Tree[format("Branch%d", frame.numBranches)]:Hide()
			frame.numBranches = frame.numBranches + 1
		end
		frame.numBranches = nil
	end,
	InitializeBranchArray = function(frame)
		frame.branchArray = frame.branchArray or {}		-- a 2-dimensional array to hold branches
		wipe(frame.branchArray)
		
		for i = 1, NUM_TALENT_TIERS do
			frame.branchArray[i] = {}
			for j = 1, NUM_TALENT_COLUMNS do
				frame.branchArray[i][j] = {}
			end
		end
	end,
	ClearBranchArray = function(frame)
		wipe(frame.branchArray)
		frame.branchArray = nil
	end,
	InitBranch = function(frame, tier, column, prereqTier, prereqColumn, blocked)

		-- algorithm taken from TalentFrameBase.lua, adjusted for my needs
		local left = min(column, prereqColumn)
		local right = max(column, prereqColumn)
		
		local branchArray = frame.branchArray
		
		if (column == prereqColumn) then			-- Same column ? ==> TOP
			for i = prereqTier, tier - 1 do
				branchArray[i][column].down = true
				if ( (i + 1) <= (tier - 1) ) then
					branchArray[i+1][column].up = true
				end
			end
			return
		end
			
		if (tier == prereqTier) then			-- Same tier ? ==> LEFT or RIGHT
			for i = left, right-1 do
				branchArray[prereqTier][i].right = true
				branchArray[prereqTier][i+1].left = true
			end
			return
		end

		-- None of these ? ==> diagonal
		if not blocked then
			branchArray[prereqTier][column].down = true
			branchArray[tier][column].up = true
			
			for i = prereqTier, tier - 1 do
				branchArray[i][column].down = true
				branchArray[i + 1][column].up = true
			end

			for i = left, right - 1 do
				branchArray[prereqTier][i].right = true
				branchArray[prereqTier][i+1].left = true
			end
		else
			for i=prereqTier, tier-1 do
				branchArray[i][column].up = true
				branchArray[i + 1][column].down = true
			end
		end
	end,
	SetBranchTexture = function(frame, branchType, x, y)
		local branch = frame.Tree[format("Branch%d", frame.numBranches)]
		
		local tc = TALENT_BRANCH_TEXTURECOORDS[branchType][1]
		
		branch:SetTexCoord(tc[1], tc[2], tc[3], tc[4]);
		branch:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", x, y)
		branch:Show()
		
		frame.numBranches = frame.numBranches + 1
	end,
	DrawBranches = function(frame)
		local x, y
		local ignoreUp
		
		for i = 1, NUM_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local p = frame.branchArray[i][j]
				
				x = INITIAL_OFFSET_X + ((j-1) * TALENT_OFFSET_X) + 2
				y = -(INITIAL_OFFSET_Y + ((i-1) * TALENT_OFFSET_Y)) - 2
				
				if p.node then			-- there's a talent there
					if p.up then
						if not ignoreUp then
							frame:SetBranchTexture("up", x, y + TALENT_BUTTON_SIZE)
						else
							ignoreUp = nil
						end
					end
					if p.down then frame:SetBranchTexture("down", x, y - TALENT_BUTTON_SIZE + 1) end
					if p.left then frame:SetBranchTexture("left", x - TALENT_BUTTON_SIZE, y) end
					if p.right then frame:SetBranchTexture("right", x + TALENT_BUTTON_SIZE, y) end			
				else
					if p.up and p.left and p.right then
						frame:SetBranchTexture("tup", x, y)
					elseif p.down and p.left and p.right then
						frame:SetBranchTexture("tdown", x, y)
					elseif p.left and p.down then
						frame:SetBranchTexture("topright", x, y)
						frame:SetBranchTexture("down", x, y-TALENT_BUTTON_SIZE)
					elseif p.left and p.up then
						frame:SetBranchTexture("bottomright", x, y)
					elseif p.left and p.right then
						frame:SetBranchTexture("right", x + TALENT_BUTTON_SIZE, y)
						frame:SetBranchTexture("left", x+1, y)
					elseif p.right and p.down then
						frame:SetBranchTexture("topleft", x, y)
						frame:SetBranchTexture("down", x, y-32)
					elseif p.right and p.up then
						frame:SetBranchTexture("bottomleft", x, y)
					elseif p.up and p.down then
						frame:SetBranchTexture("up", x, y)
						frame:SetBranchTexture("down", x, y-TALENT_BUTTON_SIZE)
						ignoreUp = true
					end
				end

				p.up = nil			-- clear after use
				p.left = nil
				p.right = nil
				p.down = nil
				p.node = nil
			end
		end
	end,
	
	-- *** Talents ***
	DrawBackground = function(frame, class, treeName, disabled)
		
		-- draws the background of a given class/tree,
		-- disabled : color or grayscale

		local _, bg = DataStore:GetTreeInfo(class, treeName)
		frame.TopLeft:SetTexture(bg.."-TopLeft")
		frame.TopRight:SetTexture(bg.."-TopRight")
		frame.BottomLeft:SetTexture(bg.."-BottomLeft")
		frame.BottomRight:SetTexture(bg.."-BottomRight")
		
		SetDesaturation(frame.TopLeft, disabled)
		SetDesaturation(frame.TopRight, disabled)
		SetDesaturation(frame.BottomLeft, disabled)
		SetDesaturation(frame.BottomRight, disabled)
	end,
	DrawTree = function(frame, class, treeName, character, guildMember)
		-- character = character key of the alt 
		-- guildMember = in case no character key is passed, it's a guild member, only his name is necessary
		
		frame:ResetButtonCount()
		frame:ResetArrowCount()
		frame:ResetBranchCount()
		frame:InitializeBranchArray()
		
		-- draw all icons in their respective slot
		for i = 1, DataStore:GetNumTalents(class, treeName) do
			local _, talentName, texture, tier, column, maxRank = DataStore:GetTalentInfo(class, treeName, i)
			local rank
			
			if character then
				rank = DataStore:GetTalentRank(character, treeName, i)
			elseif guildMember then
				rank = DataStore:GetGuildMemberTalentRank(currentGuildKey, guildMember, treeName, currentGuildMemberTalentGroup, i)
			end
			
			frame:DrawTalent(texture, tier, column, rank, maxRank, talentName, i)
			frame.branchArray[tier][column].node = true

			-- Draw arrows & branches where applicable
			local prereqTier, prereqColumn = DataStore:GetTalentPrereqs(class, treeName, i)
			if prereqTier and prereqColumn then
				local left = min(column, prereqColumn)
				local right = max(column, prereqColumn)

				if left == prereqColumn then		-- Don't check the location of the current button
					left = left + 1
				else
					right = right - 1
				end
				
				local blocked								-- Check for blocking talents
				for j = 1, DataStore:GetNumTalents(class, treeName) do
					local _, _, _, searchedTier, searchedColumn = DataStore:GetTalentInfo(class, treeName, j)
				
					if searchedTier == prereqTier then				-- do nothing if lower tier, process if same tier, exit if higher tier
						if (searchedColumn >= left) and (searchedColumn <= right) then
							blocked = true
							break
						end
					elseif searchedTier > prereqTier then
						break
					end
				end
				
				frame:DrawArrow(tier, column, prereqTier, prereqColumn, blocked)
				frame:InitBranch(tier, column, prereqTier, prereqColumn, blocked)
			end
		end
		frame:DrawBranches()
		
		frame:HideUnusedButtons()
		frame:HideUnusedArrows()
		frame:HideUnusedBranches()
		frame:ClearBranchArray()	
	end,
})
