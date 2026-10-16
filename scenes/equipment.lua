local scene = composer.newScene()
local TextSlider = require("gui.textslider")
local VerticalSlider = require("gui.verticalslider")
local Filters = require("classes.Filters")
local ItemSearch = require("classes.ItemSearch")
local box, searchButton
local equipmentFilters = Filters.create()
local previousFilters
if Game.others.onceAction4 == false then
	for i = 1, #Game.equipment do
		Game.equipment[i].equipmentId = nil
		if not Game.equipment[i].hl then
			Game.equipment[i].hl = Game.equipment[i].highlight == true or nil
		end
		Game.equipment[i].highlight = nil
	end
	Game.others.onceAction4 = true
	Game.save()
end
local contract = {
	selecting = false,
	items = {},
	cancelButton,
	acceptButton,
	counterText,
	signButton
}
local filterView, raritySortButton, skinTable, skinCounter, slider
local showingNotLocked = true
local useFiltersInContracts = true
local equipmentIds
local skinsPerRow = 3
local justDeselected
local displayedItems = {}
local selectionMode = false
local topButtons = {}
local selectionButtons = {}
local selectedItems = {}
local sortText
local qualitySettings = {}
local showKnives = true
local resortTable = false
local statTrakSetting = false
local noStatTrakSetting = false
local souvenirSetting = false
local noSouvenirSetting = false
local typeSettings = {
	Item.skin,
	Item.sticker,
	Item.glove,
	Item.other
}
local sortType = 1
local actualCategory = 1
local lastYPosition = 0
local maxY = 0
local itemCounts = {}
local actionTimer = system.getTimer()
local function updateCounter(displayedSkins)
	skinCounter.text = Lang.equipment.total .. ": " .. displayedSkins .. " / " .. #Game.equipment .. " " .. Lang.equipment.items
end
local function updateSortText()
	local text = "Sorting by: "
	if EquipmentManager.sort.rarity then
		text = text .. "rarity & "
	end
	if EquipmentManager.sort.type == 1 then
		text = text .. "name"
	else
		text = text .. "price"
	end
	sortText.text = text
end
local function isFiltered(equipmentItem)
	local item = {}
	for k, v in pairs(equipmentItem) do
		item[k] = v
	end
	if equipmentItem.type == Item.skin then
		local tmpItem = Game.skins[equipmentItem.id]
		item.rarity = tmpItem.rarity
		item.name = tmpItem.name
		item.statTrakAvailable = tmpItem.statTrakAvailable
		item.souvenirAvailable = tmpItem.souvenirAvailable
		item.topTier = tmpItem.topTier
		if item.statTrak and not item.statTrakAvailable and not item.souvenirAvailable then
			item.statTrak = false
		end
	elseif equipmentItem.type == Item.glove then
		local tmpItem = Game.gloves[equipmentItem.id]
		item.rarity = tmpItem.rarity
		item.name = tmpItem.name
	else
		local tmpItem = Game.stickers[equipmentItem.id]
		item.rarity = tmpItem.rarity
		item.name = tmpItem.name
	end
	if Game.settings.equipmentCategories == true then
		if not item.ec and actualCategory ~= 1 then
			return true
		end
		local category = Game.equipmentCategories[actualCategory]
		if item.locked and not category.locked then
			return true
		end
		if item.ec and item.ec ~= actualCategory then
			return true
		end
	else
		if showingNotLocked == false and not item.locked then
			return true
		end
		if showingNotLocked and item.locked then
			return true
		end
	end
	if contract.selecting and item.topTier then
		return true
	end
	if (equipmentFilters.filtersView or contract.selecting) and not equipmentFilters:isAllowed(item) then
		return true
	end
	if itemSearch.searchString then
		local filter = true
		if item.n and itemSearch:isAllowed(item.n) then
			filter = false
		end
		if itemSearch:isAllowed(item.name:gsub(" |", "")) then
			filter = false
		end
		if item.stickers then
			for _, sticker in ipairs(item.stickers) do
				local name = Game.getItemName({
					id = sticker,
					type = Item.sticker
				})
				if itemSearch:isAllowed(name) then
					filter = false
				end
			end
		end
		if filter then
			return true
		end
	end
	return false
