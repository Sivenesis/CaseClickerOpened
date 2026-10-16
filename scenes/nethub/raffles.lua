local composer = require("composer")
local scene = composer.newScene()
local pointsBox, raffleBox, balanceText, watchAdButton, noAdsButton
local updateButtonsTimer
local pointLimit = 50
local pointsPerAD = 2
local pointsBoxHeightMultiplier = 0.35
local winChanceTexts = {}
local rollButtons = {}
local itemPrices = {
	[1] = {
		minPrice = 40,
		maxPrice = 100,
		chancePerTicket = 6
	},
	[2] = {
		minPrice = 100,
		maxPrice = 200,
		chancePerTicket = 4
	},
	[3] = {
		minPrice = 200,
		maxPrice = 1000,
		chancePerTicket = 2
	}
}
local pointsAdded = {
	0,
	0,
	0
}
local function generateRaffleItems()
	Game.raffles = Game.raffles or { lastDay = 0, items = {} }
	Game.raffles.items = {}
	for i = 1, #itemPrices do
		local item = EquipmentManager.getItemWithPrice(itemPrices[i].minPrice, itemPrices[i].maxPrice)
		if item then
			item.received = false
			table.insert(Game.raffles.items, item)
		end
	end
end
local function updateRollButtons()
	for i = 1, #rollButtons do
		rollButtons[i][1].alpha = 0
		rollButtons[i][2].alpha = 0
		if Game.raffles.items[i] and Game.raffles.items[i].received then
			rollButtons[i][2].alpha = 1
		else
			rollButtons[i][1].alpha = 1
		end
	end
end
local function getRaffleAdCooldownLeft()
	Game.others.lastRaffleAdTime = Game.others.lastRaffleAdTime or 0
	local elapsed = os.time() - Game.others.lastRaffleAdTime
	if elapsed < 300 then
		return 300 - elapsed
	end
	return 0
end
local function updateButtons()
	if updateButtonsTimer then
		timer.cancel(updateButtonsTimer)
		updateButtonsTimer = nil
	end
	if composer.getSceneName("current") ~= "scenes.nethub.raffles" then
		return
	end
	if not watchAdButton or not noAdsButton then
		return
	end
	watchAdButton.alpha = 0
	noAdsButton.alpha = 0
	local cooldownLeft = getRaffleAdCooldownLeft()
	if cooldownLeft > 0 then
		local m = math.floor(cooldownLeft / 60)
		local s = cooldownLeft % 60
		if watchAdButton.setText then
			watchAdButton:setText(string.format("Cooldown (%d:%02d)", m, s))
		end
	else
		if watchAdButton.setText then
			watchAdButton:setText(Lang.raffles.watchAd)
		end
	end
	if ADS.isAvailable() then
		watchAdButton.alpha = 1
	else
		noAdsButton.alpha = 1
	end
	updateButtonsTimer = timer.performWithDelay(1000, updateButtons)
end
local function updateBalance()
	local pointsLeft = Raffles.points
	for i = 1, #pointsAdded do
		pointsLeft = pointsLeft - pointsAdded[i]
	end
	balanceText.text = commaValue(pointsLeft) .. " " .. Lang.raffles.points
