local composer = require("composer")
local ProgressBar = require("gui.progressbar")
local scene = composer.newScene()
local balanceText, clickGainText, perSecondGainText, searchGainText, searchPerSecondText, progressBar, cashBagImage, caseImage, getBoxButton, coinContainer, caseContainer, cashBagTrigger, caseTrigger, sheetOptions, explosionSheet, sequenceData
local lastSecond = 0
local tapsPerSecond = 0
local box
local combo = {
	coinValue = 1,
	caseValue = 1,
	lastCoinClick = os.time(),
	lastCaseClick = os.time(),
	coinText = nil,
	coinValueText = nil,
	coinBackground = nil,
	caseText = nil,
	caseValueText = nil,
	coinClickStreak = 0,
	caseClickStreak = 0,
	showingCoinText = false,
	hidingCoinText = false,
	showingCaseText = false,
	hidingCaseText = false
}
local function showCoinComboText()
	if combo.coinText.alpha >= 1 or combo.hidingCoinText then
		combo.showingCoinText = false
		return
	end
	combo.showingCoinText = true
	combo.coinText.alpha = combo.coinText.alpha + 0.05
	combo.coinValueText.alpha = combo.coinValueText.alpha + 0.05
	timer.performWithDelay(25, showCoinComboText)
end
local function hideCoinComboText()
	if combo.coinText.alpha <= 0 then
		combo.hidingCoinText = false
		return
	end
	combo.hidingCoinText = true
	combo.coinText.alpha = combo.coinText.alpha - 0.05
	combo.coinValueText.alpha = combo.coinValueText.alpha - 0.05
	timer.performWithDelay(25, hideCoinComboText)
end
local function showCaseComboText()
	if combo.caseText.alpha >= 1 or combo.hidingCaseText then
		combo.showingCoinText = false
		return
	end
	combo.showingCaseText = true
	combo.caseText.alpha = combo.caseText.alpha + 0.05
	combo.caseValueText.alpha = combo.caseValueText.alpha + 0.05
	timer.performWithDelay(25, showCaseComboText)
end
local function hideCaseComboText()
	if combo.caseText.alpha <= 0 then
		combo.hidingCaseText = false
		return
	end
	combo.hidingCaseText = true
	combo.caseText.alpha = combo.caseText.alpha - 0.05
	combo.caseValueText.alpha = combo.caseValueText.alpha - 0.05
	timer.performWithDelay(25, hideCaseComboText)
end
local function resetCombo()
	combo.caseValue = 1
	combo.coinValue = 1
	combo.lastCoinClick = os.time()
	combo.lastCaseClick = os.time()
	combo.caseClickStreak = 0
	combo.coinClickStreak = 0
	combo.coinText.alpha = 0
	combo.coinValueText.alpha = 0
	combo.caseText.alpha = 0
	combo.caseValueText.alpha = 0
end
local function onComboClick(caseCombo)
	local valueType = "coinValue"
	local streakType = "coinClickStreak"
	local tapsToCombo = Game.others.tapsToCombo + 2
	if caseCombo then
		combo.lastCaseClick = os.time()
		valueType = "caseValue"
		streakType = "caseClickStreak"
		combo.caseClickStreak = combo.caseClickStreak + 1
		tapsToCombo = Game.others.tapsToCombo - 2
	else
		combo.lastCoinClick = os.time()
		combo.coinClickStreak = combo.coinClickStreak + 1
	end
	combo[valueType] = 1 + math.abs(math.floor(combo[streakType] / tapsToCombo)) / 100
	if 1.01 <= combo[valueType] and combo.coinText.alpha == 0 then
		if caseCombo then
			showCaseComboText()
		else
			showCoinComboText()
		end
	end
	if 5 < combo[valueType] and Game.others.comboLimit then
		combo[valueType] = 5
	end
	if 10 < combo[valueType] then
		combo[valueType] = 10
	end
	if combo[valueType] > StatisticManager.getStatistic("maximumCombo") then
		StatisticManager.setStatistic("maximumCombo", combo[valueType])
	end
	if 1.01 <= combo[valueType] then
		if caseCombo then
			combo.caseValueText.text = "x" .. formatPrice(combo[valueType])
			if combo[valueType] < 2 then
				combo.caseValueText.xScale = combo[valueType]
				combo.caseValueText.yScale = combo[valueType]
			end
		else
			combo.coinValueText.text = "x" .. formatPrice(combo[valueType])
			if combo[valueType] < 2 then
				combo.coinValueText.xScale = combo[valueType]
				combo.coinValueText.yScale = combo[valueType]
			end
		end
	end
