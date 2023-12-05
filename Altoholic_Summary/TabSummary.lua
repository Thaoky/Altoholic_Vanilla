local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

addon.Tabs.Summary = {}

local ns = addon.Tabs.Summary		-- ns = namespace

function ns:AccountSharingButton_OnEnter(self)
	AltoTooltip:SetOwner(self, "ANCHOR_RIGHT")
	AltoTooltip:ClearLines()
	AltoTooltip:SetText(L["Account Sharing Request"])
	AltoTooltip:AddLine(L["Click this button to ask a player\nto share his entire Altoholic Database\nand add it to your own"],1,1,1)
	AltoTooltip:Show()
end

function ns:AccountSharingButton_OnClick()
	if addon:GetOption("UI.AccountSharing.IsEnabled") == 0 then
		addon:Print(L["Both parties must enable account sharing\nbefore using this feature (see options)"])
		return
	end
	addon:ToggleUI()
	
	if AltoAccountSharing_SendButton.requestMode then
		addon.Comm.Sharing:SetMode(2)
	else
		addon.Comm.Sharing:SetMode(1)
	end
	AltoAccountSharing:Show()
end
