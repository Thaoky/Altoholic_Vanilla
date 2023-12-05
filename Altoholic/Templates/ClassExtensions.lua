--[[ ** Class Extensions **
The purpose of class extensions is to add methods to any XML template.

This can technically be done in the XML file, as part of the XML template's OnLoad.
Like this:

self.Draw = function(self, arg1, arg2, arg3)
		... do whatever
	end

The problem is that if the object is instantiated multiple times, and it will since we're using a template, 
then the function will actually be created multiple times in memory too. A simple print proves it.

print(self.Draw)

.. this will show that the same function in each instance of the object actually has a different memory address.

Thus to stay proper, instantiate each function once here as a local function, then expose it so that widgets can reference it. 
A print with this technique proves we're using the single copy in memory of each function.

Naturally, it would also work if my local functions were all global.. but let's avoid polluting the global name space.

Usage for one method:
	self.<my method> = Altoholic:GetClassExtension(<class name>, <method name>)
 ex:
	self.SetClass = Altoholic:GetClassExtension("AltoClassIcon","SetClass")

Usage for all methods at once:
	Altoholic:SetClassExtensions(self, "AltoDropDownMenuButton")
	
--]]

local addonName = "Altoholic"
local addon = _G[addonName]

local classExtensions = {}

function addon:RegisterClassExtensions(class, methods)
	-- Sets the methods for a given type of objet, it's far from being true OOP, but works quite nice to add some methods to templates :)
	-- ScrollFrames.lua & .xml show a good example of the application
	classExtensions[class] = methods
end

function addon:GetClassExtension(class, method)
	return classExtensions[class][method]
end

-- apply class extensions to a frame
function addon:SetClassExtensions(frame, class)
	if not classExtensions[class] then return end
	
	for funcName, func in pairs(classExtensions[class]) do
		frame[funcName] = func
	end
end
