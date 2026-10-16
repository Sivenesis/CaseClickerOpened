local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local Filters = require("classes.Filters")
local ItemSearch = require("classes.ItemSearch")
local scene = composer.newScene()
local skinTable
local selectedItems = {}
local slider, worthCounter, titleText, addSelectedButton, backButton
local skinsPerRow = 3
local selectionType = ItemSelection.nameTag
local selectedItemsLimit = 0
local rowHeight = 470
local selectionFilters, itemSearch
local customVariables = {}
local function calculateBetItemsWorth()
	local betItemsWorth = 0
	for _, id in ipairs(Bets.bet.items) do
		betItemsWorth = betItemsWorth + Game.getPrice(Game.equipment[id])
	end
	for _, id in ipairs(selectedItems) do
		betItemsWorth = betItemsWorth + Game.getPrice(Game.equipment[id])
	end
	return betItemsWorth
end
local getItemTicketWorth = function(item)
	if item.type == Item.sticker then
		return math.floor(Game.getItemPrice(item) / 0.35)
	else
		return math.floor(Game.getItemPrice(item) / 0.125)
	end
end
local function getTotalItemPrice()
	local price = 0
	for i = 1, #selectedItems do
		price = price + Game.getItemPrice(Game.equipment[selectedItems[i]])
	end
	return price
end
local createItem = function(baseItem)
	local item = {}
	for k, v in pairs(baseItem) do
		item[k] = v
	end
	if baseItem.type == Item.skin then
		local tmpItem = Game.skins[baseItem.id]
		item.rarity = tmpItem.rarity
		item.name = tmpItem.name
		item.statTrakAvailable = tmpItem.statTrakAvailable
		item.souvenirAvailable = tmpItem.souvenirAvailable
		item.topTier = tmpItem.topTier
		if item.statTrak and not item.statTrakAvailable and not item.souvenirAvailable then
			item.statTrak = false
		end
	elseif baseItem.type == Item.glove then
		local tmpItem = Game.gloves[baseItem.id]
		item.rarity = tmpItem.rarity
		item.name = tmpItem.name
	else
		local tmpItem = Game.stickers[baseItem.id]
		item.rarity = tmpItem.rarity
		item.name = tmpItem.name
	end
	return item
