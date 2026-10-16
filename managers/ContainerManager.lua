ContainerManager = {}
local getTopOpenedThings = function(itemTable)
	local list = {}
	for id, item in ipairs(itemTable) do
		if item.opened and item.opened > 0 then
			table.insert(list, {
				id = id,
				opened = item.opened
			})
		end
	end
	table.sort(list, function(a, b)
		return a.opened > b.opened
	end)
	return list
end
function ContainerManager.getTopOpenedCollections()
	return getTopOpenedThings(Game.collections)
end
function ContainerManager.getTopOpenedCases()
	return getTopOpenedThings(Game.cases)
end
function ContainerManager.getUnlockedCasesIds()
	local list = {}
	for id, case in ipairs(Game.cases) do
		if case.unlocked then
			table.insert(list, id)
		end
	end
	return list
end
function ContainerManager.getUnlockedCapsuleIds()
	local list = {}
	for id, capsule in ipairs(Game.capsules) do
		if capsule.unlocked and not capsule.hasAutographs then
			table.insert(list, id)
		end
	end
	return list
end
return ContainerManager
