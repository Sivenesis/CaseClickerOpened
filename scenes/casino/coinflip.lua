local composer = require("composer")
local scene = composer.newScene()
local sceneGroup, mainBox, balance, betAmount, balancePlusText, betAmountChangeText, statusText, questionMark, actualBox
local coinflip = {
	started = false,
	winner = 0,
	bet = 0,
	finished = false
}
local coinImages = {}
local glowImage, selectedOption
local lastBet = 0
local betLimit = 250000
local function updateTexts()
	balance.text = commaValue(Game.roulette.balance) .. " " .. Lang.casino.tickets
	betAmount.text = commaValue(Game.roulette.coinflipBetAmount) .. " " .. Lang.casino.tickets
end
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
local function setCoinImagesPositions()
	for i = 1, 2 do
		coinImages[i].anchorX = 0.5
		coinImages[i].anchorY = 0.5
		coinImages[i].y = mainBox.y + 290 + 60
	end
	coinImages[1].x = mainBox.x + mainBox.width / 4
	coinImages[2].x = mainBox.x + mainBox.width / 4 * 3
end
local function resetCoinflip()
	coinflip.started = true
	Game.showingOverlay = true
	transition.fadeOut(glowImage, {time = 100})
	transition.fadeOut(statusText, {time = 500})
	timer.performWithDelay(100, function()
		transition.moveTo(coinImages[1], {
			x = mainBox.x + mainBox.width / 4,
			y = coinImages[1].y + 60,
			time = 600
		})
		transition.moveTo(coinImages[2], {
			x = mainBox.x + mainBox.width / 4 * 3,
			y = coinImages[2].y + 60,
			time = 600
		})
	end)
	timer.performWithDelay(300, function()
		transition.fadeIn(questionMark, {time = 500})
	end)
	timer.performWithDelay(800, function()
		coinflip.finished = false
		coinflip.started = false
		Game.showingOverlay = false
	end)
end
local function startDraw()
	coinflip.started = true
	Game.showingOverlay = true
	coinflip.winner = math.random(1, 2)
	coinImages[coinflip.winner]:toFront()
	transition.fadeOut(questionMark, {time = 400})
	transition.moveTo(coinImages[1], {
		x = mainBox.x + mainBox.width / 2,
		y = coinImages[1].y - 60,
		time = 1000
	})
	transition.moveTo(coinImages[2], {
		x = mainBox.x + mainBox.width / 2,
		y = coinImages[2].y - 60,
		time = 1000,
		onComplete = function()
			glowImage.x = coinImages[1].x + 6
			glowImage.y = coinImages[1].y
			transition.fadeIn(glowImage, {time = 400})
		end
	})
	timer.performWithDelay(1000, function()
		if coinflip.bet == coinflip.winner then
			statusText.text = Lang.coinflip.youHaveWon
			statusText:setFillColor(unpack(Color.green))
			Game.roulette.balance = Game.roulette.balance + lastBet * 2
			showBalancePlusText(lastBet * 2)
			StatisticManager.addStatistic("coinflipsWon")
			StatisticManager.addStatistic("ticketsWonInCoinflip", lastBet)
		else
			statusText.text = Lang.coinflip.youHaveLost
			statusText:setFillColor(unpack(Color.red))
			showBetAmountChangeText(-lastBet)
			StatisticManager.addStatistic("coinflipsLost")
			StatisticManager.addStatistic("ticketsLostInCoinflip", lastBet)
		end
		Game.roulette.ticketsToPlay = math.max(0, Game.roulette.ticketsToPlay - lastBet)
		Game.roulette.coinflipBetAmount = 0
		if lastBet <= Game.roulette.balance then
			Game.roulette.coinflipBetAmount = lastBet
			Game.roulette.balance = Game.roulette.balance - lastBet
		end
		updateTexts()
		transition.fadeIn(statusText, {time = 500})
		timer.performWithDelay(400, function()
			coinflip.started = false
			Game.showingOverlay = false
			coinflip.finished = true
		end)
	end)
