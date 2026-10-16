local EquipmentManager = {
	sort = {rarity = true, type = 2}
}
function EquipmentManager.save(saveTable)
	saveTable.sort = EquipmentManager.sort
end
function EquipmentManager.load(loadTable)
	if not loadTable.sort then
		return true
	end
	EquipmentManager.sort = loadTable.sort
end
function EquipmentManager.validateName(name)
	if 25 < #name then
		return false, "The name that you have entered is too long."
	end
	if #name < 3 then
		return false, "The name needs to have at least 3 characters."
	end
	if #name:match("[A-Za-z0-9-. ]+") ~= #name then
		return false, "Name contains invalid characters."
	end
	return true, ""
end
function EquipmentManager.validateCategoryName(name)
	if 20 < #name then
		return false, "The name that you have entered is too long."
	end
	if #name < 1 then
		return false, "The name needs to have at least 1 character."
	end
	if #name:match("[A-Za-z0-9!-. ]+") ~= #name then
		return false, "Name contains invalid characters."
	end
	return true, ""
end
function EquipmentManager.removeItems(itemIds)
	table.sort(itemIds)
	for i = #itemIds, 1, -1 do
		EquipmentManager.removeItem(itemIds[i])
	end
end
function EquipmentManager.removeItem(itemId)
	local itemPrice = Game.getPrice(Game.equipment[itemId])
	StatisticManager.addStatistic("skinsWorth", -itemPrice)
	table.remove(Game.equipment, itemId)
end
function EquipmentManager.returnItems(items, highlight)
	for _, item in ipairs(items) do
		if item.type == Item.skin then
			Game.addItem(Game.skins[item.id], false, item.statTrak, false, {
				pattern = item.pattern,
				stickers = item.stickers,
				quality = item.quality,
				highlight = highlight,
				disableAchievements = true,
				disableMissions = true
			})
		elseif item.type == Item.glove then
			Game.addItem(Game.gloves[item.id], false, false, false, {
				quality = item.quality,
				highlight = highlight,
				disableAchievements = true,
				disableMissions = true
			})
		else
			Game.addItem(Game.stickers[item.id], false, item.statTrak, false, {
				highlight = highlight,
				disableAchievements = true,
				disableMissions = true
			})
		end
	end
	Game.save()
