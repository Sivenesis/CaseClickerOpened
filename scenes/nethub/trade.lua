local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local leftTable, rightTable, trade
local ownItems = {}
local traderItems = {}
local leftText, rightText, leftSlider, rightSlider
local leftPrice = 0
local rightPrice = 0
local removableItems = true
local function updateTexts()
	leftPrice = 0
	rightPrice = 0
	for i = 1, #ownItems do
		local item
		if ownItems[i].type == Item.skin then
			item = Game.skins[ownItems[i].item_id]
		elseif ownItems[i].type == Item.glove then
			item = Game.gloves[ownItems[i].item_id]
		else
			item = Game.stickers[ownItems[i].item_id]
		end
		local quality = ownItems[i].quality
		local statTrak = ownItems[i].stattrak and 0 < ownItems[i].stattrak or ownItems[i].statTrak and 0 < ownItems[i].statTrak
		leftPrice = leftPrice + Game.getItemPrice({
			id = item.id,
			statTrak = statTrak,
			type = item.type,
			quality = quality,
			pattern = ownItems[i].pattern,
			stickers = ownItems[i].stickers
		})
	end
	for i = 1, #traderItems do
		local item
		if traderItems[i].type == Item.skin then
			item = Game.skins[traderItems[i].item_id]
		elseif traderItems[i].type == Item.glove then
			item = Game.gloves[traderItems[i].item_id]
		else
			item = Game.stickers[traderItems[i].item_id]
		end
		local quality = traderItems[i].quality
		local statTrak = traderItems[i].stattrak and 0 < traderItems[i].stattrak
		rightPrice = rightPrice + Game.getItemPrice({
			id = item.id,
			statTrak = statTrak,
			type = item.type,
			quality = quality,
			pattern = traderItems[i].pattern,
			stickers = traderItems[i].stickers
		})
	end
	leftText.text = "$" .. formatPrice(leftPrice) .. " @ " .. Lang.trade.yourItems
	rightText.text = Lang.trade.traderItems .. " @ $" .. formatPrice(rightPrice)
	if trade.state == Trade.pending then
		if trade.user1 == NetHub.getNickname() and 0 < trade.user1accepted or trade.user2 == NetHub.getNickname() and 0 < trade.user2accepted then
			leftAcceptText.text = Lang.trade.accepted
			leftAcceptText:setFillColor(unpack(Color.gold))
		else
			leftAcceptText.text = Lang.trade.notAccepted
			leftAcceptText:setFillColor(unpack(Color.lightText))
		end
		if trade.user1 ~= NetHub.getNickname() and 0 < trade.user1accepted or trade.user2 ~= NetHub.getNickname() and 0 < trade.user2accepted then
			rightAcceptText.text = Lang.trade.accepted
			rightAcceptText:setFillColor(unpack(Color.gold))
		else
			rightAcceptText.text = Lang.trade.notAccepted
			rightAcceptText:setFillColor(unpack(Color.lightText))
		end
		leftAcceptText.alpha = 1
		rightAcceptText.alpha = 1
	else
		leftAcceptText.alpha = 0
		rightAcceptText.alpha = 0
	end
end
local addItemsToTableView = function(tableView, itemTable, removable)
	tableView:deleteAllRows()
	if #itemTable == 0 then
		tableView:insertRow({
			params = {empty = true},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 350
		})
		return
	end
	for _, item in ipairs(itemTable) do
		tableView:insertRow({
			params = {item = item, removable = removable},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 450
		})
	end
end
local function addItems(event)
	local trade = event.params
	leftTable:deleteAllRows()
	rightTable:deleteAllRows()
	ownItems = trade.ownItems
	traderItems = trade.traderItems
	table.sort(ownItems, function(a, b)
		return Game.getItemPrice({
			id = a.item_id,
			stickers = a.stickers,
			type = a.type,
			pattern = a.pattern,
			quality = a.quality,
			statTrak = a.statTrak
		}) > Game.getItemPrice({
			id = b.item_id,
			stickers = b.stickers,
			type = b.type,
			pattern = b.pattern,
			quality = b.quality,
			statTrak = b.statTrak
		})
	end)
	table.sort(traderItems, function(a, b)
		return Game.getItemPrice({
			id = a.item_id,
			stickers = a.stickers,
			type = a.type,
			pattern = a.pattern,
			quality = a.quality,
			statTrak = a.statTrak
		}) > Game.getItemPrice({
			id = b.item_id,
			stickers = b.stickers,
			type = b.type,
			pattern = b.pattern,
			quality = b.quality,
			statTrak = b.statTrak
		})
	end)
	local removable = false
	if trade.state == Trade.started then
		removable = true
	end
	addItemsToTableView(leftTable, ownItems, removable)
	addItemsToTableView(rightTable, traderItems)
