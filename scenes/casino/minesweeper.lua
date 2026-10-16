local composer = require("composer")
if not Minesweeper then
	require("games.minesweeper")
end
local scene = composer.newScene()
local sceneGroup, beforeGroup, afterGroup, mainBox
local textMoved = false
local textMoveValue = 250
local redVariantButtons = {}
local greenVariantButtons = {}
local backgroundRectangles = {}
local mapRectangles = {}
local bombImages = {}
local tileTexts = {}
local betAmountChangeText, gameStatusText, balance, betAmount, balancePlusText, statusText, yourBalanceText, betAmountText
local lastBet = 0
local betLimit = 250000
local minimumBetValue = 100
local newGameButton, returnButton, sheetOptions, explosionSheet, sequenceData
local function showBalancePlusText(amount)
	if amount == 0 then
		return
	end
	local minus = false
	local str = "+"
	if 0 < amount then
		balancePlusText:setFillColor(unpack(Color.green))
	else
		balancePlusText:setFillColor(unpack(Color.red))
		str = "@"
		minus = true
		amount = amount * -1
	end
	balancePlusText.text = str .. commaValue(amount)
	balancePlusText.alpha = 1
	balancePlusText.x = balance.x + balance.width + 40
	transition.fadeOut(balancePlusText, {time = 1000})
end
local function showExplosion(event)
	if not sheetOptions then
		sheetOptions = {
			width = 300,
			height = 300,
			numFrames = 12
		}
		explosionSheet = graphics.newImageSheet("images/explosion.png", sheetOptions)
		sequenceData = {
			name = "explosion",
			start = 1,
			count = 12,
			time = 700,
			loopCount = 1,
			loopDirection = "forward"
		}
	end
	local explosion = display.newSprite(explosionSheet, sequenceData)
	explosion.anchorX = 0.5
	explosion.anchorY = 0.5
	explosion.x = event.x
	explosion.y = event.y
	explosion:rotate(math.random(1, 360))
	local scale = (40 + math.random(80, 120)) / 100
	explosion.xScale = scale
	explosion.yScale = scale
	explosion:play()
	explosion:addEventListener("sprite", function(event)
		if event.phase == "ended" then
			explosion:removeSelf()
		end
	end)
end
local function updateTexts()
	balance.text = commaValue(Game.roulette.balance) .. " " .. Lang.casino.tickets
	betAmount.text = commaValue(Game.minesweeper.betAmount) .. " " .. Lang.casino.tickets
end
local function updateButtons()
	newGameButton.alpha = 0
	returnButton.alpha = 0
	if (Game.minesweeper.lost or Game.minesweeper.won) and Game.minesweeper.started then
		newGameButton.alpha = 1
		return
	end
	returnButton.alpha = 1
end
local function updateGameStatusText()
	local number = commaValue(tostring(Game.minesweeper.roundProfit)):gsub("-", "@")
	gameStatusText.text = "Profit: " .. number .. " points"
	if Game.minesweeper.roundProfit < 0 then
		gameStatusText:setFillColor(unpack(Color.gold))
	else
		gameStatusText:setFillColor(unpack(Color.green))
	end
	if Game.minesweeper.lost then
		gameStatusText.text = gameStatusText.text .. " | Lost!"
		gameStatusText:setFillColor(unpack(Color.lightRed))
	elseif Game.minesweeper.won then
		gameStatusText.text = gameStatusText.text .. " | Won!"
		gameStatusText:setFillColor(unpack(Color.white))
	end
