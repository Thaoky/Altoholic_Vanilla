local addonName = "Altoholic"
local addon = _G[addonName]

addon:Controller("AltoholicUI.SpellButton", {
	EnableIcon = function(frame)
		-- frame:Enable()
		frame.Icon:SetDesaturated(false)
	end,
	DisableIcon = function(frame)
		-- frame:Disable()
		frame.Icon:SetDesaturated(true)
	end,
	SetSpell = function(frame, spellID, rank)
		if not spellID then return end

		local name, _, icon = GetSpellInfo(spellID)
		print()
		if not name or not icon then return end	-- exit on invalid data
		
		frame.spellID = spellID
		frame.SpellName:SetText(name)
				
		frame.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		frame.SubSpellName:SetText(rank or "")
		frame.SubSpellName:SetTextColor(0.50, 0.25, 0)
		frame.Icon:SetDesaturated(false)
		frame.Icon:SetVertexColor(1.0, 1.0, 1.0)
		
		frame.Icon:SetWidth(30)
		frame.Icon:SetHeight(30)
		frame.Icon:SetAllPoints(frame)
		frame.Icon:SetTexture(icon)
		
		frame.Icon:Show()
		frame.SpellName:Show()
		frame.SubSpellName:Show()
	end,
})
