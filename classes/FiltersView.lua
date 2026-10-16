local filtersView = {}
filtersView.__index = filtersView
local checkboxPadding = 105
SortType = {
	name = 1,
	price = 2,
	quantity = 3
}
SortTypeNames = {
	[SortType.price] = "price",
	[SortType.name] = "name",
	[SortType.quantity] = "quantity"
}
function filtersView:updateSortText()
	local text = "Sorting by: "
	if EquipmentManager.sort.rarity then
		text = text .. "rarity & "
	end
	text = text .. SortTypeNames[EquipmentManager.sort.type]
	self.sortText.text = text
end
function filtersView:drawSortButtons()
	self.sortText = display.newText({
		parent = self.actualFilterView,
		x = self.actualFilterView.width / 2,
		y = self.lastY,
		text = "",
		font = Font.counterstrike,
		fontSize = 55,
		align = "center"
	})
	self.sortText.anchorX = 0.5
	self.sortText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(self.sortText)
	self.actualFilterView:insert(self.sortText)
	self.raritySortButton = Button.create(self.actualFilterView, self.actualFilterView.width / 2 - 360, self.sortText.y + self.sortText.height + 20, 720, 90, "By rarity", ButtonType.green, function()
		if self.raritySortButton:getType() == ButtonType.green then
			EquipmentManager.sort.rarity = false
			self.raritySortButton:setType(ButtonType.red)
		else
			EquipmentManager.sort.rarity = true
			self.raritySortButton:setType(ButtonType.green)
		end
		self.sortInventory = true
		self:updateSortText()
	end, {fontSize = 55})
	if EquipmentManager.sort.rarity then
		self.raritySortButton:setType(ButtonType.green)
	else
		self.raritySortButton:setType(ButtonType.red)
	end
	local buttonWidth = self.actualFilterView.width * 0.9 / #SortTypeNames
	for k, v in ipairs(SortTypeNames) do
		Button.create(self.actualFilterView, self.actualFilterView.width / 2 + 5 - #SortTypeNames * (buttonWidth + 10) / 2 + (k - 1) * (buttonWidth + 10), self.raritySortButton.y + self.raritySortButton.height + 10, buttonWidth, self.raritySortButton.height, v, ButtonType.default, function()
			EquipmentManager.sort.type = k
			self.sortInventory = true
			self:updateSortText()
		end, {fontSize = 55})
	end
	self:updateSortText()
	self.lastY = self.raritySortButton.y + self.raritySortButton.height * 2 + 20
end
function filtersView:addBackground()
	local background = display.newRect(self.filterGroup, self.x, self.y, self.width, self.height)
	background:setFillColor(unpack(Color.row))
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
end
function filtersView:addTextSlider()
	TextSlider.create(self.filterGroup, self.x + 5, self.y, self.width - 10, 100, {
		"Main Filters",
		"Qualities & patterns",
		"Cases",
		"Collections",
		"Capsules"
	}, function(text, id)
		actualOption = id
		for i = 1, #self.filterViews do
			self.filterViews[i].alpha = 0
		end
		self.filterViews[id].alpha = 1
	end, 70)
end
function filtersView:addFilterViews()
	self.filterViews = {}
	for i = 1, 5 do
		self.filterViews[i] = widget.newScrollView({
			x = self.x + 5,
			y = self.y + 100,
			width = self.width - 10,
			height = self.height - 220,
			horizontalScrollDisabled = true,
			scrollWidth = 5000,
			hideBackground = false,
			backgroundColor = Color.row
		})
		self.filterViews[i]:addEventListener("tap", function()
			return true
		end)
		self.filterGroup:insert(self.filterViews[i])
		self.filterViews[i].alpha = 0
	end
	self.filterViews[1].alpha = 1
end
function filtersView:drawLine()
	self.lastY = self.lastY + 25
	local line = GUI.drawHorizontalLine(self.actualFilterView, 0, self.lastY, self.actualFilterView.width)
	self.lastY = self.lastY + 25
	self.actualFilterView:insert(line)
