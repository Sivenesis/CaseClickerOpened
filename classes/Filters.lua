local filters = {}
filters.__index = filters
FiltersView = require("classes.FiltersView")
function filters:allowType(itemType)
	self.allowedTypes[itemType] = true
end
function filters:forbidType(itemType)
	self.allowedTypes[itemType] = nil
end
function filters:allowAllTypes()
	for _, itemType in pairs(ItemType) do
		self.allowedTypes[itemType] = true
	end
end
function filters:forbidAllTypes()
	self.allowedTypes = {}
end
function filters:isTypeAllowed(itemType)
	return self.allowedTypes[itemType]
end
function filters:setTypeDeselectable(itemType)
	self.notSelectableTypes[itemType] = true
	self.allowedTypes[itemType] = nil
end
function filters:setTypeSelectable(itemType)
	self.notSelectableTypes[itemType] = nil
	self.allowedTypes[itemType] = true
end
function filters:allowPattern(itemType)
	self.disabledPatterns[itemType] = nil
end
function filters:forbidPattern(itemType)
	self.disabledPatterns[itemType] = true
end
function filters:allowQuality(quality)
	self.disabledQualities[quality] = nil
end
function filters:forbidQuality(quality)
	self.disabledQualities[quality] = true
end
function filters:allowAllRarities()
	self.disabledRarities = {}
end
function filters:forbidAllRarities()
	for i = -1, 4 do
		self:forbidRarity(i)
	end
end
function filters:allowRarity(rarity)
	self.disabledRarities[rarity] = nil
end
function filters:forbidRarity(rarity)
	self.disabledRarities[rarity] = true
end
function filters:disableItem(item)
	self.disabledItems[item.id .. "." .. item.type] = true
end
function filters:enableItem(item)
	self.disabledItems[item.id .. "." .. item.type] = nil
end
function filters:reset()
	self.allowedTypes = {}
	self:allowAllTypes()
	self.disabledRarities = {}
	self.disabledItems = {}
	self.disabledQualities = {}
	self.disabledPatterns = {}
	self.notSelectableTypes = {}
	self.statTraksEnabled = true
	self.showKnives = true
	self.souvenirsEnabled = true
	self.normalItemsEnabled = true
end
function filters:isAllowed(item)
	if not self.allowedTypes[item.type] then
		return false
	end
	if self.disabledItems[item.id .. "." .. item.type] then
		return false
	end
	if item.rarity and self.disabledRarities[item.rarity] and (item.type ~= ItemType.skin or not Game.isKnife(item.id)) then
		return false
	end
	if item.quality and self.disabledQualities[item.quality] then
		return false
	end
	if not item.statTrak and not item.souvenir and not self.normalItemsEnabled then
		return false
	end
	if item.type == ItemType.skin then
		if item.statTrak and not self.statTraksEnabled and item.statTrakAvailable then
			return false
		end
		if item.statTrak and item.souvenirAvailable and not self.souvenirsEnabled then
			return false
		end
		if not self.showKnives and Game.isKnife(item.id) then
			return false
		end
		if item.pattern and self.disabledPatterns[item.pattern] then
			return false
		end
	end
	return true
end
function filters:applyFilters(otherFilters)
	self.allowedTypes = otherFilters.allowedTypes
	self.disabledRarities = otherFilters.disabledRarities
	self.disabledQualities = otherFilters.disabledQualities
	self.disabledItems = otherFilters.disabledItems
	self.disabledPatterns = otherFilters.disabledPatterns
	self.notSelectableTypes = otherFilters.notSelectableTypes
	self.statTraksEnabled = otherFilters.statTraksEnabled
	self.showKnives = otherFilters.showKnives
	self.souvenirsEnabled = otherFilters.souvenirsEnabled
	self.normalItemsEnabled = otherFilters.normalItemsEnabled
end
function filters:createTemporaryFilters()
	self.temporaryFilters = self.create(self)
end
function filters:show(sceneGroup, x, y, width, height, applyCallback, options)
	if not self.filtersView then
		self:createTemporaryFilters()
		self.filtersView = FiltersView.create(self.temporaryFilters, options)
	end
	self.filtersView:show(sceneGroup, x, y, width, height, function(filters, sort)
		if sort then
			EquipmentManager.sortItems()
		end
		self:applyFilters(filters)
		applyCallback()
	end)
	return true
end
function filters.create(otherFilters)
	local newFilters = {}
	setmetatable(newFilters, filters)
	newFilters:reset()
	if otherFilters then
		newFilters:applyFilters(otherFilters)
	end
	return newFilters
end
return filters