end
local function insertItems()
	maxY = 0
	displayedItems = {}
	equipmentIds = {}
	local serializedItemsTable = {}
	if Game.settings.stackEquipmentItems then
		itemCounts = {}
	end
	local eq = {}
	for i = 1, #Game.equipment do
		if not isFiltered(Game.equipment[i]) then
			if Game.settings.stackEquipmentItems and not contract.selecting and not selectionMode then
				local addItem = true
				local itemStr = EquipmentManager.itemToString(Game.equipment[i])
				if 1 < i and serializedItemsTable[itemStr] then
					addItem = false
					itemCounts[serializedItemsTable[itemStr]] = itemCounts[serializedItemsTable[itemStr]] + 1
				end
				if addItem then
					serializedItemsTable[itemStr] = i
					itemCounts[i] = 1
					table.insert(eq, Game.equipment[i])
					equipmentIds[#equipmentIds + 1] = i
				end
				table.insert(displayedItems, i)
			else
				table.insert(eq, Game.equipment[i])
				equipmentIds[#equipmentIds + 1] = i
				table.insert(displayedItems, i)
			end
		end
	end
	if #eq == 0 then
		skinTable:insertRow({
			params = {},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 250
		})
		updateCounter(0)
		if slider then
			slider:setTableView(skinTable, skinTable.height)
			slider:scrollBar(0)
		end
		return
	end
	for i = 0, math.ceil(#eq / skinsPerRow) - 1 do
		highlights = {}
		local params = {}
		local highlights = {}
		for j = 1, skinsPerRow do
			if not eq[i * skinsPerRow + j] then
				break
			end
			params[j] = eq[i * skinsPerRow + j]
			highlights[j] = eq[i * skinsPerRow + j].hl
		end
		skinTable:insertRow({
			params = {items = params, highlights = highlights},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 466 * Game.guiScale
		})
		maxY = maxY + 466 * Game.guiScale
	end
	updateCounter(#displayedItems)
	if slider then
		slider:scrollBar(0)
		local tableMaxScroll = -(skinTable:getNumRows() * 466 * Game.guiScale) + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
	end
end
local function updateButtons()
	for _, button in pairs(topButtons) do
		button:hide()
	end
	for _, button in pairs(selectionButtons) do
		button:hide()
	end
	if selectionMode then
		for _, button in pairs(selectionButtons) do
			button:show()
		end
		if tableLength(selectedItems) > 0 then
			selectionButtons.move:setType(ButtonType.green)
			selectionButtons.sell:setType(ButtonType.green)
		else
			selectionButtons.move:setType(ButtonType.gray)
			selectionButtons.sell:setType(ButtonType.gray)
		end
		if not Game.settings.equipmentCategories then
			if showingNotLocked then
				selectionButtons.move:setText("Lock")
			else
				selectionButtons.move:setText("Unlock")
			end
		end
	elseif not contract.selecting then
		for _, button in pairs(topButtons) do
			button:show()
		end
		if not Game.settings.equipmentCategories then
			if not topButtons.showNotLockedButton then
				scene:drawShowLockedButtons()
			end
			if showingNotLocked then
				topButtons.showNotLockedButton:hide()
			else
				topButtons.showLockedButton:hide()
			end
		end
	end
end
local function scrollToLastY()
	lastYPosition = skinTable:getContentPosition()
	skinTable:deleteAllRows()
	insertItems()
	if lastYPosition < -(maxY - skinTable.height) then
		lastYPosition = -(maxY - skinTable.height)
		if 0 < lastYPosition then
			lastYPosition = 0
		end
	end
	actionTimer = system.getTimer()
	skinTable:scrollToY({y = lastYPosition, time = 0})
	if slider then
		slider:scrollListener(nil, lastYPosition)
	end
end
local function showLockedSkins()
	showingNotLocked = false
	topButtons.showNotLockedButton:show()
	topButtons.showLockedButton:hide()
	skinTable:deleteAllRows()
	insertItems()
end
local function showNotLockedSkins()
	showingNotLocked = true
	topButtons.showNotLockedButton:hide()
	topButtons.showLockedButton:show()
	skinTable:deleteAllRows()
	insertItems()
end
local function refreshSkinTable()
	skinTable:deleteAllRows()
	insertItems()
	skinTable:scrollToY({y = 0})
	if slider then
		slider:scrollBar(0)
	end
end
local function resetContractFilters()
	previousFilters = Filters.create(equipmentFilters)
	equipmentFilters:allowAllRarities()
	equipmentFilters:forbidRarity(Rarity.red)
	equipmentFilters.showKnives = false
	equipmentFilters:forbidAllTypes()
	equipmentFilters:allowType(Item.skin)
	equipmentFilters.statTraksEnabled = true
	equipmentFilters.souvenirsEnabled = false
	equipmentFilters.normalItemsEnabled = true
	updateButtons()
	refreshSkinTable()
end
local function cancelContractSigning()
	if contract.counterText.alpha == 0 and contract.acceptButton.alpha == 0 then
		return
	end
	contract.counterText.alpha = 0
	contract.cancelButton.alpha = 0
	contract.acceptButton.alpha = 0
	contract.selecting = false
	contract.items = {}
	skinTable.y = box.y + 120
	if slider then
		slider:moveY(120)
	end
	equipmentFilters:applyFilters(previousFilters)
	refreshSkinTable()
	updateButtons()
	contract.counterText.text = #contract.items .. " " .. Lang.equipment.of10needed
end
local function openSelectionMode()
	selectionMode = true
	selectedItems = {}
	updateButtons()
	scrollToLastY()
end
local function closeSelectionMode()
	selectionMode = false
	selectedItems = {}
	updateButtons()
	scrollToLastY()
end
local function onRowRender(event)
	local row = event.row
	local params = event.row.params
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	local items = params.items
	if not params.items then
		local text = Lang.equipment.empty
		if 0 < #Game.equipment then
			text = Lang.equipment.noitems
		end
		local text = display.newText({
			parent = row,
			x = getCenterX(row),
			y = 125,
			text = text,
			font = Font.counterstrike,
			fontSize = 68 * Game.guiScale,
			align = "center"
		})
		text.anchorX = 0.5
		text.anchorY = 0.5
		text:setFillColor(unpack(Color.lightText))
		FontOffset.setOffset(text)
		return
	end
	for i = 1, #items do
		GUI.drawVerticalLine(row, row.x + row.width * (i * (1 / skinsPerRow)), row.x, row.height)
	end
	for i = 1, #items do
		local columnX = (i - 1) * (1 / skinsPerRow * row.width)
		local columnWidth = 1 / skinsPerRow * row.width
		local actualEquipmentId = equipmentIds[(row.id - 1) * skinsPerRow + i]
		if not Game.equipment[actualEquipmentId] then
			insertItems()
			return true
		end
		local selectionRect = display.newRect(row, columnX + columnWidth / 2 - 345 * Game.guiScale / 2 - 4, 25 * Game.guiScale - 4, 353 * Game.guiScale, 353 * Game.guiScale)
		selectionRect:setFillColor(1, 1, 0)
		selectionRect.alpha = 0
		local isSelected = false
		for j = 1, #contract.items do
			if contract.items[j] == actualEquipmentId then
				isSelected = true
			end
		end
		if selectionMode and selectedItems[actualEquipmentId] then
			isSelected = true
		end
		if justDeselected == actualEquipmentId then
			justDeselected = nil
			selectionRect.alpha = 1
			transition.fadeOut(selectionRect, {time = 170})
		end
		if isSelected then
			transition.fadeIn(selectionRect, {time = 170})
		end
		local statTrak = false
		if Game.equipment[actualEquipmentId].statTrak then
			statTrak = true
		end
		local item
		if items[i].type == Item.skin then
			item = Game.skins[items[i].id]
			if items[i].pattern and items[i].pattern > #Game.skins[items[i].id].patterns then
				Game.equipment[actualEquipmentId].pattern = nil
			end
		elseif items[i].type == Item.sticker then
			item = Game.stickers[items[i].id]
		elseif items[i].type == Item.other then
			item = Game.otherItems[items[i].id]
		elseif items[i].type == Item.glove then
			item = Game.gloves[items[i].id]
		end
		if items[i].n then
			item.n = items[i].n
		else
			item.n = nil
		end
		local options = {}
		if contract.selecting or Game.settings.showQualityInEquipment then
			options = {
				quality = Game.equipment[actualEquipmentId].quality
			}
		end
		if items[i].pattern then
			options.pattern = items[i].pattern
		end
		if items[i].stickers and items[i].type == Item.skin then
			if Game.isKnife(items[i].id) then
				items[i].stickers = nil
			else
				options.stickers = items[i].stickers
			end
		end
		if params.highlights and params.highlights[i] then
			options.highlight = true
			Game.equipment[actualEquipmentId].hl = nil
		end
		if not selectionMode and not contract.selecting and Game.settings.stackEquipmentItems and 1 < itemCounts[actualEquipmentId] then
			options.additionalText = "x" .. itemCounts[actualEquipmentId]
		end
		local box = GUI.createItemBox(row, item, columnX + columnWidth / 2 - 345 * Game.guiScale / 2, 25 * Game.guiScale, statTrak, 1, options)
		box:addEventListener("tap", function(event)
			if selectionMode then
				local isSelected = false
				if selectedItems[actualEquipmentId] then
					isSelected = true
				end
				if isSelected then
					transition.fadeOut(selectionRect, {time = 170})
					selectedItems[actualEquipmentId] = nil
				else
					transition.fadeIn(selectionRect, {time = 170})
					selectedItems[actualEquipmentId] = true
				end
				updateButtons()
				return true
			end
			if contract.selecting == true then
				local isSelected = false
				for j = 1, #contract.items do
					if contract.items[j] == actualEquipmentId then
						isSelected = true
					end
				end
				if isSelected then
					transition.fadeOut(selectionRect, {time = 170})
					for j = 1, #contract.items do
						if contract.items[j] == actualEquipmentId then
							table.remove(contract.items, j)
							if #contract.items == 0 then
								justDeselected = actualEquipmentId
								resetContractFilters()
							end
							if #contract.items == 10 then
								contract.acceptButton.alpha = 1
								contract.counterText.alpha = 0
								break
							end
							contract.acceptButton.alpha = 0
							contract.counterText.alpha = 1
							break
						end
					end
				else
					if #contract.items == 10 then
						return
					end
					transition.fadeIn(selectionRect, {time = 170})
					table.insert(contract.items, actualEquipmentId)
					equipmentFilters:forbidAllRarities()
					equipmentFilters:allowRarity(Game.skins[items[i].id].rarity)
					if #contract.items == 1 then
						if Game.equipment[actualEquipmentId].statTrak then
							equipmentFilters.statTraksEnabled = true
							equipmentFilters.normalItemsEnabled = false
						else
							equipmentFilters.statTraksEnabled = false
							equipmentFilters.normalItemsEnabled = true
						end
						skinTable:deleteAllRows()
						insertItems()
					end
					if #contract.items == 10 then
						contract.acceptButton.alpha = 1
						contract.counterText.alpha = 0
					else
						contract.acceptButton.alpha = 0
						contract.counterText.alpha = 1
					end
				end
				contract.counterText.text = #contract.items .. " of 10 needed"
			else
				if system.getTimer() - actionTimer < 500 then
					return true
				end
				Game.showEquipmentItemInfo(actualEquipmentId, {
					lockable = true,
					stickable = true,
					equipmentId = actualEquipmentId,
					stickerRemoveCallback = function()
						skinTable:reloadData()
					end,
					lockCallback = function()
						if Game.settings.equipmentCategories then
							composer.showOverlay("overlays.moveitem", {
								isModal = true,
								effect = "slideDown",
								time = 200,
								params = {
									item = actualEquipmentId,
									okButtonCallback = function()
										scrollToLastY()
									end
								}
							})
						else
							Game.equipment[actualEquipmentId].locked = true
							scrollToLastY()
						end
					end,
					unlockCallback = function()
						Game.equipment[actualEquipmentId].locked = nil
						scrollToLastY()
					end
				})
			end
			return true
		end)
		local price = Game.getPrice(items[i])
		local formattedPrice = formatPrice(price)
		if contract.selecting or selectionMode then
			GUI.createButton(row, box.x, box.y + 345 * Game.guiScale + 13 * Game.guiScale, 345 * Game.guiScale, 60, "$" .. formattedPrice, RarityButtons[item.rarity], function()
			end, 32)
		elseif Game.equipment[actualEquipmentId].locked then
			GUI.createButton(row, box.x, box.y + 345 * Game.guiScale + 13 * Game.guiScale, 345 * Game.guiScale, 60, Lang.equipment.unlock, RarityButtons[item.rarity], function()
				if Game.settings.equipmentCategories then
					Game.equipment[actualEquipmentId].locked = nil
					Game.equipment[actualEquipmentId].ec = 1
				else
					Game.equipment[actualEquipmentId].locked = nil
				end
				scrollToLastY()
			end, 42)
		else
			GUI.createButton(row, box.x, box.y + 345 * Game.guiScale + 13 * Game.guiScale, 345 * Game.guiScale, 60 * Game.guiScale, Lang.equipment.sellfor .. " $" .. formattedPrice, RarityButtons[item.rarity], function(event)
				Game.blockButtons = true
				timer.performWithDelay(100, function()
					Game.blockButtons = false
				end, 3)
				if Game.showingOverlay then
					return true
				end
				local sellPrice = Game.sellEquipmentItem(items[i], actualEquipmentId, event, false, function(success)
					if success then
						scrollToLastY()
					end
				end)
				if not Game.settings.confirmItemSelling then
					scrollToLastY()
				end
				return true
			end, 32, {
				blockTime = 250,
				holdCallback = function(event)
					composer.showOverlay("overlays.sellitems", {
						params = {
							maximumPrice = price,
							items = displayedItems,
							callback = function()
								skinTable:deleteAllRows()
								insertItems()
							end
						}
					})
					return true
				end
			})
		end
	end
end
function scene:drawShowLockedButtons()
	local sceneGroup = self.view
	topButtons.showLockedButton = Button.create(sceneGroup, box.x + box.width - 155 + 2, box.y + 10, 145, 100, nil, ButtonType.default, function(event)
		if contract.selecting then
			return true
		end
		showLockedSkins()
		return true
	end, {
		image = {
			name = "icons/lock_unlocked.png",
			width = 50.25,
			height = 67.5
		}
	})
	topButtons.showNotLockedButton = Button.create(sceneGroup, box.x + box.width - 155 + 2, box.y + 10, 145, 100, nil, ButtonType.default, function(event)
		if contract.selecting then
			return true
		end
		showNotLockedSkins()
		return true
	end, {
		image = {
			name = "icons/lock_locked.png",
			width = 50.25,
			height = 67.5
		}
	})
	topButtons.showNotLockedButton:hide()
end
function scene:create(event)
	local sceneGroup = self.view
	box = GUI.drawMainBox(sceneGroup, "")
	local skinTableWidth = box.width
	if Game.settings.equipmentScrollbar then
		slider = VerticalSlider.create(sceneGroup, box.x + box.width - 85, box.y + 120, 80, box.height - 126)
		skinTableWidth = box.width - 85
	end
	skinTable = widget.newTableView({
		left = box.x,
		top = box.y + 120,
		width = skinTableWidth,
		height = box.height - 120,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onRowRender,
		listener = function(event)
			if GUI.holdTimer then
				timer.cancel(GUI.holdTimer)
				GUI.holdTimer = nil
			end
			if slider then
				slider:scrollListener(event)
			end
		end,
		hideScrollBar = true
	})
	skinsPerRow = calculateSkinsPerRow(skinTableWidth)
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y, box.width, box.height)
	buttonBackground:setFillColor(unpack(Color.row))
	local iconButtonCount = 1
	if Game.settings.equipmentCategories then
		iconButtonCount = 2
	end
	local iconButtonWidth = math.min(200, (box.width - iconButtonCount * 200) / 3 - 8 - 6)
	selectionButtons.back = Button.create(sceneGroup, box.x + 8, box.y + 10, iconButtonWidth, 100, nil, ButtonType.default, function(event)
		closeSelectionMode()
		return true
	end, {
		image = {
			name = "icons/back.png",
			width = 67.5,
			height = 67.5
		}
	})
	local normalButtonCount = 4
	if Game.settings.equipmentCategories then
		normalButtonCount = 3
	end
	local buttonWidth = (box.width - iconButtonWidth * iconButtonCount) / normalButtonCount - 8 - 8
	local moveButtonOptions = {fontSize = 58}
	local moveButtonWidth = buttonWidth
	if Game.settings.equipmentCategories then
		moveButtonOptions = {
			image = {
				name = "icons/move.png",
				width = 72 * Game.guiScale,
				height = 72 * Game.guiScale
			}
		}
		moveButtonWidth = iconButtonWidth
	else
		buttonWidth = buttonWidth + 6
	end
	selectionButtons.move = Button.create(sceneGroup, selectionButtons.back.x + selectionButtons.back.width + 8, box.y + 10, moveButtonWidth, 100, "", ButtonType.default, function(event)
		if selectionButtons.move.type == ButtonType.gray then
			return true
		end
		local itemList = {}
		for itemId, _ in pairs(selectedItems) do
			table.insert(itemList, itemId)
		end
		if selectionButtons.move:getText() then
			for _, item in ipairs(itemList) do
				if selectionButtons.move:getText() == "Lock" then
					Game.equipment[item].locked = true
				else
					Game.equipment[item].locked = false
				end
			end
			if selectionButtons.move:getText() == "Lock" then
				GUI.showMessageBox("Information", #itemList .. " items have been locked.")
			else
				GUI.showMessageBox("Information", #itemList .. " items have been unlocked.")
			end
			selectedItems = {}
			scrollToLastY()
			updateButtons()
			return true
		end
		composer.showOverlay("overlays.moveitem", {
			isModal = true,
			effect = "slideDown",
			time = 200,
			params = {
				items = itemList,
				okButtonCallback = function()
					selectedItems = {}
					scrollToLastY()
					updateButtons()
				end
			}
		})
		return true
	end, moveButtonOptions)
	selectionButtons.sell = Button.create(sceneGroup, selectionButtons.move.x + selectionButtons.move.width + 8, box.y + 10, buttonWidth, 100, "Sell", ButtonType.red, function(event)
		if selectionButtons.sell.type == ButtonType.gray then
			return true
		end
		local itemList = {}
		for itemId, _ in pairs(selectedItems) do
			table.insert(itemList, itemId)
		end
		table.sort(itemList, function(a, b)
			return b < a
		end)
		composer.showOverlay("overlays.massitemssell", {
			isModal = true,
			effect = "slideDown",
			time = 200,
			params = {
				items = itemList,
				callback = function()
					selectedItems = {}
					scrollToLastY()
					updateButtons()
				end
			}
		})
		return true
	end, {fontSize = 58})
	selectionButtons.selectAll = Button.create(sceneGroup, selectionButtons.sell.x + selectionButtons.sell.width + 8, box.y + 10, buttonWidth, 100, "All", ButtonType.purple, function(event)
		for _, itemId in ipairs(equipmentIds) do
			selectedItems[itemId] = true
		end
		updateButtons()
		skinTable:reloadData()
		return true
	end, {fontSize = 58})
	selectionButtons.selectNone = Button.create(sceneGroup, selectionButtons.selectAll.x + selectionButtons.selectAll.width + 8, box.y + 10, buttonWidth, 100, "None", ButtonType.purple, function(event)
		selectedItems = {}
		updateButtons()
		skinTable:reloadData()
		return true
	end, {fontSize = 58})
	itemSearch = ItemSearch.create()
	topButtons.searchButton = itemSearch:drawButton(sceneGroup, box.x + 8, box.y + 10, 145, 100)
	itemSearch:setOnChangeCallback(function()
		skinTable:deleteAllRows()
		insertItems()
	end)
	topButtons.selectButton = Button.create(sceneGroup, topButtons.searchButton.x + topButtons.searchButton.width + 9, box.y + 10, 145, 100, nil, ButtonType.default, function()
		openSelectionMode()
		return true
	end, {
		image = {
			name = "icons/select.png",
			width = 90,
			height = 81
		}
	})
	local filterButtonText = Lang.equipment.filteritems
	local filterButtonOptions = {fontSize = 56}
	local filterButtonX = topButtons.selectButton.x + topButtons.selectButton.width + 9
	local filterButtonWidth = box.width / 2 - 16 - 80 - 80 - 80
	if Game.settings.equipmentCategories then
		filterButtonWidth = 145
		filterButtonOptions = {
			image = {
				name = "icons/funnel.png",
				width = 62.99999999999999,
				height = 64.39999999999999
			}
		}
		filterButtonText = nil
	end
	topButtons.filterButton = Button.create(sceneGroup, filterButtonX, box.y + 10, filterButtonWidth, 100, filterButtonText, ButtonType.pink, function()
		if contract.selecting then
			return false
		end
		equipmentFilters:show(sceneGroup, box.x, box.y, box.width, box.height, function()
			skinTable:deleteAllRows()
			insertItems()
		end, {sortButtons = true})
	end, filterButtonOptions)
	local contractButtonX = filterButtonX + filterButtonWidth + 9
	local contractButtonWidth = box.width / 2 - 16 - 80 - 80 - 80
	if not Game.settings.equipmentCategories then
		contractButtonWidth = contractButtonWidth + 25
	end
	topButtons.signButton = Button.create(sceneGroup, contractButtonX, box.y + 10, contractButtonWidth, 100, Lang.equipment.signacontract .. "!", ButtonType.purple, function()
		if not contract.selecting then
			contract.selecting = true
			contract.counterText.alpha = 1
			contract.cancelButton.alpha = 1
			skinTable.y = box.y
			if slider then
				slider:moveY(-120)
			end
			contract.counterText.text = #contract.items .. " of 10 needed"
			resetContractFilters()
		end
	end, {fontSize = 56})
	if Game.settings.equipmentCategories then
		local listX = contractButtonX + contractButtonWidth + 9
		topButtons.categoryList = SelectionList.create(sceneGroup, listX, box.y + 10, box.x + box.width - listX - 8, 100, {
			onClick = function()
				if contract.selecting then
					return false
				end
				return true
			end
		})
		for i, category in ipairs(Game.equipmentCategories) do
			local default = i == 1
			topButtons.categoryList:addOption(category.name, function()
				actualCategory = i
				skinTable:deleteAllRows()
				insertItems()
				return true
			end, default)
		end
		topButtons.categoryList:addOption("[ Edit categories ]", function()
			composer.gotoScene("scenes.categories")
		end)
	else
		self:drawShowLockedButtons()
	end
	contract.cancelButton = GUI.createButton(sceneGroup, box.x + 8, box.y + box.height - 100, box.width / 2 - 16, 90, Lang.common.cancel, ButtonType.default, function()
		if not contract.selecting then
			return
		end
		cancelContractSigning()
	end, 45)
	contract.cancelButton.alpha = 0
	contract.acceptButton = GUI.createButton(sceneGroup, box.x + box.width / 2 + 8, box.y + box.height - 100, box.width / 2 - 16, 90, Lang.equipment.signthecontract .. "!", ButtonType.pink, function()
		if not contract.selecting then
			return
		end
		Game.signContract(contract.items)
		cancelContractSigning()
		contract.acceptButton.alpha = 0
		contract.counterText.alpha = 0
		contract.cancelButton.alpha = 0
	end, 45)
	contract.acceptButton.alpha = 0
	contract.counterText = display.newText({
		parent = sceneGroup,
		x = box.x + box.width / 2 + 15,
		y = box.y + box.height - 50,
		text = "0 " .. Lang.equipment.of10needed,
		font = Font.counterstrike,
		fontSize = 55,
		align = "center"
	})
	contract.counterText.anchorY = 0.5
	contract.counterText.alpha = 0
	FontOffset.setOffset(contract.counterText)
	skinCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(box),
		y = box.y - 28,
		text = "",
		font = Font.counterstrike,
		fontSize = 36,
		align = "center"
	})
	skinCounter.anchorX = 0.5
	skinCounter.anchorY = 0.5
	skinCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(skinCounter)
	sceneGroup:insert(skinTable)
	if slider then
		slider:toFront()
	end
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		skinTable:deleteAllRows()
		insertItems()
		if slider then
			slider:scrollBar(0)
			local tableMaxScroll = -(skinTable:getNumRows() * 466 * Game.guiScale) + skinTable.height
			slider:setTableView(skinTable, tableMaxScroll)
		end
		updateButtons()
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
		cancelContractSigning()
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