end
function scene:create(event)
	sceneGroup = self.view
	mainBox = GUI.drawMainBox(sceneGroup, Lang.casino.coinflip)
	local lastY = mainBox.y + 50
	local selectSideText = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width / 2,
		y = lastY,
		text = Lang.coinflip.chooseYourSide .. ":",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	selectSideText.anchorX = 0.5
	selectSideText.anchorY = 0
	FontOffset.setOffset(selectSideText)
	questionMark = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width / 2,
		y = lastY + 250,
		text = "< ? >",
		font = Font.counterstrike,
		fontSize = 102,
		align = "center"
	})
	questionMark.anchorX = 0.5
	questionMark.anchorY = 0
	FontOffset.setOffset(questionMark)
	questionMark:setFillColor(unpack(Color.lightText))
	coinImages[1] = display.newImageRect(sceneGroup, "images/casino/ct.png", 307.2, 307.2)
	coinImages[2] = display.newImageRect(sceneGroup, "images/casino/tt.png", 307.2, 307.2)
	glowImage = display.newImageRect(sceneGroup, "images/casino/glow.png", 441.59999999999997, 441.59999999999997)
	glowImage.alpha = 0
	glowImage.anchorX = 0.5
	glowImage.anchorY = 0.5
	for i = 1, 2 do
		coinImages[i]:addEventListener("tap", function()
			if coinflip.started then
				return
			end
			if coinflip.finished then
				return resetCoinflip()
			end
			if Game.roulette.coinflipBetAmount == 0 then
				return GUI.showMessageBox(Lang.common.info, "You need to bet at least 1 ticket.")
			end
			lastBet = Game.roulette.coinflipBetAmount
			Game.roulette.coinflipBetAmount = 0
			Game.save()
			coinflip.bet = i
			coinflip.started = true
			timer.performWithDelay(100, function()
				startDraw()
			end)
		end)
	end
	setCoinImagesPositions()
	statusText = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width / 2,
		y = lastY + 430,
		text = "",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	statusText.anchorX = 0.5
	statusText.anchorY = 0
	FontOffset.setOffset(statusText)
	statusText.alpha = 0
	lastY = lastY + 90 + 70 + 400
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, lastY - 35, mainBox.width - 20)
	local fontSize = 56
	if detectSquareScreen() then
		fontSize = 52
	end
	local yourBalanceText = display.newText({
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
	local betAmountText = display.newText({
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
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, yourBalanceText.y + 140, mainBox.width - 20)
	local valueButtonY = yourBalanceText.y + 180
	local valueButtonWidth = mainBox.width * 0.2
	local valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	local clearButton = GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "Clear", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		Game.roulette.balance = Game.roulette.balance + Game.roulette.coinflipBetAmount
		Game.roulette.coinflipBetAmount = 0
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = 1
		if Game.roulette.coinflipBetAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+10", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = 10
		if Game.roulette.coinflipBetAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+100", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = 100
		if Game.roulette.coinflipBetAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	valueButtonY = valueButtonY + 80 + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1000", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = 1000
		if Game.roulette.coinflipBetAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "1/2", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = math.floor(Game.roulette.coinflipBetAmount / 2)
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount - addAmount
		Game.roulette.balance = Game.roulette.balance + addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "x2", ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = Game.roulette.coinflipBetAmount
		if Game.roulette.coinflipBetAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance or Game.roulette.coinflipBetAmount < 0 then
			return
		end
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, Lang.common.max, ButtonType.default, function(event)
		if coinflip.started then
			return
		end
		local addAmount = Game.roulette.balance
		if addAmount + Game.roulette.coinflipBetAmount > betLimit then
			addAmount = betLimit - Game.roulette.coinflipBetAmount
		end
		Game.roulette.coinflipBetAmount = Game.roulette.coinflipBetAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50)
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, valueButtonY + 80 + 40, mainBox.width - 20)
	local betButtonY = valueButtonY + 80 + 70
	local betButtonWidth = mainBox.width * 0.3
	local returnButton = GUI.createButton(sceneGroup, getCenterX(mainBox) - betButtonWidth * 1.5 - 10, betButtonY, betButtonWidth * 3 + 20, 90, Lang.common.back, ButtonType.purple, function(event)
		if coinflip.started then
			return
		end
		composer.gotoScene("scenes.casino")
	end, 60)
	updateTexts()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
		updateTexts()
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
