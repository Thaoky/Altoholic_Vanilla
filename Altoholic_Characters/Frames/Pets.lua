local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local PETS_PER_PAGE = 12

local selectedID
local currentPetType
local currentPage
local currentPetName

addon.Pets = {}

local ns = addon.Pets		-- ns = namespace

function ns:OnEnter(frame)
	local id = frame.spellID
	if id then 
		AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
		AltoTooltip:ClearLines();
		AltoTooltip:SetHyperlink("spell:" ..id);
		AltoTooltip:Show();
	end
end

function ns:OnClick(frame, button)
	if frame.spellID and ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			local link = DataStore:GetCompanionLink(frame.spellID)
			if link then
				chat:Insert(link)
			end
		end
	end

	frame:SetChecked(true);

	local offset = (currentPage-1) * PETS_PER_PAGE
	selectedID = offset + frame:GetID()
	ns:UpdatePets()
end

-- ** Single pet view **
local function SetPage(pageNum)
	currentPage = pageNum
	
	local character = addon.Tabs.Characters:GetAltKey()
	local pets = DataStore:GetPets(character, currentPetType)
	
	if currentPage == 1 then
		AltoholicFramePetsNormalPrevPage:Disable()
	else
		AltoholicFramePetsNormalPrevPage:Enable()
	end
	
	local maxPages = 1
	if pets then
		maxPages = ceil(DataStore:GetNumPets(pets) / PETS_PER_PAGE)
		if maxPages == 0 then
			maxPages = 1
		end
	end
	
	if currentPage == maxPages then
		AltoholicFramePetsNormalNextPage:Disable()
	else
		AltoholicFramePetsNormalNextPage:Enable()
	end
	
	AltoholicFramePetsNormal_PageNumber:SetText(format(MERCHANT_PAGE_NUMBER, currentPage, maxPages ))
	ns:UpdatePets()
end

function ns:GoToPreviousPage()
	SetPage(currentPage - 1)
end

function ns:GoToNextPage()
	SetPage(currentPage + 1)
end

function ns:SetSinglePetView(petType)
	selectedID = 1
	currentPetType = petType
	
	AltoholicFramePetsNormal:Show()
	AltoholicFramePets:Show()
	
	SetPage(1)
end

function ns:UpdatePets()
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	local pets = DataStore:GetPets(character, currentPetType)
	
	local num = DataStore:GetNumPets(pets)
	
	if currentPetType == "MOUNT" then
		AltoholicTabCharacters.Status:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), format(MOUNTS .. " %s(%d)", colors.green, num)))
	else
		AltoholicTabCharacters.Status:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), format(COMPANIONS .. " %s(%d)", colors.green, num)))
	end
	
	if not pets or (num == 0) then		-- added this test as simply addressing the table seems to make it grow, I'd assume this is due to AceDB magic value ['*'].
		for i = 1, PETS_PER_PAGE do
			local button = _G["AltoholicFramePetsNormal_Button" .. i];
		
			if currentPetType == "MOUNT" then
				button:SetDisabledTexture([[Interface\PetPaperDollFrame\UI-PetFrame-Slots-Mounts]])
			else
				button:SetDisabledTexture([[Interface\PetPaperDollFrame\UI-PetFrame-Slots-Companions]])
			end
			button:Disable();
			button:SetChecked(false);
		end
		return
	end
	
	local offset = (currentPage-1) * PETS_PER_PAGE
	
	for i = 1, PETS_PER_PAGE do
		local index = offset + i
		local button = _G["AltoholicFramePetsNormal_Button" .. i];
		
		local modelID, name, spellID, icon = DataStore:GetPetInfo(pets, index)
		
		if icon and spellID then						-- if there's a pet  .. texture & enable it
			button:SetNormalTexture(icon);	
			button:Enable()
			button.spellID = spellID 
		else
			button.spellID = nil
			if currentPetType == "MOUNT" then
				button:SetDisabledTexture([[Interface\PetPaperDollFrame\UI-PetFrame-Slots-Mounts]])
			else
				button:SetDisabledTexture([[Interface\PetPaperDollFrame\UI-PetFrame-Slots-Companions]])
			end
			button:Disable();
		end

		modelID = tonumber(modelID)
		if selectedID and (index == selectedID) and modelID then
			button:SetChecked(true);		-- check only if it's the selected button and it has a model id
			AltoholicFramePetsNormal_PetName:SetText(name)
			AltoholicFramePetsNormal_ModelFrame:SetCreature(modelID);
		else
			button:SetChecked(false);
		end
	end
end


local function ScanHunter()
	-- this is a specific function to scan hunter pet talents
	--	DEFAULT_CHAT_FRAME:AddMessage("Scanning Pet " .. currentPetName)
end

function ns:OnChange()
	-- this event is triggered too often for our needs, some filtering is required  to avoid scanning pet data too often
	if arg1 ~= "player" then return end
	
	local name = UnitName("pet")
	if not name or name == UNKNOWN then	return end		-- if there's a usable pet name ..
	
	if not currentPetName then		-- not set ? initial scan
		currentPetName = name
		ScanHunter()
	elseif currentPetName ~= name then	-- already set, has it changed ? re-scan
		currentPetName = name
		ScanHunter()
	end
end

addon:RegisterEvent("UNIT_PET", addon.Pets.OnChange);
