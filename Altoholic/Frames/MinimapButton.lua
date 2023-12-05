local addonName = ...
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local OPTION_ICON_ANGLE = "UI.Minimap.IconAngle"
local OPTION_ICON_RADIUS = "UI.Minimap.IconRadius"

local function GetIconAngle()
	local xPos, yPos = GetCursorPosition()

	xPos = Minimap:GetLeft() - xPos/UIParent:GetScale() + 70 
	yPos = yPos/UIParent:GetScale() - Minimap:GetBottom() - 70 

	local iconAngle = math.deg(math.atan2(yPos, xPos))
	if iconAngle < 0 then
		iconAngle = iconAngle + 360
	end
	
	return iconAngle
end

addon:Controller("AltoholicUI.MinimapButton", {
	OnBind = function(frame)
		frame.tooltip = format("%s\n\n%s%s\n%s%s", addonName,	
			colors.white, L["Left-click to |cFF00FF00open"], 
			colors.white, L["Right-click to |cFF00FF00drag"])
	end,
	Move = function(frame)
		local angle = addon:GetOption(OPTION_ICON_ANGLE)
		local radius = addon:GetOption(OPTION_ICON_RADIUS)
		
		frame:SetPoint( "TOPLEFT", "Minimap", "TOPLEFT", 54 - (radius * cos(angle)), (radius * sin(angle)) - 55 )
	end,
	Update = function(frame)
		if frame.isMoving then
			local iconAngle = GetIconAngle()
			addon:SetOption(OPTION_ICON_ANGLE, iconAngle)
			
			-- this line should not be here, but stays temporarily
			AltoholicGeneralOptions_SliderAngle:SetValue(iconAngle)
		end
	end,
	Button_OnClick = function(frame, button)
		if button == "LeftButton" then
			addon:ToggleUI()
		end
	end,
})