end
local function updateProgressBar()
	progressBar:setProgress(Game.searchProgress / Game.searchBarLimit * 100)
	progressBar:setText(formatPrice(Game.searchProgress) .. "%")
	if Game.searchProgress >= 100 and getBoxButton and getBoxButton.alpha ~= 1 then
		getBoxButton.alpha = 1
		searchGainText.alpha = 0
		searchPerSecondText.alpha = 0
	end
	if Game.searchProgress < 100 and searchGainText and searchGainText.alpha ~= 1 then
		getBoxButton.alpha = 0
		searchGainText.alpha = 1
		searchPerSecondText.alpha = 1
	end
end
local function updateBalanceText()
	balanceText.text = "$" .. formatPrice(math.floor(Game.money * 100) / 100)
end
local function updateSearchText()
	searchPerSecondText.text = Game.searchPerSecond * Game.getTapPowerMultiplier() .. "% " .. Lang.main.persecond
	searchGainText.text = Game.clickSearchGain .. "% " .. Lang.main.pertap
end
local function updateMoneyText()
	if not balanceText then
		return
	end
	updateBalanceText()
	clickGainText.text = "$" .. Game.clickMoneyGain * Game.getTapPowerMultiplier() .. " " .. Lang.main.pertap
	perSecondGainText.text = "$" .. Game.moneyPerSecond .. " " .. Lang.main.persecond
end
local workingLoops = 0
function updateLoop()
	if composer.getSceneName("current") ~= "scenes.main" or 1 < workingLoops then
		workingLoops = workingLoops - 1
		return
	end
	updateBalanceText()
	updateProgressBar()
	if os.time() - combo.lastCaseClick >= 3 and combo.caseText.alpha == 1 then
		combo.caseValue = 0
		combo.caseClickStreak = 0
		hideCaseComboText()
	end
	if 3 <= os.time() - combo.lastCoinClick and combo.coinText.alpha == 1 then
		combo.coinValue = 0
		combo.coinClickStreak = 0
		hideCoinComboText()
	end
	timer.performWithDelay(500, updateLoop)
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
	local scale = (50 + math.random(80, 120)) / 100
	explosion.xScale = scale
	explosion.yScale = scale
	explosion:play()
	explosion:addEventListener("sprite", function(event)
		if event.phase == "ended" then
			explosion:removeSelf()
		end
	end)
end
local coins = {}
local cases = {}
function createFallingCoin(coinType)
	if Game.settings.enableAnimations == false then
		return
	end
	local coin
	if coinType == FallingCoin.tap then
		coin = display.newImageRect(coinContainer, "images/smallcoin2.png", 60, 60)
	elseif coinType == FallingCoin.critical then
		coin = display.newImageRect(coinContainer, "images/smallcoin3.png", 60, 60)
	else
		coin = display.newImageRect(coinContainer, "images/smallcoin.png", 60, 60)
	end
	coin.x = math.random(-coinContainer.width / 2 + coin.width / 2, coinContainer.width / 2 - coin.width / 2) + math.random(-40, 40)
	coin.y = -coinContainer.height / 2 - coin.height
	coin.speed = math.random(160, 360) / 100
	coin.rotationSpeed = (math.random(90, 110) / 100 - 1) * 10
	coin.anchorX = 0.5
	coin.anchorY = 0.5
	local scale = math.random(80, 100) / 100
	coin.xScale = scale
	coin.yScale = scale
	table.insert(coins, coin)
