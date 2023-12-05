local addonName = "Altoholic"
local addon = _G[addonName]

local lastFrame

addon:Controller("AltoholicUI.TabGridsMenuIcon", {
	StartAutoCastShine = function(frame)
		frame.Shine:ShineStart()
		lastFrame = frame
	end,
	StopAutoCastShine = function(frame)
		-- stop auto-cast shine on the last frame that was clicked
		if lastFrame then
			lastFrame.Shine:ShineStop()
		end
	end,
	EnableIcon = function(frame)
		frame:Enable()
		frame.Icon:SetDesaturated(false)
	end,
	DisableIcon = function(frame)
		frame:Disable()
		frame.Icon:SetDesaturated(true)
	end,
})