end
local selectionTypes = {
	[ItemSelection.sticker] = {
		returnScene = "scenes.equipment",
		titleText = "Select item to add sticker to:",
		addButtonText = "Add sticker",
		selectedItemsLimit = 1,
		customReturnScene = true,
		onButtonClick = function(selectedItems)
			Stickers.addToSkin(customVariables.stickerEquipmentId, selectedItems[1])
			local equipmentIdToShow = selectedItems[1]
			if customVariables.stickerEquipmentId < selectedItems[1] then
				equipmentIdToShow = equipmentIdToShow - 1
			end
			composer.gotoScene("scenes.equipment")
			timer.performWithDelay(100, function()
				Game.showEquipmentItemInfo(equipmentIdToShow, {})
			end)
		end,
		onSetup = function(params)
			customVariables.stickerEquipmentId = params.stickerEquipmentId
		end,
		filterFunction = function(item)
			if item.type ~= Item.skin then
				return false
			end
			if Game.isKnife(item.id) then
				return false
			end
			if item.stickers and #item.stickers >= 4 then
				return false
			end
			return true
		end
	},
	[ItemSelection.upgrader] = {
		returnScene = "scenes.games.upgrader",
		titleText = "Select item to upgrade:",
		addButtonText = "Select",
		selectedItemsLimit = 1,
		customReturnScene = false,
		onButtonClick = function(selectedItems)
			customVariables.UpgraderManager.selectItem(selectedItems[1])
		end,
		filterFunction = function(item)
			if item.locked or item.tmpLock then
				return false
			end
			local itemPrice = Game.getItemPrice(item)
			if itemPrice >= customVariables.UpgraderManager.getMaxSelectedItemPrice() then
				return false
			end
			return true
		end,
		onSetup = function(params)
			if not customVariables.UpgraderManager then
				customVariables.UpgraderManager = require("managers.UpgraderManager")
			end
		end
	},
	[ItemSelection.nameTag] = {
		returnScene = "scenes.shop",
		titleText = Lang.nametag.selectItem .. ":",
		addButtonText = Lang.nametag.renameItem,
		selectedItemsLimit = 1,
		customReturnScene = true,
		onButtonClick = function(selectedItems)
			composer.showOverlay("overlays.itemrename", {
				params = {
					item = selectedItems[1]
				}
			})
		end,
		filterFunction = function(item)
			if item.type == Item.skin then
				return true
			end
			return false
		end
	},
	[ItemSelection.casino] = {
		returnScene = "scenes.casino",
		removeSelectedItems = true,
		customReturnScene = true,
		additionalText = true,
		getAdditionalText = function(item)
			return commaValue(getItemTicketWorth(item)) .. " tickets"
		end,
		onButtonClick = function(selectedItemsPrice)
			local ticketsToAdd = customVariables.ticketAmount
			Game.roulette.balance = Game.roulette.balance + ticketsToAdd
			composer.gotoScene("scenes.casino")
			GUI.showMessageBox(Lang.common.success, Lang.casino.depositedMsg:gsub("{1}", commaValue(ticketsToAdd)))
			Game.roulette.ticketsToPlay = Game.roulette.ticketsToPlay + math.floor(ticketsToAdd / 2)
			Game.recalculateEquipmentWorth()
			Game.save()
		end,
		getRightText = function(totalPrice, s)
			return #selectedItems .. " item" .. s .. " worth " .. commaValue(customVariables.ticketAmount) .. " " .. Lang.casino.tickets .. " (" .. Lang.itemSelection.max .. ". " .. commaValue(math.max(0, 100000 - Game.roulette.balance - Game.roulette.betAmount)) .. ")"
		end,
		canSelectItem = function(item)
			if customVariables.ticketAmount + getItemTicketWorth(item) > math.max(0, 100000 - Game.roulette.balance - Game.roulette.betAmount) then
				return false
			end
			return true
		end,
		onSetup = function()
			customVariables.ticketAmount = 0
		end,
		onSelect = function(item)
			customVariables.ticketAmount = customVariables.ticketAmount + getItemTicketWorth(item)
		end,
		onDeselect = function(item)
			customVariables.ticketAmount = customVariables.ticketAmount - getItemTicketWorth(item)
		end,
		filterFunction = function(item)
			if not item.locked and not item.tmpLock then
				return true
			end
			return false
		end
	},
	[ItemSelection.bet] = {
		returnScene = "scenes.nethub.bet",
		titleText = "Select items to bet:",
		removeSelectedItems = false,
		customReturnScene = false,
		onButtonClick = function(selectedItems)
			for i = 1, #selectedItems do
				Game.equipment[selectedItems[i]].tmpLock = true
				table.insert(Bets.bet.items, selectedItems[i])
			end
		end,
		getRightText = function()
			return "Total: " .. #Bets.bet.items + #selectedItems .. " / 10 items worth $" .. formatPrice(calculateBetItemsWorth()) .. " (max $5,000)"
		end,
		canSelectItem = function(item)
			if #Bets.bet.items + #selectedItems >= 10 then
				return false
			end
			if Game.getPrice(item) + calculateBetItemsWorth() >= 5000 then
				return false
			end
			return true
		end,
		filterFunction = function(item)
			if not item.locked and not item.tmpLock then
				return true
			end
			return false
		end
	},
	[ItemSelection.jackpot] = {
		returnScene = "scenes.jackpot",
		removeSelectedItems = false,
		onButtonClick = function(selectedItems)
			Jackpot.addItems(selectedItems)
			selectedItems = {}
			composer.gotoScene("scenes.jackpot")
		end,
		getRightText = function(totalPrice)
			return "Total: " .. #selectedItems .. " items worth $" .. totalPrice
		end,
		canSelectItem = function(item)
			if #Game.jackpot.playerItems + #selectedItems >= 10 then
				return false
			end
			if Jackpot.getItemCount() + #selectedItems >= 50 then
				return false
			end
			return true
		end,
		filterFunction = function(item)
			if item.locked or item.tmpLock then
				return false
			end
			if Game.jackpot.mode == 2 and item.type ~= Item.skin or Game.jackpot.mode == 3 and item.type ~= Item.sticker then
				return false
			end
			return true
		end
	},
	[ItemSelection.trade] = {
		returnScene = "scenes.nethub.trades",
		customReturnScene = true,
		removeSelectedItems = false,
		onButtonClick = function(selectedItems)
			local itemsToAdd = {}
			for i = 1, #selectedItems do
				local eqItem = Game.equipment[selectedItems[i]]
				local tmp = {
					type = eqItem.type,
					id = eqItem.id,
					equipment_id = selectedItems[i],
					n = eqItem.n or nil,
					quality = eqItem.quality or nil,
					stickers = eqItem.stickers or nil
				}
				if eqItem.pattern and eqItem.pattern > 0 then
					tmp.pattern = eqItem.pattern
				end
				if eqItem.statTrak then
					tmp.stattrak = 1
				else
					tmp.stattrak = 0
				end
				table.insert(itemsToAdd, tmp)
			end
			selectedItems = {}
			GUI.showMessageBox(Lang.itemSelection.addingItems, Lang.common.pleaseWait .. "...", false)
			NetHub.addItemsToTrade(customVariables.tradeId, itemsToAdd, function(success, response)
				if not success or response and response.error == true then
					local text = Lang.itemSelection.couldNotAddItems .. "."
					if response and response.text then
						text = response.text
					end
					NetHub.loadTrade(customVariables.tradeId, true)
					Game.blockButtons = false
					return GUI.showMessageBox(Lang.common.error, text)
				end
				NetHub.loadTrade(customVariables.tradeId, true)
				GUI.showMessageBox("Success", response.text)
				Game.blockButtons = false
			end)
		end,
		onBackButtonClick = function()
			NetHub.loadTrade(customVariables.tradeId, true)
		end,
		getRightText = function(totalPrice)
			return Lang.itemSelection.total .. ": " .. #NetHub.cache.trades[customVariables.tradeId].ownItems + #selectedItems .. " / 20 " .. Lang.itemSelection.itemsWorth .. " " .. formatPrice(customVariables.ownItemsWorth + totalPrice)
		end,
		canSelectItem = function(item)
			if #NetHub.cache.trades[customVariables.tradeId].ownItems + #selectedItems >= 20 then
				return false
			end
			return true
		end,
		onSetup = function(params)
			customVariables.ownItemsWorth = 0
			customVariables.tradeId = tonumber(params.tradeId)
			for _, ownItem in ipairs(NetHub.cache.trades[customVariables.tradeId].ownItems) do
				local item
				if ownItem.type == Item.skin then
					item = Game.skins[ownItem.item_id]
				else
					item = Game.stickers[ownItem.item_id]
				end
				local statTrak = ownItem.stattrak and 0 < ownItem.stattrak or ownItem.statTrak and 0 < ownItem.statTrak
				customVariables.ownItemsWorth = customVariables.ownItemsWorth + Game.getItemPrice({
					id = item.id,
					type = item.type,
					quality = ownItem.quality,
					stickers = ownItem.stickers,
					pattern = ownItem.pattern,
					statTrak = statTrak
				})
			end
		end,
		filterFunction = function(item)
			if item.locked or item.tmpLock then
				return false
			end
			return true
		end
	},
	[ItemSelection.onlineJackpot] = {
		returnScene = "scenes.jackpots.jackpot",
		removeSelectedItems = false,
		onButtonClick = function(selectedItems)
			OnlineJackpots.addItems(selectedItems)
		end,
		getRightText = function(totalPrice, s)
			for _, item in ipairs(OnlineJackpots.playerItems) do
				totalPrice = totalPrice + Game.getItemPrice(item)
			end
			return #selectedItems + #OnlineJackpots.playerItems .. " " .. "item" .. s .. " worth $" .. formatPrice(totalPrice) .. " (" .. Lang.itemSelection.max .. " $" .. formatPrice(customVariables.roomType.maxTotalPrice) .. ")"
		end,
		canSelectItem = function(item)
			if #OnlineJackpots.getPlayerItems() + #selectedItems >= OnlineJackpots.room.itemsPerPlayerLimit then
				return false
			end
			if getTotalItemPrice() + Game.getItemPrice(item) > customVariables.roomType.maxTotalPrice then
				return false
			end
			if OnlineJackpots.getItemCount() + #selectedItems >= OnlineJackpots.getItemLimit() then
				return true
			end
			return true
		end,
		onSetup = function()
			customVariables.roomType = OnlineJackpots.roomTypes[OnlineJackpots.room.type]
		end,
		filterFunction = function(item)
			if item.locked then
				return false
			end
			if item.type ~= Item.skin then
				return false
			end
			local itemPrice = Game.getItemPrice(item)
			if itemPrice < customVariables.roomType.minPrice or itemPrice > customVariables.roomType.maxPrice then
				return false
			end
			return true
		end
	}
}
local function updateWorthCounter()
	if selectionType == ItemSelection.nameTag then
		return
	end
	local s = ""
	if #selectedItems ~= 1 then
		s = "s"
	end
	if selectionTypes[selectionType].getRightText then
		worthCounter.text = selectionTypes[selectionType].getRightText(getTotalItemPrice(), s)
	end