end
function createFallingCase()
	if Game.settings.enableAnimations == false then
		return
	end
	local image = Game.cases[Game.getRandomCaseId()].image
	image = image:sub(0, -5) .. "_60.png"
	local case = display.newImageRect(caseContainer, "images/cases/" .. image, 60, 45)
	case.x = math.random(-caseContainer.width / 2 + case.width / 2, caseContainer.width / 2 - case.width / 2) + math.random(-40, 40)
	case.y = -caseContainer.height / 2 - case.height
	case.speed = math.random(160, 360) / 100
	case.rotationSpeed = (math.random(90, 110) / 100 - 1) * 10
	case.anchorX = 0.5
	case.anchorY = 0.5
	local scale = math.random(80, 100) / 100
	case.xScale = scale
	case.yScale = scale
	table.insert(cases, case)
end
local touchingCashBag = false
local touchingCase = false
function onEnterFrameMain(event)
	if composer.getSceneName("current") ~= "scenes.main" then
		Runtime:removeEventListener("enterFrame", onEnterFrameMain)
		return true
	end
	if touchingCashBag and cashBagImage.xScale >= 0.9 then
		cashBagImage.xScale = cashBagImage.xScale - 0.005
		cashBagImage.yScale = cashBagImage.yScale - 0.005
	end
	if not touchingCashBag and cashBagImage.xScale < 1 then
		cashBagImage.xScale = cashBagImage.xScale + 0.005
		cashBagImage.yScale = cashBagImage.yScale + 0.005
	end
	if touchingCase and caseImage.xScale >= 0.9 then
		caseImage.xScale = caseImage.xScale - 0.005
		caseImage.yScale = caseImage.yScale - 0.005
	end
	if not touchingCase and caseImage.xScale < 1 then
		caseImage.xScale = caseImage.xScale + 0.005
		caseImage.yScale = caseImage.yScale + 0.005
	end
	for i = #coins, 1, -1 do
		if coins[i].y then
			coins[i].y = coins[i].y + coins[i].speed
			coins[i]:rotate(coins[i].rotationSpeed)
			if coins[i].y > coinContainer.height then
				coins[i]:removeSelf()
				table.remove(coins, i)
			end
		else
			if coins[i].removeSelf then
				coins[i].removeSelf()
			end
			table.remove(coins, i)
		end
	end
	for i = #cases, 1, -1 do
		if cases[i].y then
			cases[i].y = cases[i].y + cases[i].speed
			cases[i]:rotate(cases[i].rotationSpeed)
			if cases[i].y > caseContainer.height then
				cases[i]:removeSelf()
				table.remove(cases, i)
			end
		else
			if cases[i].removeSelf then
				cases[i].removeSelf()
			end
			table.remove(cases, i)
		end
	end
end
function onTap()
	if lastSecond ~= math.floor(system.getTimer() / 1000) then
		lastSecond = math.floor(system.getTimer() / 1000)
		tapsPerSecond = 0
	end
	tapsPerSecond = tapsPerSecond + 1
	if tapsPerSecond > StatisticManager.getStatistic("maximumTapsPerSecond") then
		StatisticManager.setStatistic("maximumTapsPerSecond", tapsPerSecond)
	end
