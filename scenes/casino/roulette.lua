local composer = require("composer")
local scene = composer.newScene()
local sceneGroup, mainBox, itemContainer, drawBackgroundOverlay, balance, betAmount, balancePlusText, betAmountChangeText, drawBackground, actualBox, selectedOption
local lastBet = 0
local draw = {
	started = false,
	screenItems = {},
	lastItem = nil
}
local nextSound = 1
local betLimit = 250000
local lastNumbersY = 0
local lastNumberLimit = 7
local lastNumbersXDistance = 130
local numberBoxes = {}
local function repositionNumbers()
	local startX = getCenterX(mainBox) - (#numberBoxes - 1) / 2 * lastNumbersXDistance
	for i = 1, #numberBoxes do
		numberBoxes[#numberBoxes + 1 - i].x = startX + (i - 1) * lastNumbersXDistance
	end
end
local function drawLastNumber(number, reposition)
	local group = display.newGroup()
	local path = "images/casino/"
	if number == 0 then
		path = path .. "green"
	elseif number <= 7 then
		path = path .. "red"
	else
		path = path .. "black"
	end
	path = path .. "_circle.png"
	local circle = display.newImageRect(group, path, 70, 70)
	if math.random(1, 7) == 1 then
		circle:addEventListener("tap", function()
			Game.unlockAchievement("Secret VII")
		end)
	end
	circle.anchorX = 0.5
	circle.anchorY = 0.5
	local text = display.newText({
		parent = group,
		x = 2,
		y = 2,
		text = number,
		font = Font.counterstrike,
		fontSize = 36,
		align = "center"
	})
	text.anchorX = 0.5
	text.anchorY = 0.5
	text:setFillColor(unpack(Color.white))
	FontOffset.setOffset(text)
	group.x = getCenterX(mainBox)
	group.y = lastNumbersY
	table.insert(numberBoxes, group)
	if #numberBoxes > lastNumberLimit then
		numberBoxes[1]:removeSelf()
		table.remove(numberBoxes, 1)
	end
	if reposition then
		repositionNumbers()
	end
	sceneGroup:insert(group)
	return group
end
local function addLastNumber(number)
	table.insert(Game.roulette.lastNumbers, number)
	if #Game.roulette.lastNumbers > 12 then
		table.remove(Game.roulette.lastNumbers, 1)
	end
	drawLastNumber(number, true)
end
local function addLastNumbers()
	for _, number in ipairs(Game.roulette.lastNumbers) do
		drawLastNumber(number)
	end
	repositionNumbers()
end
local function reinitDraw()
	draw.speed = math.random(4200, 4750)
	draw.speedDecrease = math.random(1030, 1320)
end
local function updateTexts()
	balance.text = commaValue(Game.roulette.balance) .. " " .. Lang.casino.tickets
	betAmount.text = commaValue(Game.roulette.betAmount) .. " " .. Lang.casino.tickets
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
local function drawNumberBox(sceneGroup, x, y, number)
	local group = display.newGroup()
	group.x = x
	group.y = y
	local rectWidth = drawBackground.width / 10
	local rectHeight = drawBackground.height * drawBackground.yScale * 0.5
	local rect = display.newRect(group, 0, 0, rectWidth, rectHeight)
	if number == 0 then
		rect:setFillColor(rgb(106, 156, 51))
	elseif number <= 7 then
		rect:setFillColor(rgb(181, 59, 64))
	else
		rect:setFillColor(rgb(54, 54, 54))
	end
	local text = display.newText({
		parent = group,
		x = rectWidth / 2,
		y = rectHeight / 2,
		text = number,
		font = Font.counterstrike,
		fontSize = 62,
		align = "center"
	})
	text.anchorX = 0.5
	text.anchorY = 0.5
	FontOffset.setOffset(text)
	sceneGroup:insert(group)
	itemContainer:insert(group)
	group.number = number
	if number == 0 then
		group.zero = true
	end
	return group
end
local function addNumberPack()
	local firstTable = shuffleTable({
		1,
		2,
		3,
		4,
		5,
		6,
		7
	})
	local secondTable = shuffleTable({
		8,
		9,
		10,
		11,
		12,
		13,
		14
	})
	local numbers = {}
	local even = math.random(0, 1) == 1
	for i = 1, 14 do
		if even then
			local i = math.random(1, #firstTable)
			table.insert(numbers, firstTable[i])
			table.remove(firstTable, i)
		else
			local i = math.random(1, #secondTable)
			table.insert(numbers, secondTable[i])
			table.remove(secondTable, i)
		end
		even = not even
	end
	local lastX = -drawBackground.width / 2
	if 0 < #draw.screenItems then
		lastX = draw.screenItems[#draw.screenItems].x
	end
	lastX = lastX + drawBackground.width / 10
	table.insert(draw.screenItems, drawNumberBox(sceneGroup, lastX, 0, 0))
	for i = 1, #numbers do
		lastX = lastX + drawBackground.width / 10
		table.insert(draw.screenItems, drawNumberBox(sceneGroup, lastX, 0, numbers[i]))
	end
end
local function setupDraw()
	for i = 1, 3 do
		addNumberPack()
	end
	local minusX = math.random(100, 1400)
	for i = 1, #draw.screenItems do
		draw.screenItems[i].x = draw.screenItems[i].x - minusX
	end
end
function rouletteDrawStep(event)
	if not draw.started then
		return
	end
	if draw.screenItems[1].x < -(drawBackground.width / 2) - drawBackground.width / 10 then
		draw.screenItems[1]:removeSelf()
		table.remove(draw.screenItems, 1)
		if #draw.screenItems < 12 then
			addNumberPack()
		end
	end
	drawBackgroundOverlay:toFront()
	local actualBox
	for i = 3, 8 do
		if draw.screenItems[i] and draw.screenItems[i].x <= -9 and draw.screenItems[i].x + draw.screenItems[i][1].width >= -9 then
			actualBox = draw.screenItems[i]
			break
		end
	end
	if draw.lastItem ~= actualBox and actualBox ~= nil then
		audio.play(Game.sounds.scrollSounds[nextSound], {
			channel = 5 + nextSound
		})
		nextSound = nextSound + 1
		if nextSound > #Game.sounds.scrollSounds then
			nextSound = 1
		end
	end
	draw.lastItem = actualBox
	if not actualBox and draw.speed < 30 then
		draw.speed = 30
	end
	for i = 1, #draw.screenItems do
		draw.screenItems[i].x = draw.screenItems[i].x - draw.speed * 0.015
	end
	local decrease = 0.015
	if draw.speed < 800 then
		decrease = 0.025
	elseif draw.speed < 1200 then
		decrease = 0.02
	elseif draw.speed < 3000 then
		decrease = 0.018
	end
	draw.speed = draw.speed - draw.speedDecrease * decrease
	draw.speedDecrease = draw.speedDecrease - 1
	if draw.speed <= 0 and actualBox then
		Game.showingOverlay = false
		draw.started = false
		local win = false
		local winMultiplier = 1
		Game.roulette.ticketsToPlay = math.max(0, Game.roulette.ticketsToPlay - lastBet)
		addLastNumber(actualBox.number)
		if selectedOption == 1 and actualBox.number <= 7 and actualBox.number ~= 0 then
			winMultiplier = 2
			win = true
		elseif selectedOption == 2 and actualBox.number == 0 then
			winMultiplier = 14
			win = true
		elseif selectedOption == 3 and 8 <= actualBox.number then
			winMultiplier = 2
			win = true
		end
		if win then
			Game.roulette.balance = Game.roulette.balance + lastBet * winMultiplier
			showBalancePlusText(lastBet * winMultiplier)
			StatisticManager.addStatistic("roulettesWon")
			StatisticManager.addStatistic("ticketsWonInRoulette", lastBet * winMultiplier - lastBet)
			Analytics.addEvent("Roulette:Win", lastBet * winMultiplier - lastBet)
		else
			showBetAmountChangeText(-lastBet)
			StatisticManager.addStatistic("roulettesLost")
			StatisticManager.addStatistic("ticketsLostInRoulette", lastBet)
			Analytics.addEvent("Roulette:Lose", lastBet)
		end
		Game.roulette.betAmount = 0
		if lastBet <= Game.roulette.balance then
			Game.roulette.betAmount = lastBet
			Game.roulette.balance = Game.roulette.balance - lastBet
		end
		updateTexts()
	end
end
function scene:create(event)
	sceneGroup = self.view
	mainBox = GUI.drawMainBox(sceneGroup, Lang.casino.roulette)
	drawBackground = display.newImageRect(sceneGroup, "images/drawbackground.png", 1116, 432)
	drawBackground.anchorX = 0.5
	drawBackground.anchorY = 0
	drawBackground.x = getCenterX(mainBox)
	drawBackground.y = mainBox.y + 50
	drawBackground.width = mainBox.width * 0.95
	drawBackground.yScale = 0.7
	itemContainer = display.newContainer(sceneGroup, drawBackground.width - 24, drawBackground.height * 2)
	itemContainer:translate(drawBackground.x - drawBackground.width * 0.5 + 20, drawBackground.y - drawBackground.height * drawBackground.yScale - 50)
	drawBackgroundOverlay = display.newImageRect(sceneGroup, "images/drawbackgroundover.png", 1116, 432)
	drawBackgroundOverlay.x = drawBackground.x
	drawBackgroundOverlay.y = drawBackground.y
	drawBackgroundOverlay.width = mainBox.width * 0.95
	drawBackgroundOverlay.anchorX = 0.5
	drawBackgroundOverlay.anchorY = 0
	drawBackgroundOverlay.yScale = 0.7
	local pointer = display.newLine(sceneGroup, drawBackground.x, drawBackground.y + 14, drawBackground.x, drawBackground.y + drawBackground.height * drawBackground.yScale - 18)
	pointer:setStrokeColor(rgb(111, 78, 29))
	pointer.strokeWidth = 3
	local lastY = drawBackground.y + drawBackground.height * drawBackground.yScale
	local lastColorsBg = display.newImageRect(sceneGroup, "images/drawbackground.png", 1116, 100.8)
	lastColorsBg.width = mainBox.width * 0.95
	lastColorsBg.anchorX = 0.5
	lastColorsBg.anchorY = 0
	lastColorsBg.x = getCenterX(mainBox)
	lastColorsBg.y = lastY
	lastNumbersY = lastColorsBg.y + lastColorsBg.height / 2
	lastNumberLimit = math.floor((lastColorsBg.width - 40) / lastNumbersXDistance)
	lastY = lastY + 90 + 70
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, lastY - 35, mainBox.width - 20)
	local fontSize = 56
	if detectSquareScreen() then
		fontSize = 52
	end
	local yourBalanceText = display.newText({
		parent = sceneGroup,
		x = drawBackground.x - drawBackground.width / 2 + 5,
		y = lastY,
		text = Lang.casino.yourBalance .. ":",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
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
		if draw.started then
			return
		end
		Game.roulette.balance = Game.roulette.balance + Game.roulette.betAmount
		Game.roulette.betAmount = 0
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1", ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = 1
		if Game.roulette.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.betAmount = Game.roulette.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+10", ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = 10
		if Game.roulette.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.betAmount = Game.roulette.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+100", ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = 100
		if Game.roulette.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.betAmount = Game.roulette.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = getCenterX(mainBox) - valueButtonWidth * 2 - 20
	valueButtonY = valueButtonY + 80 + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "+1000", ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = 1000
		if Game.roulette.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.balance = Game.roulette.balance - addAmount
		Game.roulette.betAmount = Game.roulette.betAmount + addAmount
		updateTexts()
	end, 50, {blockTime = 100, callbackAsHoldCallback = true})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "1/2", ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = math.floor(Game.roulette.betAmount / 2)
		Game.roulette.betAmount = Game.roulette.betAmount - addAmount
		Game.roulette.balance = Game.roulette.balance + addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, "x2", ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = Game.roulette.betAmount
		if Game.roulette.betAmount + addAmount > betLimit then
			return
		end
		if addAmount > Game.roulette.balance then
			return
		end
		Game.roulette.betAmount = Game.roulette.betAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50, {blockTime = 100})
	valueButtonX = valueButtonX + valueButtonWidth + 10
	GUI.createButton(sceneGroup, valueButtonX, valueButtonY, valueButtonWidth, 80, Lang.common.max, ButtonType.default, function(event)
		if draw.started then
			return
		end
		local addAmount = Game.roulette.balance
		if addAmount + Game.roulette.betAmount > betLimit then
			addAmount = betLimit - Game.roulette.betAmount
		end
		Game.roulette.betAmount = Game.roulette.betAmount + addAmount
		Game.roulette.balance = Game.roulette.balance - addAmount
		updateTexts()
	end, 50)
	GUI.drawHorizontalLine(sceneGroup, mainBox.x + 10, valueButtonY + 80 + 40, mainBox.width - 20)
	local betButtonY = valueButtonY + 80 + 70
	local betButtonWidth = mainBox.width * 0.3
	local betButtonX = getCenterX(mainBox) - betButtonWidth * 1.5 - 10
	local oneToSeven = GUI.createButton(sceneGroup, betButtonX, betButtonY, betButtonWidth, 120, Lang.roulette.oneToSeven, ButtonType.red, function(event)
		if draw.started then
			return
		end
		if Game.roulette.betAmount <= 0 then
			return GUI.showMessageBox(Lang.common.info, Lang.roulette.noTicketsMsg)
		end
		lastBet = Game.roulette.betAmount
		Game.roulette.betAmount = 0
		Game.save()
		reinitDraw()
		selectedOption = 1
		Game.showingOverlay = true
		draw.started = true
	end, 60)
	betButtonX = getCenterX(mainBox) - betButtonWidth / 2
	local zeroButton = GUI.createButton(sceneGroup, betButtonX, betButtonY, betButtonWidth, 120, "0", ButtonType.green, function(event)
		if draw.started then
			return
		end
		if Game.roulette.betAmount <= 0 then
			return GUI.showMessageBox(Lang.common.info, Lang.roulette.noTicketsMsg)
		end
		lastBet = Game.roulette.betAmount
		Game.roulette.betAmount = 0
		Game.save()
		reinitDraw()
		selectedOption = 2
		Game.showingOverlay = true
		draw.started = true
	end, 60)
	betButtonX = getCenterX(mainBox) + betButtonWidth * 0.5 + 10
	local eightToThirteen = GUI.createButton(sceneGroup, betButtonX, betButtonY, betButtonWidth, 120, Lang.roulette.eightToFourteen, ButtonType.black, function(event)
		if draw.started then
			return
		end
		if Game.roulette.betAmount <= 0 then
			return GUI.showMessageBox(Lang.common.info, Lang.roulette.noTicketsMsg)
		end
		lastBet = Game.roulette.betAmount
		Game.roulette.betAmount = 0
		Game.save()
		reinitDraw()
		selectedOption = 3
		Game.showingOverlay = true
		draw.started = true
	end, 60)
	local returnButton = GUI.createButton(sceneGroup, getCenterX(mainBox) - betButtonWidth * 1.5 - 10, betButtonY + 120 + 15, betButtonWidth * 3 + 20, 90, Lang.common.back, ButtonType.purple, function(event)
		if draw.started then
			return
		end
		composer.gotoScene("scenes.casino")
	end, 60)
	setupDraw()
	updateTexts()
	addLastNumbers()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		Runtime:addEventListener("enterFrame", rouletteDrawStep)
	elseif phase == "did" then
		updateTexts()
		reinitDraw()
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("enterFrame", rouletteDrawStep)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