end
local function drawpointsBox()
	local sceneGroup = scene.view
	pointsBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, 10, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, display.safeActualContentHeight * pointsBoxHeightMultiplier, Lang.raffles.points)
	local mainText = display.newText({
		parent = sceneGroup,
		x = getCenterX(pointsBox),
		y = pointsBox.y + 50,
		text = Lang.casino.yourBalance .. ":",
		font = Font.counterstrike,
		fontSize = 66,
		align = "center"
	})
	mainText.anchorX = 0.5
	FontOffset.setOffset(mainText)
	balanceText = display.newText({
		parent = sceneGroup,
		x = getCenterX(pointsBox),
		y = mainText.y + 76,
		text = "",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	balanceText.anchorX = 0.5
	balanceText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(balanceText)
	local watchAdsText = display.newText({
		parent = sceneGroup,
		x = getCenterX(pointsBox),
		y = mainText.y + 166,
		text = Lang.raffles.watchAdsText,
		font = Font.counterstrike,
		fontSize = 58,
		align = "center"
	})
	watchAdsText.anchorX = 0.5
	FontOffset.setOffset(watchAdsText)
	watchAdButton = GUI.createButton(sceneGroup, getCenterX(pointsBox) - 250, pointsBox.y + pointsBox.height - 80 - 35, 500, 80, Lang.raffles.watchAd, ButtonType.green, function(event)
		local cooldownLeft = getRaffleAdCooldownLeft()
		if cooldownLeft > 0 then
			local m = math.floor(cooldownLeft / 60)
			local s = cooldownLeft % 60
			return GUI.showMessageBox("Cooldown", string.format("Please wait %d:%02d before watching another ad for raffle points.", m, s))
		end
		if pointsPerAD + Raffles.points > pointLimit then
			return GUI.showMessageBox(Lang.common.error, Lang.raffles.pointLimitMsg)
		end
		ADS.showAd(function()
			Game.others.lastRaffleAdTime = os.time()
			Game.save()
			Raffles.addPoints(pointsPerAD, function()
				updateButtons()
				updateBalance()
			end)
		end)
	end, 50, {blockTime = 300})
	noAdsButton = GUI.createButton(sceneGroup, getCenterX(pointsBox) - 250, pointsBox.y + pointsBox.height - 80 - 35, 500, 80, Lang.raffles.noAdsAvailable, ButtonType.red, function(event)
	end, 50, {blockTime = 300})
end
local function drawRaffleBox()
	local sceneGroup = scene.view
	local boxY = 20 + display.safeActualContentHeight * pointsBoxHeightMultiplier + 20
	local boxHeight = display.safeActualContentHeight - boxY - 20
	raffleBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, boxY, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, boxHeight, Lang.raffles.todayRaffles)
	local todayRaffles = display.newText({
		parent = sceneGroup,
		x = getCenterX(raffleBox),
		y = raffleBox.y + 50,
		text = Lang.raffles.todayRaffles .. ":",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	todayRaffles.anchorX = 0.5
	FontOffset.setOffset(todayRaffles)
	local xBoxDistance = 400
	for i = 1, #Game.raffles.items do
		local item = Game.raffles.items[i]
		local itemBox = GUI.createItemBox(sceneGroup, item, getCenterX(raffleBox) - xBoxDistance + xBoxDistance * (i - 1), todayRaffles.y + 90, item.statTrak, 1, {
			pattern = item.pattern,
			showQuality = true,
			dontUseGUIScale = true,
			quality = item.quality,
			showPrice = true
		})
		itemBox.x = itemBox.x - itemBox.width / 2
		local slider = TextSlider.createValueSlider(sceneGroup, itemBox.x, itemBox.y + itemBox.height, 345, 80, function(actualValue, valueChange)
			local pointsLeft = Raffles.points
			for i = 1, #pointsAdded do
				pointsLeft = pointsLeft - pointsAdded[i]
			end
			if actualValue + valueChange < 0 or pointsLeft <= 0 and 0 < valueChange then
				return false
			end
			if Game.raffles.items[i].received then
				return false
			end
			local newWinChance = itemPrices[i].chancePerTicket * (actualValue + valueChange)
			if 100 < newWinChance then
				return false
			end
			pointsAdded[i] = pointsAdded[i] + valueChange
			updateBalance()
			winChanceTexts[i].text = Lang.raffles.winChance .. ": " .. newWinChance .. "%"
			return true
		end, 0, 40)
		winChanceTexts[i] = display.newText({
			parent = sceneGroup,
			x = itemBox.x + itemBox.width / 2,
			y = itemBox.y + itemBox.height + 180,
			text = Lang.raffles.winChance .. ": 0%",
			font = Font.counterstrike,
			fontSize = 42,
			align = "center"
		})
		winChanceTexts[i].anchorX = 0.5
		FontOffset.setOffset(winChanceTexts[i])
		rollButtons[i] = {}
		rollButtons[i][1] = GUI.createButton(sceneGroup, itemBox.x, itemBox.y + itemBox.height + 80, 345, 70, Lang.raffles.start, ButtonType.green, function(event)
			if pointsAdded[i] <= 0 then
				return GUI.showMessageBox(Lang.common.info, Lang.raffles.notEnoughTicketsMsg)
			end
			Raffles.usePoints(pointsAdded[i], function()
				slider:setDefaultValue()
				local pAdded = pointsAdded[i]
				pointsAdded[i] = 0
				GUI.showMessageBox(Lang.raffles.checking, Lang.common.pleaseWait, false)
				timer.performWithDelay(math.random(4, 12) * 100, function()
					local chance = pAdded * itemPrices[i].chancePerTicket
					local win = chance >= math.random(1, 100)
					if win then
						Game.raffles.items[i].received = true
						Game.addItem(Game.raffles.items[i], true, Game.raffles.items[i].statTrak, true, {
							quality = Game.raffles.items[i].quality,
							pattern = Game.raffles.items[i].pattern
						})
					else
						GUI.showMessageBox(Lang.raffles.result, Lang.raffles.lostMsg)
					end
					updateRollButtons()
					updateBalance()
					winChanceTexts[i].text = Lang.raffles.winChance .. ": 0%"
				end)
			end)
		end, 50, {blockTime = 600})
		rollButtons[i][2] = GUI.createButton(sceneGroup, itemBox.x, itemBox.y + itemBox.height + 80, 345, 70, Lang.raffles.received .. "!", ButtonType.default, function(event)
		end, 50)
	end
	updateRollButtons()
end
function scene:create(event)
	local sceneGroup = self.view
	pointLimit = (event and event.params and event.params.pointLimit) or 100
	drawpointsBox()
	updateBalance()
	updateButtons()
	Game.raffles = Game.raffles or { lastDay = 0, items = {} }
	Game.raffles.items = Game.raffles.items or {}
	local currentDay = (event and event.params and event.params.day) or tonumber(os.date("%j")) or 1
	if currentDay ~= Game.raffles.lastDay or #Game.raffles.items == 0 then
		generateRaffleItems()
		Game.raffles.lastDay = currentDay
	end
	drawRaffleBox()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		if updateButtonsTimer then
			timer.cancel(updateButtonsTimer)
			updateButtonsTimer = nil
		end
	elseif phase == "did" then
		composer.removeScene("scenes.nethub.raffles")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