end
function onCashBagClick(event)
	if Game.showingOverlay then
		return
	end
	if event.phase ~= "began" then
		if event.phase == "ended" then
			touchingCashBag = false
			display.currentStage:setFocus(nil)
		end
		return
	end
	display.currentStage:setFocus(cashBagTrigger)
	touchingCashBag = true
	onTap()
	if 13 < tapsPerSecond then
		return
	end
	onComboClick()
	local moneyGain = Game.clickMoneyGain * Game.getTapPowerMultiplier() * combo.coinValue
	local criticalHit = math.random(1, 1000) <= Game.criticalHitChance * 10
	local coinCount = math.min(math.floor(moneyGain * 100), 3)
	for i = 1, coinCount do
		if criticalHit then
			createFallingCoin(FallingCoin.critical)
		else
			createFallingCoin(FallingCoin.tap)
		end
	end
	audio.play(Game.sounds.click, {
		channel = audio.findFreeChannel()
	})
	StatisticManager.addStatistic("totalClicks")
	StatisticManager.addStatistic("moneyClicks")
	if criticalHit then
		moneyGain = moneyGain * 2
		Game.addCriticalTap()
	else
		Game.criticalStreak = 0
	end
	if Game.explosions then
		showExplosion(event)
	elseif criticalHit then
		GUI.showAnimatedText(event.target.parent, "$" .. moneyGain, event.x * (math.random(95, 105) / 100), event.y * (math.random(90, 95) / 100), Color.gold, math.random(90, 98))
	else
		GUI.showAnimatedText(event.target.parent, "$" .. moneyGain, event.x * (math.random(95, 105) / 100), event.y * (math.random(90, 95) / 100))
	end
	Game.addMoney(moneyGain, "Main", "Money Tap")
	updateMoneyText()
end
function onCaseClick(event)
	if Game.showingOverlay then
		return
	end
	if event.phase ~= "began" then
		if event.phase == "ended" then
			touchingCase = false
			display.currentStage:setFocus(nil)
		end
		return
	end
	display.currentStage:setFocus(caseTrigger)
	touchingCase = true
	if Game.searchProgress >= Game.searchBarLimit then
		return
	end
	onTap()
	onComboClick(true)
	if 13 < tapsPerSecond then
		return
	end
	createFallingCase()
	audio.play(Game.sounds.click, {
		channel = audio.findFreeChannel()
	})
	StatisticManager.addStatistic("totalClicks")
	StatisticManager.addStatistic("searchClicks")
	local searchGain = Game.clickSearchGain * Game.getTapPowerMultiplier() * combo.caseValue
	local criticalHit = math.random(1, 1000) <= Game.criticalHitChance * 10
	if criticalHit then
		searchGain = searchGain * 2
		Game.addCriticalTap()
	else
		Game.criticalStreak = 0
	end
	if Game.explosions then
		showExplosion(event)
	elseif criticalHit then
		GUI.showAnimatedText(event.target.parent, "+" .. searchGain .. "%", event.x * (math.random(95, 105) / 100), event.y * (math.random(90, 95) / 100), Color.gold, math.random(90, 98))
	else
		GUI.showAnimatedText(event.target.parent, "+" .. searchGain .. "%", event.x * (math.random(95, 105) / 100), event.y * (math.random(90, 95) / 100))
	end
	Game.searchProgress = Game.searchProgress + searchGain
	if Game.searchProgress >= 100 then
		getBoxButton.alpha = 1
		searchPerSecondText.alpha = 0
		searchGainText.alpha = 0
	end
	if Game.searchProgress >= Game.searchBarLimit then
		Game.searchProgress = Game.searchBarLimit
	end
	updateProgressBar()