end
function filtersView:drawStatTrakAndSouvenirFilters()
	table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
		x = self.width / 2 + 20,
		y = self.lastY + 55,
		size = 75,
		selected = true,
		callback = function(state)
			self.filters.statTraksEnabled = state == 1
		end,
		text = "StatTrak Items",
		fontSize = 55,
		textMargin = 100
	}))
	table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
		x = self.width / 2 + 20,
		y = self.lastY + 55 + checkboxPadding * 1,
		size = 75,
		selected = true,
		callback = function(state)
			self.filters.souvenirsEnabled = state == 1
		end,
		text = "Souvenir Items",
		fontSize = 55,
		textMargin = 100
	}))
	table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
		x = self.width / 2 + 20,
		y = self.lastY + 55 + checkboxPadding * 2,
		size = 75,
		selected = true,
		callback = function(state)
			self.filters.normalItemsEnabled = state == 1
		end,
		text = "Normal Items",
		fontSize = 55,
		textMargin = 100
	}))
end
function filtersView:drawItemTypeCheckboxes()
	local n = 0
	if 0 < #self.typeCheckboxes then
		for i = #self.typeCheckboxes, 1, -1 do
			self.typeCheckboxes[i]:removeSelf()
			table.remove(self.typeCheckboxes, i)
		end
	end
	for _, typeName in pairs(ItemTypeNames) do
		if not self.filters.notSelectableTypes[ItemType[typeName]] then
			n = n + 1
			local checkboxX = 20
			local checkboxY = self.lastY + 55 + (n - 1) * checkboxPadding
			table.insert(self.typeCheckboxes, Checkbox.create(self.actualFilterView, {
				x = checkboxX,
				y = checkboxY,
				size = 75,
				selected = self.filters:isTypeAllowed(ItemType[typeName]),
				callback = function(state)
					if state == 1 then
						self.filters:allowType(ItemType[typeName])
					else
						self.filters:forbidType(ItemType[typeName])
					end
				end,
				text = ("Show " .. ItemTypeNames[ItemType[typeName]] .. "s"):gsub("ss", "s"),
				fontSize = 55,
				textMargin = 100
			}))
		end
	end
	self.lastY = self.lastY + 3 * checkboxPadding
end
function filtersView:drawRarityCheckboxes()
	for i = -1, 4 do
		local addX = 0
		local addY = 0
		if 2 < i then
			addX = self.actualFilterView.width / 2
			addY = -4 * checkboxPadding
		end
		local color = {
			RarityColors[i][1] * 2,
			RarityColors[i][2] * 2,
			RarityColors[i][3] * 2
		}
		table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
			x = addX + 20,
			y = self.lastY + addY + 35 + (i + 1) * checkboxPadding,
			size = 75,
			selected = true,
			callback = function(state)
				if state == 1 then
					self.filters:allowRarity(i)
				else
					self.filters:forbidRarity(i)
				end
			end,
			text = RarityNames[i]:gsub("-", "@"),
			fontColor = color,
			fontSize = 55,
			textMargin = 100
		}))
	end
	table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
		x = self.actualFilterView.width / 2 + 20,
		y = self.lastY + 35 + 2 * checkboxPadding,
		size = 75,
		selected = true,
		callback = function(state)
			self.filters.showKnives = not self.filters.showKnives
		end,
		text = "Knives",
		fontSize = 55,
		fontColor = Color.gold,
		textMargin = 100
	}))
	self.lastY = self.lastY + math.ceil((#RarityNames + 2) / 2) * checkboxPadding
end
function filtersView:drawQualityCheckboxes()
	for i, name in ipairs(QualityNames) do
		local checkboxX = 20
		local checkboxY = self.lastY + 55 + (i - 1) * checkboxPadding
		if 3 < i then
			checkboxX = self.width / 2
			checkboxY = self.lastY + 55 + (i - 4) * checkboxPadding
		end
		local color = {
			1 - (i - 1) * 16 / 100,
			1 - (i - 1) * 16 / 100,
			1 - (i - 1) * 16 / 100
		}
		table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
			x = checkboxX,
			y = checkboxY,
			size = 75,
			selected = true,
			callback = function(state)
				if state == 1 then
					self.filters:allowQuality(i)
				else
					self.filters:forbidQuality(i)
				end
			end,
			text = name:gsub("-", "@"),
			fontColor = color,
			fontSize = 55,
			textMargin = 100
		}))
	end
	self.lastY = self.lastY + math.ceil(#QualityNames / 2) * checkboxPadding
end
function filtersView:drawPatternCheckboxes()
	for i, pattern in ipairs(PatternInfo) do
		local checkboxX = 20
		local checkboxY = self.lastY + 55 + (i - 1) * checkboxPadding
		if i > tableLength(PatternInfo) / 2 then
			checkboxX = self.width / 2
			checkboxY = self.lastY + 55 + (i - tableLength(PatternInfo) / 2 - 1) * checkboxPadding
		end
		table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
			x = checkboxX,
			y = checkboxY,
			size = 75,
			selected = true,
			callback = function(state)
				if state == 1 then
					self.filters:allowPattern(i)
				else
					self.filters:forbidPattern(i)
				end
			end,
			text = pattern.name,
			fontColor = color,
			fontSize = 55,
			textMargin = 100
		}))
	end
	self.lastY = self.lastY + math.ceil(tableLength(PatternInfo) / 2) * checkboxPadding + 20
