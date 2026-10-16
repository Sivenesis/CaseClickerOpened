local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local skinTable, slider
local itemTable = {}
local rowHeight = 340
local function onRowRender(event)
	local row = event.row
	local playerId = row.params.playerId
	local items = itemTable[playerId]
	local player = OnlineJackpots.room.players[playerId]
	local avatarImage = display.newImageRect(row, "images/avatars/" .. Jackpot.botNames[player.avatar]:lower() .. ".jpg", 240.1, 165.2)
	avatarImage.anchorX = 0
	avatarImage.anchorY = 0
	avatarImage.x = 10
	avatarImage.y = 10
	local playerName = display.newText({
		parent = row,
		x = 20,
		y = avatarImage.y + avatarImage.height + 20,
		text = player.name,
		font = Font.default,
		width = avatarImage.width,
		fontSize = 28
	})
	playerName.anchorX = 0
	playerName.anchorY = 0
	FontOffset.setOffset(playerName)
	GUI.drawVerticalLine(row, avatarImage.x + avatarImage.width + 25, 0, row.height)
	local itemsWorth = 0
	local lastX = avatarImage.x + avatarImage.width + 50
	local imageY = 30
	for _, item in ipairs(items) do
		if item.stickers then
			local stickerPositions = {
				[1] = {0},
				[2] = {-0.2, 0.2},
				[3] = {
					-0.4,
					0,
					0.4
				},
				[4] = {
					-0.5,
					-0.16,
					0.16,
					0.5
				}
			}
			for i = 1, math.min(4, #item.stickers) do
				local dimensions = Stickers.getStickerImageDimensions(item.stickers[i])
				local stickerImage = display.newImageRect(row, "images/smallstickers/" .. item.stickers[i] .. ".png", dimensions.width * 0.2, dimensions.height * 0.2)
				stickerImage = stickerImage or display.newImageRect(row, "images/stickers/" .. item.stickers[i] .. ".png", dimensions.width * 0.2, dimensions.height * 0.2)
				stickerImage.anchorX = 0.5
				stickerImage.anchorY = 0
				stickerImage.x = lastX + 54 + 108 * stickerPositions[#item.stickers][i]
			end
		end
		local itemPrice = Game.getItemPrice(item)
		itemsWorth = itemsWorth + itemPrice
		local imagePath = "images/skins/" .. item.id
		if item.pattern then
			imagePath = imagePath .. "_" .. (item.pattern or options.pattern)
		end
		imagePath = imagePath .. ".png"
		local imageWidth = 108
		local imageHeight = 90
		if Game.checkForItemNewImage(item.id, not item.pattern and options and options.pattern) then
			imageWidth = 107.52
			imageHeight = 80.64
		end
		local itemImage = display.newImageRect(row, imagePath, imageWidth, imageHeight)
		itemImage.anchorX = 0
		itemImage.x = lastX
		itemImage.y = imageY
		local qualityText = display.newText({
			parent = row,
			x = itemImage.x,
			y = itemImage.y + itemImage.height,
			text = QualityAbbreviations[item.quality],
			font = Font.default,
			fontSize = 20,
			align = "left"
		})
		qualityText.anchorX = 0
		qualityText.anchorY = 1
		FontOffset.setOffset(qualityText)
		if item.statTrak then
			local rectColor = Color.statTrak
			if Game.skins[item.id].souvenirAvailable then
				rectColor = Color.souvenir
			end
			local rect = display.newRect(row, lastX, itemImage.y + itemImage.height, itemImage.width, 6)
			rect.anchorX = 0
			rect.anchorY = 0
			rect:setFillColor(unpack(rectColor))
		end
		local itemText = display.newText({
			parent = row,
			x = itemImage.x + itemImage.width / 2,
			y = itemImage.y + itemImage.height + 8 + 6,
			text = "$" .. formatPrice(itemPrice),
			font = Font.default,
			fontSize = 30,
			align = "center"
		})
		itemText.anchorX = 0.5
		itemText.anchorY = 0
		FontOffset.setOffset(itemText)
		lastX = lastX + itemImage.width + 30
		if lastX + itemImage.width + 40 >= row.width then
			lastX = avatarImage.x + avatarImage.width + 50
			imageY = imageY + itemImage.height + 65
		end
	end
	local winChance = OnlineJackpots.getWinChance(player.id)
	local winChanceText = display.newText({
		parent = row,
		x = 20,
		y = playerName.y + playerName.height + 20,
		text = Lang.jackpotItems.winChance .. ": " .. winChance .. "%",
		font = Font.default,
		width = avatarImage.width,
		fontSize = 26
	})
	winChanceText.anchorX = 0
	winChanceText.anchorY = 0
	winChanceText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(winChanceText)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
function insertNewItemsToJackpotItemList(items)
	local playerId = items[1].player
	if itemTable[playerId] then
		for _, item in ipairs(items) do
			table.insert(itemTable[playerId], item)
		end
		skinTable:reloadData()
	else
		itemTable[playerId] = items
		local rowColor = Color.row
		if tableLength(itemTable) % 2 == 0 then
			rowColor = Color.lightRow
		end
		skinTable:insertRow({
			params = {playerId = playerId},
			rowColor = {default = rowColor},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = rowHeight
		})
		skinTable:reloadData()
		local tableMaxScroll = -(skinTable:getNumRows() * rowHeight) + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
	end
end
local function insertItemsToJackpotItemList()
	itemTable = {}
	for _, item in ipairs(OnlineJackpots.items) do
		if not itemTable[item.player] then
			itemTable[item.player] = {}
		end
		table.insert(itemTable[item.player], item)
	end
	skinTable:deleteAllRows()
	local i = 1
	for playerId, items in pairs(itemTable) do
		local rowColor = Color.row
		if i % 2 == 0 then
			rowColor = Color.lightRow
		end
		skinTable:insertRow({
			params = {playerId = playerId},
			rowColor = {default = rowColor},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = rowHeight
		})
		i = i + 1
	end
	slider:scrollBar(0)
	local tableMaxScroll = -(skinTable:getNumRows() * rowHeight) + skinTable.height
	slider:setTableView(skinTable, tableMaxScroll)
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.125, display.safeActualContentHeight * 0.125, display.safeActualContentWidth * 0.75, display.safeActualContentHeight * 0.75, Lang.jackpotItems.itemsInTheJackpot, false)
	mainBox:setFillColor(rgb(22, 30, 40))
	local tableMargin = 5
	slider = VerticalSlider.create(sceneGroup, mainBox.x + mainBox.width - 100 - tableMargin, mainBox.y + tableMargin, 100, mainBox.height - tableMargin * 2 - 140)
	skinTable = widget.newTableView({
		left = mainBox.x + tableMargin,
		top = mainBox.y + tableMargin,
		width = mainBox.width - tableMargin * 2 - 100,
		height = mainBox.height - tableMargin * 2 - 140,
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
	GUI.createButton(sceneGroup, getCenterX(mainBox) - mainBox.width / 2 + 10, mainBox.y + mainBox.height - 130, mainBox.width - 20, 120, Lang.common.ok, ButtonType.green, function()
		composer.hideOverlay("fade", 250)
	end, 60)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = true
		insertItemsToJackpotItemList()
		slider:scrollBar(0)
		local tableMaxScroll = -(skinTable:getNumRows() * rowHeight) + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