end
local function drawEarnCashBox(sceneGroup)
	local box = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, 10, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, display.safeActualContentHeight * 0.48, Lang.main.earncash)
	coinContainer = display.newContainer(box.width * 0.33, box.height)
	coinContainer.anchorX = 0
	coinContainer.anchorY = 0
	coinContainer:translate(box.x, box.y)
	sceneGroup:insert(coinContainer)
	cashBagTrigger = display.newRect(sceneGroup, box.x, box.y, box.width, box.height)
	cashBagTrigger.isHitTestable = true
	cashBagTrigger:setFillColor(0, 0, 0, 0)
	cashBagTrigger:addEventListener("touch", onCashBagClick)
	local topGroup = display.newGroup()
	sceneGroup:insert(topGroup)
	cashBagImage = display.newImageRect(topGroup, "images/coin2.png", 295.90000000000003, 294.8)
	cashBagImage.anchorX = 0.5
	cashBagImage.anchorY = 0.5
	cashBagImage.x = box.x + box.width * 0.166666666
	cashBagImage.y = box.y + box.height / 2
	combo.coinText = PonyFont.newText({
		parent = topGroup,
		x = cashBagImage.x,
		y = cashBagImage.y + cashBagImage.height / 2 + 17,
		text = "Combo:",
		font = BitmapFont.counterstrike,
		fontSize = 42,
		align = "center"
	})
	combo.coinText:setFillColor(unpack(Color.darkGold))
	combo.coinText.anchorX = 0.5
	combo.coinValueText = PonyFont.newText({
		parent = topGroup,
		x = combo.coinText.x,
		y = combo.coinText.y + 70,
		text = "x1.00",
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	combo.coinValueText:setFillColor(unpack(Color.gold))
	combo.coinValueText.anchorX = 0.5
	combo.coinValueText.anchorY = 0.5
	combo.coinText.alpha = 0
	combo.coinValueText.alpha = 0
	GUI.drawVerticalLine(sceneGroup, box.x + box.width * 0.33, box.y + 10, box.height - 20)
	local earnedText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = box.y + box.height * 0.25,
		text = Lang.main.balance .. ":",
		font = BitmapFont.counterstrike,
		fontSize = 72,
		align = "center"
	})
	earnedText:setFillColor(unpack(Color.lightText))
	earnedText.anchorX = 0.5
	balanceText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = box.y + box.height * 0.5,
		text = "$0.001",
		font = BitmapFont.counterstrike,
		fontSize = 112,
		align = "center"
	})
	balanceText.anchorY = 0.5
	balanceText.anchorX = 0.5
	clickGainText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = balanceText.y + 100,
		text = "$0.01 " .. Lang.main.pertap,
		font = BitmapFont.counterstrike,
		fontSize = 50,
		align = "center"
	})
	clickGainText.anchorY = 0.5
	clickGainText.anchorX = 0.5
	clickGainText:setFillColor(unpack(Color.lightText))
	perSecondGainText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = balanceText.y + 160,
		text = "$" .. Game.moneyPerSecond .. " " .. Lang.main.persecond,
		font = BitmapFont.counterstrike,
		fontSize = 50,
		align = "center"
	})
	perSecondGainText.anchorY = 0.5
	perSecondGainText.anchorX = 0.5
	perSecondGainText:setFillColor(unpack(Color.lightText))
	updateMoneyText()
	box:cornersToFront()