end
local function onRowRender(event)
	local row = event.row
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if row.params.empty then
		local emptyText = display.newText({
			parent = row,
			x = row.width / 2,
			y = row.height / 2,
			text = Lang.trade.noItemsAdded,
			font = Font.default,
			fontSize = 52,
			align = "center"
		})
		emptyText.anchorX = 0.5
		emptyText.anchorY = 0.5
		FontOffset.setOffset(emptyText)
		return
	end
	local item = row.params.item
	local boxItem
	if item.type == Item.skin then
		boxItem = {
			id = item.item_id,
			type = ItemType.skin
		}
	elseif item.type == Item.glove then
		boxItem = {
			id = item.item_id,
			type = ItemType.glove
		}
	else
		boxItem = {
			id = item.item_id,
			type = ItemType.sticker
		}
	end
	if item.name then
		boxItem.n = item.name
	end
	local hasStatTrak = false
	if item.stattrak and item.stattrak == 1 then
		hasStatTrak = true
	end
	local itemBox = GUI.createItemBox(row, boxItem, row.width / 2 - 172.5, 15, hasStatTrak, 1, {
		pattern = item.pattern,
		quality = item.quality,
		stickers = item.stickers,
		dontUseGUIScale = true
	})
	local price = Game.getItemPrice({
		id = item.item_id,
		type = item.type,
		statTrak = hasStatTrak,
		pattern = item.pattern,
		stickers = item.stickers,
		quality = item.quality
	})
	local buttonText = "$" .. price
	if row.params.removable then
		buttonText = Lang.trade.remove .. " @ " .. buttonText
	end
	GUI.createButton(row, itemBox.x, itemBox.y + itemBox.height + 5, 345, 60, buttonText, RarityButtons[boxItem.rarity], function()
		if not row.params.removable then
			return
		end
		NetHub.removeItemFromTrade(trade.id, item.id, function(success, response)
			if not success or response and response.error == true then
				local text = Lang.trade.couldNotRemoveItem
				if response and response.text then
					text = response.text
				end
				return GUI.showMessageBox(Lang.common.error, text)
			end
			leftTable:deleteRow(row.id)
			Game.addItem(boxItem, false, hasStatTrak, true, {
				pattern = item.pattern,
				name = boxItem.n or boxItem.name,
				quality = item.quality,
				stickers = item.stickers,
				disableAchievements = true,
				disableMissions = true
			})
			table.remove(ownItems, row.id)
			if #ownItems == 0 then
				addItemsToTableView(leftTable, {})
			end
			if response and response.traderItems then
				addItemsToTableView(rightTable, response.traderItems, false)
			end
			updateTexts()
		end)
	end, 32, {blockTime = 500})