end
local function setupItemSelection(params)
	titleText.text = selectionTypes[selectionType].titleText or "Select items to add:"
	selectedItemsLimit = selectionTypes[selectionType].selectedItemsLimit or 0
	addSelectedButton:setText(selectionTypes[selectionType].addButtonText or "Add Selected")
	customVariables = {}
	if selectionTypes[selectionType].onSetup then
		selectionTypes[selectionType].onSetup(params)
	end
end
local function getSelectedItemsCount()
	return #selectedItems
end
local function onRowRender(event)
	local row = event.row
	local eqIds = event.row.params.equipmentIds
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if not eqIds then
		local text = display.newText({
			parent = row,
			x = getCenterX(row),
			y = 125,
			text = Lang.equipment.empty,
			font = Font.counterstrike,
			fontSize = 72,
			align = "center"
		})
		text.anchorX = 0.5
		text.anchorY = 0.5
		text:setFillColor(unpack(Color.lightText))
		FontOffset.setOffset(text)
		return
	end
	local skins = {}
	for i = 1, #eqIds do
		skins[i] = Game.equipment[eqIds[i]]
	end
	for i = 1, skinsPerRow - 1 do
		GUI.drawVerticalLine(row, row.x + row.width * (i * (1 / skinsPerRow)), row.x, row.height)
	end
	for i = 1, #skins do
		local columnX = (i - 1) * (1 / skinsPerRow * row.width)
		local columnWidth = 1 / skinsPerRow * row.width
		local selectionRect = display.newRect(row, columnX + columnWidth / 2 - 345 * Game.guiScale / 2 - 4, 25 * Game.guiScale - 4, 353 * Game.guiScale, 353 * Game.guiScale)
		selectionRect:setFillColor(1, 1, 0)
		selectionRect.alpha = 0
		for j = 1, #selectedItems do
			if selectedItems[j] == eqIds[i] then
				selectionRect.alpha = 1
				break
			end
		end
		local itemBox = GUI.createItemBox(row, skins[i], columnX + columnWidth / 2 - 345 * Game.guiScale / 2, 25 * Game.guiScale, skins[i].statTrak, 1, {
			quality = skins[i].quality,
			pattern = skins[i].pattern,
			stickers = skins[i].stickers
		})
		itemBox:addEventListener("tap", function()
			local eqId = eqIds[i]
			if selectionRect.alpha == 0 then
				if getSelectedItemsCount() >= selectedItemsLimit and selectedItemsLimit ~= 0 then
					return true
				end
				if selectionTypes[selectionType].canSelectItem and selectionTypes[selectionType].canSelectItem(Game.equipment[eqId]) == false then
					return true
				end
				if selectionTypes[selectionType].onSelect then
					selectionTypes[selectionType].onSelect(Game.equipment[eqId])
				end
				selectionRect.alpha = 1
				table.insert(selectedItems, eqId)
				updateWorthCounter()
			else
				selectionRect.alpha = 0
				if selectionTypes[selectionType].onDeselect then
					selectionTypes[selectionType].onDeselect(Game.equipment[eqId])
				end
				for i = 1, #selectedItems do
					if selectedItems[i] == eqId then
						table.remove(selectedItems, i)
						updateWorthCounter()
						break
					end
				end
			end
			if 0 < #selectedItems then
				backButton:hide()
				addSelectedButton:show()
			else
				backButton:show()
				addSelectedButton:hide()
			end
		end)
		GUI.createButton(row, itemBox.x, itemBox.y + itemBox.height + 5, 345 * Game.guiScale, 60 * Game.guiScale, "$" .. formatPrice(Game.getPrice(Game.equipment[eqIds[i]])), RarityButtons[skins[i].rarity], function()
		end, 32)
		if selectionTypes[selectionType].additionalText then
			local additionalText = display.newText({
				parent = row,
				x = itemBox.x + itemBox.width / 2,
				y = itemBox.y + itemBox.height + 85 * Game.guiScale,
				text = selectionTypes[selectionType].getAdditionalText(Game.equipment[eqIds[i]]),
				font = Font.counterstrike,
				fontSize = 32,
				align = "center"
			})
			additionalText.anchorX = 0.5
			additionalText.anchorY = 0
			additionalText:setFillColor(unpack(Color.lightText))
			FontOffset.setOffset(additionalText)
		end
	end