end
local function drawSearchBoxesBox(sceneGroup)
	local boxY = 10 + display.safeActualContentHeight * 0.48 + 10
	local boxHeight = display.safeActualContentHeight - boxY - 10
	box = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, boxY, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, boxHeight, Lang.main.searchforcases)
	caseContainer = display.newContainer(box.width * 0.33, box.height)
	caseContainer.anchorX = 0
	caseContainer.anchorY = 0
	caseContainer:translate(box.x, box.y)
	sceneGroup:insert(caseContainer)
	caseTrigger = display.newRect(sceneGroup, box.x, box.y, box.width, box.height)
	caseTrigger.isHitTestable = true
	caseTrigger:setFillColor(0, 0, 0, 0)
	caseTrigger:addEventListener("touch", onCaseClick)
	local topGroup = display.newGroup()
	sceneGroup:insert(topGroup)
	caseImage = display.newImageRect(sceneGroup, "images/clickcase.png", 375.95, 311.06)
	caseImage.anchorY = 0.5
	caseImage.anchorX = 0.5
	caseImage.x = box.x + box.width * 0.33 / 2
	caseImage.y = box.y + box.height / 2
	combo.caseText = PonyFont.newText({
		parent = topGroup,
		x = cashBagImage.x,
		y = caseImage.y + caseImage.height / 2 + 6,
		text = "Combo:",
		font = BitmapFont.counterstrike,
		fontSize = 42,
		align = "center"
	})
	combo.caseText:setFillColor(unpack(Color.darkGold))
	combo.caseText.anchorX = 0.5
	combo.caseValueText = PonyFont.newText({
		parent = topGroup,
		x = combo.caseText.x,
		y = combo.caseText.y + 70,
		text = "x1.00",
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	combo.caseValueText:setFillColor(unpack(Color.gold))
	combo.caseValueText.anchorX = 0.5
	combo.caseValueText.anchorY = 0.5
	combo.caseText.alpha = 0
	combo.caseValueText.alpha = 0
	GUI.drawVerticalLine(sceneGroup, box.x + box.width * 0.33, box.y + 10, box.height - 20)
	searchProgressText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = box.y + box.height * 0.3,
		text = Lang.main.searchprogress .. ":",
		font = BitmapFont.counterstrike,
		fontSize = 72,
		align = "center"
	})
	searchProgressText:setFillColor(unpack(Color.lightText))
	searchProgressText.anchorX = 0.5
	searchProgressText.anchorY = 0.5
	progressBar = ProgressBar.create(sceneGroup, box.x + box.width * 0.67, box.y + box.height * 0.45, box.width * 0.63, 70, ProgressBarType.default)
	updateProgressBar()
	searchGainText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = box.y + box.height * 0.45 + 70 + 60,
		text = Game.clickSearchGain .. "% " .. Lang.main.pertap,
		font = BitmapFont.counterstrike,
		fontSize = 50,
		align = "center"
	})
	searchGainText.anchorY = 0.5
	searchGainText.anchorX = 0.5
	searchGainText:setFillColor(unpack(Color.lightText))
	searchPerSecondText = PonyFont.newText({
		parent = sceneGroup,
		x = box.x + box.width * 0.66,
		y = searchGainText.y + searchGainText.height + 25,
		text = Game.searchPerSecond .. "% " .. Lang.main.persecond,
		font = BitmapFont.counterstrike,
		fontSize = 50,
		align = "center"
	})
	searchPerSecondText.anchorY = 0.5
	searchPerSecondText.anchorX = 0.5
	searchPerSecondText:setFillColor(unpack(Color.lightText))
	getBoxButton = GUI.createButton(sceneGroup, searchPerSecondText.x - (box.width * 0.63 / 2 + 120) / 2, box.y + box.height * 0.45 + 120, box.width * 0.63 / 2 + 130, 100, Lang.main.getrandomcase, ButtonType.default, function(event)
		getBoxButton.alpha = 0
		Game.searchProgress = Game.searchProgress - 100
		searchGainText.alpha = 0
		searchPerSecondText.alpha = 0
		updateProgressBar()
		Game.showCaseDraw()
		StatisticManager.addStatistic("casesFound")
	end, 55, {blockTime = 500})
	if 100 > Game.searchProgress then
		getBoxButton.alpha = 0
	else
		searchPerSecondText.alpha = 0
		searchGainText.alpha = 0
	end
	updateProgressBar()
	box:cornersToFront()
end
function scene:create(event)
	local sceneGroup = self.view
	drawEarnCashBox(sceneGroup)
	drawSearchBoxesBox(sceneGroup)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		updateMoneyText()
		updateSearchText()
		updateProgressBar()
		timer.performWithDelay(750, updateLoop)
		workingLoops = workingLoops + 1
		resetCombo()
	elseif phase == "did" then
		Runtime:addEventListener("enterFrame", onEnterFrameMain)
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("enterFrame", onEnterFrameMain)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