end
function scene:create(event)
	local sceneGroup = self.view
	trade = event.params
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("tap", function()
		return true
	end)
	local tradePlayer = trade.user1
	if NetHub.getNickname() == tradePlayer then
		tradePlayer = trade.user2
	end
	tradePlayer = tradePlayer or "Unknown"
	local itemsReceived = trade.user1items
	if NetHub.getNickname() == trade.user2 then
		itemsReceived = trade.user2items
	end
	local padding = 10
	local mainBox = GUI.createBox(sceneGroup, padding, padding, display.safeActualContentWidth - 2 * padding, display.safeActualContentHeight - 2 * padding, Lang.trade.tradeWith .. " " .. tradePlayer)
	local firstText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 40,
		text = Lang.trade.tradeWith .. " " .. tradePlayer,
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	firstText.anchorX = 0.5
	FontOffset.setOffset(firstText)
	leftText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox) - mainBox.width * 0.12,
		y = firstText.y + firstText.height + 40,
		text = Lang.trade.yourItems,
		font = Font.counterstrike,
		fontSize = 43,
		align = "center"
	})
	leftText.anchorX = 1
	leftText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(leftText)
	rightText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox) + mainBox.width * 0.12,
		y = firstText.y + firstText.height + 40,
		text = Lang.trade.traderItems,
		font = Font.counterstrike,
		fontSize = 43,
		align = "center"
	})
	rightText.anchorX = 0
	rightText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(rightText)
	local tradeImage = display.newImageRect(sceneGroup, "images/trades/" .. TradeImages[trade.state], 162, 122.39999999999999)
	tradeImage.x = getCenterX(mainBox)
	tradeImage.y = firstText.y + firstText.height + 70
	tradeImage.anchorX = 0.5
	local statusText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = tradeImage.y + tradeImage.height + 60,
		text = Lang.trade.status .. ":\r\n" .. TradeStatuses[trade.state],
		font = Font.counterstrike,
		fontSize = 52,
		width = mainBox.width * 0.2,
		align = "center"
	})
	statusText.anchorX = 0.5
	FontOffset.setOffset(statusText)
	local leftTableX = getCenterX(mainBox) - mainBox.width * 0.47 + 75
	local leftTableY = leftText.y + leftText.height + 20
	local leftTableHeight = mainBox.height - leftTableY - 20
	local rightTableX = getCenterX(mainBox) + mainBox.width * 0.12
	local rightTableWidth = mainBox.width * 0.35 - 75
	local rightTableHeight = leftTableHeight
	if trade.state == Trade.started then
		leftTableHeight = leftTableHeight - 80
	end
	leftSlider = VerticalSlider.create(sceneGroup, leftTableX - 75, leftTableY, 75, leftTableHeight)
	rightSlider = VerticalSlider.create(sceneGroup, rightTableX + rightTableWidth, leftTableY, 75, rightTableHeight)
	leftTable = widget.newTableView({
		left = leftTableX,
		top = leftTableY,
		width = mainBox.width * 0.35 - 75,
		height = leftTableHeight,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			leftSlider:scrollListener(event)
		end
	})
	rightTable = widget.newTableView({
		left = rightTableX,
		top = leftText.y + leftText.height + 20,
		width = rightTableWidth,
		height = rightTableHeight,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			rightSlider:scrollListener(event)
		end
	})
	sceneGroup:insert(leftTable)
	sceneGroup:insert(rightTable)
	leftAcceptText = display.newText({
		parent = sceneGroup,
		x = getCenterX(leftTable),
		y = leftTable.y + leftTable.height + 30,
		text = Lang.trade.notAccepted,
		font = Font.counterstrike,
		fontSize = 52,
		align = "center"
	})
	leftAcceptText.anchorX = 0.5
	FontOffset.setOffset(leftAcceptText)
	rightAcceptText = display.newText({
		parent = sceneGroup,
		x = getCenterX(rightTable),
		y = rightTable.y + rightTable.height + 30,
		text = Lang.trade.notAccepted,
		font = Font.counterstrike,
		fontSize = 52,
		align = "center"
	})
	rightAcceptText.anchorX = 0.5
	FontOffset.setOffset(rightAcceptText)
	leftAcceptText.alpha = 0
	rightAcceptText.alpha = 0
	if trade.state == Trade.started then
		Button.create(sceneGroup, leftTable.x - 75, leftTable.y + leftTable.height, leftTable.width + 75, 80, Lang.common.addItems, ButtonType.green, function(event)
			if Game.showingOverlay then
				return
			end
			composer.gotoScene("scenes.itemselection", {
				params = {
					type = ItemSelection.trade,
					tradeId = trade.id
				}
			})
		end, {fontSize = 50, blockTime = 700})
	end
	local additionalY = -120
	if trade.state == Trade.accepted and itemsReceived == 0 and 0 < #trade.traderItems or trade.state == Trade.cancelled and itemsReceived == 0 and 0 < #trade.ownItems then
		local buttonText = Lang.trade.getItems
		if trade.state == Trade.cancelled then
			buttonText = Lang.trade.returnItems
		end
		additionalY = additionalY + 120
		GUI.createButton(sceneGroup, statusText.x - mainBox.width * 0.1, statusText.y + statusText.height + 55 + additionalY, mainBox.width * 0.2, 100, buttonText, ButtonType.green, function(event)
			NetHub.getTradeItems(trade.id)
		end, 47)
	end
	if trade.state == Trade.started or trade.state == Trade.pending and trade.userAccepted == false then
		additionalY = additionalY + 120
		GUI.createButton(sceneGroup, statusText.x - mainBox.width * 0.1, statusText.y + statusText.height + 55 + additionalY, mainBox.width * 0.2, 100, "Accept", ButtonType.green, function(event)
			if #trade.ownItems == 0 then
				return GUI.showMessageBox(Lang.common.error, Lang.trade.noPlayerItems)
			elseif #trade.traderItems == 0 then
				return GUI.showMessageBox(Lang.common.error, Lang.trade.noTraderItems)
			end
			if leftPrice == 0 or rightPrice == 0 then
				return GUI.showMessageBox(Lang.common.error, Lang.trade.unknownError)
			end
			if 1.75 < leftPrice / rightPrice then
				return GUI.showMessageBox(Lang.common.error, Lang.trade.partnerNeedToGiveItemsWorth .. " $" .. formatPrice(leftPrice * 0.5714285714285714) .. ".")
			end
			if leftPrice / rightPrice < 0.5714285714285714 then
				return GUI.showMessageBox(Lang.common.error, Lang.trade.youNeedToGiveItemsWorth .. " $" .. formatPrice(rightPrice * 0.5714285714285714) .. ".")
			end
			NetHub.acceptTrade(trade.id, trade.key)
		end, 60)
	end
	if trade.state == Trade.started or trade.state == Trade.pending then
		additionalY = additionalY + 120
		GUI.createButton(sceneGroup, statusText.x - mainBox.width * 0.1, statusText.y + statusText.height + 55 + additionalY, mainBox.width * 0.2, 100, "Cancel", ButtonType.red, function(event)
			composer.showOverlay("overlays.sellconfirmation", {
				isModal = true,
				params = {
					text = Lang.trade.cancelConfirmation,
					callback = function(result)
						if result == true then
							NetHub.cancelTrade(trade.id)
						end
					end
				}
			})
		end, 60, {blockTime = 700})
	end
	if 20 < #trade.ownItems then
		os.exit()
	end
	additionalY = additionalY + 120
	GUI.createButton(sceneGroup, statusText.x - mainBox.width * 0.1, statusText.y + statusText.height + 55 + additionalY, mainBox.width * 0.2, 100, Lang.trade.chat, ButtonType.default, function(event)
		GUI.showMessageBox(Lang.tradeChat.loadingTradeMessages, Lang.common.pleaseWait .. "...", false)
		NetHub.loadMessages(trade.id, function(success, result)
			composer.hideOverlay()
			if not success then
				return GUI.showMessageBox("Error", result and result.text or "Could not load messages.")
			end
			return composer.gotoScene("scenes.nethub.chat", {
				params = {trade = trade}
			})
		end, true)
	end, 60, {blockTime = 700})
	if (trade.state ~= Trade.cancelled or itemsReceived ~= 0 or not (0 < #trade.ownItems)) and (trade.state ~= Trade.cancelled or itemsReceived ~= 1) and (trade.state ~= Trade.cancelled or #trade.ownItems ~= 0 or #trade.traderItems ~= 0) then
		additionalY = additionalY + 120
		GUI.createButton(sceneGroup, statusText.x - mainBox.width * 0.1, statusText.y + statusText.height + 55 + additionalY, mainBox.width * 0.2, 100, Lang.common.refresh, ButtonType.default, function(event)
			NetHub.loadTrade(trade.id)
		end, 60, {blockTime = 700})
	end
	additionalY = additionalY + 120
	GUI.createButton(sceneGroup, statusText.x - mainBox.width * 0.1, statusText.y + statusText.height + 55 + additionalY, mainBox.width * 0.2, 100, Lang.common.back, ButtonType.purple, function(event)
		composer.gotoScene("scenes.nethub.trades")
		composer.removeScene("scenes.nethub.trade")
	end, 60)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.hide()
		addItems(event)
		updateTexts()
	elseif phase == "did" then
		leftSlider:scrollBar(0)
		local tableMaxScroll = -(leftTable:getNumRows() * 450) + leftTable.height
		leftSlider:setTableView(leftTable, tableMaxScroll)
		rightSlider:scrollBar(0)
		tableMaxScroll = -(rightTable:getNumRows() * 450) + rightTable.height
		rightSlider:setTableView(rightTable, tableMaxScroll, 2)
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