end
local function insertRows()
	skinTable:deleteAllRows()
	local eq = Game.equipment
	local allowedSkins = {}
	for i = 1, #eq do
		local canAdd = false
		if selectionTypes[selectionType].filterFunction then
			if selectionTypes[selectionType].filterFunction(eq[i]) then
				canAdd = true
			end
		else
			canAdd = true
		end
		if selectionFilters.filtersView or itemSearch.searchString then
			local item = createItem(eq[i])
			if canAdd then
				if not selectionFilters:isAllowed(item) then
					canAdd = false
				end
				if itemSearch.searchString then
					canAdd = false
					if item.n and itemSearch:isAllowed(item.n) then
						canAdd = true
					end
					if itemSearch:isAllowed(item.name:gsub(" |", "")) then
						canAdd = true
					end
				end
				if canAdd then
					table.insert(allowedSkins, i)
				end
			end
		elseif canAdd then
			table.insert(allowedSkins, i)
		end
	end
	if #allowedSkins == 0 then
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
			rowHeight = 250 * Game.guiScale
		})
		return
	end
	for i = 0, math.ceil(#allowedSkins / skinsPerRow) - 1 do
		local params = {}
		for j = 1, skinsPerRow do
			if not allowedSkins[i * skinsPerRow + j] then
				break
			end
			params[j] = allowedSkins[i * skinsPerRow + j]
		end
		skinTable:insertRow({
			params = {equipmentIds = params},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = rowHeight * Game.guiScale
		})
	end
	slider:scrollBar(0)
	local tableMaxScroll = -(skinTable:getNumRows() * (rowHeight * Game.guiScale)) + skinTable.height
	slider:setTableView(skinTable, tableMaxScroll)
end
function scene:create(event)
	local sceneGroup = self.view
	selectionType = event.params.type
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.01, display.safeActualContentHeight * 0.01, display.safeActualContentWidth * 0.98, display.safeActualContentHeight * 0.98, "")
	worthCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y - 28,
		text = "",
		font = Font.counterstrike,
		fontSize = 36,
		align = "center"
	})
	worthCounter.anchorX = 0.5
	worthCounter.anchorY = 0.5
	worthCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(worthCounter)
	slider = VerticalSlider.create(sceneGroup, mainBox.x + mainBox.width - 150, mainBox.y + 130, 100, mainBox.height * 0.73)
	skinTable = widget.newTableView({
		left = mainBox.x + 50,
		top = mainBox.y + 130,
		width = mainBox.width - 200,
		height = mainBox.height * 0.73,
		isBounceEnabled = false,
		hideBackground = false,
		backgroundColor = {
			unpack(Color.row)
		},
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	sceneGroup:insert(skinTable)
	skinsPerRow = calculateSkinsPerRow(skinTable.width)
	selectionFilters = Filters.create()
	itemSearch = ItemSearch.create()
	local filtersButton = Button.create(sceneGroup, skinTable.x, skinTable.y - 90, 250, 85, nil, ButtonType.pink, function()
		selectionFilters:show(sceneGroup, skinTable.x, skinTable.y - 100, skinTable.width + 110, skinTable.height + 100 + 100 + 70, function()
			insertRows()
		end, {sortButtons = false})
	end, {
		image = {
			name = "icons/funnel.png",
			width = 54,
			height = 55.199999999999996
		}
	})
	local searchButton = itemSearch:drawButton(sceneGroup, filtersButton.x + filtersButton.width + 10, filtersButton.y + 1, 250, 83)
	itemSearch:setOnChangeCallback(function()
		insertRows()
	end)
	mainBox:cornersToFront()
	titleText = display.newText({
		parent = sceneGroup,
		x = searchButton.x + searchButton.width + 30,
		y = mainBox.y + 56,
		text = "",
		font = Font.counterstrike,
		fontSize = 82,
		align = "left"
	})
	FontOffset.setOffset(titleText)
	rowHeight = 470
	if selectionTypes[selectionType].additionalText then
		rowHeight = 490
	end
	addSelectedButton = Button.create(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, mainBox.width - 340, 120, Lang.itemSelection.addSelected, ButtonType.purple, function(event)
		Game.blockButtons = true
		timer.performWithDelay(400, function()
			Game.blockButtons = false
		end, 3)
		if selectionTypes[selectionType].removeSelectedItems then
			table.sort(selectedItems, function(a, b)
				return b < a
			end)
			local totalPrice = 0
			for i = 1, #selectedItems do
				totalPrice = totalPrice + Game.getItemPrice(Game.equipment[selectedItems[i]])
				table.remove(Game.equipment, selectedItems[i])
			end
			selectionTypes[selectionType].onButtonClick(totalPrice)
		else
			selectionTypes[selectionType].onButtonClick(selectedItems)
		end
		if not selectionType == ItemSelection.nameTag then
			selectedItems = {}
		end
		if not selectionTypes[selectionType].customReturnScene then
			composer.gotoScene(selectionTypes[selectionType].returnScene)
		end
	end, {fontSize = 70, blockTime = 250})
	addSelectedButton:hide()
	backButton = Button.create(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, mainBox.width - 340, 120, Lang.common.back, ButtonType.default, function(event)
		selectedItems = {}
		if selectionTypes[selectionType].onBackButtonClick then
			return selectionTypes[selectionType].onBackButtonClick()
		end
		composer.gotoScene(selectionTypes[selectionType].returnScene)
	end, {fontSize = 70})
	local leftBox = display.newRect(sceneGroup, mainBox.x, mainBox.y + mainBox.height - 160, 200, 140)
	leftBox.alpha = 0
	leftBox.isHitTestable = true
	leftBox:addEventListener("touch", function(event)
		Game.blockButtons = true
		timer.performWithDelay(300, function()
			Game.blockButtons = false
		end, 3)
		return true
	end)
	local rightBox = display.newRect(sceneGroup, mainBox.x + mainBox.width - 200, mainBox.y + mainBox.height - 160, 200, 140)
	rightBox.alpha = 0
	rightBox.isHitTestable = true
	rightBox:addEventListener("touch", function(event)
		Game.blockButtons = true
		timer.performWithDelay(300, function()
			Game.blockButtons = false
		end, 3)
		return true
	end)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		selectionType = event.params.type
		setupItemSelection(event.params)
		Menu.hide()
		insertRows()
		selectedItems = {}
		updateWorthCounter()
		backButton:show()
		addSelectedButton:hide()
		slider:scrollBar(0)
		local tableMaxScroll = -(skinTable:getNumRows() * rowHeight * Game.guiScale) + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
		composer.removeScene("scenes.itemselection")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