end
function EquipmentManager.getItemWithPrice(minPrice, maxPrice)
	maxPrice = maxPrice or 999999
	if minPrice > maxPrice then
		maxPrice = minPrice * 2
	end
	local i = 0
	while true do
		i = i + 1
		if i == 600 then
			minPrice = minPrice * 0.9
		elseif i == 2500 then
			minPrice = minPrice * 0.8
		end
		local item = {}
		local randomResult = math.random(1, 100)
		if randomResult <= 1 then
			local glove = choose(Game.gloves)
			item.type = Item.glove
			item.id = glove.id
			item.quality = QualityManager.getRandomQuality(glove)
		elseif randomResult <= 20 then
			item.type = Item.sticker
			item.id = Game.getRandomSticker().id
		else
			item.type = Item.skin
			local rarity = math.random(1, 4)
			local skin = Game.getRandomSkinByRarity(rarity)
			item.id = skin.id
			item.quality = QualityManager.getRandomQuality(skin)
			if math.random(1, 10) <= 3 and (Game.skins[item.id].statTrakAvailable or Game.skins[item.id].souvenirAvailable) then
				item.statTrak = true
			else
				item.statTrak = false
			end
			if Game.skins[item.id].patterns then
				while not item.pattern do
					local selectedPattern = math.random(1, #Game.skins[item.id].patterns)
					local patternId = Game.skins[item.id].patterns[selectedPattern]
					local patternInfo = PatternInfo[patternId]
					if math.random(1, 100) <= patternInfo.chance then
						item.pattern = selectedPattern
					end
				end
			end
		end
		local itemPrice = Game.getItemPrice(item)
		if minPrice <= itemPrice and maxPrice >= itemPrice then
			return item, itemPrice
		end
	end
end
function EquipmentManager.compareItems(item1, item2)
	return item1.id == item2.id and item1.type == item2.type and item1.statTrak == item2.statTrak and item1.n == item2.n and item1.quality == item2.quality
end
function EquipmentManager.shallowCompareItems(item1, item2)
	return item1.id == item2.id and item1.type == item2.type
end
function EquipmentManager.itemToString(item, shallow)
	local ret = item.id .. "_" .. item.type
	if shallow then
		return ret
	end
	if item.quality then
		ret = ret .. "_" .. item.quality
	end
	if item.statTrak then
		ret = ret .. "_s"
	end
	if item.n then
		ret = ret .. "_" .. item.n
	end
	if item.locked then
		ret = ret .. "_l"
	end
	if item.stickers then
		for i = 1, #item.stickers do
			ret = ret .. "_s" .. i .. item.stickers[i]
		end
	end
	if item.pattern then
		ret = ret .. "_p" .. item.pattern
	end
	return ret
end
function EquipmentManager.printItem(item)
	print("ID:" .. item.id)
	local type = "skin"
	if item.type == Item.sticker then
		type = "sticker"
	end
	print("Type: " .. type)
	local name = ""
	if item.type == Item.skin then
		name = Game.skins[item.id].name
	else
		name = Game.stickers[item.id].name
	end
	print("Name: " .. name)
	if item.quality then
		print("Quality: " .. QualityNames[item.quality])
	end
	if item.n then
		print("Nametag: " .. item.n)
	end
end
function EquipmentManager.getItemsWorth(worth)
	local leftToReturn = worth
	local itemTable = {}
	while 0.1 < leftToReturn do
		local minimumPrice = math.max(math.min(100, leftToReturn / 3), 0.05)
		local item, price = EquipmentManager.getItemWithPrice(minimumPrice, leftToReturn)
		leftToReturn = leftToReturn - price
		table.insert(itemTable, item)
	end
	return itemTable
end
function EquipmentManager.queryItemPosition(item)
	local itemName = Game.getItemName(item)
	local itemPrice = Game.getItemPrice(item)
	local itemRarity = Game.getItemRarity(item)
	local currentItemStr = EquipmentManager.itemToString(item)
	local index = 1
	for i = 1, #Game.equipment do
		if EquipmentManager.sort.rarity then
			local eqRarity = Game.getItemRarity(Game.equipment[i])
			if itemRarity > eqRarity then
				break
			end
			if itemRarity == eqRarity then
				if EquipmentManager.sort.type == 1 then
					if itemName > Game.getItemName(Game.equipment[i]) then
						index = index + 1
					else
						break
					end
				elseif EquipmentManager.sort.type == 2 then
					if itemPrice < Game.getItemPrice(Game.equipment[i]) then
						index = index + 1
					else
						break
					end
				else
					local itemStr = EquipmentManager.itemToString(Game.equipment[i])
					if itemStr == currentItemStr then
						break
					else
						index = index + 1
					end
				end
			else
				index = index + 1
			end
		elseif EquipmentManager.sort.type == 1 then
			if itemName > Game.getItemName(Game.equipment[i]) then
				index = index + 1
			else
				break
			end
		elseif EquipmentManager.sort.type == 2 then
			if itemPrice < Game.getItemPrice(Game.equipment[i]) then
				index = index + 1
			else
				break
			end
		else
			local itemStr = EquipmentManager.itemToString(Game.equipment[i])
			if itemStr == currentItemStr then
				break
			else
				index = index + 1
			end
		end
	end
	return index
end
function EquipmentManager.sortItems()
	if EquipmentManager.sort.type == 1 then
		table.sort(Game.equipment, function(a, b)
			return Game.getItemName(a) < Game.getItemName(b)
		end)
	elseif EquipmentManager.sort.type == 2 then
		table.sort(Game.equipment, function(a, b)
			return Game.getItemPrice(a) > Game.getItemPrice(b)
		end)
	elseif EquipmentManager.sort.type == 3 then
		local itemCounts = {}
		for _, item in ipairs(Game.equipment) do
			local itemStr = EquipmentManager.itemToString(item)
			if itemCounts[itemStr] then
				itemCounts[itemStr] = itemCounts[itemStr] + 1
			else
				itemCounts[itemStr] = 1
			end
		end
		for _, item in ipairs(Game.equipment) do
			local itemStr = EquipmentManager.itemToString(item)
			item.quantity = itemCounts[itemStr]
		end
		table.sort(Game.equipment, function(a, b)
			return a.quantity > b.quantity
		end)
		for _, item in ipairs(Game.equipment) do
			item.quantity = nil
		end
	end
	if EquipmentManager.sort.rarity then
		local tmp = Game.equipment
		Game.equipment = {}
		for desiredRarity = 5, -1, -1 do
			for i = 1, #tmp do
				local rarity
				if tmp[i].type == Item.skin then
					rarity = Game.skins[tmp[i].id].rarity
				elseif tmp[i].type == Item.sticker then
					rarity = Game.stickers[tmp[i].id].rarity
				elseif tmp[i].type == Item.glove then
					rarity = Game.gloves[tmp[i].id].rarity
				end
				if rarity == desiredRarity then
					table.insert(Game.equipment, tmp[i])
				end
			end
		end
	end
end
return EquipmentManager
