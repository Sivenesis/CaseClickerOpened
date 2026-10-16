local composer = require("composer")
local scene = composer.newScene()
local amount = 0
local ticketCount, withdrawAmount
local withdrawLimit = 5000000
local function updateTexts()
	ticketCount.text = commaValue(Game.roulette.balance - amount)
	withdrawAmount.text = commaValue(amount)
end
local function changeWithdrawAmount(value)
	local balanceLeft = Game.roulette.balance - amount
	if value == 0 then
		return false
	end
	if 0 < value and 0 <= balanceLeft - value then
		if amount + value > withdrawLimit then
			return false
		end
		amount = amount + value
		return true
	end
	if value < 0 and -value <= amount then
		amount = amount + value
		return true
	end
	return false
end
function scene:create(event)
	local sceneGroup = self.view
	local params = event.params
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.7)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * 0.175, display.safeActualContentWidth * 0.9, display.safeActualContentHeight * 0.65, Lang.casino.withdraw)
	mainBox:setFillColor(rgb(22, 30, 40))
	local lastY = mainBox.y + 90
	if isAndroid() then
		lastY = lastY + 50
	end
	local mainText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = lastY,
		text = Lang.casino.withdrawQuestion,
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 58,
		align = "center"
	})
	mainText.anchorX = 0.5
	mainText.anchorY = 0
	FontOffset.setOffset(mainText)
	lastY = lastY + 120
	local yourBalanceText = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width * 0.3,
		y = lastY,
		text = Lang.casino.yourBalance .. ":",
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 60,
		align = "center"
	})
	yourBalanceText.anchorX = 0.5
	yourBalanceText:setFillColor(unpack(Color.gold))
	ticketCount = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width * 0.3,
		y = lastY + 70,
		text = 0,
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 60,
		align = "center"
	})
	ticketCount.anchorX = 0.5
	local withdrawAmountText = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width * 0.7,
		y = lastY,
		text = Lang.casino.withdrawAmount .. ":",
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 60,
		align = "center"
	})
	withdrawAmountText.anchorX = 0.5
	withdrawAmountText:setFillColor(unpack(Color.gold))
	withdrawAmount = display.newText({
		parent = sceneGroup,
		x = mainBox.x + mainBox.width * 0.7,
		y = lastY + 70,
		text = 0,
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 60,
		align = "center"
	})
	withdrawAmount.anchorX = 0.5
	lastY = lastY + 180
	local valueButtonY = lastY
	local valueButtonWidth = mainBox.width * 0.2
	local valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	local clearButton = GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "Clear", ButtonType.default, function(event)
		amount = 0
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1", ButtonType.default, function(event)
		local addAmount = 1
		changeWithdrawAmount(addAmount)
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+10", ButtonType.default, function(event)
		local addAmount = 10
		changeWithdrawAmount(addAmount)
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+100", ButtonType.default, function(event)
		local addAmount = 100
		changeWithdrawAmount(addAmount)
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	valueButtonY = valueButtonY + 80 + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1000", ButtonType.default, function(event)
		local addAmount = 1000
		changeWithdrawAmount(addAmount)
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "1/2", ButtonType.default, function(event)
		local addAmount = math.floor(amount / 2)
		changeWithdrawAmount(-addAmount)
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "x2", ButtonType.default, function(event)
		local addAmount = amount
		changeWithdrawAmount(addAmount)
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, Lang.common.max, ButtonType.default, function(event)
		local addAmount = Game.roulette.balance - amount
		if addAmount + amount > withdrawLimit then
			addAmount = withdrawLimit - amount
		end
		changeWithdrawAmount(addAmount)
		updateTexts()
	end, 50)
	GUI.createButton(sceneGroup, getCenterX(mainBox) - 300 - 300 - 10, mainBox.y + mainBox.height - 120 - 30, 600, 110, Lang.casino.withdraw, ButtonType.green, function()
		if amount < 100 then
			return GUI.showMessageBox(Lang.common.info, Lang.casino.withdrawMinMsg:gsub("{1}", "100"))
		end
		GUI.showMessageBox(Lang.casino.withdrawing, Lang.common.pleaseWait .. "...", false)
		Game.roulette.balance = Game.roulette.balance - amount
		if params.okButtonCallback then
			params.okButtonCallback()
		end
		timer.performWithDelay(200, function()
			local newItems = EquipmentManager.getItemsWorth(amount / 10)
			EquipmentManager.returnItems(newItems, true)
			table.sort(newItems, function(a, b)
				return Game.getItemPrice(a) > Game.getItemPrice(b)
			end)
			composer.gotoScene("scenes.itemlist", {
				params = {
					firstText = Lang.casino.ticketsWithdrawn .. "!",
					items = newItems,
					okButtonCallback = function()
						composer.gotoScene("scenes.casino")
					end
				}
			})
			Game.recalculateEquipmentWorth()
		end)
	end, 60, {blockTime = 600})
	GUI.createButton(sceneGroup, getCenterX(mainBox) - 300 + 300 + 10, mainBox.y + mainBox.height - 120 - 30, 600, 110, Lang.common.exit, ButtonType.red, function()
		composer.hideOverlay()
	end, 60)
	FontOffset.setOffset(mainText)
	updateTexts()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