end
function filtersView:drawBottomButtons()
	Button.create(self.filterGroup, self.x + 10, self.y + self.height - 110, self.width * 0.4 - 10, 100, "Cancel", ButtonType.default, function()
		self.filterGroup.alpha = 0
		for i = 1, #self.checkboxes do
			self.checkboxes[i]:reset()
		end
		return true
	end, {fontSize = 55})
	Button.create(self.filterGroup, self.x + self.width * 0.4 + 10, self.y + self.height - 110, self.width * 0.6 - 20, 100, "Apply", ButtonType.green, function()
		self.filterGroup.alpha = 0
		self.applyCallback(self.filters, self.sortInventory)
		return true
	end, {fontSize = 55})
end
function filtersView:drawResetButton()
	Button.create(self.actualFilterView, self.actualFilterView.width / 2 - 300, self.lastY, 600, 90, "Reset Filters", ButtonType.red, function()
		for i = 1, #self.checkboxes do
			self.checkboxes[i]:reset()
		end
		for i = 1, #self.typeCheckboxes do
			self.typeCheckboxes[i]:reset()
		end
	end, {fontSize = 55})
	self.lastY = self.lastY + 90
end
function filtersView:drawCaseCheckboxes()
	local caseCheckboxes = {}
	Button.create(self.actualFilterView, 10, self.lastY, self.width * 0.5 - 10, 80, "Select All", ButtonType.default, function()
		for i = 1, #caseCheckboxes do
			caseCheckboxes[i]:select()
		end
	end, {fontSize = 45})
	Button.create(self.actualFilterView, self.width / 2 + 10, self.lastY, self.width * 0.5 - 20, 80, "Deselect All", ButtonType.default, function()
		for i = 1, #caseCheckboxes do
			caseCheckboxes[i]:deselect()
		end
	end, {fontSize = 45})
	self.lastY = self.lastY + 80
	self:drawLine()
	local addX = 0
	local addY = 0
	for i, case in ipairs(Game.cases) do
		i = i - 1
		if i >= math.ceil(#Game.cases / 2) then
			addX = self.width / 2
			addY = -(checkboxPadding * math.ceil(#Game.cases / 2))
		end
		local nameString = case.name
		if 18 <= #nameString then
			nameString = nameString:sub(0, 15) .. "..."
		end
		table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
			x = addX + 20,
			y = addY + self.lastY + 35 + i * checkboxPadding,
			size = 75,
			selected = true,
			callback = function(state)
				for _, skin in ipairs(case.skins) do
					if state == 1 then
						self.filters:enableItem({
							id = skin,
							type = ItemType.skin
						})
					else
						self.filters:disableItem({
							id = skin,
							type = ItemType.skin
						})
					end
				end
				if case.contractSkins then
					for _, skin in ipairs(case.contractSkins) do
						if state == 1 then
							self.filters:enableItem({
								id = skin,
								type = ItemType.skin
							})
						else
							self.filters:disableItem({
								id = skin,
								type = ItemType.skin
							})
						end
					end
				end
				if case.otherSkins then
					for _, skin in ipairs(case.otherSkins) do
						if state == 1 then
							self.filters:enableItem({
								id = skin,
								type = ItemType.skin
							})
						else
							self.filters:disableItem({
								id = skin,
								type = ItemType.skin
							})
						end
					end
				end
			end,
			text = nameString,
			fontSize = 45,
			textMargin = 100
		}))
		table.insert(caseCheckboxes, self.checkboxes[#self.checkboxes])
	end
	self.lastY = self.lastY + checkboxPadding * math.ceil(#Game.cases / 2)
end
function filtersView:drawCollectionCheckboxes()
	local collectionCheckboxes = {}
	Button.create(self.actualFilterView, 10, self.lastY, self.width * 0.5 - 10, 80, "Select All", ButtonType.default, function()
		for i = 1, #collectionCheckboxes do
			collectionCheckboxes[i]:select()
		end
	end, {fontSize = 45})
	Button.create(self.actualFilterView, self.width / 2 + 10, self.lastY, self.width * 0.5 - 20, 80, "Deselect All", ButtonType.default, function()
		for i = 1, #collectionCheckboxes do
			collectionCheckboxes[i]:deselect()
		end
	end, {fontSize = 45})
	self.lastY = self.lastY + 80
	self:drawLine()
	for i, collection in ipairs(Game.collections) do
		local checkboxX = 20
		local checkboxY = self.lastY + 25 + (i - 1) * checkboxPadding
		if i >= math.ceil(#Game.souvenirs / 2) then
			checkboxX = self.width / 2
			checkboxY = self.lastY + 25 + (i - math.ceil(#Game.souvenirs / 2)) * checkboxPadding
		end
		local nameString = collection.name
		nameString = nameString:gsub("The ", "")
		nameString = nameString:gsub(" Collection", "")
		if 18 <= #nameString then
			nameString = nameString:sub(0, 15) .. "..."
		end
		table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
			x = checkboxX,
			y = checkboxY,
			size = 75,
			selected = true,
			callback = function(state)
				for _, skin in ipairs(collection.skins) do
					if state == 1 then
						self.filters:enableItem({
							id = skin,
							type = ItemType.skin
						})
					else
						self.filters:disableItem({
							id = skin,
							type = ItemType.skin
						})
					end
				end
			end,
			text = nameString,
			fontSize = 45,
			textMargin = 100
		}))
		table.insert(collectionCheckboxes, self.checkboxes[#self.checkboxes])
	end
	self.lastY = self.lastY + checkboxPadding * math.ceil(#Game.souvenirs / 2)
end
function filtersView:drawCapsuleCheckboxes()
	local capsuleCheckboxes = {}
	Button.create(self.actualFilterView, 10, self.lastY, self.width * 0.5 - 10, 80, "Select All", ButtonType.default, function()
		for i = 1, #capsuleCheckboxes do
			capsuleCheckboxes[i]:select()
		end
	end, {fontSize = 45})
	Button.create(self.actualFilterView, self.width / 2 + 10, self.lastY, self.width * 0.5 - 20, 80, "Deselect All", ButtonType.default, function()
		for i = 1, #capsuleCheckboxes do
			capsuleCheckboxes[i]:deselect()
		end
	end, {fontSize = 45})
	self.lastY = self.lastY + 80
	self:drawLine()
	local sortedCapsules = {}
	for _, capsule in ipairs(Game.capsules) do
		local categoryName = "Other capsules"
		if capsule.subName then
			categoryName = capsule.subName
		end
		if not sortedCapsules[categoryName] then
			sortedCapsules[categoryName] = {}
		end
		table.insert(sortedCapsules[categoryName], capsule)
	end
	local yAdd = false
	local firstCategory = true
	for category, capsules in pairs(sortedCapsules) do
		if firstCategory then
			firstCategory = false
		else
			self.lastY = self.lastY + 100
			if yAdd then
				self.lastY = self.lastY - checkboxPadding
			end
		end
		local leftColumn = true
		local categoryText = display.newText({
			parent = self.actualFilterView,
			x = 20,
			y = self.lastY,
			text = category,
			font = Font.counterstrike,
			fontSize = 65,
			align = "center"
		})
		categoryText.anchorX = 0
		categoryText.anchorY = 0
		FontOffset.setOffset(categoryText)
		self.actualFilterView:insert(categoryText)
		self.lastY = self.lastY + 120
		yAdd = false
		for i, capsule in ipairs(capsules) do
			yAdd = false
			if leftColumn then
				addX = 0
				leftColumn = false
			else
				addX = self.actualFilterView.width / 2
				leftColumn = true
			end
			local nameString = capsule.name
			nameString = nameString:gsub("Community Capsule", "Community")
			nameString = nameString:gsub("Foil", "F")
			nameString = nameString:gsub("Holo", "H")
			if 19 <= #nameString then
				nameString = nameString:sub(0, 16) .. "..."
			end
			table.insert(self.checkboxes, Checkbox.create(self.actualFilterView, {
				x = addX + 20,
				y = self.lastY,
				size = 75,
				selected = true,
				callback = function(state)
					for _, sticker in ipairs(capsule.stickers) do
						if state == 1 then
							self.filters:enableItem({
								id = sticker,
								type = ItemType.sticker
							})
						else
							self.filters:disableItem({
								id = sticker,
								type = ItemType.sticker
							})
						end
					end
				end,
				text = nameString,
				fontSize = 45,
				textMargin = 100
			}))
			table.insert(capsuleCheckboxes, self.checkboxes[#self.checkboxes])
			if leftColumn then
				self.lastY = self.lastY + checkboxPadding
				yAdd = true
			end
		end
	end
	self.lastY = self.lastY
end
function filtersView:show(sceneGroup, x, y, width, height, applyCallback)
	if self.filterGroup then
		self.actualFilterView = self.filterViews[1]
		self.lastY = self.itemTypeCheckboxesY
		self:drawItemTypeCheckboxes()
		self.filterGroup.alpha = 1
		return true
	end
	self.filterGroup = display.newGroup()
	sceneGroup:insert(self.filterGroup)
	self.sceneGroup = sceneGroup
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.applyCallback = applyCallback
	self:addBackground()
	self:addTextSlider()
	self:addFilterViews()
	self.actualFilterView = self.filterViews[1]
	self.lastY = 25
	if self.options.sortButtons then
		self:drawSortButtons()
		self:drawLine()
	end
	self.itemTypeCheckboxesY = self.lastY
	self:drawStatTrakAndSouvenirFilters()
	self:drawItemTypeCheckboxes()
	self:drawLine()
	self:drawResetButton()
	self:drawLine()
	self.actualFilterView = self.filterViews[2]
	self.lastY = 25
	self:drawQualityCheckboxes()
	self:drawLine()
	self:drawRarityCheckboxes()
	self:drawLine()
	self:drawPatternCheckboxes()
	self:drawLine()
	self.actualFilterView = self.filterViews[3]
	self.lastY = 25
	self:drawCaseCheckboxes()
	self:drawLine()
	self.actualFilterView = self.filterViews[4]
	self.lastY = 25
	self:drawCollectionCheckboxes()
	self:drawLine()
	self.actualFilterView = self.filterViews[5]
	self.lastY = 25
	self:drawCapsuleCheckboxes()
	self:drawLine()
	self:drawBottomButtons()
	return true
end
function filtersView:hide()
	self.filterGroup.alpha = 0
end
function filtersView.create(filters, options)
	local newFiltersView = {}
	setmetatable(newFiltersView, filtersView)
	newFiltersView.filters = filters
	newFiltersView.checkboxes = {}
	newFiltersView.typeCheckboxes = {}
	newFiltersView.options = options or {}
	return newFiltersView
end
return filtersView