end
local function showMap()
	if 0 < #mapRectangles then
		for i, rect in ipairs(mapRectangles) do
			rect:removeSelf()
			mapRectangles[i] = nil
		end
	end
	if 0 < #bombImages then
		for i, image in ipairs(bombImages) do
			image:removeSelf()
			bombImages[i] = nil
		end
	end
	if 0 < #tileTexts then
		for i, text in ipairs(tileTexts) do
			text:removeSelf()
			tileTexts[i] = nil
		end
	end
	local tileSize = 170
	local tileGap = 32
	for i = 1, #Game.minesweeper.map do
		local row = math.floor((i - 1) / Minesweeper.mapSize)
		local x = mainBox.x + mainBox.width / 2 + (i - row * 3) * (tileSize + tileGap)
		x = x - tileSize * Minesweeper.mapSize
		local y = mainBox.y + 100 + row * (tileSize + tileGap)
		if #backgroundRectangles < #Game.minesweeper.map then
			backgroundRectangles[#backgroundRectangles + 1] = display.newRect(afterGroup, x - 6, y - 6, tileSize + 6, tileSize + 6)
			backgroundRectangles[#backgroundRectangles]:setFillColor(unpack(Color.row))
		end
		mapRectangles[i] = display.newRect(afterGroup, x, y, tileSize, tileSize)
		mapRectangles[i]:setFillColor(rgb(26, 46, 68))
		mapRectangles[i]:addEventListener("tap", function(event)
			local clickResult = Minesweeper.onMapClick(i)
			if clickResult == 2 then
				local eventX = event.x
				local eventY = event.y
				showExplosion(event)
				for i = 1, 3 do
					timer.performWithDelay(120 * i, function()
						event.x = eventX + math.random(-40, 40)
						event.y = eventY + math.random(-40, 40)
						showExplosion(event)
					end)
				end
			end
			if clickResult == 3 then
				showBalancePlusText(Game.minesweeper.shownMap[i])
				for i = 1, 8 do
					timer.performWithDelay(math.random(1, 250), function()
						GUI.showAnimatedText(nil, "+", event.x + math.random(-50, 50), event.y + math.random(-50, 50), Color.darkGreen, 68)
					end)
				end
			end
			updateGameStatusText()
			updateButtons()
			updateTexts()
			showMap()
			return true
		end)
		if (Game.testMode or Game.minesweeper.won or Game.minesweeper.lost) and Minesweeper.hasBomb(i) then
			bombImages[#bombImages + 1] = display.newImageRect(afterGroup, "images/casino/bomb.png", tileSize - 10, tileSize - 10)
			bombImages[#bombImages].x = x
			bombImages[#bombImages].y = y
			bombImages[#bombImages].alpha = 0.12
		end
		if 0 < Game.minesweeper.shownMap[i] then
			if Minesweeper.hasBomb(i) then
				bombImages[#bombImages + 1] = display.newImageRect(afterGroup, "images/casino/bomb.png", tileSize - 10, tileSize - 10)
				bombImages[#bombImages].x = x
				bombImages[#bombImages].y = y
				mapRectangles[i].fill = Color.lightRed
			else
				tileTexts[#tileTexts + 1] = display.newText({
					parent = afterGroup,
					x = x + tileSize / 2,
					y = y + tileSize / 2,
					text = Game.minesweeper.shownMap[i],
					font = Font.counterstrike,
					fontSize = 80,
					align = "center"
				})
				tileTexts[#tileTexts].anchorX = 0.5
				tileTexts[#tileTexts].anchorY = 0.5
				FontOffset.setOffset(tileTexts[#tileTexts])
				mapRectangles[i].fill = Color.lightGreen
				while tileTexts[#tileTexts].width > tileSize - 20 do
					tileTexts[#tileTexts].size = tileTexts[#tileTexts].size - 4
				end
			end
		end
	end
end
local function showBeforeGroup()
	beforeGroup.alpha = 1
	afterGroup.alpha = 0
	if textMoved then
		betAmountChangeText.y = betAmountChangeText.y - textMoveValue
		balance.y = balance.y - textMoveValue
		betAmount.y = betAmount.y - textMoveValue
		balancePlusText.y = balancePlusText.y - textMoveValue
		statusText.y = statusText.y - textMoveValue
		yourBalanceText.y = yourBalanceText.y - textMoveValue
		betAmountText.y = betAmountText.y - textMoveValue
		textMoved = false
	end
	updateButtons()
end
local function showAfterGroup()
	beforeGroup.alpha = 0
	afterGroup.alpha = 1
	if not textMoved then
		betAmountChangeText.y = betAmountChangeText.y + textMoveValue
		balance.y = balance.y + textMoveValue
		betAmount.y = betAmount.y + textMoveValue
		balancePlusText.y = balancePlusText.y + textMoveValue
		statusText.y = statusText.y + textMoveValue
		yourBalanceText.y = yourBalanceText.y + textMoveValue
		betAmountText.y = betAmountText.y + textMoveValue
		textMoved = true
	end
	updateButtons()
	updateGameStatusText()
	showMap()
	updateTexts()
end
local function showBetAmountChangeText(amount)
	if amount == 0 then
		return
	end
	local minus = false
	local str = "+"
	if 0 < amount then
		betAmountChangeText:setFillColor(unpack(Color.green))
	else
		betAmountChangeText:setFillColor(unpack(Color.red))
		str = "@"
		minus = true
		amount = amount * -1
	end
	betAmountChangeText.text = str .. commaValue(amount)
	betAmountChangeText.alpha = 1
	betAmountChangeText.x = betAmount.x + betAmount.width + 40
	transition.fadeOut(betAmountChangeText, {time = 1000})
end
local function onVariantChange()
	for i = 1, #Minesweeper.variants do
		redVariantButtons[i]:show()
		greenVariantButtons[i]:hide()
		if Game.minesweeper.variant == i then
			redVariantButtons[i]:hide()
			greenVariantButtons[i]:show()
			statusText.text = "Difficulty: " .. Minesweeper.variants[i].name
		end
	end
end
function scene:create(event)
	sceneGroup = self.view
	mainBox = GUI.drawMainBox(sceneGroup, "Minesweeper")
	beforeGroup = display.newGroup()
	afterGroup = display.newGroup()
	sceneGroup:insert(beforeGroup)
	sceneGroup:insert(afterGroup)
	local lastY = mainBox.y + 50
	local beforeLastY = lastY
	local selectSideText = display.newText({
		parent = beforeGroup,
		x = mainBox.x + mainBox.width / 2,
		y = beforeLastY,
		text = "Select number of mines:",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	selectSideText.anchorX = 0.5
	selectSideText.anchorY = 0
	FontOffset.setOffset(selectSideText)
	beforeLastY = beforeLastY + 80
	for i = 1, #Minesweeper.variants do
		local buttonSize = 220
		local buttonPadding = 15
		local buttonX = mainBox.x + mainBox.width / 2 - #Minesweeper.variants / 2 * (buttonSize + buttonPadding) + (i - 1) * (buttonSize + buttonPadding)
		greenVariantButtons[i] = Button.create(beforeGroup, buttonX, beforeLastY, buttonSize, 120, Minesweeper.variants[i].mines, ButtonType.green, function(event)
		end, {fontSize = 100, blockTime = 100})
		redVariantButtons[i] = Button.create(beforeGroup, buttonX, beforeLastY, buttonSize, 120, Minesweeper.variants[i].mines, ButtonType.red, function(event)
			Game.minesweeper.variant = i
			onVariantChange()
		end, {fontSize = 100, blockTime = 100})
	end
	beforeLastY = beforeLastY + 180
	statusText = display.newText({
		parent = beforeGroup,
		x = mainBox.x + mainBox.width / 2,
		y = beforeLastY,
		text = "",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	statusText.anchorX = 0.5
	statusText.anchorY = 0
	FontOffset.setOffset(statusText)
	onVariantChange()
	gameStatusText = display.newText({
		parent = afterGroup,
		x = mainBox.x + mainBox.width / 2,
		y = mainBox.y + 725,
		text = "",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	gameStatusText.anchorX = 0.5
	gameStatusText.anchorY = 0
	FontOffset.setOffset(gameStatusText)
	gameStatusText:addEventListener("tap", function()
		Game.unlockAchievement("Secret IX")
	end)
	beforeLastY = beforeLastY + 90
	Button.create(beforeGroup, getCenterX(mainBox) - 500, beforeLastY, 1000, 130, "Start Game", ButtonType.green, function(event)
		if Game.minesweeper.betAmount < 100 then
			return GUI.showMessageBox("Info", "You need to bet at least 100 tickets to start the game.")
		end
		Minesweeper.start()
		showAfterGroup()
		showBalancePlusText(-Game.minesweeper.betAmount)
		updateTexts()
		return true
	end, {fontSize = 90, blockTime = 100})
	lastY = lastY + 90 + 70 + 400
	GUI.drawHorizontalLine(beforeGroup, mainBox.x + 10, lastY - 35, mainBox.width - 20)
	local fontSize = 56
	if detectSquareScreen() then
		fontSize = 52
	end
	yourBalanceText = display.newText({
		parent = sceneGroup,
		x = mainBox.x + 25,
		y = lastY,
		text = Lang.casino.yourBalance .. ":",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "left"
	})
	yourBalanceText.anchorX = 0
	yourBalanceText.anchorY = 0
	FontOffset.setOffset(yourBalanceText)
	balancePlusText = display.newText({
		parent = sceneGroup,
		x = yourBalanceText.x + 390 + 200,
		y = yourBalanceText.y,
		text = "",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	balancePlusText.anchorX = 0
	balancePlusText.anchorY = 0
	balancePlusText.alpha = 0
	betAmountText = display.newText({
		parent = sceneGroup,
		x = yourBalanceText.x,
		y = yourBalanceText.y + 80,
		text = Lang.roulette.betAmount .. ":",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	betAmountText.anchorX = 0
	betAmountText.anchorY = 0
	FontOffset.setOffset(betAmountText)
	balance = display.newText({
		parent = sceneGroup,
		x = yourBalanceText.x + 410,
		y = yourBalanceText.y,
		text = "",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	balance.anchorX = 0
	balance.anchorY = 0
	betAmount = display.newText({
		parent = sceneGroup,
		x = balance.x,
		y = betAmountText.y,
		text = "",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	betAmount.anchorX = 0
	betAmount.anchorY = 0
	betAmountChangeText = display.newText({
		parent = sceneGroup,
		x = yourBalanceText.x + 390 + 200,
		y = betAmountText.y,
		text = "",
		font = Font.counterstrike,
		fontSize = 54,
		align = "center"
	})
	betAmountChangeText.anchorX = 0
	betAmountChangeText.anchorY = 0
	betAmountChangeText.alpha = 0
	balance:setFillColor(unpack(Color.gold))
	betAmount:setFillColor(unpack(Color.gold))
	GUI.drawHorizontalLine(beforeGroup, mainBox.x + 10, yourBalanceText.y + 140, mainBox.width - 20)
	local valueButtonY = yourBalanceText.y + 180
	local valueButtonWidth = mainBox.width * 0.2
	local valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	local clearButton = GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "Clear", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		Game.roulette.balance = Game.roulette.balance + Game.minesweeper.betAmount
		Game.minesweeper.betAmount = 0
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = 1
		if Game.minesweeper.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.minesweeper.betAmount = Game.minesweeper.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+10", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = 10
		if Game.minesweeper.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.minesweeper.betAmount = Game.minesweeper.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+100", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = 100
		if Game.minesweeper.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.minesweeper.betAmount = Game.minesweeper.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	valueButtonY = valueButtonY + 80 + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1000", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = 1000
		if Game.minesweeper.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.minesweeper.betAmount = Game.minesweeper.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "1/2", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = math.floor(Game.minesweeper.betAmount / 2)
		Game.minesweeper.betAmount = Game.minesweeper.betAmount - addAmount
		Game.roulette.balance = Game.roulette.balance + addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "x2", ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = Game.minesweeper.betAmount
		if Game.minesweeper.betAmount + addAmount > betLimit or Game.minesweeper.betAmount < 0 then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.minesweeper.betAmount = Game.minesweeper.betAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(beforeGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, Lang.common.max, ButtonType.default, function(event)
		if Game.minesweeper.started then
			return
		end
		local addAmount = Game.roulette.balance
		if addAmount + Game.minesweeper.betAmount > betLimit then
			addAmount = betLimit - Game.minesweeper.betAmount
		end
		Game.minesweeper.betAmount = Game.minesweeper.betAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50)
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, valueButtonY + 80 + 40, mainBox.width - 20)
	GUI.drawHorizontalLine(afterGroup, mainBox.x + 10, valueButtonY - 40, mainBox.width - 20)
	local betButtonY = valueButtonY + 80 + 70
	local betButtonWidth = mainBox.width * 0.3
	returnButton = GUI.createButton(sceneGroup, getCenterX(mainBox) - betButtonWidth * 1.5 - 10, betButtonY, betButtonWidth * 3 + 20, 90, Lang.common.back, ButtonType.purple, function(event)
		composer.gotoScene("scenes.casino")
	end, 60)
	newGameButton = GUI.createButton(sceneGroup, getCenterX(mainBox) - betButtonWidth * 1.5 - 10, betButtonY, betButtonWidth * 3 + 20, 90, "New Game", ButtonType.green, function(event)
		Minesweeper.endGame()
		showBeforeGroup()
		updateTexts()
	end, 60)
	newGameButton.alpha = 0
	updateTexts()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
		updateTexts()
		if Game.minesweeper.started then
			showAfterGroup()
		else
			showBeforeGroup()
		end
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
