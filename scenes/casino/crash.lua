local CrashView = require("classes.CrashView")
local scene = composer.newScene()
local mainBox, crashView, betAmountChangeText, betAmount, balancePlusText, yourBalanceText, betAmountText
local betLimit = 200000
local minimumBetValue = 100
local function updateTexts()
	balance.text = commaValue(Game.roulette.balance) .. " " .. Lang.casino.tickets
	betAmount.text = commaValue(Game.crash.betAmount) .. " " .. Lang.casino.tickets
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
local function showBetAmountPlusText(amount)
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
	betAmountChangeText.x = balance.x + balance.width + 40
	transition.fadeOut(betAmountChangeText, {time = 1000})
end
local lastTime, lastUpdate
local function onEnterFrameCrash(event)
	if not lastTime then
		lastTime = system.getTimer()
	end
	local dt = system.getTimer() - lastTime
	if crashView.started and (not lastUpdate or system.getTimer() - lastUpdate >= 50) then
		crashView:update()
		lastUpdate = system.getTimer()
	end
	lastTime = system.getTimer()
	return true
end
function scene:updateButtons()
	self.stopButton:hide()
	self.newGameButton:hide()
	self.returnButton:hide()
	if crashView.started then
		self.stopButton:show()
	else
		self.newGameButton:show()
		self.returnButton:show()
	end
end
function scene:drawBalanceTexts()
	local sceneGroup = self.view
	local lastY = 740
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, lastY - 35, mainBox.width - 20)
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
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, yourBalanceText.y + 140, mainBox.width - 20)
end
function scene:drawValueButtons()
	local sceneGroup = self.view
	local valueButtonY = yourBalanceText.y + 180
	local valueButtonWidth = mainBox.width * 0.2
	local valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	local clearButton = GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "Clear", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		Game.roulette.balance = Game.roulette.balance + Game.crash.betAmount
		Game.crash.betAmount = 0
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = 1
		if Game.crash.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.crash.betAmount = Game.crash.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+10", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = 10
		if Game.crash.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.crash.betAmount = Game.crash.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+100", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = 100
		if Game.crash.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.crash.betAmount = Game.crash.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	valueButtonY = valueButtonY + 80 + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1000", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = 1000
		if Game.crash.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.crash.betAmount = Game.crash.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "1/2", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = math.floor(Game.crash.betAmount / 2)
		Game.crash.betAmount = Game.crash.betAmount - addAmount
		Game.roulette.balance = Game.roulette.balance + addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "x2", ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = Game.crash.betAmount
		if Game.crash.betAmount + addAmount > betLimit or Game.crash.betAmount < 0 then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.crash.betAmount = Game.crash.betAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, Lang.common.max, ButtonType.default, function(event)
		if crashView.started then
			return
		end
		local addAmount = Game.roulette.balance
		if addAmount + Game.crash.betAmount > betLimit then
			addAmount = betLimit - Game.crash.betAmount
		end
		Game.crash.betAmount = Game.crash.betAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50)
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, valueButtonY + 80 + 40, mainBox.width - 20)
	local buttonY = valueButtonY + 80 + 70
	local buttonWidth = mainBox.width * 0.45
	self.returnButton = Button.create(sceneGroup, getCenterX(mainBox) + 5, buttonY, buttonWidth, 95, Lang.common.back, ButtonType.purple, function(event)
		if crashView.started then
			return true
		end
		composer.gotoScene("scenes.casino")
	end, {fontSize = 60, blockTime = 250})
	self.newGameButton = Button.create(sceneGroup, getCenterX(mainBox) - buttonWidth - 5, buttonY, buttonWidth, 95, "New Game", ButtonType.green, function(event)
		if crashView.started then
			return true
		end
		if Game.crash.betAmount < 100 then
			return GUI.showMessageBox("Info", "You need to bet at least 100 tickets to start the game.")
		end
		local lastBet = Game.crash.betAmount
		showBalancePlusText(-Game.crash.betAmount)
		Game.roulette.ticketsToPlay = math.max(0, Game.roulette.ticketsToPlay - Game.crash.betAmount)
		Game.showingOverlay = true
		crashView:start(function()
			Game.showingOverlay = false
			StatisticManager.addStatistic("crashProfit", -Game.crash.betAmount)
			Game.crash.betAmount = 0
			if lastBet <= Game.roulette.balance then
				self:updateButtons()
				Game.crash.betAmount = lastBet
				Game.roulette.balance = Game.roulette.balance - lastBet
				showBalancePlusText(-Game.crash.betAmount)
			end
			self:updateButtons()
			updateTexts()
		end)
		self:updateButtons()
	end, {fontSize = 60, blockTime = 250})
	self.stopButton = Button.create(sceneGroup, getCenterX(mainBox) - buttonWidth - 5, buttonY, buttonWidth * 2, 95, "Stop!", ButtonType.pink, function(event)
		if not crashView.started then
			self:updateButtons()
			return true
		end
		local addMultiplier = math.round(crashView:stop() * 100) / 100
		self:updateButtons()
		local profit = math.round(Game.crash.betAmount * addMultiplier) - Game.crash.betAmount
		StatisticManager.addStatistic("crashProfit", profit)
		showBetAmountPlusText(profit)
		crashView:showSmallText("Profit: " .. commaValue(profit) .. " tickets")
		Game.crash.betAmount = math.round(Game.crash.betAmount * addMultiplier)
		if Game.crash.betAmount > betLimit then
			Game.roulette.balance = Game.roulette.balance + (Game.crash.betAmount - betLimit)
			Game.crash.betAmount = betLimit
		end
		updateTexts()
		Game.showingOverlay = false
	end, {fontSize = 60, blockTime = 250})
end
function scene:create(event)
	local sceneGroup = self.view
	mainBox = GUI.drawMainBox(sceneGroup, "Crash Game")
	crashView = CrashView.create()
	local crashViewWidth = mainBox.width * 0.9
	local crashViewHeight = 550
	crashView:draw(sceneGroup, getCenterX(mainBox) - crashViewWidth / 2, mainBox.y + 30, crashViewWidth, crashViewHeight)
	self:drawBalanceTexts()
	scene:drawValueButtons()
	updateTexts()
	self:updateButtons()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		if Game.crash.betAmount > betLimit then
			Game.crash.betAmount = betLimit
			updateTexts()
		end
		Menu.show()
		Runtime:addEventListener("enterFrame", onEnterFrameCrash)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("enterFrame", onEnterFrameCrash)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
