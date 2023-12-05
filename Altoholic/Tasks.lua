-- Simple task manager
-- Written by : Thaoky, EU-Marécages de Zangar

local addonName = ...
local addon = _G[addonName]

addon.Tasks = {}

local ns = addon.Tasks

local taskList

function ns:Init()
	taskList = taskList or {}
	wipe(taskList)
end

function ns:OnUpdate(elapsed)
	for name, task in pairs(taskList) do
		task.delay = task.delay - elapsed
		if task.delay <= 0 then
			if task.func then
				if not task.func(task.owner, elapsed) then
					-- execute the task, if it doesn't return anything, delete it.
					-- if it does, keep it in the list, and execute it in every pass (set a delay of 0).
					-- if necessary, reschedule by updating the delay
					-- The function is responsible for returning the right value
					ns:Remove(name)
				end
			end
		end
	end
end

function ns:Add(name, delay, func, owner)
	if not taskList[name] then
		taskList[name] = {}
	end

	local p = taskList[name]
	p.delay = delay						-- time before executing the task
	p.func = func							-- function pointer to the task
	p.owner = owner						-- owner (table or frame)
end

function ns:Remove(name)
	local p = taskList[name]
	if p then
		wipe(p)
		taskList[name] = nil
	end
end

function ns:Get(name)
	return taskList[name]
end

function ns:Reschedule(name, delay)
	local p = taskList[name]
	if p then
		p.delay = delay						-- time before executing the task
	end	
end
